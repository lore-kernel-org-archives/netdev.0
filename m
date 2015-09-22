From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] genetlink: simplify genl_notify
Date: Tue, 22 Sep 2015 18:56:43 +0200
Message-ID: <b1f238bfc117e127fef538257a3c43aa06d015d7.1442940978.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42081 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758072AbbIVQ5C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 12:57:02 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (Postfix) with ESMTPS id DB51BAA8
	for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 16:57:01 +0000 (UTC)
Received: from griffin.localdomain (ovpn-204-71.brq.redhat.com [10.40.204.71])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t8MGv0NW018289
	for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 12:57:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The genl_notify function has too many arguments for no real reason - all
callers use genl_info to get them anyway. Just pass the genl_info down to
genl_notify.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/wireless/mac80211_hwsim.c |  5 ++---
 include/net/genetlink.h               |  5 ++---
 net/netlink/genetlink.c               | 12 ++++++------
 net/openvswitch/datapath.c            |  3 +--
 4 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 520bef80747f..66c963dbc3fd 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -2190,9 +2190,8 @@ static void hwsim_mcast_config_msg(struct sk_buff *mcast_skb,
 				   struct genl_info *info)
 {
 	if (info)
-		genl_notify(&hwsim_genl_family, mcast_skb,
-			    genl_info_net(info), info->snd_portid,
-			    HWSIM_MCGRP_CONFIG, info->nlhdr, GFP_KERNEL);
+		genl_notify(&hwsim_genl_family, mcast_skb, info,
+			    HWSIM_MCGRP_CONFIG, GFP_KERNEL);
 	else
 		genlmsg_multicast(&hwsim_genl_family, mcast_skb, 0,
 				  HWSIM_MCGRP_CONFIG, GFP_KERNEL);
diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index a9af1cc8c1bc..1b6b6dcb018d 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -183,9 +183,8 @@ _genl_register_family_with_ops_grps(struct genl_family *family,
 					    (grps), ARRAY_SIZE(grps))
 
 int genl_unregister_family(struct genl_family *family);
-void genl_notify(struct genl_family *family,
-		 struct sk_buff *skb, struct net *net, u32 portid,
-		 u32 group, struct nlmsghdr *nlh, gfp_t flags);
+void genl_notify(struct genl_family *family, struct sk_buff *skb,
+		 struct genl_info *info, u32 group, gfp_t flags);
 
 struct sk_buff *genlmsg_new_unicast(size_t payload, struct genl_info *info,
 				    gfp_t flags);
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 2ed5f964772e..75724a96aef2 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -1136,19 +1136,19 @@ int genlmsg_multicast_allns(struct genl_family *family, struct sk_buff *skb,
 }
 EXPORT_SYMBOL(genlmsg_multicast_allns);
 
-void genl_notify(struct genl_family *family,
-		 struct sk_buff *skb, struct net *net, u32 portid, u32 group,
-		 struct nlmsghdr *nlh, gfp_t flags)
+void genl_notify(struct genl_family *family, struct sk_buff *skb,
+		 struct genl_info *info, u32 group, gfp_t flags)
 {
+	struct net *net = genl_info_net(info);
 	struct sock *sk = net->genl_sock;
 	int report = 0;
 
-	if (nlh)
-		report = nlmsg_report(nlh);
+	if (info->nlhdr)
+		report = nlmsg_report(info->nlhdr);
 
 	if (WARN_ON_ONCE(group >= family->n_mcgrps))
 		return;
 	group = family->mcgrp_offset + group;
-	nlmsg_notify(sk, skb, portid, group, report, flags);
+	nlmsg_notify(sk, skb, info->snd_portid, group, report, flags);
 }
 EXPORT_SYMBOL(genl_notify);
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 6fbd2decb19e..2913594c5123 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -91,8 +91,7 @@ static bool ovs_must_notify(struct genl_family *family, struct genl_info *info,
 static void ovs_notify(struct genl_family *family,
 		       struct sk_buff *skb, struct genl_info *info)
 {
-	genl_notify(family, skb, genl_info_net(info), info->snd_portid,
-		    0, info->nlhdr, GFP_KERNEL);
+	genl_notify(family, skb, info, 0, GFP_KERNEL);
 }
 
 /**
-- 
1.8.3.1
