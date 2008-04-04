From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][VLAN]: Fix egress priority mappings leak.
Date: Fri, 04 Apr 2008 14:07:19 +0400
Message-ID: <47F5FDD7.1060608@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47191 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752325AbYDDJnw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 05:43:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These entries are allocated in vlan_dev_set_egress_priority, 
but are never released and leaks on vlan device removal.

Drop these in vlan's ->uninit callback - after the device is 
brought down and everyone is notified about it is going to
be unregistered.

Found during testing vlan netnsization patchset.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 480ea90..41a76a0 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -692,6 +692,20 @@ static int vlan_dev_init(struct net_device *dev)
 	return 0;
 }
 
+static void vlan_dev_uninit(struct net_device *dev)
+{
+	struct vlan_priority_tci_mapping *pm;
+	struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(vlan->egress_priority_map); i++) {
+		while ((pm = vlan->egress_priority_map[i]) != NULL) {
+			vlan->egress_priority_map[i] = pm->next;
+			kfree(pm);
+		}
+	}
+}
+
 void vlan_setup(struct net_device *dev)
 {
 	ether_setup(dev);
@@ -701,6 +715,7 @@ void vlan_setup(struct net_device *dev)
 
 	dev->change_mtu		= vlan_dev_change_mtu;
 	dev->init		= vlan_dev_init;
+	dev->uninit		= vlan_dev_uninit;
 	dev->open		= vlan_dev_open;
 	dev->stop		= vlan_dev_stop;
 	dev->set_mac_address	= vlan_dev_set_mac_address;
