From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 06/10] net: dsa: debugfs: add port fdb
Date: Mon, 28 Aug 2017 15:17:44 -0400
Message-ID: <20170828191748.19492-7-vivien.didelot@savoirfairelinux.com>
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

Add a debug filesystem "fdb" entry to query a port's hardware FDB
entries through the .port_fdb_dump switch operation.

This is really convenient to query directly the hardware or inspect DSA
or CPU links, since these ports are not exposed to userspace.

    # cat port1/fdb
    vid 0  12:34:56:78:90:ab  unicast  static

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/debugfs.c | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/net/dsa/debugfs.c b/net/dsa/debugfs.c
index 7b299c9d9892..59c09a67bc23 100644
--- a/net/dsa/debugfs.c
+++ b/net/dsa/debugfs.c
@@ -10,6 +10,7 @@
  */
 
 #include <linux/debugfs.h>
+#include <linux/etherdevice.h>
 #include <linux/seq_file.h>
 
 #include "dsa_priv.h"
@@ -109,6 +110,31 @@ static int dsa_debugfs_create_file(struct dsa_switch *ds, struct dentry *dir,
 	return 0;
 }
 
+static int dsa_debugfs_fdb_dump_cb(const unsigned char *addr, u16 vid,
+				   bool is_static, void *data)
+{
+	struct seq_file *seq = data;
+
+	seq_printf(seq, "vid %d  %pM  %s  %s\n", vid, addr,
+		   is_unicast_ether_addr(addr) ? "unicast" : "multicast",
+		   is_static ? "static" : "dynamic");
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
@@ -222,6 +248,11 @@ static int dsa_debugfs_create_port(struct dsa_switch *ds, int port)
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
2.14.1
