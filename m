From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 2/4] ip_gre: check packet length and mtu correctly in erspan_xmit
Date: Sun,  1 Oct 2017 22:00:54 +0800
Message-ID: <54a772dbf163eacd65d846054a63f8f7a87e318b.1506866059.git.lucien.xin@gmail.com>
References: <cover.1506866059.git.lucien.xin@gmail.com>
 <ef4c0ca4a1f0b6ae6eabda22fd9f55d0173fa862.1506866059.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Dmitry Kozlov <xeb@mail.ru>,
        William Tu <u9012063@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:37985 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750988AbdJAOBV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 10:01:21 -0400
Received: by mail-pf0-f194.google.com with SMTP id a7so3139962pfj.5
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 07:01:21 -0700 (PDT)
In-Reply-To: <ef4c0ca4a1f0b6ae6eabda22fd9f55d0173fa862.1506866059.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1506866059.git.lucien.xin@gmail.com>
References: <cover.1506866059.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As a ARPHRD_ETHER device, skb->len in erspan_xmit is the length
of the whole ether packet. So before checking if a packet size
exceeds the mtu, skb->len should subtract dev->hard_header_len.

Otherwise, all packets with max size according to mtu would be
trimmed to be truncated packet.

Fixes: 84e54fe0a5ea ("gre: introduce native tunnel support for ERSPAN")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv4/ip_gre.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index b25b1e5..2a4ef9d 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -731,7 +731,7 @@ static netdev_tx_t erspan_xmit(struct sk_buff *skb,
 	if (skb_cow_head(skb, dev->needed_headroom))
 		goto free_skb;
 
-	if (skb->len > dev->mtu) {
+	if (skb->len - dev->hard_header_len > dev->mtu) {
 		pskb_trim(skb, dev->mtu);
 		truncate = true;
 	}
-- 
2.1.0
