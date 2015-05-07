From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH net-next 01/11] netns: Fix race between put_net() and
 netlink_kernel_create()
Date: Thu, 7 May 2015 17:04:50 +0800
Message-ID: <20150507090450.GA31792@gondor.apana.org.au>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
 <1430988770-28907-2-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cwang@twopensource.com, xemul@openvz.org,
	davem@davemloft.net, eric.dumazet@gmail.com, ebiederm@xmission.com,
	maxk@qti.qualcomm.com, stephen@networkplumber.org, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, tom@herbertland.com,
	jchapman@katalix.com, erik.hugne@ericsson.com,
	jon.maloy@ericsson.com, horms@verge.net.au
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:46756 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755AbbEGJFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 05:05:13 -0400
Content-Disposition: inline
In-Reply-To: <1430988770-28907-2-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 07, 2015 at 04:52:40PM +0800, Ying Xue wrote:
>
> @@ -409,12 +410,17 @@ void __put_net(struct net *net)
>  {
>  	/* Cleanup the network namespace in process context */
>  	unsigned long flags;
> +	bool added = false;
>  
>  	spin_lock_irqsave(&cleanup_list_lock, flags);
> -	list_add(&net->cleanup_list, &cleanup_list);
> +	if (list_empty(&net->cleanup_list)) {
> +		list_add(&net->cleanup_list, &cleanup_list);
> +		added = true;
> +	}

Stop right there.  If a ref count is hitting zero twice you've
got big problems.  Because it means that after hitting zero the
first time it'll become positive again (if only briefly) which
opens you up to a race against the cleanup.

So this idea is a non-starter.

The rules for ref counts are really simple, if you hit zero then
you're dead.  Can someone explain to me in simple terms why this
ref count is special and needs to hit zero twice?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
