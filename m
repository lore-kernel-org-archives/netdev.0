From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 02/11] net: dsa: add Broadcom tag hook
Date: Tue, 13 May 2014 22:00:28 -0700
Message-ID: <1400043637-9799-3-git-send-email-f.fainelli@gmail.com>
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
Received: from mail-pa0-f54.google.com ([209.85.220.54]:51069 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753904AbaENFBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 01:01:15 -0400
Received: by mail-pa0-f54.google.com with SMTP id bj1so1190492pad.13
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 22:01:15 -0700 (PDT)
In-Reply-To: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Register a fake Ethertype for the Broadcom tag to allow us to hook into
a given Ethernet device receive path and parse this Broadcom tag.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/netdevice.h     | 10 ++++++++++
 include/net/dsa.h             |  5 +++++
 include/uapi/linux/if_ether.h |  1 +
 net/ethernet/eth.c            |  2 ++
 4 files changed, 18 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2dea98cbbdba..323ba253ce4b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1675,6 +1675,16 @@ static inline bool netdev_uses_trailer_tags(struct net_device *dev)
 	return 0;
 }
 
+static inline bool netdev_uses_brcm_tags(struct net_device *dev)
+{
+#ifdef CONFIG_NET_DSA_TAG_BRCM
+	if (dev->dsa_ptr != NULL)
+		return dsa_uses_brcm_tags(dev->dsa_ptr);
+#endif
+
+	return 0;
+}
+
 /**
  *	netdev_priv - access network device private data
  *	@dev: network device
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 6efce384451e..0ada9c814ff9 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -203,4 +203,9 @@ static inline bool dsa_uses_trailer_tags(struct dsa_switch_tree *dst)
 	return !!(dst->tag_protocol == htons(ETH_P_TRAILER));
 }
 
+static inline bool dsa_uses_brcm_tags(struct dsa_switch_tree *dst)
+{
+	return !!(dst->tag_protocol == htons(ETH_P_BRCMTAG));
+}
+
 #endif
diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index 0f8210b8e0bc..2e9f13768abd 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -128,6 +128,7 @@
 #define ETH_P_PHONET	0x00F5		/* Nokia Phonet frames          */
 #define ETH_P_IEEE802154 0x00F6		/* IEEE802.15.4 frame		*/
 #define ETH_P_CAIF	0x00F7		/* ST-Ericsson CAIF protocol	*/
+#define ETH_P_BRCMTAG	0x00F8		/* Broadcom tag (4 bytes *)	*/
 
 /*
  *	This is an Ethernet frame header.
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 5dc638cad2e1..a7a02547f9bb 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -186,6 +186,8 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 
 	if (unlikely(netdev_uses_trailer_tags(dev)))
 		return htons(ETH_P_TRAILER);
+	if (netdev_uses_brcm_tags(dev))
+		return htons(ETH_P_BRCMTAG);
 
 	if (likely(ntohs(eth->h_proto) >= ETH_P_802_3_MIN))
 		return eth->h_proto;
-- 
1.9.1
