From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: sleeping function called from invalid context in
 net_enable_timestamp
Date: Wed, 01 Mar 2017 12:07:59 -0800
Message-ID: <1488398879.9415.302.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+bHh=mzTXw1J8vxbzimrQULss16B=693T4SMcndoNoPPg@mail.gmail.com>
         <CANn89iL8XLopw+grdzMW6_vabiQjKrVL_q-u4-b1XcL_uRAPUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34323 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751810AbdCAVRZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 16:17:25 -0500
In-Reply-To: <CANn89iL8XLopw+grdzMW6_vabiQjKrVL_q-u4-b1XcL_uRAPUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-01 at 11:59 -0800, Eric Dumazet wrote:
> On Wed, Mar 1, 2017 at 11:51 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> >
> > Hello,
> >
> > I've got the following report while running syzkaller fuzzer on
> > e5d56efc97f8240d0b5d66c03949382b6d7e5570
> 
> 
> 
> Right, a listener is playing fool games.
> 
> We need to use a work queue for all net_enable_timestamp() invocations

Something like :

diff --git a/net/core/dev.c b/net/core/dev.c
index e63bf61b19be029e30ac40443c0e2edb24de4a73..10fac295f4d4dff983156e2cac22456db948b32b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1702,15 +1702,27 @@ static void netstamp_clear(struct work_struct *work)
 {
 	int deferred = atomic_xchg(&netstamp_needed_deferred, 0);
 
-	while (deferred--)
+	while (deferred < 0) {
+		deferred++;
 		static_key_slow_dec(&netstamp_needed);
+	}
+	while (deferred > 0) {
+		deferred--;
+		static_key_slow_inc(&netstamp_needed);
+	}
 }
 static DECLARE_WORK(netstamp_work, netstamp_clear);
 #endif
 
 void net_enable_timestamp(void)
 {
+#ifdef HAVE_JUMP_LABEL
+	/* net_enable_timestamp() can be called from non process context */
+	atomic_inc(&netstamp_needed_deferred);
+	schedule_work(&netstamp_work);
+#else
 	static_key_slow_inc(&netstamp_needed);
+#endif
 }
 EXPORT_SYMBOL(net_enable_timestamp);
 
@@ -1718,7 +1730,7 @@ void net_disable_timestamp(void)
 {
 #ifdef HAVE_JUMP_LABEL
 	/* net_disable_timestamp() can be called from non process context */
-	atomic_inc(&netstamp_needed_deferred);
+	atomic_dec(&netstamp_needed_deferred);
 	schedule_work(&netstamp_work);
 #else
 	static_key_slow_dec(&netstamp_needed);
