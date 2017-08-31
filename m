From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 6/8] net: dsa: Expose dsa_slave_dev_check and dsa_slave_dev_port_num
Date: Wed, 30 Aug 2017 17:18:50 -0700
Message-ID: <1504138732-65383-7-git-send-email-f.fainelli@gmail.com>
References: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
Cc: jiri@resnulli.us, jhs@mojatatu.com, davem@davemloft.net,
        xiyou.wangcong@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34230 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750814AbdHaA1I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 20:27:08 -0400
Received: by mail-wr0-f193.google.com with SMTP id z91so5007465wrc.1
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 17:27:08 -0700 (PDT)
In-Reply-To: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Expose two helper functions:
* one to verify if a net_device is a DSA slave network device
* one to obtain the physical port number associated with a DSA slave
  network device

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h | 15 +++++++++++++++
 net/dsa/slave.c   | 12 +++++++++---
 2 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index b10e8da3f8d7..649bd06f9fe4 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -459,6 +459,21 @@ static inline bool netdev_uses_dsa(struct net_device *dev)
 	return false;
 }
 
+#if IS_ENABLED(CONFIG_NET_DSA)
+bool dsa_slave_dev_check(struct net_device *dev);
+unsigned int dsa_slave_dev_port_num(struct net_device *dev);
+#else
+static inline bool dsa_slave_dev_check(struct net_device *dev)
+{
+	return false;
+}
+
+static inline dsa_slave_dev_port_num(struct net_device *dev)
+{
+	return DSA_MAX_PORTS;
+}
+#endif
+
 struct dsa_switch *dsa_switch_alloc(struct device *dev, size_t n);
 void dsa_unregister_switch(struct dsa_switch *ds);
 int dsa_register_switch(struct dsa_switch *ds);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index bfd7173a3c6a..302ae3326e3a 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -25,8 +25,6 @@
 
 #include "dsa_priv.h"
 
-static bool dsa_slave_dev_check(struct net_device *dev);
-
 /* slave mii_bus handling ***************************************************/
 static int dsa_slave_phy_read(struct mii_bus *bus, int addr, int reg)
 {
@@ -1346,10 +1344,18 @@ void dsa_slave_destroy(struct net_device *slave_dev)
 	free_netdev(slave_dev);
 }
 
-static bool dsa_slave_dev_check(struct net_device *dev)
+bool dsa_slave_dev_check(struct net_device *dev)
 {
 	return dev->netdev_ops == &dsa_slave_netdev_ops;
 }
+EXPORT_SYMBOL_GPL(dsa_slave_dev_check);
+
+unsigned int dsa_slave_dev_port_num(struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	return p->dp->index;
+}
+EXPORT_SYMBOL_GPL(dsa_slave_dev_port_num);
 
 static int dsa_slave_changeupper(struct net_device *dev,
 				 struct netdev_notifier_changeupper_info *info)
-- 
1.9.1
