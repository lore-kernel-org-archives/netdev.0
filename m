From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: fix tcp_retransmit_skb() to maintain MSS invariant
Date: Fri, 2 Mar 2012 08:28:48 -0800
Message-ID: <CAK6E8=e_cmLHzn=RJ=Bj3aPXj0Vv9OXY=Fe5Y=pRiDALoh9ptQ@mail.gmail.com>
References: <1330698449-2969-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, Nandita Dukkipati <nanditad@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:40288 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932343Ab2CBQ3J convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2012 11:29:09 -0500
Received: by obbuo6 with SMTP id uo6so1838029obb.19
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2012 08:29:08 -0800 (PST)
In-Reply-To: <1330698449-2969-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 2, 2012 at 6:27 AM, Neal Cardwell <ncardwell@google.com> wr=
ote:
> This commit fixes tcp_retransmit_skb() to respect the invariant that
> an skb in the write queue that might be SACKed (that is, that precede=
s
> tcp_send_head()) is either less than tcp_skb_mss(skb) or an integral
> multiple of tcp_skb_mss(skb).
>
> Various parts of the TCP code maintain or assume this invariant,
> including at least tcp_write_xmit(), tcp_mss_split_point(),
> tcp_match_skb_to_sack(), and tcp_shifted_skb().
>
> tcp_retransmit_skb() did not maintain this invariant. It checked the
> current MSS and called tcp_fragment() to make sure that the skb we're
> retransmitting is at most cur_mss, but in the process it took the
> excess bytes and created an arbitrary-length skb (one that is not
> necessarily an integral multiple of its MSS) and inserted it in the
> write queue after the skb we're retransmitting.
>
> One potential indirect effect of this problem is tcp_shifted_skb()
> creating a coalesced SACKed skb that has a pcount that is 1 too large
> for its length. This happened because tcp_shifted_skb() assumed that
> skbs are integral multiples of MSS, so you can just add pcounts of
> input skbs to find the pcount of the output skb. Suspected specific
> symtoms of this problem include the WARN_ON(len > skb->len) in
> tcp_fragment() firing, as the 1-too-large pcount ripples though to
> tcp_mark_head_lost() trying to chop off too many bytes to mark as
> lost.
>
> It's also possible this bug is related to recent reports of sacked_ou=
t
> becoming negative.
>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>

I especially like the comment about the invariant, which is less
explicit in other parts of GSO code.


> ---
> =A0net/ipv4/tcp_output.c | =A0 44 +++++++++++++++++++++++++++++++++++=
++++++++-
> =A01 files changed, 43 insertions(+), 1 deletions(-)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 4ff3b6d..13034ad 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2070,6 +2070,48 @@ static void tcp_retrans_try_collapse(struct so=
ck *sk, struct sk_buff *to,
> =A0 =A0 =A0 =A0}
> =A0}
>
> +/* So we can retransmit skb, fragment it to be cur_mss bytes. In
> + * addition, we must maintain the invariant that whatever skbs we
> + * leave in the write queue are integral multiples of the MSS or a
> + * remaining small sub-MSS portion. This means we fragment the skb
> + * into potentially three skbs in the write queue:
> + *
> + * =A0(1) The first skb of exactly 1*cur_mss, which we will retransm=
it now.
> + * =A0(2) A "bulk" skb that is an integral multiple of the cur_mss
> + * =A0(3) A "left-over" skb that has any remaining portion smaller t=
han cur_mss
> + *
> + * Since either of the two required fragmentation operations can fai=
l
> + * (e.g. due to ENOMEM), and we want this invariant to be maintained
> + * if either fails, we chop off (3) first and then chop off (1).
> + *
> + * Returns non-zero if an error occurred which prevented the full sp=
litting.
> + */
> +static int tcp_retrans_mss_split(struct sock *sk, struct sk_buff *sk=
b,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsi=
gned int cur_mss)
> +{
> + =A0 =A0 =A0 int err;
> + =A0 =A0 =A0 unsigned int len;
> +
> + =A0 =A0 =A0 /* Chop off any "left-over" at end that is not aligned =
to cur_mss. */
> + =A0 =A0 =A0 if (cur_mss !=3D tcp_skb_mss(skb)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 len =3D skb->len - skb->len % cur_mss;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (len < skb->len) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D tcp_fragment(sk=
, skb, len, cur_mss);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
err;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Chop off a single MSS at the beginning to retransmit=
 now. */
> + =A0 =A0 =A0 if (skb->len > cur_mss) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D tcp_fragment(sk, skb, cur_mss, =
cur_mss);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> =A0/* This retransmits one SKB. =A0Policy decisions and retransmit qu=
eue
> =A0* state updates are done by the caller. =A0Returns non-zero if an
> =A0* error occurred which prevented the send.
> @@ -2115,7 +2157,7 @@ int tcp_retransmit_skb(struct sock *sk, struct =
sk_buff *skb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EAGAIN;
>
> =A0 =A0 =A0 =A0if (skb->len > cur_mss) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tcp_fragment(sk, skb, cur_mss, cur_=
mss))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tcp_retrans_mss_split(sk, skb, cur_=
mss))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM; /* We'=
ll try again later. */
> =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int oldpcount =3D tcp_skb_pcount(skb);
> --
> 1.7.7.3
>
