From: David Woodhouse <dwmw2@infradead.org>
Subject: tun netns BUG()
Date: Thu, 04 Jun 2009 20:05:52 +0100
Message-ID: <1244142352.3751.14.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54779 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754179AbZFDTFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 15:05:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes and I have been playing with using network namespaces for VPNs:
	http://david.woodhou.se/vpnc-netns.sh

The idea is that you set up a separate netns to be 'afflicted' by the
VPN, while your normal programs have a normal view of the network.

One option was to run a SOCKS server in the VPN's netns, so that normal
programs could get to the VPN through that. That's not what I'm doing
here though -- this one is using NAT-PT so a range of IPv6 space is
mapped to the Legacy IP range on the VPN. Any connections to
fec0:0:0:ffff:0:0:xxyy:zzww get mapped to xx.yy.zz.ww on the VPN.

This is done by passing the VPN tundev (from vpnc or openconnect) into
the new netns, and running ptrtd inside the netns. Then passing the
tundev from ptrtd back _out_ from the netns to the normal namespace.

First I noticed that when vpnc/openconnect closes, the tundev doesn't
disappear from inside the netns -- that was unexpected. So I made the
script in there exit some other way, and then it oopses when
vpnc/openconnect closes its tun fd.

Looks like you can reproduce it by passing a tundev to a different
netns, then closing that netns before you close tun fd which is attached
to it.

(This was actually tun.c from commit 1bded710a5 on 2.6.29.4, but I see
no reason to believe that 2.6.30-rc is different).

------------[ cut here ]------------
kernel BUG at net/core/dev.c:4188!
invalid opcode: 0000 [#1] SMP 
last sysfs file: /sys/devices/LNXSYSTM:00/device:00/PNP0C0A:00/power_supply/BAT0/voltage_now
CPU 0 
Modules linked in: tun veth vmnet parport_pc vmblock vmci vmmon nls_utf8 hfsplus fuse hidp rfcomm bridge stp llc bnep sco l2cap ppdev parport sunrpc ipv6 cpufreq_ondemand acpi_cpufreq freq_table vfat fat dm_multipath kvm uinput snd_hda_codec_realtek snd_hda_intel arc4 snd_hda_codec snd_hwdep ecb btusb snd_pcm snd_timer bluetooth iwlagn iwlcore lib80211 joydev snd applesmc hwmon firewire_ohci input_polldev firewire_core crc_itu_t uvcvideo mac80211 usb_storage bcm5974 soundcore i2c_i801 iTCO_wdt iTCO_vendor_support mbp_nvidia_bl sky2 videodev v4l1_compat v4l2_compat_ioctl32 cfg80211 snd_page_alloc pcspkr video output ata_generic pata_acpi nouveau drm i2c_algo_bit i2c_core [last unloaded: tun]
Pid: 22838, comm: openconnect Not tainted 2.6.29.4-167.fc11.x86_64 #1 MacBookPro4,1
RIP: 0010:[<ffffffff813117b8>]  [<ffffffff813117b8>] rollback_registered+0x7e/0x10a
RSP: 0018:ffff88000721fd68  EFLAGS: 00010202
RAX: 0000000000000002 RBX: ffff880100196000 RCX: ffff88010019672c
RDX: ffffffff815ce568 RSI: 0000000000000292 RDI: ffff880100196000
RBP: ffff88000721fd78 R08: ffff88000721e000 R09: ffff880100196700
R10: ffff88000721fd78 R11: ffff88000721fd78 R12: ffff880100196700
R13: ffff88013d0e8800 R14: 0000000000000008 R15: ffff88001050b880
FS:  00007f5d456987b0(0000) GS:ffffffff817b7000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 000000000116f6e0 CR3: 000000013c114000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
Process openconnect (pid: 22838, threadinfo ffff88000721e000, task ffff88011a401700)
Stack:
 ffff880100196700 ffff880100196000 ffff88000721fd98 ffffffff81311883
 ffff88011a582700 ffff88011a582700 ffff88000721fdb8 ffffffffa02ea4a6
 ffff880118d6f600 ffff88001050b880 ffff88000721fe08 ffffffff810d61c4
Call Trace:
 [<ffffffff81311883>] unregister_netdevice+0x3f/0x56
 [<ffffffffa02ea4a6>] tun_chr_close+0x42/0x69 [tun]
 [<ffffffff810d61c4>] __fput+0xf9/0x1a0
 [<ffffffff810d6285>] fput+0x1a/0x1c
 [<ffffffff810d35c5>] filp_close+0x68/0x72
 [<ffffffff8104a5f9>] put_files_struct+0x6c/0xc3
 [<ffffffff8104a692>] exit_files+0x42/0x47
 [<ffffffff8104c050>] do_exit+0x210/0x834
 [<ffffffff813abd37>] ? _spin_lock_irq+0x27/0x2a
 [<ffffffff813ab88d>] ? trace_hardirqs_off_thunk+0x3a/0x6c
 [<ffffffff8104c702>] do_group_exit+0x8e/0xbe
 [<ffffffff8104c749>] sys_exit_group+0x17/0x1b
 [<ffffffff8101133a>] system_call_fastpath+0x16/0x1b
Code: de 48 c7 c7 29 5c 52 81 e8 24 7e 09 00 31 d2 be 58 10 00 00 48 c7 c7 54 59 52 81 31 c0 e8 54 71 d3 ff e9 8c 00 00 00 ff c8 74 04 <0f> 0b eb fe 48 89 df e8 d2 fe ff ff 48 89 df e8 8f cd ff ff c7 
RIP  [<ffffffff813117b8>] rollback_registered+0x7e/0x10a
 RSP <ffff88000721fd68>
---[ end trace 96330edd51618473 ]---

-- 
dwmw2

