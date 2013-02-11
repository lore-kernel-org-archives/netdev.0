From: Josh Boyer <jwboyer@redhat.com>
Subject: atl1c DMA-API mapping errors in 3.8-rc6+
Date: Mon, 11 Feb 2013 08:08:13 -0500
Message-ID: <20130211130812.GA21501@hansolo.jdub.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	sgruszka@redhat.com
To: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	xiong <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19844 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757146Ab3BKNIU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2013 08:08:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

We've had two different reports[1] in Fedora of users hitting DMA-API
errors with the atl1c driver on 3.8-rc6+.  The errors are from different
locations, but the problem is the same.  Essentially, the driver isn't
doing any form of pci_dma_mapping_error checking after calling
pci_map_single.

I looked briefly at creating a patch to do so, but I wasn't immediately
able to tell what the proper error handling should be at the places atl1c
calls pci_map_single.  I'm hoping someone more familiar with the driver
will be able to figure that out fairly quickly.

I've included the backtraces below.  These errors only hit when
CONFIG_DMA_API_DEBUG is set.

josh

[1] https://bugzilla.redhat.com/show_bug.cgi?id=908436
https://bugzilla.redhat.com/show_bug.cgi?id=908550

WARNING: at lib/dma-debug.c:933 check_unmap+0x47b/0x950()
Hardware name: AO532h          
atl1c 0000:01:00.0: DMA-API: device driver failed to check map error[device address=0x0000000065f48040] [size=1522 bytes] [mapped as single]
Modules linked in: ip6table_filter ip6_tables iTCO_wdt iTCO_vendor_support acer_wmi sparse_keymap coretemp uvcvideo videobuf2_vmalloc microcode videobuf2_memops videobuf2_core joydev videodev media arc4 snd_hda_codec_realtek snd_hda_intel ath9k snd_hda_codec ath9k_common snd_hwdep ath9k_hw snd_seq ath snd_seq_device mac80211 snd_pcm cfg80211 snd_page_alloc snd_timer snd rfkill soundcore lpc_ich i2c_i801 mfd_core uinput i915 usb_storage i2c_algo_bit drm_kms_helper drm atl1c i2c_core video wmi sunrpc
Pid: 745, comm: NetworkManager Not tainted 3.8.0-0.rc6.git2.1.fc19.x86_64 #1
Call Trace:
 [<ffffffff81065ee0>] warn_slowpath_common+0x70/0xa0
 [<ffffffff81065f5c>] warn_slowpath_fmt+0x4c/0x50
 [<ffffffff81365ceb>] check_unmap+0x47b/0x950
 [<ffffffff81078b1f>] ? try_to_del_timer_sync+0x4f/0x70
 [<ffffffff8136621f>] debug_dma_unmap_page+0x5f/0x70
 [<ffffffffa00701ab>] atl1c_clean_rx_ring+0xbb/0x210 [atl1c]
 [<ffffffffa0070329>] atl1c_reset_dma_ring+0x29/0x30 [atl1c]
 [<ffffffffa0070ee2>] atl1c_check_link_status+0xb2/0x340 [atl1c]
 [<ffffffff8111341e>] ? request_threaded_irq+0xee/0x1a0
 [<ffffffffa007125e>] atl1c_up+0xee/0x1e0 [atl1c]
 [<ffffffffa007190a>] atl1c_open+0x26a/0x330 [atl1c]
 [<ffffffff815a129f>] __dev_open+0x8f/0xf0
 [<ffffffff815a1532>] __dev_change_flags+0x92/0x170
 [<ffffffff815a16ad>] dev_change_flags+0x1d/0x60
 [<ffffffff815b0678>] do_setlink+0x388/0xa40
 [<ffffffff810d3f9d>] ? __lock_acquire+0x2bd/0x1910
 [<ffffffff81364b52>] ? nla_parse+0x32/0xe0
 [<ffffffff815b26e4>] rtnl_newlink+0x394/0x5e0
 [<ffffffff812e1dde>] ? selinux_capable+0x2e/0x40
 [<ffffffff815aec13>] rtnetlink_rcv_msg+0x113/0x310
 [<ffffffff816d88bf>] ? mutex_lock_nested+0x2af/0x380
 [<ffffffff815aeadb>] ? rtnetlink_rcv+0x1b/0x40
 [<ffffffff815aeb00>] ? rtnetlink_rcv+0x40/0x40
 [<ffffffff815ce059>] netlink_rcv_skb+0xa9/0xc0
 [<ffffffff815aeaea>] rtnetlink_rcv+0x2a/0x40
 [<ffffffff815cda20>] netlink_unicast+0x180/0x230
 [<ffffffff815cdddf>] netlink_sendmsg+0x30f/0x3d0
 [<ffffffff8158154a>] sock_sendmsg+0xaa/0xe0
 [<ffffffff81591916>] ? verify_iovec+0x56/0xd0
 [<ffffffff8158279e>] __sys_sendmsg+0x39e/0x3b0
 [<ffffffff810d182c>] ? __lock_is_held+0x4c/0x70
 [<ffffffff811ec276>] ? fget_light+0xf6/0x520
 [<ffffffff811ec1bc>] ? fget_light+0x3c/0x520
 [<ffffffff81584332>] sys_sendmsg+0x42/0x80
 [<ffffffff816e4b59>] system_call_fastpath+0x16/0x1b

WARNING: at lib/dma-debug.c:933 check_unmap+0x47b/0x950()
Hardware name: System Product Name
atl1c 0000:03:00.0: DMA-API: device driver failed to check map error[device address=0x00000000cb8bc800] [size=90 bytes] [mapped as single]
Modules linked in: ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables nf_conntrack_ipv4 nf_defrag_ipv4 it87 xt_conntrack hwmon_vid nf_conntrack snd_hda_codec_via eeepc_wmi snd_hda_codec_hdmi snd_hda_intel snd_hda_codec asus_wmi snd_hwdep snd_seq snd_seq_device snd_pcm sparse_keymap snd_page_alloc rfkill snd_timer video snd soundcore kvm_amd atl1c i2c_piix4 serio_raw k10temp kvm microcode uinput btrfs zlib_deflate libcrc32c radeon i2c_algo_bit drm_kms_helper ttm drm i2c_core wmi
Pid: 473, comm: fancontrol Not tainted 3.8.0-0.rc6.git3.1.fc19.x86_64 #1
Call Trace:
 <IRQ>  [<ffffffff81065ee0>] warn_slowpath_common+0x70/0xa0
 [<ffffffff81065f5c>] warn_slowpath_fmt+0x4c/0x50
 [<ffffffff81365ceb>] check_unmap+0x47b/0x950
 [<ffffffff8136621f>] debug_dma_unmap_page+0x5f/0x70
 [<ffffffff813622e0>] ? unmap_single+0x20/0x30
 [<ffffffffa02e599f>] atl1c_intr+0x22f/0x5b0 [atl1c]
 [<ffffffff816db426>] ? _raw_spin_unlock_irqrestore+0x36/0x70
 [<ffffffff81111486>] handle_irq_event_percpu+0x56/0x390
 [<ffffffff811117fd>] handle_irq_event+0x3d/0x60
 [<ffffffff81114287>] handle_edge_irq+0x77/0x130
 [<ffffffff8101c36f>] handle_irq+0xbf/0x150
 [<ffffffff81070770>] ? irq_enter+0x50/0xa0
 [<ffffffff816e699d>] do_IRQ+0x4d/0xc0
 [<ffffffff816dbef2>] common_interrupt+0x72/0x72
 [<ffffffff816db48c>] ? _raw_spin_unlock_irq+0x2c/0x50
 [<ffffffff81119545>] ? rcu_process_callbacks+0x5/0x7a0
 [<ffffffff810703cf>] ? __do_softirq+0xef/0x3d0
 [<ffffffff816e60fc>] call_softirq+0x1c/0x30
 [<ffffffff8101c485>] do_softirq+0x85/0xc0
 [<ffffffff81070895>] irq_exit+0xd5/0xe0
 [<ffffffff816e6a7e>] smp_apic_timer_interrupt+0x6e/0x9c
 [<ffffffff816e59b2>] apic_timer_interrupt+0x72/0x80
 <EOI>  [<ffffffff816d2e4c>] ? __slab_alloc+0x4c2/0x526
 [<ffffffff810d37bd>] ? mark_held_locks+0x9d/0x100
 [<ffffffff811ade31>] ? set_track+0x61/0x1b0
 [<ffffffff816d2e45>] ? __slab_alloc+0x4bb/0x526
 [<ffffffff811945a9>] ? anon_vma_clone+0x49/0x140
 [<ffffffff810d39bd>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff811b44a4>] kmem_cache_alloc+0x284/0x2f0
 [<ffffffff811945a9>] ? anon_vma_clone+0x49/0x140
 [<ffffffff811945a9>] anon_vma_clone+0x49/0x140
 [<ffffffff811946ce>] anon_vma_fork+0x2e/0x100
 [<ffffffff8106343e>] dup_mm+0x26e/0x660
 [<ffffffff81064e2f>] copy_process.part.22+0x15cf/0x1650
 [<ffffffff81064fa5>] do_fork+0xa5/0x450
 [<ffffffff8118451c>] ? might_fault+0x5c/0xb0
 [<ffffffff816dbf98>] ? retint_swapgs+0x13/0x1b
 [<ffffffff810653d6>] sys_clone+0x16/0x20
 [<ffffffff816e5139>] stub_clone+0x69/0x90
 [<ffffffff816e4d59>] ? system_call_fastpath+0x16/0x1b
