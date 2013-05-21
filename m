From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net 2/2]  8139cp: reset BQL when ring tx ring cleared
Date: Mon, 20 May 2013 17:27:49 -0700
Message-ID: <20130520172749.2a4447b6@nehalam.linuxnetplumber.net>
References: <20130520095443.2d18b2cb@nehalam.linuxnetplumber.net>
	<20130520213728.GA28252@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:35355 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572Ab3EUA1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 20:27:54 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro12so39325pbb.27
        for <netdev@vger.kernel.org>; Mon, 20 May 2013 17:27:54 -0700 (PDT)
In-Reply-To: <20130520213728.GA28252@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 May 2013 23:37:28 +0200
Francois Romieu <romieu@fr.zoreil.com> wrote:

> cp_stop_hw includes netdev_reset_queue.
> 
> You have imho exhibited a start_xmit after cp_stop_hw race - not sure if
> it happens in cp_tx_timeout or cp_change_mtu. Reverting the analysis above,
> I have not found a place where cp_stop_hw could be called without being
> followed by a cp_clean_rings. The netdev_reset_queue in cp_stop_hw, now
> useless, should thus be removed.
> 
> Does it make sense ?

Your right, you could probably remove it.

It doesn't solve the problem, still seeing transmit timeouts.
Looks like what happens with DHCP is something else.


 zebra[2210]: interface eth0 index 2 changed <UP,BROADCAST,RUNNING,MULTICAST>.

[   23.960059] ------------[ cut here ]------------
[   23.960107] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x243/0x250()
[   23.960110] Hardware name: Bochs 
[   23.960114] Modules linked in: 9p 9pnet fscache ipv6 tun mperf cpufreq_stats cpufreq_ondemand freq_table cpufreq_userspace cpufreq_conservative virtio_uio(O) cpufreq_powersave igb_uio(O) uio cirrus ttm drm_kms_helper drm sysimgblt sysfillrect virtio_balloon i2c_piix4 i2c_core hid_generic syscopyarea psmouse evdev serio_raw microcode pcspkr intel_agp intel_gtt agpgart processor thermal_sys button vfat fat usb_storage ohci_hcd squashfs loop overlayfs raid10 raid456 async_pq async_xor xor async_memcpy async_raid6_recov usbhid hid raid6_pq async_tx raid1 raid0 multipath linear md_mod pata_acpi ata_generic virtio_blk virtio_net 8139cp ata_piix 8139too mii virtio_pci virtio_ring virtio floppy
[   23.960177] Pid: 0, comm: swapper/3 Tainted: G           O 3.9.3-1-amd64-vyatta #1
[   23.960179] Call Trace:
[   23.960181]  <IRQ>  [<ffffffff8105479b>] ? warn_slowpath_common+0x7b/0xc0
[   23.960212]  [<ffffffff81054895>] ? warn_slowpath_fmt+0x45/0x50
[   23.960228]  [<ffffffff814dfb45>] ? _raw_spin_lock+0x5/0x10
[   23.960232]  [<ffffffff8143dde3>] ? dev_watchdog+0x243/0x250
[   23.960245]  [<ffffffff810704c0>] ? __queue_work+0x2b0/0x2b0
[   23.960253]  [<ffffffff8143dba0>] ? __netdev_watchdog_up+0x70/0x70
[   23.960257]  [<ffffffff8143dba0>] ? __netdev_watchdog_up+0x70/0x70
[   23.960262]  [<ffffffff81064773>] ? call_timer_fn+0x43/0x130
[   23.960265]  [<ffffffff81064c27>] ? run_timer_softirq+0x237/0x280 
[   23.960269]  [<ffffffff8107b200>] ? update_rmtp+0x80/0x80
[   23.960272]  [<ffffffff814dfb45>] ? _raw_spin_lock+0x5/0x10
[   23.960276]  [<ffffffff8105ca41>] ? __do_softirq+0xe1/0x270
[   23.960280]  [<ffffffff8105ccd5>] ? irq_exit+0xb5/0xc0
[   23.960291]  [<ffffffff81039fd8>] ? smp_apic_timer_interrupt+0x68/0xa0
[   23.960302]  [<ffffffff814e151d>] ? apic_timer_interrupt+0x6d/0x80
[   23.960304]  <EOI>  [<ffffffff81042152>] ? native_safe_halt+0x2/0x10
[   23.960318]  [<ffffffff8101e1ef>] ? default_idle+0x3f/0xf0
[   23.960323]  [<ffffffff8101db48>] ? cpu_idle+0x88/0xd0
[   23.960330]  [<ffffffff814d547a>] ? start_secondary+0x211/0x216
[   23.960333] ---[ end trace a519f7f509aceb9a ]--- 
[   23.960407] 8139cp 0000:00:03.0 eth0: Transmit timeout, status  d   3b    4 80ff
[   35.960137] 8139cp 0000:00:03.0 eth0: Transmit timeout, status  d   3b    5 80ff
[   47.960108] 8139cp 0000:00:03.0 eth0: Transmit timeout, status  d   3b    5 80ff
[   59.960117] 8139cp 0000:00:03.0 eth0: Transmit timeout, status  d   3b    5 80ff
[   71.960115] 8139cp 0000:00:03.0 eth0: Transmit timeout, status  d   3b    5 80ff
[   83.960117] 8139cp 0000:00:03.0 eth0: Transmit timeout, status  d   3b    5 80ff
[   95.960131] 8139cp 0000:00:03.0 eth0: Transmit timeout, status  d   3b    5 80ff
~                                                                                                                                                    
~                                                                                                                                                    
~                                                                                                                                                    
~                                                                                                                                                    
~                                                                                                                                                    
~                                                                                                                                                    
~                                                                                                                                                    
~                                                                                                                                                    
~                                                                                                                                                    
~                                                                                                                                                    
~                                                                                                                                                    
~                                                                                                                                                    
~                                                                                                                                                    
~                                                                                                                                                    
~                                                                                                                                                    
~                                                                                                                                                    
~                                                                                                                                                    
~                                                                                                                                                    
~                                                                                                                                                    
"messages" 35 lines, 2958 characters written
