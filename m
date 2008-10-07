From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 18/32] net: sk_allocation() - concentrate socket
 related allocations
Date: Tue, 07 Oct 2008 14:26:24 -0700 (PDT)
Message-ID: <20081007.142624.145010147.davem@davemloft.net>
References: <20081002130504.927878499@chello.nl>
	<20081002131608.821584767@chello.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	dlezcano@fr.ibm.com, penberg@cs.helsinki.fi, neilb@suse.de
To: a.p.zijlstra@chello.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36559
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753370AbYJGV0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 17:26:49 -0400
In-Reply-To: <20081002131608.821584767@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 02 Oct 2008 15:05:22 +0200

> @@ -952,6 +955,7 @@ static void tcp_v6_send_reset(struct soc
>  #ifdef CONFIG_TCP_MD5SIG
>  	struct tcp_md5sig_key *key;
>  #endif
> +	gfp_t gfp_mask = GFP_ATOMIC;
>  
>  	if (th->rst)
>  		return;
> @@ -969,13 +973,16 @@ static void tcp_v6_send_reset(struct soc
>  		tot_len += TCPOLEN_MD5SIG_ALIGNED;
>  #endif
>  
> +	if (sk)
> +		gfp_mask = sk_allocation(skb->sk, gfp_mask);
> +
>  	/*
>  	 * We need to grab some memory, and put together an RST,
>  	 * and then put it into the queue to be sent.
>  	 */
>  
>  	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + tot_len,
> -			 GFP_ATOMIC);
> +			 sk_allocation(sk, GFP_ATOMIC));
>  	if (buff == NULL)
>  		return;
>  

I don't think this is doing what you intend it to do.

First, you're conditionally calling sk_allocation() if
'sk' is non-NULL.  But then later you unconditionally
use sk_allocation() in the alloc_skb() call.

Furthermore, in the conditionalized case you're using
"skb->sk" instead of plain "sk" which is what you actually
checked against NULL.

I have no fundamental problem with this change, so please
audit this patch for similar problems, fix them all up,
and resubmit.

I'm also tossing the rest of your networking changes since
they'll have some dependency on this one, please resend those
at the same time as the fixed up version of this one.

Thanks.
