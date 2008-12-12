From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/8] net: Add Generic Receive Offload infrastructure
Date: Fri, 12 Dec 2008 22:25:24 +0000
Message-ID: <1229120724.3051.61.camel@achroite>
References: <20081212053116.GA2927@gondor.apana.org.au>
	 <E1LB0cx-0000r3-N2@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:55763 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753185AbYLLWZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 17:25:33 -0500
In-Reply-To: <E1LB0cx-0000r3-N2@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-12-12 at 16:31 +1100, Herbert Xu wrote:
[...]
> Whenever the skb is merged into an existing entry, the gro_receive
> function should set NAPI_GRO_CB(skb)->same_flow.  Note that if an skb
> merely matches an existing entry but can't be merged with it, then
> this shouldn't be set.

So why not call this field "merged"?

[...]
> =EF=BB=BFOnce gro_receive has determined that the new skb matches a h=
eld packet,
> the held packet may be processed immediately if the new skb cannot be
> merged with it.  In this case gro_receive should return the pointer t=
o
> the existing skb in gro_list.  Otherwise the new skb should be merged=
 into
> the existing packet and NULL should be returned, unless the new skb m=
akes
> it impossible for any further merges to be made (e.g., FIN packet) wh=
ere
> the merged skb should be returned.

This belongs in a kernel-doc comment, not in the commit message.

[...]
> Currently held packets are stored in a singly liked list just like LR=
O.
> The list is limited to a maximum of 8 entries.  In future, this may b=
e
> expanded to use a hash table to allow more flows to be held for mergi=
ng.

We used a hash table in our own soft-LRO, used in out-of-tree driver
releases.  This certainly improved performance in many-to-one
benchmarks.  How much it matters in real applications, I'm less sure.

[...]
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 4388e27..5e5132c 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
[...]
> +int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
> +{
> +	struct sk_buff **pp;
> +	struct packet_type *ptype;
> +	__be16 type =3D skb->protocol;
> +	struct list_head *head =3D &ptype_base[ntohs(type) & PTYPE_HASH_MAS=
K];

Are you intending for the VLAN driver to call napi_gro_receive()?  If
not, =EF=BB=BFI think this should treat VLAN tags as part of the MAC he=
ader.
Not every NIC separates them out!

> +	int count =3D 0;
> +	int mac_len;
> +
> +	if (!(skb->dev->features & NETIF_F_GRO))
> +		goto normal;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(ptype, head, list) {
> +		struct sk_buff *p;
> +
> +		if (ptype->type !=3D type || ptype->dev || !ptype->gro_receive)
> +			continue;
> +
> +		skb_reset_network_header(skb);
> +		mac_len =3D skb->network_header - skb->mac_header;
> +		skb->mac_len =3D mac_len;
> +		NAPI_GRO_CB(skb)->same_flow =3D 0;
> +		NAPI_GRO_CB(skb)->flush =3D 0;
> +		for (p =3D napi->gro_list; p; p =3D p->next) {
> +			count++;
> +			NAPI_GRO_CB(p)->same_flow =3D
> +				p->mac_len =3D=3D mac_len &&
> +				!memcmp(skb_mac_header(p), skb_mac_header(skb),
> +					mac_len);
> +			NAPI_GRO_CB(p)->flush =3D 0;

Is this assignment to flush really necessary?  Surely any skb on the
gro_list with flush =3D=3D 1 gets removed before the next call to
napi_gro_receive()?

> +		}
> +
> +		pp =3D ptype->gro_receive(&napi->gro_list, skb);
> +		break;
> +
> +	}
> +	rcu_read_unlock();
> +
> +	if (&ptype->list =3D=3D head)
> +		goto normal;

The above loop is unclear because most of the body is supposed to run a=
t
most once; I would suggest writing the loop and the failure case as:

	rcu_read_lock();
	list_for_each_entry_rcu(ptype, head, list)
		if (ptype->type =3D=3D type && !ptype->dev && ptype->gro_receive)
			break;
	if (&ptype->list =3D=3D head) {
		rcu_read_unlock();
		goto normal;
	}
=EF=BB=BF
and then moving the rest of the loop body after this.

The inet_lro code accepts either skbs or pages and the sfc driver takes
advantage of this: so long as most packets can be coalesced by LRO, it'=
s
cheaper to allocate page buffers in advance and then attach them to skb=
s
during LRO.  I think you should support the use of page buffers.
Obviously it adds complexity but there's a real performance benefit.
(Alternately you could work out how to make skb allocation cheaper, and
everyone would be happy!)

[...]
> +void netif_napi_del(struct napi_struct *napi)
> +{
> +	struct sk_buff *skb, *next;
> +
> +	list_del(&napi->dev_list);
> +
> +	for (skb =3D napi->gro_list; skb; skb =3D next) {
> +		next =3D skb->next;
> +		skb->next =3D NULL;
> +		kfree_skb(skb);
> +	}
=EF=BB=BF[...]

Shouldn't the list already be empty at this point?

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

