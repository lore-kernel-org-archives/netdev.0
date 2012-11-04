From: Shuah Khan <shuah.khan-VXdhtT5mjnY@public.gmane.org>
Subject: [PATCH] wireless: iwlwifi - add dma_mapping_error() checks to avoid
 warnings
Date: Sat, 03 Nov 2012 19:40:33 -0600
Message-ID: <1351993233.4369.2.camel@lorien2>
Reply-To: shuah.khan-VXdhtT5mjnY@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, shuahkhan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, donald.h.fry-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add missing dma_mapping_error() checks to validate dma addresses returned by
dma_map_page() calls to avoid the following warning:

[   28.475686] WARNING: at lib/dma-debug.c:933 check_unmap+0x459/0x8a0()
[   28.475688] Hardware name: HP EliteBook 6930p
[   28.475690] iwlwifi 0000:03:00.0: DMA-API: device driver failed to check map error[device address=0x00000000ffffa000] [size=8192 bytes] [mapped as page]
[   28.475691] Modules linked in: arc4 bnep rfcomm iwldvm mac80211 snd_hda_codec_analog radeon snd_hda_intel snd_hda_codec coretemp kvm_intel snd_hwdep snd_pcm iwlwifi kvm btusb bluetooth snd_seq_midi snd_rawmidi ttm cfg80211 snd_seq_midi_event drm_kms_helper pata_pcmcia drm snd_seq binfmt_misc pcmcia snd_timer snd_seq_device tpm_infineon snd dm_multipath yenta_socket joydev pcmcia_rsrc pcmcia_core hp_wmi psmouse hp_accel microcode soundcore i2c_algo_bit sparse_keymap wmi ppdev lpc_ich lis3lv02d snd_page_alloc video tpm_tis serio_raw parport_pc input_polldev mac_hid lp parport firewire_ohci firewire_core crc_itu_t sdhci_pci sdhci e1000e
[   28.475727] Pid: 0, comm: swapper/1 Not tainted 3.7.0-rc2-next-20121026+ #2
[   28.475728] Call Trace:
[   28.475729]  <IRQ>  [<ffffffff8105832f>] warn_slowpath_common+0x7f/0xc0
[   28.475736]  [<ffffffff81058426>] warn_slowpath_fmt+0x46/0x50
[   28.475738]  [<ffffffff81347599>] check_unmap+0x459/0x8a0
[   28.475741]  [<ffffffff81347b7c>] debug_dma_unmap_page+0x5c/0x60
[   28.475751]  [<ffffffffa041e2dd>] iwl_irq_tasklet+0x4dd/0x1040 [iwlwifi]
[   28.475755]  [<ffffffffa041d50a>] ? iwl_read32+0x2a/0xa0 [iwlwifi]
[   28.475759]  [<ffffffff81410131>] ? add_interrupt_randomness+0x41/0x190
[   28.475763]  [<ffffffff813b6e53>] ? arch_local_irq_enable+0x8/0xd
[   28.475766]  [<ffffffff81060f54>] tasklet_action+0x64/0xe0
[   28.475768]  [<ffffffff81060a90>] __do_softirq+0xc0/0x240
[   28.475772]  [<ffffffff816950ae>] ? _raw_spin_lock+0xe/0x20
[   28.475774]  [<ffffffff8169ed1c>] call_softirq+0x1c/0x30
[   28.475778]  [<ffffffff810162e5>] do_softirq+0x65/0xa0
[   28.475780]  [<ffffffff81060d6e>] irq_exit+0x8e/0xb0
[   28.475782]  [<ffffffff8169f5a3>] do_IRQ+0x63/0xe0
[   28.475785]  [<ffffffff816956ad>] common_interrupt+0x6d/0x6d
[   28.475786]  <EOI>  [<ffffffff813b6e53>] ? arch_local_irq_enable+0x8/0xd
[   28.475790]  [<ffffffff813b79e9>] acpi_idle_enter_c1+0x94/0xb9
[   28.475793]  [<ffffffff815404f9>] cpuidle_enter+0x19/0x20
[   28.475795]  [<ffffffff81540b8c>] cpuidle_idle_call+0xac/0x2b0
[   28.475798]  [<ffffffff8101d56f>] cpu_idle+0xcf/0x120
[   28.475801]  [<ffffffff8168050e>] start_secondary+0x1ec/0x1f3
[   28.475802] ---[ end trace 4c30cc65c19b6dc1 ]---
[   28.475803] Mapped at:
[   28.475804]  [<ffffffff813465f9>] debug_dma_map_page+0xb9/0x160
[   28.475806]  [<ffffffffa041d704>] iwl_rx_allocate+0x94/0x2b0 [iwlwifi]
[   28.475811]  [<ffffffffa041ddad>] iwl_rx_replenish+0x2d/0x60 [iwlwifi]
[   28.475815]  [<ffffffffa0424c1b>] iwl_trans_pcie_start_fw+0x1fb/0x1450 [iwlwifi]
[   28.475819]  [<ffffffffa05ba57e>] iwl_load_ucode_wait_alive+0xbe/0x540 [iwldvm]

Signed-off-by: Shuah Khan <shuah.khan-VXdhtT5mjnY@public.gmane.org>
---
 drivers/net/wireless/iwlwifi/pcie/rx.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/wireless/iwlwifi/pcie/rx.c b/drivers/net/wireless/iwlwifi/pcie/rx.c
index 137af4c..3731442 100644
--- a/drivers/net/wireless/iwlwifi/pcie/rx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/rx.c
@@ -321,6 +321,8 @@ static void iwl_rx_allocate(struct iwl_trans *trans, gfp_t priority)
 			dma_map_page(trans->dev, page, 0,
 				     PAGE_SIZE << trans_pcie->rx_page_order,
 				     DMA_FROM_DEVICE);
+		if (dma_mapping_error(trans->dev, rxb->page_dma))
+			BUG();
 		/* dma address must be no more than 36 bits */
 		BUG_ON(rxb->page_dma & ~DMA_BIT_MASK(36));
 		/* and also 256 byte aligned! */
@@ -489,6 +491,8 @@ static void iwl_rx_handle_rxbuf(struct iwl_trans *trans,
 			dma_map_page(trans->dev, rxb->page, 0,
 				     PAGE_SIZE << trans_pcie->rx_page_order,
 				     DMA_FROM_DEVICE);
+		if (dma_mapping_error(trans->dev, rxb->page_dma))
+			BUG();
 		list_add_tail(&rxb->list, &rxq->rx_free);
 		rxq->free_count++;
 	} else
-- 
1.7.9.5



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
