From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net/ncsi: fix ncsi_vlan_rx_{add,kill}_vid references
Date: Tue,  5 Sep 2017 10:05:47 +0200
Message-ID: <20170905080615.1131665-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Joel Stanley <joel@jms.id.au>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Gavin Shan <gwshan@linux.vnet.ibm.com>,
        Samuel Mendoza-Jonas <sam@mendozajonas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:52981 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750814AbdIEIGb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 04:06:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We get a new link error in allmodconfig kernels after ftgmac100
started using the ncsi helpers:

ERROR: "ncsi_vlan_rx_kill_vid" [drivers/net/ethernet/faraday/ftgmac100.ko] undefined!
ERROR: "ncsi_vlan_rx_add_vid" [drivers/net/ethernet/faraday/ftgmac100.ko] undefined!

Related to that, we get another error when CONFIG_NET_NCSI is disabled:

drivers/net/ethernet/faraday/ftgmac100.c:1626:25: error: 'ncsi_vlan_rx_add_vid' undeclared here (not in a function); did you mean 'ncsi_start_dev'?
drivers/net/ethernet/faraday/ftgmac100.c:1627:26: error: 'ncsi_vlan_rx_kill_vid' undeclared here (not in a function); did you mean 'ncsi_vlan_rx_add_vid'?

This fixes both problems at once, using a 'static inline' stub helper
for the disabled case, and exporting the functions when they are present.

Fixes: 51564585d8c6 ("ftgmac100: Support NCSI VLAN filtering when available")
Fixes: 21acf63013ed ("net/ncsi: Configure VLAN tag filter")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/net/ncsi.h     | 10 ++++++++++
 net/ncsi/ncsi-manage.c |  2 ++
 2 files changed, 12 insertions(+)

diff --git a/include/net/ncsi.h b/include/net/ncsi.h
index 1f96af46df49..fdc60ff2511d 100644
--- a/include/net/ncsi.h
+++ b/include/net/ncsi.h
@@ -36,6 +36,16 @@ int ncsi_start_dev(struct ncsi_dev *nd);
 void ncsi_stop_dev(struct ncsi_dev *nd);
 void ncsi_unregister_dev(struct ncsi_dev *nd);
 #else /* !CONFIG_NET_NCSI */
+static inline int ncsi_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
+{
+	return -EINVAL;
+}
+
+static inline int ncsi_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
+{
+	return -EINVAL;
+}
+
 static inline struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
 					void (*notifier)(struct ncsi_dev *nd))
 {
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index 11904b3b702d..3fd3c39e6278 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -1453,6 +1453,7 @@ int ncsi_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
 
 	return found ? ncsi_process_next_channel(ndp) : 0;
 }
+EXPORT_SYMBOL_GPL(ncsi_vlan_rx_add_vid);
 
 int ncsi_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
 {
@@ -1491,6 +1492,7 @@ int ncsi_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
 
 	return found ? ncsi_process_next_channel(ndp) : 0;
 }
+EXPORT_SYMBOL_GPL(ncsi_vlan_rx_kill_vid);
 
 struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
 				   void (*handler)(struct ncsi_dev *ndev))
-- 
2.9.0
