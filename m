From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net-next] tcp: fix tcp_should_expand_sndbuf() to use tcp_packets_in_flight()
Date: Fri, 20 Feb 2015 11:44:47 -0800
Message-ID: <CAA93jw7qV-SgjD4rZJGKeP-pt_4NBkP3eB1c+ewYUWfquUA3QQ@mail.gmail.com>
References: <1424457196-3497-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:44081 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754445AbbBTTor convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 14:44:47 -0500
Received: by mail-ob0-f173.google.com with SMTP id uy5so26419045obc.4
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 11:44:47 -0800 (PST)
In-Reply-To: <1424457196-3497-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 20, 2015 at 10:33 AM, Neal Cardwell <ncardwell@google.com> =
wrote:
> tcp_should_expand_sndbuf() does not expand the send buffer if we have
> filled the congestion window.
>
> However, it should use tcp_packets_in_flight() instead of
> tp->packets_out to make this check.

oy. is this a candidate for -stable?

> Testing has established that the difference matters a lot if there ar=
e
> many SACKed packets, causing a needless performance shortfall.

One of the things I have been meaning to do for a while is go back to
testing some of the original circumstances of bufferbloat,
to see to what extent all the enormous changes to linux tcp itself
since 2010 have made a difference. I vividly remember the sort of
dup ack/sack stuff, and tcp cubic losing it=C2=B4s mind, we saw back in=
 the
day on the simple tests here:

https://gettys.wordpress.com/2010/12/06/whose-house-is-of-glasse-must-n=
ot-throw-stones-at-another/

Running without fq_codel in place on my gateways is not something that
I do willingly. I am sad to report that the latest comcast services
running at nearly 200mbit down, still exhibit 1.2 seconds of latency
under load on the rrul test, *but* my primary targets for those sorts
of tests in the cloud have not kept up with the latest linuxes.
(hoping to deploy new stuff soon)

I had thought this guy=C2=B4s dissertation on BBR was pretty promising,=
 also:

http://cpsc.yale.edu/event/dissertation-defensemichael-nowlan

and keep wondering if that code has been more thoroughly evaluated and
tested somewhere.

> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Nandita Dukkipati <nanditad@google.com>
> ---
>  net/ipv4/tcp_input.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 8fdd27b..fb4cf8b 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4770,7 +4770,7 @@ static bool tcp_should_expand_sndbuf(const stru=
ct sock *sk)
>                 return false;
>
>         /* If we filled the congestion window, do not expand.  */
> -       if (tp->packets_out >=3D tp->snd_cwnd)
> +       if (tcp_packets_in_flight(tp) >=3D tp->snd_cwnd)
>                 return false;
>
>         return true;
> --
> 2.2.0.rc0.207.ga3a616c
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Dave T=C3=A4ht

thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
