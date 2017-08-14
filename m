From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 06/11] net: dsa: debugfs: add port registers
Date: Mon, 14 Aug 2017 18:22:37 -0400
Message-ID: <20170814222242.10643-7-vivien.didelot@savoirfairelinux.com>
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

Add a debug filesystem "regs" entry to query a port's hardware registers
through the .get_regs_len and .get_regs_len switch operations.

This is very convenient because it allows one to dump the registers of
DSA links, which are not exposed to userspace.

Here are the registers of a zii-rev-b CPU and DSA ports:

    # pr -mt switch0/port{5,6}/regs
     0: 4e07			     0: 4d04
     1: 403e			     1: 003d
     2: 0000			     2: 0000
     3: 3521			     3: 3521
     4: 0533			     4: 373f
     5: 8000			     5: 0000
     6: 005f			     6: 003f
     7: 002a			     7: 002a
     8: 2080			     8: 2080
     9: 0001			     9: 0001
    10: 0000			    10: 0000
    11: 0020			    11: 0000
    12: 0000			    12: 0000
    13: 0000			    13: 0000
    14: 0000			    14: 0000
    15: 9100			    15: dada
    16: 0000			    16: 0000
    17: 0000			    17: 0000
    18: 0000			    18: 0000
    19: 0000			    19: 00d8
    20: 0000			    20: 0000
    21: 0000			    21: 0000
    22: 0022			    22: 0000
    23: 0000			    23: 0000
    24: 3210			    24: 3210
    25: 7654			    25: 7654
    26: 0000			    26: 0000
    27: 8000			    27: 8000
    28: 0000			    28: 0000
    29: 0000			    29: 0000
    30: 0000			    30: 0000
    31: 0000			    31: 0000

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/debugfs.c | 39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/net/dsa/debugfs.c b/net/dsa/debugfs.c
index 5f91b4423404..012fcf466cc1 100644
--- a/net/dsa/debugfs.c
+++ b/net/dsa/debugfs.c
@@ -109,6 +109,40 @@ static int dsa_debugfs_create_file(struct dsa_switch *ds, struct dentry *dir,
 	return 0;
 }
 
+static void dsa_debugfs_regs_read_count(struct dsa_switch *ds, int id,
+					struct seq_file *seq, int count)
+{
+	u16 data[count * ETH_GSTRING_LEN];
+	struct ethtool_regs regs;
+	int i;
+
+	ds->ops->get_regs(ds, id, &regs, data);
+
+	for (i = 0; i < count / 2; i++)
+		seq_printf(seq, "%2d: %04x\n", i, data[i]);
+}
+
+static int dsa_debugfs_regs_read(struct dsa_switch *ds, int id,
+				 struct seq_file *seq)
+{
+	int count;
+
+	if (!ds->ops->get_regs_len || !ds->ops->get_regs)
+		return -EOPNOTSUPP;
+
+	count = ds->ops->get_regs_len(ds, id);
+	if (count < 0)
+		return count;
+
+	dsa_debugfs_regs_read_count(ds, id, seq, count);
+
+	return 0;
+}
+
+static const struct dsa_debugfs_ops dsa_debugfs_regs_ops = {
+	.read = dsa_debugfs_regs_read,
+};
+
 static void dsa_debugfs_stats_read_count(struct dsa_switch *ds, int id,
 					 struct seq_file *seq, int count)
 {
@@ -219,6 +253,11 @@ static int dsa_debugfs_create_port(struct dsa_switch *ds, int port)
 	if (IS_ERR_OR_NULL(dir))
 		return -EFAULT;
 
+	err = dsa_debugfs_create_file(ds, dir, "regs", port,
+				      &dsa_debugfs_regs_ops);
+	if (err)
+		return err;
+
 	err = dsa_debugfs_create_file(ds, dir, "stats", port,
 				      &dsa_debugfs_stats_ops);
 	if (err)
-- 
2.14.0
