From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 1/4] gre: Enforce IP ID verification on outer
 headers
Date: Mon, 07 Mar 2016 09:22:01 -0800
Message-ID: <20160307172201.5295.69740.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33785 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbcCGRWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 12:22:08 -0500
Received: by mail-pa0-f42.google.com with SMTP id fl4so81702385pad.0
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 09:22:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change enforces the IP ID verification on outer headers.  As a result
if the DF flag is not set on the outer header we will force the flow to be
flushed in the event that the IP ID is out of sequence with the existing
flow.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv4/gre_offload.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 47f4c544c916..632733f18019 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -175,8 +175,6 @@ static struct sk_buff **gre_gro_receive(struct sk_buff **head,
 					     null_compute_pseudo);
 	}
 
-	flush = 0;
-
 	for (p = *head; p; p = p->next) {
 		const struct gre_base_hdr *greh2;
 
@@ -205,6 +203,9 @@ static struct sk_buff **gre_gro_receive(struct sk_buff **head,
 				continue;
 			}
 		}
+
+		/* Include the IP ID check from the outer IP hdr */
+		NAPI_GRO_CB(p)->flush |= NAPI_GRO_CB(p)->flush_id;
 	}
 
 	skb_gro_pull(skb, grehlen);
@@ -213,6 +214,7 @@ static struct sk_buff **gre_gro_receive(struct sk_buff **head,
 	skb_gro_postpull_rcsum(skb, greh, grehlen);
 
 	pp = ptype->callbacks.gro_receive(head, skb);
+	flush = 0;
 
 out_unlock:
 	rcu_read_unlock();
