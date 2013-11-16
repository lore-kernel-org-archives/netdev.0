From: Michele Baldessari <michele@acksyn.org>
Subject: oops in pskb_expand_head - 3.11.6
Date: Sat, 16 Nov 2013 23:16:15 +0000
Message-ID: <20131116231615.GA24327@marquez.int.rhx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palahniuk.acksyn.org ([5.9.7.26]:39894 "EHLO
	palahniuk.acksyn.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025Ab3KPXQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 18:16:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Two oops like the following were reported in Fedora 19 - kernel 3.11.6:
https://bugzilla.redhat.com/show_bug.cgi?id=1015905

Seems ipv6/netfilter related (?), could not find any obvious commit that
fixed it in later versions.

Environment description (from the BZ):
When a local client attempts to send an IPv6 packet larger than the MTU,
the kernel on the router panics.  In normal operation this shouldn't
happen but a simple 'ping6 -s 1490 www.google.com' from a client will
trigger the panic.
If you try this from the router itself, you get 'Packet too big:
mtu=1472' but no panic suggesting this is a 'forward' issue.

How reproducible:
'ping6 -s 1490 www.google.com' from a client will reproduce every time.

Steps to Reproduce:
1. Set up a pppoe connection
2. Set up a 6rd SIT tunnel over the pppoe connection
3. Set up infrastructure to distribute delegated IPv6 addresses
4. From a client run 'ping6 -s 1490 www.google.com'

enp1s0 = lan
enp2s0 = wan
ppp0 = pppoe via enp2s0
rdhe0 = sit via ppp0

2: enp2s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:22:4d:9a:5d:9d brd ff:ff:ff:ff:ff:ff
    inet 192.168.101.254/24 brd 192.168.101.255 scope global enp2s0 valid_lft forever preferred_lft forever
    inet6 fe80::222:4dff:fe9a:5d9d/64 scope link valid_lft forever preferred_lft forever

3: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:22:4d:9a:5d:a1 brd ff:ff:ff:ff:ff:ff
    inet 192.168.147.1/24 brd 192.168.147.255 scope global enp1s0 valid_lft forever preferred_lft forever
    inet6 2001:XXXX:XXXX:13d:2::1/128 scope global valid_lft forever preferred_lft forever
    inet6 fe80::222:4dff:fe9a:5da1/64 scope link valid_lft forever preferred_lft forever

4: sit0: <NOARP> mtu 1480 qdisc noop state DOWN 
    link/sit 0.0.0.0 brd 0.0.0.0

5: rdhe0: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1460 qdisc noqueue state UNKNOWN 
    link/sit 65.XXX.XXX.14 peer 184.105.250.46 inet6 2001:XXXX:XXXX:13d::2/64 scope global valid_lft forever preferred_lft forever
    inet6 fe80::4166:d30e/128 scope link valid_lft forever preferred_lft forever

6: ppp0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1492 qdisc pfifo_fast state UNKNOWN qlen 3
    link/ppp inet 65.XXX.XXX.14 peer 207.XXX.XXX.6/32 scope global ppp0
       valid_lft forever preferred_lft forever


[  573.858967] kernel BUG at net/core/skbuff.c:1059!
[  573.864743] invalid opcode: 0000 [#1] SMP 
[  573.869856] Modules linked in: pppoe pppox ppp_synctty ppp_async crc_ccitt ppp_generic slhc 8021q garp stp mrp llc xt_policy xt_NFLOG
nfnetlink_log nfnetlink nf_conntrack_ipv6 nf_defrag_ipv6 ip6t_rt xt_conntrack iptable_mangle ipt_MASQUERADE iptable_nat nf_conntrack_ipv4
ip6table_filter nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack xt_TCPMSS ip6table_mangle ip6_tables e1000e(OF) x86_pkg_temp_thermal kvm_intel
w83627ehf hwmon_vid coretemp kvm crc32_pclmul crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi snd_hda_codec_realtek
snd_hda_intel microcode snd_hda_codec r8169 mii snd_hwdep snd_seq snd_seq_device snd_pcm iTCO_wdt iTCO_vendor_support snd_page_alloc
snd_timer snd soundcore serio_raw shpchp mei_me lpc_ich mei i2c_i801 mfd_core mperf usb_storage i915 video i2c_algo_bit drm_kms_helper drm
ata_generic i2c_core pata_acpi
[  573.906875] CPU: 3 PID: 0 Comm: swapper/3 Tainted: GF          O 3.11.6-200.fc19.x86_64 #1
[  573.909619] Hardware name:                  /DQ67EP, BIOS SWQ6710H.86A.0066.2012.1105.1504 11/05/2012
[  573.911658] task: ffff880138305b80 ti: ffff880138334000 task.ti: ffff880138334000
[  573.913273] RIP: 0010:[<ffffffff8153def0>]  [<ffffffff8153def0>] pskb_expand_head+0x260/0x2a0
[  573.915167] RSP: 0018:ffff88013e3836a8  EFLAGS: 00010202 
[  573.916318] RAX: 0000000000000003 RBX: ffff8800376d2900 RCX: 0000000000000020
[  573.917930] RDX: 000000000000069e RSI: 0000000000000000 RDI: ffff8800376d2900
[  573.919444] RBP: ffff88013e3836d8 R08: 00000000000000c0 R09: ffff88013667ca00
[  573.920965] R10: 000000000000ffff R11: 0000000000000002 R12: ffff88013838f000
[  573.922577] R13: 0000000000000000 R14: ffff88013838f000 R15: ffff8800376d2900
[  573.924103] FS:  0000000000000000(0000) GS:ffff88013e380000(0000) knlGS:0000000000000000
[  573.925840] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  573.927519] CR2: 00007fb14b067000 CR3: 0000000135a93000 CR4: 00000000000407e0
[  573.929034] Stack:
[  573.929519]  ffff8800376d2900 ffff8800376d2900 ffff88013838f000 00000000000005a0
[  573.931323]  ffff88013838f000 ffff8800376d2900 ffff88013e383720 ffffffff8153e290
[  573.933202]  ffff88013838f000 000005a035de089c 0000000000000000 ffff88013838f000
[  573.935001] Call Trace:
[  573.935570]  <IRQ> 
[  573.936008]  [<ffffffff8153e290>] __pskb_pull_tail+0x50/0x360
[  573.937459]  [<ffffffff8154d5bc>] dev_hard_start_xmit+0x2cc/0x560
[  573.938772]  [<ffffffff8156b3b0>] sch_direct_xmit+0xe0/0x1c0
[  573.939995]  [<ffffffff8154da49>] dev_queue_xmit+0x1f9/0x480
[  573.941218]  [<ffffffff81553af1>] neigh_direct_output+0x11/0x20
[  573.942587]  [<ffffffff815f2a58>] ip6_finish_output2+0x168/0x4b0
[  573.943880]  [<ffffffff815f51bd>] ip6_fragment+0x77d/0xa60
[  573.945065]  [<ffffffff815f28f0>] ? ip6_xmit+0x400/0x400
[  573.946229]  [<ffffffff815f5521>] ip6_finish_output+0x81/0xc0
[  573.947905]  [<ffffffff815f559e>] ip6_output+0x3e/0xb0
[  573.949042]  [<ffffffff815f44da>] ip6_forward+0x29a/0x800
[  573.950212]  [<ffffffff81601ba4>] ? ip6_route_input+0xa4/0xd0
[  573.951497]  [<ffffffff815f5610>] ? ip6_output+0xb0/0xb0
[  573.952653]  [<ffffffff815f5690>] ip6_rcv_finish+0x80/0x90
[  573.953844]  [<ffffffffa03c386e>] __ipv6_conntrack_in+0xce/0x1a0 [nf_conntrack_ipv6]
[  573.955520]  [<ffffffffa03c39c7>] ipv6_conntrack_in+0x27/0x30 [nf_conntrack_ipv6]
[  573.957218]  [<ffffffff8157a1bb>] nf_iterate+0x8b/0xa0
[  573.958335]  [<ffffffff815f5610>] ? ip6_output+0xb0/0xb0
[  573.959488]  [<ffffffff8157a244>] nf_hook_slow+0x74/0x130
[  573.960653]  [<ffffffff815f5610>] ? ip6_output+0xb0/0xb0
[  573.961898]  [<ffffffffa03ba203>] nf_ct_frag6_output+0xe3/0x100 [nf_defrag_ipv6]
[  573.963497]  [<ffffffff815f5610>] ? ip6_output+0xb0/0xb0
[  573.964646]  [<ffffffffa03b90ca>] ipv6_defrag+0xba/0x100 [nf_defrag_ipv6]
[  573.966099]  [<ffffffff815f5610>] ? ip6_output+0xb0/0xb0
[  573.967716]  [<ffffffff8157a1bb>] nf_iterate+0x8b/0xa0
[  573.968834]  [<ffffffff815f5610>] ? ip6_output+0xb0/0xb0
[  573.969984]  [<ffffffff8157a244>] nf_hook_slow+0x74/0x130
[  573.971155]  [<ffffffff815f5610>] ? ip6_output+0xb0/0xb0
[  573.972411]  [<ffffffff815f5e18>] ipv6_rcv+0x348/0x440
[  573.973529]  [<ffffffff8154b8e6>] __netif_receive_skb_core+0x646/0x820
[  573.974928]  [<ffffffff81019900>] ?  flush_ptrace_hw_breakpoint+0x10/0x60
[  573.976362]  [<ffffffff8154bad8>] __netif_receive_skb+0x18/0x60
[  573.977703]  [<ffffffff8154bb53>] netif_receive_skb+0x33/0xa0
[  573.978939]  [<ffffffff8154c520>] napi_gro_receive+0x80/0xb0
[  573.980166]  [<ffffffffa032241f>] e1000_receive_skb+0x7f/0xe0 [e1000e]
[  573.981645]  [<ffffffffa03249ff>] e1000_clean_rx_irq_ps+0x4af/0x780 [e1000e]
[  573.983149]  [<ffffffffa032cd3d>] e1000e_poll+0x6d/0x310 [e1000e]
[  573.984460]  [<ffffffff813daf0c>] ?  add_interrupt_randomness+0x15c/0x190
[  573.985891]  [<ffffffff8154beb9>] net_rx_action+0x149/0x240
[  573.987550]  [<ffffffff8106c427>] __do_softirq+0xf7/0x240
[  573.988721]  [<ffffffff8165875c>] call_softirq+0x1c/0x30
[  573.989873]  [<ffffffff81014695>] do_softirq+0x55/0x90
[  573.990990]  [<ffffffff8106c705>] irq_exit+0xb5/0xc0
[  573.992241]  [<ffffffff81659056>] do_IRQ+0x56/0xc0
[  573.993295]  [<ffffffff8164e9ed>] common_interrupt+0x6d/0x6d
[  573.994517]  <EOI> 
[  573.994954]  [<ffffffff815004df>] ? cpuidle_enter_state+0x4f/0xc0
[  573.996471]  [<ffffffff81500619>] cpuidle_idle_call+0xc9/0x210
[  573.997727]  [<ffffffff8101b60e>] arch_cpu_idle+0xe/0x30
[  573.998875]  [<ffffffff810b663e>] cpu_startup_entry+0xce/0x280
[  574.000131]  [<ffffffff8103ed67>] start_secondary+0x217/0x2c0
[  574.001370] Code: 44 00 00 be 9e 01 00 00 48 c7 c7 f9 ab 9e 81 89 55
d0 e8 44 93 b2 ff 8b 55 d0 e9 7b ff ff ff 41 81 cf 00 20 00 00 e9 f1 fd
ff ff <0f> 0b 0f 0b 44 89 fe 48 89 df e8 d1 f8 ff ff 85 c0 74 12 4c 89 
[  574.008632] RIP  [<ffffffff8153def0>] pskb_expand_head+0x260/0x2a0
[  574.010382]  RSP <ffff88013e3836a8>
[  574.011174] ---[ end trace 3d6846dc38a4d9c7 ]---
[  574.012433] Kernel panic - not syncing: Fatal exception in interrupt


-- 
Michele Baldessari            <michele@acksyn.org>
C2A5 9DA3 9961 4FFB E01B  D0BC DDD4 DCCB 7515 5C6D
