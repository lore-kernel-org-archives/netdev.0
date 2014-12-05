From: Smart Weblications GmbH - Florian Wiessner
	<f.wiessner@smart-weblications.de>
Subject: Re: 3.12.33 - BUG xfrm_selector_match+0x25/0x2f6
Date: Fri, 05 Dec 2014 03:23:54 +0100
Message-ID: <5481173A.9060308@smart-weblications.de>
References: <547F2462.6040405@smart-weblications.de> <20141204075627.GE6390@secunet.com> <alpine.LFD.2.11.1412042338370.4841@ja.home.ssi.bg>
Reply-To: f.wiessner@smart-weblications.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	stable@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1412042338370.4841@ja.home.ssi.bg>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Am 05.12.2014 00:15, schrieb Julian Anastasov:
>=20
> 	Hello,
>=20
> On Thu, 4 Dec 2014, Steffen Klassert wrote:
>=20
>>> [16623.096721] Call Trace:
>>> [16623.096744]  <IRQ>
>>> [16623.096749]  [<ffffffff81547a7c>] ? xfrm_sk_policy_lookup+0x44/0=
x9b
>>> [16623.096802]  [<ffffffff81547ef7>] ? xfrm_lookup+0x91/0x446
>>> [16623.096832]  [<ffffffff81541316>] ? ip_route_me_harder+0x150/0x1=
b0
>>> [16623.096865]  [<ffffffffa01b6457>] ? ip_vs_route_me_harder+0x86/0=
x91 [ip_vs]
>>> [16623.096899]  [<ffffffffa01b797a>] ? ip_vs_out+0x2d3/0x5bc [ip_vs=
]
>>> [16623.096930]  [<ffffffff81501420>] ? ip_rcv_finish+0x2b8/0x2b8
>>
>> I really wonder why the xfrm_sk_policy_lookup codepath is taken here=
=2E
>> It looks like this is the processing of an inbound ipv4 packet that
>> is going to be rerouted to the output path by ipvs, so this packet
>> should not have socket context at all.
>=20
> 	In above trace looks like IPVS-NAT is used between
> local client and some real server. IPVS handles this skb
> at LOCAL_IN and calls ip_vs_route_me_harder(). If we have
> skb->sk at LOCAL_IN, my first thought is about early demux.
>=20
> 	If I remember correctly, looking at commit f5a41847acc535e2
> ("ipvs: move ip_route_me_harder for ICMP") that introduced
> this rerouting (2.6.37), it was needed because at that time TCP
> used rt_src from received skb to select daddr in ip_send_reply().
> As packets to server are DNAT-ed and packets to client are
> SNAT-ed we used rerouting to fill rt_src with correct IP
> after SNAT.
>=20
> 	Now when routing cache is removed in 3.6 and
> tcp_v4_send_reset() is changed to provide ip_hdr(skb)->saddr
> instead of rt_src it should be safe to remove this rerouting,
> it is enough that ip_hdr(skb)->saddr was updated on IPVS-SNAT at
> LOCAL_IN. In fact, rt_src was removed early in 3.0 with
> commit 0a5ebb8000c5362 ("ipv4: Pass explicit daddr arg to=20
> ip_send_reply().").
>=20
> 	This is only to explain above stack. Not sure
> if problem is related somehow to early demux but such
> commits look interesting:
>=20
> - commit 6b8dbcf2c44fd7a ("bridge: netfilter: orphan skb before invok=
ing=20
> ip netfilter hooks")
>=20
> 	Also, it would be good to know which 3.x kernel between
> 3.13 and 3.17 fixes the problem, it will narrow the search.
>=20


i tried with 3.12.33 without any XFRM and now got this one (which is re=
producable):

[  233.956012] BUG: unable to handle kernel NULL pointer dereference at=
 00000000
                                   00000014
[  233.956218] IP: [<ffffffffa013a470>] nf_ct_seqadj_set+0x60/0x90 [nf_=
conntrack
                                   ]
[  233.956371] PGD 0
[  233.956493] Oops: 0000 [#1] SMP
[  233.956680] Modules linked in: netconsole xt_nat xt_multiport veth i=
ptable_ma
                                   ngle xt_mark nf_conntrack_netlink nf=
netlink
ip_vs_rr ipt_MASQUERADE iptable_nat
nf_nat_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 ipt_REJECT xt_tcpudp iptab=
le_filter
                                    ip_tables cpufreq_ondemand cpufreq_=
powersave
cpufreq_conservative cpufreq_users                                    p=
ace
ocfs2_stack_o2cb ocfs2_dlm bridge stp llc bonding fuse nf_conntrack_ftp=
 802
                               1q openvswitch gre vxlan xt_conntrack x_=
tables
ocfs2_dlmfs dlm sctp ocfs2 ocfs2_                                    no=
demanager
ocfs2_stackglue configfs rbd kvm_intel kvm coretemp ip_vs_ftp ip_vs
                        nf_nat nf_conntrack psmouse i2c_i801 serio_raw =
lpc_ich
mfd_core evdev btrfs lzo_                                    decompress=
 lzo_compress
[  233.960221] CPU: 2 PID: 29996 Comm: vsftpd Not tainted 3.12.33 #4
[  233.960298] Hardware name: Supermicro X9SCI/X9SCA/X9SCI/X9SCA, BIOS =
1.1a 09/2
                                   8/2011
[  233.960395] task: ffff88075e87a2c0 ti: ffff8806a7444000 task.ti: fff=
f8806a744
                                   4000
[  233.960486] RIP: 0010:[<ffffffffa013a470>]  [<ffffffffa013a470>] nf_=
ct_seqadj
                                   _set+0x60/0x90 [nf_conntrack]
[  233.960632] RSP: 0018:ffff88083fc83998  EFLAGS: 00010206
[  233.960709] RAX: 000000000000000c RBX: ffff8806cab452cc RCX: 0000000=
000000003
[  233.960791] RDX: 0000000000000029 RSI: 0000000000000003 RDI: ffff880=
6cab452cc
[  233.960875] RBP: 00000000ee38035a R08: ffff8807e2b1edc0 R09: ffff880=
83fc839a8
[  233.960957] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000=
000000003
[  233.961041] R13: 0000000000000000 R14: 0000000000000003 R15: ffff880=
6a75a50bc
[  233.961124] FS:  00007ff22daec700(0000) GS:ffff88083fc80000(0000) kn=
lGS:00000
                                   00000000000
[  233.961226] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  233.961303] CR2: 0000000000000014 CR3: 00000006b3259000 CR4: 0000000=
0000407e0
[  233.961384] Stack:
[  233.961460]  ffff880815612b60 0000000000000012 0000000000000014 ffff=
8806cab45
                                   2c8
[  233.961776]  ffff8806a75a5001 ffffffffa014f681 0000000000000000 ffff=
ffff00000
                                   045
[  233.962095]  ffff880800000048 0000001b00000003 ffff88083fc83a70 ffff=
880815612
                                   b60
[  233.962411] Call Trace:
[  233.962482]  <IRQ>
[  233.962538]  [<ffffffffa014f681>] ? __nf_nat_mangle_tcp_packet+0x109=
/0x120 [n
                                   f_nat]
[  233.962762]  [<ffffffffa017749e>] ? ip_vs_ftp_out.part.8+0x2b2/0x338=
 [ip_vs_f
                                   tp]
[  233.962866]  [<ffffffff814cb8c0>] ? __domain_mapping+0x25d/0x2a3
[  233.962949]  [<ffffffff8154140c>] ? fib_table_lookup+0xe4/0x255
[  233.963032]  [<ffffffffa015f858>] ? ip_vs_app_pkt_out+0x105/0x18b [i=
p_vs]
[  233.963110]  [<ffffffffa0162ffc>] ? tcp_snat_handler+0x6b/0x320 [ip_=
vs]
[  233.963189]  [<ffffffffa0155d3d>] ? ip_vs_conn_out_get_proto+0x1c/0x=
25 [ip_vs
                                   ]
[  233.963284]  [<ffffffffa0158937>] ? ip_vs_out+0x290/0x5bc [ip_vs]
[  233.963362]  [<ffffffff8150f544>] ? ip_frag_mem+0x2a/0x2a
[  233.963442]  [<ffffffff81508e1f>] ? nf_iterate+0x42/0x80
[  233.963519]  [<ffffffff81508ec6>] ? nf_hook_slow+0x69/0xff
[  233.963595]  [<ffffffff8150f544>] ? ip_frag_mem+0x2a/0x2a
[  233.963667]  [<ffffffff8150f8ae>] ? ip_forward+0x22d/0x2cf
[  233.963744]  [<ffffffff814e57ce>] ? __netif_receive_skb_core+0x5f0/0=
x66c
[  233.963826]  [<ffffffff814e59df>] ? process_backlog+0x13e/0x13e
[  233.963911]  [<ffffffffa0455e09>] ? br_handle_frame_finish+0x382/0x3=
82 [bridg
                                   e]
[  233.964008]  [<ffffffff814e5a2b>] ? netif_receive_skb+0x4c/0x7d
[  233.964090]  [<ffffffffa0455d95>] ? br_handle_frame_finish+0x30e/0x3=
82 [bridg
                                   e]
[  233.964186]  [<ffffffffa0455fda>] ? br_handle_frame+0x1d1/0x217 [bri=
dge]
[  233.964267]  [<ffffffff814e567d>] ? __netif_receive_skb_core+0x49f/0=
x66c
[  233.964350]  [<ffffffff814e592b>] ? process_backlog+0x8a/0x13e
[  233.964429]  [<ffffffff814e5c31>] ? net_rx_action+0xa2/0x1c0
[  233.964508]  [<ffffffff81047e2e>] ? __do_softirq+0xf6/0x24f
[  233.964588]  [<ffffffff8106cbfd>] ? account_system_time+0x10f/0x169
[  233.964669]  [<ffffffff815ad7dc>] ? call_softirq+0x1c/0x30
[  233.964743]  <EOI>
[  233.964801]  [<ffffffff8100464d>] ? do_softirq+0x2c/0x5f
[  233.965013]  [<ffffffff81047ca1>] ? local_bh_enable+0x67/0x85
[  233.965088]  [<ffffffff81511689>] ? ip_finish_output+0x2c9/0x322
[  233.965165]  [<ffffffff8151240a>] ? ip_queue_xmit+0x2b7/0x2f0
[  233.965239]  [<ffffffff81524772>] ? tcp_transmit_skb+0x6ef/0x755
[  233.965316]  [<ffffffff815250e8>] ? tcp_write_xmit+0x886/0x9cb
[  233.965391]  [<ffffffff8152527a>] ? __tcp_push_pending_frames+0x24/0=
x7e
[  233.965473]  [<ffffffff8151a33c>] ? tcp_sendmsg+0xa4c/0xbfc
[  233.965550]  [<ffffffff814d3477>] ? sock_aio_write+0xe3/0xfd
[  233.965631]  [<ffffffff81122f4d>] ? do_sync_write+0x59/0x79
[  233.965709]  [<ffffffff811239e3>] ? vfs_write+0xc4/0x182
[  233.965786]  [<ffffffff81123daf>] ? SyS_write+0x45/0x7c
[  233.965864]  [<ffffffff815ac35b>] ? tracesys+0xdd/0xe2
[  233.965940] Code: 68 14 4d 01 c5 45 85 e4 74 46 f0 80 4f 78 40 48 8d=
 5f 04 48
                                    89 df e8 00 12 47 e1 31 c0 41 83 fe=
 02 0f 97
c0 48 6b c0 0c 4c 01 e8 <8b> 70 08                                     =
39 70 04
74 08 89 ea 0f ca 39 10 79 0d 89 70 04 44 01
[  233.969602] RIP  [<ffffffffa013a470>] nf_ct_seqadj_set+0x60/0x90 [nf=
_conntrac
                                   k]
[  233.969746]  RSP <ffff88083fc83998>
[  233.969816] CR2: 0000000000000014
[  233.969919] ---[ end trace c6faf7aa989b11c2 ]---
[  233.969999] Kernel panic - not syncing: Fatal exception in interrupt
[  233.970081] Rebooting in 10 seconds..
[  244.029931] ACPI MEMORY or I/O RESET_REG.


node01:/ocfs2/usr/src/linux-3.12.33/scripts# ./decodecode < /tmp/oops-i=
pvsftp.txt
[ 233.965940] Code: 68 14 4d 01 c5 45 85 e4 74 46 f0 80 4f 78 40 48 8d =
5f 04 48
89 df e8 00 12 47 e1 31 c0 41 83 fe 02 0f 97 c0 48 6b c0 0c 4c 01 e8 <8=
b> 70 08
39 70 04 74 08 89 ea 0f ca 39 10 79 0d 89 70 04 44 01
All code
=3D=3D=3D=3D=3D=3D=3D=3D
   0:   68 14 4d 01 c5          pushq  $0xffffffffc5014d14
   5:   45 85 e4                test   %r12d,%r12d
   8:   74 46                   je     0x50
   a:   f0 80 4f 78 40          lock orb $0x40,0x78(%rdi)
   f:   48 8d 5f 04             lea    0x4(%rdi),%rbx
  13:   48 89 df                mov    %rbx,%rdi
  16:   e8 00 12 47 e1          callq  0xffffffffe147121b
  1b:   31 c0                   xor    %eax,%eax
  1d:   41 83 fe 02             cmp    $0x2,%r14d
  21:   0f 97 c0                seta   %al
  24:   48 6b c0 0c             imul   $0xc,%rax,%rax
  28:   4c 01 e8                add    %r13,%rax
  2b:*  8b 70 08                mov    0x8(%rax),%esi           <-- tra=
pping
instruction
  2e:   39 70 04                cmp    %esi,0x4(%rax)
  31:   74 08                   je     0x3b
  33:   89 ea                   mov    %ebp,%edx
  35:   0f ca                   bswap  %edx
  37:   39 10                   cmp    %edx,(%rax)
  39:   79 0d                   jns    0x48
  3b:   89 70 04                mov    %esi,0x4(%rax)
  3e:   44                      rex.R
  3f:   01                      .byte 0x1

Code starting with the faulting instruction
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
   0:   8b 70 08                mov    0x8(%rax),%esi
   3:   39 70 04                cmp    %esi,0x4(%rax)
   6:   74 08                   je     0x10
   8:   89 ea                   mov    %ebp,%edx
   a:   0f ca                   bswap  %edx
   c:   39 10                   cmp    %edx,(%rax)
   e:   79 0d                   jns    0x1d
  10:   89 70 04                mov    %esi,0x4(%rax)
  13:   44                      rex.R
  14:   01                      .byte 0x1


setup is like this:


#virtual=3D<myVIP>:21
#       real=3D10.10.1.20:21 masq
#       real=3D10.10.1.21:21 masq
#       real=3D10.10.1.22:21 masq
#       real=3D10.10.1.23:21 masq
#       persistent=3D600
#       service=3Dftp
#       scheduler=3Drr
#       protocol=3Dtcp
#       checktype=3Dconnect

( i remarked it to prevent fruther crashes...)

when ip_vs_ftp is loaded and someone trying to make a ftp connection, t=
he system
panics instantly.

10.10.1.20 - 10.10.1.23 are lxc-containers using veth connected to the =
bridge
running on 4 different nodes. The node running ldirector/ipvsadm has al=
so one of
those containers running (don't know if that matters)

brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.00259052bbf4       no              bond0
                                                        vethMKELUc
                                                        vethXdWGqf
                                                        vethgJMmEb
                                                        vethmKNqFc


I disabled the ftp server lxc container on the node doing ip_vs, so tha=
t the
endpoint of the connection is not on the same node and tried again but =
with the
same result.

Unfortunatelly i cannot test with newer kernels than 3.12, because ocfs=
2 is
somehow broken in >=3D 3.14


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
