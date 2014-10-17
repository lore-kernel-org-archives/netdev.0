From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] openvswitch: Create right mask with disabled megaflows
Date: Thu, 16 Oct 2014 21:55:45 -0700
Message-ID: <1413521745-1492-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Daniele Di Proietto <ddiproietto@vmware.com>,
	Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:60397 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751052AbaJQGpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 02:45:01 -0400
Received: by mail-pa0-f50.google.com with SMTP id kx10so265716pab.9
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2014 23:44:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If megaflows are disabled, the userspace does not send the netlink attribute
OVS_FLOW_ATTR_MASK, and the kernel must create an exact match mask.

sw_flow_mask_set() sets every bytes (in 'range') of the mask to 0xff, even the
bytes that represent padding for struct sw_flow, or the bytes that represent
fields that may not be set during ovs_flow_extract().
This is a problem, because when we extract a flow from a packet,
we do not memset() anymore the struct sw_flow to 0.

This commit gets rid of sw_flow_mask_set() and introduces mask_set_nlattr(),
which operates on the netlink attributes rather than on the mask key. Using
this approach we are sure that only the bytes that the user provided in the
flow are matched.

Also, if the parse_flow_mask_nlattrs() for the mask ENCAP attribute fails, we
now return with an error.

This bug is introduced by commit 0714812134d7dcadeb7ecfbfeb18788aa7e1eaac
("openvswitch: Eliminate memset() from flow_extract").

Reported-by: Alex Wang <alexw@nicira.com>
Signed-off-by: Daniele Di Proietto <ddiproietto@vmware.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/flow_netlink.c |   93 +++++++++++++++++++++++++++++++---------
 1 files changed, 72 insertions(+), 21 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 368f233..939bcb3 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -103,10 +103,19 @@ static void update_range__(struct sw_flow_match *match,
 	SW_FLOW_KEY_MEMCPY_OFFSET(match, offsetof(struct sw_flow_key, field), \
 				  value_p, len, is_mask)
 
-static u16 range_n_bytes(const struct sw_flow_key_range *range)
-{
-	return range->end - range->start;
-}
+#define SW_FLOW_KEY_MEMSET_FIELD(match, field, value, is_mask) \
+	do { \
+		update_range__(match, offsetof(struct sw_flow_key, field),  \
+				     sizeof((match)->key->field), is_mask); \
+		if (is_mask) {						    \
+			if ((match)->mask)				    \
+				memset((u8 *)&(match)->mask->key.field, value,\
+				       sizeof((match)->mask->key.field));   \
+		} else {                                                    \
+			memset((u8 *)&(match)->key->field, value,           \
+			       sizeof((match)->key->field));                \
+		}                                                           \
+	} while (0)
 
 static bool match_validate(const struct sw_flow_match *match,
 			   u64 key_attrs, u64 mask_attrs)
@@ -809,13 +818,26 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
 	return 0;
 }
 
-static void sw_flow_mask_set(struct sw_flow_mask *mask,
-			     struct sw_flow_key_range *range, u8 val)
+static void nlattr_set(struct nlattr *attr, u8 val, bool is_attr_mask_key)
 {
-	u8 *m = (u8 *)&mask->key + range->start;
+	struct nlattr *nla;
+	int rem;
+
+	/* The nlattr stream should already have been validated */
+	nla_for_each_nested(nla, attr, rem) {
+		/* We assume that ovs_key_lens[type] == -1 means that type is a
+		 * nested attribute
+		 */
+		if (is_attr_mask_key && ovs_key_lens[nla_type(nla)] == -1)
+			nlattr_set(nla, val, false);
+		else
+			memset(nla_data(nla), val, nla_len(nla));
+	}
+}
 
-	mask->range = *range;
-	memset(m, val, range_n_bytes(range));
+static void mask_set_nlattr(struct nlattr *attr, u8 val)
+{
+	nlattr_set(attr, val, true);
 }
 
 /**
@@ -836,6 +858,7 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 {
 	const struct nlattr *a[OVS_KEY_ATTR_MAX + 1];
 	const struct nlattr *encap;
+	struct nlattr *newmask = NULL;
 	u64 key_attrs = 0;
 	u64 mask_attrs = 0;
 	bool encap_valid = false;
@@ -882,18 +905,44 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 	if (err)
 		return err;
 
+	if (match->mask && !mask) {
+		/* Create an exact match mask. We need to set to 0xff all the
+		 * 'match->mask' fields that have been touched in 'match->key'.
+		 * We cannot simply memset 'match->mask', because padding bytes
+		 * and fields not specified in 'match->key' should be left to 0.
+		 * Instead, we use a stream of netlink attributes, copied from
+		 * 'key' and set to 0xff: ovs_key_from_nlattrs() will take care
+		 * of filling 'match->mask' appropriately.
+		 */
+		newmask = kmemdup(key, nla_total_size(nla_len(key)),
+				  GFP_KERNEL);
+		if (!newmask)
+			return -ENOMEM;
+
+		mask_set_nlattr(newmask, 0xff);
+
+		/* The userspace does not send tunnel attributes that are 0,
+		 * but we should not wildcard them nonetheless.
+		 */
+		if (match->key->tun_key.ipv4_dst)
+			SW_FLOW_KEY_MEMSET_FIELD(match, tun_key, 0xff, true);
+
+		mask = newmask;
+	}
+
 	if (mask) {
 		err = parse_flow_mask_nlattrs(mask, a, &mask_attrs);
 		if (err)
-			return err;
+			goto free_newmask;
 
-		if (mask_attrs & 1 << OVS_KEY_ATTR_ENCAP)  {
+		if (mask_attrs & 1 << OVS_KEY_ATTR_ENCAP) {
 			__be16 eth_type = 0;
 			__be16 tci = 0;
 
 			if (!encap_valid) {
 				OVS_NLERR("Encap mask attribute is set for non-VLAN frame.\n");
-				return  -EINVAL;
+				err = -EINVAL;
+				goto free_newmask;
 			}
 
 			mask_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
@@ -904,10 +953,13 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 				mask_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
 				encap = a[OVS_KEY_ATTR_ENCAP];
 				err = parse_flow_mask_nlattrs(encap, a, &mask_attrs);
+				if (err)
+					goto free_newmask;
 			} else {
 				OVS_NLERR("VLAN frames must have an exact match on the TPID (mask=%x).\n",
 						ntohs(eth_type));
-				return -EINVAL;
+				err = -EINVAL;
+				goto free_newmask;
 			}
 
 			if (a[OVS_KEY_ATTR_VLAN])
@@ -915,23 +967,22 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 
 			if (!(tci & htons(VLAN_TAG_PRESENT))) {
 				OVS_NLERR("VLAN tag present bit must have an exact match (tci_mask=%x).\n", ntohs(tci));
-				return -EINVAL;
+				err = -EINVAL;
+				goto free_newmask;
 			}
 		}
 
 		err = ovs_key_from_nlattrs(match, mask_attrs, a, true);
 		if (err)
-			return err;
-	} else {
-		/* Populate exact match flow's key mask. */
-		if (match->mask)
-			sw_flow_mask_set(match->mask, &match->range, 0xff);
+			goto free_newmask;
 	}
 
 	if (!match_validate(match, key_attrs, mask_attrs))
-		return -EINVAL;
+		err = -EINVAL;
 
-	return 0;
+free_newmask:
+	kfree(newmask);
+	return err;
 }
 
 /**
-- 
1.7.1
