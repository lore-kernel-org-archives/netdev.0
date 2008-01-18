From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] Add LRO control to ethtool
Date: Fri, 18 Jan 2008 11:01:27 +0000
Message-ID: <20080118110126.GA23117@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pythagoras.zen.co.uk ([212.23.3.140]:50846 "EHLO
	pythagoras.zen.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753487AbYARLBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 06:01:32 -0500
Received: from [82.69.137.158] (helo=opal.uk.level5networks.com)
	by pythagoras.zen.co.uk with esmtp (Exim 4.63)
	(envelope-from <bwh@solarflare.com>)
	id 1JFoyX-0001OV-Kg
	for netdev@vger.kernel.org; Fri, 18 Jan 2008 11:01:30 +0000
Received: from achroite (achroite.uk.level5networks.com [10.17.20.50])
	by opal.uk.level5networks.com (8.12.8/8.12.8) with ESMTP id m0IB1RMC018805
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 11:01:29 GMT
Received: from bwh by achroite with local (Exim 4.62)
	(envelope-from <bwh@solarflare.com>)
	id 1JFoyV-00069p-1F
	for netdev@vger.kernel.org; Fri, 18 Jan 2008 11:01:27 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel-side ethtool code supports ETHTOOL_{G,S}FLAGS commands
which can control various features; currently the only feature is LRO.
I didn't see any code to use these in the ethtool git repository
<git://git.kernel.org/pub/scm/network/ethtool/ethtool.git>.  So here's
a patch that adds that.  I tested this with the latest version of the
sfc driver, which we should be re-posting later today.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

diff --git a/ethtool.c b/ethtool.c
index 3adf843..cfe7c9f 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -151,7 +151,8 @@ static struct option {
 		"		[ sg on|off ]\n"
 	        "		[ tso on|off ]\n"
 	        "		[ ufo on|off ]\n"
-	        "		[ gso on|off ]\n" },
+	        "		[ gso on|off ]\n"
+	        "		[ lro on|off ]\n" },
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
@@ -1217,7 +1220,8 @@ static int dump_coalesce(void)
 	return 0;
 }
 
-static int dump_offload (int rx, int tx, int sg, int tso, int ufo, int gso)
+static int dump_offload (int rx, int tx, int sg, int tso, int ufo, int gso,
+			 int lro)
 {
 	fprintf(stdout,
 		"rx-checksumming: %s\n"
@@ -1225,13 +1229,15 @@ static int dump_offload (int rx, int tx, int sg, int tso, int ufo, int gso)
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
@@ -1495,7 +1501,8 @@ static int do_scoalesce(int fd, struct ifreq *ifr)
 static int do_goffload(int fd, struct ifreq *ifr)
 {
 	struct ethtool_value eval;
-	int err, allfail = 1, rx = 0, tx = 0, sg = 0, tso = 0, ufo = 0, gso = 0;
+	int err, allfail = 1;
+	int rx = 0, tx = 0, sg = 0, tso = 0, ufo = 0, gso = 0, lro = 0;
 
 	fprintf(stdout, "Offload parameters for %s:\n", devname);
 
@@ -1559,12 +1566,22 @@ static int do_goffload(int fd, struct ifreq *ifr)
 		allfail = 0;
 	}
 
+	eval.cmd = ETHTOOL_GFLAGS;
+	ifr->ifr_data = (caddr_t)&eval;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err)
+		perror("Cannot get device large receive offload settings");
+	else {
+		lro = (eval.data & ETH_FLAG_LRO) != 0;
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
@@ -1641,6 +1658,17 @@ static int do_soffload(int fd, struct ifreq *ifr)
 			return 90;
 		}
 	}
+	if (off_lro_wanted >= 0) {
+		changed = 1;
+		eval.cmd = ETHTOOL_SFLAGS;
+		eval.data = (off_lro_wanted == 1) ? ETH_FLAG_LRO : 0;
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


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
