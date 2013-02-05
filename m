From: Josh Boyer <jwboyer@redhat.com>
Subject: 3.8-rc6 e100 DMA-API error
Date: Tue, 5 Feb 2013 11:34:04 -0500
Message-ID: <20130205163403.GE2456@hansolo.jdub.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40973 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753323Ab3BEQeP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2013 11:34:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

Fedora runs the rawhide kernels with CONFIG_DMA_API_DEBUG set.  We
recently had a report [1] of the e100 driver throwing a "failed to check
map error" warning with e100_tx_clean as the top function in the
backtrace.  Looking at the code and the backtrace, the place that should
be done is in e100_xmit_prepare, right here:

        cb->u.tcb.tbd.buf_addr = cpu_to_le32(pci_map_single(nic->pdev,
                skb->data, skb->len, PCI_DMA_TODEVICE));
        /* check for mapping failure? */
        cb->u.tcb.tbd.size = cpu_to_le16(skb->len);

Given the comment already exists, is there a reason that check isn't done
in this function?  I see e100_rx_alloc_skb calls pci_dma_mapping_error,
but wasn't sure if e100_xmit_prepare had something special about it.

This was seen with 3.8-rc6.  I've included the backtrace below.

Thanks,
josh

[1] https://bugzilla.redhat.com/show_bug.cgi?id=907694

[   46.656594] ------------[ cut here ]------------
[   46.657004] WARNING: at lib/dma-debug.c:933 check_unmap+0x47b/0x950()
[   46.657004] Hardware name: To Be Filled By O.E.M.
[   46.657004] e100 0000:00:0e.0: DMA-API: device driver failed to check map error[device address=0x000000007a4540fa] [size=90 bytes] [mapped as single]
[   46.657004] Modules linked in:
[   46.657004]  w83627hf hwmon_vid snd_via82xx ppdev snd_ac97_codec ac97_bus snd_seq snd_pcm snd_mpu401 snd_mpu401_uart ns558 snd_rawmidi gameport parport_pc e100 snd_seq_device parport snd_page_alloc snd_timer snd soundcore skge shpchp k8temp mii edac_core i2c_viapro edac_mce_amd nfsd auth_rpcgss nfs_acl lockd sunrpc binfmt_misc uinput ata_generic pata_acpi radeon i2c_algo_bit drm_kms_helper ttm firewire_ohci drm firewire_core pata_via sata_via i2c_core sata_promise crc_itu_t
[   46.657004] Pid: 792, comm: ip Not tainted 3.8.0-0.rc6.git0.1.fc19.x86_64 #1
[   46.657004] Call Trace:
[   46.657004]  <IRQ>  [<ffffffff81065ed0>] warn_slowpath_common+0x70/0xa0
[   46.657004]  [<ffffffff81065f4c>] warn_slowpath_fmt+0x4c/0x50
[   46.657004]  [<ffffffff81364cfb>] check_unmap+0x47b/0x950
[   46.657004]  [<ffffffff8136522f>] debug_dma_unmap_page+0x5f/0x70
[   46.657004]  [<ffffffffa030f0f0>] ? e100_tx_clean+0x30/0x210 [e100]
[   46.657004]  [<ffffffffa030f1a8>] e100_tx_clean+0xe8/0x210 [e100]
[   46.657004]  [<ffffffffa030fc6f>] e100_poll+0x56f/0x6c0 [e100]
[   46.657004]  [<ffffffff8159dce1>] ? net_rx_action+0xa1/0x370
[   46.657004]  [<ffffffff8159ddb2>] net_rx_action+0x172/0x370
[   46.657004]  [<ffffffff810703bf>] __do_softirq+0xef/0x3d0
[   46.657004]  [<ffffffff816e4ebc>] call_softirq+0x1c/0x30
[   46.657004]  [<ffffffff8101c485>] do_softirq+0x85/0xc0
[   46.657004]  [<ffffffff81070885>] irq_exit+0xd5/0xe0
[   46.657004]  [<ffffffff816e5756>] do_IRQ+0x56/0xc0
[   46.657004]  [<ffffffff816dacb2>] common_interrupt+0x72/0x72
[   46.657004]  <EOI>  [<ffffffff816da1eb>] ? _raw_spin_unlock_irqrestore+0x3b/0x70
[   46.657004]  [<ffffffff816d124d>] __slab_free+0x58/0x38b
[   46.657004]  [<ffffffff81214424>] ? fsnotify_clear_marks_by_inode+0x34/0x120
[   46.657004]  [<ffffffff811b0417>] ? kmem_cache_free+0x97/0x320
[   46.657004]  [<ffffffff8157fc14>] ? sock_destroy_inode+0x34/0x40
[   46.657004]  [<ffffffff8157fc14>] ? sock_destroy_inode+0x34/0x40
[   46.657004]  [<ffffffff811b0692>] kmem_cache_free+0x312/0x320
[   46.657004]  [<ffffffff8157fc14>] sock_destroy_inode+0x34/0x40
[   46.657004]  [<ffffffff811e8c28>] destroy_inode+0x38/0x60
[   46.657004]  [<ffffffff811e8d5e>] evict+0x10e/0x1a0
[   46.657004]  [<ffffffff811e9605>] iput+0xf5/0x180
[   46.657004]  [<ffffffff811e4338>] dput+0x248/0x310
[   46.657004]  [<ffffffff811ce0e1>] __fput+0x171/0x240
[   46.657004]  [<ffffffff811ce26e>] ____fput+0xe/0x10
[   46.657004]  [<ffffffff8108d54c>] task_work_run+0xac/0xe0
[   46.657004]  [<ffffffff8106c6ed>] do_exit+0x26d/0xc30
[   46.657004]  [<ffffffff8109eccc>] ? finish_task_switch+0x7c/0x120
[   46.657004]  [<ffffffff816dad58>] ? retint_swapgs+0x13/0x1b
[   46.657004]  [<ffffffff8106d139>] do_group_exit+0x49/0xc0
[   46.657004]  [<ffffffff8106d1c4>] sys_exit_group+0x14/0x20
[   46.657004]  [<ffffffff816e3b19>] system_call_fastpath+0x16/0x1b
[   46.657004] ---[ end trace 4468c44e2156e7d1 ]---
[   46.657004] Mapped at:
[   46.657004]  [<ffffffff813663d1>] debug_dma_map_page+0x91/0x140
[   46.657004]  [<ffffffffa030e8eb>] e100_xmit_prepare+0x12b/0x1c0 [e100]
[   46.657004]  [<ffffffffa030c924>] e100_exec_cb+0x84/0x140 [e100]
[   46.657004]  [<ffffffffa030e56a>] e100_xmit_frame+0x3a/0x190 [e100]
[   46.657004]  [<ffffffff8159ee89>] dev_hard_start_xmit+0x259/0x6c0
