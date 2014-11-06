From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 14/14] openvswitch: Avoid NULL mask check while building mask
Date: Thu,  6 Nov 2014 01:19:53 -0800
Message-ID: <1415265593-1930-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:38528 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752022AbaKFJTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 04:19:55 -0500
Received: by mail-pd0-f173.google.com with SMTP id v10so800335pde.4
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 01:19:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OVS does mask validation even if it does not need to convert
netlink mask attributes to mask structure.  ovs_nla_get_match()
caller can pass NULL mask structure pointer if the caller does
not need mask.  Therefore NULL check is required in SW_FLOW_KEY*
macros.  Following patch does not convert mask netlink attributes
if mask pointer is NULL, so we do not need these checks in
SW_FLOW_KEY* macro.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Acked-by: Daniele Di Proietto <ddiproietto@vmware.com>
Acked-by: Andy Zhou <azhou@nicira.com>
---
 net/openvswitch/flow_netlink.c | 107 ++++++++++++++++++++---------------------
 1 file changed, 53 insertions(+), 54 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 482a0cb..ed31097 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -50,21 +50,18 @@
 
 #include "flow_netlink.h"
 
-static void update_range__(struct sw_flow_match *match,
-			   size_t offset, size_t size, bool is_mask)
+static void update_range(struct sw_flow_match *match,
+			 size_t offset, size_t size, bool is_mask)
 {
-	struct sw_flow_key_range *range = NULL;
+	struct sw_flow_key_range *range;
 	size_t start = rounddown(offset, sizeof(long));
 	size_t end = roundup(offset + size, sizeof(long));
 
 	if (!is_mask)
 		range = &match->range;
-	else if (match->mask)
+	else
 		range = &match->mask->range;
 
-	if (!range)
-		return;
-
 	if (range->start == range->end) {
 		range->start = start;
 		range->end = end;
@@ -80,22 +77,20 @@ static void update_range__(struct sw_flow_match *match,
 
 #define SW_FLOW_KEY_PUT(match, field, value, is_mask) \
 	do { \
-		update_range__(match, offsetof(struct sw_flow_key, field),  \
-				     sizeof((match)->key->field), is_mask); \
-		if (is_mask) {						    \
-			if ((match)->mask)				    \
-				(match)->mask->key.field = value;	    \
-		} else {                                                    \
+		update_range(match, offsetof(struct sw_flow_key, field),    \
+			     sizeof((match)->key->field), is_mask);	    \
+		if (is_mask)						    \
+			(match)->mask->key.field = value;		    \
+		else							    \
 			(match)->key->field = value;		            \
-		}                                                           \
 	} while (0)
 
 #define SW_FLOW_KEY_MEMCPY_OFFSET(match, offset, value_p, len, is_mask)	    \
 	do {								    \
-		update_range__(match, offset, len, is_mask);		    \
+		update_range(match, offset, len, is_mask);		    \
 		if (is_mask)						    \
 			memcpy((u8 *)&(match)->mask->key + offset, value_p, \
-			       len);					    \
+			       len);					   \
 		else							    \
 			memcpy((u8 *)(match)->key + offset, value_p, len);  \
 	} while (0)
@@ -104,18 +99,16 @@ static void update_range__(struct sw_flow_match *match,
 	SW_FLOW_KEY_MEMCPY_OFFSET(match, offsetof(struct sw_flow_key, field), \
 				  value_p, len, is_mask)
 
-#define SW_FLOW_KEY_MEMSET_FIELD(match, field, value, is_mask) \
-	do { \
-		update_range__(match, offsetof(struct sw_flow_key, field),  \
-				     sizeof((match)->key->field), is_mask); \
-		if (is_mask) {						    \
-			if ((match)->mask)				    \
-				memset((u8 *)&(match)->mask->key.field, value,\
-				       sizeof((match)->mask->key.field));   \
-		} else {                                                    \
+#define SW_FLOW_KEY_MEMSET_FIELD(match, field, value, is_mask)		    \
+	do {								    \
+		update_range(match, offsetof(struct sw_flow_key, field),    \
+			     sizeof((match)->key->field), is_mask);	    \
+		if (is_mask)						    \
+			memset((u8 *)&(match)->mask->key.field, value,      \
+			       sizeof((match)->mask->key.field));	    \
+		else							    \
 			memset((u8 *)&(match)->key->field, value,           \
 			       sizeof((match)->key->field));                \
-		}                                                           \
 	} while (0)
 
 static bool match_validate(const struct sw_flow_match *match,
@@ -677,8 +670,7 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
 
 		SW_FLOW_KEY_PUT(match, eth.tci, tci, is_mask);
 		attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
-	} else if (!is_mask)
-		SW_FLOW_KEY_PUT(match, eth.tci, htons(0xffff), true);
+	}
 
 	if (attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) {
 		__be16 eth_type;
@@ -903,8 +895,8 @@ static void mask_set_nlattr(struct nlattr *attr, u8 val)
  * attribute specifies the mask field of the wildcarded flow.
  */
 int ovs_nla_get_match(struct sw_flow_match *match,
-		      const struct nlattr *key,
-		      const struct nlattr *mask)
+		      const struct nlattr *nla_key,
+		      const struct nlattr *nla_mask)
 {
 	const struct nlattr *a[OVS_KEY_ATTR_MAX + 1];
 	const struct nlattr *encap;
@@ -914,7 +906,7 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 	bool encap_valid = false;
 	int err;
 
-	err = parse_flow_nlattrs(key, a, &key_attrs);
+	err = parse_flow_nlattrs(nla_key, a, &key_attrs);
 	if (err)
 		return err;
 
@@ -955,36 +947,43 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 	if (err)
 		return err;
 
-	if (match->mask && !mask) {
-		/* Create an exact match mask. We need to set to 0xff all the
-		 * 'match->mask' fields that have been touched in 'match->key'.
-		 * We cannot simply memset 'match->mask', because padding bytes
-		 * and fields not specified in 'match->key' should be left to 0.
-		 * Instead, we use a stream of netlink attributes, copied from
-		 * 'key' and set to 0xff: ovs_key_from_nlattrs() will take care
-		 * of filling 'match->mask' appropriately.
-		 */
-		newmask = kmemdup(key, nla_total_size(nla_len(key)),
-				  GFP_KERNEL);
-		if (!newmask)
-			return -ENOMEM;
+	if (match->mask) {
+		if (!nla_mask) {
+			/* Create an exact match mask. We need to set to 0xff
+			 * all the 'match->mask' fields that have been touched
+			 * in 'match->key'. We cannot simply memset
+			 * 'match->mask', because padding bytes and fields not
+			 * specified in 'match->key' should be left to 0.
+			 * Instead, we use a stream of netlink attributes,
+			 * copied from 'key' and set to 0xff.
+			 * ovs_key_from_nlattrs() will take care of filling
+			 * 'match->mask' appropriately.
+			 */
+			newmask = kmemdup(nla_key,
+					  nla_total_size(nla_len(nla_key)),
+					  GFP_KERNEL);
+			if (!newmask)
+				return -ENOMEM;
 
-		mask_set_nlattr(newmask, 0xff);
+			mask_set_nlattr(newmask, 0xff);
 
-		/* The userspace does not send tunnel attributes that are 0,
-		 * but we should not wildcard them nonetheless.
-		 */
-		if (match->key->tun_key.ipv4_dst)
-			SW_FLOW_KEY_MEMSET_FIELD(match, tun_key, 0xff, true);
+			/* The userspace does not send tunnel attributes that
+			 * are 0, but we should not wildcard them nonetheless.
+			 */
+			if (match->key->tun_key.ipv4_dst)
+				SW_FLOW_KEY_MEMSET_FIELD(match, tun_key,
+							 0xff, true);
 
-		mask = newmask;
-	}
+			nla_mask = newmask;
+		}
 
-	if (mask) {
-		err = parse_flow_mask_nlattrs(mask, a, &mask_attrs);
+		err = parse_flow_mask_nlattrs(nla_mask, a, &mask_attrs);
 		if (err)
 			goto free_newmask;
 
+		/* Always match on tci. */
+		SW_FLOW_KEY_PUT(match, eth.tci, htons(0xffff), true);
+
 		if (mask_attrs & 1 << OVS_KEY_ATTR_ENCAP) {
 			__be16 eth_type = 0;
 			__be16 tci = 0;
-- 
1.9.3
