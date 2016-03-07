From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 3/4] vxlan: Enforce IP ID verification on outer
 headers
Date: Mon, 07 Mar 2016 09:22:14 -0800
Message-ID: <20160307172214.5295.52624.stgit@localhost.localdomain>
References: <20160307172201.5295.69740.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34455 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752876AbcCGRWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 12:22:16 -0500
Received: by mail-pa0-f52.google.com with SMTP id fy10so81615425pac.1
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 09:22:16 -0800 (PST)
In-Reply-To: <20160307172201.5295.69740.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change enforces the IP ID verification on outer headers.  As a result
if the DF flag is not set on the outer header we will force the flow to be
flushed in the event that the IP ID is out of sequence with the existing
flow.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/vxlan.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 775ddb48388d..906587d1531a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -591,8 +591,6 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head,
 
 	skb_gro_pull(skb, sizeof(struct vxlanhdr)); /* pull vxlan header */
 
-	flush = 0;
-
 	for (p = *head; p; p = p->next) {
 		if (!NAPI_GRO_CB(p)->same_flow)
 			continue;
@@ -603,10 +601,13 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head,
 			NAPI_GRO_CB(p)->same_flow = 0;
 			continue;
 		}
+
+		/* Include the IP ID check from the outer IP hdr */
+		NAPI_GRO_CB(p)->flush |= NAPI_GRO_CB(p)->flush_id;
 	}
 
 	pp = eth_gro_receive(head, skb);
-
+	flush = 0;
 out:
 	skb_gro_remcsum_cleanup(skb, &grc);
 	NAPI_GRO_CB(skb)->flush |= flush;
