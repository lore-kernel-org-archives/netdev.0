From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [RFC PATCH v2] net: fold dev_disable_lro() into
 netdev_fix_features()
Date: Thu, 12 May 2011 18:35:27 +0200
Message-ID: <20110512163527.GA17878@rere.qmqm.pl>
References: <20110507114803.0D80A13A6B@rere.qmqm.pl>
 <20110512160640.2A0B713A6B@rere.qmqm.pl>
 <1305217747.5214.17.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	bridge@lists.linux-foundation.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:52503 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932156Ab1ELQf2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2011 12:35:28 -0400
Content-Disposition: inline
In-Reply-To: <1305217747.5214.17.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 12, 2011 at 05:29:07PM +0100, Ben Hutchings wrote:
> On Thu, 2011-05-12 at 18:06 +0200, Micha=B3 Miros=B3aw wrote:
> > This implements checks for forwarding mode in netdev_fix_features()=
 using
> > dev->priv_flags bits. As a side effect, after device is no longer
> > forwarding it gets LRO back. This also means that user is not allow=
ed to
> > enable LRO after device is put to forwarding mode.
> >=20
> > This patch depends on removal of discrete offload setting ethtool o=
ps.
>=20
> This is nice, but:
>=20
> [...]
> > --- a/net/bridge/br_if.c
> > +++ b/net/bridge/br_if.c
> > @@ -158,6 +158,8 @@ static void del_nbp(struct net_bridge_port *p)
> >  	br_netpoll_disable(p);
> > =20
> >  	call_rcu(&p->rcu, destroy_nbp_rcu);
> > +
> > +	netdev_update_features(dev);
> >  }
> > =20
> >  /* called with RTNL */
> > @@ -368,11 +370,9 @@ int br_add_if(struct net_bridge *br, struct ne=
t_device *dev)
> > =20
> >  	dev->priv_flags |=3D IFF_BRIDGE_PORT;
> > =20
> > -	dev_disable_lro(dev);
> > -
> >  	list_add_rcu(&p->list, &br->port_list);
> > =20
> > -	netdev_update_features(br->dev);
> > +	netdev_change_features(dev);
> > =20
> >  	spin_lock_bh(&br->lock);
> >  	changed_addr =3D br_stp_recalculate_bridge_id(br);
> Why netdev_change_features() here?  I thought that was primarily for =
use
> when vlan_features may have been changed.

Because this recalculates port's features and then cascades to bridge's
device. I could have written:

	netdev_update_features(dev);
	netdev_update_features(br->dev);

But that might cause redundant recalculations for br->dev (first throug=
h
notifier calls). I'll add a comment here.

>=20
> [...]
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> [...]
> > @@ -5241,6 +5221,11 @@ u32 netdev_fix_features(struct net_device *d=
ev, u32 features)
> >  		}
> >  	}
> > =20
> > +	if (features & NETIF_F_LRO && dev->priv_flags & IFF_LRO_FORBIDDEN=
) {
> > +		netdev_info(dev, "Disabling LRO for forwarding interface.\n");
> > +		features &=3D NETIF_F_LRO;
> [...]
>=20
> Mising '~'.

=46ixed.

Best Regards,
Micha=B3 Miros=B3aw
