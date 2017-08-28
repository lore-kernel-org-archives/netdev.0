From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 03/10] net: dsa: debugfs: add tag_protocol
Date: Mon, 28 Aug 2017 15:17:41 -0400
Message-ID: <20170828191748.19492-4-vivien.didelot@savoirfairelinux.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36288 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751192AbdH1TVj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 15:21:39 -0400
In-Reply-To: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a debug filesystem "tag_protocol" entry to query the switch tagging
protocol through the .get_tag_protocol operation.

    # cat switch1/tag_protocol
    EDSA

To ease maintenance of tag protocols, add a dsa_tag_protocol_name helper
to the public API which to convert a tag protocol enum to a string.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 26 ++++++++++++++++++++++++++
 net/dsa/debugfs.c | 23 +++++++++++++++++++++++
 2 files changed, 49 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 7341178319f5..1309ba0376ae 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -39,6 +39,32 @@ enum dsa_tag_protocol {
 	DSA_TAG_LAST,		/* MUST BE LAST */
 };
 
+static inline const char *dsa_tag_protocol_name(enum dsa_tag_protocol proto)
+{
+	switch (proto) {
+	case DSA_TAG_PROTO_NONE:
+		return "none";
+	case DSA_TAG_PROTO_BRCM:
+		return "BRCM";
+	case DSA_TAG_PROTO_DSA:
+		return "DSA";
+	case DSA_TAG_PROTO_EDSA:
+		return "EDSA";
+	case DSA_TAG_PROTO_KSZ:
+		return "KSZ";
+	case DSA_TAG_PROTO_LAN9303:
+		return "LAN9303";
+	case DSA_TAG_PROTO_MTK:
+		return "MTK";
+	case DSA_TAG_PROTO_QCA:
+		return "QCA";
+	case DSA_TAG_PROTO_TRAILER:
+		return "TRAILER";
+	default:
+		return "unknown";
+	}
+}
+
 #define DSA_MAX_SWITCHES	4
 #define DSA_MAX_PORTS		12
 
diff --git a/net/dsa/debugfs.c b/net/dsa/debugfs.c
index 54e97e05a9d7..8a0e4311ff8c 100644
--- a/net/dsa/debugfs.c
+++ b/net/dsa/debugfs.c
@@ -109,6 +109,24 @@ static int dsa_debugfs_create_file(struct dsa_switch *ds, struct dentry *dir,
 	return 0;
 }
 
+static int dsa_debugfs_tag_protocol_read(struct dsa_switch *ds, int id,
+					 struct seq_file *seq)
+{
+	enum dsa_tag_protocol proto;
+
+	if (!ds->ops->get_tag_protocol)
+		return -EOPNOTSUPP;
+
+	proto = ds->ops->get_tag_protocol(ds);
+	seq_printf(seq, "%s\n", dsa_tag_protocol_name(proto));
+
+	return 0;
+}
+
+static const struct dsa_debugfs_ops dsa_debugfs_tag_protocol_ops = {
+	.read = dsa_debugfs_tag_protocol_read,
+};
+
 static int dsa_debugfs_tree_read(struct dsa_switch *ds, int id,
 				 struct seq_file *seq)
 {
@@ -150,6 +168,11 @@ static int dsa_debugfs_create_switch(struct dsa_switch *ds)
 	if (IS_ERR_OR_NULL(ds->debugfs_dir))
 		return -EFAULT;
 
+	err = dsa_debugfs_create_file(ds, ds->debugfs_dir, "tag_protocol", -1,
+				      &dsa_debugfs_tag_protocol_ops);
+	if (err)
+		return err;
+
 	err = dsa_debugfs_create_file(ds, ds->debugfs_dir, "tree", -1,
 				      &dsa_debugfs_tree_ops);
 	if (err)
-- 
2.14.1
