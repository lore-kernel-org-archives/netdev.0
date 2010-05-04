From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question about vlans, bonding, etc.
Date: Tue, 04 May 2010 06:48:26 +0200
Message-ID: <1272948506.2407.174.camel@edumazet-laptop>
References: <i2tb65cae941005031706o19a6f1e9zc86b33d73462113f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: "George B." <georgeb@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f217.google.com ([209.85.218.217]:62218 "EHLO
	mail-bw0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903Ab0EDEsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 00:48:31 -0400
Received: by bwz9 with SMTP id 9so1856681bwz.29
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 21:48:29 -0700 (PDT)
In-Reply-To: <i2tb65cae941005031706o19a6f1e9zc86b33d73462113f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 03 mai 2010 =C3=A0 17:06 -0700, George B. a =C3=A9crit :
> Watching the "Receive issues with bonding and vlans" thread brought a
> question to mind.  In what order should things be done for best
> performance?
>=20
> For example, say I have a pair of ethernet interfaces.  Do I slave th=
e
> ethernet interfaces to the bond device and then make the vlans on the
> bond devices?
> Or do I make the vlans on the ethernet devices and then bond the vlan
> interfaces?
>=20
> In the first case I would have:
>=20
>=20
>=20
> bond0.3--|     |------eth0
>              bond0
> bond0.5--|     |------eth1
>=20
> The second case would be:
>=20
>       |------------------eth0.5-----|
>       |          |-------eth0.3---eth0
> bond0  bond1
>       |          |-------eth1.3---eth1
>       |------------------eth1.5-----|
>=20
> I am using he first method currently as it seemed more intuitive to m=
e
> at the time to bond the ethernets and then put the vlans on the bonds
> but it seems life might be easier for the vlan driver if it is bound
> directly to the hardware.  I am using Intel NICs (igb driver) with 4
> queues per NIC.
>=20
> Would there be a performance difference expected between the two
> configurations?  Can the vlan driver "see through" the bond interface
> to the
> hardware and take advantage of multiple queues if the hardware
> supports it in the first configuration?

Unfortunatly, first combination is not multiqueue aware yet.

You'll need to patch bonding driver like this if your nics have 4
queues :

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 85e813c..98cc3c0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4915,8 +4915,8 @@ int bond_create(struct net *net, const char *name=
)
=20
        rtnl_lock();
=20
-       bond_dev =3D alloc_netdev(sizeof(struct bonding), name ? name :=
 "",
-                               bond_setup);
+       bond_dev =3D alloc_netdev_mq(sizeof(struct bonding), name ? nam=
e : "",
+                               bond_setup, 4);
        if (!bond_dev) {
                pr_err("%s: eek! can't alloc netdev!\n", name);
                rtnl_unlock();


