From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: tcp_process_frto() should not set snd_cwnd to 0
Date: Sat, 2 Feb 2013 10:57:40 -0500
Message-ID: <CADVnQykbufy-kQrEnJm0bbt=n7C8OfE1=Kr-2KfP7Mbu5Eq58w@mail.gmail.com>
References: <20130123161238.GE8912@reaktio.net>
	<20130123214445.GA16641@order.stressinduktion.org>
	<20130123215151.GF8912@reaktio.net>
	<20130123152642.4a8389ba@nehalam.linuxnetplumber.net>
	<20130123234116.GC16641@order.stressinduktion.org>
	<1358984831.12374.1227.camel@edumazet-glaptop>
	<20130124135120.GD16641@order.stressinduktion.org>
	<1359777110.30177.58.camel@edumazet-glaptop>
	<20130202142832.GP8912@reaktio.net>
	<1359818075.30177.78.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-1?Q?Pasi_K=E4rkk=E4inen?= <pasik@iki.fi>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:36631 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757751Ab3BBP5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2013 10:57:41 -0500
Received: by mail-ee0-f54.google.com with SMTP id c41so2545772eek.27
        for <netdev@vger.kernel.org>; Sat, 02 Feb 2013 07:57:40 -0800 (PST)
In-Reply-To: <1359818075.30177.78.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 2, 2013 at 10:14 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 8aca4ee..37760df 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3506,7 +3506,7 @@ static bool tcp_process_frto(struct sock *sk, int flag)
>                 if (!(flag & FLAG_DATA_ACKED) && (tp->frto_counter == 1)) {
>                         /* Prevent sending of new data. */
>                         tp->snd_cwnd = min(tp->snd_cwnd,
> -                                          tcp_packets_in_flight(tp));
> +                                          max(tcp_packets_in_flight(tp), 1U));
>                         return true;
>                 }

This seems better than what we have now, but it seems to paper over a
significant bug somewhere in FRTO. If we are at this spot and
tcp_packets_in_flight() is zero, then this means that we have lost our
chance to disambiguate whether this loss timeout was spurious, and we
should assume it was a legit loss, so we should call:
    tcp_enter_frto_loss(sk, 2, flag);

One possible approach (please excuse the formatting for this informal proposal):

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0905997..66f7c32 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3482,7 +3482,8 @@ static bool tcp_process_frto(struct sock *sk, int flag)
     ((tp->frto_counter >= 2) && (flag & FLAG_RETRANS_DATA_ACKED)))
  tp->undo_marker = 0;

- if (!before(tp->snd_una, tp->frto_highmark)) {
+ if (!before(tp->snd_una, tp->frto_highmark) ||
+    !tcp_packets_in_flight(tp)) {
  tcp_enter_frto_loss(sk, (tp->frto_counter == 1 ? 2 : 3), flag);
  return true;
  }

neal
