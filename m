From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 17 of 39] IB/ipath - use more appropriate gfp flags
Date: Thu, 29 Jun 2006 17:02:55 -0700
Message-ID: <20060629170255.028d7a90.akpm@osdl.org>
References: <patchbomb.1151617251@eng-12.pathscale.com>
	<9d943b828776136a2bb7.1151617268@eng-12.pathscale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, mst@mellanox.co.il, openib-general@openib.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:64224 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751329AbWF3ADN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 20:03:13 -0400
To: "Bryan O'Sullivan" <bos@pathscale.com>
In-Reply-To: <9d943b828776136a2bb7.1151617268@eng-12.pathscale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Bryan O'Sullivan" <bos@pathscale.com> wrote:
>
> diff -r fd5e733f02ac -r 9d943b828776 drivers/infiniband/hw/ipath/ipath_file_ops.c
> --- a/drivers/infiniband/hw/ipath/ipath_file_ops.c	Thu Jun 29 14:33:25 2006 -0700
> +++ b/drivers/infiniband/hw/ipath/ipath_file_ops.c	Thu Jun 29 14:33:25 2006 -0700
> @@ -705,6 +705,15 @@ static int ipath_create_user_egr(struct 
>  	unsigned e, egrcnt, alloced, egrperchunk, chunk, egrsize, egroff;
>  	size_t size;
>  	int ret;
> +	gfp_t gfp_flags;
> +
> +	/*
> +	 * GFP_USER, but without GFP_FS, so buffer cache can be
> +	 * coalesced (we hope); otherwise, even at order 4,
> +	 * heavy filesystem activity makes these fail, and we can
> +	 * use compound pages.
> +	 */
> +	gfp_flags = __GFP_WAIT | __GFP_IO | __GFP_COMP;

Yes, GFP_NOFS|_GFP_COMP is reasonably strong - we can do swapout but not
file pageout.

I expect you'll find that a full GFP_KERNEL is OK here.  The ~__GFP_FS is
used to prevent the vm scanner from calling into ->writepage() and getting
stuck on locks which the __alloc_pages() caller already holds.

But ipathfs doesn't even implement ->writepage(), so I don't see any
problem with setting __GFP_FS.  If you're getting into trouble there then
I'd recommend giving it a try - it will make memory reclaim more
successful, especially with ext3, where a ->writepage often cleans the page
synchronously without doing any IO.

That being said, order-4 allocations will be fairly reliably unreliable.
