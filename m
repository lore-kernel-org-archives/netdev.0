From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [BUG] crash in 8139cp with 3.9.2 and KVM
Date: Thu, 16 May 2013 21:49:13 -0700
Message-ID: <20130516214913.53ed65f9@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:48626 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694Ab3EQEtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 00:49:18 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq13so2948828pbb.33
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 21:49:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seeing the following panic when using emulated 8139cp with KVM and 3.9.2 kernel.

Looks like netdev_alloc_skb_ip_align() can return a fragmented skb sometimes
and using skb_put() on a non-linear skb causes a panic.

[  421.342513] ------------[ cut here ]------------^M
[  421.348267] kernel BUG at net/core/skbuff.c:1253!^M
[  421.351260] invalid opcode: 0000 [#1] SMP ^M
[  421.352215] Modules linked in: 9p 9pnet fscache ipv6 tun mperf virtio_uio(O) igb_uio(O) uio cpufreq_userspace cpufreq_stats cpufreq_powersave cpufreq_ondemand freq_table cpufreq_conservative ghash_clmulni_intel crc32_pclmul crc32c_intel aesni_intel ablk_helper cryptd lrw aes_x86_64 xts gf128mul cirrus microcode ttm drm_kms_helper drm sysimgblt sysfillrect pcspkr hid_generic serio_raw evdev psmouse syscopyarea intel_agp intel_gtt agpgart i2c_piix4 virtio_balloon i2c_core processor thermal_sys button vfat fat usb_storage ohci_hcd squashfs loop overlayfs raid10 raid456 async_pq async_xor xor async_memcpy async_raid6_recov usbhid hid raid6_pq async_tx raid1 raid0 multipath linear md_mod pata_acpi ata_generic virtio_net virtio_blk floppy ata_piix 8139cp virtio_pci virtio_ring 8139too virtio 
 mii^M
[  421.352215] CPU 0 ^M
[  421.352215] Pid: 0, comm: swapper/0 Tainted: G           O 3.9.2-1-amd64-vyatta #1 Bochs Bochs^M
[  421.352215] RIP: 0010:[<ffffffff81410aa9>]  [<ffffffff81410aa9>] skb_put+0x39/0xa0^M
[  421.352215] RSP: 0018:ffff88007fc03dd8  EFLAGS: 00010286^M
[  421.352215] RAX: 0000000000000000 RBX: ffff8800374207c0 RCX: 0000000000000000^M
[  421.352215] RDX: 00000000909c6000 RSI: 0000000000000099 RDI: ffff880037bd8a00^M
[  421.352215] RBP: 0000000000000039 R08: 00000000ffff8800 R09: ffff880037bd8b80^M
[  421.352215] R10: 0000000000000039 R11: 0000000000000600 R12: 000000003100009d^M
[  421.352215] R13: ffff880079e68390 R14: 0000000000000390 R15: ffff880037bd8a00^M
[  421.352215] FS:  0000000000000000(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000^M
[  421.352215] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033^M
[  421.352215] CR2: 00007f2ce7e73000 CR3: 000000007999a000 CR4: 00000000000407f0^M
[  421.352215] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000^M
[  421.352215] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400^M
[  421.352215] Process swapper/0 (pid: 0, threadinfo ffffffff81800000, task ffffffff81813420)^M
[  421.352215] Stack:^M
[  421.352215]  0000000000000086 0000000000000001 ffff8800374207c0 0000000000000039^M
[  421.352215]  000000003100009d ffffffffa002f3fa 000000000000014d 0000000000000039^M
[  421.352215]  0000000000000600 0000000037439e40 0000000000000099 ffff880037420000^M
[  421.352215] Call Trace:^M
[  421.352215]  <IRQ> ^M
[  421.352215]  [<ffffffffa002f3fa>] ? cp_rx_poll+0x1fa/0x490 [8139cp]^M
[  421.352215]  [<ffffffff814216b2>] ? net_rx_action+0x182/0x2e0^M
[  421.352215]  [<ffffffff8105d9f1>] ? __do_softirq+0xe1/0x270^M
[  421.352215]  [<ffffffff8105dc85>] ? irq_exit+0xb5/0xc0^M
[  421.352215]  [<ffffffff8101640c>] ? do_IRQ+0x5c/0xd0^M
[  421.352215]  [<ffffffff814e092d>] ? common_interrupt+0x6d/0x6d^M
[  421.352215]  <EOI> ^M
[  421.352215]  [<ffffffff81042152>] ? native_safe_halt+0x2/0x10^M
[  421.352215]  [<ffffffff8101e1ef>] ? default_idle+0x3f/0xf0^M
[  421.352215]  [<ffffffff8101db48>] ? cpu_idle+0x88/0xd0^M
[  421.352215]  [<ffffffff818d215b>] ? start_kernel+0x38c/0x397^M
[  421.352215]  [<ffffffff818d1bef>] ? repair_env_string+0x5b/0x5b^M
[  421.352215]  [<ffffffff818d1726>] ? x86_64_start_kernel+0x147/0x156^M
[  421.352215] Code: 00 8b 97 d0 00 00 00 45 85 c0 75 1f 8d 0c 16 01 77 68 3b 8f d4 00 00 00 89 8f d0 00 00 00 77 0f 89 d2 48 83 c4 28 49 8d 04 11 c3 <0f> 0b eb fe 48 8b 57 20 48 c7 c0 d0 fe 70 81 8b 4f 68 41 89 f0 ^M
[  421.352215] RIP  [<ffffffff81410aa9>] skb_put+0x39/0xa0^M
[  421.352215]  RSP <ffff88007fc03dd8>^M
[  421.352215] ---[ end trace 106864a4b494698f ]---^M

  1250	unsigned char *skb_put(struct sk_buff *skb, unsigned int len)
  1251	{
  1252		unsigned char *tmp = skb_tail_pointer(skb);
  1253		SKB_LINEAR_ASSERT(skb);
  1254		skb->tail += len;
  1255		skb->len  += len;
  1256		if (unlikely(skb->tail > skb->end))
  1257			skb_over_panic(skb, len, __builtin_return_address(0));
  1258		return tmp;
  1259	}
  1260	EXPORT_SYMBOL(skb_put);
