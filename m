From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/8] net: dsa: cleanup resources upon module removal
Date: Mon, 12 Jan 2015 13:57:42 -0800
Message-ID: <1421099866-3184-5-git-send-email-f.fainelli@gmail.com>
References: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, buytenh@wantstofly.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:58806 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129AbbALV56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 16:57:58 -0500
Received: by mail-pd0-f172.google.com with SMTP id y13so32689918pdi.3
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 13:57:57 -0800 (PST)
In-Reply-To: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were not doing anything while removing the dsa module, which means
that we were leaving dangling network devices without any sort of driver
backing them, leading to all sorts of crashes. Make sure that we do
cleanup the slave network devices, slave MII bus we created, and
unassign the master_netdev dsa_ptr to make the packet processing go
through the regulard Ethernet receive path.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c      | 19 +++++++++++++++++++
 net/dsa/dsa_priv.h |  1 +
 net/dsa/slave.c    | 14 ++++++++++++++
 3 files changed, 34 insertions(+)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index de77c83cfd9a..df7ec066ac64 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -316,10 +316,22 @@ out:
 
 static void dsa_switch_destroy(struct dsa_switch *ds)
 {
+	int i;
 #ifdef CONFIG_NET_DSA_HWMON
 	if (ds->hwmon_dev)
 		hwmon_device_unregister(ds->hwmon_dev);
 #endif
+
+	for (i = 0; i < DSA_MAX_PORTS; i++) {
+		if (!(ds->phys_port_mask & (1 << i)))
+			continue;
+
+		dsa_slave_destroy(ds->ports[i]);
+	}
+
+	mdiobus_unregister(ds->slave_mii_bus);
+	mdiobus_free(ds->slave_mii_bus);
+	kfree(ds);
 }
 
 #ifdef CONFIG_PM_SLEEP
@@ -754,6 +766,13 @@ static int dsa_remove(struct platform_device *pdev)
 			dsa_switch_destroy(ds);
 	}
 
+	dst->master_netdev->dsa_ptr = NULL;
+	/* If we used a tagging format that doesn't have an ethertype
+	 * field, make sure that all packets from this point get sent
+	 * without the tag and go through the regular receive path.
+	 */
+	wmb();
+
 	dsa_of_remove(pdev);
 
 	return 0;
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 1397b2894c1f..1773b2a20d90 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -61,6 +61,7 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds);
 struct net_device *dsa_slave_create(struct dsa_switch *ds,
 				    struct device *parent,
 				    int port, char *name);
+void dsa_slave_destroy(struct net_device *slave_dev);
 int dsa_slave_suspend(struct net_device *slave_dev);
 int dsa_slave_resume(struct net_device *slave_dev);
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 515569ffde8a..043cffcb1a3a 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -690,3 +690,17 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 
 	return slave_dev;
 }
+
+void dsa_slave_destroy(struct net_device *slave_dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(slave_dev);
+
+	if (p->phy) {
+		/* Prevent further updates */
+		fixed_phy_set_link_update(p->phy, NULL);
+		phy_disconnect(p->phy);
+	}
+
+	unregister_netdev(slave_dev);
+	free_netdev(slave_dev);
+}
-- 
2.1.0
