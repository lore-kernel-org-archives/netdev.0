From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink stats and message ordering.
Date: Sat, 20 Nov 2010 05:49:02 +0100
Message-ID: <1290228542.2756.57.camel@edumazet-laptop>
References: <4CE6BFE1.6020404@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56881 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932257Ab0KTEtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 23:49:07 -0500
Received: by wyb28 with SMTP id 28so5200108wyb.19
        for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 20:49:06 -0800 (PST)
In-Reply-To: <4CE6BFE1.6020404@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 novembre 2010 =C3=A0 10:20 -0800, Ben Greear a =C3=A9cri=
t :
> I have a single netlink socket that listens for various things,
> as well as requests netdev stats and such.
>=20
> I am seeing a case during interface creation (mac-vlans) where I get =
one set of stats
> that appears to show 1 packet transmitted, and then immediately after=
 that,
> a second set of stats for the same device that shows all zero counter=
s.
>=20
> Since I'm trying to handle wraps properly, my code tends to consider =
this
> a wrap and of course the numbers go all wrong since it wasn't really =
a wrap.
>=20
> I am wondering if it's possible that netlink messages are somehow bei=
ng
> re-ordered before they are sent to my application?

That's strange, maybe you could add a timestamp (or a sequence number)
in the stats message to check if two messages are eventually re-ordered=
=2E

As a fast check you could try to increment an error counter like this.
If you see the rx_dropped going back, then for sure there is a
problem...

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 93f0ba2..1d271ca 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -444,6 +444,7 @@ static struct rtnl_link_stats64 *macvlan_dev_get_st=
ats64(struct net_device *dev,
 {
 	struct macvlan_dev *vlan =3D netdev_priv(dev);
=20
+	atomic_long_inc(&dev->rx_dropped);
 	if (vlan->pcpu_stats) {
 		struct macvlan_pcpu_stats *p;
 		u64 rx_packets, rx_bytes, rx_multicast, tx_packets, tx_bytes;


