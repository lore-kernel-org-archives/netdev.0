From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 07/11] net: dsa: debugfs: add port fdb
Date: Mon, 14 Aug 2017 18:22:38 -0400
Message-ID: <20170814222242.10643-8-vivien.didelot@savoirfairelinux.com>
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

Add a debug filesystem "fdb" entry to query a port's hardware FDB
entries through the .port_fdb_dump switch operation.

This is really convenient to query directly the hardware or inspect DSA
or CPU links, since these ports are not exposed to userspace.

    # cat port1/fdb
    vid 0    12:34:56:78:90:ab    static    unicast

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/debugfs.c | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/net/dsa/debugfs.c b/net/dsa/debugfs.c
index 012fcf466cc1..8204c62dc9c1 100644
--- a/net/dsa/debugfs.c
+++ b/net/dsa/debugfs.c
@@ -10,6 +10,7 @@
  */
 
 #include <linux/debugfs.h>
+#include <linux/etherdevice.h>
 #include <linux/seq_file.h>
 
 #include "dsa_priv.h"
@@ -109,6 +110,36 @@ static int dsa_debugfs_create_file(struct dsa_switch *ds, struct dentry *dir,
 	return 0;
 }
 
+static int dsa_debugfs_fdb_dump_cb(const unsigned char *addr, u16 vid,
+				   bool is_static, void *data)
+{
+	struct seq_file *seq = data;
+	int i;
+
+	seq_printf(seq, "vid %d", vid);
+	for (i = 0; i < ETH_ALEN; i++)
+		seq_printf(seq, "%s%02x", i ? ":" : "    ", addr[i]);
+	seq_printf(seq, "    %s", is_static ? "static" : "dynamic");
+	seq_printf(seq, "    %s", is_unicast_ether_addr(addr) ?
+		   "unicast" : "multicast");
+	seq_puts(seq, "\n");
+
+	return 0;
+}
+
+static int dsa_debugfs_fdb_read(struct dsa_switch *ds, int id,
+				struct seq_file *seq)
+{
+	if (!ds->ops->port_fdb_dump)
+		return -EOPNOTSUPP;
+
+	return ds->ops->port_fdb_dump(ds, id, dsa_debugfs_fdb_dump_cb, seq);
+}
+
+static const struct dsa_debugfs_ops dsa_debugfs_fdb_ops = {
+	.read = dsa_debugfs_fdb_read,
+};
+
 static void dsa_debugfs_regs_read_count(struct dsa_switch *ds, int id,
 					struct seq_file *seq, int count)
 {
@@ -253,6 +284,11 @@ static int dsa_debugfs_create_port(struct dsa_switch *ds, int port)
 	if (IS_ERR_OR_NULL(dir))
 		return -EFAULT;
 
+	err = dsa_debugfs_create_file(ds, dir, "fdb", port,
+				      &dsa_debugfs_fdb_ops);
+	if (err)
+		return err;
+
 	err = dsa_debugfs_create_file(ds, dir, "regs", port,
 				      &dsa_debugfs_regs_ops);
 	if (err)
-- 
2.14.0
