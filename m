From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/5] llc: allow applications to get copy of kernel datagrams
 (redo)
Date: Wed, 31 May 2006 10:00:39 -0700
Message-ID: <20060531100039.5bce8cd6@dxpl.pdx.osdl.net>
References: <20060524000414.052569000@localhost.localdomain>
	<20060524000530.269796000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:11137 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751731AbWEaRAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 May 2006 13:00:41 -0400
To: Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060524000530.269796000@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is legal for an application to bind to a SAP that is also being
used by the kernel. This happens if the bridge module binds to the
STP SAP, and the user wants to have a daemon for STP as well.
It is possible to have kernel doing STP on one bridge, but
let application do RSTP on another bridge.

Previous version of the patch was broken and called rcv() twice.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- br.orig/net/llc/llc_input.c
+++ br/net/llc/llc_input.c
@@ -173,8 +173,11 @@ int llc_rcv(struct sk_buff *skb, struct 
 	 */
 	rcv = rcu_dereference(sap->rcv_func);
 	if (rcv) {
-		rcv(skb, dev, pt, orig_dev);
-		goto out_put;
+ 		struct sk_buff *skb2;
+
+		skb2 = skb_clone(skb, GFP_ATOMIC);
+ 		if (skb2)
+ 			rcv(skb2, dev, pt, orig_dev);
 	}
 	dest = llc_pdu_type(skb);
 	if (unlikely(!dest || !llc_type_handlers[dest - 1]))
