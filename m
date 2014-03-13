From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RCU PATCH 06/14] net: sched: fw use RCU
Date: Thu, 13 Mar 2014 13:22:46 -0700
Message-ID: <20140313202245.GK21124@linux.vnet.ibm.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
 <20140310170546.3011.82918.stgit@nitbit.x32>
 <1394473279.3607.46.camel@edumazet-glaptop2.roam.corp.google.com>
 <53208E3F.5090401@gmail.com>
 <1394643673.21721.48.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.fastabend@gmail.com>,
	xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:33795 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755032AbaCMUWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 16:22:50 -0400
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 13 Mar 2014 14:22:49 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id A26D619D8058
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2014 14:22:44 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2DKM7xj10617334
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2014 21:22:07 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s2DKQK9u024577
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2014 14:26:20 -0600
Content-Disposition: inline
In-Reply-To: <1394643673.21721.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 12, 2014 at 10:01:13AM -0700, Eric Dumazet wrote:
> On Wed, 2014-03-12 at 09:41 -0700, John Fastabend wrote:
>=20
> > Rearranging the rcu_head placement above results in this error:
> >=20
> > net/sched/cls_fw.c: In function =E2=80=98fw_destroy=E2=80=99:
> > net/sched/cls_fw.c:169:279: error: call to =E2=80=98__compiletime_a=
ssert_169=E2=80=99=20
> > declared with attribute error: BUILD_BUG_ON failed:=20
> > !__is_kfree_rcu_offset(__builtin_offsetof(typeof(*(head)),rcu))
> >=20
> >=20
> > However it seems best to have the rcu_head at the end of the struct
> > so I'll just convert the kfree_rcu() to call_rcu().
>=20
>=20
> I missed HTSIZE was so big.
>=20
> Its unfortunate because it makes struct fw_head slightly larger than =
one
> page.

Hmmm...  You know, the offset that kfree uses is a byte offset.  I see
no reason why any of the rcu_head structures should be misaligned.  If
HTSIZE is too big by only a factor of four or smaller, would the follow=
ing
(untested) patch to RCU be appropriate?

							Thanx, Paul

-----------------------------------------------------------------------=
-

rcu: Increase kfree_rcu() offset range

The kfree_rcu() function operates by placing an offset into the rcu_hea=
d
structure in place of the function pointer that is normally there.
This offset cannot exceed 4095, on the theory that no Linux kernel will
ever have executable code in page zero.  However, the rcu_head structur=
e
contains a pair of function pointers, and should never be misaligned.
This commit therefore divides the offset by the size of a pointer when
being placed into the rcu_head structure, and multiplies it by this
same constant when pulling it out.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 3cea28c64ebe..2dc4ecf923d0 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -1023,8 +1023,13 @@ static inline notrace void rcu_read_unlock_sched=
_notrace(void)
  * The BUILD_BUG_ON check must not involve any function calls, hence t=
he
  * checks are done in macros here.
  */
-#define kfree_rcu(ptr, rcu_head)					\
-	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
+#define kfree_rcu(ptr, rcu_head) \
+do { \
+	unsigned long ___offset =3D offsetof(typeof(*(ptr)), rcu_head); \
+	\
+	BUILD_BUG_ON(___offset & (sizeof(void *) - 1)); \
+	__kfree_rcu(&((ptr)->rcu_head), ___offset / sizeof(void *)); \
+} while (0)
=20
 #if defined(CONFIG_TINY_RCU) || defined(CONFIG_RCU_NOCB_CPU_ALL)
 static inline int rcu_needs_cpu(int cpu, unsigned long *delta_jiffies)
diff --git a/kernel/rcu/rcu.h b/kernel/rcu/rcu.h
index bfda2726ca45..93dbd98ad6da 100644
--- a/kernel/rcu/rcu.h
+++ b/kernel/rcu/rcu.h
@@ -106,7 +106,7 @@ static inline bool __rcu_reclaim(const char *rn, st=
ruct rcu_head *head)
 	rcu_lock_acquire(&rcu_callback_map);
 	if (__is_kfree_rcu_offset(offset)) {
 		RCU_TRACE(trace_rcu_invoke_kfree_callback(rn, head, offset));
-		kfree((void *)head - offset);
+		kfree((void *)head - offset * sizeof(void *));
 		rcu_lock_release(&rcu_callback_map);
 		return 1;
 	} else {
