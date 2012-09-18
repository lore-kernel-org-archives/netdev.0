From: Stephan Springl <springl-k@bfw-online.de>
Subject: Re: [PATCH v2] tcp: fix regression in urgent data handling
Date: Tue, 18 Sep 2012 10:00:39 +0200 (MSZ)
Message-ID: <Pine.LNX.4.64.1209180959300.27164@lar.bfw.de>
References: <1347922299.26523.198.camel@edumazet-glaptop>
 <1347954850.26523.211.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-555875106-929378568-1347955239=:27164"
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bfw-online.de ([62.245.186.164]:54281 "EHLO
	mail.bfw-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756274Ab2IRIYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 04:24:36 -0400
In-Reply-To: <1347954850.26523.211.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---555875106-929378568-1347955239=:27164
Content-Type: TEXT/PLAIN; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT

Works here on top of 3.5.4, so

Tested-by: Stephan Springl <springl-k@bfw-online.de>

On Tue, 18 Sep 2012, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Stephan Springl found that commit 1402d366019fed "tcp: introduce
> tcp_try_coalesce" introduced a regression for rlogin
>
> It turns out problem comes from TCP urgent data handling and
> a change in behavior in input path.
>
> rlogin sends two one-byte packets with URG ptr set, and when next data
> frame is coalesced, we lack sk_data_ready() calls to wakeup consumer.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Stephan Springl <springl-k@bfw-online.de>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
> v2: Changed Stephan Springl email address in changelog/CC
>
> net/ipv4/tcp_input.c |    5 ++---
> 1 file changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 6e38c6c..d377f48 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4661,7 +4661,7 @@ queue_and_out:
>
> 		if (eaten > 0)
> 			kfree_skb_partial(skb, fragstolen);
> -		else if (!sock_flag(sk, SOCK_DEAD))
> +		if (!sock_flag(sk, SOCK_DEAD))
> 			sk->sk_data_ready(sk, 0);
> 		return;
> 	}
> @@ -5556,8 +5556,7 @@ no_ack:
> #endif
> 			if (eaten)
> 				kfree_skb_partial(skb, fragstolen);
> -			else
> -				sk->sk_data_ready(sk, 0);
> +			sk->sk_data_ready(sk, 0);
> 			return 0;
> 		}
> 	}
>
>
>


Freundliche Grüße

BFW Werner Völk GmbH
ppa. Stephan Springl
-- 
Stephan Springl                           BFW Werner Völk GmbH
Tel.:  +49 89 82917-452                   Energiemesstechnik & Service
Fax:   +49 89 82917-599                   Pasinger Str. 20 - 22
Mail:  springl@bfw-online.de              D-82166 Gräfelfing
Web:   http://www.novamess.de             Geschäftsführer: Georg F. Völk
                                           HRB 44779 Amtsgericht München
                                           USt.-ID: DE129301566
---555875106-929378568-1347955239=:27164--
