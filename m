From: Eric Dumazet <erdnetdev@gmail.com>
Subject: [PATCH] ipv4: arp: fix a lockdep splat in arp_solicit()
Date: Fri, 21 Dec 2012 09:32:10 -0800
Message-ID: <1356111130.21834.7565.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:59745 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983Ab2LURcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 12:32:13 -0500
Received: by mail-pa0-f44.google.com with SMTP id hz11so2959896pad.31
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 09:32:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Yan Burman reported following lockdep warning :

=============================================
[ INFO: possible recursive locking detected ]
3.7.0+ #24 Not tainted
---------------------------------------------
swapper/1/0 is trying to acquire lock:
  (&n->lock){++--..}, at: [<ffffffff8139f56e>] __neigh_event_send
+0x2e/0x2f0

but task is already holding lock:
  (&n->lock){++--..}, at: [<ffffffff813f63f4>] arp_solicit+0x1d4/0x280

other info that might help us debug this:
  Possible unsafe locking scenario:

        CPU0
        ----
   lock(&n->lock);
   lock(&n->lock);

  *** DEADLOCK ***

  May be due to missing lock nesting notation

4 locks held by swapper/1/0:
  #0:  (((&n->timer))){+.-...}, at: [<ffffffff8104b350>] 
call_timer_fn+0x0/0x1c0
  #1:  (&n->lock){++--..}, at: [<ffffffff813f63f4>] arp_solicit
+0x1d4/0x280
  #2:  (rcu_read_lock_bh){.+....}, at: [<ffffffff81395400>] 
dev_queue_xmit+0x0/0x5d0
  #3:  (rcu_read_lock_bh){.+....}, at: [<ffffffff813cb41e>] 
ip_finish_output+0x13e/0x640

stack backtrace:
Pid: 0, comm: swapper/1 Not tainted 3.7.0+ #24
Call Trace:
  <IRQ>  [<ffffffff8108c7ac>] validate_chain+0xdcc/0x11f0
  [<ffffffff8108d570>] ? __lock_acquire+0x440/0xc30
  [<ffffffff81120565>] ? kmem_cache_free+0xe5/0x1c0
  [<ffffffff8108d570>] __lock_acquire+0x440/0xc30
  [<ffffffff813c3570>] ? inet_getpeer+0x40/0x600
  [<ffffffff8108d570>] ? __lock_acquire+0x440/0xc30
  [<ffffffff8139f56e>] ? __neigh_event_send+0x2e/0x2f0
  [<ffffffff8108ddf5>] lock_acquire+0x95/0x140
  [<ffffffff8139f56e>] ? __neigh_event_send+0x2e/0x2f0
  [<ffffffff8108d570>] ? __lock_acquire+0x440/0xc30
  [<ffffffff81448d4b>] _raw_write_lock_bh+0x3b/0x50
  [<ffffffff8139f56e>] ? __neigh_event_send+0x2e/0x2f0
  [<ffffffff8139f56e>] __neigh_event_send+0x2e/0x2f0
  [<ffffffff8139f99b>] neigh_resolve_output+0x16b/0x270
  [<ffffffff813cb62d>] ip_finish_output+0x34d/0x640
  [<ffffffff813cb41e>] ? ip_finish_output+0x13e/0x640
  [<ffffffffa046f146>] ? vxlan_xmit+0x556/0xbec [vxlan]
  [<ffffffff813cb9a0>] ip_output+0x80/0xf0
  [<ffffffff813ca368>] ip_local_out+0x28/0x80
  [<ffffffffa046f25a>] vxlan_xmit+0x66a/0xbec [vxlan]
  [<ffffffffa046f146>] ? vxlan_xmit+0x556/0xbec [vxlan]
  [<ffffffff81394a50>] ? skb_gso_segment+0x2b0/0x2b0
  [<ffffffff81449355>] ? _raw_spin_unlock_irqrestore+0x65/0x80
  [<ffffffff81394c57>] ? dev_queue_xmit_nit+0x207/0x270
  [<ffffffff813950c8>] dev_hard_start_xmit+0x298/0x5d0
  [<ffffffff813956f3>] dev_queue_xmit+0x2f3/0x5d0
  [<ffffffff81395400>] ? dev_hard_start_xmit+0x5d0/0x5d0
  [<ffffffff813f5788>] arp_xmit+0x58/0x60
  [<ffffffff813f59db>] arp_send+0x3b/0x40
  [<ffffffff813f6424>] arp_solicit+0x204/0x280
  [<ffffffff813a1a70>] ? neigh_add+0x310/0x310
  [<ffffffff8139f515>] neigh_probe+0x45/0x70
  [<ffffffff813a1c10>] neigh_timer_handler+0x1a0/0x2a0
  [<ffffffff8104b3cf>] call_timer_fn+0x7f/0x1c0
  [<ffffffff8104b350>] ? detach_if_pending+0x120/0x120
  [<ffffffff8104b748>] run_timer_softirq+0x238/0x2b0
  [<ffffffff813a1a70>] ? neigh_add+0x310/0x310
  [<ffffffff81043e51>] __do_softirq+0x101/0x280
  [<ffffffff814518cc>] call_softirq+0x1c/0x30
  [<ffffffff81003b65>] do_softirq+0x85/0xc0
  [<ffffffff81043a7e>] irq_exit+0x9e/0xc0
  [<ffffffff810264f8>] smp_apic_timer_interrupt+0x68/0xa0
  [<ffffffff8145122f>] apic_timer_interrupt+0x6f/0x80
  <EOI>  [<ffffffff8100a054>] ? mwait_idle+0xa4/0x1c0
  [<ffffffff8100a04b>] ? mwait_idle+0x9b/0x1c0
  [<ffffffff8100a6a9>] cpu_idle+0x89/0xe0
  [<ffffffff81441127>] start_secondary+0x1b2/0x1b6


Bug is from arp_solicit(), releasing the neigh lock after arp_send()
In case of vxlan, we eventually need to write lock a neigh lock later.

Its a false positive, but we can get rid of it without lockdep
annotations.

We can instead use neigh_ha_snapshot() helper.

Reported-by: Yan Burman <yanb@mellanox.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
---
 net/ipv4/arp.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index ce6fbdf..1169ed4 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -321,7 +321,7 @@ static void arp_error_report(struct neighbour *neigh, struct sk_buff *skb)
 static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 {
 	__be32 saddr = 0;
-	u8  *dst_ha = NULL;
+	u8 dst_ha[MAX_ADDR_LEN];
 	struct net_device *dev = neigh->dev;
 	__be32 target = *(__be32 *)neigh->primary_key;
 	int probes = atomic_read(&neigh->probes);
@@ -363,9 +363,9 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	if (probes < 0) {
 		if (!(neigh->nud_state & NUD_VALID))
 			pr_debug("trying to ucast probe in NUD_INVALID\n");
-		dst_ha = neigh->ha;
-		read_lock_bh(&neigh->lock);
+		neigh_ha_snapshot(dst_ha, neigh, dev);
 	} else {
+		memset(dst_ha, 0, dev->addr_len);
 		probes -= neigh->parms->app_probes;
 		if (probes < 0) {
 #ifdef CONFIG_ARPD
@@ -377,8 +377,6 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 
 	arp_send(ARPOP_REQUEST, ETH_P_ARP, target, dev, saddr,
 		 dst_ha, dev->dev_addr, NULL);
-	if (dst_ha)
-		read_unlock_bh(&neigh->lock);
 }
 
 static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)
