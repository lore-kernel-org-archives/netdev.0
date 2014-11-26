From: Smart Weblications GmbH - Florian Wiessner
	<f.wiessner@smart-weblications.de>
Subject: 3.12.33 Bug with ipvs
Date: Wed, 26 Nov 2014 21:55:27 +0100
Message-ID: <54763E3F.4020306@smart-weblications.de>
Reply-To: f.wiessner@smart-weblications.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smart-weblications.de ([188.65.144.61]:34187 "EHLO
	mail.smart-weblications.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750792AbaKZVDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 16:03:16 -0500
Received: from office.smart-weblications.net (unknown [91.204.168.193])
	by mail.smart-weblications.de (Postfix) with ESMTPA id 0FF174057C7
	for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 20:56:34 +0000 (UTC)
Received: from [192.168.200.60] (unknown [192.168.200.60])
	by office.smart-weblications.net (Postfix) with ESMTPA id 6ADB5C068C
	for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 21:56:33 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi netdev,

On 3.12.33 i see this every 3 hours or so on a box with ip_vs running w=
ith a
setup which made no problems on 3.10.40. Could someone give me hints ho=
w to
debug this? It seems to happen instantly, when i add ip_vs_ftp and have=
 some nat
rules. Setup is like this:

host connected to net with bond0 over eth0 eth1 (bonding mode6)
bond0 added to br0

running 5 lxc using veth on br0 as real servers to use for ipvs

we use net 10.10.1.0/24  10.10.0.0/24  on lxc, 10.10.1.1 as gw-ip on th=
e host
and vip bound to the host so we do some aditional NAT:

iptables -t nat -A POSTROUTING -o br0 -s 10.10.0.0/24 -j SNAT --to 192.=
168.1.61
iptables -t nat -A POSTROUTING -o br0 -s 10.10.1.0/24 ! -d 192.168.1.0/=
26 -j
SNAT --to 192.168.1.62

then setup additional nat for ftp passive to a realserver:
iptables -t nat -A PREROUTING -i br0 -d 192.168.1.62 -p tcp -m multipor=
t
--dports 64000:64444 -j DNAT --to 10.10.1.20

we also use ipv6 in the lxc container, but do not use any ip_vs ipv6 ru=
les


[13230.422498] BUG: unable to handle kernel paging request at 000000000=
00600d0
[13230.422541] IP: [<ffffffff814ff2fc>] xfrm_selector_match+0x25/0x2f6
[13230.422577] PGD 57fb0d067 PUD 718403067 PMD 0
[13230.422682] Oops: 0000 [#1] SMP
[13230.422711] Modules linked in: ip6table_filter ip6_tables ebt_arp eb=
t_ip
ebtable_nat ebtables act_police cls_u32 sch_ingress arptable_filter arp=
_tables
netconsole xmand cpufreq_powersave cpufreq_conservative cpufreq_userspa=
ce
ocfs2_stack_o2cb ocfs2_dlm bridge stp llc bonding fuse nf_conntrack_ftp=
 8021q
openvswitch gre vxlan xt_collia_generic serpent_generic blowfish_generi=
c
blowfish_common cast5_generic cast_common xcbc sha512_generic crypto_nu=
ll af_key
psmouse serio_raw lpc_ich i2c_i801 mfd_c
[13230.423318] CPU: 6 PID: 18038 Comm: kvm.php Not tainted 3.12.33 #6
[13230.423348] Hardware name: Supermicro X9SCI/X9SCA/X9SCI/X9SCA, BIOS =
1.1a
09/28/2011
[13230.423395] task: ffff88043803c680 ti: ffff880162836000 task.ti: fff=
f880162836000
[13230.423440] RIP: 0010:[<ffffffff814ff2fc>]  [<ffffffff814ff2fc>]
xfrm_selector_match+0x25/0x2f6
[13230.423491] RSP: 0018:ffff88083fd83a68  EFLAGS: 00010246
[13230.423519] RAX: 0000000000000001 RBX: ffff88083fd83b88 RCX: ffff880=
4ce5c68c0
[13230.423549] RDX: 0000000000000002 RSI: ffff88083fd83b88 RDI: 0000000=
0000600a6
[13230.423580] RBP: 00000000000600a6 R08: 0000000000000000 R09: ffff880=
83fd83b08
[13230.423611] R10: 0000000000000000 R11: 0000000000000001 R12: ffff880=
83fd83b88
[13230.423641] R13: 0000000000000001 R14: ffffffff81812040 R15: fffffff=
fa01ab3b0
[13230.423672] FS:  00007f6fd48e4720(0000) GS:ffff88083fd80000(0000)
knlGS:0000000000000000
[13230.423725] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[13230.423758] CR2: 00000000000600d0 CR3: 00000007188b1000 CR4: 0000000=
0000407e0
[13230.423790] Stack:
[13230.423817]  0000000000000000 0000000000060002 ffff8804ce5c68c0 ffff=
88083fd83b88
[13230.423877]  0000000000000001 ffffffff814ff611 0000000000000000 ffff=
8800907be740
[13230.423935]  ffff88043803c680 ffffffff81812040 000000003c9041bc ffff=
ffff814ffa8c
[13230.423992] Call Trace:
[13230.424019]  <IRQ>
[13230.424024]  [<ffffffff814ff611>] ? xfrm_sk_policy_lookup+0x44/0x9b
[13230.424076]  [<ffffffff814ffa8c>] ? xfrm_lookup+0x91/0x446
[13230.424111]  [<ffffffff814f76a6>] ? ip_route_me_harder+0x150/0x1b0
[13230.424146]  [<ffffffffa019a457>] ? ip_vs_route_me_harder+0x86/0x91 =
[ip_vs]
[13230.424182]  [<ffffffffa019b97a>] ? ip_vs_out+0x2d3/0x5bc [ip_vs]
[13230.424213]  [<ffffffff814b537c>] ? ip_rcv_finish+0x2b8/0x2b8
[13230.424244]  [<ffffffff814b0237>] ? nf_iterate+0x42/0x80
[13230.424277]  [<ffffffff814b02de>] ? nf_hook_slow+0x69/0xff
[13230.424308]  [<ffffffff814b537c>] ? ip_rcv_finish+0x2b8/0x2b8
[13230.424339]  [<ffffffff814b56a0>] ? ip_local_deliver+0x6f/0x7e
[13230.424371]  [<ffffffff8148c94c>] ? __netif_receive_skb_core+0x5c6/0=
x62d
[13230.424404]  [<ffffffff8148cb48>] ? process_backlog+0x13e/0x13e
[13230.424438]  [<ffffffffa041adfd>] ? br_handle_frame_finish+0x382/0x3=
82 [bridge]
[13230.424493]  [<ffffffff8148cb94>] ? netif_receive_skb+0x4c/0x7d
[13230.424526]  [<ffffffffa041ad89>] ? br_handle_frame_finish+0x30e/0x3=
82 [bridge]
[13230.430400]  [<ffffffffa041afce>] ? br_handle_frame+0x1d1/0x217 [bri=
dge]
[13230.430431]  [<ffffffff8148c7fb>] ? __netif_receive_skb_core+0x475/0=
x62d
[13230.430468]  [<ffffffff8145cf3a>] ? intel_pstate_cpu_exit+0x3c/0x3c
[13230.430504]  [<ffffffff8103eb48>] ? call_timer_fn.isra.24+0x1c/0x6f
[13230.430539]  [<ffffffff8148ca94>] ? process_backlog+0x8a/0x13e
[13230.430577]  [<ffffffff8148cd96>] ? net_rx_action+0x9e/0x175
[13230.430612]  [<ffffffff8103a4b7>] ? __do_softirq+0xb8/0x176
[13230.430643]  [<ffffffff81566c3c>] ? call_softirq+0x1c/0x30
[13230.430671]  <EOI>
[13230.430676]  [<ffffffff810040b1>] ? do_softirq+0x2c/0x5f
[13230.430727]  [<ffffffff81039ffd>] ? local_bh_enable+0x67/0x85
[13230.430756]  [<ffffffff814b8c6a>] ? ip_finish_output+0x2e1/0x33a
[13230.430790]  [<ffffffffa01a11f6>] ? ip_vs_nat_xmit+0x267/0x2b2 [ip_v=
s]
[13230.430822]  [<ffffffffa019b34a>] ? ip_vs_in+0x442/0x4c5 [ip_vs]
[13230.430852]  [<ffffffff814b7cec>] ? ip_forward_options+0x163/0x163
[13230.430882]  [<ffffffff814b0237>] ? nf_iterate+0x42/0x80
[13230.430910]  [<ffffffff814b02de>] ? nf_hook_slow+0x69/0xff
[13230.430939]  [<ffffffff814b7cec>] ? ip_forward_options+0x163/0x163
[13230.430970]  [<ffffffff814b9705>] ? __ip_local_out+0x69/0x76
[13230.431000]  [<ffffffff8147d5e3>] ? __sk_dst_check+0x24/0x4c
[13230.431029]  [<ffffffff814b971b>] ? ip_local_out+0x9/0x22
[13230.431058]  [<ffffffff814b99eb>] ? ip_queue_xmit+0x2b7/0x2f0
[13230.431088]  [<ffffffff814cbdd0>] ? tcp_transmit_skb+0x6f5/0x75b
[13230.431119]  [<ffffffff814cde61>] ? tcp_connect+0x44a/0x4d9
[13230.431149]  [<ffffffff8106fcf8>] ? ktime_get_real+0xc/0x3f
[13230.431180]  [<ffffffff814883cb>] ? secure_tcp_sequence_number+0x4d/=
0x5e
[13230.431211]  [<ffffffff814d0ae4>] ? tcp_v4_connect+0x3ab/0x402
[13230.431241]  [<ffffffff814e10b7>] ? __inet_stream_connect+0x80/0x27c
[13230.431272]  [<ffffffff81125353>] ? fsnotify_clear_marks_by_inode+0x=
26/0x103
[13230.431304]  [<ffffffff814e12e3>] ? inet_stream_connect+0x30/0x48
[13230.431334]  [<ffffffff8147b52e>] ? SyS_connect+0x6e/0x93
[13230.431365]  [<ffffffff8104bc74>] ? task_work_run+0x7d/0x8d
[13230.431394]  [<ffffffff81103804>] ? SyS_fcntl+0x232/0x45e
[13230.431430]  [<ffffffff81565a22>] ? system_call_fastpath+0x16/0x1b
[13230.431464] Code: 5d 41 5e 41 5f c3 41 55 66 83 fa 02 41 54 55 48 89=
 fd 53 48
89 f3 41 50 74 11 31 c0 66 83 fa 0a 0f 85 ce 02 00 00 e9 fd 00 00 00 <0=
f> b6 47
2a 8b
[13230.431740] RIP  [<ffffffff814ff2fc>] xfrm_selector_match+0x25/0x2f6
[13230.431772]  RSP <ffff88083fd83a68>
[13230.431795] CR2: 00000000000600d0
[13230.432240] ---[ end trace 103912aa204977dc ]---

node01:/ocfs2/usr/src/linux-3.12.33/scripts# ./decodecode </tmp/oops.lo=
g
[13230.431464] Code: 5d 41 5e 41 5f c3 41 55 66 83 fa 02 41 54 55 48 89=
 fd 53 48
89 f3 41 50 74 11 31 c0 66 83 fa 0a 0f 85 ce 02 00 00 e9 fd 00 00 00 <0=
f> b6 47
2a 8b 17 8b 76 18 84 c0 74 1a b9 20 00 00 00 31 f2 29
All code
=3D=3D=3D=3D=3D=3D=3D=3D
   0:   5d                      pop    %rbp
   1:   41 5e                   pop    %r14
   3:   41 5f                   pop    %r15
   5:   c3                      retq
   6:   41 55                   push   %r13
   8:   66 83 fa 02             cmp    $0x2,%dx
   c:   41 54                   push   %r12
   e:   55                      push   %rbp
   f:   48 89 fd                mov    %rdi,%rbp
  12:   53                      push   %rbx
  13:   48 89 f3                mov    %rsi,%rbx
  16:   41 50                   push   %r8
  18:   74 11                   je     0x2b
  1a:   31 c0                   xor    %eax,%eax
  1c:   66 83 fa 0a             cmp    $0xa,%dx
  20:   0f 85 ce 02 00 00       jne    0x2f4
  26:   e9 fd 00 00 00          jmpq   0x128
  2b:*  0f b6 47 2a             movzbl 0x2a(%rdi),%eax          <-- tra=
pping
instruction
  2f:   8b 17                   mov    (%rdi),%edx
  31:   8b 76 18                mov    0x18(%rsi),%esi
  34:   84 c0                   test   %al,%al
  36:   74 1a                   je     0x52
  38:   b9 20 00 00 00          mov    $0x20,%ecx
  3d:   31 f2                   xor    %esi,%edx
  3f:   29                      .byte 0x29

Code starting with the faulting instruction
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
   0:   0f b6 47 2a             movzbl 0x2a(%rdi),%eax
   4:   8b 17                   mov    (%rdi),%edx
   6:   8b 76 18                mov    0x18(%rsi),%esi
   9:   84 c0                   test   %al,%al
   b:   74 1a                   je     0x27
   d:   b9 20 00 00 00          mov    $0x20,%ecx
  12:   31 f2                   xor    %esi,%edx
  14:   29                      .byte 0x29


I can't get a clue of that output. I rebuild the kernel now with

CONFIG_IP_VS=3Dm
# CONFIG_IP_VS_IPV6 is not set
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=3D18
CONFIG_IP_VS_PROTO_TCP=3Dy
CONFIG_IP_VS_PROTO_UDP=3Dy
# CONFIG_IP_VS_PROTO_AH_ESP is not set
# CONFIG_IP_VS_PROTO_ESP is not set
# CONFIG_IP_VS_PROTO_AH is not set
# CONFIG_IP_VS_PROTO_SCTP is not set
CONFIG_IP_VS_RR=3Dm
CONFIG_IP_VS_WRR=3Dm
CONFIG_IP_VS_LC=3Dm
CONFIG_IP_VS_WLC=3Dm
CONFIG_IP_VS_LBLC=3Dm
CONFIG_IP_VS_LBLCR=3Dm
CONFIG_IP_VS_DH=3Dm
CONFIG_IP_VS_SH=3Dm
CONFIG_IP_VS_SED=3Dm
CONFIG_IP_VS_NQ=3Dm
CONFIG_IP_VS_SH_TAB_BITS=3D12
CONFIG_IP_VS_FTP=3Dm
CONFIG_IP_VS_NFCT=3Dy
CONFIG_IP_VS_PE_SIP=3Dm

instead of:

CONFIG_IP_VS=3Dm
CONFIG_IP_VS_IPV6=3Dy
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=3D12
CONFIG_IP_VS_PROTO_TCP=3Dy
CONFIG_IP_VS_PROTO_UDP=3Dy
CONFIG_IP_VS_PROTO_AH_ESP=3Dy
CONFIG_IP_VS_PROTO_ESP=3Dy
CONFIG_IP_VS_PROTO_AH=3Dy
# CONFIG_IP_VS_PROTO_SCTP is not set
CONFIG_IP_VS_RR=3Dm
CONFIG_IP_VS_WRR=3Dm
CONFIG_IP_VS_LC=3Dm
CONFIG_IP_VS_WLC=3Dm
CONFIG_IP_VS_LBLC=3Dm
CONFIG_IP_VS_LBLCR=3Dm
CONFIG_IP_VS_DH=3Dm
CONFIG_IP_VS_SH=3Dm
CONFIG_IP_VS_SED=3Dm
CONFIG_IP_VS_NQ=3Dm
CONFIG_IP_VS_SH_TAB_BITS=3D11
# CONFIG_IP_VS_FTP is not set
CONFIG_IP_VS_NFCT=3Dy
# CONFIG_IP_VS_PE_SIP is not set


and try again as i think it might be ipv6 related.


Could someone shed some light on the decoded output and point me somewh=
ere so i
can debug this further?




--=20

Mit freundlichen Gr=FC=DFen,

=46lorian Wiessner

Smart Weblications GmbH
Martinsberger Str. 1
D-95119 Naila

fon.: +49 9282 9638 200
fax.: +49 9282 9638 205
24/7: +49 900 144 000 00 - 0,99 EUR/Min*
http://www.smart-weblications.de

--
Sitz der Gesellschaft: Naila
Gesch=E4ftsf=FChrer: Florian Wiessner
HRB-Nr.: HRB 3840 Amtsgericht Hof
*aus dem dt. Festnetz, ggf. abweichende Preise aus dem Mobilfunknetz
