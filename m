From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [BUG] af_unix race in close?
Date: Wed, 23 Sep 2009 16:54:21 -0700
Message-ID: <20090923165421.60e0d49c@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34953 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750850AbZIWXyY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2009 19:54:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This oops seems to show lots of times:
http://www.kerneloops.org/guilty.php?guilty=unix_write_space&version=2.6.31-release&start=2064384&end=2097151&class=oops
Looks like race in unix domain socket close with data outstanding.

BUG: unable to handle kernel paging request at 6b6b6b8f
IP: [] unix_write_space+0x45/0x87
*pde = 00000000 
Oops: 0000 [#1] SMP 
last sysfs file: /sys/devices/LNXSYSTM:00/device:00/PNP0C0A:00/power_supply/BAT1/charge_full
Modules linked in: ext2 fuse nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 cpufreq_ondemand acpi_cpufreq dm_multipath uinput uvcvideo videodev v4l1_compat arc4 snd_hda_codec_realtek iTCO_wdt iTCO_vendor_support ecb serio_raw i2c_i801 snd_hda_intel joydev snd_hda_codec snd_hwdep snd_pcm snd_timer ath5k r8169 snd mac80211 mii soundcore ath snd_page_alloc jmb38x_ms cfg80211 memstick rfkill wmi squashfs vfat fat mmc_block i915 sdhci_pci ata_generic pata_acpi sdhci mmc_core drm i2c_algo_bit i2c_core usb_storage video output [last unloaded: microcode]

Pid: 6809, comm: metacity Not tainted (2.6.31-0.125.4.2.rc5.git2.fc12.i686 #1) AOA110
EIP: 0060:[] EFLAGS: 00010202 CPU: 0
EIP is at unix_write_space+0x45/0x87
EAX: 6b6b6b6b EBX: ec988780 ECX: 00000000 EDX: 6b6b6b8f
ESI: ec988950 EDI: ffffff20 EBP: ec941e28 ESP: ec941e1c
 DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
Process metacity (pid: 6809, ti=ec940000 task=e63095c0 task.ti=ec940000)
Stack:
 37dc7803 ec988780 000000e1 ec941e40 c0772142 37dc7803 dcc1c900 dcc1c900
<0> c07f6a02 ec941e50 c0775766 37dc7803 dcc1c900 ec941e60 c07754ae 37dc7803
<0> dcc1c900 ec941e78 c07755db 37dc7803 ec98b0c0 dcc1c900 00000000 ec941ea0
Call Trace:
 [] ? sock_wfree+0x44/0x68
 [] ? unix_release_sock+0x182/0x1e0
 [] ? skb_release_head_state+0x6c/0xcb
 [] ? __kfree_skb+0x20/0x94
 [] ? kfree_skb+0x68/0x7f
 [] ? unix_release_sock+0x182/0x1e0
 [] ? unix_release+0x2f/0x42
 [] ? sock_release+0x29/0x7f
 [] ? sock_close+0x30/0x45
 [] ? __fput+0x101/0x1a2
 [] ? fput+0x27/0x3a
 [] ? filp_close+0x64/0x7f
 [] ? put_files_struct+0x68/0xbd
 [] ? exit_files+0x43/0x59
 [] ? do_exit+0x1d6/0x648
 [] ? audit_syscall_entry+0x134/0x167
 [] ? do_group_exit+0x72/0x99
 [] ? sys_exit_group+0x27/0x3c
 [] ? syscall_call+0x7/0xb
Code: 00 89 45 f4 31 c0 89 f0 e8 9a 76 02 00 8b 83 dc 00 00 00 c1 e0 02 3b 83 e4 00 00 00 7f 32 8b 83 a4 00 00 00 85 c0 74 17 8d 50 24 <39> 50 24 74 0f b9 01 00 00 00 ba 01 00 00 00 e8 bb cf c3 ff b9 
EIP: [] unix_write_space+0x45/0x87 SS:ESP 0068:ec941e1c
CR2: 000000006b6b6b8f
---[ end trace 4a36bd1eb2fc9896 ]---


