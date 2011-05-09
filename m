From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: use batched device unregister in
 veth and macvlan
Date: Mon, 09 May 2011 21:05:35 +0200
Message-ID: <1304967935.3050.9.camel@edumazet-laptop>
References: <BANLkTim2e1Gm_jqfY89is-FfRYTu2=G02w@mail.gmail.com>
	 <1304929236.3342.8.camel@edumazet-laptop>
	 <1304932677.3342.17.camel@edumazet-laptop>
	 <20110509.114200.226765786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirqus@gmail.com, alex@alex.org.uk, netdev@vger.kernel.org,
	jesse@nicira.com, paulmck@linux.vnet.ibm.com,
	greearb@candelatech.com, Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49413 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933Ab1EITFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 15:05:41 -0400
Received: by wwa36 with SMTP id 36so6084627wwa.1
        for <netdev@vger.kernel.org>; Mon, 09 May 2011 12:05:39 -0700 (PDT)
In-Reply-To: <20110509.114200.226765786.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 09 mai 2011 =C3=A0 11:42 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 09 May 2011 11:17:57 +0200
>=20
> > veth devices dont use the batched device unregisters yet.
> >=20
> > Since veth are a pair of devices, it makes sense to use a batch of =
two
> > unregisters, this roughly divides dismantle time by two.
> >=20
> > Fix this by changing dellink() callers to always provide a non NULL
> > head. (Idea from Micha=C5=82 Miros=C5=82aw)
> >=20
> > This patch also handles macvlan case : We now dismantle all macvlan=
s on
> > top of a lower dev at once.
> >=20
> > Reported-by: Alex Bligh <alex@alex.org.uk>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Applied.

Thanks !

I believe there is one problem with this patch and
unregister_vlan_dev(), I'll have to find a solution fast ;)


ip link add link eth2 eth2.103 type vlan id 103 gvrp on
ip link add link eth2 eth2.104 type vlan id 104 gvrp on
ip link set eth2.103 up
ip link set eth2.104 up
ip link del eth2.103
ip link del eth2.104   <<<BUG>>>


[  372.573591] BUG: unable to handle kernel NULL pointer dereference at=
           (null)
[  372.573738] IP: [<ffffffffa014ecde>] garp_request_leave+0x2e/0x88 [g=
arp]
[  372.573835] PGD 7a7d0067 PUD 7c9b1067 PMD 0=20
[  372.573995] Oops: 0000 [#1] SMP=20
[  372.574119] last sysfs file: /sys/devices/virtual/net/eth2.104/ifind=
ex
[  372.574180] CPU 3=20
[  372.574221] Modules linked in: 8021q garp stp llc nfsd lockd sunrpc =
tg3 libphy sg [last unloaded: x_tables]
[  372.574765]=20
[  372.574817] Pid: 5656, comm: ip Tainted: G        W   2.6.39-rc2-019=
16-g0e21eae-dirty #696 HP ProLiant BL460c G6
[  372.574967] RIP: 0010:[<ffffffffa014ecde>]  [<ffffffffa014ecde>] gar=
p_request_leave+0x2e/0x88 [garp]
[  372.575083] RSP: 0018:ffff8801168697c8  EFLAGS: 00010282
[  372.577084] RAX: 0000000000000000 RBX: ffff880116869816 RCX: 0000000=
000000002
[  372.577146] RDX: 0000000000000000 RSI: ffffffffa01594c0 RDI: ffff880=
117bc0000
[  372.577208] RBP: ffff8801168697f8 R08: 0000000000000001 R09: ffff880=
07a190800
[  372.577269] R10: ffff88007a17da00 R11: 0000000000000000 R12: ffff880=
117bc0000
[  372.577331] R13: ffff8801168699d8 R14: 0000000000000001 R15: 0000000=
000000002
[  372.577393] FS:  0000000000000000(0000) GS:ffff88007fc40000(0063) kn=
lGS:00000000f779f6c0
[  372.577494] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  372.577553] CR2: 0000000000000000 CR3: 000000007af08000 CR4: 0000000=
0000006e0
[  372.577615] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000=
000000000
[  372.577677] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000=
000000400
[  372.577739] Process ip (pid: 5656, threadinfo ffff880116868000, task=
 ffff88011a388000)
[  372.577816] Stack:
[  372.577868]  ffff8801168697e8 ffff88007a74c800 ffff880117bc0000 ffff=
8801168699d8
[  372.578083]  ffff880116869868 0000000000000000 ffff880116869818 ffff=
ffffa0158226
[  372.578297]  0000000316869818 6800880116869938 ffff880116869838 ffff=
ffffa0157467
[  372.578511] Call Trace:
[  372.578579]  [<ffffffffa0158226>] vlan_gvrp_request_leave+0x46/0x50 =
[8021q]
[  372.578642]  [<ffffffffa0157467>] vlan_dev_stop+0xb7/0xc0 [8021q]
[  372.578703]  [<ffffffff81398b87>] __dev_close_many+0x87/0xe0
[  372.578763]  [<ffffffff81398c67>] dev_close_many+0x87/0x110
[  372.578823]  [<ffffffff81398d90>] rollback_registered_many+0xa0/0x24=
0
[  372.578884]  [<ffffffff81398f49>] unregister_netdevice_many+0x19/0x6=
0
[  372.578946]  [<ffffffff813a7e62>] rtnl_dellink+0xc2/0xf0
[  372.579005]  [<ffffffff813a5ae7>] rtnetlink_rcv_msg+0x247/0x250
[  372.579066]  [<ffffffff813a58a0>] ? rtnetlink_net_init+0x40/0x40
[  372.579126]  [<ffffffff813cb529>] netlink_rcv_skb+0x99/0xc0
[  372.579185]  [<ffffffff813a7690>] rtnetlink_rcv+0x20/0x30
[  372.579244]  [<ffffffff813cb296>] netlink_unicast+0x296/0x2a0
[  372.579304]  [<ffffffff8139052f>] ? memcpy_fromiovec+0x5f/0x80
[  372.579364]  [<ffffffff813cc1c7>] netlink_sendmsg+0x227/0x370


unregister_vlan_dev() does :

vlan_group_set_device(grp, vlan_id, NULL);=20

unregister_netdevice_queue(dev, head);
/* If the group is now empty, kill off the group. */
if (grp->nr_vlans =3D=3D 0) {
	vlan_gvrp_uninit_applicant(real_dev);


Now 'head' is not anymore NULL, we no longer immediately release the
dev in unregister_netdevice_queue() but queue it.

So vlan_gvrp_uninit_applicant() is now freeing garp structure, _before_
vlan_gvrp_request_leave() is called from vlan_dev_stop()

So we dereference NULL pointer in garp_request_leave

I suspect we should move the 'group freeing' out from unregister_vlan_d=
ev() to=20
vlan_dev_stop() ?

Patrick, David any idea before I cook a patch ?

BTW, bug must be present in net-2.6, if we unload vlan module (since in=
 this
case we also had a non NULL head )

Thanks


