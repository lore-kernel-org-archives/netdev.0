From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 5/6] vlan: introduce functions to do mass addition/deletion of vids by another device
Date: Thu,  8 Dec 2011 15:11:19 +0100
Message-ID: <1323353480-1900-6-git-send-email-jpirko@redhat.com>
References: <1323353480-1900-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	ebiederm@xmission.com, mirqus@gmail.com, kaber@trash.net,
	greearb@candelatech.com, jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34115 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752776Ab1LHOLu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 09:11:50 -0500
In-Reply-To: <1323353480-1900-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce functions handy to copy vlan ids from one driver's list to
another.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/if_vlan.h |   15 +++++++++++++++
 net/8021q/vlan_core.c   |   44 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 0c96913..13aff1e 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -97,6 +97,10 @@ extern struct sk_buff *vlan_untag(struct sk_buff *skb);
 extern int vlan_vid_add(struct net_device *dev, unsigned short vid);
 extern void vlan_vid_del(struct net_device *dev, unsigned short vid);
 
+extern int vlan_vids_add_by_dev(struct net_device *dev,
+				const struct net_device *by_dev);
+extern void vlan_vids_del_by_dev(struct net_device *dev,
+				 const struct net_device *by_dev);
 #else
 static inline struct net_device *
 __vlan_find_dev_deep(struct net_device *real_dev, u16 vlan_id)
@@ -136,6 +140,17 @@ static inline int vlan_vid_add(struct net_device *dev, unsigned short vid)
 static inline void vlan_vid_del(struct net_device *dev, unsigned short vid)
 {
 }
+
+static inline int vlan_vids_add_by_dev(struct net_device *dev,
+				       const struct net_device *by_dev)
+{
+	return 0;
+}
+
+static inline void vlan_vids_del_by_dev(struct net_device *dev,
+					const struct net_device *by_dev)
+{
+}
 #endif
 
 /**
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 329e031..1414c93 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -321,3 +321,47 @@ void vlan_vid_del(struct net_device *dev, unsigned short vid)
 	}
 }
 EXPORT_SYMBOL(vlan_vid_del);
+
+int vlan_vids_add_by_dev(struct net_device *dev,
+			 const struct net_device *by_dev)
+{
+	struct vlan_vid_info *vid_info;
+	int err;
+
+	ASSERT_RTNL();
+
+	if (!by_dev->vlan_info)
+		return 0;
+
+	list_for_each_entry(vid_info, &by_dev->vlan_info->vid_list, list) {
+		err = vlan_vid_add(dev, vid_info->vid);
+		if (err)
+			goto unwind;
+	}
+	return 0;
+
+unwind:
+	list_for_each_entry_continue_reverse(vid_info,
+					     &by_dev->vlan_info->vid_list,
+					     list) {
+		vlan_vid_del(dev, vid_info->vid);
+	}
+
+	return err;
+}
+EXPORT_SYMBOL(vlan_vids_add_by_dev);
+
+void vlan_vids_del_by_dev(struct net_device *dev,
+			  const struct net_device *by_dev)
+{
+	struct vlan_vid_info *vid_info;
+
+	ASSERT_RTNL();
+
+	if (!by_dev->vlan_info)
+		return;
+
+	list_for_each_entry(vid_info, &by_dev->vlan_info->vid_list, list)
+		vlan_vid_del(dev, vid_info->vid);
+}
+EXPORT_SYMBOL(vlan_vids_del_by_dev);
-- 
1.7.6
