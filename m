From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 7/8] genetlink: pass family to genlmsg_multicast() and friends
Date: Sat, 16 Nov 2013 18:03:48 +0100
Message-ID: <1384621429-24543-8-git-send-email-johannes@sipsolutions.net>
References: <1384621429-24543-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:57915 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752037Ab3KPREB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 12:04:01 -0500
In-Reply-To: <1384621429-24543-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

This doesn't really change anything, but prepares for the
next patch that will change the API to pass the group ID
within the family, rather than the global group ID.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 drivers/acpi/event.c            |  3 +-
 drivers/net/team/team.c         |  5 +--
 drivers/scsi/pmcraid.c          |  3 +-
 drivers/thermal/thermal_core.c  |  3 +-
 fs/quota/netlink.c              |  2 +-
 include/linux/genl_magic_func.h |  3 +-
 include/net/genetlink.h         | 18 ++++++++---
 net/core/drop_monitor.c         |  3 +-
 net/hsr/hsr_netlink.c           |  6 ++--
 net/ieee802154/netlink.c        |  2 +-
 net/netlink/genetlink.c         | 12 ++++---
 net/nfc/netlink.c               | 39 +++++++++++++++--------
 net/openvswitch/datapath.c      | 31 +++++++++++-------
 net/openvswitch/datapath.h      |  1 +
 net/openvswitch/dp_notify.c     |  3 +-
 net/wimax/op-msg.c              |  3 +-
 net/wimax/stack.c               |  3 +-
 net/wireless/nl80211.c          | 70 ++++++++++++++++++++---------------------
 18 files changed, 127 insertions(+), 83 deletions(-)

diff --git a/drivers/acpi/event.c b/drivers/acpi/event.c
index 8247fcd..68a8755 100644
--- a/drivers/acpi/event.c
+++ b/drivers/acpi/event.c
@@ -146,7 +146,8 @@ int acpi_bus_generate_netlink_event(const char *device_class,
 		return result;
 	}
 
-	genlmsg_multicast(skb, 0, acpi_event_mcgrp.id, GFP_ATOMIC);
+	genlmsg_multicast(&acpi_event_genl_family,
+			  skb, 0, acpi_event_mcgrp.id, GFP_ATOMIC);
 	return 0;
 }
 
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index f55758b..2721e29 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2677,8 +2677,9 @@ static struct genl_multicast_group team_change_event_mcgrp = {
 static int team_nl_send_multicast(struct sk_buff *skb,
 				  struct team *team, u32 portid)
 {
-	return genlmsg_multicast_netns(dev_net(team->dev), skb, 0,
-				       team_change_event_mcgrp.id, GFP_KERNEL);
+	return genlmsg_multicast_netns(&team_nl_family, dev_net(team->dev),
+				       skb, 0, team_change_event_mcgrp.id,
+				       GFP_KERNEL);
 }
 
 static int team_nl_send_event_options_get(struct team *team,
diff --git a/drivers/scsi/pmcraid.c b/drivers/scsi/pmcraid.c
index 1eb7b028..2775441 100644
--- a/drivers/scsi/pmcraid.c
+++ b/drivers/scsi/pmcraid.c
@@ -1512,7 +1512,8 @@ static int pmcraid_notify_aen(
 	}
 
 	result =
-		genlmsg_multicast(skb, 0, pmcraid_event_family.id, GFP_ATOMIC);
+		genlmsg_multicast(&pmcraid_event_family, skb, 0,
+				  pmcraid_event_family.id, GFP_ATOMIC);
 
 	/* If there are no listeners, genlmsg_multicast may return non-zero
 	 * value.
diff --git a/drivers/thermal/thermal_core.c b/drivers/thermal/thermal_core.c
index 4962a6a..2570a94 100644
--- a/drivers/thermal/thermal_core.c
+++ b/drivers/thermal/thermal_core.c
@@ -1675,7 +1675,8 @@ int thermal_generate_netlink_event(struct thermal_zone_device *tz,
 		return result;
 	}
 
-	result = genlmsg_multicast(skb, 0, thermal_event_mcgrp.id, GFP_ATOMIC);
+	result = genlmsg_multicast(&thermal_event_genl_family, skb, 0,
+				   thermal_event_mcgrp.id, GFP_ATOMIC);
 	if (result)
 		dev_err(&tz->device, "Failed to send netlink event:%d", result);
 
diff --git a/fs/quota/netlink.c b/fs/quota/netlink.c
index b261ce4..2e2220d 100644
--- a/fs/quota/netlink.c
+++ b/fs/quota/netlink.c
@@ -88,7 +88,7 @@ void quota_send_warning(struct kqid qid, dev_t dev,
 		goto attr_err_out;
 	genlmsg_end(skb, msg_head);
 
-	genlmsg_multicast(skb, 0, quota_mcgrp.id, GFP_NOFS);
+	genlmsg_multicast(&quota_genl_family, skb, 0, quota_mcgrp.id, GFP_NOFS);
 	return;
 attr_err_out:
 	printk(KERN_ERR "VFS: Not enough space to compose quota message!\n");
diff --git a/include/linux/genl_magic_func.h b/include/linux/genl_magic_func.h
index 4708603..5b9b8ae 100644
--- a/include/linux/genl_magic_func.h
+++ b/include/linux/genl_magic_func.h
@@ -286,7 +286,8 @@ static int CONCAT_(GENL_MAGIC_FAMILY, _genl_multicast_ ## group)(	\
 		CONCAT_(GENL_MAGIC_FAMILY, _mcg_ ## group).id;	\
 	if (!group_id)							\
 		return -EINVAL;						\
-	return genlmsg_multicast(skb, 0, group_id, flags);		\
+	return genlmsg_multicast(&ZZZ_genl_family, skb, 0,		\
+				 group_id, flags);			\
 }
 
 #include GENL_MAGIC_INCLUDE_FILE
diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index d8a8b1f..3c7511b 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -166,7 +166,8 @@ static inline int _genl_register_family_with_ops(struct genl_family *family,
 int genl_unregister_family(struct genl_family *family);
 int genl_register_mc_group(struct genl_family *family,
 			   struct genl_multicast_group *grp);
-void genl_notify(struct sk_buff *skb, struct net *net, u32 portid,
+void genl_notify(struct genl_family *family,
+		 struct sk_buff *skb, struct net *net, u32 portid,
 		 u32 group, struct nlmsghdr *nlh, gfp_t flags);
 
 void *genlmsg_put(struct sk_buff *skb, u32 portid, u32 seq,
@@ -246,13 +247,15 @@ static inline void genlmsg_cancel(struct sk_buff *skb, void *hdr)
 
 /**
  * genlmsg_multicast_netns - multicast a netlink message to a specific netns
+ * @family: the generic netlink family
  * @net: the net namespace
  * @skb: netlink message as socket buffer
  * @portid: own netlink portid to avoid sending to yourself
  * @group: multicast group id
  * @flags: allocation flags
  */
-static inline int genlmsg_multicast_netns(struct net *net, struct sk_buff *skb,
+static inline int genlmsg_multicast_netns(struct genl_family *family,
+					  struct net *net, struct sk_buff *skb,
 					  u32 portid, unsigned int group, gfp_t flags)
 {
 	return nlmsg_multicast(net->genl_sock, skb, portid, group, flags);
@@ -260,19 +263,23 @@ static inline int genlmsg_multicast_netns(struct net *net, struct sk_buff *skb,
 
 /**
  * genlmsg_multicast - multicast a netlink message to the default netns
+ * @family: the generic netlink family
  * @skb: netlink message as socket buffer
  * @portid: own netlink portid to avoid sending to yourself
  * @group: multicast group id
  * @flags: allocation flags
  */
-static inline int genlmsg_multicast(struct sk_buff *skb, u32 portid,
+static inline int genlmsg_multicast(struct genl_family *family,
+				    struct sk_buff *skb, u32 portid,
 				    unsigned int group, gfp_t flags)
 {
-	return genlmsg_multicast_netns(&init_net, skb, portid, group, flags);
+	return genlmsg_multicast_netns(family, &init_net, skb,
+				       portid, group, flags);
 }
 
 /**
  * genlmsg_multicast_allns - multicast a netlink message to all net namespaces
+ * @family: the generic netlink family
  * @skb: netlink message as socket buffer
  * @portid: own netlink portid to avoid sending to yourself
  * @group: multicast group id
@@ -280,7 +287,8 @@ static inline int genlmsg_multicast(struct sk_buff *skb, u32 portid,
  *
  * This function must hold the RTNL or rcu_read_lock().
  */
-int genlmsg_multicast_allns(struct sk_buff *skb, u32 portid,
+int genlmsg_multicast_allns(struct genl_family *family,
+			    struct sk_buff *skb, u32 portid,
 			    unsigned int group, gfp_t flags);
 
 /**
diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 46ee488..1eab1dc 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -120,7 +120,8 @@ static void send_dm_alert(struct work_struct *work)
 	skb = reset_per_cpu_data(data);
 
 	if (skb)
-		genlmsg_multicast(skb, 0, dm_mcgrp.id, GFP_KERNEL);
+		genlmsg_multicast(&net_drop_monitor_family, skb, 0,
+				  dm_mcgrp.id, GFP_KERNEL);
 }
 
 /*
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index 908e335..0009416 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -129,7 +129,8 @@ void hsr_nl_ringerror(struct hsr_priv *hsr_priv, unsigned char addr[ETH_ALEN],
 		goto nla_put_failure;
 
 	genlmsg_end(skb, msg_head);
-	genlmsg_multicast(skb, 0, hsr_network_genl_mcgrp.id, GFP_ATOMIC);
+	genlmsg_multicast(&hsr_genl_family, skb, 0,
+			  hsr_network_genl_mcgrp.id, GFP_ATOMIC);
 
 	return;
 
@@ -163,7 +164,8 @@ void hsr_nl_nodedown(struct hsr_priv *hsr_priv, unsigned char addr[ETH_ALEN])
 		goto nla_put_failure;
 
 	genlmsg_end(skb, msg_head);
-	genlmsg_multicast(skb, 0, hsr_network_genl_mcgrp.id, GFP_ATOMIC);
+	genlmsg_multicast(&hsr_genl_family, skb, 0,
+			  hsr_network_genl_mcgrp.id, GFP_ATOMIC);
 
 	return;
 
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 1a81709..5172f46 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -70,7 +70,7 @@ int ieee802154_nl_mcast(struct sk_buff *msg, unsigned int group)
 	if (genlmsg_end(msg, hdr) < 0)
 		goto out;
 
-	return genlmsg_multicast(msg, 0, group, GFP_ATOMIC);
+	return genlmsg_multicast(&nl802154_family, msg, 0, group, GFP_ATOMIC);
 out:
 	nlmsg_free(msg);
 	return -ENOBUFS;
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 5e81562..0e1e1fb 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -883,11 +883,12 @@ static int genl_ctrl_event(int event, struct genl_family *family,
 		return PTR_ERR(msg);
 
 	if (!family->netnsok) {
-		genlmsg_multicast_netns(&init_net, msg, 0,
+		genlmsg_multicast_netns(&genl_ctrl, &init_net, msg, 0,
 					GENL_ID_CTRL, GFP_KERNEL);
 	} else {
 		rcu_read_lock();
-		genlmsg_multicast_allns(msg, 0, GENL_ID_CTRL, GFP_ATOMIC);
+		genlmsg_multicast_allns(&genl_ctrl, msg, 0,
+					GENL_ID_CTRL, GFP_ATOMIC);
 		rcu_read_unlock();
 	}
 
@@ -993,14 +994,15 @@ static int genlmsg_mcast(struct sk_buff *skb, u32 portid, unsigned long group,
 	return err;
 }
 
-int genlmsg_multicast_allns(struct sk_buff *skb, u32 portid, unsigned int group,
-			    gfp_t flags)
+int genlmsg_multicast_allns(struct genl_family *family, struct sk_buff *skb,
+			    u32 portid, unsigned int group, gfp_t flags)
 {
 	return genlmsg_mcast(skb, portid, group, flags);
 }
 EXPORT_SYMBOL(genlmsg_multicast_allns);
 
-void genl_notify(struct sk_buff *skb, struct net *net, u32 portid, u32 group,
+void genl_notify(struct genl_family *family,
+		 struct sk_buff *skb, struct net *net, u32 portid, u32 group,
 		 struct nlmsghdr *nlh, gfp_t flags)
 {
 	struct sock *sk = net->genl_sock;
diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index fe6760d..3092df31 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -194,7 +194,8 @@ int nfc_genl_targets_found(struct nfc_dev *dev)
 
 	genlmsg_end(msg, hdr);
 
-	return genlmsg_multicast(msg, 0, nfc_genl_event_mcgrp.id, GFP_ATOMIC);
+	return genlmsg_multicast(&nfc_genl_family, msg, 0,
+				 nfc_genl_event_mcgrp.id, GFP_ATOMIC);
 
 nla_put_failure:
 	genlmsg_cancel(msg, hdr);
@@ -223,7 +224,8 @@ int nfc_genl_target_lost(struct nfc_dev *dev, u32 target_idx)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(msg, 0, nfc_genl_event_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&nfc_genl_family, msg, 0,
+			  nfc_genl_event_mcgrp.id, GFP_KERNEL);
 
 	return 0;
 
@@ -255,7 +257,8 @@ int nfc_genl_tm_activated(struct nfc_dev *dev, u32 protocol)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(msg, 0, nfc_genl_event_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&nfc_genl_family, msg, 0,
+			  nfc_genl_event_mcgrp.id, GFP_KERNEL);
 
 	return 0;
 
@@ -285,7 +288,8 @@ int nfc_genl_tm_deactivated(struct nfc_dev *dev)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(msg, 0, nfc_genl_event_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&nfc_genl_family, msg, 0,
+			  nfc_genl_event_mcgrp.id, GFP_KERNEL);
 
 	return 0;
 
@@ -318,7 +322,8 @@ int nfc_genl_device_added(struct nfc_dev *dev)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(msg, 0, nfc_genl_event_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&nfc_genl_family, msg, 0,
+			  nfc_genl_event_mcgrp.id, GFP_KERNEL);
 
 	return 0;
 
@@ -348,7 +353,8 @@ int nfc_genl_device_removed(struct nfc_dev *dev)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(msg, 0, nfc_genl_event_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&nfc_genl_family, msg, 0,
+			  nfc_genl_event_mcgrp.id, GFP_KERNEL);
 
 	return 0;
 
@@ -414,7 +420,8 @@ int nfc_genl_llc_send_sdres(struct nfc_dev *dev, struct hlist_head *sdres_list)
 
 	genlmsg_end(msg, hdr);
 
-	return genlmsg_multicast(msg, 0, nfc_genl_event_mcgrp.id, GFP_ATOMIC);
+	return genlmsg_multicast(&nfc_genl_family, msg, 0,
+				 nfc_genl_event_mcgrp.id, GFP_ATOMIC);
 
 nla_put_failure:
 	genlmsg_cancel(msg, hdr);
@@ -448,7 +455,8 @@ int nfc_genl_se_added(struct nfc_dev *dev, u32 se_idx, u16 type)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(msg, 0, nfc_genl_event_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&nfc_genl_family, msg, 0,
+			  nfc_genl_event_mcgrp.id, GFP_KERNEL);
 
 	return 0;
 
@@ -479,7 +487,8 @@ int nfc_genl_se_removed(struct nfc_dev *dev, u32 se_idx)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(msg, 0, nfc_genl_event_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&nfc_genl_family, msg, 0,
+			  nfc_genl_event_mcgrp.id, GFP_KERNEL);
 
 	return 0;
 
@@ -600,7 +609,8 @@ int nfc_genl_dep_link_up_event(struct nfc_dev *dev, u32 target_idx,
 
 	dev->dep_link_up = true;
 
-	genlmsg_multicast(msg, 0, nfc_genl_event_mcgrp.id, GFP_ATOMIC);
+	genlmsg_multicast(&nfc_genl_family, msg, 0,
+			  nfc_genl_event_mcgrp.id, GFP_ATOMIC);
 
 	return 0;
 
@@ -632,7 +642,8 @@ int nfc_genl_dep_link_down_event(struct nfc_dev *dev)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(msg, 0, nfc_genl_event_mcgrp.id, GFP_ATOMIC);
+	genlmsg_multicast(&nfc_genl_family, msg, 0,
+			  nfc_genl_event_mcgrp.id, GFP_ATOMIC);
 
 	return 0;
 
@@ -1137,7 +1148,8 @@ int nfc_genl_fw_download_done(struct nfc_dev *dev, const char *firmware_name,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(msg, 0, nfc_genl_event_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&nfc_genl_family, msg, 0,
+			  nfc_genl_event_mcgrp.id, GFP_KERNEL);
 
 	return 0;
 
@@ -1308,7 +1320,8 @@ static void se_io_cb(void *context, u8 *apdu, size_t apdu_len, int err)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast(msg, 0, nfc_genl_event_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&nfc_genl_family, msg, 0,
+			  nfc_genl_event_mcgrp.id, GFP_KERNEL);
 
 	kfree(ctx);
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 8ec8b73..1de9446 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -61,10 +61,11 @@
 
 int ovs_net_id __read_mostly;
 
-static void ovs_notify(struct sk_buff *skb, struct genl_info *info,
+static void ovs_notify(struct genl_family *family,
+		       struct sk_buff *skb, struct genl_info *info,
 		       struct genl_multicast_group *grp)
 {
-	genl_notify(skb, genl_info_net(info), info->snd_portid,
+	genl_notify(family, skb, genl_info_net(info), info->snd_portid,
 		    grp->id, info->nlhdr, GFP_KERNEL);
 }
 
@@ -877,7 +878,8 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 	ovs_unlock();
 
 	if (!IS_ERR(reply))
-		ovs_notify(reply, info, &ovs_dp_flow_multicast_group);
+		ovs_notify(&dp_flow_genl_family, reply, info,
+			   &ovs_dp_flow_multicast_group);
 	else
 		netlink_set_err(sock_net(skb->sk)->genl_sock, 0,
 				ovs_dp_flow_multicast_group.id, PTR_ERR(reply));
@@ -990,7 +992,8 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	ovs_flow_free(flow, true);
 	ovs_unlock();
 
-	ovs_notify(reply, info, &ovs_dp_flow_multicast_group);
+	ovs_notify(&dp_flow_genl_family, reply, info,
+		   &ovs_dp_flow_multicast_group);
 	return 0;
 unlock:
 	ovs_unlock();
@@ -1237,7 +1240,8 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 
 	ovs_unlock();
 
-	ovs_notify(reply, info, &ovs_dp_datapath_multicast_group);
+	ovs_notify(&dp_datapath_genl_family, reply, info,
+		   &ovs_dp_datapath_multicast_group);
 	return 0;
 
 err_destroy_local_port:
@@ -1302,7 +1306,8 @@ static int ovs_dp_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	__dp_destroy(dp);
 	ovs_unlock();
 
-	ovs_notify(reply, info, &ovs_dp_datapath_multicast_group);
+	ovs_notify(&dp_datapath_genl_family, reply, info,
+		   &ovs_dp_datapath_multicast_group);
 
 	return 0;
 unlock:
@@ -1333,7 +1338,8 @@ static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	ovs_unlock();
-	ovs_notify(reply, info, &ovs_dp_datapath_multicast_group);
+	ovs_notify(&dp_datapath_genl_family, reply, info,
+		   &ovs_dp_datapath_multicast_group);
 
 	return 0;
 unlock:
@@ -1425,7 +1431,7 @@ static const struct nla_policy vport_policy[OVS_VPORT_ATTR_MAX + 1] = {
 	[OVS_VPORT_ATTR_OPTIONS] = { .type = NLA_NESTED },
 };
 
-static struct genl_family dp_vport_genl_family = {
+struct genl_family dp_vport_genl_family = {
 	.id = GENL_ID_GENERATE,
 	.hdrsize = sizeof(struct ovs_header),
 	.name = OVS_VPORT_FAMILY,
@@ -1595,7 +1601,8 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		goto exit_unlock;
 	}
 
-	ovs_notify(reply, info, &ovs_dp_vport_multicast_group);
+	ovs_notify(&dp_vport_genl_family, reply, info,
+		   &ovs_dp_vport_multicast_group);
 
 exit_unlock:
 	ovs_unlock();
@@ -1642,7 +1649,8 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	BUG_ON(err < 0);
 
 	ovs_unlock();
-	ovs_notify(reply, info, &ovs_dp_vport_multicast_group);
+	ovs_notify(&dp_vport_genl_family, reply, info,
+		   &ovs_dp_vport_multicast_group);
 	return 0;
 
 exit_free:
@@ -1679,7 +1687,8 @@ static int ovs_vport_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	err = 0;
 	ovs_dp_detach_port(vport);
 
-	ovs_notify(reply, info, &ovs_dp_vport_multicast_group);
+	ovs_notify(&dp_vport_genl_family, reply, info,
+		   &ovs_dp_vport_multicast_group);
 
 exit_unlock:
 	ovs_unlock();
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index d3d14a58..4067ea4 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -177,6 +177,7 @@ static inline struct vport *ovs_vport_ovsl(const struct datapath *dp, int port_n
 }
 
 extern struct notifier_block ovs_dp_device_notifier;
+extern struct genl_family dp_vport_genl_family;
 extern struct genl_multicast_group ovs_dp_vport_multicast_group;
 
 void ovs_dp_process_received_packet(struct vport *, struct sk_buff *);
diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
index 5c2dab2..aa29d85 100644
--- a/net/openvswitch/dp_notify.c
+++ b/net/openvswitch/dp_notify.c
@@ -40,7 +40,8 @@ static void dp_detach_port_notify(struct vport *vport)
 		return;
 	}
 
-	genlmsg_multicast_netns(ovs_dp_get_net(dp), notify, 0,
+	genlmsg_multicast_netns(&dp_vport_genl_family,
+				ovs_dp_get_net(dp), notify, 0,
 				ovs_dp_vport_multicast_group.id,
 				GFP_KERNEL);
 }
diff --git a/net/wimax/op-msg.c b/net/wimax/op-msg.c
index ff19cbe..f37dd3c 100644
--- a/net/wimax/op-msg.c
+++ b/net/wimax/op-msg.c
@@ -279,7 +279,8 @@ int wimax_msg_send(struct wimax_dev *wimax_dev, struct sk_buff *skb)
 
 	d_printf(1, dev, "CTX: wimax msg, %zu bytes\n", size);
 	d_dump(2, dev, msg, size);
-	genlmsg_multicast(skb, 0, wimax_gnl_mcg.id, GFP_KERNEL);
+	genlmsg_multicast(&wimax_gnl_family, skb, 0,
+			  wimax_gnl_mcg.id, GFP_KERNEL);
 	d_printf(1, dev, "CTX: genl multicast done\n");
 	return 0;
 }
diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index 6328afe..1888874 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -177,7 +177,8 @@ int wimax_gnl_re_state_change_send(
 		goto out;
 	}
 	genlmsg_end(report_skb, header);
-	genlmsg_multicast(report_skb, 0, wimax_gnl_mcg.id, GFP_KERNEL);
+	genlmsg_multicast(&wimax_gnl_family, report_skb, 0,
+			  wimax_gnl_mcg.id, GFP_KERNEL);
 out:
 	d_fnend(3, dev, "(wimax_dev %p report_skb %p) = %d\n",
 		wimax_dev, report_skb, result);
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 1b6c5dd..f20edfd 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -6868,7 +6868,7 @@ void cfg80211_testmode_event(struct sk_buff *skb, gfp_t gfp)
 
 	nla_nest_end(skb, data);
 	genlmsg_end(skb, hdr);
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), skb, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), skb, 0,
 				nl80211_testmode_mcgrp.id, gfp);
 }
 EXPORT_SYMBOL(cfg80211_testmode_event);
@@ -9597,7 +9597,7 @@ void nl80211_notify_dev_rename(struct cfg80211_registered_device *rdev)
 		return;
 	}
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_config_mcgrp.id, GFP_KERNEL);
 }
 
@@ -9707,7 +9707,7 @@ void nl80211_send_scan_start(struct cfg80211_registered_device *rdev,
 		return;
 	}
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_scan_mcgrp.id, GFP_KERNEL);
 }
 
@@ -9726,7 +9726,7 @@ void nl80211_send_scan_done(struct cfg80211_registered_device *rdev,
 		return;
 	}
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_scan_mcgrp.id, GFP_KERNEL);
 }
 
@@ -9745,7 +9745,7 @@ void nl80211_send_scan_aborted(struct cfg80211_registered_device *rdev,
 		return;
 	}
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_scan_mcgrp.id, GFP_KERNEL);
 }
 
@@ -9764,7 +9764,7 @@ void nl80211_send_sched_scan_results(struct cfg80211_registered_device *rdev,
 		return;
 	}
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_scan_mcgrp.id, GFP_KERNEL);
 }
 
@@ -9782,7 +9782,7 @@ void nl80211_send_sched_scan(struct cfg80211_registered_device *rdev,
 		return;
 	}
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_scan_mcgrp.id, GFP_KERNEL);
 }
 
@@ -9837,8 +9837,8 @@ void nl80211_send_reg_change_event(struct regulatory_request *request)
 	genlmsg_end(msg, hdr);
 
 	rcu_read_lock();
-	genlmsg_multicast_allns(msg, 0, nl80211_regulatory_mcgrp.id,
-				GFP_ATOMIC);
+	genlmsg_multicast_allns(&nl80211_fam, msg, 0,
+				nl80211_regulatory_mcgrp.id, GFP_ATOMIC);
 	rcu_read_unlock();
 
 	return;
@@ -9873,7 +9873,7 @@ static void nl80211_send_mlme_event(struct cfg80211_registered_device *rdev,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -9961,7 +9961,7 @@ static void nl80211_send_mlme_timeout(struct cfg80211_registered_device *rdev,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -10017,7 +10017,7 @@ void nl80211_send_connect_result(struct cfg80211_registered_device *rdev,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -10056,7 +10056,7 @@ void nl80211_send_roamed(struct cfg80211_registered_device *rdev,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -10094,7 +10094,7 @@ void nl80211_send_disconnected(struct cfg80211_registered_device *rdev,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, GFP_KERNEL);
 	return;
 
@@ -10128,7 +10128,7 @@ void nl80211_send_ibss_bssid(struct cfg80211_registered_device *rdev,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -10169,7 +10169,7 @@ void cfg80211_notify_new_peer_candidate(struct net_device *dev, const u8 *addr,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -10208,7 +10208,7 @@ void nl80211_michael_mic_failure(struct cfg80211_registered_device *rdev,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -10261,8 +10261,8 @@ void nl80211_send_beacon_hint_event(struct wiphy *wiphy,
 	genlmsg_end(msg, hdr);
 
 	rcu_read_lock();
-	genlmsg_multicast_allns(msg, 0, nl80211_regulatory_mcgrp.id,
-				GFP_ATOMIC);
+	genlmsg_multicast_allns(&nl80211_fam, msg, 0,
+				nl80211_regulatory_mcgrp.id, GFP_ATOMIC);
 	rcu_read_unlock();
 
 	return;
@@ -10307,7 +10307,7 @@ static void nl80211_send_remain_on_chan_event(
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -10362,7 +10362,7 @@ void cfg80211_new_sta(struct net_device *dev, const u8 *mac_addr,
 		return;
 	}
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 }
 EXPORT_SYMBOL(cfg80211_new_sta);
@@ -10392,7 +10392,7 @@ void cfg80211_del_sta(struct net_device *dev, const u8 *mac_addr, gfp_t gfp)
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -10428,7 +10428,7 @@ void cfg80211_conn_failed(struct net_device *dev, const u8 *mac_addr,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -10590,7 +10590,7 @@ void cfg80211_mgmt_tx_status(struct wireless_dev *wdev, u64 cookie,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -10639,7 +10639,7 @@ void cfg80211_cqm_rssi_notify(struct net_device *dev,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -10684,7 +10684,7 @@ static void nl80211_gtk_rekey_notify(struct cfg80211_registered_device *rdev,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -10742,7 +10742,7 @@ nl80211_pmksa_candidate_notify(struct cfg80211_registered_device *rdev,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -10789,7 +10789,7 @@ static void nl80211_ch_switch_notify(struct cfg80211_registered_device *rdev,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -10866,7 +10866,7 @@ void cfg80211_cqm_txe_notify(struct net_device *dev,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -10915,7 +10915,7 @@ nl80211_radar_notify(struct cfg80211_registered_device *rdev,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -10962,7 +10962,7 @@ void cfg80211_cqm_pktloss_notify(struct net_device *dev,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -11002,7 +11002,7 @@ void cfg80211_probe_status(struct net_device *dev, const u8 *addr,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -11154,7 +11154,7 @@ void cfg80211_report_wowlan_wakeup(struct wireless_dev *wdev,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -11196,7 +11196,7 @@ void cfg80211_tdls_oper_request(struct net_device *dev, const u8 *peer,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, gfp);
 	return;
 
@@ -11279,7 +11279,7 @@ void cfg80211_ft_event(struct net_device *netdev,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_multicast_netns(wiphy_net(&rdev->wiphy), msg, 0,
+	genlmsg_multicast_netns(&nl80211_fam, wiphy_net(&rdev->wiphy), msg, 0,
 				nl80211_mlme_mcgrp.id, GFP_KERNEL);
 }
 EXPORT_SYMBOL(cfg80211_ft_event);
-- 
1.8.4.rc3
