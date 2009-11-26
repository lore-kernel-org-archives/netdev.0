From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/4] veth: move loopback logic to common location
Date: Thu, 26 Nov 2009 18:44:59 +0100
Message-ID: <200911261844.59912.arnd@arndb.de>
References: <1259024166-28158-1-git-send-email-arnd@arndb.de> <200911261621.28298.arnd@arndb.de> <4B0E9FD0.4040107@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	virtualization@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Anna Fischer <anna.fischer@hp.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Patrick Mullaney <pmullaney@novell.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751333AbZKZRpx@vger.kernel.org>
In-Reply-To: <4B0E9FD0.4040107@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 26 November 2009, Patrick McHardy wrote:
> In addition to those already handled, I'd say
> 
> - priority: affects qdisc classification, may refer to classes of the
>   old namespace
> - ipvs_property: might cause packets to incorrectly skip netfilter hooks
> - nf_trace: might trigger packet tracing
> - nf_bridge: contains references to network devices in the old NS,
>   also indicates packet was bridged
> - iif: index is only valid in the originating namespace
> - probably secmark.

ok

> - tc_index: classification result, should only be set in the namespace
>   of the classifier
> - tc_verd: RTTL etc. should begin at zero again

Wouldn't that defeat the purpose of RTTL? If you create a loop
across two devices in different namespaces, it may no longer get
detected. Or is that a different problem again?

	Arnd <><

---

net: maintain namespace isolation between vlan and real device

In the vlan and macvlan drivers, the start_xmit function forwards
data to the dev_queue_xmit function for another device, which may
potentially belong to a different namespace.

To make sure that classification stays within a single namespace,
this resets the potentially critical fields.

Still needs testing, don't apply

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/macvlan.c     |    2 +-
 include/linux/netdevice.h |    9 +++++++++
 net/8021q/vlan_dev.c      |    2 +-
 net/core/dev.c            |   37 +++++++++++++++++++++++++++++++++----
 4 files changed, 44 insertions(+), 6 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 322112c..edcebf1 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -269,7 +269,7 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 xmit_world:
-	skb->dev = vlan->lowerdev;
+	skb_set_dev(skb, vlan->lowerdev);
 	return dev_queue_xmit(skb);
 }
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9428793..fdf4a1a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1009,6 +1009,15 @@ static inline bool netdev_uses_dsa_tags(struct net_device *dev)
 	return 0;
 }
 
+#ifdef CONFIG_NET_NS
+static inline void skb_set_dev(struct sk_buff *skb, struct net_device *dev)
+{
+	skb->dev = dev;
+}
+#else /* CONFIG_NET_NS */
+void skb_set_dev(struct sk_buff *skb, struct net_device *dev);
+#endif
+
 static inline bool netdev_uses_trailer_tags(struct net_device *dev)
 {
 #ifdef CONFIG_NET_DSA_TAG_TRAILER
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index de0dc6b..51fcfff 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -323,7 +323,7 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 	}
 
 
-	skb->dev = vlan_dev_info(dev)->real_dev;
+	skb_set_dev(skb, vlan_dev_info(dev)->real_dev);
 	len = skb->len;
 	ret = dev_queue_xmit(skb);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index f8baa15..220d4e4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1448,13 +1448,10 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 	if (skb->len > (dev->mtu + dev->hard_header_len))
 		return NET_RX_DROP;
 
-	skb_dst_drop(skb);
+	skb_set_dev(skb, dev);
 	skb->tstamp.tv64 = 0;
 	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, dev);
-	skb->mark = 0;
-	secpath_reset(skb);
-	nf_reset(skb);
 	return netif_rx(skb);
 }
 EXPORT_SYMBOL_GPL(dev_forward_skb);
@@ -1614,6 +1611,39 @@ static bool dev_can_checksum(struct net_device *dev, struct sk_buff *skb)
 	return false;
 }
 
+/**
+ * skb_dev_set -- assign a buffer to a new device
+ * @skb: buffer for the new device
+ * @dev: network device
+ *
+ * If an skb is owned by a device already, we have to reset
+ * all data private to the namespace a device belongs to
+ * before assigning it a new device.
+ */
+void skb_set_dev(struct sk_buff *skb, struct net_device *dev)
+{
+	if (skb->dev && !net_eq(dev_net(skb->dev), dev_net(dev))) {
+		secpath_reset(skb);
+		skb_dst_drop(skb);
+		nf_reset(skb);
+		skb_init_secmark(skb);
+		skb->mark = 0;
+		skb->priority = 0;
+		skb->nf_trace = 0;
+		skb->ipvs_property = 0;
+#ifdef CONFIG_NET_SCHED
+		skb->tc_index = 0;
+#ifdef CONFIG_NET_CLS_ACT
+		skb->tc_verd = SET_TC_VERD(skb->tc_verd, 0);
+		skb->tc_verd = SET_TC_RTTL(skb->tc_verd, 0);
+#endif
+#endif
+	}
+	skb->dev = dev;
+	skb->skb_iif = skb->dev->ifindex;
+}
+EXPORT_SYMBOL(skb_set_dev);
+
 /*
  * Invalidate hardware checksum when packet is to be mangled, and
  * complete checksum manually on outgoing path.
