From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 2/4] geneve: Enforce IP ID verification on outer
 headers
Date: Mon, 07 Mar 2016 09:22:08 -0800
Message-ID: <20160307172208.5295.19163.stgit@localhost.localdomain>
References: <20160307172201.5295.69740.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:32810 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506AbcCGRWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 12:22:10 -0500
Received: by mail-pa0-f45.google.com with SMTP id fl4so81703681pad.0
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 09:22:09 -0800 (PST)
In-Reply-To: <20160307172201.5295.69740.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change enforces the IP ID verification on outer headers.  As a result
if the DF flag is not set on the outer header we will force the flow to be
flushed in the event that the IP ID is out of sequence with the existing
flow.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/geneve.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index bc5da357e16d..f4b89b73517e 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -462,8 +462,6 @@ static struct sk_buff **geneve_gro_receive(struct sk_buff **head,
 			goto out;
 	}
 
-	flush = 0;
-
 	for (p = *head; p; p = p->next) {
 		if (!NAPI_GRO_CB(p)->same_flow)
 			continue;
@@ -474,20 +472,23 @@ static struct sk_buff **geneve_gro_receive(struct sk_buff **head,
 			NAPI_GRO_CB(p)->same_flow = 0;
 			continue;
 		}
+
+		/* Include the IP ID check from the outer IP hdr */
+		NAPI_GRO_CB(p)->flush |= NAPI_GRO_CB(p)->flush_id;
 	}
 
 	type = gh->proto_type;
 
 	rcu_read_lock();
 	ptype = gro_find_receive_by_type(type);
-	if (!ptype) {
-		flush = 1;
+	if (!ptype)
 		goto out_unlock;
-	}
 
 	skb_gro_pull(skb, gh_len);
 	skb_gro_postpull_rcsum(skb, gh, gh_len);
+
 	pp = ptype->callbacks.gro_receive(head, skb);
+	flush = 0;
 
 out_unlock:
 	rcu_read_unlock();
