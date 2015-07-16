From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 1/3] tcp: introduce TCP experimental option
 for SMC
Date: Wed, 15 Jul 2015 21:28:37 -0700 (PDT)
Message-ID: <20150715.212837.233151628267116088.davem@davemloft.net>
References: <1436877755-23431-1-git-send-email-ubraun@linux.vnet.ibm.com>
	<1436877755-23431-2-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: utz.bacher@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, ursula.braun@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbbGPE2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 00:28:38 -0400
In-Reply-To: <1436877755-23431-2-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Tue, 14 Jul 2015 14:42:33 +0200

> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 48c3696..1b9a698 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -90,15 +90,28 @@ struct tcp_options_received {
>  		sack_ok : 4,	/* SACK seen on SYN packet		*/
>  		snd_wscale : 4,	/* Window scaling received from sender	*/
>  		rcv_wscale : 4;	/* Window scaling to send to receiver	*/
> +	u8	smc_capability:1; /* SMC capability			*/
>  	u8	num_sacks;	/* Number of SACK blocks		*/
>  	u16	user_mss;	/* mss requested by user in ioctl	*/
>  	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
>  };

This adds new space to this structure, which can be avoided.

sack_ok only actually needs 3 bits, not 4, then you can use the extra
bit for smc_capability.

> diff --git a/include/net/request_sock.h b/include/net/request_sock.h
> index 87935ca..dee47d2 100644
> --- a/include/net/request_sock.h
> +++ b/include/net/request_sock.h
> @@ -55,7 +55,8 @@ struct request_sock {
>  	struct sock			*rsk_listener;
>  	u16				mss;
>  	u8				num_retrans; /* number of retransmits */
> -	u8				cookie_ts:1; /* syncookie: encode tcpopts in timestamp */
> +	u8				cookie_ts:1, /* syncookie: encode tcpopts in timestamp */
> +					smc_capability:1;
>  	u8				num_timeout:7; /* number of timeouts */
>  	/* The following two fields can be easily recomputed I think -AK */
>  	u32				window_clamp; /* window clamp at creation time */

Again, similar situation here.

Please find a way to add your new boolean value without expanding the size of
this structure.  Here is it clear that a single u8 is fully consumed by the
cookie_ts and num_timeout bit fields.

> +#if IS_ENABLED(CONFIG_AFSMC)

I think this ifdef is completely pointless.

What do you think every Linux distribution is going to do for their kernels?
They are going to turn everything on.

So you need to find a way for your new feature to be nearly zero cost,
especially in the fast paths, assuming the code is enabled.
