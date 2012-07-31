From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 net 1/3] net: Allow driver to limit number of GSO segments
 per skb
Date: Tue, 31 Jul 2012 02:57:00 +0100
Message-ID: <1343699820.2667.71.camel@bwh-desktop.uk.solarflarecom.com>
References: <1343699476.2667.69.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Ben Greear <greearb@candelatech.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:46136 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753765Ab2GaB5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 21:57:04 -0400
In-Reply-To: <1343699476.2667.69.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A peer (or local user) may cause TCP to use a nominal MSS of as little
as 88 (actual MSS of 76 with timestamps).  Given that we have a
sufficiently prodigious local sender and the peer ACKs quickly enough,
it is nevertheless possible to grow the window for such a connection
to the point that we will try to send just under 64K at once.  This
results in a single skb that expands to 861 segments.

In some drivers with TSO support, such an skb will require hundreds of
DMA descriptors; a substantial fraction of a TX ring or even more than
a full ring.  The TX queue selected for the skb may stall and trigger
the TX watchdog repeatedly (since the problem skb will be retried
after the TX reset).  This particularly affects sfc, for which the
issue is designated as CVE-2012-3412.

Therefore:
1. Add the field net_device::gso_max_segs holding the device-specific
   limit.
2. In netif_skb_features(), if the number of segments is too high then
   mask out GSO features to force fall back to software GSO.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/netdevice.h |    2 ++
 net/core/dev.c            |    4 ++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index eb06e58..a9db4f3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1300,6 +1300,8 @@ struct net_device {
 	/* for setting kernel sock attribute on TCP connection setup */
 #define GSO_MAX_SIZE		65536
 	unsigned int		gso_max_size;
+#define GSO_MAX_SEGS		65535
+	u16			gso_max_segs;
 
 #ifdef CONFIG_DCB
 	/* Data Center Bridging netlink ops */
diff --git a/net/core/dev.c b/net/core/dev.c
index 0ebaea1..4020646 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2133,6 +2133,9 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
 	__be16 protocol = skb->protocol;
 	netdev_features_t features = skb->dev->features;
 
+	if (skb_shinfo(skb)->gso_segs > skb->dev->gso_max_segs)
+		features &= ~NETIF_F_GSO_MASK;
+
 	if (protocol == htons(ETH_P_8021Q)) {
 		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
 		protocol = veh->h_vlan_encapsulated_proto;
@@ -5942,6 +5945,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	dev_net_set(dev, &init_net);
 
 	dev->gso_max_size = GSO_MAX_SIZE;
+	dev->gso_max_segs = GSO_MAX_SEGS;
 
 	INIT_LIST_HEAD(&dev->napi_list);
 	INIT_LIST_HEAD(&dev->unreg_list);
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
