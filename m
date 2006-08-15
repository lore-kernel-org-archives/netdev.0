From: Paul Mackerras <paulus@samba.org>
Subject: Re: [patch 03/13] ppp: handle kmalloc() failures
Date: Tue, 15 Aug 2006 20:09:37 +1000
Message-ID: <17633.40289.120307.571499@cargo.ozlabs.ibm.com>
References: <200608150603.k7F63chF012930@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, takis@issaris.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.tip.net.au ([203.10.76.45]:2792 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S965347AbWHOKJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 06:09:42 -0400
To: akpm@osdl.org
In-Reply-To: <200608150603.k7F63chF012930@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org writes:

> From: Panagiotis Issaris <takis@issaris.org>
> 
> The PPP code contains two kmalloc()s followed by memset()s without handling a
> possible memory allocation failure.  (Suggested by Joe Perches).

Nack, because...

> -	cardmap_set(&all_ppp_units, unit, ppp);
> +	ret = cardmap_set(&all_ppp_units, unit, ppp);
> +	if (ret != 0) {
> +		printk(KERN_ERR "PPP: couldn't set cardmap\n");

first, this is a useless error message, and

> @@ -2735,6 +2742,10 @@ static void cardmap_set(struct cardmap *
>  		set_bit(i, &p->inuse);
>  	else
>  		clear_bit(i, &p->inuse);
> +	return 0;
> +enomem:
> +	cardmap_destroy(pmap);

secondly, this is a bit rude, isn't it, destroying the whole thing
because one insertion failed?  Some existing pppd will come along and
try to use its (previously successfully created) ppp unit and get told
it doesn't exist any more!

Paul.
