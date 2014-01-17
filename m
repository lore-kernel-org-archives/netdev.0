From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PANIC in vxlan <debugging now>
Date: Thu, 16 Jan 2014 19:37:39 -0800
Message-ID: <1389929859.31367.466.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140116171428.00004da1@unknown>
	 <52D89EAE.2080308@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:52258 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbaAQDhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 22:37:42 -0500
Received: by mail-yk0-f170.google.com with SMTP id 9so1743128ykp.1
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 19:37:41 -0800 (PST)
In-Reply-To: <52D89EAE.2080308@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-17 at 11:08 +0800, Fan Du wrote:
>=20
> On 2014=E5=B9=B401=E6=9C=8817=E6=97=A5 09:14, Jesse Brandeburg wrote:
> > I'm currently debugging this but given where the kernel release cyc=
le
> > is I wanted to let the list know.
>=20
> How you reproduce it? I use below two methods, both works.
> And my net-next head is at: abfce3ef58b6a6c95de389f9d20047a05b10e484,=
 pretty new.
>=20
> Method 1:
> ip link add vxlan0 type vxlan id 42 group ff0e::110
> ip link set vxlan0 up
> ip link set vxlan0 down
>=20
> Method 2:
> ip link add vxlan0 type vxlan id 42 group ff0e::110
> ip link set vxlan0 up
> ip link delete vxlan0
>=20

Given the stack trace, it seems you need to setup a network namespace.

Try=20

ip netns add foo


>=20
> > It may well be a bug in our code, and if it is we'll find it, but h=
ere is
> > the panic, it doesn't occur when vxlan is not enabled.
> >
> > Jan 16 13:46:44 jbrandeb-cp2 kernel: [   17.331010] cgroup: libvirt=
d (1387) created nested cgroup for controller "memory" which has incomp=
lete hierarchy supp
> > ort. Nested cgroups may change behavior in the future.
> > Jan 16 13:46:44 jbrandeb-cp2 kernel: [   17.331014] cgroup: "memory=
" requires setting use_hierarchy to 1 on the root.
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.576568] ------------[ c=
ut here ]------------
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.586411] kernel BUG at i=
nclude/net/netns/generic.h:45!
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.596336] invalid opcode:=
 0000 [#1] SMP
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.606268] Modules linked =
in: lockd sunrpc i40e igb iTCO_wdt iTCO_vendor_support sb_edac ioatdma =
ptp microcode lpc_ich edac_core i2c_i801 mfd_core dca pps_core wmi kvm =
uinput isci firewire_ohci libsas firewire_core crc_itu_t scsi_transport=
_sas mgag200 drm_kms_helper ttm
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.637923] CPU: 0 PID: 138=
7 Comm: libvirtd Not tainted 3.13.0-rc7+ #30
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.648599] Hardware name: =
Intel Corporation S2600CO ........../S2600CO, BIOS SE5C600.86B.01.08.60=
03.062420131549 06/24/2013
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.659612] task: ffff88063=
b5c6000 ti: ffff8806333ca000 task.ti: ffff8806333ca000
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.670661] RIP: 0010:[<fff=
fffff816df92f>]  [<ffffffff816df92f>] net_generic.isra.34.part.35+0x4/0=
x6
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.681738] RSP: 0018:ffff8=
806333cbb80  EFLAGS: 00010246
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.692536] RAX: 0000000000=
000000 RBX: 00000000ffffffed RCX: 0000000000000010
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.703577] RDX: ffff88063d=
03d380 RSI: 0000000000000010 RDI: ffffffff81cfd9f0
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.714612] RBP: ffff880633=
3cbb80 R08: 0000000000000000 R09: ffffffff81cfd9f0
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.725531] R10: 0000000000=
0002cc R11: 0000000000000004 R12: 0000000000000000
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.736448] R13: ffff880639=
118000 R14: ffff8806333cbc68 R15: 0000000000000000
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.747292] FS:  00007f6381=
830700(0000) GS:ffff880647600000(0000) knlGS:0000000000000000
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.758248] CS:  0010 DS: 0=
000 ES: 0000 CR0: 0000000080050033
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.769263] CR2: 00007f637c=
04b000 CR3: 0000000c3aa1f000 CR4: 00000000000407f0
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.780402] Stack:
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.791386]  ffff8806333cbb=
c0 ffffffff814d0865 ffff8806333cbc40 00000000ffffffef
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.802702]  00000000ffffff=
ed ffffffff81cc67d0 0000000000000010 ffff8806333cbc68
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.814021]  ffff8806333cbc=
00 ffffffff816e9e5d 0000000000000004 ffff8806333cbc68
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.825185] Call Trace:
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.836106]  [<ffffffff814d=
0865>] vxlan_lowerdev_event+0xf5/0x100
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.847254]  [<ffffffff816e=
9e5d>] notifier_call_chain+0x4d/0x70
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.858457]  [<ffffffff8109=
12be>] __raw_notifier_call_chain+0xe/0x10
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.869696]  [<ffffffff8109=
12d6>] raw_notifier_call_chain+0x16/0x20
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.880896]  [<ffffffff815d=
9610>] call_netdevice_notifiers_info+0x40/0x70
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.892063]  [<ffffffff815d=
9656>] call_netdevice_notifiers+0x16/0x20
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.903107]  [<ffffffff815e=
1bce>] register_netdevice+0x1be/0x3a0
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.914128]  [<ffffffff815e=
1dce>] register_netdev+0x1e/0x30
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.925072]  [<ffffffff814c=
b94a>] loopback_net_init+0x4a/0xb0
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.936048]  [<ffffffffa016=
ed6e>] ? lockd_init_net+0x6e/0xb0 [lockd]
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.947081]  [<ffffffff815d=
6bac>] ops_init+0x4c/0x150
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.958070]  [<ffffffff815d=
6d23>] setup_net+0x73/0x110
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.969006]  [<ffffffff815d=
725b>] copy_net_ns+0x7b/0x100
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.979897]  [<ffffffff8109=
0e11>] create_new_namespaces+0x101/0x1b0
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   17.990855]  [<ffffffff8109=
0f45>] copy_namespaces+0x85/0xb0
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   18.001656]  [<ffffffff8106=
93d5>] copy_process.part.26+0x935/0x1500
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   18.012370]  [<ffffffff811d=
5186>] ? mntput+0x26/0x40
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   18.022924]  [<ffffffff8106=
a15c>] do_fork+0xbc/0x2e0
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   18.033331]  [<ffffffff811b=
7f2e>] ? ____fput+0xe/0x10
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   18.043622]  [<ffffffff8108=
9c5c>] ? task_work_run+0xac/0xe0
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   18.053905]  [<ffffffff8106=
a406>] SyS_clone+0x16/0x20
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   18.064265]  [<ffffffff816e=
e689>] stub_clone+0x69/0x90
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   18.074600]  [<ffffffff816e=
e329>] ? system_call_fastpath+0x16/0x1b
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   18.084879] Code: 00 75 1d =
55 be 2f 00 00 00 48 c7 c7 65 93 a2 81 48 89 e5 e8 f4 b5 98 ff 5d c6 05=
 30 aa 5f 00 01 c3 55 48 89 e5 0f 0b 55 48 89 e5<0f>  0b 55 48 89 e5 0f=
 0b 66 66 66 66 90 55 48 c7 c7 c0 4c cb 81
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   18.105818] RIP  [<ffffffff=
816df92f>] net_generic.isra.34.part.35+0x4/0x6
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   18.116106]  RSP<ffff880633=
3cbb80>
> > Jan 16 13:46:45 jbrandeb-cp2 kernel: [   18.172366] ---[ end trace =
0bb84cf9aa76a384 ]---
> > Jan 16 13:46:47 jbrandeb-cp2 systemd[1]: Startup finished in 4s 918=
ms 164us (kernel) + 3s 548ms 460us (initrd) + 11s 2ms 474us (userspace)=
 =3D 19s 469ms 98us.
> > Jan 16 13:46:47 jbrandeb-cp2 dbus-daemon[989]: dbus[989]: [system] =
Activating via systemd: service name=3D'org.freedesktop.Accounts' unit=3D=
'accounts-daemon.service'
> >
> > code says:
> > (gdb) l *(vxlan_lowerdev_event+0xf5)
> > 0xffffffff814d0865 is at include/net/netns/generic.h:41.
> > 34      static inline void *net_generic(const struct net *net, int =
id)
> > 35      {
> > 36              struct net_generic *ng;
> > 37              void *ptr;
> > 38
> > 39              rcu_read_lock();
> > 40              ng =3D rcu_dereference(net->gen);
> > 41              BUG_ON(id =3D=3D 0 || id>  ng->len);
> > 42              ptr =3D ng->ptr[id - 1];
> > 43              rcu_read_unlock();
> > 44
> >>>>> 45              BUG_ON(!ptr);
> > 46              return ptr;
> > 47      }
> > 48      #endif
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
>=20
