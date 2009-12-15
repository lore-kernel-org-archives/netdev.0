From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Add rtnetlink init_rcvwnd to set the TCP initial receive
 window
Date: Tue, 15 Dec 2009 22:00:24 +0100
Message-ID: <4B27F8E8.8040606@gmail.com>
References: <pvm3a3cx9cd.fsf@chavey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com
To: chavey@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42403 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760417AbZLOVAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 16:00:34 -0500
In-Reply-To: <pvm3a3cx9cd.fsf@chavey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/12/2009 21:37, chavey@google.com a =E9crit :
> Add rtnetlink init_rcvwnd to set the TCP initial receive window size
> advertised by passive and active TCP connections.
> The current Linux TCP implementation limits the advertised TCP initia=
l
> receive window to the one prescribed by slow start. For short lived
> TCP connections used for transaction type of traffic (i.e. http
> requests), bounding the advertised TCP initial receive window results
> in increased latency to complete the transaction.
> Support for setting initial congestion window is already supported
> using rtnetlink init_cwnd, but the feature is useless without the
> ability to set a larger TCP initial receive window.
> The rtnetlink init_rcvwnd allows increasing the TCP initial receive
> window, allowing TCP connection to advertise larger TCP receive windo=
w
> than the ones bounded by slow start.
>=20
> Signed-off-by: Laurent Chavey <chavey@google.com>
> ---

> diff --git a/include/net/dst.h b/include/net/dst.h
> index 5a900dd..ac7a116 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -78,21 +78,13 @@ struct dst_entry
>  	__u32			__pad2;
>  #endif
> =20
> -
>  	/*
> -	 * Align __refcnt to a 64 bytes alignment
> +	 * Align client references, __refcnt to a 64 bytes alignment
>  	 * (L1_CACHE_SIZE would be too much)
> -	 */
> -#ifdef CONFIG_64BIT
> -	long			__pad_to_align_refcnt[2];
> -#else
> -	long			__pad_to_align_refcnt[1];
> -#endif
> -	/*
>  	 * __refcnt wants to be on a different cache line from
>  	 * input/output/ops or performance tanks badly
>  	 */
> -	atomic_t		__refcnt;	/* client references	*/
> +	atomic_t		__refcnt __attribute__((__aligned__(64)));

Please dont do that.

There is a reason for not hiding holes in this structure.

Next time someone wants to add a new metric... bang... 64 bytes silentl=
y added...

->
#ifdef CONFIG_64BIT
	long			__pad_to_align_refcnt[1];
#endif


Thanks
