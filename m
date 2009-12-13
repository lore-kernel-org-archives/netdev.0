From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Sun, 13 Dec 2009 20:25:12 +0800
Message-ID: <20091213122512.GA17255@gondor.apana.org.au>
References: <1260312605.19229.8.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, mst@redhat.com, netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54992 "HELO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with SMTP id S1752052AbZLMMZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 07:25:34 -0500
Content-Disposition: inline
In-Reply-To: <1260312605.19229.8.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sridhar Samudrala <sri@us.ibm.com> wrote:
> When testing vhost-net patches with a guest running linux 2.6.32, i am
> running into "Unexpected full queue" warning messages from start_xmit() in
> virtio_net.c causing a lot of requeues and a drastic reduction in throughput.
> 
> With a guest running 2.6.31, i get guest to host throughput around 7000Mb/s,
> but it drops to around 3200Mb/s with 2.6.32.
> 
> I don't see this problem with usermode virtio in qemu, but i get a thruput of
> only 2700Mb/s with both 2.6.31 and 2.6.32.
> 
> The following patch fixes this problem by dropping the skb and not requeuing
> to qdisc when it cannot be added to ring buffer. With this patch, i see
> similar performance as 2.6.31 with vhost-net.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index b9e002f..307cfd6 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -528,7 +528,11 @@ again:
>                        netif_start_queue(dev);
>                        goto again;
>                }
> -               return NETDEV_TX_BUSY;
> +
> +               /* drop the skb under stress. */ 
> +               vi->dev->stats.tx_dropped++;
> +               kfree_skb(skb);
> +               return NETDEV_TX_OK;
>        }

This patch only hides the real problem.  The issue is that we
should never start the queue unless we can accomodate a full
64KB packet.

In your case, whenever we have the space for a single slot we'd
start the queue.  However, if the head of the queue required more
than one slot it would immediately return BUSY and stop the queue
again.

Your patch simply drops the packet (likely to be TSO) which would
end up upsetting the TCP transmitter.

Please see what a real Ethernet driver (e.g., tg3 or ixgbe) does
for queue management.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
