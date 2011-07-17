From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] Fix panic in virtnet_remove
Date: Sun, 17 Jul 2011 13:12:15 +0300
Message-ID: <20110717101215.GA19287@redhat.com>
References: <20110715091650.23026.78221.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, shemminger@vyatta.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44539 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752596Ab1GQKLy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jul 2011 06:11:54 -0400
Content-Disposition: inline
In-Reply-To: <20110715091650.23026.78221.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 15, 2011 at 02:46:50PM +0530, Krishna Kumar wrote:
> modprobe -r virtio_net panics in free_netdev() as the
> dev is already freed in the newly introduced virtnet_free
> (commit 3fa2a1df9094).

Good catch, thanks!

> Since virtnet_remove doesn't require
> dev after unregister,

I'm not sure that true: vi used just above the line you remove
is I think the struct virtnet_info that is allocated
as part of that structure.


> I am removing the free_netdev call
> in virtnet_remove instead of in virtnet_free (which seems
> to be the right place to free the dev). Confirmed that
> the panic is fixed with this patch.

This might be just because the memory isn't reused.
Try enabling slab poisoning, I think you'll observe some problems.

Do we absolutely have to have a destructor?
Can't we move the per cpu counter free from
virtnet_free to virtnet_remove, and get rid of
virtnet_free completely?


> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  drivers/net/virtio_net.c |    2 --
>  1 file changed, 2 deletions(-)
> 
> diff -ruNp org/drivers/net/virtio_net.c new/drivers/net/virtio_net.c
> --- org/drivers/net/virtio_net.c	2011-07-04 10:38:33.000000000 +0530
> +++ new/drivers/net/virtio_net.c	2011-07-15 14:27:48.000000000 +0530
> @@ -1121,8 +1121,6 @@ static void __devexit virtnet_remove(str
>  
>  	while (vi->pages)
>  		__free_pages(get_a_page(vi, GFP_KERNEL), 0);
> -
> -	free_netdev(vi->dev);
>  }
>  
>  static struct virtio_device_id id_table[] = {
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
