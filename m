From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 net 1/2] mactap: Fix checksum errors for non-gso
 packets in bridge mode
Date: Tue, 29 Apr 2014 16:21:16 +0300
Message-ID: <20140429132115.GA18119@redhat.com>
References: <1398780591-10644-1-git-send-email-vyasevic@redhat.com>
 <1398780591-10644-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel.lezcano@free.fr,
	nightnord@gmail.com, kaber@trash.net, eric.dumazet@gmail.com,
	jasowang@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49249 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750952AbaD2OUk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 10:20:40 -0400
Content-Disposition: inline
In-Reply-To: <1398780591-10644-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2014 at 10:09:50AM -0400, Vlad Yasevich wrote:
> The following is a problematic configuration:
> 
>  VM1: virtio-net device connected to macvtap0@eth0
>  VM2: e1000 device connect to macvtap1@eth0
> 
> The problem is is that virtio-net supports checksum offloading
> and thus sends the packets to the host with CHECKSUM_PARTIAL set.
> On the other hand, e1000 does not support any acceleration.
> 
> For small TCP packets (and this includes the 3-way handshake),
> e1000 ends up receiving packets that only have a partial checksum
> set.  This causes TCP to fail checksum validation and to drop
> packets.  As a result tcp connections can not be established.
> 
> Commit 3e4f8b787370978733ca6cae452720a4f0c296b8
> 	macvtap: Perform GSO on forwarding path.
> fixes this issue for large packets wthat will end up undergoing GSO.
> This commit adds a check for the non-GSO case and attempts to
> compute the checksum for partially checksummed packets in the
> non-GSO case.
> 
> CC: Daniel Lezcano <daniel.lezcano@free.fr>
> CC: Patrick McHardy <kaber@trash.net>
> CC: Andrian Nord <nightnord@gmail.com>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Michael S. Tsirkin <mst@redhat.com>
> CC: Jason Wang <jasowang@redhat.com>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/macvtap.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index ff111a8..3381c4f 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -322,6 +322,15 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
>  			segs = nskb;
>  		}
>  	} else {
> +		/* If we receive a partial checksum and the tap side
> +		 * doesn't support checksum offload, compute the checksum.
> +		 * Note: it doesn't matter which checksum feature to
> +		 *        check, we either support them all or none.
> +		 */
> +		if (skb->ip_summed == CHECKSUM_PARTIAL &&
> +		    !(features & NETIF_F_ALL_CSUM) &&
> +		    skb_checksum_help(skb))
> +			goto drop;
>  		skb_queue_tail(&q->sk.sk_receive_queue, skb);
>  	}
>  
> -- 
> 1.9.0
