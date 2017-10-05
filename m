From: William Tu <u9012063@gmail.com>
Subject: [net-next,v2] ip_gre: check packet length and mtu correctly in erspan tx
Date: Thu,  5 Oct 2017 12:07:12 -0700
Message-ID: <1507230432-56495-1-git-send-email-u9012063@gmail.com>
Cc: Xin Long <lucien.xin@gmail.com>,
        David Laight <David.Laight@aculab.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33181 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751369AbdJEWJF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 18:09:05 -0400
Received: by mail-pf0-f194.google.com with SMTP id m28so15274399pfi.0
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 15:09:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly to early patch for erspan_xmit(), the ARPHDR_ETHER device
is the length of the whole ether packet.  So skb->len should subtract
the dev->hard_header_len.

Fixes: 1a66a836da63 ("gre: add collect_md mode to ERSPAN tunnel")
Fixes: 84e54fe0a5ea ("gre: introduce native tunnel support for ERSPAN")
Signed-off-by: William Tu <u9012063@gmail.com>
Cc: Xin Long <lucien.xin@gmail.com>
Cc: David Laight <David.Laight@aculab.com>
---
v1->v2:
use addition to avoid overflow
fix pskb_trim size 
---
 net/ipv4/ip_gre.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index b279c325c7f6..fb95f68d6e53 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -579,8 +579,8 @@ static void erspan_fb_xmit(struct sk_buff *skb, struct net_device *dev,
 	if (gre_handle_offloads(skb, false))
 		goto err_free_rt;
 
-	if (skb->len > dev->mtu) {
-		pskb_trim(skb, dev->mtu);
+	if (skb->len > dev->mtu + dev->hard_header_len) {
+		pskb_trim(skb, dev->mtu + dev->hard_header_len);
 		truncate = true;
 	}
 
@@ -731,8 +731,8 @@ static netdev_tx_t erspan_xmit(struct sk_buff *skb,
 	if (skb_cow_head(skb, dev->needed_headroom))
 		goto free_skb;
 
-	if (skb->len - dev->hard_header_len > dev->mtu) {
-		pskb_trim(skb, dev->mtu);
+	if (skb->len > dev->mtu + dev->hard_header_len) {
+		pskb_trim(skb, dev->mtu + dev->hard_header_len);
 		truncate = true;
 	}
 
-- 
2.7.4
