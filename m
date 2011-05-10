From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC V2 PATCH] rtnetlink: Add method to calculate dump info
 data size
Date: Mon, 9 May 2011 20:56:26 -0700
Message-ID: <20110509205626.19dede92@nehalam>
References: <20110509222629.8689.77365.stgit@gitlad.jf.intel.com>
	<1304995413.3050.19.camel@edumazet-laptop>
	<20110509201705.409f6d39@nehalam>
	<1304999127.3050.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	bhutchings@solarflare.com, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53130 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754565Ab1EJD43 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 23:56:29 -0400
In-Reply-To: <1304999127.3050.40.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 May 2011 05:45:27 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 09 mai 2011 =C3=A0 20:17 -0700, Stephen Hemminger a =C3=A9cr=
it :
> > On Tue, 10 May 2011 04:43:33 +0200
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >=20
> > > Le lundi 09 mai 2011 =C3=A0 15:26 -0700, Greg Rose a =C3=A9crit :
> > > > The message size allocated for rtnl info dumps was limited to a=
 single
> > > > page.  This is not enough for additional interface info availab=
le with
> > > > devices that support SR-IOV.  Calculate the amount of data requ=
ired so
> > > > the dump can allocate enough data to satisfy the request.
> > > >=20
> > > > V2 of this patch adds a new argument to the rtnl_register servi=
ce that
> > > > allows for a new method to calculate the amount of data require=
d to
> > > > complete the info dump request.  So far the method is only impl=
emented
> > > > for the RTM_GETLINK slot.
> > > >=20
> > > > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> > >=20
> > > > =20
> > > > +static u16 rtnl_calcit(struct sk_buff *skb)
> > > > +{
> > > > +	struct net *net =3D sock_net(skb->sk);
> > > > +	int h;
> > > > +	int idx =3D 0, s_idx;
> > > > +	struct net_device *dev;
> > > > +	struct hlist_head *head;
> > > > +	struct hlist_node *node;
> > > > +	u16 alloc_size =3D 0;
> > > > +
> > > > +	for (h =3D 0; h < NETDEV_HASHENTRIES; h++, s_idx =3D 0) {
> > > > +		idx =3D 0;
> > > > +		head =3D &net->dev_index_head[h];
> > > > +		hlist_for_each_entry(dev, node, head, index_hlist) {
> > > > +			if (idx < s_idx) {
> > > > +				idx++;
> > > > +				continue;
> > > > +			}
> > > > +			alloc_size =3D (u16)if_nlmsg_size(dev);
> > > > +			break;
> > > > +		}
> > > > +	}
> > > > +
> > > > +	return alloc_size;
> > > > +}
> > > > +
> > >=20
> > >=20
> > > Sorry this wont scale. Some machines have thousand of devices.
> > >=20
> > > Just make an upper approximation, you dont need an exact one ;)
> >=20
> > The route dump does scale, can't you use a similar logic?
> > The result doesn't come back as one huge allocation.
> > I regularly test 600K routes on small machines.
> >=20
>=20
> Not sure I understand you Stephen.
>=20
> In Greg patch, rtnl_calcit() would be called for every 4K/8K block "i=
p"
> gets from kernel.
>=20
> If you add a function to route dump that would scan the 600K routes t=
o
> get the max route size, surely you notice O(N^2) complexity instead o=
f
> O(N)
>=20
> We only need to maintain a global variable to hold min_dump_alloc

I was hoping that the new interface dump would not need a pre-calculate=
d
size and could just incrementally add values. I was trying to use an
analogy with route dumping. The current route dump does not precalculat=
e
size.

What happens is dump iterates over the table and puts entries into
skb. When space is exhausted in skb the iterator stops and records the
key of the where to restart. Then restarts with next skb from there.

This scales O(N) with number of routes and does not have to precompute
size.



--=20
