From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 4/6] gre: Add support for checksum unnecessary conversions
Date: Sun, 31 Aug 2014 15:12:44 -0700
Message-ID: <1409523166-9215-5-git-send-email-therbert@google.com>
References: <1409523166-9215-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:42682 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbaHaWN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2014 18:13:26 -0400
Received: by mail-pa0-f42.google.com with SMTP id lf10so10750392pab.29
        for <netdev@vger.kernel.org>; Sun, 31 Aug 2014 15:13:26 -0700 (PDT)
In-Reply-To: <1409523166-9215-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call skb_checksum_try_convert and skb_gro_checksum_try_convert
after checksum is found present and validated in the GRE header
for normal and GRO paths respectively.

In GRO path, call skb_gro_checksum_try_convert

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/gre_demux.c   | 4 ++++
 net/ipv4/gre_offload.c | 8 ++++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index 0485bf7..7e0756d 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -125,6 +125,10 @@ static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 			*csum_err = true;
 			return -EINVAL;
 		}
+
+		skb_checksum_try_convert(skb, IPPROTO_GRE, 0,
+					 null_compute_pseudo);
+
 		options++;
 	}
 
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index a4d7965..d3fe2ac 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -172,10 +172,14 @@ static struct sk_buff **gre_gro_receive(struct sk_buff **head,
 	}
 
 	/* Don't bother verifying checksum if we're going to flush anyway. */
-	if ((greh->flags & GRE_CSUM) && !NAPI_GRO_CB(skb)->flush &&
-	    skb_gro_checksum_simple_validate(skb))
+	if ((greh->flags & GRE_CSUM) && !NAPI_GRO_CB(skb)->flush) {
+		if (skb_gro_checksum_simple_validate(skb))
 			goto out_unlock;
 
+		skb_gro_checksum_try_convert(skb, IPPROTO_GRE, 0,
+					     null_compute_pseudo);
+	}
+
 	flush = 0;
 
 	for (p = *head; p; p = p->next) {
-- 
2.1.0.rc2.206.gedb03e5
