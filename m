From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH] xfrm: don't segment UFO packets
Date: Wed, 16 Mar 2016 17:00:26 +0100
Message-ID: <20160316160026.GB19258@midget.suse.cz>
References: <20160129234424.GC7907@midget.suse.cz>
 <20160130042102.GA22809@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:58064 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750919AbcCPQAa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 12:00:30 -0400
Content-Disposition: inline
In-Reply-To: <20160130042102.GA22809@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm_output() will segment GSO packets, including UDP (UFO) packets.
this is wrong per RFC4303, section 3.3.4.  Fragmentation:

   If necessary, fragmentation is performed after ESP
   processing within an IPsec implementation.  Thus,
   transport mode ESP is applied only to whole IP
   datagrams (not to IP fragments).

Prevent xfrm_output() from segmenting UFO packets so that they will be
fragmented after the xfrm transforms.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>


diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4355129..6f3e814 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3501,6 +3501,12 @@ static inline bool skb_is_gso_v6(const struct sk_buff *skb)
 	return skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6;
 }
 
+/* Note: Should be called only if skb_is_gso(skb) is true */
+static inline bool skb_is_ufo(const struct sk_buff *skb)
+{
+	return skb_shinfo(skb)->gso_type & SKB_GSO_UDP;
+}
+
 void __skb_warn_lro_forwarding(const struct sk_buff *skb);
 
 static inline bool skb_warn_if_lro(const struct sk_buff *skb)
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index cc3676e..c52cc8b 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -197,8 +197,12 @@ int xfrm_output(struct sock *sk, struct sk_buff *skb)
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	int err;
 
-	if (skb_is_gso(skb))
-		return xfrm_output_gso(net, sk, skb);
+	if (skb_is_gso(skb)) {
+		if (skb_is_ufo(skb))
+			return xfrm_output2(net, sk, skb);
+		else
+			return xfrm_output_gso(net, sk, skb);
+	}
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		err = skb_checksum_help(skb);
-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
