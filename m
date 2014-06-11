From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 3/3] net: Add skb_gro_postpull_rcsum to udp and vxlan
Date: Tue, 10 Jun 2014 18:54:26 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406101849110.5835@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:58590 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753119AbaFKBy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 21:54:27 -0400
Received: by mail-yh0-f74.google.com with SMTP id 29so1098889yhl.5
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 18:54:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to gro_postpull_rcsum for GRO to work with checksum complete.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c    | 2 ++
 net/ipv4/udp_offload.c | 1 +
 2 files changed, 3 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 4e2caaf..1610d51 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -565,6 +565,7 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head, struct sk_buff
 			goto out;
 	}
 	skb_gro_pull(skb, sizeof(struct vxlanhdr)); /* pull vxlan header */
+	skb_gro_postpull_rcsum(skb, vh, sizeof(struct vxlanhdr));
 
 	off_eth = skb_gro_offset(skb);
 	hlen = off_eth + sizeof(*eh);
@@ -599,6 +600,7 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head, struct sk_buff
 	}
 
 	skb_gro_pull(skb, sizeof(*eh)); /* pull inner eth header */
+	skb_gro_postpull_rcsum(skb, eh, sizeof(*eh));
 	pp = ptype->callbacks.gro_receive(head, skb);
 
 out_unlock:
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 7b18401..546d2d4 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -200,6 +200,7 @@ unflush:
 	}
 
 	skb_gro_pull(skb, sizeof(struct udphdr)); /* pull encapsulating udp header */
+	skb_gro_postpull_rcsum(skb, uh, sizeof(struct udphdr));
 	pp = uo_priv->offload->callbacks.gro_receive(head, skb);
 
 out_unlock:
-- 
2.0.0.526.g5318336
