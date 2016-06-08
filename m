From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: vrf: Add IFF_NO_QUEUE flag
Date: Wed,  8 Jun 2016 12:08:51 -0700
Message-ID: <1465412931-29567-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35330 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423144AbcFHTJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 15:09:03 -0400
Received: by mail-pf0-f173.google.com with SMTP id c2so5253509pfa.2
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 12:09:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Getting the following splat with ping in a VRF:

[   49.036323] ======================================================
[   49.038300] [ INFO: possible circular locking dependency detected ]
[   49.040313] 4.7.0-rc1+ #252 Not tainted
[   49.041502] -------------------------------------------------------
[   49.043518] ping/2143 is trying to acquire lock:
[   49.044999]  (&(&list->lock)->rlock#3){+.-...}, at: [<ffffffff81407cc5>] __dev_queue_xmit+0x3d3/0x751
[   49.048107]
[   49.048107] but task is already holding lock:
[   49.049844]  (dev->qdisc_running_key ?: &qdisc_running_key){+.-...}, at: [<ffffffff81407d1a>] __dev_queue_xmit+0x428/0x751
[   49.052783]
[   49.052783] which lock already depends on the new lock.
[   49.052783]
[   49.054455]
[   49.054455] the existing dependency chain (in reverse order) is:
[   49.055894]
-> #1 (dev->qdisc_running_key ?: &qdisc_running_key){+.-...}:
[   49.057531]        [<ffffffff810853b7>] __lock_acquire+0x5e4/0x690
[   49.058924]        [<ffffffff81085a32>] lock_acquire+0x140/0x1d8
[   49.060271]        [<ffffffff81401fe6>] write_seqcount_begin+0x21/0x24
[   49.061741]        [<ffffffff81407d1a>] __dev_queue_xmit+0x428/0x751
[   49.062936]        [<ffffffff8140804e>] dev_queue_xmit+0xb/0xd
[   49.064258]        [<ffffffff81411989>] neigh_resolve_output+0x113/0x12e
[   49.065767]        [<ffffffff8149fda9>] ip6_finish_output2+0x39b/0x3ee
[   49.067212]        [<ffffffff814a2472>] ip6_finish_output+0x96/0x9d
[   49.068568]        [<ffffffff814a24f9>] ip6_output+0x80/0xe9
[   49.069789]        [<ffffffff814bf9bc>] dst_output+0x4f/0x56
[   49.070824]        [<ffffffff814c01b6>] mld_sendpack+0x17e/0x1fd
[   49.071964]        [<ffffffff814c17d9>] mld_ifc_timer_expire+0x1ea/0x21e
[   49.073407]        [<ffffffff8109deb9>] call_timer_fn+0x120/0x303
[   49.074551]        [<ffffffff8109e29b>] run_timer_softirq+0x1ae/0x1d8
[   49.075399]        [<ffffffff8105129a>] __do_softirq+0x1c3/0x451
[   49.076217]        [<ffffffff81051744>] irq_exit+0x40/0x94
[   49.076945]        [<ffffffff81031069>] smp_apic_timer_interrupt+0x29/0x34
[   49.077849]        [<ffffffff814f6fac>] apic_timer_interrupt+0x8c/0xa0
[   49.078719]        [<ffffffff8101da2d>] default_idle+0x1f/0x32
[   49.079462]        [<ffffffff8101dfe0>] arch_cpu_idle+0xa/0xc
[   49.080191]        [<ffffffff8107eeca>] default_idle_call+0x1e/0x20
[   49.080989]        [<ffffffff8107f002>] cpu_startup_entry+0x136/0x1ee
[   49.081805]        [<ffffffff814f05b4>] rest_init+0x12b/0x131
[   49.082551]        [<ffffffff81cb8ea2>] start_kernel+0x3da/0x3e7
[   49.083317]        [<ffffffff81cb841b>] x86_64_start_reservations+0x2f/0x31
[   49.084192]        [<ffffffff81cb854a>] x86_64_start_kernel+0x12d/0x13a
[   49.085025]
-> #0 (&(&list->lock)->rlock#3){+.-...}:
[   49.085749]        [<ffffffff8108435a>] validate_chain.isra.37+0x7c8/0xa5b
[   49.086631]        [<ffffffff810853b7>] __lock_acquire+0x5e4/0x690
[   49.087427]        [<ffffffff81085a32>] lock_acquire+0x140/0x1d8
[   49.088194]        [<ffffffff814f5896>] _raw_spin_lock+0x2f/0x65
[   49.088961]        [<ffffffff81407cc5>] __dev_queue_xmit+0x3d3/0x751
[   49.089771]        [<ffffffff8140804e>] dev_queue_xmit+0xb/0xd
[   49.090534]        [<ffffffff8146a633>] arp_xmit+0x32/0x7e
[   49.091238]        [<ffffffff8146a6bb>] arp_send_dst+0x3c/0x42
[   49.091972]        [<ffffffff8146a93c>] arp_solicit+0x27b/0x28e
[   49.092719]        [<ffffffff8140ead8>] neigh_probe+0x4a/0x5e
[   49.093448]        [<ffffffff814100b8>] __neigh_event_send+0x1d0/0x21b
[   49.094305]        [<ffffffff8141012e>] neigh_event_send+0x2b/0x2d
[   49.095080]        [<ffffffff8141188e>] neigh_resolve_output+0x18/0x12e
[   49.095908]        [<ffffffff81441bf2>] ip_finish_output2+0x3c0/0x41c
[   49.096716]        [<ffffffff81442485>] ip_finish_output+0x132/0x13e
[   49.097517]        [<ffffffff814424b2>] NF_HOOK_COND.constprop.43+0x21/0x8a
[   49.098408]        [<ffffffff81443623>] ip_output+0x65/0x6a
[   49.099131]        [<ffffffff814414ed>] dst_output+0x2b/0x30
[   49.099848]        [<ffffffff81442f64>] ip_local_out+0x2a/0x31
[   49.100580]        [<ffffffff81398201>] vrf_xmit+0x149/0x28c
[   49.101294]        [<ffffffff814075f1>] dev_hard_start_xmit+0x154/0x337
[   49.102169]        [<ffffffff8142795e>] sch_direct_xmit+0x98/0x16c
[   49.102948]        [<ffffffff81407d45>] __dev_queue_xmit+0x453/0x751
[   49.103747]        [<ffffffff8140804e>] dev_queue_xmit+0xb/0xd
[   49.104480]        [<ffffffff81411989>] neigh_resolve_output+0x113/0x12e
[   49.105322]        [<ffffffff813976aa>] dst_neigh_output.isra.18+0x13b/0x148
[   49.106204]        [<ffffffff813977bb>] vrf_finish_output+0x104/0x139
[   49.107044]        [<ffffffff81397986>] vrf_output+0x5c/0xc1
[   49.107755]        [<ffffffff814414ed>] dst_output+0x2b/0x30
[   49.108472]        [<ffffffff81442f64>] ip_local_out+0x2a/0x31
[   49.109211]        [<ffffffff81443dd5>] ip_send_skb+0x14/0x38
[   49.109941]        [<ffffffff81443e27>] ip_push_pending_frames+0x2e/0x31
[   49.110792]        [<ffffffff81464a77>] raw_sendmsg+0x788/0x9d2
[   49.111543]        [<ffffffff81471de5>] inet_sendmsg+0x35/0x5c
[   49.112283]        [<ffffffff813ece43>] sock_sendmsg_nosec+0x12/0x1d
[   49.113079]        [<ffffffff813edcf7>] ___sys_sendmsg+0x1b1/0x21f
[   49.113851]        [<ffffffff813ee01c>] __sys_sendmsg+0x40/0x5e
[   49.114609]        [<ffffffff813ee04e>] SyS_sendmsg+0x14/0x16
[   49.115345]        [<ffffffff814f633c>] entry_SYSCALL_64_fastpath+0x1f/0xbd
[   49.116221]
[   49.116221] other info that might help us debug this:
[   49.116221]
[   49.117198]  Possible unsafe locking scenario:
[   49.117198]
[   49.117926]        CPU0                    CPU1
[   49.118503]        ----                    ----
[   49.119059]   lock(dev->qdisc_running_key ?: &qdisc_running_key);
[   49.119839]                                lock(&(&list->lock)->rlock#3);
[   49.120722] lock(dev->qdisc_running_key ?: &qdisc_running_key);
[   49.121800]   lock(&(&list->lock)->rlock#3);
[   49.122396]
[   49.122396]  *** DEADLOCK ***
[   49.122396]
[   49.123134] 6 locks held by ping/2143:
[   49.123604]  #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff81464a18>] raw_sendmsg+0x729/0x9d2
[   49.124749]  #1:  (rcu_read_lock_bh){......}, at: [<ffffffff81397076>] rcu_lock_acquire+0x0/0x20
[   49.125914]  #2:  (rcu_read_lock_bh){......}, at: [<ffffffff813ff64d>] rcu_lock_acquire+0x0/0x20
[   49.127103]  #3:  (dev->qdisc_running_key ?: &qdisc_running_key){+.-...}, at: [<ffffffff81407d1a>] __dev_queue_xmit+0x428/0x751
[   49.128592]  #4:  (rcu_read_lock_bh){......}, at: [<ffffffff814412dd>] rcu_lock_acquire+0x0/0x20
[   49.129760]  #5:  (rcu_read_lock_bh){......}, at: [<ffffffff813ff64d>] rcu_lock_acquire+0x0/0x20
[   49.130940]

git bisect points to:

$ git bisect good
f9eb8aea2a1e12fc2f584d1627deeb957435a801 is the first bad commit
commit f9eb8aea2a1e12fc2f584d1627deeb957435a801
Author: Eric Dumazet <edumazet@google.com>
Date:   Mon Jun 6 09:37:15 2016 -0700

    net_sched: transform qdisc running bit into a seqcount

    Instead of using a single bit (__QDISC___STATE_RUNNING)
    in sch->__state, use a seqcount.

    This adds lockdep support, but more importantly it will allow us
    to sample qdisc/class statistics without having to grab qdisc root lock.

Fix by adding the IFF_NO_QUEUE flag for VRF devices.

Fixes: f9eb8aea2a1e ("net_sched: transform qdisc running bit into a seqcount")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index e3e693bf0dec..a3da975cd2df 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -999,6 +999,8 @@ static void vrf_setup(struct net_device *dev)
 	/* Fill in device structure with ethernet-generic values. */
 	eth_hw_addr_random(dev);
 
+	dev->priv_flags |= IFF_NO_QUEUE;
+
 	/* don't acquire vrf device's netif_tx_lock when transmitting */
 	dev->features |= NETIF_F_LLTX;
 
-- 
2.1.4
