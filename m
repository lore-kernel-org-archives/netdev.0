From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net] tun_dst: Fix potential NULL dereference
Date: Wed,  4 Nov 2015 13:49:49 +0100
Message-ID: <1446641389-26183-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:54673 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750914AbbKDMtw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2015 07:49:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tun_dst_unclone() the return value of skb_metadata_dst() is checked
for being NULL after it is dereferenced. Fix this by moving the
dereference after the NULL check.

Found by the Coverity scanner (CID 1338068).

Fixes: fc4099f17240 ("openvswitch: Fix egress tunnel info.")
Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 include/net/dst_metadata.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index ce00971..6816f0f 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -63,12 +63,13 @@ static inline struct metadata_dst *tun_rx_dst(int md_size)
 static inline struct metadata_dst *tun_dst_unclone(struct sk_buff *skb)
 {
 	struct metadata_dst *md_dst = skb_metadata_dst(skb);
-	int md_size = md_dst->u.tun_info.options_len;
+	int md_size;
 	struct metadata_dst *new_md;
 
 	if (!md_dst)
 		return ERR_PTR(-EINVAL);
 
+	md_size = md_dst->u.tun_info.options_len;
 	new_md = metadata_dst_alloc(md_size, GFP_ATOMIC);
 	if (!new_md)
 		return ERR_PTR(-ENOMEM);
-- 
2.6.1.148.g7927db1
