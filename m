From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 10/10][VLAN]: Handle vlan devices net namespace
 changing.
Date: Tue, 15 Apr 2008 16:19:17 +0400
Message-ID: <48049D45.5020606@openvz.org>
References: <4804989F.1060503@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:36749 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753428AbYDOLpC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 07:45:02 -0400
In-Reply-To: <4804989F.1060503@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When van device is moved to another namespace proc files,
related to this device, should also change one.

Use the netdev REGISTER and UNREGISTER event handlers for this.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/8021q/vlan.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 7e9d22e..2a739ad 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -154,8 +154,6 @@ void unregister_vlan_dev(struct net_device *dev)
 	grp = __vlan_find_group(real_dev);
 	BUG_ON(!grp);
 
-	vlan_proc_rem_dev(dev);
-
 	/* Take it out of our own structures, but be sure to interlock with
 	 * HW accelerating devices or SW vlan input packet processing.
 	 */
@@ -278,9 +276,6 @@ int register_vlan_dev(struct net_device *dev)
 	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
 		real_dev->vlan_rx_add_vid(real_dev, vlan_id);
 
-	if (vlan_proc_add_dev(dev) < 0)
-		pr_warning("8021q: failed to add proc entry for %s\n",
-			   dev->name);
 	return 0;
 
 out_free_group:
@@ -396,6 +391,14 @@ static void __vlan_device_event(struct net_device *dev, unsigned long event)
 			pr_warning("8021q: failed to change proc name for %s\n",
 					dev->name);
 		break;
+	case NETDEV_REGISTER:
+		if (vlan_proc_add_dev(dev) < 0)
+			pr_warning("8021q: failed to add proc entry for %s\n",
+					dev->name);
+		break;
+	case NETDEV_UNREGISTER:
+		vlan_proc_rem_dev(dev);
+		break;
 	}
 }
 
-- 
1.5.3.4

