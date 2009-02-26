From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/2] veth: Configurable nterface MTU
Date: Wed, 25 Feb 2009 21:49:04 -0800
Message-ID: <m1fxi1kasv.fsf@fess.ebiederm.org>
References: <m1ljrtkavi.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:59346 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874AbZBZFsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 00:48:33 -0500
In-Reply-To: <m1ljrtkavi.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Wed\, 25 Feb 2009 21\:47\:29 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The limitation to only 1500 byte mtu's limits the utility of the veth
device for testing routing.

Signed-off-by: Eric Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/veth.c |   24 +++++++++++++++++++++++-
 1 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 124fe75..88778bb 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -19,6 +19,10 @@
 #define DRV_NAME	"veth"
 #define DRV_VERSION	"1.0"
 
+#define MIN_MTU 68		/* Min L3 MTU */
+#define MAX_MTU 65535		/* Max L3 MTU (arbitrary) */
+#define MTU_PAD (ETH_HLEN + 4)  /* Max difference between L2 and L3 size MTU */
+
 struct veth_net_stats {
 	unsigned long	rx_packets;
 	unsigned long	tx_packets;
@@ -159,7 +163,7 @@ static int veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	cpu = smp_processor_id();
 	stats = per_cpu_ptr(priv->stats, cpu);
 
-	if (!(rcv->flags & IFF_UP))
+	if (!(rcv->flags & IFF_UP) || (skb->len > (rcv->mtu + MTU_PAD)))
 		goto outf;
 
 	skb->pkt_type = PACKET_HOST;
@@ -249,6 +253,19 @@ static int veth_close(struct net_device *dev)
 	return 0;
 }
 
+static int is_valid_veth_mtu(int new_mtu)
+{
+	return (new_mtu >= MIN_MTU && new_mtu <= MAX_MTU);
+}
+
+static int veth_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if (is_valid_veth_mtu(new_mtu))
+		return -EINVAL;
+	dev->mtu = new_mtu;
+	return 0;
+}
+
 static int veth_dev_init(struct net_device *dev)
 {
 	struct veth_net_stats *stats;
@@ -277,6 +294,7 @@ static const struct net_device_ops veth_netdev_ops = {
 	.ndo_open            = veth_open,
 	.ndo_stop            = veth_close,
 	.ndo_start_xmit      = veth_xmit,
+	.ndo_change_mtu      = veth_change_mtu,
 	.ndo_get_stats       = veth_get_stats,
 	.ndo_set_mac_address = eth_mac_addr,
 };
@@ -303,6 +321,10 @@ static int veth_validate(struct nlattr *tb[], struct nlattr *data[])
 		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
 			return -EADDRNOTAVAIL;
 	}
+	if (tb[IFLA_MTU]) {
+		if (is_valid_veth_mtu(nla_get_u32(tb[IFLA_MTU])))
+			return -EINVAL;
+	}
 	return 0;
 }
 
-- 
1.6.1.2.350.g88cc

