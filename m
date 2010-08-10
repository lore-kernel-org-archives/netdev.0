From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] netpoll: use non-BH variant of RCU
Date: Tue, 10 Aug 2010 16:25:24 -0400
Message-ID: <1281471924-2237-1-git-send-email-linville@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55821 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753210Ab0HJUe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 16:34:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"netpoll: Fix RCU usage" switched netpoll_rx to use the BH variant
of RCU.  Unfortunately, calling netpoll_rx from netif_rx resulted in
the following backtrace:

WARNING: at kernel/softirq.c:143 _local_bh_enable_ip+0x3e/0xab()
Hardware name: 2373HU6
Modules linked in: arc4 ecb lib80211_crypt_wep fuse nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc cpufreq_ondemand acpi_cpufreq mperf ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 dm_multipath uinput snd_intel8x0m snd_intel8x0 snd_ac97_codec ac97_bus ppdev snd_seq ipw2200 nsc_ircc snd_seq_device video irda e1000 parport_pc snd_pcm libipw parport output crc_ccitt thinkpad_acpi cfg80211 i2c_i801 joydev pcspkr iTCO_wdt rfkill iTCO_vendor_support lib80211 snd_timer snd soundcore snd_page_alloc yenta_socket radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded: microcode]
Pid: 0, comm: swapper Not tainted 2.6.35-wl+ #5
Call Trace:
 [<c043aa42>] warn_slowpath_common+0x6a/0x7f
 [<c0440541>] ? _local_bh_enable_ip+0x3e/0xab
 [<c072e8dc>] ? rcu_read_unlock_bh+0x21/0x23
 [<c043aa6b>] warn_slowpath_null+0x14/0x18
 [<c0440541>] _local_bh_enable_ip+0x3e/0xab
 [<c04405cd>] local_bh_enable+0x10/0x12
 [<c072e8dc>] rcu_read_unlock_bh+0x21/0x23
 [<c072e978>] netpoll_rx+0x9a/0xa2
 [<c0730ab9>] netif_rx+0x13/0x85
 [<f7cc02db>] libipw_rx+0x78c/0x7b6 [libipw]
 [<c07c6902>] ? _raw_spin_lock_irqsave+0x60/0x6a
 [<f81aedc9>] ipw_irq_tasklet+0xec3/0x1285 [ipw2200]
 [<c07c6f01>] ? _raw_spin_unlock_irq+0x26/0x30
 [<c046189a>] ? print_lock_contention_bug+0x11/0xb2
 [<c046189a>] ? print_lock_contention_bug+0x11/0xb2
 [<c043fd87>] tasklet_action+0x78/0xcb
 [<c0440293>] __do_softirq+0xc4/0x183
 [<c044038d>] do_softirq+0x3b/0x5f
 [<c04404d0>] irq_exit+0x3a/0x6d
 [<c0404423>] do_IRQ+0x8b/0x9f
 [<c04038b5>] common_interrupt+0x35/0x3c
 [<c062ecfa>] ? acpi_idle_enter_simple+0xfe/0x13c
 [<c045007b>] ? exit_itimers+0x2d/0x73
 [<c062ecfc>] ? acpi_idle_enter_simple+0x100/0x13c
 [<c070bf10>] cpuidle_idle_call+0x78/0xdc
 [<c040251c>] cpu_idle+0x9b/0xb7
 [<c07b1dd2>] rest_init+0xa6/0xab
 [<c0a4b96d>] start_kernel+0x389/0x38e
 [<c0a4b0c9>] i386_start_kernel+0xc9/0xd0

Switching back to the non-BH variant of RCU resolves the issue.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 include/linux/netpoll.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 413742c..0bdd527 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -63,8 +63,8 @@ static inline bool netpoll_rx(struct sk_buff *skb)
 	unsigned long flags;
 	bool ret = false;
 
-	rcu_read_lock_bh();
-	npinfo = rcu_dereference_bh(skb->dev->npinfo);
+	rcu_read_lock();
+	npinfo = rcu_dereference(skb->dev->npinfo);
 
 	if (!npinfo || (list_empty(&npinfo->rx_np) && !npinfo->rx_flags))
 		goto out;
@@ -76,13 +76,13 @@ static inline bool netpoll_rx(struct sk_buff *skb)
 	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 
 out:
-	rcu_read_unlock_bh();
+	rcu_read_unlock();
 	return ret;
 }
 
 static inline int netpoll_rx_on(struct sk_buff *skb)
 {
-	struct netpoll_info *npinfo = rcu_dereference_bh(skb->dev->npinfo);
+	struct netpoll_info *npinfo = rcu_dereference(skb->dev->npinfo);
 
 	return npinfo && (!list_empty(&npinfo->rx_np) || npinfo->rx_flags);
 }
-- 
1.7.2.1

