From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 5/6] flow_dissector: Include GRE keyid in hash computation
Date: Fri, 27 Feb 2015 19:11:48 -0800
Message-ID: <1425093109-1077-6-git-send-email-therbert@google.com>
References: <1425093109-1077-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:34705 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbbB1DNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 22:13:00 -0500
Received: by igal13 with SMTP id l13so4881558iga.1
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 19:13:00 -0800 (PST)
In-Reply-To: <1425093109-1077-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If keyid is present include that in hash_extra in flow_keys when
dissecting. This will then be included in hash computation.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/flow_dissector.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index b11eec1..e04946f 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -219,8 +219,21 @@ ipv6:
 			nhoff += 4;
 			if (hdr->flags & GRE_CSUM)
 				nhoff += 4;
-			if (hdr->flags & GRE_KEY)
+			if (hdr->flags & GRE_KEY) {
+				const __be32 *keyid;
+				__be32 _keyid;
+
+				keyid = __skb_header_pointer(skb, nhoff,
+							     sizeof(_keyid),
+							     data, hlen,
+							     &_keyid);
+				if (!keyid)
+					return false;
+
+				flow->hash_extra ^= *keyid;
+
 				nhoff += 4;
+			}
 			if (hdr->flags & GRE_SEQ)
 				nhoff += 4;
 			if (proto == htons(ETH_P_TEB)) {
-- 
2.2.0.rc0.207.ga3a616c
