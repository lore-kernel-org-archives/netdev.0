From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] xen-netfront: reject short packets and handle
 non-linear packets
Date: Wed, 25 Jan 2017 08:51:26 -0800
Message-ID: <1485363086.5145.24.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485361612-10154-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
        Boris Ostrovsky <boris.ostrovsky@oracle.com>,
        Juergen Gross <jgross@suse.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35862 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751029AbdAYQv2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 11:51:28 -0500
Received: by mail-pg0-f66.google.com with SMTP id 75so20150030pgf.3
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 08:51:28 -0800 (PST)
In-Reply-To: <1485361612-10154-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-25 at 16:26 +0000, Paul Durrant wrote:
> Sowmini points out two vulnerabilities in xen-netfront:
> 
> a) The code assumes that skb->len is at least ETH_HLEN.
> b) The code assumes that at least ETH_HLEN octets are in the linear
>    port of the socket buffer.
> 
> This patch adds tests for both of these, and in the case of the latter
> pulls sufficient bytes into the linear area.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Reported-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Tested-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: Juergen Gross <jgross@suse.com>
> ---
>  drivers/net/xen-netfront.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 40f26b6..0478809 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -567,6 +567,10 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	u16 queue_index;
>  	struct sk_buff *nskb;
>  
> +	/* Basic sanity check */
> +	if (unlikely(skb->len < ETH_HLEN))
> +		goto drop;
> +
>  	/* Drop the packet if no queues are set up */
>  	if (num_queues < 1)
>  		goto drop;
> @@ -609,6 +613,11 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	}
>  
>  	len = skb_headlen(skb);
> +	if (unlikely(len < ETH_HLEN)) {
> +		if (!__pskb_pull_tail(skb, ETH_HLEN - len))
> +			goto drop;
> +		len = ETH_HLEN;
> +	}

Looks like duplicated code, and buggy, considering the code above

page = virt_to_page(skb->data);
offset = offset_in_page(skb->data);

Your patch might end up with skb->data/head being reallocated, and use
after free would happen.

What about something like that ?

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 40f26b69beb11459f0566fc1d1d739aa75e643bf..99a67fe4de86d3141169143b0820d00968cb09f2 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -583,6 +583,8 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			skb->len);
 		goto drop;
 	}
+	if (!pskb_may_pull(skb, ETH_HLEN))
+		goto drop;
 
 	slots = xennet_count_skb_slots(skb);
 	if (unlikely(slots > MAX_XEN_SKB_FRAGS + 1)) {
