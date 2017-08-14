From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 11/11] net: dsa: debugfs: add port vlan
Date: Mon, 14 Aug 2017 18:22:42 -0400
Message-ID: <20170814222242.10643-12-vivien.didelot@savoirfairelinux.com>
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

Add a debug filesystem "vlan" entry to query a port's hardware VLAN
entries through the .port_vlan_dump switch operation.

This is really convenient to query directly the hardware or inspect DSA
or CPU links, since these ports are not exposed to userspace.

Here are the VLAN entries for a CPU port:

    # cat port5/vlan
    vid 1
    vid 42  pvid

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/debugfs.c | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/net/dsa/debugfs.c b/net/dsa/debugfs.c
index 98c5068d20da..b00942368d29 100644
--- a/net/dsa/debugfs.c
+++ b/net/dsa/debugfs.c
@@ -286,6 +286,34 @@ static const struct dsa_debugfs_ops dsa_debugfs_tree_ops = {
 	.read = dsa_debugfs_tree_read,
 };
 
+static int dsa_debugfs_vlan_dump_cb(u16 vid, bool pvid, bool untagged,
+				    void *data)
+{
+	struct seq_file *seq = data;
+
+	seq_printf(seq, "vid %d", vid);
+	if (pvid)
+		seq_puts(seq, "  pvid");
+	if (untagged)
+		seq_puts(seq, "  untagged");
+	seq_puts(seq, "\n");
+
+	return 0;
+}
+
+static int dsa_debugfs_vlan_read(struct dsa_switch *ds, int id,
+				 struct seq_file *seq)
+{
+	if (!ds->ops->port_vlan_dump)
+		return -EOPNOTSUPP;
+
+	return ds->ops->port_vlan_dump(ds, id, dsa_debugfs_vlan_dump_cb, seq);
+}
+
+static const struct dsa_debugfs_ops dsa_debugfs_vlan_ops = {
+	.read = dsa_debugfs_vlan_read,
+};
+
 static int dsa_debugfs_create_port(struct dsa_switch *ds, int port)
 {
 	struct dentry *dir;
@@ -318,6 +346,11 @@ static int dsa_debugfs_create_port(struct dsa_switch *ds, int port)
 	if (err)
 		return err;
 
+	err = dsa_debugfs_create_file(ds, dir, "vlan", port,
+				      &dsa_debugfs_vlan_ops);
+	if (err)
+		return err;
+
 	return 0;
 }
 
-- 
2.14.0
