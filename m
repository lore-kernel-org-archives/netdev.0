From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 95211] New: IPsec + VTI: kernel BUG xfrm_input (NULL
 pointer dereference)
Date: Wed, 25 Mar 2015 17:37:27 -0700
Message-ID: <20150325173727.68f88c82@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36493 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318AbbCZAha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 20:37:30 -0400
Received: by padcy3 with SMTP id cy3so45594878pad.3
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 17:37:29 -0700 (PDT)
Received: from uryu.home.lan ([144.49.132.3])
        by mx.google.com with ESMTPSA id fu14sm3633426pad.44.2015.03.25.17.37.29
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 17:37:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 22 Mar 2015 13:28:55 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 95211] New: IPsec + VTI: kernel BUG xfrm_input (NULL pointer dereference)


https://bugzilla.kernel.org/show_bug.cgi?id=95211

            Bug ID: 95211
           Summary: IPsec + VTI: kernel BUG xfrm_input (NULL pointer
                    dereference)
           Product: Networking
           Version: 2.5
    Kernel Version: 4.0-rc4, 3.16.7, 3.17.8, 3.18.9
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: mike@normi.net
        Regression: No

Hi,

I'm getting a fairly consistent kernel panic once or twice a day when
using a VTI tunnel. This problem has been mentioned before [1], but
assumed to be fixed with 3.18 - apparently that's not the case.

The panic involves the xfrm_input function, which calls
xfrm_tunnel_check, which dereferences outer_mode, which is NULL. I
already tried disabling reauth on the IPsec tunnel, to make the tunnel
as stable as possible, but it still panics from time to time (seems to be less
often though).

Tested with vanilla 3.16.7, 3.17.8, 3.18.9 and 4.0-rc4. Backtrace for
4.0-rc4 is below, together with some other possibly helpful info. The
exact panic location is:

mike@d-debdev-01:~/linux-4.0-rc4$ addr2line ffffffff8150dca2 -e vmlinux -i -f
-p
xfrm_tunnel_check at /home/mike/linux-4.0-rc4/include/net/xfrm.h:1808
    (inlined by) xfrm_input at
/home/mike/linux-4.0-rc4/net/xfrm/xfrm_input.c:241

Thanks,

Mike

[1]: http://marc.info/?t=142495092700001&r=1&w=2


root@p-fw-02:~# ip tunnel
vti1: ip/ip  remote <<right IP 1>>  local <<left IP>>  ttl inherit  key 15
ip_vti0: ip/ip  remote any  local any  ttl inherit  nopmtudisc key 0
vti2: ip/ip  remote <<right IP 2>>  local <<left IP>>  ttl inherit  key 16


root@p-fw-02:~# ip xfrm state
src <<left IP>> dst <<right IP 2>>
    proto esp spi 0xcca59c0d reqid 2 mode tunnel
    replay-window 32 flag af-unspec
    mark 16/0xffffffff
    auth-trunc hmac(sha1) 0x1f620cf9e3b0434f6d5f965b4a83dc25e62f5b11 96
    enc cbc(aes) 0xd9259f7a413d924881c5756da65f490f
src <<right IP 2>> dst <<left IP>>
    proto esp spi 0xc7751dbb reqid 2 mode tunnel
    replay-window 32 flag af-unspec
    mark 16/0xffffffff
    auth-trunc hmac(sha1) 0x64b46cda7791c1f6736317c73fe5275428a97795 96
    enc cbc(aes) 0xeabb8f45e410457897fcaa2a3df64692
src <<left IP>> dst <<right IP 1>>
    proto esp spi 0xc3099c22 reqid 1 mode tunnel
    replay-window 32 flag af-unspec
    mark 15/0xffffffff
    aead rfc4106(gcm(aes)) 0xafc7a185c3bbc7b1a3a41a06e2e61a40ee7dda03 128
src <<right IP 1>> dst <<left IP>>
    proto esp spi 0xcba06a44 reqid 1 mode tunnel
    replay-window 32 flag af-unspec
    mark 15/0xffffffff
    aead rfc4106(gcm(aes)) 0x10d6b583064786efd0286d0e259511fd37d29757 128


root@p-fw-02:~# ip xfrm policy
src 0.0.0.0/0 dst 0.0.0.0/0
    dir fwd priority 3075 ptype main
    mark 16/0xffffffff
    tmpl src <<right IP 2>> dst <<left IP>>
        proto esp reqid 2 mode tunnel
src 0.0.0.0/0 dst 0.0.0.0/0
    dir in priority 3075 ptype main
    mark 16/0xffffffff
    tmpl src <<right IP 2>> dst <<left IP>>
        proto esp reqid 2 mode tunnel
src 0.0.0.0/0 dst 0.0.0.0/0
    dir out priority 3075 ptype main
    mark 16/0xffffffff
    tmpl src <<left IP>> dst <<right IP 2>>
        proto esp reqid 2 mode tunnel
src 0.0.0.0/0 dst 0.0.0.0/0
    dir fwd priority 3075 ptype main
    mark 15/0xffffffff
    tmpl src <<right IP 1>> dst <<left IP>>
        proto esp reqid 1 mode tunnel
src 0.0.0.0/0 dst 0.0.0.0/0
    dir in priority 3075 ptype main
    mark 15/0xffffffff
    tmpl src <<right IP 1>> dst <<left IP>>
        proto esp reqid 1 mode tunnel
src 0.0.0.0/0 dst 0.0.0.0/0
    dir out priority 3075 ptype main
    mark 15/0xffffffff
    tmpl src <<left IP>> dst <<right IP 1>>
        proto esp reqid 1 mode tunnel
src 0.0.0.0/0 dst 0.0.0.0/0
    socket in priority 0 ptype main
src 0.0.0.0/0 dst 0.0.0.0/0
    socket out priority 0 ptype main
src 0.0.0.0/0 dst 0.0.0.0/0
    socket in priority 0 ptype main
src 0.0.0.0/0 dst 0.0.0.0/0
    socket out priority 0 ptype main
src ::/0 dst ::/0
    socket in priority 0 ptype main
src ::/0 dst ::/0
    socket out priority 0 ptype main
src ::/0 dst ::/0
    socket in priority 0 ptype main
src ::/0 dst ::/0
    socket out priority 0 ptype main


[75696.801396] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000034
[75696.824026] IP: [<ffffffff8150dca2>] xfrm_input+0x3c2/0x5a0
[75696.826783] PGD 2d122067 PUD 2d11e067 PMD 0
[75696.828853] Oops: 0000 [#1] SMP
[75696.830427] Modules linked in: authenc hmac seqiv xfrm6_mode_tunnel
xfrm4_mode_tunnel xfrm_user xfrm4_tunnel tunnel4 ipcomp xfrm_ipcomp
esp4 ah4 af_key xfrm_algo act_police cls_basic cls_flow cls_fw cls_u32
sch_tbf sch_prio sch_hfsc sch_htb sch_ingress sch_sfq xt_statistic
xt_CT nf_log_ipv4 nf_log_ipv6 nf_log_common xt_realm xt_LOG
xt_connlimit xt_addrtype xt_comment xt_recent xt_nat ipt_REJECT
nf_reject_ipv4 ipt_MASQUERADE nf_nat_masquerade_ipv4 ipt_ECN
ipt_CLUSTERIP ipt_ah nf_nat_tftp nf_nat_snmp_basic nf_conntrack_snmp
nf_nat_sip nf_nat_pptp nf_nat_proto_gre xt_set ip_set nf_nat_irc
nf_nat_h323 nf_nat_ftp nf_nat_amanda nf_conntrack_sane
nf_conntrack_tftp nf_conntrack_sip nf_conntrack_proto_udplite
nf_conntrack_proto_sctp nf_conntrack_pptp nf_conntrack_proto_gre
ts_kmp nf_conntrack_netlink nf_conntrack_amanda
nf_conntrack_netbios_ns nf_conntrack_broadcast xt_time
nf_conntrack_irc xt_TCPMSS nf_conntrack_h323 nf_conntrack_ftp xt_sctp
xt_TPROXY xt_policy xt_tcpmss xt_pkttype xt_physdev br_netfilter
bridge stp llc xt_owner xt_NFLOG xt_NFQUEUE nfnetlink_log xt_multiport
xt_mark xt_mac xt_limit xt_length xt_iprange xt_helper xt_hashlimit
xt_DSCP xt_dscp xt_dccp xt_connmark xt_CLASSIFY ip6t_REJECT xt_AUDIT
nf_reject_ipv6 xt_tcpudp xt_state nfnetlink ip_vti ip_tunnel
nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_mangle ip6table_raw
ip6table_filter ip6_tables xt_conntrack iptable_mangle iptable_nat
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack
iptable_raw iptable_filter ip_tables x_tables loop iosf_mbi coretemp
crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_pcm aesni_intel
aes_x86_64 snd_timer snd soundcore lrw gf128mul glue_helper
ablk_helper cryptd vmw_balloon psmouse pcspkr serio_raw evdev
parport_pc parport vmwgfx ttm drm_kms_helper drm i2c_piix4 battery
vmw_vmci i2c_core acpi_cpufreq ac button processor thermal_sys shpchp
ext4 crc16 mbcache jbd2 dm_mod sg sr_mod cdrom ata_generic sd_mod
crc32c_intel floppy e1000 ata_piix libata mptspi scsi_transport_spi
mptscsih mptbase scsi_mod
[75696.927310] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.0.0-rc4 #1
[75696.930337] Hardware name: VMware, Inc. VMware Virtual
Platform/440BX Desktop Reference Platform, BIOS 6.00 04/14/2014
[75696.935437] task: ffffffff818164e0 ti: ffffffff81800000 task.ti:
ffffffff81800000
[75696.939122] RIP: 0010:[<ffffffff8150dca2>]  [<ffffffff8150dca2>]
xfrm_input+0x3c2/0x5a0
[75696.943103] RSP: 0018:ffff880031003bd8  EFLAGS: 00010286
[75696.945646] RAX: 0000000000000000 RBX: 0000000000000002 RCX:
0000000000000000
[75696.949073] RDX: 0000000000000001 RSI: 00000000fffffe01 RDI:
ffffffff8150aad3
[75696.952481] RBP: 0000000000000032 R08: ffff880021296800 R09:
0000000000000002
[75696.955965] R10: 0000000000000032 R11: 000000000000000f R12:
0000000000000000
[75696.959369] R13: ffff880021296800 R14: ffff88002d73e300 R15:
0000000000000032
[75696.962802] FS:  0000000000000000(0000) GS:ffff880031000000(0000)
knlGS:0000000000000000
[75696.966707] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[75696.969510] CR2: 0000000000000034 CR3: 000000002d100000 CR4:
00000000000407f0
[75696.973093] Stack:
[75696.974147]  ffff88002d73e300 89888c9a7649897f 0000000000000000
ffffffff818b8e80
[75696.978017]  ffff88002b79761e bc33cec600000002 0000000000000000
010000002d4058c0
[75696.981857]  ffff8800001e20a0 ffffffffa0446040 ffff88002d73e300
ffffffff818b8e80
[75696.985740] Call Trace:
[75696.986978]  <IRQ>
[75696.987960]  [<ffffffff81500fc6>] ? xfrm4_esp_rcv+0x36/0x70
[75696.990949]  [<ffffffff814acc9a>] ? ip_local_deliver_finish+0x9a/0x200
[75696.994130]  [<ffffffff81471b83>] ? __netif_receive_skb_core+0x6f3/0x8f0
[75696.997405]  [<ffffffff8101e0d5>] ? read_tsc+0x5/0x10
[75697.000076]  [<ffffffff81471f4f>] ? netif_receive_skb_internal+0x1f/0x90
[75697.003395]  [<ffffffff81472b60>] ? napi_gro_receive+0xb0/0xe0
[75697.006209]  [<ffffffffa00ca8a7>] ? e1000_clean_rx_irq+0x2b7/0x500 [e1000]
[75697.009510]  [<ffffffff81573c6d>] ? common_interrupt+0x6d/0x6d
[75697.012388]  [<ffffffffa00ccd14>] ? e1000_clean+0x274/0x910 [e1000]
[75697.015420]  [<ffffffff81471b83>] ? __netif_receive_skb_core+0x6f3/0x8f0
[75697.018590]  [<ffffffff814726ad>] ? net_rx_action+0x15d/0x320
[75697.021355]  [<ffffffff81073a3e>] ? __do_softirq+0xde/0x260
[75697.024035]  [<ffffffff81073e05>] ? irq_exit+0x95/0xa0
[75697.026511]  [<ffffffff81575e84>] ? do_IRQ+0x64/0x110
[75697.028973]  [<ffffffff81573c6d>] ? common_interrupt+0x6d/0x6d
[75697.031763]  <EOI>
[75697.032715]  [<ffffffff8101f5f0>] ? idle_notifier_register+0x20/0x20
[75697.036134]  [<ffffffff81059002>] ? native_safe_halt+0x2/0x10
[75697.038931]  [<ffffffff8101f60c>] ? default_idle+0x1c/0xb0
[75697.041760]  [<ffffffff810acb8c>] ? cpu_startup_entry+0x32c/0x430
[75697.044588]  [<ffffffff819060b4>] ? start_kernel+0x48a/0x495
[75697.047211]  [<ffffffff81905a31>] ? set_init_arg+0x50/0x50
[75697.049758]  [<ffffffff81905117>] ? early_idt_handlers+0x117/0x120
[75697.052658]  [<ffffffff81905117>] ? early_idt_handlers+0x117/0x120
[75697.055668]  [<ffffffff81905737>] ? x86_64_start_kernel+0x161/0x170
[75697.058698] Code: f9 ff ff 48 8b 44 24 08 49 89 46 68 e9 f4 fc ff
ff 0f 1f 84 00 00 00 00 00 49 83 7e 40 00 0f 84 6c fd ff ff 49 8b 85
e0 02 00 00 <f6> 40 34 01 0f 85 5b fd ff ff e9 93 fd ff ff 0f 1f 80 00
00 00
[75697.072570] RIP  [<ffffffff8150dca2>] xfrm_input+0x3c2/0x5a0
[75697.075434]  RSP <ffff880031003bd8>
[75697.077227] CR2: 0000000000000034
[75697.079773] ---[ end trace 427b0d003f7ec598 ]---
[75697.082615] Kernel panic - not syncing: Fatal exception in interrupt
[75697.086138] Kernel Offset: disabled
[75697.088004] Rebooting in 1 seconds..
[75698.097904] ACPI MEMORY or I/O RESET_REG.

-- 
You are receiving this mail because:
You are the assignee for the bug.
