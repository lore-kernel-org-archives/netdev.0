From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: don't fragment SACKed skbs in tcp_mark_head_lost()
Date: Sat, 3 Mar 2012 07:19:35 -0800
Message-ID: <CAK6E8=dZ0+L3cvWQhZec43TYU8kPYrTDO6UC7JwpGQPCXoUkiA@mail.gmail.com>
References: <1330760211-25785-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, Nandita Dukkipati <nanditad@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:32800 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753850Ab2CCPT4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Mar 2012 10:19:56 -0500
Received: by obbuo6 with SMTP id uo6so2674630obb.19
        for <netdev@vger.kernel.org>; Sat, 03 Mar 2012 07:19:55 -0800 (PST)
In-Reply-To: <1330760211-25785-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 2, 2012 at 11:36 PM, Neal Cardwell <ncardwell@google.com> w=
rote:
> In tcp_mark_head_lost() we should not attempt to fragment a SACKed sk=
b
> to mark the first portion as lost. This is for two primary reasons:
>
> (1) tcp_shifted_skb() coalesces adjacent regions of SACKed skbs. When
> doing this, it preserves the sum of their packet counts in order to
> reflect the real-world dynamics on the wire. But given that skbs can
> have remainders that do not align to MSS boundaries, this packet coun=
t
> preservation means that for SACKed skbs there is not necessarily a
> direct linear relationship between tcp_skb_pcount(skb) and
> skb->len. Thus tcp_mark_head_lost()'s previous attempts to fragment
> off and mark as lost a prefix of length (packets - oldcnt)*mss from
> SACKed skbs were leading to occasional failures of the WARN_ON(len >
> skb->len) in tcp_fragment() (which used to be a BUG_ON(); see the
> recent "crash in tcp_fragment" thread on netdev).
>
> (2) there is no real point in fragmenting off part of a SACKed skb an=
d
> calling tcp_skb_mark_lost() on it, since tcp_skb_mark_lost() is a NOP
> for SACKed skbs.
>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>

Thanks for spending a lot of time on this obscure bug.

> ---
> =A0net/ipv4/tcp_input.c | =A0 =A01 +
> =A01 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index ee42d42..d9b83d1 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2569,6 +2569,7 @@ static void tcp_mark_head_lost(struct sock *sk,=
 int packets, int mark_head)
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (cnt > packets) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((tcp_is_sack(tp) &=
& !tcp_is_fack(tp)) ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (TCP_SKB_CB(skb=
)->sacked & TCPCB_SACKED_ACKED) ||
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(oldcnt >=3D p=
ackets))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> --
> 1.7.7.3
>
