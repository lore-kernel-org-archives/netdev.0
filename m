From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Subject: Re: [Linux-ATM-General] [PATCH] atm/br2684: netif_stop_queue() when
 atm	device busy and netif_wake_queue() when we can send packets again.
Date: Thu, 10 Sep 2009 12:49:12 -0700
Message-ID: <4AA95838.4010007@redfish-solutions.com>
References: <4A9901E7.9040804@hiramoto.org> <1251545092-18081-1-git-send-email-karl@hiramoto.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020006070102040909060705"
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
To: Karl Hiramoto <karl@hiramoto.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:43072 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752988AbZIJTtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 15:49:40 -0400
In-Reply-To: <1251545092-18081-1-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020006070102040909060705
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

I had noticed that with my Solos card, and using Qwest 7062/896kb/s
service that I was typically only getting ~400kb/s upstream, so I
thought that delayed transmitter restarts might be the culprit and
decided to try out this patch.

I'm running 2.6.27.26, and I modified the patch as below.

Has anyone confirmed this patch (Karl's) against 2.6.27?

Thanks,

-Philip


Karl Hiramoto wrote:
> This patch removes the call to dev_kfree_skb() when the atm device is busy.
> Calling dev_kfree_skb() causes heavy packet loss then the device is under
> heavy load, the more correct behavior should be to stop the upper layers,
> then when the lower device can queue packets again wake the upper layers.
>
> Signed-off-by: Karl Hiramoto <karl@hiramoto.org>
> ---
>  net/atm/br2684.c |   37 +++++++++++++++++++++++++++----------
>  1 files changed, 27 insertions(+), 10 deletions(-)
>
> diff --git a/net/atm/br2684.c b/net/atm/br2684.c
> index 2912665..5c42225 100644
> --- a/net/atm/br2684.c
> +++ b/net/atm/br2684.c
> @@ -69,7 +69,7 @@ struct br2684_vcc {
>  	struct net_device *device;
>  	/* keep old push, pop functions for chaining */
>  	void (*old_push) (struct atm_vcc * vcc, struct sk_buff * skb);
> -	/* void (*old_pop)(struct atm_vcc *vcc, struct sk_buff *skb); */
> +	void (*old_pop)(struct atm_vcc *vcc, struct sk_buff *skb);
>  	enum br2684_encaps encaps;
>  	struct list_head brvccs;
>  #ifdef CONFIG_ATM_BR2684_IPFILTER
> @@ -142,6 +142,22 @@ static struct net_device *br2684_find_dev(const struct br2684_if_spec *s)
>  	return NULL;
>  }
>  
> +/* chained vcc->pop function.  Check if we should wake the netif_queue */
> +static void br2684_pop(struct atm_vcc *vcc, struct sk_buff *skb)
> +{
> +	struct br2684_vcc *brvcc = BR2684_VCC(vcc);
> +	struct net_device *net_dev = skb->dev;
> +
> +	pr_debug("br2684_pop(vcc %p ; net_dev %p )\n", vcc, net_dev);
> +	brvcc->old_pop(vcc, skb);
> +
> +	if (!net_dev)
> +		return;
> +
> +	if (atm_may_send(vcc, 0))
> +		netif_wake_queue(net_dev);
> +
> +}
>  /*
>   * Send a packet out a particular vcc.  Not to useful right now, but paves
>   * the way for multiple vcc's per itf.  Returns true if we can send,
> @@ -200,20 +216,19 @@ static int br2684_xmit_vcc(struct sk_buff *skb, struct net_device *dev,
>  
>  	ATM_SKB(skb)->vcc = atmvcc = brvcc->atmvcc;
>  	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n", skb, atmvcc, atmvcc->dev);
> -	if (!atm_may_send(atmvcc, skb->truesize)) {
> -		/*
> -		 * We free this here for now, because we cannot know in a higher
> -		 * layer whether the skb pointer it supplied wasn't freed yet.
> -		 * Now, it always is.
> -		 */
> -		dev_kfree_skb(skb);
> -		return 0;
> -	}
>  	atomic_add(skb->truesize, &sk_atm(atmvcc)->sk_wmem_alloc);
>  	ATM_SKB(skb)->atm_options = atmvcc->atm_options;
>  	dev->stats.tx_packets++;
>  	dev->stats.tx_bytes += skb->len;
>  	atmvcc->send(atmvcc, skb);
> +
> +	if (!atm_may_send(atmvcc, 0)) {
> +		netif_stop_queue(brvcc->device);
> +		/*check for race with br2684_pop*/
> +		if (atm_may_send(atmvcc, 0))
> +			netif_start_queue(brvcc->device);
> +	}
> +
>  	return 1;
>  }
>  
> @@ -503,8 +518,10 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
>  	atmvcc->user_back = brvcc;
>  	brvcc->encaps = (enum br2684_encaps)be.encaps;
>  	brvcc->old_push = atmvcc->push;
> +	brvcc->old_pop = atmvcc->pop;
>  	barrier();
>  	atmvcc->push = br2684_push;
> +	atmvcc->pop = br2684_pop;
>  
>  	__skb_queue_head_init(&queue);
>  	rq = &sk_atm(atmvcc)->sk_receive_queue;
>   


--------------020006070102040909060705
Content-Type: text/plain;
 name="linux-2.6.27-br2684.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.27-br2684.patch"

--- linux-2.6.27.29-astlinux/net/atm/br2684.c.orig	2009-07-30 16:06:41.000000000 -0700
+++ linux-2.6.27.29-astlinux/net/atm/br2684.c	2009-09-10 12:42:50.000000000 -0700
@@ -69,7 +69,7 @@ struct br2684_vcc {
 	struct net_device *device;
 	/* keep old push, pop functions for chaining */
 	void (*old_push) (struct atm_vcc * vcc, struct sk_buff * skb);
-	/* void (*old_pop)(struct atm_vcc *vcc, struct sk_buff *skb); */
+	void (*old_pop)(struct atm_vcc *vcc, struct sk_buff *skb);
 	enum br2684_encaps encaps;
 	struct list_head brvccs;
 #ifdef CONFIG_ATM_BR2684_IPFILTER
@@ -143,6 +143,22 @@ static struct net_device *br2684_find_de
 	return NULL;
 }
 
+/* chained vcc->pop function.  Check if we should wake the netif_queue */
+static void br2684_pop(struct atm_vcc *vcc, struct sk_buff *skb)
+{
+	struct br2684_vcc *brvcc = BR2684_VCC(vcc);
+	struct net_device *net_dev = skb->dev;
+
+	pr_debug("br2684_pop(vcc %p ; net_dev %p )\n", vcc, net_dev);
+	brvcc->old_pop(vcc, skb);
+
+	if (!net_dev)
+		return;
+
+	if (atm_may_send(vcc, 0))
+		netif_wake_queue(net_dev);
+
+}
 /*
  * Send a packet out a particular vcc.  Not to useful right now, but paves
  * the way for multiple vcc's per itf.  Returns true if we can send,
@@ -200,20 +216,19 @@ static int br2684_xmit_vcc(struct sk_buf
 
 	ATM_SKB(skb)->vcc = atmvcc = brvcc->atmvcc;
 	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n", skb, atmvcc, atmvcc->dev);
-	if (!atm_may_send(atmvcc, skb->truesize)) {
-		/*
-		 * We free this here for now, because we cannot know in a higher
-		 * layer whether the skb pointer it supplied wasn't freed yet.
-		 * Now, it always is.
-		 */
-		dev_kfree_skb(skb);
-		return 0;
-	}
 	atomic_add(skb->truesize, &sk_atm(atmvcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = atmvcc->atm_options;
 	brdev->stats.tx_packets++;
 	brdev->stats.tx_bytes += skb->len;
 	atmvcc->send(atmvcc, skb);
+
+	if (!atm_may_send(atmvcc, 0)) {
+		netif_stop_queue(brvcc->device);
+		/*check for race with br2684_pop*/
+		if (atm_may_send(atmvcc, 0))
+			netif_start_queue(brvcc->device);
+	}
+
 	return 1;
 }
 
@@ -509,8 +524,10 @@ static int br2684_regvcc(struct atm_vcc 
 	atmvcc->user_back = brvcc;
 	brvcc->encaps = (enum br2684_encaps)be.encaps;
 	brvcc->old_push = atmvcc->push;
+	brvcc->old_pop = atmvcc->pop;
 	barrier();
 	atmvcc->push = br2684_push;
+	atmvcc->pop = br2684_pop;
 
 	rq = &sk_atm(atmvcc)->sk_receive_queue;
 

--------------020006070102040909060705--
