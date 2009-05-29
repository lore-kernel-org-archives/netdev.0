From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.31 01/10] wimax/i2400m: generate fake source MAC address with random_ether_addr()
Date: Thu, 28 May 2009 18:12:05 -0700
Message-ID: <fe442683853a2c0863b700acc4328b4d73090206.1243559425.git.inaky@linux.intel.com>
References: <cover.1243559425.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 076-076-148-181.pdx.net ([76.76.148.181]:45064 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753719AbZE2EL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 00:11:57 -0400
In-Reply-To: <cover.1243559425.git.inaky@linux.intel.com>
In-Reply-To: <cover.1243559425.git.inaky@linux.intel.com>
References: <cover.1243559425.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The WiMAX i2400m driver needs to generate a fake source MAC address to
fake an ethernet header (for destination, the card's MAC is
used). This is the source of the packet, which is the basestation it
came from. The basestation's mac address is not usable for this, as it
uses its own namespace and it is not always available.

Currently the fake source MAC address was being set to all zeros,
which was causing trouble with bridging.

Use random_ether_addr() to generate a proper one that creates no
trouble.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |    2 ++
 drivers/net/wimax/i2400m/i2400m.h |    5 +++++
 drivers/net/wimax/i2400m/netdev.c |    4 +++-
 3 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 07a54ba..a21318b 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -62,6 +62,7 @@
  *   unregister_netdev()
  */
 #include "i2400m.h"
+#include <linux/etherdevice.h>
 #include <linux/wimax/i2400m.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
@@ -650,6 +651,7 @@ int i2400m_setup(struct i2400m *i2400m, enum i2400m_bri bm_flags)
 	result = i2400m_read_mac_addr(i2400m);
 	if (result < 0)
 		goto error_read_mac_addr;
+	random_ether_addr(i2400m->src_mac_addr);
 
 	result = register_netdev(net_dev);	/* Okey dokey, bring it up */
 	if (result < 0) {
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 3ae2df3..434ba31 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -323,6 +323,10 @@ struct i2400m_roq;
  *     delivered. Then the driver can release them to the host. See
  *     drivers/net/i2400m/rx.c for details.
  *
+ * @src_mac_addr: MAC address used to make ethernet packets be coming
+ *     from. This is generated at i2400m_setup() time and used during
+ *     the life cycle of the instance. See i2400m_fake_eth_header().
+ *
  * @init_mutex: Mutex used for serializing the device bringup
  *     sequence; this way if the device reboots in the middle, we
  *     don't try to do a bringup again while we are tearing down the
@@ -421,6 +425,7 @@ struct i2400m {
 	unsigned rx_pl_num, rx_pl_max, rx_pl_min,
 		rx_num, rx_size_acc, rx_size_min, rx_size_max;
 	struct i2400m_roq *rx_roq;	/* not under rx_lock! */
+	u8 src_mac_addr[ETH_HLEN];
 
 	struct mutex msg_mutex;		/* serialize command execution */
 	struct completion msg_completion;
diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index 6b1fe7a..9653f47 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -404,10 +404,12 @@ static
 void i2400m_rx_fake_eth_header(struct net_device *net_dev,
 			       void *_eth_hdr, __be16 protocol)
 {
+	struct i2400m *i2400m = net_dev_to_i2400m(net_dev);
 	struct ethhdr *eth_hdr = _eth_hdr;
 
 	memcpy(eth_hdr->h_dest, net_dev->dev_addr, sizeof(eth_hdr->h_dest));
-	memset(eth_hdr->h_source, 0, sizeof(eth_hdr->h_dest));
+	memcpy(eth_hdr->h_source, i2400m->src_mac_addr,
+	       sizeof(eth_hdr->h_source));
 	eth_hdr->h_proto = protocol;
 }
 
-- 
1.6.2.3

