From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] OOPS with NETLINK_FIB_LOOKUP netlink socket
Date: Fri, 21 Dec 2007 12:00:43 +0300
Message-ID: <20071221090043.GA25484@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@openvz.org, netdev@vger.kernel.org, kaber@trash.net,
	kuznet@ms2.inr.ac.ru
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:64087 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753823AbXLUI6i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 03:58:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nl_fib_input re-reuses incoming skb to send the reply. This means that this
packet will be freed twice, namely in:
- netlink_unicast_kernel
- on receive path
Use clone to send as a cure, the caller is responsible for kfree_skb on error.

Thanks to Alexey Dobryan, who originally found the problem.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index b03c4c6..ac6238a 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -832,10 +832,13 @@ static void nl_fib_input(struct sk_buff *skb)
 
 	nlh = nlmsg_hdr(skb);
 	if (skb->len < NLMSG_SPACE(0) || skb->len < nlh->nlmsg_len ||
-	    nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*frn))) {
-		kfree_skb(skb);
+	    nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*frn)))
 		return;
-	}
+
+	skb = skb_clone(skb, GFP_KERNEL);
+	if (skb == NULL)
+		return;
+	nlh = nlmsg_hdr(skb);
 
 	frn = (struct fib_result_nl *) NLMSG_DATA(nlh);
 	tb = fib_get_table(frn->tb_id_in);
