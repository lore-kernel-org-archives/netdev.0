From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V3 net-next 1/1] hv_netvsc: Use the xmit_more skb flag
 to optimize signaling the host
Date: Wed, 06 May 2015 11:08:53 -0700
Message-ID: <1430935733.14545.57.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430936436-5837-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430936436-5837-1-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-05-06 at 11:20 -0700, K. Y. Srinivasan wrote:
> Based on the information given to this driver (via the xmit_more skb flag),
> we can defer signaling the host if more packets are on the way. This will help
> make the host more efficient since it can potentially process a larger batch of
> packets. Implement this optimization.


> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index 5993c7e..4efaa6e 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -435,6 +435,8 @@ check_size:
>  	packet->page_buf = page_buf;
>  
>  	packet->q_idx = skb_get_queue_mapping(skb);
> +	if (netif_tx_queue_stopped(netdev_get_tx_queue(net, packet->q_idx)))
> +		packet->xmit_more = false;

Have you tested this condition ever triggers ?

It should not.

netvsc_start_xmit() should not be called if the queue is stopped.

The problem is the following :

netvsc_start_xmit() is called with the packet that is going to stop the
queue, filling last slot, but with skb->xmit_more = 1;

So you need to do something about xmit_more, after calling
netif_tx_stop_queue(), not before.
