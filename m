From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 08/11] net: dsa: allow updating fixed PHY link information
Date: Tue, 13 May 2014 22:00:34 -0700
Message-ID: <1400043637-9799-9-git-send-email-f.fainelli@gmail.com>
References: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	nhorman@tuxdriver.com, andy@greyhouse.net, tgraf@suug.ch,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@cumulusnetworks.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:41568 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753898AbaENFBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 01:01:31 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so1179326pad.16
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 22:01:30 -0700 (PDT)
In-Reply-To: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow switch drivers to hook a PHY link update callback to perform
port-specific link work.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h |  3 +++
 net/dsa/slave.c   | 18 +++++++++++++++++-
 2 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index a19bda9e260b..1aa40a0491d4 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -17,6 +17,7 @@
 #include <linux/workqueue.h>
 #include <linux/of.h>
 #include <linux/phy.h>
+#include <linux/phy_fixed.h>
 
 #define DSA_MAX_SWITCHES	4
 #define DSA_MAX_PORTS		12
@@ -183,6 +184,8 @@ struct dsa_switch_driver {
 	 */
 	void	(*adjust_link)(struct dsa_switch *ds, int port,
 				struct phy_device *phydev);
+	void	(*fixed_link_update)(struct dsa_switch *ds, int port,
+				struct fixed_phy_status *st);
 
 	/*
 	 * ethtool hardware statistics.
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 8ed94dab1867..791b0899e7ee 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -381,6 +381,18 @@ static void dsa_slave_adjust_link(struct net_device *dev)
 		phy_print_status(p->phy);
 }
 
+static int dsa_slave_fixed_link_update(struct net_device *dev,
+					struct fixed_phy_status *status)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (ds->drv->fixed_link_update)
+		ds->drv->fixed_link_update(ds, p->port, status);
+
+	return 0;
+}
+
 /* slave device setup *******************************************************/
 static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 		struct net_device *slave_dev)
@@ -396,10 +408,14 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 		p->phy = of_phy_connect(slave_dev, phy_dn,
 				dsa_slave_adjust_link, 0,
 				p->phy_interface);
-	else
+	else {
 		p->phy = of_phy_connect_fixed_link(slave_dev,
 				dsa_slave_adjust_link,
 				p->phy_interface);
+		if (p->phy)
+			fixed_phy_set_link_update(p->phy,
+					dsa_slave_fixed_link_update);
+	}
 
 	/* We could not connect to a designated PHY, so use the switch internal
 	 * MDIO bus instead
-- 
1.9.1
