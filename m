From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH] ipv4: Restore accept_local behaviour in
 fib_validate_source()
Date: Thu, 14 Aug 2014 15:36:32 +0200
Message-ID: <1408023392.2808.4.camel@localhost>
References: <1408020352-22841-1-git-send-email-sebastien.barre@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Gregory Detal <gregory.detal@uclouvain.be>
To: =?ISO-8859-1?Q?S=E9bastien_Barr=E9?= <sebastien.barre@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27107 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754829AbaHNNgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 09:36:45 -0400
In-Reply-To: <1408020352-22841-1-git-send-email-sebastien.barre@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Do, 2014-08-14 at 14:45 +0200, S=C3=A9bastien Barr=C3=A9 wrote:
> Commit 7a9bc9b introduced a short-circuit to avoid calling
> fib_validate_source when not needed. That change took rp_filter
> into account, but not accept_local. This resulted in a change
> of behaviour: with rp_filter and accept_local off, incoming
> packets with a local address in the source field should be
> dropped.
>=20
> Here is how to reproduce the change pre/post 7a9bc9b commit:
> -configure the same IPv4 address on hosts A and B.
> -try to send an arp request from B to A.
> -The arp request will be dropped before commit 7a9bc9b,
> but accepted and answered after that commit.
>=20
> This adds a check for ACCEPT_LOCAL, to maintain full
> fib validation in case it is 0.
>=20
> Signed-off-by: S=C3=A9bastien Barr=C3=A9 <sebastien.barre@uclouvain.b=
e>
>=20
> ---
>  net/ipv4/fib_frontend.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 255aa99..fa1fb2d 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -321,6 +321,7 @@ int fib_validate_source(struct sk_buff *skb, __be=
32 src, __be32 dst,
>  	int r =3D secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(idev);
> =20
>  	if (!r && !fib_num_tclassid_users(dev_net(dev)) &&
> +	    IN_DEV_ACCEPT_LOCAL(idev) &&
>  	    (dev->ifindex !=3D oif || !IN_DEV_TX_REDIRECTS(idev))) {
>  		*itag =3D 0;
>  		return 0;

But fib_validate_check is too strict for this situation. In case
rp_filter and accept_local are disabled, you should also leave
__fib_validate_source directly after the RTN_UNICAST checks.

Bye,
Hannes
