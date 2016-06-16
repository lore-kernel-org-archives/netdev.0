From: Abdelrhman Ahmed <ab@abahmed.com>
Subject: [PATCH] net: Fix skb_network_offset in neigh_resolve_output and
 neigh_connected_output
Date: Thu, 16 Jun 2016 08:50:21 +0200
Message-ID: <57624C2D.8020906@abahmed.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender163-mail.zoho.com ([74.201.84.163]:24505 "EHLO
	sender163-mail.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbcFPGub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 02:50:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e1f165032c8bade3a6bdf546f8faf61fda4dd01c ("net: Fix 
skb_under_panic oops in neigh_resolve_output") resets the skb to 
network_header, but this will discard header or data which is inserted 
by netfilter hooks (e.g. POSTROUTING) between network layer and hardware 
header only for the first packet(s) before using cached hardware header 
and this will lead to inconsistent behavior for outgoing packets.
The fix is to reset with reference to skb's data pointer before loop 
instead of network header.

Signed-off-by: Abdelrhman Ahmed <ab@abahmed.com>
--- net/core/neighbour.c.orig    2016-06-16 05:52:26.521301488 +0200
+++ net/core/neighbour.c    2016-06-16 08:09:54.577222828 +0200
@@ -1293,15 +1293,19 @@ int neigh_resolve_output(struct neighbou
      int rc = 0;

      if (!neigh_event_send(neigh, skb)) {
-        int err;
+        int err, offset;
          struct net_device *dev = neigh->dev;
+        unsigned char *data;
          unsigned int seq;

          if (dev->header_ops->cache && !neigh->hh.hh_len)
              neigh_hh_init(neigh);

+        data = skb->data;
+
          do {
-            __skb_pull(skb, skb_network_offset(skb));
+            offset = data - skb->data;
+            __skb_pull(skb, offset);
              seq = read_seqbegin(&neigh->ha_lock);
              err = dev_hard_header(skb, dev, ntohs(skb->protocol),
                            neigh->ha, NULL, skb->len);
@@ -1326,11 +1330,15 @@ EXPORT_SYMBOL(neigh_resolve_output);
  int neigh_connected_output(struct neighbour *neigh, struct sk_buff *skb)
  {
      struct net_device *dev = neigh->dev;
+    unsigned char *data;
      unsigned int seq;
-    int err;
+    int err, offset;
+
+    data = skb->data;

      do {
-        __skb_pull(skb, skb_network_offset(skb));
+        offset = data - skb->data;
+        __skb_pull(skb, offset);
          seq = read_seqbegin(&neigh->ha_lock);
          err = dev_hard_header(skb, dev, ntohs(skb->protocol),
                        neigh->ha, NULL, skb->len);

-- 
Regards,
Abdelrhman
