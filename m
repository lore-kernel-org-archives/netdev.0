From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 12/14] openvswitch: Move key_attr_size() to flow_netlink.h.
Date: Thu,  6 Nov 2014 01:19:44 -0800
Message-ID: <1415265584-1872-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Joe Stringer <joestringer@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:40060 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752069AbaKFJTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 04:19:47 -0500
Received: by mail-pa0-f53.google.com with SMTP id kx10so873077pab.40
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 01:19:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joestringer@nicira.com>

flow-netlink has netlink related code.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/datapath.c     | 31 +++----------------------------
 net/openvswitch/flow_netlink.c | 32 ++++++++++++++++++++++++++++++++
 net/openvswitch/flow_netlink.h |  2 ++
 3 files changed, 37 insertions(+), 28 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 4fd8a45..5101780 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -375,37 +375,12 @@ static int queue_gso_packets(struct datapath *dp, struct sk_buff *skb,
 	return err;
 }
 
-static size_t key_attr_size(void)
-{
-	return    nla_total_size(4)   /* OVS_KEY_ATTR_PRIORITY */
-		+ nla_total_size(0)   /* OVS_KEY_ATTR_TUNNEL */
-		  + nla_total_size(8)   /* OVS_TUNNEL_KEY_ATTR_ID */
-		  + nla_total_size(4)   /* OVS_TUNNEL_KEY_ATTR_IPV4_SRC */
-		  + nla_total_size(4)   /* OVS_TUNNEL_KEY_ATTR_IPV4_DST */
-		  + nla_total_size(1)   /* OVS_TUNNEL_KEY_ATTR_TOS */
-		  + nla_total_size(1)   /* OVS_TUNNEL_KEY_ATTR_TTL */
-		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT */
-		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_CSUM */
-		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_OAM */
-		  + nla_total_size(256)   /* OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS */
-		+ nla_total_size(4)   /* OVS_KEY_ATTR_IN_PORT */
-		+ nla_total_size(4)   /* OVS_KEY_ATTR_SKB_MARK */
-		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
-		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
-		+ nla_total_size(4)   /* OVS_KEY_ATTR_8021Q */
-		+ nla_total_size(0)   /* OVS_KEY_ATTR_ENCAP */
-		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
-		+ nla_total_size(40)  /* OVS_KEY_ATTR_IPV6 */
-		+ nla_total_size(2)   /* OVS_KEY_ATTR_ICMPV6 */
-		+ nla_total_size(28); /* OVS_KEY_ATTR_ND */
-}
-
 static size_t upcall_msg_size(const struct nlattr *userdata,
 			      unsigned int hdrlen)
 {
 	size_t size = NLMSG_ALIGN(sizeof(struct ovs_header))
 		+ nla_total_size(hdrlen) /* OVS_PACKET_ATTR_PACKET */
-		+ nla_total_size(key_attr_size()); /* OVS_PACKET_ATTR_KEY */
+		+ nla_total_size(ovs_key_attr_size()); /* OVS_PACKET_ATTR_KEY */
 
 	/* OVS_PACKET_ATTR_USERDATA */
 	if (userdata)
@@ -678,8 +653,8 @@ static void get_dp_stats(struct datapath *dp, struct ovs_dp_stats *stats,
 static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts)
 {
 	return NLMSG_ALIGN(sizeof(struct ovs_header))
-		+ nla_total_size(key_attr_size()) /* OVS_FLOW_ATTR_KEY */
-		+ nla_total_size(key_attr_size()) /* OVS_FLOW_ATTR_MASK */
+		+ nla_total_size(ovs_key_attr_size()) /* OVS_FLOW_ATTR_KEY */
+		+ nla_total_size(ovs_key_attr_size()) /* OVS_FLOW_ATTR_MASK */
 		+ nla_total_size(sizeof(struct ovs_flow_stats)) /* OVS_FLOW_ATTR_STATS */
 		+ nla_total_size(1) /* OVS_FLOW_ATTR_TCP_FLAGS */
 		+ nla_total_size(8) /* OVS_FLOW_ATTR_USED */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 1b29ea7..1050b28 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -252,6 +252,38 @@ static bool match_validate(const struct sw_flow_match *match,
 	return true;
 }
 
+size_t ovs_key_attr_size(void)
+{
+	/* Whenever adding new OVS_KEY_ FIELDS, we should consider
+	 * updating this function.
+	 */
+	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 22);
+
+	return    nla_total_size(4)   /* OVS_KEY_ATTR_PRIORITY */
+		+ nla_total_size(0)   /* OVS_KEY_ATTR_TUNNEL */
+		  + nla_total_size(8)   /* OVS_TUNNEL_KEY_ATTR_ID */
+		  + nla_total_size(4)   /* OVS_TUNNEL_KEY_ATTR_IPV4_SRC */
+		  + nla_total_size(4)   /* OVS_TUNNEL_KEY_ATTR_IPV4_DST */
+		  + nla_total_size(1)   /* OVS_TUNNEL_KEY_ATTR_TOS */
+		  + nla_total_size(1)   /* OVS_TUNNEL_KEY_ATTR_TTL */
+		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT */
+		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_CSUM */
+		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_OAM */
+		  + nla_total_size(256) /* OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS */
+		+ nla_total_size(4)   /* OVS_KEY_ATTR_IN_PORT */
+		+ nla_total_size(4)   /* OVS_KEY_ATTR_SKB_MARK */
+		+ nla_total_size(4)   /* OVS_KEY_ATTR_DP_HASH */
+		+ nla_total_size(4)   /* OVS_KEY_ATTR_RECIRC_ID */
+		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
+		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
+		+ nla_total_size(4)   /* OVS_KEY_ATTR_VLAN */
+		+ nla_total_size(0)   /* OVS_KEY_ATTR_ENCAP */
+		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
+		+ nla_total_size(40)  /* OVS_KEY_ATTR_IPV6 */
+		+ nla_total_size(2)   /* OVS_KEY_ATTR_ICMPV6 */
+		+ nla_total_size(28); /* OVS_KEY_ATTR_ND */
+}
+
 /* The size of the argument for each %OVS_KEY_ATTR_* Netlink attribute.  */
 static const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_ENCAP] = -1,
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
index 6355b1d..4f03706 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -37,6 +37,8 @@
 
 #include "flow.h"
 
+size_t ovs_key_attr_size(void);
+
 void ovs_match_init(struct sw_flow_match *match,
 		    struct sw_flow_key *key, struct sw_flow_mask *mask);
 
-- 
1.9.3
