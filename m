From: =?windows-1252?Q?J=F6rg_Marx?= <joerg.marx@secunet.com>
Subject: Re: [PATCH nf] netfilter: conntrack: fix race in __nf_conntrack_confirm
 against get_next_corpse
Date: Wed, 12 Nov 2014 11:57:31 +0100
Message-ID: <54633D1B.5090404@secunet.com>
References: <012601cff7d1$7ce2d620$76a88260$@gmail.com>	<20141106133648.2534.1403.stgit@dragon>	<20141110165439.GA7788@salvia> <20141112083500.5404e5f4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <programme110@gmail.com>, <netfilter-devel@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>, <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20141112083500.5404e5f4@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12.11.2014 08:35, Jesper Dangaard Brouer wrote:

Hi,

I wrote the patch in 2010, so find some arguments below:

>>> > > +	nf_ct_del_from_dying_or_unconfirmed_list(ct);
>>> > > =20
>>> > >  	if (unlikely(nf_ct_is_dying(ct))) {
>>> > > +		nf_ct_add_to_dying_list(ct);
>>> > >  		nf_conntrack_double_unlock(hash, reply_hash);
>>> > >  		local_bh_enable();
>>> > >  		return NF_ACCEPT;
>> >=20
>> > Not directly related to your patch, but I don't find a good reason=
 why
>> > we're accepting this packet.
>> >=20
>> > If the conntrack from the unconfirmed list is dying, then the obje=
ct
>> > will be released by when the packet leaves the stack to its
>> > destination. With stateful filtering depending in place, the follo=
w up
>> > packet in the reply direction will likely be considered invalid (i=
f
>> > tcp tracking is on). Fortunately for us, the origin will likely
>> > retransmit the syn again, so the ct will be setup accordingly.
>> >=20
>> > So, why should we allow this to go through?
> True, it also seems strange to me that we accept this packet.

The raise was triggered in a scenario when we tested high-load IPsec
tunnels and flushed the conntrack hashs from userspace.

=46or me there is little difference in choosing DROP or ACCEPT as verdi=
ct.
The packet/skb belongs to a formerly allowed connection, most likely
this connection is still allowed (but the conntrack hash entry is about
to be removed due to userspace is flushing the conntrack table).

To minimize the impact (lost packets -> retransmit) I decided to allow
the skb in flight, so were is no lost packet at this place.

When the connection is not allowed anymore (but was allowed up to now,
because the hash entry exists), the impact is one last packet 'slipping
through'.

Today I would still decide the way I did in 2010.

>=20
>> > This return verdict was introduced in: fc35077 ("netfilter:
>> > nf_conntrack: fix a race in __nf_conntrack_confirm against
>> > nf_ct_get_next_corpse()") btw.
> And the commit does not argue why NF_ACCEPT was chosen...
>=20
> -- Best regards, Jesper Dangaard Brouer MSc.CS, Sr. Network Kernel
> Developer at Red Hat Author of http://www.iptv-analyzer.org LinkedIn:
> http://www.linkedin.com/in/brouer

best regards
J=F6rg Marx

--=20

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
