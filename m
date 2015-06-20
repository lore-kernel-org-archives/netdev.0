From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 4/6] dsa: mv88x6xxx: Add debugfs interface for statistics
Date: Sat, 20 Jun 2015 18:42:31 +0200
Message-ID: <1434818553-10239-5-git-send-email-andrew@lunn.ch>
References: <1434818553-10239-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59966 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753381AbbFTQtE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jun 2015 12:49:04 -0400
In-Reply-To: <1434818553-10239-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the contents of the statistics counters to be shown in debugfs.
This is particularly useful for the cpu and dsa ports, which cannot be
seen using ethtools -S.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 59 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 43c1515a8319..fc5d4fdfcb02 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1730,6 +1730,62 @@ static const struct file_operations mv88e6xxx_atu_fops = {
 	.owner  = THIS_MODULE,
 };
 
+static void mv88e6xxx_stats_show_header(struct seq_file *s,
+					struct mv88e6xxx_priv_state *ps)
+{
+	int port;
+
+	seq_puts(s, "      Statistic       ");
+	for (port = 0 ; port < ps->num_ports; port++)
+		seq_printf(s, "Port %2d  ", port);
+	seq_puts(s, "\n");
+}
+
+static int mv88e6xxx_stats_show(struct seq_file *s, void *p)
+{
+	struct dsa_switch *ds = s->private;
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_hw_stat *stats = mv88e6xxx_hw_stats;
+	int port, stat, max_stats;
+	uint64_t value;
+
+	if (have_sw_in_discards(ds))
+		max_stats = ARRAY_SIZE(mv88e6xxx_hw_stats);
+	else
+		max_stats = ARRAY_SIZE(mv88e6xxx_hw_stats) - 3;
+
+	mv88e6xxx_stats_show_header(s, ps);
+
+	mutex_lock(&ps->smi_mutex);
+
+	for (stat = 0; stat < max_stats; stat++) {
+		seq_printf(s, "%19s: ", stats[stat].string);
+		for (port = 0 ; port < ps->num_ports; port++) {
+			_mv88e6xxx_stats_snapshot(ds, port);
+			value = _mv88e6xxx_get_ethtool_stat(ds, stat, stats,
+							    port);
+			seq_printf(s, "%8llu ", value);
+		}
+		seq_puts(s, "\n");
+	}
+	mutex_unlock(&ps->smi_mutex);
+
+	return 0;
+}
+
+static int mv88e6xxx_stats_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, mv88e6xxx_stats_show, inode->i_private);
+}
+
+static const struct file_operations mv88e6xxx_stats_fops = {
+	.open   = mv88e6xxx_stats_open,
+	.read   = seq_read,
+	.llseek = no_llseek,
+	.release = single_release,
+	.owner  = THIS_MODULE,
+};
+
 int mv88e6xxx_setup_common(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -1753,6 +1809,9 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 	debugfs_create_file("atu", S_IRUGO, ps->dbgfs, ds,
 			    &mv88e6xxx_atu_fops);
 
+	debugfs_create_file("stats", S_IRUGO, ps->dbgfs, ds,
+			    &mv88e6xxx_stats_fops);
+
 	return 0;
 }
 
-- 
2.1.4
