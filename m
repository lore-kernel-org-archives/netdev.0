From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH v3 net 2/2] net: skbuff: Limit skb_vlan_pop/push() to expect skb->data at mac header
Date: Thu, 29 Sep 2016 12:10:41 +0300
Message-ID: <1475140241-23586-2-git-send-email-shmulik.ladkani@gmail.com>
References: <1475140241-23586-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Pravin Shelar <pshelar@ovn.org>, Jiri Pirko <jiri@mellanox.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34130 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933484AbcI2JLI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 05:11:08 -0400
Received: by mail-wm0-f66.google.com with SMTP id w72so1054156wmf.1
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 02:11:07 -0700 (PDT)
In-Reply-To: <1475140241-23586-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_vlan_pop/push were too generic, trying to support the cases where
skb->data is at mac header, and cases where skb->data is arbitrarily
elsewhere.

Supporting an arbitrary skb->data was complex and bogus:
 - It failed to unwind skb->data to its original location post actual
   pop/push.
   (Also, semantic is not well defined for unwinding: If data was into
    the eth header, need to use same offset from start; But if data was
    at network header or beyond, need to adjust the original offset
    according to the push/pull)
 - It mangled the rcsum post actual push/pop, without taking into account
   that the eth bytes might already have been pulled out of the csum.

Most callers (ovs, bpf) already had their skb->data at mac_header upon
invoking skb_vlan_pop/push.
Last caller that failed to do so (act_vlan) has been recently fixed.

Therefore, to simplify things, no longer support arbitrary skb->data
inputs for skb_vlan_pop/push().

skb->data is expected to be exactly at mac_header; WARN otherwise.

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Pravin Shelar <pshelar@ovn.org>
Cc: Jiri Pirko <jiri@mellanox.com>
---
 v3: Instead of correcting unwinding of skb->data in skb_vlan_pop/push,
     just kill the support for arbitraray skb->data inputs, and assume
     given skb->data always points at mac_header.
     Fix act_vlan, the sole user not adehering to this assumption.

 v2: Instead of reducing mac_len by 4 bytes, which was found incorrect,
     fix the problem of wrong unwinding of 'skb->data'

 net/core/skbuff.c | 37 ++++++++++++++++++++++---------------
 1 file changed, 22 insertions(+), 15 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3864b4b68f..8c38263cdf 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4478,13 +4478,18 @@ EXPORT_SYMBOL(skb_ensure_writable);
 static int __skb_vlan_pop(struct sk_buff *skb, u16 *vlan_tci)
 {
 	struct vlan_hdr *vhdr;
-	unsigned int offset = skb->data - skb_mac_header(skb);
+	int offset = skb->data - skb_mac_header(skb);
 	int err;
 
-	__skb_push(skb, offset);
+	if (WARN_ONCE(offset,
+		      "__skb_vlan_pop got skb with skb->data not at mac header (offset %d)\n",
+		      offset)) {
+		return -EINVAL;
+	}
+
 	err = skb_ensure_writable(skb, VLAN_ETH_HLEN);
 	if (unlikely(err))
-		goto pull;
+		return err;
 
 	skb_postpull_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
 
@@ -4501,12 +4506,13 @@ static int __skb_vlan_pop(struct sk_buff *skb, u16 *vlan_tci)
 		skb_set_network_header(skb, ETH_HLEN);
 
 	skb_reset_mac_len(skb);
-pull:
-	__skb_pull(skb, offset);
 
 	return err;
 }
 
+/* Pop a vlan tag either from hwaccel or from payload.
+ * Expects skb->data at mac header.
+ */
 int skb_vlan_pop(struct sk_buff *skb)
 {
 	u16 vlan_tci;
@@ -4541,29 +4547,30 @@ int skb_vlan_pop(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(skb_vlan_pop);
 
+/* Push a vlan tag either into hwaccel or into payload (if hwaccel tag present).
+ * Expects skb->data at mac header.
+ */
 int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci)
 {
 	if (skb_vlan_tag_present(skb)) {
-		unsigned int offset = skb->data - skb_mac_header(skb);
+		int offset = skb->data - skb_mac_header(skb);
 		int err;
 
-		/* __vlan_insert_tag expect skb->data pointing to mac header.
-		 * So change skb->data before calling it and change back to
-		 * original position later
-		 */
-		__skb_push(skb, offset);
+		if (WARN_ONCE(offset,
+			      "skb_vlan_push got skb with skb->data not at mac header (offset %d)\n",
+			      offset)) {
+			return -EINVAL;
+		}
+
 		err = __vlan_insert_tag(skb, skb->vlan_proto,
 					skb_vlan_tag_get(skb));
-		if (err) {
-			__skb_pull(skb, offset);
+		if (err)
 			return err;
-		}
 
 		skb->protocol = skb->vlan_proto;
 		skb->mac_len += VLAN_HLEN;
 
 		skb_postpush_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
-		__skb_pull(skb, offset);
 	}
 	__vlan_hwaccel_put_tag(skb, vlan_proto, vlan_tci);
 	return 0;
-- 
2.7.4
