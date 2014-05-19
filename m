From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: Expose header length compution
 function
Date: Mon, 19 May 2014 14:01:31 -0700
Message-ID: <1400533291.5367.67.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399553434-25617-1-git-send-email-amirv@mellanox.com>
			<1399553434-25617-2-git-send-email-amirv@mellanox.com>
		 <20140509.162454.1317479460010270185.davem@davemloft.net>
		 <536E5DF4.8010908@gmail.com>
	 <1399744197.7973.11.camel@edumazet-glaptop2.roam.corp.google.com>
	 <536E9FE7.6060809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, amirv@mellanox.com,
	netdev@vger.kernel.org, idos@mellanox.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:62880 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbaESVBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 17:01:35 -0400
Received: by mail-pa0-f54.google.com with SMTP id bj1so6287396pad.13
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 14:01:34 -0700 (PDT)
In-Reply-To: <536E9FE7.6060809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-05-10 at 14:53 -0700, Alexander Duyck wrote:

> I'm more of a fan of purpose built functions in hot-path.  In the case
> of skb_flow_dissect, it is meant to collect the inputs for a Jenkins
> hash.

Not really.

And having multiple flow dissectors is really a lot of trouble for us,
and contributes to code bloat.

>   If we also expand it to get the length my concern is that it may
> do both, but it won't be very efficient at doing either, and that
> doesn't even take into account that somebody at some point might want
> the flow dissector to not do things like coalesce IPv6 addresses to
> support things like a Toeplitz hash which would slow things down further.
> 
> I can wait for the patch. I don't really see what you're talking about
> since we are trying to linearize the header portion of the buffers and
> for jumbos frames all 2K of the buffer has been used so you can't do any
> tricks like use a paged frag for the head.


I've tested the following with a mlx4, and it indeed speeds up GRE
traffic, as GRO packets can now contain 17 MSS instead of 8.

(Pulling payload means GRO had to use 2 'frags' per MSS)

 drivers/net/ethernet/mellanox/mlx4/en_rx.c |   13 ++++++----
 include/linux/skbuff.h                     |    1 
 net/core/flow_dissector.c                  |   23 +++++++++++++++++++
 3 files changed, 32 insertions(+), 5 deletions(-)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index e8c0d2b832b7..ff996b7c9a89 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -586,6 +586,7 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 		skb_copy_to_linear_data(skb, va, length);
 		skb->tail += length;
 	} else {
+		unsigned int hlen;
 		/* Move relevant fragments to skb */
 		used_frags = mlx4_en_complete_rx_desc(priv, rx_desc, frags,
 							skb, length);
@@ -595,16 +596,18 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 		}
 		skb_shinfo(skb)->nr_frags = used_frags;
 
+		hlen = eth_frame_headlen(va, length);
+
 		/* Copy headers into the skb linear buffer */
-		memcpy(skb->data, va, HEADER_COPY_SIZE);
-		skb->tail += HEADER_COPY_SIZE;
+		memcpy(skb->data, va, hlen);
+		skb->tail += hlen;
 
 		/* Skip headers in first fragment */
-		skb_shinfo(skb)->frags[0].page_offset += HEADER_COPY_SIZE;
+		skb_shinfo(skb)->frags[0].page_offset += hlen;
 
 		/* Adjust size of first fragment */
-		skb_frag_size_sub(&skb_shinfo(skb)->frags[0], HEADER_COPY_SIZE);
-		skb->data_len = length - HEADER_COPY_SIZE;
+		skb_frag_size_sub(&skb_shinfo(skb)->frags[0], hlen);
+		skb->data_len = length - hlen;
 	}
 	return skb;
 }
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7a9beeb1c458..4b3d8999a11c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3066,6 +3066,7 @@ bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
 int skb_checksum_setup(struct sk_buff *skb, bool recalculate);
 
 u32 __skb_get_poff(const struct sk_buff *skb);
+u32 eth_frame_headlen(void *data, unsigned int len);
 
 /**
  * skb_head_is_locked - Determine if the skb->head is locked down
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 107ed12a5323..55d4831493c1 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -323,6 +323,29 @@ u32 __skb_get_poff(const struct sk_buff *skb)
 	return poff;
 }
 
+
+/* Helper to find length of headers in an ethernet frame.
+ * This can help drivers to pull exact amount of bytes into
+ * skb->head to get optimal GRO performance.
+ * TODO: Could also return rxhash while we do a complete flow dissection.
+ */
+u32 eth_frame_headlen(void *data, unsigned int len)
+{
+	const struct ethhdr *eth = data;
+	struct sk_buff skb;
+
+	if (unlikely(len < ETH_HLEN))
+		return len;
+
+	skb.protocol = eth->h_proto;
+	skb.head = skb.data = data + ETH_HLEN;
+	skb_reset_network_header(&skb);
+	skb.len = len - ETH_HLEN;
+	skb.data_len = 0;
+	return __skb_get_poff(&skb) + ETH_HLEN;
+}
+EXPORT_SYMBOL(eth_frame_headlen);
+
 static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 {
 #ifdef CONFIG_XPS
