From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: sctp gso should set feature with NETIF_F_SG when calling skb_segment
Date: Tue, 24 Jan 2017 14:05:16 +0800
Message-ID: <7b4d081c051650e706ffda360fdfbd4baaa1a317.1485237916.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34984 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdAXGFX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 01:05:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now sctp gso puts segments into skb's frag_list, then processes these
segments in skb_segment. But skb_segment handles them only when gs is
enabled, as it's in the same branch with skb's frags.

Although almost all the NICs support sg other than some old ones, but
since commit 1e16aa3ddf86 ("net: gso: use feature flag argument in all
protocol gso handlers"), features &= skb->dev->hw_enc_features, and
xfrm_output_gso call skb_segment with features = 0, which means sctp
gso would call skb_segment with sg = 0, and skb_segment would not work
as expected.

This patch is to fix it by setting features param with NETIF_F_SG when
calling skb_segment so that it can go the right branch to process the
skb's frag_list.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/offload.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/offload.c b/net/sctp/offload.c
index 7e869d0..4f5a2b5 100644
--- a/net/sctp/offload.c
+++ b/net/sctp/offload.c
@@ -68,7 +68,7 @@ static struct sk_buff *sctp_gso_segment(struct sk_buff *skb,
 		goto out;
 	}
 
-	segs = skb_segment(skb, features | NETIF_F_HW_CSUM);
+	segs = skb_segment(skb, features | NETIF_F_HW_CSUM | NETIF_F_SG);
 	if (IS_ERR(segs))
 		goto out;
 
-- 
2.1.0
