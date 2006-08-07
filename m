From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ipx: header length validation needed
Date: Mon, 7 Aug 2006 13:46:36 -0700
Message-ID: <20060807134636.30f8b779@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:31935 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932113AbWHGUvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 16:51:21 -0400
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IPX is not checking for non-linear (and short packets) in it's receive routine.
This is serious because it may mean it ends up reading past end of skb.

This maybe related to this bug, because sky2 will copy small packets into small
skb's.

    http://bugzilla.kernel.org/show_bug.cgi?id=6693

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- a/net/ipx/af_ipx.c	2006-07-07 13:02:31.000000000 -0700
+++ b/net/ipx/af_ipx.c	2006-08-07 13:18:08.000000000 -0700
@@ -1642,6 +1642,9 @@
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
 		goto out;
 
+	if (!pskb_may_pull(skb, sizeof(struct ipxhdr)))
+		goto drop;
+
 	ipx		= ipx_hdr(skb);
 	ipx_pktsize	= ntohs(ipx->ipx_pktsize);
 	
