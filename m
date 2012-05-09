From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pktgen: fix crash at module unload
Date: Thu, 10 May 2012 01:29:51 +0200
Message-ID: <1336606191.12504.97.camel@edumazet-glaptop>
References: <1336591268.12504.62.camel@edumazet-glaptop>
	 <874nrpyrp1.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:63027 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759025Ab2EIX34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 19:29:56 -0400
Received: by wgbdr13 with SMTP id dr13so786111wgb.1
        for <netdev@vger.kernel.org>; Wed, 09 May 2012 16:29:55 -0700 (PDT)
In-Reply-To: <874nrpyrp1.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-09 at 14:23 -0700, Eric W. Biederman wrote:

> That seems reasonable.
> 
> Would it be easier to call unregister_netdevice_notifer before shutting
> down the threads, so you don't have the weird cases to deal with during
> shutdown?
 
> 
> It looks like pg_cleanup doesn't take the pktgen_thread_lock, so
> I suspect that there are still races.
> 

It was 'safe' because pktgen doesnt yet support cpu hotplug.

Given pktgen nature, I am not sure we should care, granted it doesnt
crash when a poor guy like me want to use it once in a while...

list was modified only at module load.

[PATCH v2] pktgen: fix crash at module unload

commit 7d3d43dab4e9 (net: In unregister_netdevice_notifier unregister
the netdevices.) makes pktgen crashing at module unload.

[  296.820578] BUG: spinlock bad magic on CPU#6, rmmod/3267
[  296.820719]  lock: ffff880310c38000, .magic: ffff8803, .owner: <none>/-1, .owner_cpu: -1
[  296.820943] Pid: 3267, comm: rmmod Not tainted 3.4.0-rc5+ #254
[  296.821079] Call Trace:
[  296.821211]  [<ffffffff8168a715>] spin_dump+0x8a/0x8f
[  296.821345]  [<ffffffff8168a73b>] spin_bug+0x21/0x26
[  296.821507]  [<ffffffff812b4741>] do_raw_spin_lock+0x131/0x140
[  296.821648]  [<ffffffff8169188e>] _raw_spin_lock+0x1e/0x20
[  296.821786]  [<ffffffffa00cc0fd>] __pktgen_NN_threads+0x4d/0x140 [pktgen]
[  296.821928]  [<ffffffffa00ccf8d>] pktgen_device_event+0x10d/0x1e0 [pktgen]
[  296.822073]  [<ffffffff8154ed4f>] unregister_netdevice_notifier+0x7f/0x100
[  296.822216]  [<ffffffffa00d2a0b>] pg_cleanup+0x48/0x73 [pktgen]
[  296.822357]  [<ffffffff8109528e>] sys_delete_module+0x17e/0x2a0
[  296.822502]  [<ffffffff81699652>] system_call_fastpath+0x16/0x1b

Hold the pktgen_thread_lock while splicing pktgen_threads, and test
pktgen_exiting in pktgen_device_event() to make unload faster.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/pktgen.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index ffb5d38..b644505 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1931,7 +1931,7 @@ static int pktgen_device_event(struct notifier_block *unused,
 {
 	struct net_device *dev = ptr;
 
-	if (!net_eq(dev_net(dev), &init_net))
+	if (!net_eq(dev_net(dev), &init_net) || pktgen_exiting)
 		return NOTIFY_DONE;
 
 	/* It is OK that we do not hold the group lock right now,
@@ -3755,12 +3755,18 @@ static void __exit pg_cleanup(void)
 {
 	struct pktgen_thread *t;
 	struct list_head *q, *n;
+	struct list_head list;
 
 	/* Stop all interfaces & threads */
 	pktgen_exiting = true;
 
-	list_for_each_safe(q, n, &pktgen_threads) {
+	mutex_lock(&pktgen_thread_lock);
+	list_splice(&list, &pktgen_threads);
+	mutex_unlock(&pktgen_thread_lock);
+
+	list_for_each_safe(q, n, &list) {
 		t = list_entry(q, struct pktgen_thread, th_list);
+		list_del(&t->th_list);
 		kthread_stop(t->tsk);
 		kfree(t);
 	}
