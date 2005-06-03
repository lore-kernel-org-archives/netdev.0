From: ravinandan.arakali@neterion.com
Subject: [PATCH 2.6.12-rc4] ethtool: Support for UDP Large Send Offload
Date: Thu,  2 Jun 2005 17:43:58 -0700 (PDT)
Message-ID: <20050603004358.28C4B7B99F@linux.site>
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, ananda.raju@neterion.com,
        rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net, jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Attached below is a patch on ethtool utility to support USO(UDP Large
Send Offload).
Pls review the patch.

Usage:
1. To view USO setting
# ethtool -k <ethernet_interface>

2. To set/unset USO 
# ethtool -K <ethernet_interface> uso on|off

Signed-off-by: Ananda Raju <ananda.raju@neterion.com>
Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
---
diff -uNr ethtool-3/ethtool-copy.h ethtool-3_uso/ethtool-copy.h
--- ethtool-3/ethtool-copy.h	2005-01-28 01:50:26.000000000 +0545
+++ ethtool-3_uso/ethtool-copy.h	2005-06-02 23:06:48.000000000 +0545
@@ -283,6 +283,8 @@
 #define ETHTOOL_GSTATS		0x0000001d /* get NIC-specific statistics */
 #define ETHTOOL_GTSO		0x0000001e /* Get TSO enable (ethtool_value) */
 #define ETHTOOL_STSO		0x0000001f /* Set TSO enable (ethtool_value) */
+#define ETHTOOL_GUSO		0x00000020 /* Get USO enable (ethtool_value) */
+#define ETHTOOL_SUSO		0x00000021 /* Set USO enable (ethtool_value) */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff -uNr ethtool-3/ethtool.c ethtool-3_uso/ethtool.c
--- ethtool-3/ethtool.c	2005-01-28 04:19:29.000000000 +0545
+++ ethtool-3_uso/ethtool.c	2005-06-02 23:06:52.000000000 +0545
@@ -119,6 +119,7 @@
  *		[ tx on|off ] \
  *		[ sg on|off ] \
  *		[ tso on|off ]
+ *		[ uso on|off ]
  *	ethtool -r DEVNAME
  *	ethtool -p DEVNAME [ %d ]
  *	ethtool -t DEVNAME [ online|offline ]
@@ -191,6 +192,7 @@
 		"		[ tx on|off ] \\\n"
 		"		[ sg on|off ] \\\n"
 		"		[ tso on|off ]\n"
+		"		[ uso on|off ]\n"
 		"	ethtool -r DEVNAME\n"
 		"	ethtool -p DEVNAME [ %%d ]\n"
 		"	ethtool -t DEVNAME [online|(offline)]\n"
@@ -236,6 +238,7 @@
 static int off_csum_tx_wanted = -1;
 static int off_sg_wanted = -1;
 static int off_tso_wanted = -1;
+static int off_uso_wanted = -1;
 
 static struct ethtool_pauseparam epause;
 static int gpause_changed = 0;
@@ -339,6 +342,7 @@
 	{ "tx", CMDL_BOOL, &off_csum_tx_wanted, NULL },
 	{ "sg", CMDL_BOOL, &off_sg_wanted, NULL },
 	{ "tso", CMDL_BOOL, &off_tso_wanted, NULL },
+	{ "uso", CMDL_BOOL, &off_uso_wanted, NULL },
 };
 
 static struct cmdline_info cmdline_pause[] = {
@@ -1184,17 +1188,19 @@
 	return 0;
 }
 
-static int dump_offload (int rx, int tx, int sg, int tso)
+static int dump_offload (int rx, int tx, int sg, int tso, int uso)
 {
 	fprintf(stdout,
 		"rx-checksumming: %s\n"
 		"tx-checksumming: %s\n"
 		"scatter-gather: %s\n"
-		"tcp segmentation offload: %s\n",
+		"tcp segmentation offload: %s\n"
+		"udp large send offload: %s\n",
 		rx ? "on" : "off",
 		tx ? "on" : "off",
 		sg ? "on" : "off",
-		tso ? "on" : "off");
+		tso ? "on" : "off",
+		uso ? "on" : "off");
 
 	return 0;
 }
@@ -1458,7 +1464,7 @@
 static int do_goffload(int fd, struct ifreq *ifr)
 {
 	struct ethtool_value eval;
-	int err, allfail = 1, rx = 0, tx = 0, sg = 0, tso = 0;
+	int err, allfail = 1, rx = 0, tx = 0, sg = 0, tso = 0, uso = 0;
 
 	fprintf(stdout, "Offload parameters for %s:\n", devname);
 
@@ -1502,12 +1508,22 @@
 		allfail = 0;
 	}
 
+	eval.cmd = ETHTOOL_GUSO;
+	ifr->ifr_data = (caddr_t)&eval;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err)
+		perror("Cannot get device udp large send offload settings");
+	else {
+		uso = eval.data;
+		allfail = 0;
+	}
+
 	if (allfail) {
 		fprintf(stdout, "no offload info available\n");
 		return 83;
 	}
 
-	return dump_offload(rx, tx, sg, tso);
+	return dump_offload(rx, tx, sg, tso, uso);
 }
 
 static int do_soffload(int fd, struct ifreq *ifr)
@@ -1562,6 +1578,17 @@
 			return 88;
 		}
 	}
+	if (off_uso_wanted >= 0) {
+		changed = 1;
+		eval.cmd = ETHTOOL_SUSO;
+		eval.data = (off_uso_wanted == 1);
+		ifr->ifr_data = (caddr_t)&eval;
+		err = ioctl(fd, SIOCETHTOOL, ifr);
+		if (err) {
+			perror("Cannot set device udp large send offload settings");
+			return 89;
+		}
+	}
 	if (!changed) {
 		fprintf(stdout, "no offload settings changed\n");
 	}
