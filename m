From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 2/7] ipv4: ipmr: Add the parent ID field to VIF struct
Date: Tue,  3 Oct 2017 09:58:07 +0200
Message-ID: <20171003075812.1540-3-jiri@resnulli.us>
References: <20171003075812.1540-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, nikolay@cumulusnetworks.com, andrew@lunn.ch,
        dsa@cumulusnetworks.com, edumazet@google.com, willemb@google.com,
        johannes.berg@intel.com, dcaratti@redhat.com, pabeni@redhat.com,
        daniel@iogearbox.net, f.fainelli@gmail.com, fw@strlen.de,
        gfree.wind@vip.163.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:57045 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751059AbdJCH6Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 03:58:16 -0400
Received: by mail-wm0-f65.google.com with SMTP id l68so1115415wmd.5
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 00:58:15 -0700 (PDT)
In-Reply-To: <20171003075812.1540-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

In order to allow the ipmr module to do partial multicast forwarding
according to the device parent ID, add the device parent ID field to the
VIF struct. This way, the forwarding path can use the parent ID field
without invoking switchdev calls, which requires the RTNL lock.

When a new VIF is added, set the device parent ID field in it by invoking
the switchdev_port_attr_get call.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
 - Set the vif->dev_parent_id.len field
 - Remove the vif->dev_parent_id_valid field and use len instead
 - Set the vif->dev_parent_id to invalid if the device does not support the
   switchdev PARENT_ID attribute
---
 include/linux/mroute.h |  1 +
 net/ipv4/ipmr.c        | 11 +++++++++++
 2 files changed, 12 insertions(+)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index b072a84..8242d05 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -57,6 +57,7 @@ static inline bool ipmr_rule_default(const struct fib_rule *rule)
 
 struct vif_device {
 	struct net_device 	*dev;			/* Device we are using */
+	struct netdev_phys_item_id dev_parent_id;	/* Device parent ID    */
 	unsigned long	bytes_in,bytes_out;
 	unsigned long	pkt_in,pkt_out;		/* Statistics 			*/
 	unsigned long	rate_limit;		/* Traffic shaping (NI) 	*/
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a844738..1b161ad 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -67,6 +67,7 @@
 #include <net/fib_rules.h>
 #include <linux/netconf.h>
 #include <net/nexthop.h>
+#include <net/switchdev.h>
 
 struct ipmr_rule {
 	struct fib_rule		common;
@@ -868,6 +869,9 @@ static int vif_add(struct net *net, struct mr_table *mrt,
 		   struct vifctl *vifc, int mrtsock)
 {
 	int vifi = vifc->vifc_vifi;
+	struct switchdev_attr attr = {
+		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
+	};
 	struct vif_device *v = &mrt->vif_table[vifi];
 	struct net_device *dev;
 	struct in_device *in_dev;
@@ -942,6 +946,13 @@ static int vif_add(struct net *net, struct mr_table *mrt,
 
 	/* Fill in the VIF structures */
 
+	attr.orig_dev = dev;
+	if (!switchdev_port_attr_get(dev, &attr)) {
+		memcpy(v->dev_parent_id.id, attr.u.ppid.id, attr.u.ppid.id_len);
+		v->dev_parent_id.id_len = attr.u.ppid.id_len;
+	} else {
+		v->dev_parent_id.id_len = 0;
+	}
 	v->rate_limit = vifc->vifc_rate_limit;
 	v->local = vifc->vifc_lcl_addr.s_addr;
 	v->remote = vifc->vifc_rmt_addr.s_addr;
-- 
2.9.5
