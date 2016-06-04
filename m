From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: Provide CPU port statistics to master netdev
Date: Fri,  3 Jun 2016 17:05:22 -0700
Message-ID: <1464998733-10405-3-git-send-email-f.fainelli@gmail.com>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35321 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbcFDAFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 20:05:43 -0400
Received: by mail-pa0-f66.google.com with SMTP id gp3so6932334pac.2
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 17:05:43 -0700 (PDT)
In-Reply-To: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch overloads the DSA master netdev, aka CPU Ethernet MAC to also
include switch-side statistics, which is useful for debugging purposes,
when the switch is not properly connected to the Ethernet MAC (duplex
mismatch, (RG)MII electrical issues etc.).

We accomplish this by retaining the original copy of the master netdev's
ethtool_ops, and just overload the 3 operations we care about:
get_sset_count, get_strings and get_ethtool_stats so as to intercept
these calls and call into the original master_netdev ethtool_ops, plus
our own.

We take this approach as opposed to providing a set of DSA helper
functions that would retrive the CPU port's statistics, because the
entire purpose of DSA is to allow unmodified Ethernet MAC drivers to be
used as CPU conduit interfaces, therefore, statistics overlay in such
drivers would simply not scale.

The new ethtool -S <iface> output would therefore look like this now:
<iface> statistics
p<2 digits cpu port number>_<switch MIB counter names>

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes from RFC:

- prepend the CPU port as a prefix to make it clear what the stats are
  about, master netdev interface stats are unchanged

 include/net/dsa.h |  5 ++++
 net/dsa/slave.c   | 88 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 93 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 2d280aba97e2..8e86af87c84f 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -111,6 +111,11 @@ struct dsa_switch_tree {
 	enum dsa_tag_protocol	tag_protocol;
 
 	/*
+	 * Original copy of the master netdev ethtool_ops
+	 */
+	struct ethtool_ops	master_ethtool_ops;
+
+	/*
 	 * The switch and port to which the CPU is attached.
 	 */
 	s8			cpu_switch;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 3b6750f5e68b..5ea8a40c8d33 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -666,6 +666,78 @@ static void dsa_slave_get_strings(struct net_device *dev,
 	}
 }
 
+static void dsa_cpu_port_get_ethtool_stats(struct net_device *dev,
+					   struct ethtool_stats *stats,
+					   uint64_t *data)
+{
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_switch *ds = dst->ds[0];
+	s8 cpu_port = dst->cpu_port;
+	int count = 0;
+
+	if (dst->master_ethtool_ops.get_sset_count) {
+		count = dst->master_ethtool_ops.get_sset_count(dev,
+							       ETH_SS_STATS);
+		dst->master_ethtool_ops.get_ethtool_stats(dev, stats, data);
+	}
+
+	if (ds->drv->get_ethtool_stats)
+		ds->drv->get_ethtool_stats(ds, cpu_port, data + count);
+}
+
+static int dsa_cpu_port_get_sset_count(struct net_device *dev, int sset)
+{
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_switch *ds = dst->ds[0];
+	int count = 0;
+
+	if (dst->master_ethtool_ops.get_sset_count)
+		count += dst->master_ethtool_ops.get_sset_count(dev, sset);
+
+	if (sset == ETH_SS_STATS && ds->drv->get_sset_count)
+		count += ds->drv->get_sset_count(ds);
+
+	return count;
+}
+
+static void dsa_cpu_port_get_strings(struct net_device *dev,
+				     uint32_t stringset, uint8_t *data)
+{
+	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_switch *ds = dst->ds[0];
+	s8 cpu_port = dst->cpu_port;
+	int len = ETH_GSTRING_LEN;
+	int mcount = 0, count;
+	unsigned int i;
+	uint8_t pfx[4];
+	uint8_t *ndata;
+
+	snprintf(pfx, sizeof(pfx), "p%.2d", cpu_port);
+	/* We do not want to be NULL-terminated, since this is a prefix */
+	pfx[sizeof(pfx) - 1] = '_';
+
+	if (dst->master_ethtool_ops.get_sset_count) {
+		mcount = dst->master_ethtool_ops.get_sset_count(dev,
+								ETH_SS_STATS);
+		dst->master_ethtool_ops.get_strings(dev, stringset, data);
+	}
+
+	if (stringset == ETH_SS_STATS && ds->drv->get_strings) {
+		ndata = data + mcount * len;
+		/* This function copies ETH_GSTRINGS_LEN bytes, we will mangle
+		 * the output after to prepend our CPU port prefix we
+		 * constructed earlier
+		 */
+		ds->drv->get_strings(ds, cpu_port, ndata);
+		count = ds->drv->get_sset_count(ds);
+		for (i = 0; i < count; i++) {
+			memmove(ndata + (i * len + sizeof(pfx)),
+				ndata + i * len, len - sizeof(pfx));
+			memcpy(ndata + i * len, pfx, sizeof(pfx));
+		}
+	}
+}
+
 static void dsa_slave_get_ethtool_stats(struct net_device *dev,
 					struct ethtool_stats *stats,
 					uint64_t *data)
@@ -821,6 +893,8 @@ static const struct ethtool_ops dsa_slave_ethtool_ops = {
 	.get_eee		= dsa_slave_get_eee,
 };
 
+static struct ethtool_ops dsa_cpu_port_ethtool_ops;
+
 static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_open	 	= dsa_slave_open,
 	.ndo_stop		= dsa_slave_close,
@@ -1038,6 +1112,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		     int port, char *name)
 {
 	struct net_device *master = ds->dst->master_netdev;
+	struct dsa_switch_tree *dst = ds->dst;
 	struct net_device *slave_dev;
 	struct dsa_slave_priv *p;
 	int ret;
@@ -1049,6 +1124,19 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 
 	slave_dev->features = master->vlan_features;
 	slave_dev->ethtool_ops = &dsa_slave_ethtool_ops;
+	if (master->ethtool_ops != &dsa_cpu_port_ethtool_ops) {
+		memcpy(&dst->master_ethtool_ops, master->ethtool_ops,
+		       sizeof(struct ethtool_ops));
+		memcpy(&dsa_cpu_port_ethtool_ops, &dst->master_ethtool_ops,
+		       sizeof(struct ethtool_ops));
+		dsa_cpu_port_ethtool_ops.get_sset_count =
+					dsa_cpu_port_get_sset_count;
+		dsa_cpu_port_ethtool_ops.get_ethtool_stats =
+					dsa_cpu_port_get_ethtool_stats;
+		dsa_cpu_port_ethtool_ops.get_strings =
+					dsa_cpu_port_get_strings;
+		master->ethtool_ops = &dsa_cpu_port_ethtool_ops;
+	}
 	eth_hw_addr_inherit(slave_dev, master);
 	slave_dev->priv_flags |= IFF_NO_QUEUE;
 	slave_dev->netdev_ops = &dsa_slave_netdev_ops;
-- 
2.1.0
