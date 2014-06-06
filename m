From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 3.13] core, nfqueue, openvswitch: Orphan frags in
 skb_zerocopy and handle errors
Date: Fri, 06 Jun 2014 17:01:07 +0100
Message-ID: <1402070467.23860.1.camel@deadeye.wl.decadent.org.uk>
References: <1395873465-22282-1-git-send-email-zoltan.kiss@citrix.com>
	 <20140327.152956.1528740039185894234.davem@davemloft.net>
	 <20140421112601.GC3200@hercules>
	 <1398181118.3624.203.camel@deadeye.wl.decadent.org.uk>
	 <5356AEBF.5010505@citrix.com>
	 <1398194284.7767.101.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-4fQtRN7bhDnEI4wT0xh8"
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, stable <stable@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1398194284.7767.101.camel@deadeye.wl.decadent.org.uk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-4fQtRN7bhDnEI4wT0xh8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

[Trimmed cc list; added Greg and stable]

On Tue, 2014-04-22 at 20:18 +0100, Ben Hutchings wrote:
> From: Zoltan Kiss <zoltan.kiss@citrix.com>
>=20
> commit 36d5fe6a000790f56039afe26834265db0a3ad4c upstream.
>=20
> skb_zerocopy can copy elements of the frags array between skbs, but it do=
esn't
> orphan them. Also, it doesn't handle errors, so this patch takes care of =
that
> as well, and modify the callers accordingly. skb_tx_error() is also added=
 to
> the callers so they will signal the failed delivery towards the creator o=
f the
> skb.
>=20
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> [bwh: Backported to 3.13: skb_zerocopy() is new in 3.14, but was moved fr=
om a
>  static function in nfnetlink_queue.  We need to patch that and its calle=
r, but
>  not openvswitch.]
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

I noticed this is still not applied or queued for the 3.10.y branch, but
it does seem to be needed.

Ben.

> ---
> On Tue, 2014-04-22 at 19:02 +0100, Zoltan Kiss wrote:
> > On 22/04/14 16:38, Ben Hutchings wrote:
> > > On Mon, 2014-04-21 at 12:26 +0100, Luis Henriques wrote:
> > >> Hi David,
> > >>
> > >> On Thu, Mar 27, 2014 at 03:29:56PM -0400, David Miller wrote:
> > >>> From: Zoltan Kiss <zoltan.kiss@citrix.com>
> > >>> Date: Wed, 26 Mar 2014 22:37:45 +0000
> > >>>
> > >>>> skb_zerocopy can copy elements of the frags array between skbs, bu=
t it doesn't
> > >>>> orphan them. Also, it doesn't handle errors, so this patch takes c=
are of that
> > >>>> as well, and modify the callers accordingly. skb_tx_error() is als=
o added to
> > >>>> the callers so they will signal the failed delivery towards the cr=
eator of the
> > >>>> skb.
> > >>>>
> > >>>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> > >>>
> > >>> Fingers crossed :-)  Applied, thanks Zoltan.
> > >>> --
> > >>> To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > >>> the body of a message to majordomo@vger.kernel.org
> > >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > >>
> > >> Could you please queue this for stable as well?  It has CVE-2014-256=
8
> > >> assigned to it and I believe it is applicable to some of the trees.
> > >
> > > It was applied to 3.13, but needs backporting to earlier versions.  I
> > > posted my attempt in
> > > <1397429860.10849.86.camel@deadeye.wl.decadent.org.uk> but it needs
> > > testing/reviewing.
> >=20
> > This one is a different issue, although it is very similar.
>=20
> Sorry for mixing these up.  I believe this bug has been present since
> zerocopy was added to nfqueue in Linux 3.10 (commit ae08ce002108).  This
> is the version I used for Debian's 3.13 branch, which might be usable
> for older stable branches too.
>=20
> Ben.
>=20
> ---
> --- a/net/netfilter/nfnetlink_queue_core.c
> +++ b/net/netfilter/nfnetlink_queue_core.c
> @@ -235,22 +235,23 @@ nfqnl_flush(struct nfqnl_instance *queue
>  	spin_unlock_bh(&queue->lock);
>  }
> =20
> -static void
> +static int
>  nfqnl_zcopy(struct sk_buff *to, const struct sk_buff *from, int len, int=
 hlen)
>  {
>  	int i, j =3D 0;
>  	int plen =3D 0; /* length of skb->head fragment */
> +	int ret;
>  	struct page *page;
>  	unsigned int offset;
> =20
>  	/* dont bother with small payloads */
> -	if (len <=3D skb_tailroom(to)) {
> -		skb_copy_bits(from, 0, skb_put(to, len), len);
> -		return;
> -	}
> +	if (len <=3D skb_tailroom(to))
> +		return skb_copy_bits(from, 0, skb_put(to, len), len);
> =20
>  	if (hlen) {
> -		skb_copy_bits(from, 0, skb_put(to, hlen), hlen);
> +		ret =3D skb_copy_bits(from, 0, skb_put(to, hlen), hlen);
> +		if (unlikely(ret))
> +			return ret;
>  		len -=3D hlen;
>  	} else {
>  		plen =3D min_t(int, skb_headlen(from), len);
> @@ -268,6 +269,11 @@ nfqnl_zcopy(struct sk_buff *to, const st
>  	to->len +=3D len + plen;
>  	to->data_len +=3D len + plen;
> =20
> +	if (unlikely(skb_orphan_frags(from, GFP_ATOMIC))) {
> +		skb_tx_error(from);
> +		return -ENOMEM;
> +	}
> +
>  	for (i =3D 0; i < skb_shinfo(from)->nr_frags; i++) {
>  		if (!len)
>  			break;
> @@ -278,6 +284,8 @@ nfqnl_zcopy(struct sk_buff *to, const st
>  		j++;
>  	}
>  	skb_shinfo(to)->nr_frags =3D j;
> +
> +	return 0;
>  }
> =20
>  static int
> @@ -374,13 +382,16 @@ nfqnl_build_packet_message(struct net *n
> =20
>  	skb =3D nfnetlink_alloc_skb(net, size, queue->peer_portid,
>  				  GFP_ATOMIC);
> -	if (!skb)
> +	if (!skb) {
> +		skb_tx_error(entskb);
>  		return NULL;
> +	}
> =20
>  	nlh =3D nlmsg_put(skb, 0, 0,
>  			NFNL_SUBSYS_QUEUE << 8 | NFQNL_MSG_PACKET,
>  			sizeof(struct nfgenmsg), 0);
>  	if (!nlh) {
> +		skb_tx_error(entskb);
>  		kfree_skb(skb);
>  		return NULL;
>  	}
> @@ -504,13 +515,15 @@ nfqnl_build_packet_message(struct net *n
>  		nla->nla_type =3D NFQA_PAYLOAD;
>  		nla->nla_len =3D nla_attr_size(data_len);
> =20
> -		nfqnl_zcopy(skb, entskb, data_len, hlen);
> +		if (nfqnl_zcopy(skb, entskb, data_len, hlen))
> +			goto nla_put_failure;
>  	}
> =20
>  	nlh->nlmsg_len =3D skb->len;
>  	return skb;
> =20
>  nla_put_failure:
> +	skb_tx_error(entskb);
>  	kfree_skb(skb);
>  	net_err_ratelimited("nf_queue: error creating packet message\n");
>  	return NULL;
>=20

--=20
Ben Hutchings
You can't have everything.  Where would you put it?


--=-4fQtRN7bhDnEI4wT0xh8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU5Hlyue/yOyVhhEJAQpu4w/+MF8zSQgGqyzne+seHF5CONl0FTzgENfs
aPv/Xz2Wp35mRNWRzDDhMd4KcWdfJV7V+N6rYcet3Q2MBBLNY6GALv3qXQT7GHjT
+QmgVAogc5Y7PZYj2q1ostVZkcAi7zS9tHiV7Y6/aB3/mA/3lfWpBVb48eTMXHZy
2Q0T7x27zrWp7tLfJosuFjlWAwrSMTwRQExlcYVXT2LDESBJdxe0nO2aZwZYcMb9
5+jPYOhsphGqBOfkVfv6yc/s6LfJXuSCxhBhVFfoBDIB4FhmyGw8MAUmRQr7KA21
+/pA3yXb3lcj4Hir6i6k8OLBoMlN+8BDL9bs1LMEGCXNmVfboTB5KSmAfuCQaFOj
8lrukk97VJF0NgiIeE/dUg6IJRZ6vNyGKoMjefbZli2JVoi3u5T6B1XrRHBlrDhs
HUnYGEjfniOCwx2BIm9yk/bgbt7A50v9GwAhLkdaW9ZhaTTtyJiTSPyBvk3/Ta+d
DQUDnzXM3G+U4rnbU8ugO/7KSz0Io9JLb3rF4OMv7NckTkIP7uQHeqMjnwKVUM4q
Gnuk0yJ3VIPrNNlMe9pkmvM54zLvIiIhyrIRtkhBxiWUyHcZFuAXtSNo442Epo2h
XW4ooCOnDSnz7q1cyMkvRMTbSwONy/zQXVxFRpZ0eUZA+TnvGi5+FswpZzqXqn/S
L4UA6N3oX7g=
=NFpQ
-----END PGP SIGNATURE-----

--=-4fQtRN7bhDnEI4wT0xh8--
