From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC V2 PATCH] rtnetlink: Add method to calculate dump info
 data size
Date: Tue, 10 May 2011 05:45:27 +0200
Message-ID: <1304999127.3050.40.camel@edumazet-laptop>
References: <20110509222629.8689.77365.stgit@gitlad.jf.intel.com>
	 <1304995413.3050.19.camel@edumazet-laptop>
	 <20110509201705.409f6d39@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	bhutchings@solarflare.com, davem@davemloft.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39772 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717Ab1EJDpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 23:45:31 -0400
Received: by wya21 with SMTP id 21so4354678wya.19
        for <netdev@vger.kernel.org>; Mon, 09 May 2011 20:45:30 -0700 (PDT)
In-Reply-To: <20110509201705.409f6d39@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 09 mai 2011 =C3=A0 20:17 -0700, Stephen Hemminger a =C3=A9crit=
 :
> On Tue, 10 May 2011 04:43:33 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > Le lundi 09 mai 2011 =C3=A0 15:26 -0700, Greg Rose a =C3=A9crit :
> > > The message size allocated for rtnl info dumps was limited to a s=
ingle
> > > page.  This is not enough for additional interface info available=
 with
> > > devices that support SR-IOV.  Calculate the amount of data requir=
ed so
> > > the dump can allocate enough data to satisfy the request.
> > >=20
> > > V2 of this patch adds a new argument to the rtnl_register service=
 that
> > > allows for a new method to calculate the amount of data required =
to
> > > complete the info dump request.  So far the method is only implem=
ented
> > > for the RTM_GETLINK slot.
> > >=20
> > > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> >=20
> > > =20
> > > +static u16 rtnl_calcit(struct sk_buff *skb)
> > > +{
> > > +	struct net *net =3D sock_net(skb->sk);
> > > +	int h;
> > > +	int idx =3D 0, s_idx;
> > > +	struct net_device *dev;
> > > +	struct hlist_head *head;
> > > +	struct hlist_node *node;
> > > +	u16 alloc_size =3D 0;
> > > +
> > > +	for (h =3D 0; h < NETDEV_HASHENTRIES; h++, s_idx =3D 0) {
> > > +		idx =3D 0;
> > > +		head =3D &net->dev_index_head[h];
> > > +		hlist_for_each_entry(dev, node, head, index_hlist) {
> > > +			if (idx < s_idx) {
> > > +				idx++;
> > > +				continue;
> > > +			}
> > > +			alloc_size =3D (u16)if_nlmsg_size(dev);
> > > +			break;
> > > +		}
> > > +	}
> > > +
> > > +	return alloc_size;
> > > +}
> > > +
> >=20
> >=20
> > Sorry this wont scale. Some machines have thousand of devices.
> >=20
> > Just make an upper approximation, you dont need an exact one ;)
>=20
> The route dump does scale, can't you use a similar logic?
> The result doesn't come back as one huge allocation.
> I regularly test 600K routes on small machines.
>=20

Not sure I understand you Stephen.

In Greg patch, rtnl_calcit() would be called for every 4K/8K block "ip"
gets from kernel.

If you add a function to route dump that would scan the 600K routes to
get the max route size, surely you notice O(N^2) complexity instead of
O(N)

We only need to maintain a global variable to hold min_dump_alloc

[ and only increase this variable when necessary, not bother to decreas=
e
it when removing a driver ]



