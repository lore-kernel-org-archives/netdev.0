From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC V2 PATCH] rtnetlink: Add method to calculate dump info
 data size
Date: Mon, 9 May 2011 20:17:05 -0700
Message-ID: <20110509201705.409f6d39@nehalam>
References: <20110509222629.8689.77365.stgit@gitlad.jf.intel.com>
	<1304995413.3050.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	bhutchings@solarflare.com, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58561 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753379Ab1EJDRI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 23:17:08 -0400
In-Reply-To: <1304995413.3050.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 May 2011 04:43:33 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 09 mai 2011 =C3=A0 15:26 -0700, Greg Rose a =C3=A9crit :
> > The message size allocated for rtnl info dumps was limited to a sin=
gle
> > page.  This is not enough for additional interface info available w=
ith
> > devices that support SR-IOV.  Calculate the amount of data required=
 so
> > the dump can allocate enough data to satisfy the request.
> >=20
> > V2 of this patch adds a new argument to the rtnl_register service t=
hat
> > allows for a new method to calculate the amount of data required to
> > complete the info dump request.  So far the method is only implemen=
ted
> > for the RTM_GETLINK slot.
> >=20
> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
>=20
> > =20
> > +static u16 rtnl_calcit(struct sk_buff *skb)
> > +{
> > +	struct net *net =3D sock_net(skb->sk);
> > +	int h;
> > +	int idx =3D 0, s_idx;
> > +	struct net_device *dev;
> > +	struct hlist_head *head;
> > +	struct hlist_node *node;
> > +	u16 alloc_size =3D 0;
> > +
> > +	for (h =3D 0; h < NETDEV_HASHENTRIES; h++, s_idx =3D 0) {
> > +		idx =3D 0;
> > +		head =3D &net->dev_index_head[h];
> > +		hlist_for_each_entry(dev, node, head, index_hlist) {
> > +			if (idx < s_idx) {
> > +				idx++;
> > +				continue;
> > +			}
> > +			alloc_size =3D (u16)if_nlmsg_size(dev);
> > +			break;
> > +		}
> > +	}
> > +
> > +	return alloc_size;
> > +}
> > +
>=20
>=20
> Sorry this wont scale. Some machines have thousand of devices.
>=20
> Just make an upper approximation, you dont need an exact one ;)

The route dump does scale, can't you use a similar logic?
The result doesn't come back as one huge allocation.
I regularly test 600K routes on small machines.

--=20
