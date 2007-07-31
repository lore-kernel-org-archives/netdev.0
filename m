From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] ethtool: Add LRO support
Date: Tue, 31 Jul 2007 13:21:25 -0700
Message-ID: <20070731202125.15775.22269.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22018 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759415AbXGaUV1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 16:21:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 ethtool-copy.h |    8 ++++++++
 ethtool.8      |    8 ++++++--
 ethtool.c      |   39 +++++++++++++++++++++++++++++++++------
 3 files changed, 47 insertions(+), 8 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 3a63224..ab9d688 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -274,6 +274,8 @@ int ethtool_op_get_perm_addr(struct net_device *dev,
 			     struct ethtool_perm_addr *addr, u8 *data);
 u32 ethtool_op_get_ufo(struct net_device *dev);
 int ethtool_op_set_ufo(struct net_device *dev, u32 data);
+u32 ethtool_op_get_lro(struct net_device *dev);
+int ethtool_op_set_lro(struct net_device *dev, u32 data);
 
 /**
  * &ethtool_ops - Alter and report network device settings
@@ -305,6 +307,8 @@ int ethtool_op_set_ufo(struct net_device *dev, u32 data);
  * set_tso: Turn TCP segmentation offload on or off
  * get_ufo: Report whether UDP fragmentation offload is enabled
  * set_ufo: Turn UDP fragmentation offload on or off
+ * get_lro: Report whether large receive offload is enabled
+ * set_lro: Turn large receive offload on or off
  * self_test: Run specified self-tests
  * get_strings: Return a set of strings that describe the requested objects 
  * phys_id: Identify the device
@@ -373,6 +377,8 @@ struct ethtool_ops {
 	void	(*complete)(struct net_device *);
 	u32     (*get_ufo)(struct net_device *);
 	int     (*set_ufo)(struct net_device *, u32);
+	u32     (*get_lro)(struct net_device *);
+	int     (*set_lro)(struct net_device *, u32);
 };
 #endif /* __KERNEL__ */
 
@@ -414,6 +420,8 @@ struct ethtool_ops {
 #define ETHTOOL_SUFO		0x00000022 /* Set UFO enable (ethtool_value) */
 #define ETHTOOL_GGSO		0x00000023 /* Get GSO enable (ethtool_value) */
 #define ETHTOOL_SGSO		0x00000024 /* Set GSO enable (ethtool_value) */
+#define ETHTOOL_GLRO		0x00000025 /* Get LRO enable (ethtool_value) */
+#define ETHTOOL_SLRO		0x00000026 /* Set LRO enable (ethtool_value) */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/ethtool.8 b/ethtool.8
index af51056..89abf08 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -158,6 +158,7 @@ ethtool \- Display or change ethernet card settings
 .B2 tso on off
 .B2 ufo on off
 .B2 gso on off
+.B2 lro on off
 
 .B ethtool \-p|\-\-blink
 .I ethX
@@ -289,10 +290,13 @@ Specifies whether scatter-gather should be enabled.
 Specifies whether TCP segmentation offload should be enabled.
 .TP
 .A2 ufo on off
-Specifies whether UDP fragmentation offload should be enabled 
+Specifies whether UDP fragmentation offload should be enabled.
 .TP
 .A2 gso on off
-Specifies whether generic segmentation offload should be enabled 
+Specifies whether generic segmentation offload should be enabled.
+.TP
+.A2 lro on off
+Specifies whether large receive offload should be enabled.
 .TP
 .B \-p \-\-identify
 Initiates adapter-specific action intended to enable an operator to
diff --git a/ethtool.c b/ethtool.c
index b04f747..4c9844a 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -151,7 +151,8 @@ static struct option {
 		"		[ sg on|off ]\n"
 	        "		[ tso on|off ]\n"
 	        "		[ ufo on|off ]\n"
-	        "		[ gso on|off ]\n" },
+	        "		[ gso on|off ]\n"
+		"		[ lro on|off ]\n" },
     { "-i", "--driver", MODE_GDRV, "Show driver information" },
     { "-d", "--register-dump", MODE_GREGS, "Do a register dump",
 		"		[ raw on|off ]\n"
@@ -200,6 +201,7 @@ static int off_sg_wanted = -1;
 static int off_tso_wanted = -1;
 static int off_ufo_wanted = -1;
 static int off_gso_wanted = -1;
+static int off_lro_wanted = -1;
 
 static struct ethtool_pauseparam epause;
 static int gpause_changed = 0;
@@ -310,6 +312,7 @@ static struct cmdline_info cmdline_offload[] = {
 	{ "tso", CMDL_BOOL, &off_tso_wanted, NULL },
 	{ "ufo", CMDL_BOOL, &off_ufo_wanted, NULL },
 	{ "gso", CMDL_BOOL, &off_gso_wanted, NULL },
+	{ "lro", CMDL_BOOL, &off_lro_wanted, NULL },
 };
 
 static struct cmdline_info cmdline_pause[] = {
@@ -1207,7 +1210,7 @@ static int dump_coalesce(void)
 	return 0;
 }
 
-static int dump_offload (int rx, int tx, int sg, int tso, int ufo, int gso)
+static int dump_offload (int rx, int tx, int sg, int tso, int ufo, int gso, int lro)
 {
 	fprintf(stdout,
 		"rx-checksumming: %s\n"
@@ -1215,13 +1218,15 @@ static int dump_offload (int rx, int tx, int sg, int tso, int ufo, int gso)
 		"scatter-gather: %s\n"
 		"tcp segmentation offload: %s\n"
 		"udp fragmentation offload: %s\n"
-		"generic segmentation offload: %s\n",
+		"generic segmentation offload: %s\n"
+		"large receive offload: %s\n",
 		rx ? "on" : "off",
 		tx ? "on" : "off",
 		sg ? "on" : "off",
 		tso ? "on" : "off",
 		ufo ? "on" : "off",
-		gso ? "on" : "off");
+		gso ? "on" : "off",
+		lro ? "on" : "off");
 
 	return 0;
 }
@@ -1485,7 +1490,8 @@ static int do_scoalesce(int fd, struct ifreq *ifr)
 static int do_goffload(int fd, struct ifreq *ifr)
 {
 	struct ethtool_value eval;
-	int err, allfail = 1, rx = 0, tx = 0, sg = 0, tso = 0, ufo = 0, gso = 0;
+	int err, allfail = 1;
+	int rx = 0, tx = 0, sg = 0, tso = 0, ufo = 0, gso = 0, lro = 0;
 
 	fprintf(stdout, "Offload parameters for %s:\n", devname);
 
@@ -1549,12 +1555,22 @@ static int do_goffload(int fd, struct ifreq *ifr)
 		allfail = 0;
 	}
 
+	eval.cmd = ETHTOOL_GLRO;
+	ifr->ifr_data = (caddr_t)&eval;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err)
+		perror("Cannot get device generic large receive offload settings");
+	else {
+		gso = eval.data;
+		allfail = 0;
+	}
+
 	if (allfail) {
 		fprintf(stdout, "no offload info available\n");
 		return 83;
 	}
 
-	return dump_offload(rx, tx, sg, tso, ufo, gso);
+	return dump_offload(rx, tx, sg, tso, ufo, gso, lro);
 }
 
 static int do_soffload(int fd, struct ifreq *ifr)
@@ -1631,6 +1647,17 @@ static int do_soffload(int fd, struct ifreq *ifr)
 			return 90;
 		}
 	}
+	if (off_lro_wanted >= 0) {
+		changed = 1;
+		eval.cmd = ETHTOOL_SLRO;
+		eval.data = (off_gso_wanted == 1);
+		ifr->ifr_data = (caddr_t)&eval;
+		err = ioctl(fd, SIOCETHTOOL, ifr);
+		if (err) {
+			perror("Cannot set device large receive offload settings");
+			return 91;
+		}
+	}
 	if (!changed) {
 		fprintf(stdout, "no offload settings changed\n");
 	}
