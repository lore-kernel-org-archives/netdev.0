From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: fix false reordering signal in tcp_shifted_skb
Date: Tue, 28 Feb 2012 18:16:32 -0800
Message-ID: <CAK6E8=ehLUL8oZVARCGbh9XL7qu_eMC9XxjXApXyDUvoBADLNQ@mail.gmail.com>
References: <1330286779-10462-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, Nandita Dukkipati <nanditad@google.com>,
	Tom Herbert <therbert@google.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:56431 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966056Ab2B2CQx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Feb 2012 21:16:53 -0500
Received: by obcva7 with SMTP id va7so7539841obc.19
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2012 18:16:52 -0800 (PST)
In-Reply-To: <1330286779-10462-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 26, 2012 at 12:06 PM, Neal Cardwell <ncardwell@google.com> =
wrote:
> When tcp_shifted_skb() shifts bytes from the skb that is currently
> pointed to by 'highest_sack' then the increment of
> TCP_SKB_CB(skb)->seq implicitly advances tcp_highest_sack_seq(). This
> implicit advancement, combined with the recent fix to pass the correc=
t
> SACKed range into tcp_sacktag_one(), caused tcp_sacktag_one() to thin=
k
> that the newly SACKed range was before the tcp_highest_sack_seq(),
> leading to a call to tcp_update_reordering() with a degree of
> reordering matching the size of the newly SACKed range (typically jus=
t
> 1 packet, which is a NOP, but potentially larger).
>
> This commit fixes this by simply calling tcp_sacktag_one() before the
> TCP_SKB_CB(skb)->seq advancement that can advance our notion of the
> highest SACKed sequence.
>
> Correspondingly, we can simplify the code a little now that
> tcp_shifted_skb() should update the lost_cnt_hint in all cases where
> skb =3D=3D tp->lost_skb_hint.
>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> ---
> =A0net/ipv4/tcp_input.c | =A0 18 ++++++++++--------
> =A01 files changed, 10 insertions(+), 8 deletions(-)
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 53c8ce4..ee42d42 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -1403,8 +1403,16 @@ static int tcp_shifted_skb(struct sock *sk, st=
ruct sk_buff *skb,
>
> =A0 =A0 =A0 =A0BUG_ON(!pcount);
>
> - =A0 =A0 =A0 /* Adjust hint for FACK. Non-FACK is handled in tcp_sac=
ktag_one(). */
> - =A0 =A0 =A0 if (tcp_is_fack(tp) && (skb =3D=3D tp->lost_skb_hint))
> + =A0 =A0 =A0 /* Adjust counters and hints for the newly sacked seque=
nce
> + =A0 =A0 =A0 =A0* range but discard the return value since prev is a=
lready
> + =A0 =A0 =A0 =A0* marked. We must tag the range first because the se=
q
> + =A0 =A0 =A0 =A0* advancement below implicitly advances
> + =A0 =A0 =A0 =A0* tcp_highest_sack_seq() when skb is highest_sack.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 tcp_sacktag_one(sk, state, TCP_SKB_CB(skb)->sacked,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start_seq, end_seq, dup=
_sack, pcount);
> +
> + =A0 =A0 =A0 if (skb =3D=3D tp->lost_skb_hint)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->lost_cnt_hint +=3D pcount;
>
> =A0 =A0 =A0 =A0TCP_SKB_CB(prev)->end_seq +=3D shifted;
> @@ -1430,12 +1438,6 @@ static int tcp_shifted_skb(struct sock *sk, st=
ruct sk_buff *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_shinfo(skb)->gso_type =3D 0;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 /* Adjust counters and hints for the newly sacked seque=
nce range but
> - =A0 =A0 =A0 =A0* discard the return value since prev is already mar=
ked.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 tcp_sacktag_one(sk, state, TCP_SKB_CB(skb)->sacked,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start_seq, end_seq, dup=
_sack, pcount);
> -
> =A0 =A0 =A0 =A0/* Difference in this won't matter, both ACKed by the =
same cumul. ACK */
> =A0 =A0 =A0 =A0TCP_SKB_CB(prev)->sacked |=3D (TCP_SKB_CB(skb)->sacked=
 & TCPCB_EVER_RETRANS);
>
> --
> 1.7.7.3
>
Acked-by: Yuchung Cheng <ycheng@google.com>
