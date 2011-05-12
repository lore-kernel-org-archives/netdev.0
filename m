From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next] net:set valid name before calling ndo_init()
Date: Thu, 12 May 2011 23:32:58 +0800
Message-ID: <BANLkTi=0FvtU0drkV=sGzc-4pGuvDrgnnw@mail.gmail.com>
References: <1300936598-3971-1-git-send-email-panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	mirq-linux@rere.qmqm.pl, jpirko@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?UTF-8?B?V2VpcGluZyBQYW4o5r2Y5Y2r5bmzKQ==?=
	<panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f173.google.com ([209.85.212.173]:41216 "EHLO
	mail-px0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755208Ab1ELPdS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 11:33:18 -0400
In-Reply-To: <1300936598-3971-1-git-send-email-panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2011 at 11:16 AM, Weiping Pan(=E6=BD=98=E5=8D=AB=E5=B9=B3=
)
<panweiping3@gmail.com> wrote:
> From: Pan Weiping <panweiping3@gmail.com>
>
> A bug of bonding was invloved by e815d19ffe02bdfda1260949ef2b1806171,
> see example 1 and 2.
>
> In register_netdevice(), the name of net_device is not valid until
> dev_get_valid_name() is called. But dev->netdev_ops->ndo_init(that is
> bond_init) is called before dev_get_valid_name(),
> and it uses the invalid name of net_device.
>
> I think register_netdevice() should make sure that the name of net_de=
vice is
> valid before calling ndo_init().
>
> example 1:
> modprobe bonding
> ls =C2=A0/proc/net/bonding/bond%d
>
> ps -eLf
> root =C2=A0 =C2=A0 =C2=A03398 =C2=A0 =C2=A0 2 =C2=A03398 =C2=A00 =C2=A0=
 =C2=A01 21:34 ? =C2=A0 =C2=A0 =C2=A0 =C2=A000:00:00 [bond%d]
>
> example 2:
> modprobe bonding max_bonds=3D3
>
> [ =C2=A0170.100292] bonding: Ethernet Channel Bonding Driver: v3.7.1 =
(April 27, 2011)
> [ =C2=A0170.101090] bonding: Warning: either miimon or arp_interval a=
nd arp_ip_target module parameters must be specified, otherwise bonding=
 will not detect link failures! see bonding.txt for details.
> [ =C2=A0170.102469] ------------[ cut here ]------------
> [ =C2=A0170.103150] WARNING: at /home/pwp/net-next-2.6/fs/proc/generi=
c.c:586 proc_register+0x126/0x157()
> [ =C2=A0170.104075] Hardware name: VirtualBox
> [ =C2=A0170.105065] proc_dir_entry 'bonding/bond%d' already registere=
d
> [ =C2=A0170.105613] Modules linked in: bonding(+) sunrpc ipv6 uinput =
microcode ppdev parport_pc parport joydev e1000 pcspkr i2c_piix4 i2c_co=
re [last unloaded: bonding]
> [ =C2=A0170.108397] Pid: 3457, comm: modprobe Not tainted 2.6.39-rc2+=
 #14
> [ =C2=A0170.108935] Call Trace:
> [ =C2=A0170.109382] =C2=A0[<c0438f3b>] warn_slowpath_common+0x6a/0x7f
> [ =C2=A0170.109911] =C2=A0[<c051a42a>] ? proc_register+0x126/0x157
> [ =C2=A0170.110329] =C2=A0[<c0438fc3>] warn_slowpath_fmt+0x2b/0x2f
> [ =C2=A0170.110846] =C2=A0[<c051a42a>] proc_register+0x126/0x157
> [ =C2=A0170.111870] =C2=A0[<c051a4dd>] proc_create_data+0x82/0x98
> [ =C2=A0170.112335] =C2=A0[<f94e6af6>] bond_create_proc_entry+0x3f/0x=
73 [bonding]
> [ =C2=A0170.112905] =C2=A0[<f94dd806>] bond_init+0x77/0xa5 [bonding]
> [ =C2=A0170.113319] =C2=A0[<c0721ac6>] register_netdevice+0x8c/0x1d3
> [ =C2=A0170.113848] =C2=A0[<f94e0e30>] bond_create+0x6c/0x90 [bonding=
]
> [ =C2=A0170.114322] =C2=A0[<f94f4763>] bonding_init+0x763/0x7b1 [bond=
ing]
> [ =C2=A0170.114879] =C2=A0[<c0401240>] do_one_initcall+0x76/0x122
> [ =C2=A0170.115317] =C2=A0[<f94f4000>] ? 0xf94f3fff
> [ =C2=A0170.115799] =C2=A0[<c0463f1e>] sys_init_module+0x1286/0x140d
> [ =C2=A0170.116879] =C2=A0[<c07c6d9f>] sysenter_do_call+0x12/0x28
> [ =C2=A0170.117404] ---[ end trace 64e4fac3ae5fff1a ]---
> [ =C2=A0170.117924] bond%d: Warning: failed to register to debugfs
> [ =C2=A0170.128728] ------------[ cut here ]------------
> [ =C2=A0170.129360] WARNING: at /home/pwp/net-next-2.6/fs/proc/generi=
c.c:586 proc_register+0x126/0x157()
> [ =C2=A0170.130323] Hardware name: VirtualBox
> [ =C2=A0170.130797] proc_dir_entry 'bonding/bond%d' already registere=
d
> [ =C2=A0170.131315] Modules linked in: bonding(+) sunrpc ipv6 uinput =
microcode ppdev parport_pc parport joydev e1000 pcspkr i2c_piix4 i2c_co=
re [last unloaded: bonding]
> [ =C2=A0170.133731] Pid: 3457, comm: modprobe Tainted: G =C2=A0 =C2=A0=
 =C2=A0 =C2=A0W =C2=A0 2.6.39-rc2+ #14
> [ =C2=A0170.134308] Call Trace:
> [ =C2=A0170.134743] =C2=A0[<c0438f3b>] warn_slowpath_common+0x6a/0x7f
> [ =C2=A0170.135305] =C2=A0[<c051a42a>] ? proc_register+0x126/0x157
> [ =C2=A0170.135820] =C2=A0[<c0438fc3>] warn_slowpath_fmt+0x2b/0x2f
> [ =C2=A0170.137168] =C2=A0[<c051a42a>] proc_register+0x126/0x157
> [ =C2=A0170.137700] =C2=A0[<c051a4dd>] proc_create_data+0x82/0x98
> [ =C2=A0170.138174] =C2=A0[<f94e6af6>] bond_create_proc_entry+0x3f/0x=
73 [bonding]
> [ =C2=A0170.138745] =C2=A0[<f94dd806>] bond_init+0x77/0xa5 [bonding]
> [ =C2=A0170.139278] =C2=A0[<c0721ac6>] register_netdevice+0x8c/0x1d3
> [ =C2=A0170.139828] =C2=A0[<f94e0e30>] bond_create+0x6c/0x90 [bonding=
]
> [ =C2=A0170.140361] =C2=A0[<f94f4763>] bonding_init+0x763/0x7b1 [bond=
ing]
> [ =C2=A0170.140927] =C2=A0[<c0401240>] do_one_initcall+0x76/0x122
> [ =C2=A0170.141494] =C2=A0[<f94f4000>] ? 0xf94f3fff
> [ =C2=A0170.141975] =C2=A0[<c0463f1e>] sys_init_module+0x1286/0x140d
> [ =C2=A0170.142463] =C2=A0[<c07c6d9f>] sysenter_do_call+0x12/0x28
> [ =C2=A0170.142974] ---[ end trace 64e4fac3ae5fff1b ]---
> [ =C2=A0170.144949] bond%d: Warning: failed to register to debugfs
>
> Signed-off-by: Pan Weiping <panweiping3@gmail.com>
Acked-by: Changli Gao <xiaosuo@gmail.com>


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
