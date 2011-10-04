From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] x25: Validate incoming call user data lengths
Date: Tue, 04 Oct 2011 16:33:39 +0200
Message-ID: <1317738819.2440.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CA+nUz_J73agjPQPqdbTraUPLyv39sqQ4kvZTmrZrFXLW1faqwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andrew Hendry <andrew.hendry@gmail.com>
To: Matthew Daley <mattjd@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60380 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756574Ab1JDOd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 10:33:28 -0400
Received: by wyg34 with SMTP id 34so593812wyg.19
        for <netdev@vger.kernel.org>; Tue, 04 Oct 2011 07:33:27 -0700 (PDT)
In-Reply-To: <CA+nUz_J73agjPQPqdbTraUPLyv39sqQ4kvZTmrZrFXLW1faqwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 04 octobre 2011 =C3=A0 14:00 +0000, Matthew Daley a =C3=A9crit=
 :
> X.25 call user data is being copied in its entirety from incoming mes=
sages
> without consideration to the size of the destination buffers, leading=
 to
> possible buffer overflows. Validate incoming call user data lengths b=
efore
> these copies are performed.
>=20
> It appears this issue was noticed some time ago, however nothing seem=
ed to
> come of it: see http://www.spinics.net/lists/linux-x25/msg00043.html =
and
> commit 8db09f26f912f7c90c764806e804b558da520d4f.
>=20
> Signed-off-by: Matthew Daley <mattjd@gmail.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Andrew Hendry <andrew.hendry@gmail.com>
> Cc: stable <stable@kernel.org>
> ---
> Hopefully this is acceptable; I thought someone with greater knowledg=
e of
> X.25 might step in :) It should take into account Andrew's suggestion=
 to
> move af_x25.c's check to before the call acception.
>=20
>  net/x25/af_x25.c |    6 ++++++
>  net/x25/x25_in.c |    3 +++
>  2 files changed, 9 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
> index d306154..a4bd172 100644
> --- a/net/x25/af_x25.c
> +++ b/net/x25/af_x25.c
> @@ -959,6 +959,12 @@ int x25_rx_call_request(struct sk_buff *skb,
> struct x25_neigh *nb,
>  	skb_pull(skb,len);
>=20
>  	/*
> +	 *	Ensure that the amount of call user data is valid.
> +	 */
> +	if (skb->len > X25_MAX_CUD_LEN)
> +		goto out_clear_request;
> +
> +	/*
>  	 *	Find a listener for the particular address/cud pair.
>  	 */
>  	sk =3D x25_find_listener(&source_addr,skb);
> diff --git a/net/x25/x25_in.c b/net/x25/x25_in.c
> index 0b073b5..63488fd 100644
> --- a/net/x25/x25_in.c
> +++ b/net/x25/x25_in.c
> @@ -127,6 +127,9 @@ static int x25_state1_machine(struct sock *sk,
> struct sk_buff *skb, int frametyp
>  		 *	Copy any Call User Data.
>  		 */
>  		if (skb->len > 0) {
> +			if (skb->len > X25_MAX_CUD_LEN)
> +				goto out_clear;
> +
>  			skb_copy_from_linear_data(skb,
>  						  x25->calluserdata.cuddata,
>  						  skb->len);
> --

It seems fine to me.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Now, you could also fix x25 for undersized/frags frames :

Apparently, no check is done in this respect (missing pskb_may_pull()
calls)...
