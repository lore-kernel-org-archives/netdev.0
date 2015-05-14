From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH 1/3] ipv6: make inet6addr_chain blocking and always call
 with rtnl locked
Date: Thu, 14 May 2015 16:56:18 +0300
Message-ID: <20150514135618.14062.1969.stgit@buzz>
References: <20150514134657.14062.87579.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>, Jiri Benc <jbenc@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1m.cmail.yandex.net ([5.255.216.100]:44699 "EHLO
	forward-corp1m.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933073AbbENN4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 09:56:24 -0400
In-Reply-To: <20150514134657.14062.87579.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike to inetaddr_chain inet6addr_chain is atomic and called from bh
context without rtnl when ipv6 receives router advertisement packet.

Several drivers don't know about that: ipvlan thinks that it has rtnl
here, ocrdma locks mutex inside callback. Probably there is more.

This patch makes it blocking and calls from first stage of DAD work.
Looks like this is completely safe and rtnl already locked here.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

---

Splash in ipvlan when ipv6 addrconf got RA:

[   44.673784] RTNL: assertion failed at drivers/net/ipvlan/ipvlan_core.c (114)
[   44.674761] CPU: 0 PID: 3 Comm: ksoftirqd/0 Not tainted 4.1.0-rc3+ #69
[   44.674763] Hardware name: OpenStack Foundation OpenStack Nova, BIOS Bochs 01/01/2011
[   44.674765]  ffff880216273000 ffff88021613b7e8 ffffffff818c6054 ffff88021fc10c10
[   44.674767]  0000000000000000 ffff88021613b818 ffffffff815544e8 0000000000000000
[   44.674769]  ffff8800db5d0000 ffff880216270000 ffff8802162707c0 ffff88021613b848
[   44.674771] Call Trace:
[   44.674787]  [<ffffffff818c6054>] dump_stack+0x45/0x57
[   44.674800]  [<ffffffff815544e8>] ipvlan_addr_busy+0x98/0xa0
[   44.674802]  [<ffffffff81555755>] ipvlan_addr6_event+0x115/0x200
[   44.674810]  [<ffffffff810733fd>] notifier_call_chain+0x4d/0x70
[   44.674812]  [<ffffffff81073445>] atomic_notifier_call_chain+0x15/0x20
[   44.674829]  [<ffffffff817dbb16>] inet6addr_notifier_call_chain+0x16/0x20
[   44.674836]  [<ffffffff817a46c0>] ipv6_add_addr+0xa0/0x420
[   44.674838]  [<ffffffff817aa058>] addrconf_prefix_rcv+0x568/0x7d0
[   44.674842]  [<ffffffff817b7bad>] ndisc_rcv+0x8ad/0xf40
[   44.674845]  [<ffffffff817bec10>] icmpv6_rcv+0x430/0x870
[   44.674847]  [<ffffffff817dbd56>] ? ipv6_skip_exthdr+0x46/0x170
[   44.674850]  [<ffffffff818cfe79>] ? _raw_read_unlock_bh+0x19/0x20
[   44.674852]  [<ffffffff817c33f0>] ? ipv6_chk_mcast_addr+0x110/0x130
[   44.674854]  [<ffffffff817a1ffb>] ip6_input_finish+0x11b/0x3e0
[   44.674855]  [<ffffffff817a281a>] ip6_input+0x6a/0x80
[   44.674857]  [<ffffffff817c330a>] ? ipv6_chk_mcast_addr+0x2a/0x130
[   44.674859]  [<ffffffff817a1ee0>] ? ip6_rcv_finish+0xa0/0xa0
[   44.674860]  [<ffffffff817a28c0>] ip6_mc_input+0x90/0xb0
[   44.674861]  [<ffffffff817a1edd>] ip6_rcv_finish+0x9d/0xa0
[   44.674863]  [<ffffffff817a2602>] ipv6_rcv+0x342/0x4f0
[   44.674864]  [<ffffffff817a1e40>] ? ip6_make_skb+0x1a0/0x1a0
[   44.674873]  [<ffffffff816dc876>] __netif_receive_skb_core+0x216/0x900
[   44.674877]  [<ffffffff8155ce00>] ? virtnet_receive+0x170/0x750
[   44.674879]  [<ffffffff816dcf81>] __netif_receive_skb+0x21/0x70
[   44.674880]  [<ffffffff816dd06d>] process_backlog+0x9d/0x140
[   44.674882]  [<ffffffff816dd896>] net_rx_action+0x146/0x330
[   44.674884]  [<ffffffff81089baa>] ? pick_next_task_fair+0x47a/0x490
[   44.674887]  [<ffffffff81059e37>] __do_softirq+0xe7/0x2e0
[   44.674888]  [<ffffffff8105a04b>] run_ksoftirqd+0x1b/0x60
[   44.674890]  [<ffffffff810758c6>] smpboot_thread_fn+0x116/0x170
[   44.674891]  [<ffffffff810757b0>] ? sort_range+0x20/0x20
[   44.674893]  [<ffffffff81072924>] kthread+0xc4/0xe0
[   44.674895]  [<ffffffff81000303>] ? do_one_initcall+0xb3/0x1c0
[   44.674897]  [<ffffffff81072860>] ? flush_kthread_worker+0x90/0x90
[   44.674899]  [<ffffffff818d07e2>] ret_from_fork+0x42/0x70
[   44.674901]  [<ffffffff81072860>] ? flush_kthread_worker+0x90/0x90
---
 net/ipv6/addrconf.c      |    7 ++++---
 net/ipv6/addrconf_core.c |    8 ++++----
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 37b70e82bff8..61512e10ec92 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -910,9 +910,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 out2:
 	rcu_read_unlock_bh();
 
-	if (likely(err == 0))
-		inet6addr_notifier_call_chain(NETDEV_UP, ifa);
-	else {
+	if (err) {
 		kfree(ifa);
 		ifa = ERR_PTR(err);
 	}
@@ -2735,6 +2733,7 @@ static void add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 		spin_lock_bh(&ifp->lock);
 		ifp->flags &= ~IFA_F_TENTATIVE;
 		spin_unlock_bh(&ifp->lock);
+		inet6addr_notifier_call_chain(NETDEV_UP, ifp);
 		ipv6_ifa_notify(RTM_NEWADDR, ifp);
 		in6_ifa_put(ifp);
 	}
@@ -3415,6 +3414,8 @@ static void addrconf_dad_begin(struct inet6_ifaddr *ifp)
 	struct inet6_dev *idev = ifp->idev;
 	struct net_device *dev = idev->dev;
 
+	inet6addr_notifier_call_chain(NETDEV_UP, ifp);
+
 	addrconf_join_solict(dev, &ifp->addr);
 
 	prandom_seed((__force u32) ifp->addr.s6_addr32[3]);
diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index d873ceea86e6..6997bd7946d3 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -87,23 +87,23 @@ int __ipv6_addr_type(const struct in6_addr *addr)
 }
 EXPORT_SYMBOL(__ipv6_addr_type);
 
-static ATOMIC_NOTIFIER_HEAD(inet6addr_chain);
+static BLOCKING_NOTIFIER_HEAD(inet6addr_chain);
 
 int register_inet6addr_notifier(struct notifier_block *nb)
 {
-	return atomic_notifier_chain_register(&inet6addr_chain, nb);
+	return blocking_notifier_chain_register(&inet6addr_chain, nb);
 }
 EXPORT_SYMBOL(register_inet6addr_notifier);
 
 int unregister_inet6addr_notifier(struct notifier_block *nb)
 {
-	return atomic_notifier_chain_unregister(&inet6addr_chain, nb);
+	return blocking_notifier_chain_unregister(&inet6addr_chain, nb);
 }
 EXPORT_SYMBOL(unregister_inet6addr_notifier);
 
 int inet6addr_notifier_call_chain(unsigned long val, void *v)
 {
-	return atomic_notifier_call_chain(&inet6addr_chain, val, v);
+	return blocking_notifier_call_chain(&inet6addr_chain, val, v);
 }
 EXPORT_SYMBOL(inet6addr_notifier_call_chain);
 
