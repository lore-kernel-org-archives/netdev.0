From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf] netfilter: conntrack: fix race in
 __nf_conntrack_confirm against get_next_corpse
Date: Thu, 13 Nov 2014 13:08:26 +0100
Message-ID: <20141113120826.GA8224@salvia>
References: <012601cff7d1$7ce2d620$76a88260$@gmail.com>
 <20141106133648.2534.1403.stgit@dragon>
 <20141110165439.GA7788@salvia>
 <20141112083500.5404e5f4@redhat.com>
 <54633D1B.5090404@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, programme110@gmail.com,
	netfilter-devel@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: =?iso-8859-1?Q?J=F6rg?= Marx <joerg.marx@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42233 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932419AbaKMMGa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2014 07:06:30 -0500
Content-Disposition: inline
In-Reply-To: <54633D1B.5090404@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 12, 2014 at 11:57:31AM +0100, J=F6rg Marx wrote:
> On 12.11.2014 08:35, Jesper Dangaard Brouer wrote:
>=20
> Hi,
>=20
> I wrote the patch in 2010, so find some arguments below:
>=20
> >>> > > +	nf_ct_del_from_dying_or_unconfirmed_list(ct);
> >>> > > =20
> >>> > >  	if (unlikely(nf_ct_is_dying(ct))) {
> >>> > > +		nf_ct_add_to_dying_list(ct);
> >>> > >  		nf_conntrack_double_unlock(hash, reply_hash);
> >>> > >  		local_bh_enable();
> >>> > >  		return NF_ACCEPT;
> >> >=20
> >> > Not directly related to your patch, but I don't find a good reas=
on why
> >> > we're accepting this packet.
> >> >=20
> >> > If the conntrack from the unconfirmed list is dying, then the ob=
ject
> >> > will be released by when the packet leaves the stack to its
> >> > destination. With stateful filtering depending in place, the fol=
low up
> >> > packet in the reply direction will likely be considered invalid =
(if
> >> > tcp tracking is on). Fortunately for us, the origin will likely
> >> > retransmit the syn again, so the ct will be setup accordingly.
> >> >=20
> >> > So, why should we allow this to go through?
> > True, it also seems strange to me that we accept this packet.
>=20
> The raise was triggered in a scenario when we tested high-load IPsec
> tunnels and flushed the conntrack hashs from userspace.
>=20
> For me there is little difference in choosing DROP or ACCEPT as verdi=
ct.
> The packet/skb belongs to a formerly allowed connection, most likely
> this connection is still allowed (but the conntrack hash entry is abo=
ut
> to be removed due to userspace is flushing the conntrack table).

__nf_conntrack_confirm() is only called for the first packet that we
see in a flow. If you just invoked the flush command once (which
should be the common case), then this is likely to be the first packet
of the flow (unless you already called flush anytime soon in the
past).

> To minimize the impact (lost packets -> retransmit) I decided to allo=
w
> the skb in flight, so were is no lost packet at this place.

I understand your original motivation was to be conservative.

> When the connection is not allowed anymore (but was allowed up to now=
,
> because the hash entry exists), the impact is one last packet 'slippi=
ng
> through'.

The general policy in conntrack is to not drop packets, but in this
case we'll leave things in inconsistent state (ie. we will likely
receive a reply packet in response to the original packet that has no
conntrack yet).

Thanks.
