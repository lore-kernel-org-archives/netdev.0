From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Sat, 24 Oct 2009 06:35:53 +0200
Message-ID: <4AE28429.6040608@gmail.com>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org> <200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com> <20091023211338.GA6145@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org,
	Cosmin Ratiu <cratiu@ixiacom.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57774 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbZJXEf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 00:35:57 -0400
In-Reply-To: <20091023211338.GA6145@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney a =E9crit :
> On Wed, Oct 21, 2009 at 05:40:07PM +0200, Eric Dumazet wrote:
>> [PATCH] net: allow netdev_wait_allrefs() to run faster
>>
>> netdev_wait_allrefs() waits that all references to a device vanishes=
=2E
>>
>> It currently uses a _very_ pessimistic 250 ms delay between each pro=
be.
>> Some users report that no more than 4 devices can be dismantled per =
second,
>> this is a pretty serious problem for extreme setups.
>>
>> Most likely, references only wait for a rcu grace period that should=
 come
>> fast, so use a schedule_timeout_uninterruptible(1) to allow faster r=
ecovery.
>=20
> Is this a place where synchronize_rcu_expedited() is appropriate?
> (It went in to 2.6.32-rc1.)
>=20

Thanks for the tip Paul

I believe netdev_wait_allrefs() is not a perfect candidate, because=20
synchronize_sched_expedited() seems really expensive.

Maybe we could call it once only, if we had to call 1 times
the jiffie delay ?

diff --git a/net/core/dev.c b/net/core/dev.c
index fa88dcd..9b04b9a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4970,6 +4970,7 @@ EXPORT_SYMBOL(register_netdev);
 static void netdev_wait_allrefs(struct net_device *dev)
 {
 	unsigned long rebroadcast_time, warning_time;
+	unsigned int count =3D 0;
=20
 	rebroadcast_time =3D warning_time =3D jiffies;
 	while (atomic_read(&dev->refcnt) !=3D 0) {
@@ -4995,7 +4996,10 @@ static void netdev_wait_allrefs(struct net_devic=
e *dev)
 			rebroadcast_time =3D jiffies;
 		}
=20
-		msleep(250);
+		if (count++ =3D=3D 1)
+			synchronize_rcu_expedited();
+		else
+			schedule_timeout_uninterruptible(1);
=20
 		if (time_after(jiffies, warning_time + 10 * HZ)) {
 			printk(KERN_EMERG "unregister_netdevice: "

