From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net_device leak after "bridge: allow creating bridge devices
 with netlink"?
Date: Mon, 22 Aug 2011 18:05:59 +0200
Message-ID: <1314029159.2307.99.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E525ADA020000780005278A@nat28.tlf.novell.com>
	 <1314017401.2307.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110822085532.2ff4479c@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Beulich <JBeulich@novell.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38017 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753273Ab1HVQF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 12:05:57 -0400
Received: by wwf5 with SMTP id 5so5365051wwf.1
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 09:05:56 -0700 (PDT)
In-Reply-To: <20110822085532.2ff4479c@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 22 ao=C3=BBt 2011 =C3=A0 08:55 -0700, Stephen Hemminger a =C3=A9=
crit :
> On Mon, 22 Aug 2011 14:50:01 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > Le lundi 22 ao=C3=BBt 2011 =C3=A0 12:34 +0100, Jan Beulich a =C3=A9=
crit :
> > > Stephen,
> > >=20
> > > directly returning the result of register_netdev() from br_add_br=
idge()
> > > would - to me - appear to be leaking "dev" in case of failure. Or=
 am I
> > > overlooking some implicit mechanism by which this would get freed=
?
> > >=20
> > > Thanks, Jan
> >=20
> > You're 100 % right, there is a leak here.
> >=20
> > (But "ip" or "brctl" commands first check link already exist before
> > trying create it, so you need to tweak them to actually hit this bu=
g)
> >=20
> > We have to add a free_netdev() call to free the net_device.
> >=20
> >=20
> >=20
> > diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> > index 2cdf007..e738154 100644
> > --- a/net/bridge/br_if.c
> > +++ b/net/bridge/br_if.c
> > @@ -231,6 +231,7 @@ static struct net_bridge_port *new_nbp(struct n=
et_bridge *br,
> >  int br_add_bridge(struct net *net, const char *name)
> >  {
> >  	struct net_device *dev;
> > +	int res;
> > =20
> >  	dev =3D alloc_netdev(sizeof(struct net_bridge), name,
> >  			   br_dev_setup);
> > @@ -240,7 +241,10 @@ int br_add_bridge(struct net *net, const char =
*name)
> > =20
> >  	dev_net_set(dev, net);
> > =20
> > -	return register_netdev(dev);
> > +	res =3D register_netdev(dev);
> > +	if (res)
> > +		free_netdev(dev);
> > +	return res;
> >  }
> > =20
> >  int br_del_bridge(struct net *net, const char *name)
>=20
> Missing Signed-off-by:?
>=20
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Well, its only a direct coding of Jan report ;)

Thanks

[PATCH] bridge: fix a possible net_device leak

Jan Beulich reported a possible net_device leak in bridge code after
commit bb900b27a2f4 (bridge: allow creating bridge devices with netlink=
)

Reported-by: Jan Beulich <JBeulich@novell.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
---
 net/bridge/br_if.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 2cdf007..e738154 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -231,6 +231,7 @@ static struct net_bridge_port *new_nbp(struct net_b=
ridge *br,
 int br_add_bridge(struct net *net, const char *name)
 {
 	struct net_device *dev;
+	int res;
=20
 	dev =3D alloc_netdev(sizeof(struct net_bridge), name,
 			   br_dev_setup);
@@ -240,7 +241,10 @@ int br_add_bridge(struct net *net, const char *nam=
e)
=20
 	dev_net_set(dev, net);
=20
-	return register_netdev(dev);
+	res =3D register_netdev(dev);
+	if (res)
+		free_netdev(dev);
+	return res;
 }
=20
 int br_del_bridge(struct net *net, const char *name)


