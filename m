From: Philip Craig <philipc@snapgear.com>
Subject: Re: [PATCH 4/4] gre: Add Transparent Ethernet Bridging
Date: Thu, 09 Oct 2008 18:43:21 +1000
Message-ID: <48EDC429.5090502@snapgear.com>
References: <20081009070424.GA16684@gondor.apana.org.au> <E1KnpaS-0004Pe-Qt@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070604040401000600010600"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:47922 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752348AbYJIInZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 04:43:25 -0400
In-Reply-To: <E1KnpaS-0004Pe-Qt@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070604040401000600010600
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Thanks for doing this work, much appreciated.

I haven't tested your patches yet, but when I was attempting this,
I needed the attached patch to get it to work with bridging and
netfilter, otherwise gre tries to call
skb->dst->ops->update_pmtu(skb->dst, mtu);


Herbert Xu wrote:
> @@ -530,7 +572,13 @@ static int ipgre_rcv(struct sk_buff *skb)
>  		dst_release(skb->dst);
>  		skb->dst = NULL;
>  		nf_reset(skb);
> +
> +		if (tunnel->dev->type == ARPHRD_ETHER)
> +			skb->protocol = eth_type_trans(skb, skb->dev);

Do you need to check pskb_may_pull(skb, ETH_HLEN)?

> +
> +		skb_reset_network_header(skb);
>  		ipgre_ecn_decapsulate(iph, skb);
> +
>  		netif_rx(skb);
>  		read_unlock(&ipgre_lock);
>  		return(0);


--------------070604040401000600010600
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

--- linux-2.6.x/net/bridge/br_netfilter.c	18 Jun 2006 23:30:55 -0000	1.1.1.25
+++ linux-2.6.x/net/bridge/br_netfilter.c	11 Aug 2006 04:10:04 -0000
@@ -765,14 +765,28 @@ out:
 	return NF_STOLEN;
 }
 
+/*
+ * We've finished passing through netfilter, so we can remove the fake dst.
+ * This is required by some lower layers, eg ip_gre
+ */
+static int br_nf_dev_queue_xmit_finish(struct sk_buff *skb)
+{
+	if (skb->dst == (struct dst_entry *)&__fake_rtable) {
+		dst_release(skb->dst);
+		skb->dst = NULL;
+	}
+
+	return br_dev_queue_push_xmit(skb);
+}
+
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
 	if (skb->protocol == htons(ETH_P_IP) &&
 	    skb->len > skb->dev->mtu &&
 	    !(skb_shinfo(skb)->ufo_size || skb_shinfo(skb)->tso_size))
-		return ip_fragment(skb, br_dev_queue_push_xmit);
+		return ip_fragment(skb, br_nf_dev_queue_xmit_finish);
 	else
-		return br_dev_queue_push_xmit(skb);
+		return br_nf_dev_queue_xmit_finish(skb);
 }
 
 /* PF_BRIDGE/POST_ROUTING ********************************************/

--------------070604040401000600010600--
