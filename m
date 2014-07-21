From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/5] net-timestamp: extend SCM_TIMESTAMPING
 ancillary data struct
Date: Mon, 21 Jul 2014 16:24:48 -0700 (PDT)
Message-ID: <20140721.162448.2136956416390069389.davem@davemloft.net>
References: <1405971357-22830-1-git-send-email-willemb@google.com>
	<1405971357-22830-2-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37536 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091AbaGUXZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 19:25:45 -0400
In-Reply-To: <1405971357-22830-2-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Mon, 21 Jul 2014 15:35:53 -0400

> Applications that request kernel tx timestamps with SO_TIMESTAMPING
> read timestamps as recvmsg() ancillary data. The response is defined
> implicitly as timespec[3]. Define the struct, and
> 
> 1) Add support for new tstamp types. On tx, scm_timestamping always
> accompanies a sock_extended_err. Define previously unused field
> ee_info to signal the type of ts[0]. Introduce SCM_TSTAMP_SND.
> 
> 2) Add support to discern timestamps. When multiple timestamped
> packets are in flight concurrently, correlating a timestamp with
> the right send() call is non-trivial. Define previously unused field
> ee_data to communicate a send() specific key, skb->mark. It is
> up to the application to optionally set this field to a unique
> value for each send call.
> 
> The reception path is not modified. On rx, no struct similar to
> sock_extended_err is passed along with SCM_TIMESTAMPING.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

I'm not so sure about this skb->mark usage, it has other uses for things
such as classification, it influences route lookups, netfilter behavior,
etc.

I do not think you therefore want to add another usage, timestamp packet
keying, which may conflict.

Also:

>  	if (sock_flag(sk, SOCK_RCVTSTAMP) ||
>  	    sock_flag(sk, SOCK_TIMESTAMPING_RX_SOFTWARE) ||
> -	    (kt.tv64 && sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE)) ||
> +	    (kt.tv64 && (sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) ||
> +	     skb_shinfo(skb)->tx_flags & SKBTX_ANY_SW_TSTAMP)) ||

This isn't indented correctly, the tx_flags test is part of the sock_flag()
test expression right before it so either:

	    (kt.tv64 && (sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) ||
			 skb_shinfo(skb)->tx_flags & SKBTX_ANY_SW_TSTAMP)) ||

or:


	    (kt.tv64 &&
	     (sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) ||
	      skb_shinfo(skb)->tx_flags & SKBTX_ANY_SW_TSTAMP)) ||

Thanks.
