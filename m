From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next 05/14] gtp: Remove special mtu handling
Date: Mon, 18 Sep 2017 17:38:55 -0700
Message-ID: <20170919003904.5124-6-tom@quantonium.net>
References: <20170919003904.5124-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, pablo@netfilter.org, laforge@gnumonks.org,
        rohit@quantonium.net, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:44863 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751377AbdISAjo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 20:39:44 -0400
Received: by mail-pg0-f43.google.com with SMTP id j16so1094024pga.1
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 17:39:44 -0700 (PDT)
In-Reply-To: <20170919003904.5124-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removes MTU handling in gtp_build_skb_ip4. This is non standard relative
to how other tunneling protocols handle MTU. The model espoused is that
the inner interface should set it's MTU to be less than the expected
path MTU on the overlay network. Path MTU discovery is not typically
used for modifying tunnel MTUs.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/gtp.c | 30 ------------------------------
 1 file changed, 30 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 1de2ea6217ea..f2089fa4f004 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -466,8 +466,6 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 	struct iphdr *iph;
 	struct sock *sk;
 	__be32 saddr;
-	__be16 df;
-	int mtu;
 
 	/* Read the IP destination address and resolve the PDP context.
 	 * Prepend PDP header with TEI/TID from PDP ctx.
@@ -510,34 +508,6 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 
 	skb_dst_drop(skb);
 
-	/* This is similar to tnl_update_pmtu(). */
-	df = iph->frag_off;
-	if (df) {
-		mtu = dst_mtu(&rt->dst) - dev->hard_header_len -
-			sizeof(struct iphdr) - sizeof(struct udphdr);
-		switch (pctx->gtp_version) {
-		case GTP_V0:
-			mtu -= sizeof(struct gtp0_header);
-			break;
-		case GTP_V1:
-			mtu -= sizeof(struct gtp1_header);
-			break;
-		}
-	} else {
-		mtu = dst_mtu(&rt->dst);
-	}
-
-	rt->dst.ops->update_pmtu(&rt->dst, NULL, skb, mtu);
-
-	if (!skb_is_gso(skb) && (iph->frag_off & htons(IP_DF)) &&
-	    mtu < ntohs(iph->tot_len)) {
-		netdev_dbg(dev, "packet too big, fragmentation needed\n");
-		memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
-		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
-			  htonl(mtu));
-		goto err_rt;
-	}
-
 	gtp_set_pktinfo_ipv4(pktinfo, sk, iph, pctx, rt, &fl4, dev);
 	gtp_push_header(skb, pktinfo);
 
-- 
2.11.0
