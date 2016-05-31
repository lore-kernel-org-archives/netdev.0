From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] udp: avoid csum_partial() for validated skb
Date: Tue, 31 May 2016 15:22:41 -0700
Message-ID: <1464733361.5939.130.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Sam Kumar <samanthakumar@google.com>,
	Willem de Bruijn <willemb@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33631 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752837AbcEaWWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 18:22:43 -0400
Received: by mail-pf0-f193.google.com with SMTP id b124so224082pfb.0
        for <netdev@vger.kernel.org>; Tue, 31 May 2016 15:22:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit e6afc8ace6dd5 ("udp: remove headers from UDP packets before
queueing"), udp_csum_pull_header() helper was added but missed fact
that CHECKSUM_UNNECESSARY packets were now converted to CHECKSUM_NONE
and skb->csum_valid was set to 1 for them.

Since csum_partial() is quite expensive, even for 8-byte area, it is
worth adding a test.

We also can use skb->data instead of udp_hdr() as we are pulling
UDP headers, as it is sightly faster.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/udp.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index ae07f375370da41271b839a272676ac970c3647e..8894d7144189935d4441fc2231edcb825dd7497e 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -160,8 +160,8 @@ void udp_set_csum(bool nocheck, struct sk_buff *skb,
 
 static inline void udp_csum_pull_header(struct sk_buff *skb)
 {
-	if (skb->ip_summed == CHECKSUM_NONE)
-		skb->csum = csum_partial(udp_hdr(skb), sizeof(struct udphdr),
+	if (!skb->csum_valid && skb->ip_summed == CHECKSUM_NONE)
+		skb->csum = csum_partial(skb->data, sizeof(struct udphdr),
 					 skb->csum);
 	skb_pull_rcsum(skb, sizeof(struct udphdr));
 	UDP_SKB_CB(skb)->cscov -= sizeof(struct udphdr);
