From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 2/9] gre: Enforce IP ID verification on outer headers
Date: Fri, 18 Mar 2016 16:24:51 -0700
Message-ID: <20160318232451.14955.10778.stgit@localhost.localdomain>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: ecree@solarflare.com, netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34956 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125AbcCRXYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 19:24:53 -0400
Received: by mail-pf0-f182.google.com with SMTP id n5so186135382pfn.2
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 16:24:52 -0700 (PDT)
In-Reply-To: <20160318230945.14955.63211.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change enforces the IP ID verification on outer headers.  As a result
if the DF flag is not set on the outer header we will force the flow to be
flushed in the event that the IP ID is out of sequence with the existing
flow.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv4/gre_offload.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 540866dbd27d..7ea14ced9222 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -203,6 +203,20 @@ static struct sk_buff **gre_gro_receive(struct sk_buff **head,
 				continue;
 			}
 		}
+
+		/* Include the IP ID check from the outer IP hdr */
+		if (!NAPI_GRO_CB(p)->flush_id)
+			continue;
+
+		/* If flush_id is non-zero and rfc6864 is enabled for
+		 * the new frame the only possibility is that we are
+		 * incrementing so we can xor by count to cancel out
+		 * the one acceptable value.
+		 */
+		NAPI_GRO_CB(p)->flush |= NAPI_GRO_CB(skb)->rfc6864 ?
+					 NAPI_GRO_CB(p)->flush_id ^
+					 NAPI_GRO_CB(p)->count :
+					 NAPI_GRO_CB(p)->flush_id;
 	}
 
 	skb_gro_pull(skb, grehlen);
