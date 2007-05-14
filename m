From: James Morris <jmorris@namei.org>
Subject: oops in net/ipv4/icmp.c:icmp_send() with icmp_errors_use_inbound_ifaddr
 (fwd)
Date: Mon, 14 May 2007 14:30:17 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0705141430120.8521@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:44390 "EHLO
	mail1.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757110AbXENSaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 14:30:20 -0400
Received: from dsl092-066-197.bos1.dsl.speakeasy.net (HELO d.namei) ([66.92.66.197])
          (envelope-sender <jmorris@namei.org>)
          by mail1.sea5.speakeasy.net (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 14 May 2007 18:30:19 -0000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

---------- Forwarded message ----------
Date: Mon, 14 May 2007 08:15:50 -0700 (PDT)
From: Curtis Doty <Curtis@GreenKey.net>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Subject: oops in net/ipv4/icmp.c:icmp_send() with icmp_errors_use_inbound_ifaddr

Summary: On a multi-homed box, after turning on
/proc/sys/net/ipv4/icmp_errors_use_inbound_ifaddr, it now periodically oopses
when trying to lookup the source address to use for sending an ICMP in response
to a jump ipt_REJECT.

I'm still trying to figure out what makes this test case unique. It spuriously
occurs with many fedora builds of 2.6.{18,19,20} all of which don't appear to
have any patches in this area of the kernel. Just _maybe_ it's because of a
combination of dogleg routing and overloading one vlan with multiple subnets:

# ip route list table main proto kernel scope link
10.10.36.208/28 dev eth0.1  src 10.10.36.210
10.10.36.224/27 dev eth0.1  src 10.10.36.226
10.10.1.0/24 dev eth0.5  src 10.10.1.48
10.10.2.0/24 dev eth0.9  src 10.10.2.27
10.10.10.0/24 dev eth0.8  src 10.10.10.1

Policy routing has been disabled and the problem still occurs. Only one route
remains. It is gw:

# ip route list table main proto boot
default via 10.10.36.209 dev eth0.1

Am I on the right track here or is this a distro/build/config issue? Here's the
oops:

BUG: unable to handle kernel NULL pointer dereference at virtual address
000000a8
 printing eip:
c05fe72b
*pde = 3d429067
Oops: 0000 [#1]
SMP
last sysfs file: /devices/platform/i2c-9191/name
Modules linked in: it87 hwmon_vid hwmon i2c_isa eeprom 8021q nf_nat_ftp
nf_conntrack_ftp ipt_REJECT ipt_owner ipt_ULOG xt_limit xt_state xt_multiport
iptable_filter xt_tcpudp iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack
nfnetlink ip_tables x_tables video sbs i2c_ec dock button battery asus_acpi
backlight ac parport_pc lp parport 8139too 8139cp mii pcspkr i2c_i801 i2c_i810
iTCO_wdt i2c_algo_bit i2c_core iTCO_vendor_support dm_snapshot dm_zero dm_mirror
dm_mod ata_piix libata sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd
CPU:    0
EIP:    0060:[<c05fe72b>]    Not tainted VLI
EFLAGS: 00010246   (2.6.20-1.2948.fc6 #1)
EIP is at inet_select_addr+0x4/0x9f
eax: 00000000   ebx: f8b97046   ecx: 000000fd   edx: 00000000
esi: 000000fd   edi: 00000001   ebp: f71cd0ac   esp: c078bc9c
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, ti=c078b000 task=c06fc480 task.ti=c0746000)
Stack: f8b97046 f601b130 c05fd0b6 f728b980 f728b980 f8b5adbb c05bcb6e c078bd74
       00000003 00000003 00000246 00000246 00000000 f887e014 f8a611a6 f7c1ea80
       f728b9a8 00000000 f727d220 f887e000 00000001 00000072 f7383800 f728b980
Call Trace:
 [<f8b97046>] reject+0x0/0x4ae [ipt_REJECT]
 [<c05fd0b6>] icmp_send+0x14d/0x39b
 [<f8b5adbb>] nf_conntrack_free+0x18/0x20 [nf_conntrack]
 [<c05bcb6e>] __kfree_skb+0xc5/0x10d
 [<f8a611a6>] rtl8139_start_xmit+0xe2/0x112 [8139too]
 [<c05c12fc>] dev_hard_start_xmit+0x1bc/0x21b
 [<c060e141>] xfrm_decode_session+0x44/0x4b
 [<c0620667>] _spin_lock_irqsave+0x9/0xd
 [<c042edc9>] lock_timer_base+0x15/0x2f
 [<c042eed5>] __mod_timer+0x94/0x9e
 [<f8b90406>] ipt_ulog_packet+0x2f0/0x3ba [ipt_ULOG]
 [<f8b97046>] reject+0x0/0x4ae [ipt_REJECT]
 [<f8b9709c>] reject+0x56/0x4ae [ipt_REJECT]
 [<c06205bd>] _spin_unlock_bh+0x5/0xd
 [<f8b904f6>] ipt_ulog_target+0x26/0x2e [ipt_ULOG]
 [<f8b97046>] reject+0x0/0x4ae [ipt_REJECT]
 [<f8b3d454>] ipt_do_table+0x28c/0x2e8 [ip_tables]
 [<c05d7550>] nf_iterate+0x38/0x6a
 [<c05d7681>] nf_hook_slow+0x4d/0xb5
 [<c05dec14>] dst_output+0x0/0x7
 [<c05e0f14>] ip_queue_xmit+0x3a3/0x3f4
 [<c05dec14>] dst_output+0x0/0x7
 [<c0422645>] try_to_wake_up+0x3aa/0x3b4
 [<c05f47f1>] tcp_v4_send_check+0x74/0xaa
 [<c05ef1c3>] tcp_transmit_skb+0x6d5/0x703
 [<c05eff49>] tcp_retransmit_skb+0x4b1/0x592
 [<c05e8db7>] tcp_enter_loss+0x1a8/0x205
 [<c05f258b>] tcp_write_timer+0x43f/0x638
 [<c0620655>] _spin_unlock_irq+0x5/0x7
 [<c0439d17>] hrtimer_run_queues+0x127/0x141
 [<c0422add>] run_rebalance_domains+0x116/0x33e
 [<c05f214c>] tcp_write_timer+0x0/0x638
 [<c042e51b>] run_timer_softirq+0x101/0x164
 [<c042b7b0>] __do_softirq+0x5d/0xba
 [<c040615b>] do_softirq+0x59/0xb1
 [<c0419d4e>] smp_apic_timer_interrupt+0x76/0x80
 [<c04049b0>] apic_timer_interrupt+0x28/0x30
 [<c0402d52>] default_idle+0x0/0x3e
 [<c061007b>] __xfrm_policy_check+0x4c5/0x592
 [<c0402d7e>] default_idle+0x2c/0x3e
 [<c04023d0>] cpu_idle+0x9e/0xb7
 [<c074b812>] start_kernel+0x3b6/0x3be
 [<c074b25a>] unknown_bootoption+0x0/0x202
 =======================
Code: eb 10 39 72 18 75 09 89 f8 33 42 14 85 c6 74 0e 8b 12 85 d2 74 08 f6 42 25
01 74 e6 31 d2 83 c4 0c 89 d0 5b 5e 5f c3 56 89 ce 53 <8b> 80 a8 00 00 00 85 c0
74 39 8b 48 0c 31 db eb 24 0f b6 41 24
EIP: [<c05fe72b>] inet_select_addr+0x4/0x9f SS:ESP 0068:c078bc9c
 <0>Kernel panic - not syncing: Fatal exception in interrupt
 <0>Rebooting in 60 seconds..

And a few relevant details:

# uname -a
Linux host 2.6.20-1.2948.fc6 #1 SMP Fri Apr 27 19:48:40 EDT 2007 i686 i686 i386
GNU/Linux

# lspci -tv
-[0000:00]-+-00.0  Intel Corporation 82845G/GL[Brookdale-G]/GE/PE DRAM
Controller/Host-Hub Interface
           +-02.0  Intel Corporation 82845G/GL[Brookdale-G]/GE Chipset
Integrated Graphics Device
           +-1d.0  Intel Corporation 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M) USB
UHCI Controller #1
           +-1d.1  Intel Corporation 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M) USB
UHCI Controller #2
           +-1d.2  Intel Corporation 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M) USB
UHCI Controller #3
           +-1d.7  Intel Corporation 82801DB/DBM (ICH4/ICH4-M) USB2 EHCI
Controller
           +-1e.0-[0000:01]----05.0  Realtek Semiconductor Co., Ltd.
RTL-8139/8139C/8139C+
           +-1f.0  Intel Corporation 82801DB/DBL (ICH4/ICH4-L) LPC Interface
Bridge
           +-1f.1  Intel Corporation 82801DB (ICH4) IDE Controller
           \-1f.3  Intel Corporation 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M) SMBus
Controller

Rather than turn off ipt_REJECT or icmp_errors_use_inbound_ifaddr, I've removed
the system from production to try and capture the error. It's still live and on
the wire, and the oopses occur every few days/weeks. Unfortunately, I cannot
reproduce at will. :-(

-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
