From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v1 10/11] net: rocker: have flow api calls set
 cookie value
Date: Wed, 31 Dec 2014 11:50:01 -0800
Message-ID: <20141231194954.31070.34584.stgit@nitbit.x32>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net
To: tgraf@suug.ch, sfeldma@gmail.com, jiri@resnulli.us,
	jhs@mojatatu.com, simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:46011 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610AbaLaTuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 14:50:21 -0500
Received: by mail-oi0-f47.google.com with SMTP id v63so36663302oia.6
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 11:50:21 -0800 (PST)
In-Reply-To: <20141231194057.31070.5244.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/rocker/rocker.c |   19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 4d2d292..4ca95da 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3938,7 +3938,8 @@ static int rocker_flow_set_ig_port(struct net_device *dev,
 	in_lport_mask = flow->matches[0].mask_u32;
 	goto_tbl = rocker_goto_value(flow->actions[0].args[0].value_u16);
 
-	err = rocker_flow_tbl_ig_port(rocker_port, flags, 0,
+	err = rocker_flow_tbl_ig_port(rocker_port, flags,
+				      flow->uid, 
 				      in_lport, in_lport_mask,
 				      goto_tbl);
 	return err;
@@ -4000,7 +4001,7 @@ static int rocker_flow_set_vlan(struct net_device *dev,
 	if (!have_in_lport)
 		return -EINVAL;
 
-	err = rocker_flow_tbl_vlan(rocker_port, flags, 0, in_lport,
+	err = rocker_flow_tbl_vlan(rocker_port, flags, flow->uid, in_lport,
 				   vlan_id, vlan_id_mask, goto_tbl,
 				   untagged, new_vlan_id);
 	return err;
@@ -4082,7 +4083,7 @@ static int rocker_flow_set_term_mac(struct net_device *dev,
 		}
 	}
 
-	err = rocker_flow_tbl_term_mac(rocker_port, 0,
+	err = rocker_flow_tbl_term_mac(rocker_port, flow->uid,
 				       in_lport, in_lport_mask,
 				       ethtype, eth_dst, eth_dst_mask,
 				       vlan_id, vlan_id_mask,
@@ -4182,7 +4183,7 @@ static int rocker_flow_set_bridge(struct net_device *dev,
 	}
 
 	/* Ignoring eth_dst_mask it seems to cause a EINVAL return code */
-	err = rocker_flow_tbl_bridge(rocker_port, flags, 0,
+	err = rocker_flow_tbl_bridge(rocker_port, flags, flow->uid,
 				     eth_dst, eth_dst_mask,
 				     vlan_id, tunnel_id,
 				     goto_tbl, group_id, copy_to_cpu);
@@ -4289,7 +4290,7 @@ static int rocker_flow_set_acl(struct net_device *dev,
 		}
 	}
 
-	err = rocker_flow_tbl_acl(rocker_port, flags, 0,
+	err = rocker_flow_tbl_acl(rocker_port, flags, flow->uid,
 				  in_lport, in_lport_mask,
 				  eth_src, eth_src_mask,
 				  eth_dst, eth_dst_mask, ethtype,
@@ -4354,6 +4355,8 @@ static int rocker_flow_set_group_slice_l3_unicast(struct net_device *dev,
 		}
 	}
 
+	entry->cookie = flow->uid;
+
 	return rocker_group_tbl_do(rocker_port, flags, entry);
 }
 
@@ -4409,6 +4412,8 @@ static int rocker_flow_set_group_slice_l2_rewrite(struct net_device *dev,
 		}
 	}
 
+	entry->cookie = flow->uid;
+
 	return rocker_group_tbl_do(rocker_port, flags, entry);
 }
 
@@ -4464,6 +4469,8 @@ static int rocker_flow_set_group_slice_l2(struct net_device *dev,
 		}
 	}
 
+	entry->cookie = flow->uid;
+
 	return rocker_group_tbl_do(rocker_port, flags, entry);
 }
 
@@ -5307,7 +5314,7 @@ static int rocker_get_flows(struct sk_buff *skb, struct net_device *dev,
 			continue;
 
 		flow.table_id = table;
-		flow.uid = group->group_id;
+		flow.uid = group->cookie;
 		flow.priority = 1;
 
 		switch (table) {
