From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next-2.6] vhost: Restart tx poll when socket send
	queue is full
Date: Tue, 23 Feb 2010 12:24:37 +0200
Message-ID: <20100223102437.GA23835@redhat.com>
References: <1266526751.15681.71.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58686 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750958Ab0BWK2D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2010 05:28:03 -0500
Content-Disposition: inline
In-Reply-To: <1266526751.15681.71.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 18, 2010 at 12:59:11PM -0800, Sridhar Samudrala wrote:
> When running guest to remote host TCP stream test using vhost-net
> via tap/macvtap, i am seeing network transmit hangs. This happens
> when handle_tx() returns because of the socket send queue full 
> condition.
> This patch fixes this by restarting tx poll when hitting this
> condition.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 91a324c..82d4bbe 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -113,12 +113,16 @@ static void handle_tx(struct vhost_net *net)
>  	if (!sock)
>  		return;
>  
> -	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
> -	if (wmem >= sock->sk->sk_sndbuf)
> -		return;
> -
>  	use_mm(net->dev.mm);
>  	mutex_lock(&vq->mutex);
> +
> +	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
> +	if (wmem >= sock->sk->sk_sndbuf) {
> +		tx_poll_start(net, sock);
> +		set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
> +		goto unlock;
> +	}
> +
>  	vhost_disable_notify(vq);
>  
>  	if (wmem < sock->sk->sk_sndbuf * 2)
> @@ -178,6 +182,7 @@ static void handle_tx(struct vhost_net *net)
>  		}
>  	}
>  
> +unlock:
>  	mutex_unlock(&vq->mutex);
>  	unuse_mm(net->dev.mm);
>  }


It might be better to avoid use_mm when ring is full.
Does the following fix the tx hang for you?


diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 4c89283..f5f6efe 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -113,8 +113,12 @@ static void handle_tx(struct vhost_net *net)
 		return;
 
 	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
-	if (wmem >= sock->sk->sk_sndbuf)
-		return;
+	if (wmem >= sock->sk->sk_sndbuf) {
+		mutex_lock(&vq->mutex);
+		tx_poll_start(net, sock);
+		mutex_unlock(&vq->mutex);
+                return;
+	}
 
 	use_mm(net->dev.mm);
 	mutex_lock(&vq->mutex);
