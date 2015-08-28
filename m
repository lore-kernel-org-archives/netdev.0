From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bonding: fix bond_poll_controller bh_enable warning
Date: Fri, 28 Aug 2015 08:33:35 -0700
Message-ID: <658DEBCA-6BE2-4388-AFE8-58C6A71029AC@cumulusnetworks.com>
References: <20150801171540.2f6d8aa6@urahara> <1440726872-6624-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, 13806511171@163.com,
	shemminger@linux-foundation.org, maheshb@google.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	davem@davemloft.net
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34996 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbbH1Pdg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 11:33:36 -0400
Received: by pacdd16 with SMTP id dd16so66102599pac.2
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 08:33:36 -0700 (PDT)
In-Reply-To: <1440726872-6624-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Aug 27, 2015, at 6:54 PM, Nikolay Aleksandrov <razor@blackwall.org=
> wrote:
>=20
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>=20
> The problem is rcu_read_unlock_bh() which triggers a warning.
> ndo_poll_controller is supposed to be running with either irqs disabl=
ed
> or bh disabled already, so we don't need to take rcu_read_lock_bh.
> Use the standard rcu_read_lock/unlock to make the non-bh rcu_derefere=
nce
> happy.
>=20

Actually I was wrong here, e.g. netpoll_send_udp(). It is currently onl=
y used by netconsole
with irqs disabled but that doesn=E2=80=99t have to be true for future =
users.
I wanted to avoid conditional lock acquiring but we may have to go that=
 way.
I=E2=80=99ll post a v2 in a few hours.

Please drop this patch.

Thanks,
 Nik

> This patch fixes https://bugzilla.kernel.org/show_bug.cgi?id=3D102181
>=20
> [   98.502922] bond0: making interface eth1 the new active one
> [   98.503039] ------------[ cut here ]------------
> [   98.503039] WARNING: CPU: 0 PID: 1744 at kernel/softirq.c:150 __lo=
cal_bh_enable_ip+0x96/0xc0()
> [   98.503039] Modules linked in: bonding(OE) rpcsec_gss_krb5 nfsv4 d=
ns_resolver nfs fscache netconsole ppdev joydev parport_pc serio_raw pa=
rport i2c_piix4 video acpi_cpufreq nfsd auth_rpcgss nfs_acl lockd grace=
 sunrpc virtio_net e1000 ata_generic pcnet32 mii virtio_pci virtio_ring=
 virtio pata_acpi
> [   98.503039] CPU: 0 PID: 1744 Comm: ifenslave Tainted: G           =
OE   4.2.0-rc7+ #56
> [   98.503039] Hardware name: innotek GmbH VirtualBox/VirtualBox, BIO=
S VirtualBox 12/01/2006
> [   98.503039]  0000000000000000 00000000e96ba230 ffff880020c236b8 ff=
ffffff8183f105
> [   98.503039]  0000000000000000 0000000000000000 ffff880020c236f8 ff=
ffffff810a9496
> [   98.503039]  ffff88002ea99e08 0000000000000200 ffffffffa02a8e06 ff=
ff88002ea99e08
> [   98.503039] Call Trace:
> [   98.503039]  [<ffffffff8183f105>] dump_stack+0x4c/0x65
> [   98.503039]  [<ffffffff810a9496>] warn_slowpath_common+0x86/0xc0
> [   98.503039]  [<ffffffffa02a8e06>] ? bond_poll_controller+0x146/0x2=
50 [bonding]
> [   98.503039]  [<ffffffff810a95ca>] warn_slowpath_null+0x1a/0x20
> [   98.503039]  [<ffffffff810ae376>] __local_bh_enable_ip+0x96/0xc0
> [   98.503039]  [<ffffffffa02a8e2f>] bond_poll_controller+0x16f/0x250=
 [bonding]
> [   98.503039]  [<ffffffffa02a8cf3>] ? bond_poll_controller+0x33/0x25=
0 [bonding]
> [   98.503039]  [<ffffffff810feaed>] ? trace_hardirqs_off+0xd/0x10
> [   98.503039]  [<ffffffff81848afb>] ? _raw_spin_unlock_irqrestore+0x=
5b/0x60
> [   98.503039]  [<ffffffff816ec48e>] netpoll_poll_dev+0x6e/0x350
> [   98.503039]  [<ffffffff816eb977>] ? netpoll_start_xmit+0x137/0x1d0
> [   98.503039]  [<ffffffff816b2e8b>] ? __alloc_skb+0x5b/0x210
> [   98.503039]  [<ffffffff816ec89d>] netpoll_send_skb_on_dev+0x12d/0x=
2a0
> [   98.503039]  [<ffffffff816eccde>] netpoll_send_udp+0x2ce/0x430
> [   98.503039]  [<ffffffffa0190850>] write_msg+0xb0/0xf0 [netconsole]
> [   98.503039]  [<ffffffff81116b63>] call_console_drivers.constprop.2=
5+0x133/0x260
> [   98.503039]  [<ffffffff81117934>] console_unlock+0x2f4/0x580
> [   98.503039]  [<ffffffff81117ea5>] ? vprintk_emit+0x2e5/0x630
> [   98.503039]  [<ffffffff81117ee5>] vprintk_emit+0x325/0x630
> [   98.503039]  [<ffffffff81118379>] vprintk_default+0x29/0x40
> [   98.503039]  [<ffffffff8183de4f>] printk+0x55/0x6b
> [   98.503039]  [<ffffffff816c754c>] __netdev_printk+0x16c/0x260
> [   98.503039]  [<ffffffff816c7a12>] netdev_info+0x62/0x80
> [   98.503039]  [<ffffffffa02ab464>] bond_change_active_slave+0x134/0=
x6a0 [bonding]
> [   98.503039]  [<ffffffffa02aba95>] bond_select_active_slave+0xc5/0x=
310 [bonding]
> [   98.503039]  [<ffffffffa02aeb78>] bond_enslave+0x1088/0x10c0 [bond=
ing]
> [   98.503039]  [<ffffffffa02af46b>] bond_do_ioctl+0x37b/0x400 [bondi=
ng]
> [   98.503039]  [<ffffffff81101d8d>] ? trace_hardirqs_on+0xd/0x10
> [   98.503039]  [<ffffffff816dc437>] ? rtnl_lock+0x17/0x20
> [   98.503039]  [<ffffffff816e5fd1>] dev_ifsioc+0x331/0x3e0
> [   98.503039]  [<ffffffff816e62dc>] dev_ioctl+0xec/0x6c0
> [   98.503039]  [<ffffffff816a6c6a>] sock_do_ioctl+0x4a/0x60
> [   98.503039]  [<ffffffff816a7300>] sock_ioctl+0x1c0/0x250
> [   98.503039]  [<ffffffff81271bfe>] do_vfs_ioctl+0x2ee/0x540
> [   98.503039]  [<ffffffff810fd943>] ? up_read+0x23/0x40
> [   98.503039]  [<ffffffff81070993>] ? __do_page_fault+0x1d3/0x420
> [   98.503039]  [<ffffffff8127e246>] ? __fget_light+0x66/0x90
> [   98.503039]  [<ffffffff81271ec9>] SyS_ioctl+0x79/0x90
> [   98.503039]  [<ffffffff8184936e>] entry_SYSCALL_64_fastpath+0x12/0=
x76
> [   98.503039] ---[ end trace 00cfa804b0670051 ]---
>=20
> Fixes: 616f45416ca0 ("bonding: implement bond_poll_controller()")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> drivers/net/bonding/bond_main.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index a98dd4f1b0e3..1b4b24218807 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -979,7 +979,7 @@ static void bond_poll_controller(struct net_devic=
e *bond_dev)
> 		if (bond_3ad_get_active_agg_info(bond, &ad_info))
> 			return;
>=20
> -	rcu_read_lock_bh();
> +	rcu_read_lock();
> 	bond_for_each_slave_rcu(bond, slave, iter) {
> 		ops =3D slave->dev->netdev_ops;
> 		if (!bond_slave_is_up(slave) || !ops->ndo_poll_controller)
> @@ -1000,7 +1000,7 @@ static void bond_poll_controller(struct net_dev=
ice *bond_dev)
> 		ops->ndo_poll_controller(slave->dev);
> 		up(&ni->dev_lock);
> 	}
> -	rcu_read_unlock_bh();
> +	rcu_read_unlock();
> }
>=20
> static void bond_netpoll_cleanup(struct net_device *bond_dev)
> --=20
> 2.4.3
>=20
