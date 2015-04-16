From: Luis Henriques <luis.henriques@canonical.com>
Subject: Re: [PATCH stable 3.10-3.16] tcp: Fix crash in TCP Fast Open
Date: Thu, 16 Apr 2015 17:24:05 +0100
Message-ID: <20150416162405.GF5949@hercules>
References: <1429120832.3211.91.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stable <stable@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>, 782515@bugs.debian.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:55150 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100AbbDPQYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 12:24:08 -0400
Content-Disposition: inline
In-Reply-To: <1429120832.3211.91.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2015 at 07:00:32PM +0100, Ben Hutchings wrote:
> Commit 355a901e6cf1 ("tcp: make connect() mem charging friendly")
> changed tcp_send_syn_data() to perform an open-coded copy of the 'syn=
'
> skb rather than using skb_copy_expand().
>=20
> The open-coded copy does not cover the skb_shared_info::gso_segs
> field, so in the new skb it is left set to 0.  When this commit was
> backported into stable branches between 3.10.y and 3.16.7-ckty
> inclusive, it triggered the BUG() in tcp_transmit_skb().
>=20
> Since Linux 3.18 the GSO segment count is kept in the
> tcp_skb_cb::tcp_gso_segs field and tcp_send_syn_data() does copy the
> tcp_skb_cb structure to the new skb, so mainline and newer stable
> branches are not affected.
>=20
> Set skb_shared_info::gso_segs to the correct value of 1.
>=20
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Thanks a lot, Ben.  I'll queue this for the next 3.16 kernel release.

Cheers,
--
Lu=EDs

> ---
>  net/ipv4/tcp_output.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index d5457e4..1ea0a07 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2992,6 +2992,7 @@ static int tcp_send_syn_data(struct sock *sk, s=
truct sk_buff *syn)
>  		goto fallback;
>  	syn_data->ip_summed =3D CHECKSUM_PARTIAL;
>  	memcpy(syn_data->cb, syn->cb, sizeof(syn->cb));
> +	skb_shinfo(syn_data)->gso_segs =3D 1;
>  	if (unlikely(memcpy_fromiovecend(skb_put(syn_data, space),
>  					 fo->data->msg_iov, 0, space))) {
>  		kfree_skb(syn_data);
>=20
> --=20
> Ben Hutchings
> Editing code like this is akin to sticking plasters on the bleeding s=
tump
> of a severed limb. - me, 29 June 1999
