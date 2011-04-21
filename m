From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next] net: Allow ethtool to set interface in loopback mode.
Date: Wed, 20 Apr 2011 17:57:38 -0700
Message-ID: <1303347458-14499-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:2034 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926Ab1DUA5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 20:57:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables ethtool to set the loopback mode on a given interface.
By configuring the interface in loopback mode in conjunction with a policy
route / rule, a userland application can stress the egress / ingress path
exposing the flows of the change in progress and potentially help developer(s)
understand the impact of those changes without even sending a packet out
on the network.

Following set of commands illustrates one such example -
    a) ip -4 addr add 192.168.1.1/24 dev eth1
    b) ip -4 rule add from all iif eth1 lookup 250
    c) ip -4 route add local 0/0 dev lo proto kernel scope host table 250
    d) arp -Ds 192.168.1.100 eth1
    e) arp -Ds 192.168.1.200 eth1
    f) sysctl -w net.ipv4.ip_nonlocal_bind=1
    g) sysctl -w net.ipv4.conf.all.accept_local=1
    # Assuming that the machine has 8 cores
    h) taskset 000f netserver -L 192.168.1.200
    i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.168.1.200 -l 30

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 include/linux/netdevice.h |    3 ++-
 net/core/ethtool.c        |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cb8178a..c4d9dd7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1067,6 +1067,7 @@ struct net_device {
 #define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
 #define NETIF_F_RXCSUM		(1 << 29) /* Receive checksumming offload */
 #define NETIF_F_NOCACHE_COPY	(1 << 30) /* Use no-cache copyfromuser */
+#define NETIF_F_LOOPBACK	(1 << 31) /* Enable loopback */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
@@ -1082,7 +1083,7 @@ struct net_device {
 	/* = all defined minus driver/device-class-related */
 #define NETIF_F_NEVER_CHANGE	(NETIF_F_HIGHDMA | NETIF_F_VLAN_CHALLENGED | \
 				  NETIF_F_LLTX | NETIF_F_NETNS_LOCAL)
-#define NETIF_F_ETHTOOL_BITS	(0x7f3fffff & ~NETIF_F_NEVER_CHANGE)
+#define NETIF_F_ETHTOOL_BITS	(0xff3fffff & ~NETIF_F_NEVER_CHANGE)
 
 	/* List of features with software fallbacks. */
 #define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 13d79f5..d177ce9 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -362,7 +362,7 @@ static const char netdev_features_strings[ETHTOOL_DEV_FEATURE_WORDS * 32][ETH_GS
 	/* NETIF_F_RXHASH */          "rx-hashing",
 	/* NETIF_F_RXCSUM */          "rx-checksum",
 	/* NETIF_F_NOCACHE_COPY */    "tx-nocache-copy"
-	"",
+	/* NETIF_F_LOOPBACK */        "loopback",
 };
 
 static int __ethtool_get_sset_count(struct net_device *dev, int sset)
-- 
1.7.3.1

