From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH] sis900: Fix the tx queue timeout issue
Date: Wed, 31 Jul 2013 18:43:02 +0400
Message-ID: <1375281782-2332-1-git-send-email-kda@linux-powerpc.org>
Cc: netdev@vger.kernel.org, Denis Kirjanov <kda@linux-powerpc.org>
To: venza@brownhat.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:44415 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752934Ab3GaShu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 14:37:50 -0400
Received: by mail-lb0-f177.google.com with SMTP id r11so842352lbv.8
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 11:37:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[  198.720048] ------------[ cut here ]------------
[  198.720108] WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:255 dev_watchdog+0x229/0x240()
[  198.720118] NETDEV WATCHDOG: eth0 (sis900): transmit queue 0 timed out
[  198.720125] Modules linked in: bridge stp llc dmfe sundance 3c59x sis900 mii
[  198.720159] CPU: 0 PID: 0 Comm: swapper Not tainted 3.11.0-rc3+ #12
[  198.720167] Hardware name: System Manufacturer System Name/TUSI-M, BIOS ASUS TUSI-M ACPI BIOS
Revision 1013 Beta 001 12/14/2001
[  198.720175]  000000ff c13fa6b9 c169ddcc c12208d6 c169ddf8 c1031e4d c1664a84 c169de24
[  198.720197]  00000000 c165f5ea 000000ff c13fa6b9 00000001 000000ff c1664a84 c169de10
[  198.720217]  c1031f13 00000009 c169de08 c1664a84 c169de24 c169de50 c13fa6b9 c165f5ea
[  198.720240] Call Trace:
[  198.720257]  [<c13fa6b9>] ? dev_watchdog+0x229/0x240
[  198.720274]  [<c12208d6>] dump_stack+0x16/0x20
[  198.720306]  [<c1031e4d>] warn_slowpath_common+0x7d/0xa0
[  198.720318]  [<c13fa6b9>] ? dev_watchdog+0x229/0x240
[  198.720330]  [<c1031f13>] warn_slowpath_fmt+0x33/0x40
[  198.720342]  [<c13fa6b9>] dev_watchdog+0x229/0x240
[  198.720357]  [<c103f158>] call_timer_fn+0x78/0x150
[  198.720369]  [<c103f0e0>] ? internal_add_timer+0x40/0x40
[  198.720381]  [<c13fa490>] ? dev_init_scheduler+0xa0/0xa0
[  198.720392]  [<c103f33f>] run_timer_softirq+0x10f/0x200
[  198.720412]  [<c103954f>] ? __do_softirq+0x6f/0x210
[  198.720424]  [<c13fa490>] ? dev_init_scheduler+0xa0/0xa0
[  198.720435]  [<c1039598>] __do_softirq+0xb8/0x210
[  198.720467]  [<c14b54d2>] ? _raw_spin_unlock+0x22/0x30
[  198.720484]  [<c1003245>] ? handle_irq+0x25/0xd0
[  198.720496]  [<c1039c0c>] irq_exit+0x9c/0xb0
[  198.720508]  [<c14bc9d7>] do_IRQ+0x47/0x94
[  198.720534]  [<c1056078>] ? hrtimer_start+0x28/0x30
[  198.720564]  [<c14bc8b1>] common_interrupt+0x31/0x38
[  198.720589]  [<c1008692>] ? default_idle+0x22/0xa0
[  198.720600]  [<c10083c7>] arch_cpu_idle+0x17/0x30
[  198.720631]  [<c106d23d>] cpu_startup_entry+0xcd/0x180
[  198.720643]  [<c14ae30a>] rest_init+0xaa/0xb0
[  198.720654]  [<c14ae260>] ? reciprocal_value+0x50/0x50
[  198.720668]  [<c17044e0>] ? repair_env_string+0x60/0x60
[  198.720679]  [<c1704bda>] start_kernel+0x29a/0x350
[  198.720690]  [<c17044e0>] ? repair_env_string+0x60/0x60
[  198.720721]  [<c1704269>] i386_start_kernel+0x39/0xa0
[  198.720729] ---[ end trace 81e0a6266f5c73a8 ]---
[  198.720740] eth0: Transmit timeout, status 00000204 00000000

We are trying to initiate a frame transmission even
if we are not ready to do so due auto negotiation progress:

timer routine checks the link status and if it's up calls
netif_carrier_on() allowing upper layer to start the tx queue

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 drivers/net/ethernet/sis/sis900.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index eb4aea3..9516734 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -1613,9 +1613,13 @@ sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
 	unsigned int  count_dirty_tx;
 
 	/* Don't transmit data before the complete of auto-negotiation */
-	if(!sis_priv->autong_complete){
-		netif_stop_queue(net_dev);
-		return NETDEV_TX_BUSY;
+	if (unlikely(!sis_priv->autong_complete)) {
+		if (netif_msg_tx_err(sis_priv) && net_ratelimit())
+			printk(KERN_DEBUG "%s: Auto negotiation in progress\n",
+					net_dev->name);
+		net_dev->stats.tx_dropped++;
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
 	}
 
 	spin_lock_irqsave(&sis_priv->lock, flags);
-- 
1.8.0.2
