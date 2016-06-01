From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 1/2] macvlan: Fix potential use-after free for broadcasts
Date: Wed, 1 Jun 2016 11:43:00 +0800
Message-ID: <20160601034300.GB31335@gondor.apana.org.au>
References: <20160526234433.GU8402@wantstofly.org>
 <20160530081752.GA4956@gondor.apana.org.au>
 <20160530082828.GB5106@gondor.apana.org.au>
 <20160531.140713.2187659962450926738.davem@davemloft.net>
 <20160601034218.GA31335@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: buytenh@wantstofly.org, kaber@trash.net, netdev@vger.kernel.org,
	jpirko@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:36414 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756857AbcFADnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 23:43:06 -0400
Content-Disposition: inline
In-Reply-To: <20160601034218.GA31335@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we postpone a broadcast packet we save the source port in
the skb if it is local.  However, the source port can disappear
before we get a chance to process the packet.

This patch fixes this by holding a ref count on the netdev.

It also delays the skb->cb modification until after we allocate
the new skb as you should not modify shared skbs.

Fixes: 412ca1550cbe ("macvlan: Move broadcasts into a work queue")
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 2bcf1f3..78a00e3 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -305,11 +305,14 @@ static void macvlan_process_broadcast(struct work_struct *w)
 
 		rcu_read_unlock();
 
+		if (src)
+			dev_put(src->dev);
 		kfree_skb(skb);
 	}
 }
 
 static void macvlan_broadcast_enqueue(struct macvlan_port *port,
+				      const struct macvlan_dev *src,
 				      struct sk_buff *skb)
 {
 	struct sk_buff *nskb;
@@ -319,8 +322,12 @@ static void macvlan_broadcast_enqueue(struct macvlan_port *port,
 	if (!nskb)
 		goto err;
 
+	MACVLAN_SKB_CB(nskb)->src = src;
+
 	spin_lock(&port->bc_queue.lock);
 	if (skb_queue_len(&port->bc_queue) < MACVLAN_BC_QUEUE_LEN) {
+		if (src)
+			dev_hold(src->dev);
 		__skb_queue_tail(&port->bc_queue, nskb);
 		err = 0;
 	}
@@ -429,8 +436,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 			goto out;
 		}
 
-		MACVLAN_SKB_CB(skb)->src = src;
-		macvlan_broadcast_enqueue(port, skb);
+		macvlan_broadcast_enqueue(port, src, skb);
 
 		return RX_HANDLER_PASS;
 	}
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
