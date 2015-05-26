From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] openvswitch: disable LRO unless stated otherwise
Date: Tue, 26 May 2015 19:38:29 +0200
Message-ID: <15f0c96df9cc152b05d8a5ff0c0059eb1f042cca.1432661690.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53747 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751243AbbEZRjF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2015 13:39:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, openvswitch tries to disable LRO from the user space. This does
not work correctly when the device added is a vlan interface, though.
Instead of dealing with possibly complex stacked cross name space relations
in the user space, do the same as bridging does and call dev_disable_lro in
the kernel.

As there are use cases of openvswitch setup that can keep LRO enabled and
there's a planned feature to optimize such use cases (and stop disabling LRO
unconditionally from the user space daemon), allow the user space to
override this when adding the interface.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/uapi/linux/openvswitch.h | 9 +++++++++
 net/openvswitch/vport-netdev.c   | 3 +++
 2 files changed, 12 insertions(+)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index bbd49a0c46c7..3832953a4f27 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -252,6 +252,15 @@ enum ovs_vport_attr {
 
 #define OVS_VPORT_ATTR_MAX (__OVS_VPORT_ATTR_MAX - 1)
 
+/* OVS_VPORT_ATTR_OPTIONS attributes for netdev vports.
+ */
+enum {
+	OVS_NETDEV_ATTR_KEEP_LRO, /* flag */
+	__OVS_NETDEV_ATTR_MAX
+};
+
+#define OVS_NETDEV_ATTR_MAX (__OVS_NETDEV_ATTR_MAX - 1)
+
 enum {
 	OVS_VXLAN_EXT_UNSPEC,
 	OVS_VXLAN_EXT_GBP,	/* Flag or __u32 */
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 4776282c6417..04391b6cfb9a 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -125,6 +125,9 @@ static struct vport *netdev_create(const struct vport_parms *parms)
 	if (err)
 		goto error_master_upper_dev_unlink;
 
+	if (!parms->options ||
+	    !nla_find_nested(parms->options, OVS_NETDEV_ATTR_KEEP_LRO))
+		dev_disable_lro(netdev_vport->dev);
 	dev_set_promiscuity(netdev_vport->dev, 1);
 	netdev_vport->dev->priv_flags |= IFF_OVS_DATAPATH;
 	rtnl_unlock();
-- 
1.8.3.1
