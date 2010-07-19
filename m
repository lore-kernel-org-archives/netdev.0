From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG net-next-2.6] vlan, bonding, bnx2 problems
Date: Mon, 19 Jul 2010 15:24:14 +0200
Message-ID: <1279545854.2553.37.camel@edumazet-laptop>
References: <a372414c0d74e9ab599d095627353d94@dondevamos.com>
	 <1278015554.2782.11.camel@edumazet-laptop>
	 <957a5becb6e742b6dc3255b68bef3ba8@dondevamos.com>
	 <20100718.153910.67919508.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pedro.netdev@dondevamos.com, netdev@vger.kernel.org,
	kaber@trash.net, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40661 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932376Ab0GSNYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 09:24:21 -0400
Received: by wwb39 with SMTP id 39so182138wwb.1
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 06:24:19 -0700 (PDT)
In-Reply-To: <20100718.153910.67919508.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 18 juillet 2010 =C3=A0 15:39 -0700, David Miller a =C3=A9cr=
it :
> From: Pedro Garcia <pedro.netdev@dondevamos.com>
> Date: Sun, 18 Jul 2010 18:43:25 +0200
>=20
> > - Without the 8021q module loaded in the kernel, all 802.1p packets=
=20
> > (VLAN 0 but QoS tagging) are silently discarded (as expected, as=20
> > the protocol is not loaded).
> > =20
> > - Without this patch in 8021q module, these packets are forwarded t=
o=20
> > the module, but they are discarded also if VLAN 0 is not configured=
,
> > which should not be the default behaviour, as VLAN 0 is not really
> > a VLANed packet but a 802.1p packet. Defining VLAN 0 makes it almos=
t
> > impossible to communicate with mixed 802.1p and non 802.1p devices =
on
> > the same network due to arp table issues.
> >=20
> > - Changed logic to skip vlan specific code in vlan_skb_recv if VLAN=
=20
> > is 0 and we have not defined a VLAN with ID 0, but we accept the=20
> > packet with the encapsulated proto and pass it later to netif_rx.
> >=20
> > - In the vlan device event handler, added some logic to add VLAN 0=20
> > to HW filter in devices that support it (this prevented any traffic
> > in VLAN 0 to reach the stack in e1000e with HW filter under 2.6.35,
> > and probably also with other HW filtered cards, so we fix it here).
> >=20
> > - In the vlan unregister logic, prevent the elimination of VLAN 0=20
> > in devices with HW filter.
> >=20
> > - The default behaviour is to ignore the VLAN 0 tagging and accept
> > the packet as if it was not tagged, but we can still define a=20
> > VLAN 0 if desired (so it is backwards compatible).
> >=20
> > Signed-off-by: Pedro Garcia <pedro.netdev@dondevamos.com>
>=20
> Applied, thanks Pedro.

Hmm, current net-next-2.6 is not working with bonding and bnx2.

I got some fatal oops.

modprobe bond0
ifconfig bond0 down
echo 100 >/sys/class/net/bond0/bonding/miimon
echo 1 >/sys/class/net/bond0/bonding/mode
ifconfig bond0 up
ifenslave bond0 eth1 eth2
ip link set eth1 up
ip link set eth2 up

After some debugging to avoid crashes, I get :


[   31.784308] bonding: bond0: Setting MII monitoring interval to 100.
[   31.784391] bonding: bond0: setting mode to active-backup (1).
[   31.784900] 8021q: adding VLAN 0 to HW filter on device bond0
[   31.784903] ADDRCONF(NETDEV_UP): bond0: link is not ready
[   31.904440] ------------[ cut here ]------------
[   31.904500] WARNING: at drivers/net/bonding/bond_ipv6.c:185 bond_ine=
t6addr_event+0x179/0x240 [bonding]()
[   31.904576] Hardware name: ProLiant BL460c G1
[   31.904629] Modules linked in: ipmi_si ipmi_msghandler hpilo bonding=
 ipv6
[   31.904873] Pid: 4586, comm: ifenslave Tainted: G        W   2.6.35-=
rc1-01453-g3e12451-dirty #836
[   31.904948] Call Trace:
[   31.905002]  [<c13421c4>] ? printk+0x18/0x1c
[   31.905057]  [<c103c8fd>] warn_slowpath_common+0x6d/0xa0
[   31.905114]  [<f8cf5fd9>] ? bond_inet6addr_event+0x179/0x240 [bondin=
g]
[   31.905172]  [<f8cf5fd9>] ? bond_inet6addr_event+0x179/0x240 [bondin=
g]
[   31.905236]  [<c103c94d>] warn_slowpath_null+0x1d/0x20
[   31.905296]  [<f8cf5fd9>] bond_inet6addr_event+0x179/0x240 [bonding]
[   31.905354]  [<c105b061>] notifier_call_chain+0x41/0x60
[   31.905409]  [<c105b0cd>] atomic_notifier_call_chain+0x1d/0x20
[   31.905471]  [<f8b88b31>] addrconf_ifdown+0x211/0x320 [ipv6]
[   31.905529]  [<f8b897ae>] addrconf_notify+0x6e/0x870 [ipv6]
[   31.905586]  [<c1344912>] ? _raw_write_unlock_bh+0x12/0x20
[   31.905642]  [<c1344912>] ? _raw_write_unlock_bh+0x12/0x20
[   31.905701]  [<f8b8f1f0>] ? fib6_clean_all+0x70/0x80 [ipv6]
[   31.905770]  [<f8b8dda0>] ? fib6_age+0x0/0x90 [ipv6]
[   31.905830]  [<c104a106>] ? lock_timer_base+0x26/0x50
[   31.905884]  [<c104a279>] ? del_timer+0x69/0xb0
[   31.905938]  [<c134493d>] ? _raw_spin_unlock_bh+0xd/0x10
[   31.905997]  [<f8b8f267>] ? fib6_run_gc+0x67/0xe0 [ipv6]
[   31.906052]  [<c105b061>] notifier_call_chain+0x41/0x60
[   31.906107]  [<c105b19a>] raw_notifier_call_chain+0x1a/0x20
[   31.906165]  [<c129fe37>] call_netdevice_notifiers+0x27/0x60
[   31.906221]  [<c12ac0cd>] ? rtmsg_ifinfo+0xbd/0xf0
[   31.906276]  [<c12a183c>] __dev_notify_flags+0x5c/0x80
[   31.906333]  [<c12a1897>] dev_change_flags+0x37/0x60
[   31.906390]  [<c12f6291>] devinet_ioctl+0x591/0x6f0
[   31.906445]  [<c11726be>] ? copy_to_user+0x2e/0x40
[   31.906500]  [<c12f7212>] inet_ioctl+0xa2/0xd0
[   31.906555]  [<c128f65e>] sock_ioctl+0x4e/0x240
[   31.906610]  [<c10d3a44>] vfs_ioctl+0x34/0xa0
[   31.906664]  [<c10c7cab>] ? alloc_file+0x1b/0xa0
[   31.906718]  [<c128f610>] ? sock_ioctl+0x0/0x240
[   31.906771]  [<c10d4186>] do_vfs_ioctl+0x66/0x550
[   31.906827]  [<c1022ca0>] ? do_page_fault+0x0/0x350
[   31.906881]  [<c1022e41>] ? do_page_fault+0x1a1/0x350
[   31.906936]  [<c129098c>] ? sys_socket+0x5c/0x70
[   31.906990]  [<c1291860>] ? sys_socketcall+0x60/0x270
[   31.907045]  [<c10d46a9>] sys_ioctl+0x39/0x60
[   31.907099]  [<c1002bd0>] sysenter_do_call+0x12/0x26
[   31.907153] ---[ end trace 5c4638450a77a22f ]---
[   32.046479] BUG: scheduling while atomic: ifenslave/4586/0x00000100
[   32.046540] Modules linked in: ipmi_si ipmi_msghandler hpilo bonding=
 ipv6
[   32.046784] Pid: 4586, comm: ifenslave Tainted: G        W   2.6.35-=
rc1-01453-g3e12451-dirty #836
[   32.046860] Call Trace:
[   32.046910]  [<c13421c4>] ? printk+0x18/0x1c
[   32.046965]  [<c10315c9>] __schedule_bug+0x59/0x60
[   32.047019]  [<c1342a2c>] schedule+0x57c/0x850
[   32.047074]  [<c104a106>] ? lock_timer_base+0x26/0x50
[   32.047128]  [<c1342f78>] schedule_timeout+0x118/0x250
[   32.047183]  [<c104a2c0>] ? process_timeout+0x0/0x10
[   32.047238]  [<c13430c5>] schedule_timeout_uninterruptible+0x15/0x20
[   32.047295]  [<c104a345>] msleep+0x15/0x20
[   32.047350]  [<c1227082>] bnx2_napi_disable+0x52/0x80
[   32.047405]  [<c122b56f>] bnx2_netif_stop+0x3f/0xa0
[   32.047460]  [<c122b62a>] bnx2_vlan_rx_register+0x5a/0x80
[   32.047516]  [<f8ced776>] bond_enslave+0x526/0xa90 [bonding]
[   32.047576]  [<f8b8f0d0>] ? fib6_clean_node+0x0/0xb0 [ipv6]
[   32.047634]  [<f8b8dda0>] ? fib6_age+0x0/0x90 [ipv6]
[   32.047689]  [<c129d2d3>] ? netdev_set_master+0x3/0xc0
[   32.047746]  [<f8cee4cb>] bond_do_ioctl+0x31b/0x430 [bonding]
[   32.047804]  [<c105b19a>] ? raw_notifier_call_chain+0x1a/0x20
[   32.047861]  [<c12abd5d>] ? __rtnl_unlock+0xd/0x10
[   32.047915]  [<c129f8cd>] ? __dev_get_by_name+0x7d/0xa0
[   32.047970]  [<c12a19b0>] dev_ifsioc+0xf0/0x290
[   32.048025]  [<f8cee1b0>] ? bond_do_ioctl+0x0/0x430 [bonding]
[   32.048081]  [<c12a1ce1>] dev_ioctl+0x191/0x610
[   32.048136]  [<c12eeb20>] ? udp_ioctl+0x0/0x70
[   32.048189]  [<c128f67c>] sock_ioctl+0x6c/0x240
[   32.048243]  [<c10d3a44>] vfs_ioctl+0x34/0xa0
[   32.048297]  [<c10c7cab>] ? alloc_file+0x1b/0xa0
[   32.048351]  [<c128f610>] ? sock_ioctl+0x0/0x240
[   32.048404]  [<c10d4186>] do_vfs_ioctl+0x66/0x550
[   32.048459]  [<c1022ca0>] ? do_page_fault+0x0/0x350
[   32.048513]  [<c1022e41>] ? do_page_fault+0x1a1/0x350
[   32.048568]  [<c129098c>] ? sys_socket+0x5c/0x70
[   32.048622]  [<c1291860>] ? sys_socketcall+0x60/0x270
[   32.048677]  [<c10d46a9>] sys_ioctl+0x39/0x60
[   32.048730]  [<c1002bd0>] sysenter_do_call+0x12/0x26
[   32.052025] bonding: bond0: enslaving eth1 as a backup interface wit=
h a down link.
[   32.100207] tg3 0000:14:04.0: PME# enabled
[   32.100222]  pci0000:00: wake-up capability enabled by ACPI
[   32.224488]  pci0000:00: wake-up capability disabled by ACPI
[   32.224492] tg3 0000:14:04.0: PME# disabled
[   32.348516] tg3 0000:14:04.0: BAR 0: set to [mem 0xfdff0000-0xfdffff=
ff 64bit] (PCI address [0xfdff0000-0xfdffffff]
[   32.348524] tg3 0000:14:04.0: BAR 2: set to [mem 0xfdfe0000-0xfdfeff=
ff 64bit] (PCI address [0xfdfe0000-0xfdfeffff]
[   32.363711] bonding: bond0: enslaving eth2 as a backup interface wit=
h a down link.



=46or bnx2, it seems commit 212f9934afccf9c9739921
was not sufficient to correct the "scheduling while atomic" bug...
enslaving a bnx2 on a bond device with one vlan already set :
 bond_enslave -> bnx2_vlan_rx_register -> bnx2_netif_stop -> bnx2_napi_=
disable -> msleep()

=46or the first oops, following patch cures it, but I am not pleased
with it. This zero-vid registration seems wrong at the beginning.

Thanks

[RFC net-next-2.6] bonding: fix bond_inet6addr_event()=20

After commit ad1afb0039391 (vlan_dev: VLAN 0 should be treated
as "no vlan tag" (802.1p packet)),
bond_inet6addr_event() might be called with a NULL bond->vlgrp pointer,=
 and
a non empty bond->vlan_list. vlan_group_get_device() is dereferencing a=
 NULL pointer.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/drivers/net/bonding/bond_ipv6.c b/drivers/net/bonding/bond=
_ipv6.c
index 969ffed..121b073 100644
--- a/drivers/net/bonding/bond_ipv6.c
+++ b/drivers/net/bonding/bond_ipv6.c
@@ -178,6 +178,8 @@ static int bond_inet6addr_event(struct notifier_blo=
ck *this,
 		}
=20
 		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
+			if (!bond->vlgrp)
+				continue;
 			vlan_dev =3D vlan_group_get_device(bond->vlgrp,
 							 vlan->vlan_id);
 			if (vlan_dev =3D=3D event_dev) {



