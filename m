From: Timo Teras <timo.teras@iki.fi>
Subject: [bisected] [oops] gre/gro oops in skb_gro_receive+0x118/0x453
Date: Fri, 16 May 2014 10:40:14 +0300
Message-ID: <20140516104014.607d2d0f@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:33281 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755345AbaEPHj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 03:39:58 -0400
Received: by mail-la0-f43.google.com with SMTP id mc6so1643041lab.16
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 00:39:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The oops happens when forwarding traffic between ethX <-> gre. Where
the GRE tunnel is an NBMA tunnel and the GRE traffic is IPsec'ed in
transport mode. It seems that locally originating traffic to gre is not
affected.

The oops also goes away if GRO is turned off for gre tunnel device.

I have bisected this always reproducible oops to commit:

8a29111c7ca68d928dfab58636f3f6acf0ac04f7 is the first bad commit

commit 8a29111c7ca68d928dfab58636f3f6acf0ac04f7
Author: Eric Dumazet <edumazet@google.com>
Date: Oct 8 09:02:23 2013 -0700
net: gro: allow to build full sized skb

This oops backtrace is from vanilla 3.14.4 kernel, but it is identical
up to the offending commit.

[  286.927713] BUG: unable to handle kernel paging request at 2b90bdc8
[  286.930813] IP: [<c120fc88>] skb_gro_receive+0x118/0x453
[  286.930813] *pde = 00000000 
[  286.930813] Oops: 0000 [#1] SMP 
[  286.930813] Modules linked in: sha1_generic authenc esp4 xfrm4_mode_transport
deflate ctr twofish_generic twofish_i586 twofish_common camellia_generic
serpent_sse2_i586 xts lrw gf128mul serpent_generic glue_helper ablk_helper cryptd
blowfish_generic blowfish_common cast5_generic cast_common des_generic cbc cmac
xcbc rmd160 sha512_generic hmac crypto_null af_key xfrm_algo ip_gre ip_tunnel
nf_conntrack_netbios_ns nf_conntrack_broadcast iptable_raw ipt_MASQUERADE
iptable_nat nf_nat_ipv4 nf_nat ipt_REJECT xt_helper nf_conntrack_ipv4
nf_defrag_ipv4 iptable_filter ip_tables nf_conntrack_ftp nf_conntrack_sip
xt_CT ip6table_raw xt_LOG xt_limit xt_policy xt_tcpudp nf_conntrack_ipv6
nf_defrag_ipv6 xt_recent xt_multiport xt_conntrack nf_conntrack ip6table_filter
ip6_tables x_tables ipv6 af_packet mousedev via_rng rng_core via_cputemp hwmon
hwmon_vid padlock_aes padlock_sha serio_raw psmouse pcspkr shpchp i2c_viapro
i2c_core via_rhine snd_via82xx snd_ac97_codec snd_pcm snd_timer ac97_bus
snd_mpu401_uart snd_rawmidi snd_seq_device snd soundcore firewire_ohci
firewire_core crc_itu_t via_agp agpgart r8169 firmware_class mii fan evdev
parport_pc parport thermal button acpi_cpufreq processor nls_utf8 nls_cp437
vfat fat sata_via ehci_pci ehci_hcd uhci_hcd pata_via pata_acpi ata_generic
libata usb_storage usbcore usb_common sd_mod scsi_mod crc_t10dif
crct10dif_common squashfs loop
[  286.930813] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.14.4 #1-fragbisect
[  286.930813] Hardware name:    /CN700-8237, BIOS 6.00 PG 08/06/2008
[  286.930813] task: c13e8930 ti: f6408000 task.ti: c13de000
[  286.930813] EIP: 0060:[<c120fc88>] EFLAGS: 00210202 CPU: 0
[  286.930813] EIP is at skb_gro_receive+0x118/0x453
[  286.930813] EAX: 2b90bdc8 EBX: e9f669c0 ECX: 00000034 EDX: 00000596
[  286.930813] ESI: e9f669c0 EDI: f648f134 EBP: f6409eb4 ESP: f6409e7c
[  286.930813]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  286.930813] CR0: 8005003b CR2: 2b90bdc8 CR3: 2a731000 CR4: 00000690
[  286.930813] Stack:
[  286.930813]  c120df4b e9f4f796 00000046 00000000 f648f134 c013a600 0000007a e9f4fd40
[  286.930813]  2b90bdc8 00000034 e9f663c0 e9f663c0 e9f669c0 f648f134 f6409ee0 c125cc6f
[  286.930813]  00000000 00000020 00000046 2e001080 e9f4ed96 00000562 e9f663c0 e9f4f782
[  286.930813] Call Trace:
[  286.930813]  [<c120df4b>] ? csum_partial_ext+0x16/0x18
[  286.930813]  [<c125cc6f>] tcp_gro_receive+0x1a8/0x218
[  286.930813]  [<c125cd9f>] tcp4_gro_receive+0xc0/0xc8
[  286.930813]  [<c1268439>] inet_gro_receive+0x1c5/0x1df
[  286.930813]  [<c1219a15>] dev_gro_receive+0x231/0x393
[  286.930813]  [<f80e006b>] ? rh_timer_func+0x8/0xa [usbcore]
[  286.930813]  [<c1219c1c>] napi_gro_receive+0xb/0x5e
[  286.930813]  [<f8650056>] gro_cell_poll+0x56/0x73 [ip_tunnel]
[  286.930813]  [<c121a2da>] net_rx_action+0xb0/0x14d
[  286.930813]  [<c1030d43>] __do_softirq+0xb8/0x1a5
[  286.930813]  [<c1030c8b>] ? cpu_callback+0xec/0xec
[  286.930813]  <IRQ> 
[  286.930813]  [<c1030fa5>] ? irq_exit+0x44/0x81
[  286.930813]  [<c1002da0>] ? do_IRQ+0x9f/0xb3
[  286.930813]  [<c106e642>] ? clockevents_notify+0x10f/0x116
[  286.930813]  [<c1298d33>] ? common_interrupt+0x33/0x40
[  286.930813]  [<c11f0292>] ? cpuidle_enter_state+0x39/0xa3
[  286.930813]  [<c11f03a5>] ? cpuidle_idle_call+0xa9/0xe6
[  286.930813]  [<c1007f8f>] ? arch_cpu_idle+0x8/0x1c
[  286.930813]  [<c1060542>] ? cpu_startup_entry+0xf3/0x159
[  286.930813]  [<c128b36b>] ? rest_init+0x5d/0x5f
[  286.930813]  [<c1415a17>] ? start_kernel+0x3b2/0x3b8
[  286.930813]  [<c141549b>] ? repair_env_string+0x51/0x51
[  286.930813]  [<c14152d0>] ? i386_start_kernel+0x7a/0x7e
[  286.930813] Code: 54 29 56 50 c7 46 54 00 00 00 00 29 d1 89 8e b4 00 00 00
e9 09 03 00 00 8b 45 f0 f6 80 87 00 00 00 01 8b 45 e8 0f 84 cf 00 00 00
<8a> 00 88 45 d8 0f b6 d0 8b 45 f0 8b 80 ac 00 00 00 89 45 d4 05
[  286.930813] EIP: [<c120fc88>] skb_gro_receive+0x118/0x453 SS:ESP 0068:f6409e7c
[  286.930813] CR2: 000000002b90bdc8
[  286.930813] ---[ end trace ac04411e60d3534c ]---
[  286.930813] Kernel panic - not syncing: Fatal exception in interrupt
[  286.930813] Kernel Offset: 0x0 from 0xc1000000 (relocation range: 0xc0000000-0xf7ffdfff)
