From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] net: sctp: use MAX_HEADER for headroom reserve in
 output path
Date: Wed, 03 Dec 2014 10:32:02 -0500
Message-ID: <547F2CF2.4050609@gmail.com>
References: <1417605238-9936-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	robert@swiecki.net
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:41176 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293AbaLCPcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 10:32:07 -0500
In-Reply-To: <1417605238-9936-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/2014 06:13 AM, Daniel Borkmann wrote:
> To accomodate for enough headroom for tunnels, use MAX_HEADER instead
> of LL_MAX_HEADER. Robert reported that he has hit after roughly 40hrs
> of trinity an skb_under_panic() via SCTP output path (see reference).
> I couldn't reproduce it from here, but not using MAX_HEADER as elsewh=
ere
> in other protocols might be one possible cause for this.
>=20
> In any case, it looks like accounting on chunks themself seems to loo=
k
> good as the skb already passed the SCTP output path and did not hit
> any skb_over_panic(). Given tunneling was enabled in his .config, the
> headroom would have been expanded by MAX_HEADER in this case.
>=20
> Reported-by: Robert =C5=9Awi=C4=99cki <robert@swiecki.net>
> Reference: https://lkml.org/lkml/2014/12/1/507
> Fixes: 594ccc14dfe4d ("[SCTP] Replace incorrect use of dev_alloc_skb =
with alloc_skb in sctp_packet_transmit().")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Looks right.  If sctp path is over any kind of L3 tunnel, we'll see thi=
s.

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>  net/sctp/output.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 42dffd4..fc5e45b 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -401,12 +401,12 @@ int sctp_packet_transmit(struct sctp_packet *pa=
cket)
>  	sk =3D chunk->skb->sk;
> =20
>  	/* Allocate the new skb.  */
> -	nskb =3D alloc_skb(packet->size + LL_MAX_HEADER, GFP_ATOMIC);
> +	nskb =3D alloc_skb(packet->size + MAX_HEADER, GFP_ATOMIC);
>  	if (!nskb)
>  		goto nomem;
> =20
>  	/* Make sure the outbound skb has enough header room reserved. */
> -	skb_reserve(nskb, packet->overhead + LL_MAX_HEADER);
> +	skb_reserve(nskb, packet->overhead + MAX_HEADER);
> =20
>  	/* Set the owning socket so that we know where to get the
>  	 * destination IP address.
>=20
