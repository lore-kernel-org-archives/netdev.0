From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPv4 multicast and mac-vlans acting weird on 3.0.4+
Date: Wed, 05 Oct 2011 23:36:43 +0200
Message-ID: <1317850603.3457.21.camel@edumazet-laptop>
References: <4E8C89EE.3090600@candelatech.com>
	 <1317844449.3457.3.camel@edumazet-laptop>
	 <4E8CB990.1010406@candelatech.com>
	 <1317845835.3457.5.camel@edumazet-laptop>
	 <4E8CBBD6.3080500@candelatech.com>
	 <1317846693.3457.11.camel@edumazet-laptop>
	 <4E8CC474.7050803@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57430 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754579Ab1JEVgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 17:36:51 -0400
Received: by wwf22 with SMTP id 22so3212551wwf.1
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2011 14:36:50 -0700 (PDT)
In-Reply-To: <4E8CC474.7050803@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 05 octobre 2011 =C3=A0 13:56 -0700, Ben Greear a =C3=A9crit=
 :

> Wouldn't you have the same problem with two real Ethernet interfaces =
on
> the same LAN, or two 802.1Q devices for that matter?  The addrs will =
all
> be the same in that case too?
>=20

Usually multicast is coupled with routing.

A JOIN message from your app wont be sent on all interfaces...

But yes, we might have a similar issue with regular vlans.

Probably nobody noticed yet. Just say no to fragments :)

> Also, if I have just a single mac-vlan active (the other 3 are 'ifcon=
fig foo down'),
> I still see the problem with mcast.
>=20

Thats another bug : macvlan doesnt test IFF_UP on broadcasts, only for
unicast messages. Please test following patch.

>  From what you describe, I am thinking I may be hitting a different
> issue.  Any ideas on how to figure out why exactly the NF_HOOK isn't
> calling the ip_rcv_finish method?
>=20

Really I believe I tried to explain the thing already...

ip_local_deliver() -> ip_defrag() :


[PATCH] macvlan: dont send frames on DOWN devices

Reported-by: Ben Greear <greearb@candelatech.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index b100c90..94a0282 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -145,7 +145,8 @@ static void macvlan_broadcast(struct sk_buff *skb,
 		hlist_for_each_entry_rcu(vlan, n, &port->vlan_hash[i], hlist) {
 			if (vlan->dev =3D=3D src || !(vlan->mode & mode))
 				continue;
-
+			if (!(vlan->dev->flags & IFF_UP))
+				continue;
 			nskb =3D skb_clone(skb, GFP_ATOMIC);
 			err =3D macvlan_broadcast_one(nskb, vlan, eth,
 					 mode =3D=3D MACVLAN_MODE_BRIDGE);
