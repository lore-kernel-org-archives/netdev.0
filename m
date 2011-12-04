From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] tcp: tcp_sendmsg() page recycling
Date: Sun, 04 Dec 2011 09:20:53 -0800
Message-ID: <1323019253.1785.7.camel@joe2Laptop>
References: <1323018317.2762.143.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:41337 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752155Ab1LDRUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Dec 2011 12:20:55 -0500
In-Reply-To: <1323018317.2762.143.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-12-04 at 18:05 +0100, Eric Dumazet wrote:
> If our TCP_PAGE(sk) is not shared (page_count() == 1), we can set page
> offset to 0.
[]
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
[]
> @@ -1009,7 +1009,12 @@ new_segment:
>  				int merge = 0;
>  				int i = skb_shinfo(skb)->nr_frags;
>  				struct page *page = TCP_PAGE(sk);
> -				int off = TCP_OFF(sk);
> +				int off;
> +
> +				if (page && page_count(page) == 1)
> +					TCP_OFF(sk) = 0;
> +
> +				off = TCP_OFF(sk);

This might be clearer and take one less indirection as

				if (page && page_count(page) == 1) {
					TCP_OFF(sk) = 0;
					off = 0;
				} else {
					off = 0;
				}

or maybe

				if (page && page_count(page) == 1)
					off = TCP_OFF(sk) = 0;
				else
					off = 0;

And maybe the TCP_OFF and TCP_PAGE macros should be removed.
