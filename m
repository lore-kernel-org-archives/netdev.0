From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/7] gre: Call skb_checksum_simple_validate
Date: Wed, 7 May 2014 16:51:46 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405071642230.867@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:33713 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbaEGXvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 19:51:47 -0400
Received: by mail-vc0-f202.google.com with SMTP id if11so272751vcb.1
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 16:51:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use skb_checksum_simple_validate to verify checksum.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/gre_demux.c | 24 +-----------------------
 1 file changed, 1 insertion(+), 23 deletions(-)

diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index 250be74..fbfd829 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -93,28 +93,6 @@ void gre_build_header(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 }
 EXPORT_SYMBOL_GPL(gre_build_header);
 
-static __sum16 check_checksum(struct sk_buff *skb)
-{
-	__sum16 csum = 0;
-
-	switch (skb->ip_summed) {
-	case CHECKSUM_COMPLETE:
-		csum = csum_fold(skb->csum);
-
-		if (!csum)
-			break;
-		/* Fall through. */
-
-	case CHECKSUM_NONE:
-		skb->csum = 0;
-		csum = __skb_checksum_complete(skb);
-		skb->ip_summed = CHECKSUM_COMPLETE;
-		break;
-	}
-
-	return csum;
-}
-
 static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 			    bool *csum_err)
 {
@@ -141,7 +119,7 @@ static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 
 	options = (__be32 *)(greh + 1);
 	if (greh->flags & GRE_CSUM) {
-		if (check_checksum(skb)) {
+		if (skb_checksum_simple_validate(skb)) {
 			*csum_err = true;
 			return -EINVAL;
 		}
-- 
1.9.1.423.g4596e3a
