From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net af_key: Fix RCU splat
Date: Sun, 23 Aug 2015 16:48:21 -0700 (PDT)
Message-ID: <20150823.164821.642841258349384154.davem@davemloft.net>
References: <1440085900-8917-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500AbbHWXsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 19:48:22 -0400
In-Reply-To: <1440085900-8917-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 20 Aug 2015 08:51:40 -0700

> @@ -1670,7 +1670,7 @@ static int pfkey_register(struct sock *sk, struct sk_buff *skb, const struct sad
>  		return -ENOBUFS;
>  	}
>  
> -	pfkey_broadcast(supp_skb, GFP_KERNEL, BROADCAST_REGISTERED, sk, sock_net(sk));
> +	pfkey_broadcast(supp_skb, GFP_ATOMIC, BROADCAST_REGISTERED, sk, sock_net(sk));

As Eric alluded to, the gfp_t argument is totally pointless.

It is used inside of pfkey_broadcast() via calls to pfkey_broadcast_one() inside of
an RCU protected area _CREATED_ by pfkey_broadcast() itself.

Therefore it could never possibly honor a sleeping gfp_t flag, and GFP_ATOMIC must
always be used.

So just get rid of it and use GFP_ATOMIC unconditionally.
