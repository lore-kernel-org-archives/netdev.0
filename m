From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH] tcp: fix tcp_rcv_rtt_update() use of an unscaled RTT sample
Date: Tue, 10 Apr 2012 20:45:46 +0200
Message-ID: <CANn89iLpZ+XEMNf-22jByXe9_Ap5C7r07B0BTPHVrgUKgb5fxQ@mail.gmail.com>
References: <1334080760-968-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:54034 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758523Ab2DJSpq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 14:45:46 -0400
Received: by ghrr11 with SMTP id r11so80678ghr.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 11:45:46 -0700 (PDT)
In-Reply-To: <1334080760-968-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 10, 2012 at 7:59 PM, Neal Cardwell <ncardwell@google.com> w=
rote:
> Fix a code path in tcp_rcv_rtt_update() that was comparing scaled and
> unscaled RTT samples.
>
> The intent in the code was to only use the 'm' measurement if it was =
a
> new minimum. =A0However, since 'm' had not yet been shifted left 3 bi=
ts
> but 'new_sample' had, this comparison would nearly always succeed,
> leading us to erroneously set our receive-side RTT estimate to the 'm=
'
> sample when that sample could be nearly 8x too high to use.
>
> The overall effect is to often cause the receive-side RTT estimate to
> be significantly too large (up to 40% too large for brief periods in
> my tests).
>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> ---
> =A0net/ipv4/tcp_input.c | =A0 =A07 +++++--
> =A01 files changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index e886e2f..e7b54d2 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -474,8 +474,11 @@ static void tcp_rcv_rtt_update(struct tcp_sock *=
tp, u32 sample, int win_dep)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!win_dep) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0m -=3D (new_sample >> =
3);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0new_sample +=3D m;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (m < new_sample)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_sample =3D m << 3;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 m <<=3D 3;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (m < new_sample)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_sam=
ple =3D m;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* No previous measure. */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0new_sample =3D m << 3;
> --
> 1.7.7.3
>

Acked-by: Eric Dumazet <edumazet@google.com>
