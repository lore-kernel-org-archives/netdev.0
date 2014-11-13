From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv10 ovs 03/15] datapath: Add 'is_mask' to ovs_nla_put_flow().
Date: Thu, 13 Nov 2014 11:17:43 -0800
Message-ID: <1415906275-3172-4-git-send-email-joestringer@nicira.com>
References: <1415906275-3172-1-git-send-email-joestringer@nicira.com>
Cc: netdev@vger.kernel.org
To: dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog004.obsmtp.com ([74.125.150.48]:49827 "HELO
	na6sys009bog004.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933571AbaKMThY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 14:37:24 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so1338224pab.0
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 11:37:23 -0800 (PST)
In-Reply-To: <1415906275-3172-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function previously hid the 'is_mask' parameter from the callers,
which actually have better knowledge about whether it is serializing a
mask or not. Expose this parameter to the callers. This allows the same
function to be called to serialize masked keys as well as masked keys.

To serialize an unmasked key:
ovs_nla_put_flow(key, key, skb, false);

To serialize a masked key:
ovs_nla_put_flow(mask, key, skb, false);

To serialize a mask:
ovs_nla_put_flow(key, mask, skb, true);

Signed-off-by: Joe Stringer <joestringer@nicira.com>
CC: netdev@vger.kernel.org
---
v10: First post.
---
 datapath/datapath.c     |    7 ++++---
 datapath/flow_netlink.c |    4 ++--
 datapath/flow_netlink.h |    4 ++--
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/datapath/datapath.c b/datapath/datapath.c
index 3607170..a898584 100644
--- a/datapath/datapath.c
+++ b/datapath/datapath.c
@@ -468,7 +468,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 	upcall->dp_ifindex = dp_ifindex;
 
 	nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_KEY);
-	err = ovs_nla_put_flow(key, key, user_skb);
+	err = ovs_nla_put_flow(key, key, user_skb, false);
 	BUG_ON(err);
 	nla_nest_end(user_skb, nla);
 
@@ -694,7 +694,8 @@ static int ovs_flow_cmd_fill_match(const struct sw_flow *flow,
 	if (!nla)
 		return -EMSGSIZE;
 
-	err = ovs_nla_put_flow(&flow->unmasked_key, &flow->unmasked_key, skb);
+	err = ovs_nla_put_flow(&flow->unmasked_key, &flow->unmasked_key, skb,
+			       false);
 	if (err)
 		return err;
 
@@ -705,7 +706,7 @@ static int ovs_flow_cmd_fill_match(const struct sw_flow *flow,
 	if (!nla)
 		return -EMSGSIZE;
 
-	err = ovs_nla_put_flow(&flow->key, &flow->mask->key, skb);
+	err = ovs_nla_put_flow(&flow->key, &flow->mask->key, skb, true);
 	if (err)
 		return err;
 
diff --git a/datapath/flow_netlink.c b/datapath/flow_netlink.c
index 503cf63..c1c29f5 100644
--- a/datapath/flow_netlink.c
+++ b/datapath/flow_netlink.c
@@ -1132,11 +1132,11 @@ int ovs_nla_get_flow_metadata(const struct nlattr *attr,
 }
 
 int ovs_nla_put_flow(const struct sw_flow_key *swkey,
-		     const struct sw_flow_key *output, struct sk_buff *skb)
+		     const struct sw_flow_key *output,
+		     struct sk_buff *skb, bool is_mask)
 {
 	struct ovs_key_ethernet *eth_key;
 	struct nlattr *nla, *encap;
-	bool is_mask = (swkey != output);
 
 	if (nla_put_u32(skb, OVS_KEY_ATTR_RECIRC_ID, output->recirc_id))
 		goto nla_put_failure;
diff --git a/datapath/flow_netlink.h b/datapath/flow_netlink.h
index 577f12b..fde7616 100644
--- a/datapath/flow_netlink.h
+++ b/datapath/flow_netlink.h
@@ -43,8 +43,8 @@ size_t ovs_key_attr_size(void);
 void ovs_match_init(struct sw_flow_match *match,
 		    struct sw_flow_key *key, struct sw_flow_mask *mask);
 
-int ovs_nla_put_flow(const struct sw_flow_key *,
-		     const struct sw_flow_key *, struct sk_buff *);
+int ovs_nla_put_flow(const struct sw_flow_key *, const struct sw_flow_key *,
+		     struct sk_buff *, bool is_mask);
 int ovs_nla_get_flow_metadata(const struct nlattr *, struct sw_flow_key *,
 			      bool log);
 
-- 
1.7.10.4
