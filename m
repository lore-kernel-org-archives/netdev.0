From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next] 6lowpan: revert 'reuse eth_mac_addr()'
Date: Mon,  2 Jul 2012 09:58:46 +0400
Message-ID: <1341208726-2793-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, danny.kukawka@bisect.de,
	dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:42143 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932066Ab2GBGCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 02:02:31 -0400
Received: by wgbdr13 with SMTP id dr13so4886871wgb.1
        for <netdev@vger.kernel.org>; Sun, 01 Jul 2012 23:02:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts the commit cdf49c283e2e105da86ca575ad35b453f5ff24ea which
replaces lowpan '.ndo_set_mac_address' method by ethernet's one.

Accorind to the IEEE 802.15.4 standard, device has 8-byte length address,
so this hook loses the last 2 bytes which may rise a compatibility problems
with other IEEE 802.15.4 standard implementations.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/ieee802154/6lowpan.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index ad0c226..049d8cd 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -55,7 +55,6 @@
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/netdevice.h>
-#include <linux/etherdevice.h>
 #include <net/af_ieee802154.h>
 #include <net/ieee802154.h>
 #include <net/ieee802154_netdev.h>
@@ -936,6 +935,19 @@ drop:
 	return -EINVAL;
 }
 
+static int lowpan_set_address(struct net_device *dev, void *p)
+{
+	struct sockaddr *sa = p;
+
+	if (netif_running(dev))
+		return -EBUSY;
+
+	/* TODO: validate addr */
+	memcpy(dev->dev_addr, sa->sa_data, dev->addr_len);
+
+	return 0;
+}
+
 static int lowpan_get_mac_header_length(struct sk_buff *skb)
 {
 	/*
@@ -1078,7 +1090,7 @@ static struct header_ops lowpan_header_ops = {
 
 static const struct net_device_ops lowpan_netdev_ops = {
 	.ndo_start_xmit		= lowpan_xmit,
-	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_set_mac_address	= lowpan_set_address,
 };
 
 static struct ieee802154_mlme_ops lowpan_mlme = {
-- 
1.7.2.3
