From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] ipmr, ip6mr: fix scheduling while atomic and a deadlock with ipmr_get_route
Date: Sun, 25 Sep 2016 23:08:31 +0200
Message-ID: <1474837711-19277-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: tgraf@suug.ch, davem@davemloft.net, roopa@cumulusnetworks.com,
        sharpd@cumulusnetworks.com,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37178 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034182AbcIYVIi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 17:08:38 -0400
Received: by mail-wm0-f43.google.com with SMTP id b130so117036013wmc.0
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 14:08:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the commit below the ipmr/ip6mr rtnl_unicast() code uses the portid
instead of the previous dst_pid which was copied from in_skb's portid.
Since the skb is new the portid is 0 at that point so the packets are sent
to the kernel and we get scheduling while atomic or a deadlock (depending
on where it happens) by trying to acquire rtnl two times.
Also since this is RTM_GETROUTE, it can be triggered by a normal user.

Here's the sleeping while atomic trace:
[ 7858.212557] BUG: sleeping function called from invalid context at kernel/locking/mutex.c:620
[ 7858.212748] in_atomic(): 1, irqs_disabled(): 0, pid: 0, name: swapper/0
[ 7858.212881] 2 locks held by swapper/0/0:
[ 7858.213013]  #0:  (((&mrt->ipmr_expire_timer))){+.-...}, at: [<ffffffff810fbbf5>] call_timer_fn+0x5/0x350
[ 7858.213422]  #1:  (mfc_unres_lock){+.....}, at: [<ffffffff8161e005>] ipmr_expire_process+0x25/0x130
[ 7858.213807] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.8.0-rc7+ #179
[ 7858.213934] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[ 7858.214108]  0000000000000000 ffff88005b403c50 ffffffff813a7804 0000000000000000
[ 7858.214412]  ffffffff81a1338e ffff88005b403c78 ffffffff810a4a72 ffffffff81a1338e
[ 7858.214716]  000000000000026c 0000000000000000 ffff88005b403ca8 ffffffff810a4b9f
[ 7858.215251] Call Trace:
[ 7858.215412]  <IRQ>  [<ffffffff813a7804>] dump_stack+0x85/0xc1
[ 7858.215662]  [<ffffffff810a4a72>] ___might_sleep+0x192/0x250
[ 7858.215868]  [<ffffffff810a4b9f>] __might_sleep+0x6f/0x100
[ 7858.216072]  [<ffffffff8165bea3>] mutex_lock_nested+0x33/0x4d0
[ 7858.216279]  [<ffffffff815a7a5f>] ? netlink_lookup+0x25f/0x460
[ 7858.216487]  [<ffffffff8157474b>] rtnetlink_rcv+0x1b/0x40
[ 7858.216687]  [<ffffffff815a9a0c>] netlink_unicast+0x19c/0x260
[ 7858.216900]  [<ffffffff81573c70>] rtnl_unicast+0x20/0x30
[ 7858.217128]  [<ffffffff8161cd39>] ipmr_destroy_unres+0xa9/0xf0
[ 7858.217351]  [<ffffffff8161e06f>] ipmr_expire_process+0x8f/0x130
[ 7858.217581]  [<ffffffff8161dfe0>] ? ipmr_net_init+0x180/0x180
[ 7858.217785]  [<ffffffff8161dfe0>] ? ipmr_net_init+0x180/0x180
[ 7858.217990]  [<ffffffff810fbc95>] call_timer_fn+0xa5/0x350
[ 7858.218192]  [<ffffffff810fbbf5>] ? call_timer_fn+0x5/0x350
[ 7858.218415]  [<ffffffff8161dfe0>] ? ipmr_net_init+0x180/0x180
[ 7858.218656]  [<ffffffff810fde10>] run_timer_softirq+0x260/0x640
[ 7858.218865]  [<ffffffff8166379b>] ? __do_softirq+0xbb/0x54f
[ 7858.219068]  [<ffffffff816637c8>] __do_softirq+0xe8/0x54f
[ 7858.219269]  [<ffffffff8107a948>] irq_exit+0xb8/0xc0
[ 7858.219463]  [<ffffffff81663452>] smp_apic_timer_interrupt+0x42/0x50
[ 7858.219678]  [<ffffffff816625bc>] apic_timer_interrupt+0x8c/0xa0
[ 7858.219897]  <EOI>  [<ffffffff81055f16>] ? native_safe_halt+0x6/0x10
[ 7858.220165]  [<ffffffff810d64dd>] ? trace_hardirqs_on+0xd/0x10
[ 7858.220373]  [<ffffffff810298e3>] default_idle+0x23/0x190
[ 7858.220574]  [<ffffffff8102a20f>] arch_cpu_idle+0xf/0x20
[ 7858.220790]  [<ffffffff810c9f8c>] default_idle_call+0x4c/0x60
[ 7858.221016]  [<ffffffff810ca33b>] cpu_startup_entry+0x39b/0x4d0
[ 7858.221257]  [<ffffffff8164f995>] rest_init+0x135/0x140
[ 7858.221469]  [<ffffffff81f83014>] start_kernel+0x50e/0x51b
[ 7858.221670]  [<ffffffff81f82120>] ? early_idt_handler_array+0x120/0x120
[ 7858.221894]  [<ffffffff81f8243f>] x86_64_start_reservations+0x2a/0x2c
[ 7858.222113]  [<ffffffff81f8257c>] x86_64_start_kernel+0x13b/0x14a

Fixes: 2942e9005056 ("[RTNETLINK]: Use rtnl_unicast() for rtnetlink unicasts")
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
I like this fix better than the alternative to set skb's portid before
calling the get_route. If you prefer that just let me know.

 include/linux/mroute.h  | 2 +-
 include/linux/mroute6.h | 2 +-
 net/ipv4/ipmr.c         | 3 ++-
 net/ipv4/route.c        | 3 ++-
 net/ipv6/ip6mr.c        | 5 +++--
 net/ipv6/route.c        | 4 +++-
 6 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index d351fd3e1049..e5fb81376e92 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -120,5 +120,5 @@ struct mfc_cache {
 struct rtmsg;
 int ipmr_get_route(struct net *net, struct sk_buff *skb,
 		   __be32 saddr, __be32 daddr,
-		   struct rtmsg *rtm, int nowait);
+		   struct rtmsg *rtm, int nowait, u32 portid);
 #endif
diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
index 3987b64040c5..19a1c0c2993b 100644
--- a/include/linux/mroute6.h
+++ b/include/linux/mroute6.h
@@ -116,7 +116,7 @@ struct mfc6_cache {
 
 struct rtmsg;
 extern int ip6mr_get_route(struct net *net, struct sk_buff *skb,
-			   struct rtmsg *rtm, int nowait);
+			   struct rtmsg *rtm, int nowait, u32 portid);
 
 #ifdef CONFIG_IPV6_MROUTE
 extern struct sock *mroute6_socket(struct net *net, struct sk_buff *skb);
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a87bcd2d4a94..5f006e13de56 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2123,7 +2123,7 @@ static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 
 int ipmr_get_route(struct net *net, struct sk_buff *skb,
 		   __be32 saddr, __be32 daddr,
-		   struct rtmsg *rtm, int nowait)
+		   struct rtmsg *rtm, int nowait, u32 portid)
 {
 	struct mfc_cache *cache;
 	struct mr_table *mrt;
@@ -2168,6 +2168,7 @@ int ipmr_get_route(struct net *net, struct sk_buff *skb,
 			return -ENOMEM;
 		}
 
+		NETLINK_CB(skb2).portid = portid;
 		skb_push(skb2, sizeof(struct iphdr));
 		skb_reset_network_header(skb2);
 		iph = ip_hdr(skb2);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index b5b47a26d4ec..62c3ed0b7556 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2503,7 +2503,8 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src, u32 table_id,
 		    IPV4_DEVCONF_ALL(net, MC_FORWARDING)) {
 			int err = ipmr_get_route(net, skb,
 						 fl4->saddr, fl4->daddr,
-						 r, nowait);
+						 r, nowait, portid);
+
 			if (err <= 0) {
 				if (!nowait) {
 					if (err == 0)
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index fccb5dd91902..7f4265b1649b 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2285,8 +2285,8 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 	return 1;
 }
 
-int ip6mr_get_route(struct net *net,
-		    struct sk_buff *skb, struct rtmsg *rtm, int nowait)
+int ip6mr_get_route(struct net *net, struct sk_buff *skb, struct rtmsg *rtm,
+		    int nowait, u32 portid)
 {
 	int err;
 	struct mr6_table *mrt;
@@ -2331,6 +2331,7 @@ int ip6mr_get_route(struct net *net,
 			return -ENOMEM;
 		}
 
+		NETLINK_CB(skb2).portid = portid;
 		skb_reset_transport_header(skb2);
 
 		skb_put(skb2, sizeof(struct ipv6hdr));
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e3a224b97905..269218aacbea 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3202,7 +3202,9 @@ static int rt6_fill_node(struct net *net,
 	if (iif) {
 #ifdef CONFIG_IPV6_MROUTE
 		if (ipv6_addr_is_multicast(&rt->rt6i_dst.addr)) {
-			int err = ip6mr_get_route(net, skb, rtm, nowait);
+			int err = ip6mr_get_route(net, skb, rtm, nowait,
+						  portid);
+
 			if (err <= 0) {
 				if (!nowait) {
 					if (err == 0)
-- 
2.1.4
