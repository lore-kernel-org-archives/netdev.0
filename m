From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 05/11] net: dsa: debugfs: add port stats
Date: Mon, 14 Aug 2017 18:22:36 -0400
Message-ID: <20170814222242.10643-6-vivien.didelot@savoirfairelinux.com>
References: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Maxime Hadjinlian <maxime@devialet.com>,
        Chris Healy <cphealy@gmail.com>,
        Maxim Uvarov <muvarov@gmail.com>,
        Stefan Eichenberger <eichest@gmail.com>,
        Jason Cobham <jcobham@questertangent.com>,
        Juergen Borleis <jbe@pengutronix.de>,
        Tobias Waldekranz <tobias@waldekranz.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a debug filesystem "stats" entry to query a port's hardware
statistics through the DSA switch .get_sset_count, .get_strings and
.get_ethtool_stats operations.

This allows one to get statistics about DSA links interconnecting
switches, which is very convenient because this kind of port is not
exposed to userspace.

Here are the stats of a zii-rev-b DSA and CPU ports:

    # pr -mt switch0/port{5,6}/stats
    in_good_octets      : 0             in_good_octets      : 13824
    in_bad_octets       : 0             in_bad_octets       : 0
    in_unicast          : 0             in_unicast          : 0
    in_broadcasts       : 0             in_broadcasts       : 216
    in_multicasts       : 0             in_multicasts       : 0
    in_pause            : 0             in_pause            : 0
    in_undersize        : 0             in_undersize        : 0
    in_fragments        : 0             in_fragments        : 0
    in_oversize         : 0             in_oversize         : 0
    in_jabber           : 0             in_jabber           : 0
    in_rx_error         : 0             in_rx_error         : 0
    in_fcs_error        : 0             in_fcs_error        : 0
    out_octets          : 9216          out_octets          : 0
    out_unicast         : 0             out_unicast         : 0
    out_broadcasts      : 144           out_broadcasts      : 0
    out_multicasts      : 0             out_multicasts      : 0
    out_pause           : 0             out_pause           : 0
    excessive           : 0             excessive           : 0
    collisions          : 0             collisions          : 0
    deferred            : 0             deferred            : 0
    single              : 0             single              : 0
    multiple            : 0             multiple            : 0
    out_fcs_error       : 0             out_fcs_error       : 0
    late                : 0             late                : 0
    hist_64bytes        : 0             hist_64bytes        : 0
    hist_65_127bytes    : 0             hist_65_127bytes    : 0
    hist_128_255bytes   : 0             hist_128_255bytes   : 0
    hist_256_511bytes   : 0             hist_256_511bytes   : 0
    hist_512_1023bytes  : 0             hist_512_1023bytes  : 0
    hist_1024_max_bytes : 0             hist_1024_max_bytes : 0
    sw_in_discards      : 0             sw_in_discards      : 0
    sw_in_filtered      : 0             sw_in_filtered      : 0
    sw_out_filtered     : 0             sw_out_filtered     : 216

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/debugfs.c | 43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/net/dsa/debugfs.c b/net/dsa/debugfs.c
index 30a732e86161..5f91b4423404 100644
--- a/net/dsa/debugfs.c
+++ b/net/dsa/debugfs.c
@@ -109,6 +109,43 @@ static int dsa_debugfs_create_file(struct dsa_switch *ds, struct dentry *dir,
 	return 0;
 }
 
+static void dsa_debugfs_stats_read_count(struct dsa_switch *ds, int id,
+					 struct seq_file *seq, int count)
+{
+	u8 strings[count * ETH_GSTRING_LEN];
+	u64 stats[count];
+	int i;
+
+	ds->ops->get_strings(ds, id, strings);
+	ds->ops->get_ethtool_stats(ds, id, stats);
+
+	for (i = 0; i < count; i++)
+		seq_printf(seq, "%-20s: %lld\n", strings + i * ETH_GSTRING_LEN,
+			   stats[i]);
+}
+
+static int dsa_debugfs_stats_read(struct dsa_switch *ds, int id,
+				  struct seq_file *seq)
+{
+	int count;
+
+	if (!ds->ops->get_sset_count || !ds->ops->get_strings ||
+	    !ds->ops->get_ethtool_stats)
+		return -EOPNOTSUPP;
+
+	count = ds->ops->get_sset_count(ds);
+	if (count < 0)
+		return count;
+
+	dsa_debugfs_stats_read_count(ds, id, seq, count);
+
+	return 0;
+}
+
+static const struct dsa_debugfs_ops dsa_debugfs_stats_ops = {
+	.read = dsa_debugfs_stats_read,
+};
+
 static int dsa_debugfs_tag_protocol_read(struct dsa_switch *ds, int id,
 					 struct seq_file *seq)
 {
@@ -174,6 +211,7 @@ static int dsa_debugfs_create_port(struct dsa_switch *ds, int port)
 {
 	struct dentry *dir;
 	char name[32];
+	int err;
 
 	snprintf(name, sizeof(name), DSA_PORT_FMT, port);
 
@@ -181,6 +219,11 @@ static int dsa_debugfs_create_port(struct dsa_switch *ds, int port)
 	if (IS_ERR_OR_NULL(dir))
 		return -EFAULT;
 
+	err = dsa_debugfs_create_file(ds, dir, "stats", port,
+				      &dsa_debugfs_stats_ops);
+	if (err)
+		return err;
+
 	return 0;
 }
 
-- 
2.14.0
