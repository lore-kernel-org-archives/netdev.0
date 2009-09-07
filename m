From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Next Sept 7: Bug : skb_release_head_state on x86
Date: Mon, 07 Sep 2009 19:17:02 +0200
Message-ID: <4AA5400E.9010108@gmail.com>
References: <20090907210206.7830ba68.sfr@canb.auug.org.au> <4AA5399A.405@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, David Miller <davem@davemloft.net>
To: Sachin Sant <sachinp@in.ibm.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4AA5399A.405@in.ibm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sachin Sant a =E9crit :
> Today's next kernel running on a x86 box crashed with
>=20
> BUG: unable to handle kernel paging request at 00010090
> IP: [<c034559d>] skb_release_head_state+0x20/0xac
> *pdpt =3D 000000003455c001 *pde =3D 0000000000000000
> Oops: 0002 [#1] SMP
> last sysfs file: /sys/devices/system/cpu/cpu3/topology/core_siblings
> Modules linked in: ipv6 microcode fuse loop dm_mod ppdev rtc_cmos i2c=
_piix4
> rtc_core i2c_core rtc_lib button sr_mod tg3 parport_pc sworks_agp cdr=
om
> floppy
> parport agpgart pcspkr libphy sg ohci_hcd ehci_hcd sd_mod crc_t10dif
> usbcore
> edd fan ide_pci_generic serverworks ide_core ata_generic pata_serverw=
orks
> libata ips scsi_mod thermal processor thermal_sys hwmon [last unloade=
d:
> speedstep_lib]
>=20
> Pid: 6, comm: ksoftirqd/1 Not tainted
> (2.6.31-rc9-autotest-next-20090907-5-pae
> #1) eserver xSeries 235 -[86717AX]-
> EIP: 0060:[<c034559d>] EFLAGS: 00010206 CPU: 1
> EIP is at skb_release_head_state+0x20/0xac
> EAX: 00000000 EBX: f44b5200 ECX: f44b5200 EDX: 00010090
> ESI: f5548000 EDI: 00000000 EBP: f5c69dd4 ESP: f5c69dd0
> DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> Process ksoftirqd/1 (pid: 6, ti=3Df5c68000 task=3Df5c4f280 task.ti=3D=
f5c68000)
> Stack:
> f44b5200 f5c69de0 c0345398 f5c69e48 f5c69de8 c034542e f5c69e58 c03888=
07
> <0> f44b5200 f5582900 ced1a038 c07ac124 ced1a030 3e6f7c09 eb152044 f4=
b4bc00
> <0> 00000006 c05a594c f5c69e30 c036a2c0 c07ac124 f4b4bc00 f4b4bc00 eb=
152030
> Call Trace:

This is a crash on a 32bit kernel

> [<c0345398>] ? __kfree_skb+0xb/0x71
> [<c034542e>] ? consume_skb+0x30/0x32
> [<c0388807>] ? arp_process+0x572/0x58e
> [<c036a2c0>] ? ip_local_deliver_finish+0x143/0x207
> [<c0388907>] ? arp_rcv+0xda/0xed
> [<c034bdc2>] ? netif_receive_skb+0x43a/0x459
> [<c034bee4>] ? napi_skb_finish+0x1e/0x33
> [<c034c267>] ? napi_gro_receive+0x20/0x24
> [<f8b3667f>] ? tg3_poll+0x5ed/0x802 [tg3]
> [<c034c351>] ? net_rx_action+0x93/0x173
> [<c013769c>] ? __do_softirq+0xa7/0x144
> [<c013775f>] ? do_softirq+0x26/0x2b
> [<c01377ae>] ? ksoftirqd+0x4a/0xae
> [<c0137764>] ? ksoftirqd+0x0/0xae
> [<c0146a2e>] ? kthread+0x61/0x66
> [<c01469cd>] ? kthread+0x0/0x66
> [<c0103507>] ? kernel_thread_helper+0x7/0x10
> Code: fe ff ff 83 c4 0c 5b 5e 5f 5d c3 55 89 e5 53 89 c3 8b 40 18 85 =
c0
> 74 05
> e8 22 ae 00 00 8b 53 1c c7 43 18 00 00 00 00 85 d2 74 11 <f0> ff 0a 0=
f
> 94 c0 84
> c0 74 07 89 d0 e8 81 c6 05 00 83 7b 6c 00
> EIP: [<c034559d>] skb_release_head_state+0x20/0xac SS:ESP 0068:f5c69d=
d0
> CR2: 0000000000010090
> ---[ end trace 64c8710cf222dc04 ]---
>=20
> At the time of crash, kernbench was running on this box.
>=20
> The corresponding c code is :
> 0000000000002387 <skb_release_head_state>:
> static void skb_release_head_state(struct sk_buff *skb) {


and you decode a 64 bits kernel

>    2387:       55                      push   %rbp     2388:       48=
 89
> e5                mov    %rsp,%rbp
>    238b:       53                      push   %rbx     238c:       48=
 89
> fb                mov    %rdi,%rbx
>    238f:       48 83 ec 08             sub    $0x8,%rsp
> skb_dst_drop():
> /usr/local/autobench/var/tmp/build/linux/include/net/dst.h:179
> }
> ...... <SNIP> ......
> ...... <SNIP> ......
>=20
> skb_release_head_state():
> /usr/local/autobench/var/tmp/build/linux/net/core/skbuff.c:395
>        skb_dst_drop(skb);
> #ifdef CONFIG_XFRM
>        secpath_put(skb->sp);
>    23a1:       48 8b 7b 30             mov    0x30(%rbx),%rdi
> skb_dst_drop():
> /usr/local/autobench/var/tmp/build/linux/include/net/dst.h:181
>        skb->_skb_dst =3D 0UL;
>    23a5:       48 c7 43 28 00 00 00    movq   $0x0,0x28(%rbx)
> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  This line
>    23ac:       00
>=20

This is more probably
=20
<f0> ff 0a       lock decl (%edx)

part of :=20

secpath_put(skb->sp);


So some skb has a strange/buggy skb->sp (value 0x00010090)

It looks like skb->cb[xxx] overwrote skb->sp

Please check you have CONFIG_XFRM=3Dy, and that you did rebuild all you=
r modules after
patching your kernel...
