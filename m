From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] yet another IPX nonlinear receive fix
Date: Tue, 8 Aug 2006 16:18:24 -0700
Message-ID: <20060808161824.5727f57d@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:63418 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965069AbWHHXSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 19:18:37 -0400
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Need to check some more cases in IPX receive.
If the skb is purely fragments, the IPX header needs to
be extracted. The function pskb_may_pull() may in theory invalidate
all the pointers in the skb, so references to ipx header must be
refreshed.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---

 net/ipx/af_ipx.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

675a6798f7a587cae7acf1ad795366ee201e1a41
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index c13e86b..4019642 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1642,14 +1642,17 @@ static int ipx_rcv(struct sk_buff *skb, 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
 		goto out;
 
-	ipx		= ipx_hdr(skb);
-	ipx_pktsize	= ntohs(ipx->ipx_pktsize);
+	if (!pskb_may_pull(skb, sizeof(struct ipxhdr)))
+		goto drop;
+
+	ipx_pktsize = ntohs(ipxhdr(skb)->ipx_pktsize);
 	
 	/* Too small or invalid header? */
 	if (ipx_pktsize < sizeof(struct ipxhdr) ||
 	    !pskb_may_pull(skb, ipx_pktsize))
 		goto drop;
                         
+	ipx = ipx_hdr(skb);
 	if (ipx->ipx_checksum != IPX_NO_CHECKSUM &&
 	   ipx->ipx_checksum != ipx_cksum(ipx, ipx_pktsize))
 		goto drop;
-- 
1.2.4

