From: Luis Henriques <luis.henriques@canonical.com>
Subject: Re: [PATCH 3.2-3.12] skbuff: skb_segment: orphan frags before copying
Date: Mon, 9 Jun 2014 14:29:01 +0100
Message-ID: <20140609132901.GD3591@hercules>
References: <1402070968.23860.9.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	stable <stable@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:53852 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932685AbaFIN3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 09:29:07 -0400
Content-Disposition: inline
In-Reply-To: <1402070968.23860.9.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 06, 2014 at 05:09:28PM +0100, Ben Hutchings wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
>=20
> commit 1fd819ecb90cc9b822cd84d3056ddba315d3340f upstream.
>=20
> skb_segment copies frags around, so we need
> to copy them carefully to avoid accessing
> user memory after reporting completion to userspace
> through a callback.
>=20
> skb_segment doesn't normally happen on datapath:
> TSO needs to be disabled - so disabling zero copy
> in this case does not look like a big deal.
>=20
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> [bwh: Backported to 3.2.  As skb_segment() only supports page-frags *=
or* a
>  frag list, there is no need for the additional frag_skb pointer or t=
he
>  preparatory renaming.]
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> This is what I used in Debian for 3.2, and I believe it applies to al=
l
> stable branches up to 3.12 inclusive.
>=20
> For branches older than 3.6, this requires cherry-picking commit
> a353e0ce0fd4 ('skbuff: add an api to orphan frags').  To avoid breaki=
ng
> OOT builds of openvswitch, which will use skb_orphan_frags() if
> available, it is also necessary to cherry-pick commit dcc0fb782b3a
> ('skbuff: export skb_copy_ubufs').
>=20
> Ben.
>=20

Thanks Ben, I'll queue it for the 3.11 kernel.

Cheers,
--
Lu=EDs

> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2701,6 +2701,9 @@ struct sk_buff *skb_segment(struct sk_bu
>  						 skb_put(nskb, hsize), hsize);
> =20
>  		while (pos < offset + len && i < nfrags) {
> +			if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
> +				goto err;
> +
>  			*frag =3D skb_shinfo(skb)->frags[i];
>  			__skb_frag_ref(frag);
>  			size =3D skb_frag_size(frag);
>=20
> --=20
> Ben Hutchings
> You can't have everything.  Where would you put it?
