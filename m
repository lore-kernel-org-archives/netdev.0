From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/5] llc: use rcu_dereference on receive handler
Date: Tue, 23 May 2006 17:04:16 -0700
Message-ID: <20060524000530.152393000@localhost.localdomain>
References: <20060524000414.052569000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:7813 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932434AbWEXAFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 20:05:49 -0400
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Content-Disposition: inline; filename=llc-rcvfunc-rcu.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The receive hander pointer might be modified during network changes
of protocol. So use rcu_dereference (only matters on alpha).

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
--- br.orig/net/llc/llc_input.c
+++ br/net/llc/llc_input.c
@@ -142,6 +142,8 @@ int llc_rcv(struct sk_buff *skb, struct 
 	struct llc_sap *sap;
 	struct llc_pdu_sn *pdu;
 	int dest;
+	int (*rcv)(struct sk_buff *, struct net_device *,
+		   struct packet_type *, struct net_device *);
 
 	/*
 	 * When the interface is in promisc. mode, drop all the crap that it
@@ -169,8 +171,9 @@ int llc_rcv(struct sk_buff *skb, struct 
 	 * First the upper layer protocols that don't need the full
 	 * LLC functionality
 	 */
-	if (sap->rcv_func) {
-		sap->rcv_func(skb, dev, pt, orig_dev);
+	rcv = rcu_dereference(sap->rcv_func);
+	if (rcv) {
+		rcv(skb, dev, pt, orig_dev);
 		goto out_put;
 	}
 	dest = llc_pdu_type(skb);

--

