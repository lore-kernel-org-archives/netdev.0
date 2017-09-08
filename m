From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net] net: qualcomm: rmnet: Fix a double free
Date: Fri, 08 Sep 2017 13:44:52 -0600
Message-ID: <2ddbb6da514108b4e70ccd8362292134@codeaurora.org>
References: <20170908102356.tzysh6qaiesd2umz@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170908102356.tzysh6qaiesd2umz@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
> b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
> index 557c9bf1a469..0335fce54201 100644
> --- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
> +++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
> @@ -95,10 +95,8 @@ struct sk_buff *rmnet_map_deaggregate(struct sk_buff 
> *skb)
>  	skb_pull(skb, packet_len);
> 
>  	/* Some hardware can send us empty frames. Catch them */
> -	if (ntohs(maph->pkt_len) == 0) {
> -		kfree_skb(skb);
> +	if (ntohs(maph->pkt_len) == 0)
>  		return NULL;
> -	}
> 
>  	return skbn;
>  }

Thanks for the patch. This is fixing the double free, but is leaking the 
new skb skbn
created. Perhaps we should add the check earlier -

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c 
b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
index 557c9bf..86b8c75 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
@@ -84,6 +84,10 @@ struct sk_buff *rmnet_map_deaggregate(struct sk_buff 
*skb)
         if (((int)skb->len - (int)packet_len) < 0)
                 return NULL;

+       /* Some hardware can send us empty frames. Catch them */
+       if (ntohs(maph->pkt_len) == 0)
+               return NULL;
+
         skbn = alloc_skb(packet_len + RMNET_MAP_DEAGGR_SPACING, 
GFP_ATOMIC);
         if (!skbn)
                 return NULL;
@@ -94,11 +98,5 @@ struct sk_buff *rmnet_map_deaggregate(struct sk_buff 
*skb)
         memcpy(skbn->data, skb->data, packet_len);
         skb_pull(skb, packet_len);

-       /* Some hardware can send us empty frames. Catch them */
-       if (ntohs(maph->pkt_len) == 0) {
-               kfree_skb(skb);
-               return NULL;
-       }
-
         return skbn;
  }


-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a 
Linux Foundation Collaborative Project
