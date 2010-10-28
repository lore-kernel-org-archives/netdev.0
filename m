From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ip_gre: fix fallback tunnel setup
Date: Thu, 28 Oct 2010 21:11:19 +0200
Message-ID: <1288293079.2711.19.camel@edumazet-laptop>
References: <1288283634.11523.20.camel@edumazet-laptop>
	 <20101028.102917.246527148.davem@davemloft.net>
	 <1288291138.2711.0.camel@edumazet-laptop>
	 <20101028.114102.112602886.davem@davemloft.net>
	 <1288291679.2711.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:59040 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758930Ab0J1TLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 15:11:25 -0400
Received: by ewy7 with SMTP id 7so1834215ewy.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 12:11:24 -0700 (PDT)
In-Reply-To: <1288291679.2711.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 28 octobre 2010 =C3=A0 20:47 +0200, Eric Dumazet a =C3=A9crit =
:
> Le jeudi 28 octobre 2010 =C3=A0 11:41 -0700, David Miller a =C3=A9cri=
t :
> > I am still able to revert this I think without screwing up
> > publicly visible history, so I will double check and do the
> > revert if I can.
>=20
> Cool, I'll provide a patch in a couple of minutes, when tested.
>=20

I believe the right fix is this one, Pavel what do you think ?

With your patch, we allocate the per_cpu data twice for the fallback
tunnel, thus leaking memory.

Thanks

Note: free_percpu(NULL) is legal

[PATCH] ip_gre: fix fallback tunnel setup

Before making the fallback tunnel visible to lookups, we should make
sure it is completely setup, once ipgre_tunnel_init() had been called
and tstats per_cpu pointer allocated.

move rcu_assign_pointer(ign->tunnels_wc[0], tunnel); from
ipgre_fb_tunnel_init() to ipgre_init_net()

Based on a patch from Pavel Emelyanov

Reported-by: Pavel Emelyanov <xemul@openvz.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_gre.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 01087e0..70ff77f 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1325,7 +1325,6 @@ static void ipgre_fb_tunnel_init(struct net_devic=
e *dev)
 {
 	struct ip_tunnel *tunnel =3D netdev_priv(dev);
 	struct iphdr *iph =3D &tunnel->parms.iph;
-	struct ipgre_net *ign =3D net_generic(dev_net(dev), ipgre_net_id);
=20
 	tunnel->dev =3D dev;
 	strcpy(tunnel->parms.name, dev->name);
@@ -1336,7 +1335,6 @@ static void ipgre_fb_tunnel_init(struct net_devic=
e *dev)
 	tunnel->hlen		=3D sizeof(struct iphdr) + 4;
=20
 	dev_hold(dev);
-	rcu_assign_pointer(ign->tunnels_wc[0], tunnel);
 }
=20
=20
@@ -1383,10 +1381,12 @@ static int __net_init ipgre_init_net(struct net=
 *net)
 	if ((err =3D register_netdev(ign->fb_tunnel_dev)))
 		goto err_reg_dev;
=20
+	rcu_assign_pointer(ign->tunnels_wc[0],
+			   netdev_priv(ign->fb_tunnel_dev));
 	return 0;
=20
 err_reg_dev:
-	free_netdev(ign->fb_tunnel_dev);
+	ipgre_dev_free(ign->fb_tunnel_dev);
 err_alloc_dev:
 	return err;
 }


