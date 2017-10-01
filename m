From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 1/4] ip_gre: get key from session_id correctly in erspan_rcv
Date: Sun,  1 Oct 2017 22:00:53 +0800
Message-ID: <ef4c0ca4a1f0b6ae6eabda22fd9f55d0173fa862.1506866059.git.lucien.xin@gmail.com>
References: <cover.1506866059.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Dmitry Kozlov <xeb@mail.ru>,
        William Tu <u9012063@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33178 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751072AbdJAOBN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 10:01:13 -0400
Received: by mail-pf0-f193.google.com with SMTP id m28so3009467pfi.0
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 07:01:13 -0700 (PDT)
In-Reply-To: <cover.1506866059.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1506866059.git.lucien.xin@gmail.com>
References: <cover.1506866059.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

erspan only uses the first 10 bits of session_id as the key to look
up the tunnel. But in erspan_rcv, it missed 'session_id & ID_MASK'
when getting the key from session_id.

If any other flag is also set in session_id in a packet, it would
fail to find the tunnel due to incorrect key in erspan_rcv.

This patch is to add 'session_id & ID_MASK' there and also remove
the unnecessary variable session_id.

Fixes: 84e54fe0a5ea ("gre: introduce native tunnel support for ERSPAN")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv4/ip_gre.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 8b837f6..b25b1e5 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -259,7 +259,6 @@ static int erspan_rcv(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 	struct ip_tunnel *tunnel;
 	struct erspanhdr *ershdr;
 	const struct iphdr *iph;
-	__be32 session_id;
 	__be32 index;
 	int len;
 
@@ -275,8 +274,7 @@ static int erspan_rcv(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 	/* The original GRE header does not have key field,
 	 * Use ERSPAN 10-bit session ID as key.
 	 */
-	session_id = cpu_to_be32(ntohs(ershdr->session_id));
-	tpi->key = session_id;
+	tpi->key = cpu_to_be32(ntohs(ershdr->session_id) & ID_MASK);
 	index = ershdr->md.index;
 	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex,
 				  tpi->flags | TUNNEL_KEY,
-- 
2.1.0
