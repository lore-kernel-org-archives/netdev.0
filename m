From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] linux-2.4: vlan: Slab memleak fix
Date: Mon, 29 Jun 2009 16:43:27 +0100
Message-ID: <20090629154325.GB18570@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank Seidel <Frank.Seidel@sphairon.com>,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h5.dl5rb.org.uk ([81.2.74.5]:42981 "EHLO h5.dl5rb.org.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751999AbZF2Pnn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 11:43:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arne Redlich <readlicha@sphairon.com>

Fix slab memleak on wan service restart

Signed-off-by: Arne Redlich <redlicha@sphairon.com>
Signed-off-by: Frank Seidel <Frank.Seidel@sphairon.com>
Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
---
 net/8021q/vlan_dev.c |   22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -548,6 +548,22 @@ int vlan_dev_set_ingress_priority(char *
 	return -EINVAL;
 }
 
+/* Remove all egress_priority_map hash table entries. --redlicha */
+static void vlan_dev_destroy_egress_priority_map(struct net_device *dev)
+{
+	struct vlan_dev_info *info = VLAN_DEV_INFO(dev);
+	struct vlan_priority_tci_mapping *m;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(info->egress_priority_map); i++) {
+		while ((m = info->egress_priority_map[i])) {
+			info->egress_priority_map[i] =
+				info->egress_priority_map[i]->next;
+			kfree(m);
+		}
+	}
+}
+
 int vlan_dev_set_egress_priority(char *dev_name, __u32 skb_prio, short vlan_prio)
 {
 	struct net_device *dev = dev_get_by_name(dev_name);
@@ -826,7 +842,11 @@ void vlan_dev_destruct(struct net_device
 		if (dev->priv) {
 			if (VLAN_DEV_INFO(dev)->dent)
 				BUG();
-
+			/*
+			 * Don't leak the hash table entries in
+			 * VLAN_DEV_INFO(dev)->egress_priority_map! --redlicha
+			 */
+			vlan_dev_destroy_egress_priority_map(dev);
 			kfree(dev->priv);
 			dev->priv = NULL;
 		}
