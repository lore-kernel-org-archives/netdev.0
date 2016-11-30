From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] vhost_net: don't continue to call the recvmsg when
 meet errors
Date: Wed, 30 Nov 2016 15:40:51 +0200
Message-ID: <20161130152004-mutt-send-email-mst@kernel.org>
References: <1480507857-22976-1-git-send-email-wangyunjian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, caihe@huawei.com
To: Yunjian Wang <wangyunjian@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60644 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753106AbcK3Nk4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 08:40:56 -0500
Content-Disposition: inline
In-Reply-To: <1480507857-22976-1-git-send-email-wangyunjian@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 08:10:57PM +0800, Yunjian Wang wrote:
> When we meet an error(err=-EBADFD) recvmsg,

How do you get EBADFD? Won't vhost_net_rx_peek_head_len
return 0 in this case, breaking the loop?

> the error handling in vhost
> handle_rx() will continue. This will cause a soft CPU lockup in vhost thread.
> 
> Signed-off-by: Yunjian Wang <wangyunjian@huawei.com>
> ---
>  drivers/vhost/net.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 5dc128a..edc470b 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -717,6 +717,9 @@ static void handle_rx(struct vhost_net *net)
>  			pr_debug("Discarded rx packet: "
>  				 " len %d, expected %zd\n", err, sock_len);
>  			vhost_discard_vq_desc(vq, headcount);
> +			/* Don't continue to do, when meet errors. */
> +			if (err < 0)
> +				goto out;

You might get e.g. EAGAIN and I think you need to retry
in this case.

>  			continue;
>  		}
>  		/* Supply virtio_net_hdr if VHOST_NET_F_VIRTIO_NET_HDR */
> -- 
> 1.9.5.msysgit.1
> 
