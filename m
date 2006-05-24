From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/5] llc: allow applications to get copy of kernel datagrams
Date: Tue, 23 May 2006 17:04:17 -0700
Message-ID: <20060524000530.269796000@localhost.localdomain>
References: <20060524000414.052569000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:8069 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932442AbWEXAFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 20:05:49 -0400
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Content-Disposition: inline; filename=llc-rcv-sap.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is legal for an application to bind to a SAP that is also being
used by the kernel. This happens if the bridge module binds to the
STP SAP, and the user wants to have a daemon for STP as well.
It is possible to have kernel doing STP on one bridge, but
let application do RSTP on another bridge.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
--- llc.orig/net/llc/llc_input.c
+++ llc/net/llc/llc_input.c
@@ -173,8 +173,10 @@ int llc_rcv(struct sk_buff *skb, struct 
 	 */
 	rcv = rcu_dereference(sap->rcv_func);
 	if (rcv) {
+ 		struct sk_buff *cskb = skb_clone(skb, GFP_ATOMIC);
+ 		if (cskb)
+ 			rcv(cskb, dev, pt, orig_dev);
 		rcv(skb, dev, pt, orig_dev);
-		goto out_put;
 	}
 	dest = llc_pdu_type(skb);
 	if (unlikely(!dest || !llc_type_handlers[dest - 1]))

--

