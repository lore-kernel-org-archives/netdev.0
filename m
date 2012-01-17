From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 net] net: WARN if skb_checksum_help() is called on skb
 requiring segmentation
Date: Tue, 17 Jan 2012 17:57:56 +0000
Message-ID: <1326823076.2478.19.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:33906 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752481Ab2AQR6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 12:58:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_checksum_help() has never done anything useful with skbs that
require segmentation.  Setting skb->ip_summed = CHECKSUM_NONE makes
them invalid and provokes a later WARNing in skb_gso_segment().

Passing such an skb to skb_checksum_help() indicates a bug, so we
should warn about it immediately.  Move the warning from
skb_gso_segment() into a shared function, and add gso_type and
gso_size to it.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/core/dev.c |   31 +++++++++++++++++++------------
 1 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7e6b7dc..17db2f2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1887,6 +1887,22 @@ void skb_set_dev(struct sk_buff *skb, struct net_device *dev)
 EXPORT_SYMBOL(skb_set_dev);
 #endif /* CONFIG_NET_NS */
 
+static void skb_warn_bad_offload(const struct sk_buff *skb)
+{
+	struct net_device *dev = skb->dev;
+	const char *driver = "";
+
+	if (dev && dev->dev.parent)
+		driver = dev_driver_string(dev->dev.parent);
+
+	WARN(1, "%s: caps=(%pNF, %pNF) len=%d data_len=%d gso_size=%d "
+	     "gso_type=%d ip_summed=%d\n",
+	     driver, dev ? &dev->features : NULL,
+	     skb->sk ? &skb->sk->sk_route_caps : NULL,
+	     skb->len, skb->data_len, skb_shinfo(skb)->gso_size,
+	     skb_shinfo(skb)->gso_type, skb->ip_summed);
+}
+
 /*
  * Invalidate hardware checksum when packet is to be mangled, and
  * complete checksum manually on outgoing path.
@@ -1900,8 +1916,8 @@ int skb_checksum_help(struct sk_buff *skb)
 		goto out_set_summed;
 
 	if (unlikely(skb_shinfo(skb)->gso_size)) {
-		/* Let GSO fix up the checksum. */
-		goto out_set_summed;
+		skb_warn_bad_offload(skb);
+		return -EINVAL;
 	}
 
 	offset = skb_checksum_start_offset(skb);
@@ -1961,16 +1977,7 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb,
 	__skb_pull(skb, skb->mac_len);
 
 	if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
-		struct net_device *dev = skb->dev;
-		const char *driver = "";
-
-		if (dev && dev->dev.parent)
-			driver = dev_driver_string(dev->dev.parent);
-
-		WARN(1, "%s: caps=(%pNF, %pNF) len=%d data_len=%d ip_summed=%d\n",
-		     driver, dev ? &dev->features : NULL,
-		     skb->sk ? &skb->sk->sk_route_caps : NULL,
-		     skb->len, skb->data_len, skb->ip_summed);
+		skb_warn_bad_offload(skb);
 
 		if (skb_header_cloned(skb) &&
 		    (err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
-- 
1.7.7.5


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
