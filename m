From: Tom Herbert <therbert@google.com>
Subject: [PATCH 4/4] rps: Inspect GRE encapsulated packets to get flow hash
Date: Thu, 19 May 2011 08:39:30 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1105190827420.12804@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:5870 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932336Ab1ESPje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 11:39:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Crack open GRE packets in __skb_get_rxhash to compute 4-tuple hash on
in encapsulated packet.  Note that this is used only when the
__skb_get_rxhash is taken, in particular only when the device does
not compute provide the rxhash (ie. feature is disabled).

This was tested by creating a single GRE tunnel between two 16 core
AMD machines.  200 netperf TCP_RR streams were ran with 1 byte
request and response size.

Without patch: 157497 tps, 50/90/99% latencies 1250/1292/1364 usecs
With patch: 325896 tps, 50/90/99% latencies 603/848/1169

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/dev.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0c83494..7799bbd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2552,6 +2552,28 @@ again:
 	}
 
 	switch (ip_proto) {
+	case IPPROTO_GRE:
+		if (pskb_may_pull(skb, nhoff + 16)) {
+			u8 *h = skb->data + nhoff;
+			__be16 flags = *(__be16 *)h;
+
+			/*
+			 * Only look inside GRE if version zero and no
+			 * routing
+			 */
+			if (!(flags & (GRE_VERSION|GRE_ROUTING))) {
+				proto = *(__be16 *)(h + 2);
+				nhoff += 4;
+				if (flags & GRE_CSUM)
+					nhoff += 4;
+				if (flags & GRE_KEY)
+					nhoff += 4;
+				if (flags & GRE_SEQ)
+					nhoff += 4;
+				goto again;
+			}
+		}
+		break;
 	default:
 		break;
 	}
-- 
1.7.3.1

