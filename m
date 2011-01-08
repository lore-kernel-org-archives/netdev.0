From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: [PATCH 3/5] NET: IPV4: ARP: allow to invalidate specific ARP
 entries
Date: Sun, 09 Jan 2011 01:57:12 +0200
Message-ID: <1294531032.25396.11.camel@maxim-laptop>
References: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
	 <1290996593-32416-4-git-send-email-maximlevitsky@gmail.com>
	 <1294404478.7674.0.camel@maxim-laptop>
	 <1294405062.3306.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux1394-devel <linux1394-devel@lists.sourceforge.net>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:44877 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab1AHX5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jan 2011 18:57:19 -0500
Received: by eye27 with SMTP id 27so8134928eye.19
        for <netdev@vger.kernel.org>; Sat, 08 Jan 2011 15:57:18 -0800 (PST)
In-Reply-To: <1294405062.3306.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-01-07 at 13:57 +0100, Eric Dumazet wrote:
> Le vendredi 07 janvier 2011 =C3=A0 14:47 +0200, Maxim Levitsky a =C3=A9=
crit :
> > On Mon, 2010-11-29 at 04:09 +0200, Maxim Levitsky wrote:
> > > IPv4 over firewire needs to be able to remove ARP entries
> > > from the ARP cache that belong to nodes that are removed, because
> > > IPv4 over firewire uses ARP packets for private information
> > > about nodes.
> > >=20
> > > This information becomes invalid as soon as node drops
> > > off the bus and when it reconnects, its only possible
> > > to start takling to is after it responded to an ARP packet.
> > > But ARP cache prevents such packets from being sent.
> > >=20
> > > CC: netdev@vger.kernel.org
> > > CC: "David S. Miller" <davem@davemloft.net>
> > > CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> > > CC: James Morris <jmorris@namei.org>
> > > CC: Patrick McHardy <kaber@trash.net>
> >=20
> > Anybody?
> >=20
> > Best regards,
> > 	Maxim Levitsky
> >=20
> > >=20
> > >=20
> > > Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
> > > ---
> > >  include/net/arp.h |    1 +
> > >  net/ipv4/arp.c    |   29 ++++++++++++++++++-----------
> > >  2 files changed, 19 insertions(+), 11 deletions(-)
> > >=20
> > > diff --git a/include/net/arp.h b/include/net/arp.h
> > > index f4cf6ce..91f0568 100644
> > > --- a/include/net/arp.h
> > > +++ b/include/net/arp.h
> > > @@ -25,5 +25,6 @@ extern struct sk_buff *arp_create(int type, int=
 ptype, __be32 dest_ip,
> > >  				  const unsigned char *src_hw,
> > >  				  const unsigned char *target_hw);
> > >  extern void arp_xmit(struct sk_buff *skb);
> > > +int arp_invalidate(struct net_device *dev, __be32 ip);
> > > =20
> > >  #endif	/* _ARP_H */
> > > diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> > > index d8e540c..35b1272 100644
> > > --- a/net/ipv4/arp.c
> > > +++ b/net/ipv4/arp.c
> > > @@ -1142,6 +1142,23 @@ static int arp_req_get(struct arpreq *r, s=
truct net_device *dev)
> > >  	return err;
> > >  }
> > > =20
> > > +int arp_invalidate(struct net_device *dev, __be32 ip)
> > > +{
> > > +	int err =3D -ENXIO;
> > > +	struct neighbour *neigh =3D neigh_lookup(&arp_tbl, &ip, dev);
> > > +
> > > +	if (neigh) {
> > > +		if (neigh->nud_state & ~NUD_NOARP)
> > > +			err =3D neigh_update(neigh, NULL, NUD_FAILED,
> > > +					   NEIGH_UPDATE_F_OVERRIDE|
> > > +					   NEIGH_UPDATE_F_ADMIN);
> > > +		neigh_release(neigh);
> > > +	}
> > > +
> > > +	return err;
> > > +}
> > > +EXPORT_SYMBOL(arp_invalidate);
> > > +
> > >  static int arp_req_delete_public(struct net *net, struct arpreq =
*r,
> > >  		struct net_device *dev)
> > >  {
> > > @@ -1162,7 +1179,6 @@ static int arp_req_delete(struct net *net, =
struct arpreq *r,
> > >  {
> > >  	int err;
> > >  	__be32 ip;
> > > -	struct neighbour *neigh;
> > > =20
> > >  	if (r->arp_flags & ATF_PUBL)
> > >  		return arp_req_delete_public(net, r, dev);
> > > @@ -1180,16 +1196,7 @@ static int arp_req_delete(struct net *net,=
 struct arpreq *r,
> > >  		if (!dev)
> > >  			return -EINVAL;
> > >  	}
> > > -	err =3D -ENXIO;
> > > -	neigh =3D neigh_lookup(&arp_tbl, &ip, dev);
> > > -	if (neigh) {
> > > -		if (neigh->nud_state & ~NUD_NOARP)
> > > -			err =3D neigh_update(neigh, NULL, NUD_FAILED,
> > > -					   NEIGH_UPDATE_F_OVERRIDE|
> > > -					   NEIGH_UPDATE_F_ADMIN);
> > > -		neigh_release(neigh);
> > > -	}
> > > -	return err;
> > > +	return arp_invalidate(dev, ip);
> > >  }
> > > =20
> > >  /*
> >=20
>=20
> Hi Maxim
>=20
> You were supposed to respin your patch after my commit :
>=20
> (941666c2e3e0f9f6a1 net: RCU conversion of dev_getbyhwaddr() and
> arp_ioctl())
>=20
> Thanks

Hi,

After looking at the code (and honestly its hard to work with it as it
has no documentation at all), I think I don't need any changes in my
patch.

Here is the latest version for I use with the above commit applied (it
is in mainline now).

---

commit 7da91d68d78b6a44ba6337be3b29b22ba2909b9e
Author: Maxim Levitsky <maximlevitsky@gmail.com>
Date:   Sat Nov 27 00:50:45 2010 +0200

    NET: IPV4: ARP: allow to invalidate specific ARP entries
   =20
    IPv4 over firewire needs to be able to remove ARP entries
    from the ARP cache that belong to nodes that are removed, because
    IPv4 over firewire uses ARP packets for private information
    about nodes.
   =20
    This information becomes invalid as soon as node drops
    off the bus and when it reconnects, its only possible
    to start takling to is after it responded to an ARP packet.
    But ARP cache prevents such packets from being sent.
   =20
    CC: netdev@vger.kernel.org
    CC: "David S. Miller" <davem@davemloft.net>
    CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
    CC: James Morris <jmorris@namei.org>
    CC: Patrick McHardy <kaber@trash.net>
   =20
   =20
    Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>

diff --git a/include/net/arp.h b/include/net/arp.h
index f4cf6ce..91f0568 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -25,5 +25,6 @@ extern struct sk_buff *arp_create(int type, int ptype=
, __be32 dest_ip,
 				  const unsigned char *src_hw,
 				  const unsigned char *target_hw);
 extern void arp_xmit(struct sk_buff *skb);
+int arp_invalidate(struct net_device *dev, __be32 ip);
=20
 #endif	/* _ARP_H */
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index a2fc7b9..e941c75 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1143,6 +1143,23 @@ static int arp_req_get(struct arpreq *r, struct =
net_device *dev)
 	return err;
 }
=20
+int arp_invalidate(struct net_device *dev, __be32 ip)
+{
+	int err =3D -ENXIO;
+	struct neighbour *neigh =3D neigh_lookup(&arp_tbl, &ip, dev);
+
+	if (neigh) {
+		if (neigh->nud_state & ~NUD_NOARP)
+			err =3D neigh_update(neigh, NULL, NUD_FAILED,
+					   NEIGH_UPDATE_F_OVERRIDE|
+					   NEIGH_UPDATE_F_ADMIN);
+		neigh_release(neigh);
+	}
+
+	return err;
+}
+EXPORT_SYMBOL(arp_invalidate);
+
 static int arp_req_delete_public(struct net *net, struct arpreq *r,
 		struct net_device *dev)
 {
@@ -1163,7 +1180,6 @@ static int arp_req_delete(struct net *net, struct=
 arpreq *r,
 {
 	int err;
 	__be32 ip;
-	struct neighbour *neigh;
=20
 	if (r->arp_flags & ATF_PUBL)
 		return arp_req_delete_public(net, r, dev);
@@ -1181,16 +1197,7 @@ static int arp_req_delete(struct net *net, struc=
t arpreq *r,
 		if (!dev)
 			return -EINVAL;
 	}
-	err =3D -ENXIO;
-	neigh =3D neigh_lookup(&arp_tbl, &ip, dev);
-	if (neigh) {
-		if (neigh->nud_state & ~NUD_NOARP)
-			err =3D neigh_update(neigh, NULL, NUD_FAILED,
-					   NEIGH_UPDATE_F_OVERRIDE|
-					   NEIGH_UPDATE_F_ADMIN);
-		neigh_release(neigh);
-	}
-	return err;
+	return arp_invalidate(dev, ip);
 }
=20
 /*




