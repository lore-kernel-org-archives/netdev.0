From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH net-next] net: add devm version of alloc_etherdev_mqs function
Date: Sat, 28 Jan 2017 15:15:42 +0100
Message-ID: <20170128141542.9676-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Andrew Lunn <andrew@lunn.ch>, Joe Perches <joe@perches.com>,
        Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Jarod Wilson <jarod@redhat.com>,
        Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34243 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751848AbdA1OP4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2017 09:15:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafał Miłecki <rafal@milecki.pl>

This patch adds devm_alloc_etherdev_mqs function and devm_alloc_etherdev
macro. These can be used for simpler netdev allocation without having to
care about calling free_netdev.

Thanks to this change drivers, their error paths and removal paths may
get simpler by a bit.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
I'm working on V2 of:
[PATCH 0/3] net-next: use one struct bgmac & add PHY support
and I just realized I could get a way simpler error path in bgmac with a
devm_alloc_etherdev helper. So there is my suggestion for adding it.
---
 include/linux/etherdevice.h |  5 +++++
 net/ethernet/eth.c          | 28 ++++++++++++++++++++++++++++
 2 files changed, 33 insertions(+)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 42add77ae47d..c62b709b1ce0 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -54,6 +54,11 @@ struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
 #define alloc_etherdev(sizeof_priv) alloc_etherdev_mq(sizeof_priv, 1)
 #define alloc_etherdev_mq(sizeof_priv, count) alloc_etherdev_mqs(sizeof_priv, count, count)
 
+struct net_device *devm_alloc_etherdev_mqs(struct device *dev, int sizeof_priv,
+					   unsigned int txqs,
+					   unsigned int rxqs);
+#define devm_alloc_etherdev(dev, sizeof_priv) devm_alloc_etherdev_mqs(dev, sizeof_priv, 1, 1)
+
 struct sk_buff **eth_gro_receive(struct sk_buff **head,
 				 struct sk_buff *skb);
 int eth_gro_complete(struct sk_buff *skb, int nhoff);
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 8c5a479681ca..efdaaab735fc 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -392,6 +392,34 @@ struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
 }
 EXPORT_SYMBOL(alloc_etherdev_mqs);
 
+static void devm_free_netdev(struct device *dev, void *res)
+{
+	free_netdev(*(struct net_device **)res);
+}
+
+struct net_device *devm_alloc_etherdev_mqs(struct device *dev, int sizeof_priv,
+					   unsigned int txqs, unsigned int rxqs)
+{
+	struct net_device **dr;
+	struct net_device *netdev;
+
+	dr = devres_alloc(devm_free_netdev, sizeof(*dr), GFP_KERNEL);
+	if (!dr)
+		return NULL;
+
+	netdev = alloc_etherdev_mqs(sizeof_priv, txqs, rxqs);
+	if (!netdev) {
+		devres_free(dr);
+		return NULL;
+	}
+
+	*dr = netdev;
+	devres_add(dev, dr);
+
+	return netdev;
+}
+EXPORT_SYMBOL(devm_alloc_etherdev_mqs);
+
 ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len)
 {
 	return scnprintf(buf, PAGE_SIZE, "%*phC\n", len, addr);
-- 
2.11.0
