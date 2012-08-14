From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net] ipv6: addrconf: Avoid calling netdevice notifiers with
 RCU read-side lock
Date: Tue, 14 Aug 2012 19:54:51 +0100
Message-ID: <1344970491.2690.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <1344940096-5548-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <edumazet@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Cong Wang <amwang@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:48950 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756069Ab2HNSy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 14:54:56 -0400
In-Reply-To: <1344940096-5548-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang reports that lockdep detected suspicious RCU usage while
enabling IPV6 forwarding:

 [ 1123.310275] ===============================
 [ 1123.442202] [ INFO: suspicious RCU usage. ]
 [ 1123.558207] 3.6.0-rc1+ #109 Not tainted
 [ 1123.665204] -------------------------------
 [ 1123.768254] include/linux/rcupdate.h:430 Illegal context switch in RCU read-side critical section!
 [ 1123.992320]
 [ 1123.992320] other info that might help us debug this:
 [ 1123.992320]
 [ 1124.307382]
 [ 1124.307382] rcu_scheduler_active = 1, debug_locks = 0
 [ 1124.522220] 2 locks held by sysctl/5710:
 [ 1124.648364]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81768498>] rtnl_trylock+0x15/0x17
 [ 1124.882211]  #1:  (rcu_read_lock){.+.+.+}, at: [<ffffffff81871df8>] rcu_lock_acquire+0x0/0x29
 [ 1125.085209]
 [ 1125.085209] stack backtrace:
 [ 1125.332213] Pid: 5710, comm: sysctl Not tainted 3.6.0-rc1+ #109
 [ 1125.441291] Call Trace:
 [ 1125.545281]  [<ffffffff8109d915>] lockdep_rcu_suspicious+0x109/0x112
 [ 1125.667212]  [<ffffffff8107c240>] rcu_preempt_sleep_check+0x45/0x47
 [ 1125.781838]  [<ffffffff8107c260>] __might_sleep+0x1e/0x19b
[...]
 [ 1127.445223]  [<ffffffff81757ac5>] call_netdevice_notifiers+0x4a/0x4f
[...]
 [ 1127.772188]  [<ffffffff8175e125>] dev_disable_lro+0x32/0x6b
 [ 1127.885174]  [<ffffffff81872d26>] dev_forward_change+0x30/0xcb
 [ 1128.013214]  [<ffffffff818738c4>] addrconf_forward_change+0x85/0xc5
[...]

addrconf_forward_change() uses RCU iteration over the netdev list,
which is unnecessary since it already holds the RTNL lock.  We also
cannot reasonably require netdevice notifier functions not to sleep.

Reported-by: Cong Wang <amwang@redhat.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/ipv6/addrconf.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 7918181..6bc85f7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -494,8 +494,7 @@ static void addrconf_forward_change(struct net *net, __s32 newf)
 	struct net_device *dev;
 	struct inet6_dev *idev;
 
-	rcu_read_lock();
-	for_each_netdev_rcu(net, dev) {
+	for_each_netdev(net, dev) {
 		idev = __in6_dev_get(dev);
 		if (idev) {
 			int changed = (!idev->cnf.forwarding) ^ (!newf);
@@ -504,7 +503,6 @@ static void addrconf_forward_change(struct net *net, __s32 newf)
 				dev_forward_change(idev);
 		}
 	}
-	rcu_read_unlock();
 }
 
 static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int newf)
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
