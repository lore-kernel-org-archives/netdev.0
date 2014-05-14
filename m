From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 07/11] net: dsa: allow drivers to do link adjustment
Date: Tue, 13 May 2014 22:00:33 -0700
Message-ID: <1400043637-9799-8-git-send-email-f.fainelli@gmail.com>
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
Received: from mail-pa0-f41.google.com ([209.85.220.41]:53938 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753904AbaENFB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 01:01:28 -0400
Received: by mail-pa0-f41.google.com with SMTP id lj1so1194084pab.0
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 22:01:27 -0700 (PDT)
In-Reply-To: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whenever libphy determines that the link status of a given PHY/port has
changed, allow to call into the switch driver link adjustment callback
so proper actions can be taken care of by the switch driver.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h | 7 +++++++
 net/dsa/slave.c   | 4 ++++
 2 files changed, 11 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index c435eaa772d5..a19bda9e260b 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -16,6 +16,7 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/of.h>
+#include <linux/phy.h>
 
 #define DSA_MAX_SWITCHES	4
 #define DSA_MAX_PORTS		12
@@ -178,6 +179,12 @@ struct dsa_switch_driver {
 	void	(*poll_link)(struct dsa_switch *ds);
 
 	/*
+	 * Link state adjustment (called from libphy)
+	 */
+	void	(*adjust_link)(struct dsa_switch *ds, int port,
+				struct phy_device *phydev);
+
+	/*
 	 * ethtool hardware statistics.
 	 */
 	void	(*get_strings)(struct dsa_switch *ds, int port, uint8_t *data);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 7b190b6f64e4..8ed94dab1867 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -356,6 +356,7 @@ static const struct net_device_ops dummy_netdev_ops = {
 static void dsa_slave_adjust_link(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
 	unsigned int status_changed = 0;
 
 	if (p->old_link != p->phy->link) {
@@ -373,6 +374,9 @@ static void dsa_slave_adjust_link(struct net_device *dev)
 		p->old_pause = p->phy->pause;
 	}
 
+	if (ds->drv->adjust_link && status_changed)
+		ds->drv->adjust_link(ds, p->port, p->phy);
+
 	if (status_changed)
 		phy_print_status(p->phy);
 }
-- 
1.9.1
