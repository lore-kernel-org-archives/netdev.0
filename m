From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net-next v2 3/3] macsec: introduce IEEE 802.1AE driver
Date: Wed, 16 Mar 2016 10:50:39 +0100
Message-ID: <20160316095039.GA22528@bistromath>
References: <cover.1457714618.git.sd@queasysnail.net>
 <3d7ef45fa74b3bde47dabee3f23c8b8d04b546aa.1457714618.git.sd@queasysnail.net>
 <1458050611.2871.11.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>, stephen@networkplumber.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59727 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753680AbcCPJup (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 05:50:45 -0400
Content-Disposition: inline
In-Reply-To: <1458050611.2871.11.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

2016-03-15, 15:03:31 +0100, Johannes Berg wrote:
> Hi,
>=20
> > +struct macsec_rx_sa_stats {
> > +	__u32 InPktsOK;
> > +	__u32 InPktsInvalid;
> > +	__u32 InPktsNotValid;
> > +	__u32 InPktsNotUsingSA;
> > +	__u32 InPktsUnusedSA;
> > +};
> > +
> > +struct macsec_tx_sa_stats {
> > +	__u32 OutPktsProtected;
> > +	__u32 OutPktsEncrypted;
> > +};
>=20
> Just noticed this: is there a particular reason for using only __u32
> here? The others all seem to use __u64.

The standard defines them this way (Counter32 for the SA stats,
Counter64 for the SC/SecY stats).


> > +static int macsec_dump_txsc(struct sk_buff *skb, struct
> > netlink_callback *cb)
> > +{
> > +	struct net *net =3D sock_net(skb->sk);
> > +	struct net_device *dev;
> > +	int dev_idx, d;
> > +
> > +	dev_idx =3D cb->args[0];
> > +
> > +	d =3D 0;
> > +	for_each_netdev(net, dev) {
> > +		struct macsec_secy *secy;
> > +
> > +		if (d < dev_idx)
> > +			goto next;
> > +
> > +		if (!netif_is_macsec(dev))
> > +			goto next;
> > +
> > +		secy =3D &macsec_priv(dev)->secy;
> > +		if (dump_secy(secy, dev, skb, cb) < 0)
> > +			goto done;
> > +next:
> > +		d++;
> > +	}
> > +
> > +done:
> > +	cb->args[0] =3D d;
> > +	return skb->len;
> > +}
>=20
> Maybe you should consider adding=C2=A0genl_dump_check_consistent() su=
pport
> here, so userspace can figure out if the dump was really consistent, =
if
> necessary.
>=20
> To do this, you have to keep a global generation counter that changes
> whenever this list changes (adding/removing macsec interfaces, I thin=
k)
> and then set
>=20
> 	cb->seq =3D macsec_generation_counter;
>=20
> at the beginning of this function, and call
> genl_dump_check_consistent() for each message in the loop.

Thanks, I'll have a look at this.


> Btw, aren't you missing locking here for=C2=A0for_each_netdev()?

Oops, yeah.

--=20
Sabrina
