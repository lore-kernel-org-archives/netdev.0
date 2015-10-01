From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2 1/4] openvswitch: add tunnel protocol to sw_flow_key
Date: Thu,  1 Oct 2015 16:44:39 +0200
Message-ID: <c3cd5405d57793d2d9e84f2c5bdd0438cf68d980.1443710454.git.jbenc@redhat.com>
References: <cover.1443710454.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54369 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752966AbbJAOpM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2015 10:45:12 -0400
In-Reply-To: <cover.1443710454.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Store tunnel protocol (AF_INET or AF_INET6) in sw_flow_key. This field now
also acts as an indicator whether the flow contains tunnel data (this was
previously indicated by tun_key.u.ipv4.dst being set but with IPv6 addresses
in an union with IPv4 ones this won't work anymore).

The new field was added to a hole in sw_flow_key.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
v2: Set the tun_proto mask to 0xff in ip_tun_from_nlattr.
---
 net/openvswitch/flow.c         |  4 ++--
 net/openvswitch/flow.h         |  1 +
 net/openvswitch/flow_netlink.c | 10 ++++++++--
 net/openvswitch/flow_table.c   |  2 +-
 4 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index c8db44ab2ee7..0ea128eeeab2 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -698,8 +698,7 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 {
 	/* Extract metadata from packet. */
 	if (tun_info) {
-		if (ip_tunnel_info_af(tun_info) != AF_INET)
-			return -EINVAL;
+		key->tun_proto = ip_tunnel_info_af(tun_info);
 		memcpy(&key->tun_key, &tun_info->key, sizeof(key->tun_key));
 
 		if (tun_info->options_len) {
@@ -714,6 +713,7 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 			key->tun_opts_len = 0;
 		}
 	} else  {
+		key->tun_proto = 0;
 		key->tun_opts_len = 0;
 		memset(&key->tun_key, 0, sizeof(key->tun_key));
 	}
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index fe527d2dd4b7..5688e33e2de6 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -63,6 +63,7 @@ struct sw_flow_key {
 		u32	skb_mark;	/* SKB mark. */
 		u16	in_port;	/* Input switch port (or DP_MAX_PORTS). */
 	} __packed phy; /* Safe when right after 'tun_key'. */
+	u8 tun_proto;			/* Protocol of encapsulating tunnel. */
 	u32 ovs_flow_hash;		/* Datapath computed hash value.  */
 	u32 recirc_id;			/* Recirculation ID.  */
 	struct {
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 5c030a4d7338..6be701f6b31b 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -643,6 +643,10 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 	}
 
 	SW_FLOW_KEY_PUT(match, tun_key.tun_flags, tun_flags, is_mask);
+	if (is_mask)
+		SW_FLOW_KEY_MEMSET_FIELD(match, tun_proto, 0xff, true);
+	else
+		SW_FLOW_KEY_PUT(match, tun_proto, AF_INET, false);
 
 	if (rem > 0) {
 		OVS_NLERR(log, "IPv4 tunnel attribute has %d unknown bytes.",
@@ -1194,7 +1198,7 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
 			/* The userspace does not send tunnel attributes that
 			 * are 0, but we should not wildcard them nonetheless.
 			 */
-			if (match->key->tun_key.u.ipv4.dst)
+			if (match->key->tun_proto)
 				SW_FLOW_KEY_MEMSET_FIELD(match, tun_key,
 							 0xff, true);
 
@@ -1367,7 +1371,7 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 	if (nla_put_u32(skb, OVS_KEY_ATTR_PRIORITY, output->phy.priority))
 		goto nla_put_failure;
 
-	if ((swkey->tun_key.u.ipv4.dst || is_mask)) {
+	if ((swkey->tun_proto || is_mask)) {
 		const void *opts = NULL;
 
 		if (output->tun_key.tun_flags & TUNNEL_OPTIONS_PRESENT)
@@ -1913,6 +1917,8 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 
 	tun_info = &tun_dst->u.tun_info;
 	tun_info->mode = IP_TUNNEL_INFO_TX;
+	if (key.tun_proto == AF_INET6)
+		tun_info->mode |= IP_TUNNEL_INFO_IPV6;
 	tun_info->key = key.tun_key;
 
 	/* We need to store the options in the action itself since
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index f2ea83ba4763..95dbcedf0bd4 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -427,7 +427,7 @@ static u32 flow_hash(const struct sw_flow_key *key,
 
 static int flow_key_start(const struct sw_flow_key *key)
 {
-	if (key->tun_key.u.ipv4.dst)
+	if (key->tun_proto)
 		return 0;
 	else
 		return rounddown(offsetof(struct sw_flow_key, phy),
-- 
1.8.3.1
