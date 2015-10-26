From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] forcedeth: fix unilateral interrupt disabling in netpoll path
Date: Mon, 26 Oct 2015 12:24:22 -0400
Message-ID: <1445876662-7946-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53914 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbbJZQYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 12:24:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Forcedeth currently uses disable_irq_lockdep and enable_irq_lockdep, which in
some configurations simply calls local_irq_disable.  This causes errant warnings
in the netpoll path as in netpoll_send_skb_on_dev, where we disable irqs using
local_irq_save, leading to the following warning:

WARNING: at net/core/netpoll.c:352 netpoll_send_skb_on_dev+0x243/0x250() (Not
tainted)
Hardware name:
netpoll_send_skb_on_dev(): eth0 enabled interrupts in poll
(nv_start_xmit_optimized+0x0/0x860 [forcedeth])
Modules linked in: netconsole(+) configfs ipv6 iptable_filter ip_tables ppdev
parport_pc parport sg microcode serio_raw edac_core edac_mce_amd k8temp
snd_hda_codec_realtek snd_hda_codec_generic forcedeth snd_hda_intel
snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm snd_timer snd soundcore
snd_page_alloc i2c_nforce2 i2c_core shpchp ext4 jbd2 mbcache sr_mod cdrom sd_mod
crc_t10dif pata_amd ata_generic pata_acpi sata_nv dm_mirror dm_region_hash
dm_log dm_mod [last unloaded: scsi_wait_scan]
Pid: 1940, comm: modprobe Not tainted 2.6.32-573.7.1.el6.x86_64.debug #1
Call Trace:
 [<ffffffff8107bbc1>] ? warn_slowpath_common+0x91/0xe0
 [<ffffffff8107bcc6>] ? warn_slowpath_fmt+0x46/0x60
 [<ffffffffa00fe5b0>] ? nv_start_xmit_optimized+0x0/0x860 [forcedeth]
 [<ffffffff814b3593>] ? netpoll_send_skb_on_dev+0x243/0x250
 [<ffffffff814b37c9>] ? netpoll_send_udp+0x229/0x270
 [<ffffffffa02e3299>] ? write_msg+0x39/0x110 [netconsole]
 [<ffffffffa02e331b>] ? write_msg+0xbb/0x110 [netconsole]
 [<ffffffff8107bd55>] ? __call_console_drivers+0x75/0x90
 [<ffffffff8107bdba>] ? _call_console_drivers+0x4a/0x80
 [<ffffffff8107c445>] ? release_console_sem+0xe5/0x250
 [<ffffffff8107d200>] ? register_console+0x190/0x3e0
 [<ffffffffa02e71a6>] ? init_netconsole+0x1a6/0x216 [netconsole]
 [<ffffffffa02e7000>] ? init_netconsole+0x0/0x216 [netconsole]
 [<ffffffff810020d0>] ? do_one_initcall+0xc0/0x280
 [<ffffffff810d4933>] ? sys_init_module+0xe3/0x260
 [<ffffffff8100b0d2>] ? system_call_fastpath+0x16/0x1b
---[ end trace f349c7af88e6a6d5 ]---
console [netcon0] enabled
netconsole: network logging started

Fix it by modifying the forcedeth code to use
disable_irq_nosync_lockdep_irqsavedisable_irq_nosync_lockdep_irqsave instead,
which saves and restores irq state properly.  This also saves us a little code
in the process

Tested by the reporter, with successful restuls

Patch applies to the head of the net tree

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
Reported-by: Vasily Averin <vvs@sw.ru>
---
 drivers/net/ethernet/nvidia/forcedeth.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index a41bb5e..75e88f4 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -4076,6 +4076,8 @@ static void nv_do_nic_poll(unsigned long data)
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	u32 mask = 0;
+	unsigned long flags;
+	unsigned int irq = 0;
 
 	/*
 	 * First disable irq(s) and then
@@ -4085,25 +4087,27 @@ static void nv_do_nic_poll(unsigned long data)
 
 	if (!using_multi_irqs(dev)) {
 		if (np->msi_flags & NV_MSI_X_ENABLED)
-			disable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
+			irq = np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector;
 		else
-			disable_irq_lockdep(np->pci_dev->irq);
+			irq = np->pci_dev->irq;
 		mask = np->irqmask;
 	} else {
 		if (np->nic_poll_irq & NVREG_IRQ_RX_ALL) {
-			disable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
+			irq = np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector;
 			mask |= NVREG_IRQ_RX_ALL;
 		}
 		if (np->nic_poll_irq & NVREG_IRQ_TX_ALL) {
-			disable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_TX].vector);
+			irq = np->msi_x_entry[NV_MSI_X_VECTOR_TX].vector;
 			mask |= NVREG_IRQ_TX_ALL;
 		}
 		if (np->nic_poll_irq & NVREG_IRQ_OTHER) {
-			disable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_OTHER].vector);
+			irq = np->msi_x_entry[NV_MSI_X_VECTOR_OTHER].vector;
 			mask |= NVREG_IRQ_OTHER;
 		}
 	}
-	/* disable_irq() contains synchronize_irq, thus no irq handler can run now */
+
+	disable_irq_nosync_lockdep_irqsave(irq, &flags);
+	synchronize_irq(irq);
 
 	if (np->recover_error) {
 		np->recover_error = 0;
@@ -4156,28 +4160,22 @@ static void nv_do_nic_poll(unsigned long data)
 			nv_nic_irq_optimized(0, dev);
 		else
 			nv_nic_irq(0, dev);
-		if (np->msi_flags & NV_MSI_X_ENABLED)
-			enable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
-		else
-			enable_irq_lockdep(np->pci_dev->irq);
 	} else {
 		if (np->nic_poll_irq & NVREG_IRQ_RX_ALL) {
 			np->nic_poll_irq &= ~NVREG_IRQ_RX_ALL;
 			nv_nic_irq_rx(0, dev);
-			enable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
 		}
 		if (np->nic_poll_irq & NVREG_IRQ_TX_ALL) {
 			np->nic_poll_irq &= ~NVREG_IRQ_TX_ALL;
 			nv_nic_irq_tx(0, dev);
-			enable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_TX].vector);
 		}
 		if (np->nic_poll_irq & NVREG_IRQ_OTHER) {
 			np->nic_poll_irq &= ~NVREG_IRQ_OTHER;
 			nv_nic_irq_other(0, dev);
-			enable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_OTHER].vector);
 		}
 	}
 
+	enable_irq_lockdep_irqrestore(irq, &flags);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
2.1.0
