From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] bridge: vlan tunnel id info range fill size calc cleanups
Date: Tue,  7 Feb 2017 16:12:00 -0800
Message-ID: <1486512720-1071-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, colin.king@canonical.com,
        nikolay@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35559 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751060AbdBHANA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 19:13:00 -0500
Received: by mail-pg0-f43.google.com with SMTP id 194so42999992pgd.2
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 16:12:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This fixes a bug and cleans up tunnelid range size
calculation code by using consistent variable names
and checks in size calculation and fill functions.

tested for a few cases of vlan-vni range mappings:
(output from patched iproute2):
$bridge vlan showtunnel
port     vid        tunid
vxlan0   100-105    1000-1005
         200        2000
         210        2100
         211-213    2100-2102
         214        2104
         216-217    2108-2109
         219        2119

Fixes: efa5356b0d97 ("bridge: per vlan dst_metadata netlink support")
Reported-by: Colin Ian King <colin.king@canonical.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_netlink_tunnel.c |   34 ++++++++++++++++------------------
 1 file changed, 16 insertions(+), 18 deletions(-)

diff --git a/net/bridge/br_netlink_tunnel.c b/net/bridge/br_netlink_tunnel.c
index 4c1303b..3a0eb54 100644
--- a/net/bridge/br_netlink_tunnel.c
+++ b/net/bridge/br_netlink_tunnel.c
@@ -30,18 +30,18 @@ static size_t __get_vlan_tinfo_size(void)
 		  nla_total_size(sizeof(u16)); /* IFLA_BRIDGE_VLAN_TUNNEL_FLAGS */
 }
 
-static bool vlan_tunnel_id_isrange(struct net_bridge_vlan *v,
-				   struct net_bridge_vlan *v_end)
+static bool vlan_tunid_inrange(struct net_bridge_vlan *v_curr,
+			       struct net_bridge_vlan *v_last)
 {
-	__be32 tunid_curr = tunnel_id_to_key32(v->tinfo.tunnel_id);
-	__be32 tunid_end = tunnel_id_to_key32(v_end->tinfo.tunnel_id);
+	__be32 tunid_curr = tunnel_id_to_key32(v_curr->tinfo.tunnel_id);
+	__be32 tunid_last = tunnel_id_to_key32(v_last->tinfo.tunnel_id);
 
-	return (be32_to_cpu(tunid_curr) - be32_to_cpu(tunid_end)) == 1;
+	return (be32_to_cpu(tunid_curr) - be32_to_cpu(tunid_last)) == 1;
 }
 
 static int __get_num_vlan_tunnel_infos(struct net_bridge_vlan_group *vg)
 {
-	struct net_bridge_vlan *v, *v_start = NULL, *v_end = NULL;
+	struct net_bridge_vlan *v, *vtbegin = NULL, *vtend = NULL;
 	int num_tinfos = 0;
 
 	/* Count number of vlan infos */
@@ -50,27 +50,25 @@ static int __get_num_vlan_tunnel_infos(struct net_bridge_vlan_group *vg)
 		if (!br_vlan_should_use(v) || !v->tinfo.tunnel_id)
 			continue;
 
-		if (!v_start) {
+		if (!vtbegin) {
 			goto initvars;
-		} else if ((v->vid - v_end->vid) == 1 &&
-			   vlan_tunnel_id_isrange(v_end, v) == 1) {
-			v_end = v;
+		} else if ((v->vid - vtend->vid) == 1 &&
+			   vlan_tunid_inrange(v, vtend)) {
+			vtend = v;
 			continue;
 		} else {
-			if ((v_end->vid - v->vid) > 0 &&
-			    vlan_tunnel_id_isrange(v_end, v) > 0)
+			if ((vtend->vid - vtbegin->vid) > 0)
 				num_tinfos += 2;
 			else
 				num_tinfos += 1;
 		}
 initvars:
-		v_start = v;
-		v_end = v;
+		vtbegin = v;
+		vtend = v;
 	}
 
-	if (v_start) {
-		if ((v_end->vid - v->vid) > 0 &&
-		    vlan_tunnel_id_isrange(v_end, v) > 0)
+	if (vtbegin && vtend) {
+		if ((vtend->vid - vtbegin->vid) > 0)
 			num_tinfos += 2;
 		else
 			num_tinfos += 1;
@@ -171,7 +169,7 @@ int br_fill_vlan_tunnel_info(struct sk_buff *skb,
 		if (!vtbegin) {
 			goto initvars;
 		} else if ((v->vid - vtend->vid) == 1 &&
-			    vlan_tunnel_id_isrange(v, vtend)) {
+			    vlan_tunid_inrange(v, vtend)) {
 			vtend = v;
 			continue;
 		} else {
-- 
1.7.10.4
