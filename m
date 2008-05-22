From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: use krealloc() in nf_conntrack_extend.c V2
Date: Thu, 22 May 2008 21:06:06 +0200
Message-ID: <4835C41E.2010502@trash.net>
References: <Pine.LNX.4.64.0805222145320.6071@sbz-30.cs.Helsinki.FI> <Pine.LNX.4.64.0805222155150.6294@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mpm@selenic.com, clameter@sgi.com
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44503 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879AbYEVTHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 15:07:51 -0400
In-Reply-To: <Pine.LNX.4.64.0805222155150.6294@sbz-30.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pekka J Enberg wrote:
> The ksize() API is going away because it is being abused and it doesn't even
> work consistenly across different allocators. Therefore, convert
> net/netfilter/nf_conntrack_extend.c to use krealloc().
>
> Cc: <netfilter-devel@vger.kernel.org>
> Cc: <netdev@vger.kernel.org>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: Christoph Lameter <clameter@sgi.com>
> Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
> ---
> Patrick, please use this patch instead. The previous one did the moving
> unconditionally which is wrong. This one moves entries around only if
> krealloc() allocated a new buffer.
>
>  net/netfilter/nf_conntrack_extend.c |   10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
>
> Index: slab-2.6/net/netfilter/nf_conntrack_extend.c
> ===================================================================
> --- slab-2.6.orig/net/netfilter/nf_conntrack_extend.c	2008-05-22 21:52:12.000000000 +0300
> +++ slab-2.6/net/netfilter/nf_conntrack_extend.c	2008-05-22 21:52:26.000000000 +0300
> @@ -88,13 +88,11 @@
>  	newlen = newoff + t->len;
>  	rcu_read_unlock();
>  
> -	if (newlen >= ksize(ct->ext)) {
> -		new = kmalloc(newlen, gfp);
> -		if (!new)
> -			return NULL;
> -
> -		memcpy(new, ct->ext, ct->ext->len);
> +	new = krealloc(ct->ext, newlen, gfp);

Unfortunately this means we'll always have to reallocate, even
if there's still some room left from the previous allocation.
Any chance to avoid that?

