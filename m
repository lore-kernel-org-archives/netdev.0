From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH net-next] netlink: avoid namespace change while
 creating socket
Date: Tue, 5 May 2015 09:52:04 +0800
Message-ID: <20150505015204.GA4993@gondor.apana.org.au>
References: <1430731339-22292-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xemul@openvz.org, den@openvz.org, davem@davemloft.net,
	avagin@gmail.com, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:57815 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932629AbbEEBwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 21:52:19 -0400
Content-Disposition: inline
In-Reply-To: <1430731339-22292-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 04, 2015 at 05:22:19PM +0800, Ying Xue wrote:
> Commit 23fe18669e7f ("[NETNS]: Fix race between put_net() and
> netlink_kernel_create().") attempts to fix the following race
> scenario:
> 
> put_net()
>   if (atomic_dec_and_test(&net->refcnt))
>     /* true */
>       __put_net(net);
>         queue_work(...);
> 
> /*
>  * note: the net now has refcnt 0, but still in
>  * the global list of net namespaces
>  */
> 
> == re-schedule ==
> 
> register_pernet_subsys(&some_ops);
>   register_pernet_operations(&some_ops);
>     (*some_ops)->init(net);
>       /*
>        * we call netlink_kernel_create() here
>        * in some places
>        */
>       netlink_kernel_create();
>          sk_alloc();
>             get_net(net); /* refcnt = 1 */
>          /*
>           * now we drop the net refcount not to
>           * block the net namespace exit in the
>           * future (or this can be done on the
>           * error path)
>           */
>          put_net(sk->sk_net);
>              if (atomic_dec_and_test(&...))
>                    /*
>                     * true. BOOOM! The net is
>                     * scheduled for release twice
>                     */

Surely the problem here is that the caller of netlink_kernel_create
should hold a ref count on net, so why doesn't it?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
