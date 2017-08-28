From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 10/10] net: dsa: debugfs: add port vlan
Date: Mon, 28 Aug 2017 15:17:48 -0400
Message-ID: <20170828191748.19492-11-vivien.didelot@savoirfairelinux.com>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a debug filesystem "vlan" entry to query a port's hardware VLAN
entries through the .port_vlan_dump switch operation.

This is really convenient to query directly the hardware or inspect DSA
or CPU links, since these ports are not exposed to userspace.

Here are the VLAN entries for a CPU port:

    # cat port5/vlan
    vid 1  untagged  pvid
    vid 42  tagged

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/debugfs.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/net/dsa/debugfs.c b/net/dsa/debugfs.c
index bed8e1d5cfe1..40fe19872ab1 100644
--- a/net/dsa/debugfs.c
+++ b/net/dsa/debugfs.c
@@ -250,6 +250,30 @@ static const struct dsa_debugfs_ops dsa_debugfs_tree_ops = {
 	.read = dsa_debugfs_tree_read,
 };
 
+static int dsa_debugfs_vlan_dump_cb(u16 vid, bool pvid, bool untagged,
+				    void *data)
+{
+	struct seq_file *seq = data;
+
+	seq_printf(seq, "vid %d  %s  %s\n", vid,
+		   untagged ? "untagged" : "tagged", pvid ? "pvid" : "");
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
@@ -282,6 +306,11 @@ static int dsa_debugfs_create_port(struct dsa_switch *ds, int port)
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
2.14.1
