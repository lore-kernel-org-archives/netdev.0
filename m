From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next 11/11] ieee802154, mac802154: implement devkey record option
Date: Fri, 16 May 2014 17:46:45 +0200
Message-ID: <1400255205-9031-12-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1400255205-9031-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:40082 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430AbaEPPuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 11:50:55 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s4GFoqXD000563
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 16 May 2014 17:50:53 +0200
In-Reply-To: <1400255205-9031-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 802.15.4-2011 standard states that for each key, a list of devices
that use this key shall be kept. Previous patches have only considered
two options:

 * a device "uses" (or may use) all keys, rendering the list useless
 * a device is restricted to a certain set of keys

Another option would be that a device *may* use all keys, but need not
do so, and we are interested in the actual set of keys the device uses.
Recording keys used by any given device may have a noticable performance
impact and might not be needed as often. The common case, in which a
device will not switch keys too often, should still perform well.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 include/net/ieee802154_netdev.h |    1 +
 net/mac802154/llsec.c           |   38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 39 insertions(+)

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index eb9f850..3b53c8e 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -280,6 +280,7 @@ struct ieee802154_llsec_device_key {
 enum {
 	IEEE802154_LLSEC_DEVKEY_IGNORE,
 	IEEE802154_LLSEC_DEVKEY_RESTRICT,
+	IEEE802154_LLSEC_DEVKEY_RECORD,
 
 	__IEEE802154_LLSEC_DEVKEY_MAX,
 };
diff --git a/net/mac802154/llsec.c b/net/mac802154/llsec.c
index 392653b..a83674e 100644
--- a/net/mac802154/llsec.c
+++ b/net/mac802154/llsec.c
@@ -921,6 +921,37 @@ llsec_do_decrypt(struct sk_buff *skb, const struct mac802154_llsec *sec,
 }
 
 static int
+llsec_update_devkey_record(struct mac802154_llsec_device *dev,
+			   const struct ieee802154_llsec_key_id *in_key)
+{
+	struct mac802154_llsec_device_key *devkey;
+
+	devkey = llsec_devkey_find(dev, in_key);
+
+	if (!devkey) {
+		struct mac802154_llsec_device_key *next;
+
+		next = kzalloc(sizeof(*devkey), GFP_ATOMIC);
+		if (!next)
+			return -ENOMEM;
+
+		next->devkey.key_id = *in_key;
+
+		spin_lock_bh(&dev->lock);
+
+		devkey = llsec_devkey_find(dev, in_key);
+		if (!devkey)
+			list_add_rcu(&next->devkey.list, &dev->dev.keys);
+		else
+			kfree(next);
+
+		spin_unlock_bh(&dev->lock);
+	}
+
+	return 0;
+}
+
+static int
 llsec_update_devkey_info(struct mac802154_llsec_device *dev,
 			 const struct ieee802154_llsec_key_id *in_key,
 			 u32 frame_counter)
@@ -933,6 +964,13 @@ llsec_update_devkey_info(struct mac802154_llsec_device *dev,
 			return -ENOENT;
 	}
 
+	if (dev->dev.key_mode == IEEE802154_LLSEC_DEVKEY_RECORD) {
+		int rc = llsec_update_devkey_record(dev, in_key);
+
+		if (rc < 0)
+			return rc;
+	}
+
 	spin_lock_bh(&dev->lock);
 
 	if ((!devkey && frame_counter < dev->dev.frame_counter) ||
-- 
1.7.9.5
