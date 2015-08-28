From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bonding: fix bond dev flags after convert to arphrd_ether
Date: Thu, 27 Aug 2015 19:07:41 -0700
Message-ID: <92603003-58ED-46B1-B789-5D4765256FAC@cumulusnetworks.com>
References: <1436990983-1406-1-git-send-email-razor@blackwall.org> <1817.1436992353@famine>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Andy Gospodarek <gospo@cumulusnetworks.com>, vfalico@gmail.com,
	David Miller <davem@davemloft.net>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33700 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbbH1CHo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 22:07:44 -0400
Received: by padfo6 with SMTP id fo6so6073177pad.0
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 19:07:44 -0700 (PDT)
In-Reply-To: <1817.1436992353@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jul 15, 2015, at 1:32 PM, Jay Vosburgh <jay.vosburgh@canonical.com=
> wrote:
>=20
> Nikolay Aleksandrov <razor@blackwall.org> wrote:
>=20
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>=20
>> If a bonding device enslaves devices !=3D arphrd_ether it'll change =
types
>> and if later these devices are released, it can enslave an arphrd_et=
her
>> device and switch back calling ether_setup() which resets dev->flags=
 to
>> IFF_BROADCAST|IFF_MULTICAST and clears IFF_MASTER which then could l=
ead
>> to many different bugs. This bug seems to have been there since the
>> introduction of ether_setup() in bond_enslave().
>=20
> 	I thought the hack-around for the non-ethernet device problem
> was that, for non-ARPHRD_ETHER devices, the bonding master device is
> automatically destroyed when the last slave is released.
>=20
> 	This (well, this sort of thing) originally came up with IPoIB
> devices needing different ops that would disappear if the ipoib modul=
e
> was unloaded, so the bond master was deliberately unregistered when t=
he
> last slave was released.
>=20
> 	Looking at the code, at first glance this appears to still be
> the case: bond_slave_netdev_event calls bond_release_and_destroy for =
!=3D
> ARPHRD_ETHER, which in turn should unregister the bond itself if ther=
e
> are no slaves left.  Is this no longer working as intended?
>=20
> 	-J
>=20
Restarting this thread because there=E2=80=99s actually a bug here, wha=
t you described with
the bonding destruction is true when the slaves are all destroyed but i=
t isn=E2=80=99t true if they=E2=80=99re
just released, if you take a look at bond_slave_netdev_event() the bond=
 destruction happens
only on NETDEV_UNREGISTER and I just hit this bug by enslaving a non-AR=
PHRD_ETHER
device, releasing it and enslaving a ARPHRD_ETHER device so ether_setup=
() path in bond_enslave
is hit and IFF_MASTER gets dropped:
17: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqu=
eue state UP mode DEFAULT group default qlen 1000
    link/fddi 9a:33:c5:30:ff:a6 brd ff:ff:ff:ff:ff:ff
(release non-ARPHRD_ETHER slave)
(enslave ARPHRD_ETHER device)
17: bond0: <BROADCAST,MULTICAST,LOWER_UP> mtu 1500 qdisc noqueue state =
UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:3c:13:57 brd ff:ff:ff:ff:ff:ff

Notice the master flag is gone and of course on unload we get:
[57981.545547] ------------[ cut here ]------------
[57981.545567] WARNING: CPU: 0 PID: 13792 at fs/proc/generic.c:575 remo=
ve_proc_entry+0x17e/0x190()
[57981.545572] remove_proc_entry: removing non-empty directory 'net/bon=
ding', leaking at least 'bond0'
[57981.545576] Modules linked in: bonding(-) bridge(OE) stp llc rpcsec_=
gss_krb5 nfsv4 dns_resolver nfs fscache macvlan netconsole ppdev joydev=
 serio_raw parport_pc parport i2c_piix4 video acpi_cpufreq nfsd auth_rp=
cgss nfs_acl lockd grace sunrpc virtio_net pcnet32 mii virtio_pci virti=
o_ring virtio e1000 ata_generic pata_acpi [last unloaded: bonding]
[57981.545614] CPU: 0 PID: 13792 Comm: rmmod Tainted: G           OE   =
4.2.0-rc7+ #56
[57981.545618] Hardware name: innotek GmbH VirtualBox/VirtualBox, BIOS =
VirtualBox 12/01/2006
[57981.545623]  0000000000000000 00000000b15c0564 ffff88001ec43ca8 ffff=
ffff8183f105
[57981.545629]  0000000000000000 ffff88001ec43d00 ffff88001ec43ce8 ffff=
ffff810a9496
[57981.545635]  0000000000000000 ffff88002ef6a800 ffff88002ef6a838 ffff=
88002e24ed00
[57981.545641] Call Trace:
[57981.545649]  [<ffffffff8183f105>] dump_stack+0x4c/0x65
[57981.545656]  [<ffffffff810a9496>] warn_slowpath_common+0x86/0xc0
[57981.545662]  [<ffffffff810a9525>] warn_slowpath_fmt+0x55/0x70
[57981.545669]  [<ffffffff812dbcde>] remove_proc_entry+0x17e/0x190
[57981.545675]  [<ffffffff812e79d5>] ? kernfs_remove_by_name_ns+0x55/0x=
a0
[57981.545687]  [<ffffffffa032522e>] bond_destroy_proc_dir+0x2e/0x3e [b=
onding]
[57981.545694]  [<ffffffffa03126fe>] bond_net_exit+0x13e/0x200 [bonding=
]
[57981.545700]  [<ffffffffa03125c5>] ? bond_net_exit+0x5/0x200 [bonding=
]
[57981.545707]  [<ffffffff816bd7c8>] ops_exit_list.isra.4+0x38/0x60
[57981.545713]  [<ffffffff816bdd08>] unregister_pernet_operations+0x78/=
0xd0
[57981.545718]  [<ffffffff816bdd87>] unregister_pernet_subsys+0x27/0x40
[57981.545726]  [<ffffffffa032546b>] bonding_exit+0x26/0xbbb [bonding]
[57981.545732]  [<ffffffff8114a9f7>] SyS_delete_module+0x1b7/0x210
[57981.545739]  [<ffffffff81003017>] ? trace_hardirqs_on_thunk+0x17/0x1=
9
[57981.545745]  [<ffffffff8184936e>] entry_SYSCALL_64_fastpath+0x12/0x7=
6
[57981.545749] ---[ end trace 46a4798bb28254d0 ]=E2=80=94

We need to convert it back to ARPHRD_ETHER if releasing the last slave,=
 because
we can=E2=80=99t destroy it (in some paths bond->dev is used after bond=
_release()).
Basically we should make the case that if the bonding doesn=E2=80=99t h=
ave any slaves then it=E2=80=99s
always an ARPHRD_ETHER device.

Thoughts ?

>=20
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> Fixes: e36b9d16c6a6 ("bonding: clean muticast addresses when device =
changes type")
>> ---
>> drivers/net/bonding/bond_main.c | 1 +
>> 1 file changed, 1 insertion(+)
>>=20
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>> index 317a49480475..8ba119896e55 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1368,6 +1368,7 @@ int bond_enslave(struct net_device *bond_dev, =
struct net_device *slave_dev)
>> 				bond_setup_by_slave(bond_dev, slave_dev);
>> 			else {
>> 				ether_setup(bond_dev);
>> +				bond_dev->flags |=3D IFF_MASTER;
>> 				bond_dev->priv_flags &=3D ~IFF_TX_SKB_SHARING;
>> 			}
>>=20
>> --=20
>> 1.9.3
>>=20
>=20
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
