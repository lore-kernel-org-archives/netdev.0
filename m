From: Thierry Du Tre <thierry@dtsystems.be>
Subject: [PATCH] vlan: support ingress/egress priority map flushing
Date: Fri, 10 Mar 2017 15:41:35 +0100
Message-ID: <4d3ee617-df9d-eed7-ced6-1458b3f92a1a@dtsystems.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35537 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932784AbdCJOln (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 09:41:43 -0500
Received: by mail-wr0-f196.google.com with SMTP id u108so11875240wrb.2
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 06:41:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sending packets via a vlan device we can manipulate the priority bits in the vlan header (PCP) via a mapping based on tc class value.
Similarly, when packets are received via a vlan device, the PCP value can be mapped onto a tc class value, which is available for iptables rules and tc queueing disciplines.

One can use the vconfig utility to set both ingress and egress mapping entries (set_ingress_map/set_egress_map) or any other application to call the vlan ioctl handler.

The resulting map can be printed via /proc/net/vlan/<ifname> , i.e. :
# cat /proc/net/vlan/vlan11
vlan11  VID: 11  REORDER_HDR: 1  dev->priv_flags: 1
          total frames received     52331849
           total bytes received  17451834908
       Broadcast/Multicast Rcvd      1525155

       total frames transmitted     98569270
        total bytes transmitted 144870211289
Device: eth_test
INGRESS priority mappings: 0:0  1:1  2:2  3:3  4:0  5:0  6:0 7:0
  EGRESS priority mappings: 0:7

The current API offers only GET and SET operations, and when actually using this functionality a flush is missing to reset all entries.
This patch adds a FLUSH operation for both ingress and egress map which can then be used by vconfig or other applications.

Signed-off-by: Thierry Du Tre <thierry@dtsystems.be>
---
  include/uapi/linux/if_vlan.h |  2 ++
  net/8021q/vlan.c             | 16 ++++++++++++++++
  net/8021q/vlan.h             |  2 ++
  net/8021q/vlan_dev.c         | 23 +++++++++++++++++++++++
  4 files changed, 43 insertions(+)

diff --git a/include/uapi/linux/if_vlan.h b/include/uapi/linux/if_vlan.h
index 7e5e6b3..6bdff52 100644
--- a/include/uapi/linux/if_vlan.h
+++ b/include/uapi/linux/if_vlan.h
@@ -20,6 +20,8 @@
  enum vlan_ioctl_cmds {
  	ADD_VLAN_CMD,
  	DEL_VLAN_CMD,
+	FLUSH_VLAN_INGRESS_PRIORITY_CMD,
+	FLUSH_VLAN_EGRESS_PRIORITY_CMD,
  	SET_VLAN_INGRESS_PRIORITY_CMD,
  	SET_VLAN_EGRESS_PRIORITY_CMD,
  	GET_VLAN_INGRESS_PRIORITY_CMD,
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 467069b..8988419 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -539,6 +539,22 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
  	}
  
  	switch (args.cmd) {
+	case FLUSH_VLAN_INGRESS_PRIORITY_CMD:
+		err = -EPERM;
+		if (!capable(CAP_NET_ADMIN))
+			break;
+		vlan_dev_flush_ingress_priority(dev);
+		err = 0;
+		break;
+
+	case FLUSH_VLAN_EGRESS_PRIORITY_CMD:
+		err = -EPERM;
+		if (!capable(CAP_NET_ADMIN))
+			break;
+		vlan_dev_flush_egress_priority(dev);
+		err = 0;
+		break;
+
  	case SET_VLAN_INGRESS_PRIORITY_CMD:
  		err = -EPERM;
  		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index df8bd65..d8d90ca 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -97,6 +97,8 @@ static inline struct net_device *vlan_find_dev(struct net_device *real_dev,
  							    (i) % VLAN_N_VID)))
  
  /* found in vlan_dev.c */
+void vlan_dev_flush_ingress_priority(const struct net_device *dev);
+void vlan_dev_flush_egress_priority(const struct net_device *dev);
  void vlan_dev_set_ingress_priority(const struct net_device *dev,
  				   u32 skb_prio, u16 vlan_prio);
  int vlan_dev_set_egress_priority(const struct net_device *dev,
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index e97ab82..8fd91c3 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -159,6 +159,29 @@ static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
  	return 0;
  }
  
+void vlan_dev_flush_ingress_priority(const struct net_device *dev)
+{
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
+
+	memset(vlan->ingress_priority_map, 0, sizeof(vlan->ingress_priority_map));
+	vlan->nr_ingress_mappings = 0;
+}
+
+void vlan_dev_flush_egress_priority(const struct net_device *dev)
+{
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
+	struct vlan_priority_tci_mapping *mp;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(vlan->egress_priority_map); i++) {
+		while ((mp = vlan->egress_priority_map[i]) != NULL) {
+			vlan->egress_priority_map[i] = mp->next;
+			kfree(mp);
+		}
+	}
+	vlan->nr_egress_mappings = 0;
+}
+
  void vlan_dev_set_ingress_priority(const struct net_device *dev,
  				   u32 skb_prio, u16 vlan_prio)
  {
-- 
2.7.4
