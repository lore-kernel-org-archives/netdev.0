From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH] udp: Fix inverted NAPI_GRO_CB(skb)->flush test
Date: Wed, 10 Sep 2014 21:23:18 -0500
Message-ID: <1410402198-30811-1-git-send-email-scottwood@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Scott Wood <scottwood@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0112.outbound.protection.outlook.com ([157.56.110.112]:5441
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751596AbaIKD5s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 23:57:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 2abb7cdc0d ("udp: Add support for doing checksum unnecessary
conversion") caused napi_gro_cb structs with the "flush" field zero to
take the "udp_gro_receive" path rather than the "set flush to 1" path
that they would previously take.  As a result I saw booting from an NFS
root hang shortly after starting userspace, with "server not
responding" messages.

This change to the handling of "flush == 0" packets appears to be
incidental to the goal of adding new code in the case where
skb_gro_checksum_validate_zero_check() returns zero.  Based on that and
the fact that it breaks things, I'm assuming that it is unintentional.

Fixes: 2abb7cdc0d ("udp: Add support for doing checksum unnecessary conversion")
Cc: Tom Herbert <therbert@google.com>
Signed-off-by: Scott Wood <scottwood@freescale.com>
---
 net/ipv4/udp_offload.c | 2 +-
 net/ipv6/udp_offload.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 84e0e05..b8c845a 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -294,7 +294,7 @@ static struct sk_buff **udp4_gro_receive(struct sk_buff **head,
 		goto flush;
 
 	/* Don't bother verifying checksum if we're going to flush anyway. */
-	if (!NAPI_GRO_CB(skb)->flush)
+	if (NAPI_GRO_CB(skb)->flush)
 		goto skip;
 
 	if (skb_gro_checksum_validate_zero_check(skb, IPPROTO_UDP, uh->check,
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 89cb9a9..2907fb8 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -138,7 +138,7 @@ static struct sk_buff **udp6_gro_receive(struct sk_buff **head,
 		goto flush;
 
 	/* Don't bother verifying checksum if we're going to flush anyway. */
-	if (!NAPI_GRO_CB(skb)->flush)
+	if (NAPI_GRO_CB(skb)->flush)
 		goto skip;
 
 	if (skb_gro_checksum_validate_zero_check(skb, IPPROTO_UDP, uh->check,
-- 
1.9.1
