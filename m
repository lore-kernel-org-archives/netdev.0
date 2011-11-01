From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 09/21] Encapsulate command context in a structure
Date: Tue, 1 Nov 2011 23:16:26 +0000
Message-ID: <1320189386.2758.39.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:38087 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451Ab1KAXQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:16:30 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the fd and ifr arguments to each sub-command handler with
struct cmd_context.  Change send_ioctl() to take a pointer to
this context and a pointer to the ethtool_cmd or other structure.
Use send_ioctl() consistently.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c  |  419 +++++++++++++++++++++++++-----------------------------------
 internal.h |   16 ++-
 rxclass.c  |   42 +++----
 3 files changed, 204 insertions(+), 273 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index f967f84..b6f535c 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -67,42 +67,40 @@ enum {
 static int parse_wolopts(char *optstr, u32 *data);
 static char *unparse_wolopts(int wolopts);
 static void get_mac_addr(char *src, unsigned char *dest);
-static int do_gdrv(int fd, struct ifreq *ifr);
-static int do_gset(int fd, struct ifreq *ifr);
-static int do_sset(int fd, struct ifreq *ifr);
-static int do_gregs(int fd, struct ifreq *ifr);
-static int do_nway_rst(int fd, struct ifreq *ifr);
-static int do_geeprom(int fd, struct ifreq *ifr);
-static int do_seeprom(int fd, struct ifreq *ifr);
-static int do_test(int fd, struct ifreq *ifr);
-static int do_phys_id(int fd, struct ifreq *ifr);
-static int do_gpause(int fd, struct ifreq *ifr);
-static int do_spause(int fd, struct ifreq *ifr);
-static int do_gring(int fd, struct ifreq *ifr);
-static int do_sring(int fd, struct ifreq *ifr);
-static int do_schannels(int fd, struct ifreq *ifr);
-static int do_gchannels(int fd, struct ifreq *ifr);
-static int do_gcoalesce(int fd, struct ifreq *ifr);
-static int do_scoalesce(int fd, struct ifreq *ifr);
-static int do_goffload(int fd, struct ifreq *ifr);
-static int do_soffload(int fd, struct ifreq *ifr);
-static int do_gstats(int fd, struct ifreq *ifr);
+static int do_gdrv(struct cmd_context *ctx);
+static int do_gset(struct cmd_context *ctx);
+static int do_sset(struct cmd_context *ctx);
+static int do_gregs(struct cmd_context *ctx);
+static int do_nway_rst(struct cmd_context *ctx);
+static int do_geeprom(struct cmd_context *ctx);
+static int do_seeprom(struct cmd_context *ctx);
+static int do_test(struct cmd_context *ctx);
+static int do_phys_id(struct cmd_context *ctx);
+static int do_gpause(struct cmd_context *ctx);
+static int do_spause(struct cmd_context *ctx);
+static int do_gring(struct cmd_context *ctx);
+static int do_sring(struct cmd_context *ctx);
+static int do_schannels(struct cmd_context *ctx);
+static int do_gchannels(struct cmd_context *ctx);
+static int do_gcoalesce(struct cmd_context *ctx);
+static int do_scoalesce(struct cmd_context *ctx);
+static int do_goffload(struct cmd_context *ctx);
+static int do_soffload(struct cmd_context *ctx);
+static int do_gstats(struct cmd_context *ctx);
 static int rxflow_str_to_type(const char *str);
 static int parse_rxfhashopts(char *optstr, u32 *data);
 static char *unparse_rxfhashopts(u64 opts);
 static int dump_rxfhash(int fhash, u64 val);
-static int do_srxclass(int fd, struct ifreq *ifr);
-static int do_grxclass(int fd, struct ifreq *ifr);
-static int do_grxfhindir(int fd, struct ifreq *ifr);
-static int do_srxfhindir(int fd, struct ifreq *ifr);
-static int do_srxclsrule(int fd, struct ifreq *ifr);
-static int do_grxclsrule(int fd, struct ifreq *ifr);
-static int do_flash(int fd, struct ifreq *ifr);
-static int do_permaddr(int fd, struct ifreq *ifr);
-static int do_getfwdump(int fd, struct ifreq *ifr);
-static int do_setfwdump(int fd, struct ifreq *ifr);
-
-static int send_ioctl(int fd, struct ifreq *ifr);
+static int do_srxclass(struct cmd_context *ctx);
+static int do_grxclass(struct cmd_context *ctx);
+static int do_grxfhindir(struct cmd_context *ctx);
+static int do_srxfhindir(struct cmd_context *ctx);
+static int do_srxclsrule(struct cmd_context *ctx);
+static int do_grxclsrule(struct cmd_context *ctx);
+static int do_flash(struct cmd_context *ctx);
+static int do_permaddr(struct cmd_context *ctx);
+static int do_getfwdump(struct cmd_context *ctx);
+static int do_setfwdump(struct cmd_context *ctx);
 
 static enum {
 	MODE_VERSION = -2,
@@ -1982,94 +1980,92 @@ static int dump_rxfhash(int fhash, u64 val)
 
 static int doit(void)
 {
-	struct ifreq ifr;
-	int fd;
+	struct cmd_context ctx;
 
 	/* Setup our control structures. */
-	memset(&ifr, 0, sizeof(ifr));
-	strcpy(ifr.ifr_name, devname);
+	memset(&ctx.ifr, 0, sizeof(ctx.ifr));
+	strcpy(ctx.ifr.ifr_name, devname);
 
 	/* Open control socket. */
-	fd = socket(AF_INET, SOCK_DGRAM, 0);
-	if (fd < 0) {
+	ctx.fd = socket(AF_INET, SOCK_DGRAM, 0);
+	if (ctx.fd < 0) {
 		perror("Cannot get control socket");
 		return 70;
 	}
 
 	/* all of these are expected to populate ifr->ifr_data as needed */
 	if (mode == MODE_GDRV) {
-		return do_gdrv(fd, &ifr);
+		return do_gdrv(&ctx);
 	} else if (mode == MODE_GSET) {
-		return do_gset(fd, &ifr);
+		return do_gset(&ctx);
 	} else if (mode == MODE_SSET) {
-		return do_sset(fd, &ifr);
+		return do_sset(&ctx);
 	} else if (mode == MODE_GREGS) {
-		return do_gregs(fd, &ifr);
+		return do_gregs(&ctx);
 	} else if (mode == MODE_NWAY_RST) {
-		return do_nway_rst(fd, &ifr);
+		return do_nway_rst(&ctx);
 	} else if (mode == MODE_GEEPROM) {
-		return do_geeprom(fd, &ifr);
+		return do_geeprom(&ctx);
 	} else if (mode == MODE_SEEPROM) {
-		return do_seeprom(fd, &ifr);
+		return do_seeprom(&ctx);
 	} else if (mode == MODE_TEST) {
-		return do_test(fd, &ifr);
+		return do_test(&ctx);
 	} else if (mode == MODE_PHYS_ID) {
-		return do_phys_id(fd, &ifr);
+		return do_phys_id(&ctx);
 	} else if (mode == MODE_GPAUSE) {
-		return do_gpause(fd, &ifr);
+		return do_gpause(&ctx);
 	} else if (mode == MODE_SPAUSE) {
-		return do_spause(fd, &ifr);
+		return do_spause(&ctx);
 	} else if (mode == MODE_GCOALESCE) {
-		return do_gcoalesce(fd, &ifr);
+		return do_gcoalesce(&ctx);
 	} else if (mode == MODE_SCOALESCE) {
-		return do_scoalesce(fd, &ifr);
+		return do_scoalesce(&ctx);
 	} else if (mode == MODE_GRING) {
-		return do_gring(fd, &ifr);
+		return do_gring(&ctx);
 	} else if (mode == MODE_SRING) {
-		return do_sring(fd, &ifr);
+		return do_sring(&ctx);
 	} else if (mode == MODE_GCHANNELS) {
-		return do_gchannels(fd, &ifr);
+		return do_gchannels(&ctx);
 	} else if (mode == MODE_SCHANNELS) {
-		return do_schannels(fd, &ifr);
+		return do_schannels(&ctx);
 	} else if (mode == MODE_GOFFLOAD) {
-		return do_goffload(fd, &ifr);
+		return do_goffload(&ctx);
 	} else if (mode == MODE_SOFFLOAD) {
-		return do_soffload(fd, &ifr);
+		return do_soffload(&ctx);
 	} else if (mode == MODE_GSTATS) {
-		return do_gstats(fd, &ifr);
+		return do_gstats(&ctx);
 	} else if (mode == MODE_GNFC) {
-		return do_grxclass(fd, &ifr);
+		return do_grxclass(&ctx);
 	} else if (mode == MODE_SNFC) {
-		return do_srxclass(fd, &ifr);
+		return do_srxclass(&ctx);
 	} else if (mode == MODE_GRXFHINDIR) {
-		return do_grxfhindir(fd, &ifr);
+		return do_grxfhindir(&ctx);
 	} else if (mode == MODE_SRXFHINDIR) {
-		return do_srxfhindir(fd, &ifr);
+		return do_srxfhindir(&ctx);
 	} else if (mode == MODE_SCLSRULE) {
-		return do_srxclsrule(fd, &ifr);
+		return do_srxclsrule(&ctx);
 	} else if (mode == MODE_GCLSRULE) {
-		return do_grxclsrule(fd, &ifr);
+		return do_grxclsrule(&ctx);
 	} else if (mode == MODE_FLASHDEV) {
-		return do_flash(fd, &ifr);
+		return do_flash(&ctx);
 	} else if (mode == MODE_PERMADDR) {
-		return do_permaddr(fd, &ifr);
+		return do_permaddr(&ctx);
 	} else if (mode == MODE_GET_DUMP) {
-		return do_getfwdump(fd, &ifr);
+		return do_getfwdump(&ctx);
 	} else if (mode == MODE_SET_DUMP) {
-		return do_setfwdump(fd, &ifr);
+		return do_setfwdump(&ctx);
 	}
 
 	return 69;
 }
 
-static int do_gdrv(int fd, struct ifreq *ifr)
+static int do_gdrv(struct cmd_context *ctx)
 {
 	int err;
 	struct ethtool_drvinfo drvinfo;
 
 	drvinfo.cmd = ETHTOOL_GDRVINFO;
-	ifr->ifr_data = (caddr_t)&drvinfo;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &drvinfo);
 	if (err < 0) {
 		perror("Cannot get driver information");
 		return 71;
@@ -2077,7 +2073,7 @@ static int do_gdrv(int fd, struct ifreq *ifr)
 	return dump_drvinfo(&drvinfo);
 }
 
-static int do_gpause(int fd, struct ifreq *ifr)
+static int do_gpause(struct cmd_context *ctx)
 {
 	struct ethtool_cmd ecmd;
 	int err;
@@ -2085,8 +2081,7 @@ static int do_gpause(int fd, struct ifreq *ifr)
 	fprintf(stdout, "Pause parameters for %s:\n", devname);
 
 	epause.cmd = ETHTOOL_GPAUSEPARAM;
-	ifr->ifr_data = (caddr_t)&epause;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &epause);
 	if (err) {
 		perror("Cannot get device pause settings");
 		return 76;
@@ -2094,8 +2089,7 @@ static int do_gpause(int fd, struct ifreq *ifr)
 
 	if (epause.autoneg) {
 		ecmd.cmd = ETHTOOL_GSET;
-		ifr->ifr_data = (caddr_t)&ecmd;
-		err = send_ioctl(fd, ifr);
+		err = send_ioctl(ctx, &ecmd);
 		if (err) {
 			perror("Cannot get device settings");
 			return 1;
@@ -2137,13 +2131,12 @@ static void do_generic_set(struct cmdline_info *info,
 		do_generic_set1(&info[i], changed_out);
 }
 
-static int do_spause(int fd, struct ifreq *ifr)
+static int do_spause(struct cmd_context *ctx)
 {
 	int err, changed = 0;
 
 	epause.cmd = ETHTOOL_GPAUSEPARAM;
-	ifr->ifr_data = (caddr_t)&epause;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &epause);
 	if (err) {
 		perror("Cannot get device pause settings");
 		return 77;
@@ -2157,8 +2150,7 @@ static int do_spause(int fd, struct ifreq *ifr)
 	}
 
 	epause.cmd = ETHTOOL_SPAUSEPARAM;
-	ifr->ifr_data = (caddr_t)&epause;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &epause);
 	if (err) {
 		perror("Cannot set device pause parameters");
 		return 79;
@@ -2167,13 +2159,12 @@ static int do_spause(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-static int do_sring(int fd, struct ifreq *ifr)
+static int do_sring(struct cmd_context *ctx)
 {
 	int err, changed = 0;
 
 	ering.cmd = ETHTOOL_GRINGPARAM;
-	ifr->ifr_data = (caddr_t)&ering;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &ering);
 	if (err) {
 		perror("Cannot get device ring settings");
 		return 76;
@@ -2187,8 +2178,7 @@ static int do_sring(int fd, struct ifreq *ifr)
 	}
 
 	ering.cmd = ETHTOOL_SRINGPARAM;
-	ifr->ifr_data = (caddr_t)&ering;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &ering);
 	if (err) {
 		perror("Cannot set device ring parameters");
 		return 81;
@@ -2197,15 +2187,14 @@ static int do_sring(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-static int do_gring(int fd, struct ifreq *ifr)
+static int do_gring(struct cmd_context *ctx)
 {
 	int err;
 
 	fprintf(stdout, "Ring parameters for %s:\n", devname);
 
 	ering.cmd = ETHTOOL_GRINGPARAM;
-	ifr->ifr_data = (caddr_t)&ering;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &ering);
 	if (err == 0) {
 		err = dump_ring();
 		if (err)
@@ -2218,13 +2207,12 @@ static int do_gring(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-static int do_schannels(int fd, struct ifreq *ifr)
+static int do_schannels(struct cmd_context *ctx)
 {
 	int err, changed = 0;
 
 	echannels.cmd = ETHTOOL_GCHANNELS;
-	ifr->ifr_data = (caddr_t)&echannels;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &echannels);
 	if (err) {
 		perror("Cannot get device channel parameters");
 		return 1;
@@ -2243,8 +2231,7 @@ static int do_schannels(int fd, struct ifreq *ifr)
 	}
 
 	echannels.cmd = ETHTOOL_SCHANNELS;
-	ifr->ifr_data = (caddr_t)&echannels;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &echannels);
 	if (err) {
 		perror("Cannot set device channel parameters");
 		return 1;
@@ -2253,15 +2240,14 @@ static int do_schannels(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-static int do_gchannels(int fd, struct ifreq *ifr)
+static int do_gchannels(struct cmd_context *ctx)
 {
 	int err;
 
 	fprintf(stdout, "Channel parameters for %s:\n", devname);
 
 	echannels.cmd = ETHTOOL_GCHANNELS;
-	ifr->ifr_data = (caddr_t)&echannels;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &echannels);
 	if (err == 0) {
 		err = dump_channels();
 		if (err)
@@ -2274,15 +2260,14 @@ static int do_gchannels(int fd, struct ifreq *ifr)
 
 }
 
-static int do_gcoalesce(int fd, struct ifreq *ifr)
+static int do_gcoalesce(struct cmd_context *ctx)
 {
 	int err;
 
 	fprintf(stdout, "Coalesce parameters for %s:\n", devname);
 
 	ecoal.cmd = ETHTOOL_GCOALESCE;
-	ifr->ifr_data = (caddr_t)&ecoal;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &ecoal);
 	if (err == 0) {
 		err = dump_coalesce();
 		if (err)
@@ -2295,13 +2280,12 @@ static int do_gcoalesce(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-static int do_scoalesce(int fd, struct ifreq *ifr)
+static int do_scoalesce(struct cmd_context *ctx)
 {
 	int err, changed = 0;
 
 	ecoal.cmd = ETHTOOL_GCOALESCE;
-	ifr->ifr_data = (caddr_t)&ecoal;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &ecoal);
 	if (err) {
 		perror("Cannot get device coalesce settings");
 		return 76;
@@ -2316,8 +2300,7 @@ static int do_scoalesce(int fd, struct ifreq *ifr)
 	}
 
 	ecoal.cmd = ETHTOOL_SCOALESCE;
-	ifr->ifr_data = (caddr_t)&ecoal;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &ecoal);
 	if (err) {
 		perror("Cannot set device coalesce parameters");
 		return 81;
@@ -2326,7 +2309,7 @@ static int do_scoalesce(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-static int do_goffload(int fd, struct ifreq *ifr)
+static int do_goffload(struct cmd_context *ctx)
 {
 	struct ethtool_value eval;
 	int err, allfail = 1, rx = 0, tx = 0, sg = 0;
@@ -2336,8 +2319,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 	fprintf(stdout, "Offload parameters for %s:\n", devname);
 
 	eval.cmd = ETHTOOL_GRXCSUM;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &eval);
 	if (err)
 		perror("Cannot get device rx csum settings");
 	else {
@@ -2346,8 +2328,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 	}
 
 	eval.cmd = ETHTOOL_GTXCSUM;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &eval);
 	if (err)
 		perror("Cannot get device tx csum settings");
 	else {
@@ -2356,8 +2337,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 	}
 
 	eval.cmd = ETHTOOL_GSG;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &eval);
 	if (err)
 		perror("Cannot get device scatter-gather settings");
 	else {
@@ -2366,8 +2346,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 	}
 
 	eval.cmd = ETHTOOL_GTSO;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &eval);
 	if (err)
 		perror("Cannot get device tcp segmentation offload settings");
 	else {
@@ -2376,8 +2355,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 	}
 
 	eval.cmd = ETHTOOL_GUFO;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
+	err = send_ioctl(ctx, &eval);
 	if (err)
 		perror("Cannot get device udp large send offload settings");
 	else {
@@ -2386,8 +2364,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 	}
 
 	eval.cmd = ETHTOOL_GGSO;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
+	err = send_ioctl(ctx, &eval);
 	if (err)
 		perror("Cannot get device generic segmentation offload settings");
 	else {
@@ -2396,8 +2373,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 	}
 
 	eval.cmd = ETHTOOL_GFLAGS;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
+	err = send_ioctl(ctx, &eval);
 	if (err) {
 		perror("Cannot get device flags");
 	} else {
@@ -2410,8 +2386,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 	}
 
 	eval.cmd = ETHTOOL_GGRO;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
+	err = send_ioctl(ctx, &eval);
 	if (err)
 		perror("Cannot get device GRO settings");
 	else {
@@ -2428,7 +2403,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 			    ntuple, rxhash);
 }
 
-static int do_soffload(int fd, struct ifreq *ifr)
+static int do_soffload(struct cmd_context *ctx)
 {
 	struct ethtool_value eval;
 	int err, changed = 0;
@@ -2437,8 +2412,7 @@ static int do_soffload(int fd, struct ifreq *ifr)
 		changed = 1;
 		eval.cmd = ETHTOOL_SRXCSUM;
 		eval.data = (off_csum_rx_wanted == 1);
-		ifr->ifr_data = (caddr_t)&eval;
-		err = send_ioctl(fd, ifr);
+		err = send_ioctl(ctx, &eval);
 		if (err) {
 			perror("Cannot set device rx csum settings");
 			return 84;
@@ -2449,8 +2423,7 @@ static int do_soffload(int fd, struct ifreq *ifr)
 		changed = 1;
 		eval.cmd = ETHTOOL_STXCSUM;
 		eval.data = (off_csum_tx_wanted == 1);
-		ifr->ifr_data = (caddr_t)&eval;
-		err = send_ioctl(fd, ifr);
+		err = send_ioctl(ctx, &eval);
 		if (err) {
 			perror("Cannot set device tx csum settings");
 			return 85;
@@ -2461,8 +2434,7 @@ static int do_soffload(int fd, struct ifreq *ifr)
 		changed = 1;
 		eval.cmd = ETHTOOL_SSG;
 		eval.data = (off_sg_wanted == 1);
-		ifr->ifr_data = (caddr_t)&eval;
-		err = send_ioctl(fd, ifr);
+		err = send_ioctl(ctx, &eval);
 		if (err) {
 			perror("Cannot set device scatter-gather settings");
 			return 86;
@@ -2473,8 +2445,7 @@ static int do_soffload(int fd, struct ifreq *ifr)
 		changed = 1;
 		eval.cmd = ETHTOOL_STSO;
 		eval.data = (off_tso_wanted == 1);
-		ifr->ifr_data = (caddr_t)&eval;
-		err = send_ioctl(fd, ifr);
+		err = send_ioctl(ctx, &eval);
 		if (err) {
 			perror("Cannot set device tcp segmentation offload settings");
 			return 88;
@@ -2484,8 +2455,7 @@ static int do_soffload(int fd, struct ifreq *ifr)
 		changed = 1;
 		eval.cmd = ETHTOOL_SUFO;
 		eval.data = (off_ufo_wanted == 1);
-		ifr->ifr_data = (caddr_t)&eval;
-		err = ioctl(fd, SIOCETHTOOL, ifr);
+		err = send_ioctl(ctx, &eval);
 		if (err) {
 			perror("Cannot set device udp large send offload settings");
 			return 89;
@@ -2495,8 +2465,7 @@ static int do_soffload(int fd, struct ifreq *ifr)
 		changed = 1;
 		eval.cmd = ETHTOOL_SGSO;
 		eval.data = (off_gso_wanted == 1);
-		ifr->ifr_data = (caddr_t)&eval;
-		err = ioctl(fd, SIOCETHTOOL, ifr);
+		err = send_ioctl(ctx, &eval);
 		if (err) {
 			perror("Cannot set device generic segmentation offload settings");
 			return 90;
@@ -2506,8 +2475,7 @@ static int do_soffload(int fd, struct ifreq *ifr)
 		changed = 1;
 		eval.cmd = ETHTOOL_GFLAGS;
 		eval.data = 0;
-		ifr->ifr_data = (caddr_t)&eval;
-		err = ioctl(fd, SIOCETHTOOL, ifr);
+		err = send_ioctl(ctx, &eval);
 		if (err) {
 			perror("Cannot get device flag settings");
 			return 91;
@@ -2517,7 +2485,7 @@ static int do_soffload(int fd, struct ifreq *ifr)
 		eval.data = ((eval.data & ~off_flags_mask) |
 			     off_flags_wanted);
 
-		err = ioctl(fd, SIOCETHTOOL, ifr);
+		err = send_ioctl(ctx, &eval);
 		if (err) {
 			perror("Cannot set device flag settings");
 			return 92;
@@ -2527,8 +2495,7 @@ static int do_soffload(int fd, struct ifreq *ifr)
 		changed = 1;
 		eval.cmd = ETHTOOL_SGRO;
 		eval.data = (off_gro_wanted == 1);
-		ifr->ifr_data = (caddr_t)&eval;
-		err = ioctl(fd, SIOCETHTOOL, ifr);
+		err = send_ioctl(ctx, &eval);
 		if (err) {
 			perror("Cannot set device GRO settings");
 			return 93;
@@ -2542,7 +2509,7 @@ static int do_soffload(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-static int do_gset(int fd, struct ifreq *ifr)
+static int do_gset(struct cmd_context *ctx)
 {
 	int err;
 	struct ethtool_cmd ecmd;
@@ -2553,8 +2520,7 @@ static int do_gset(int fd, struct ifreq *ifr)
 	fprintf(stdout, "Settings for %s:\n", devname);
 
 	ecmd.cmd = ETHTOOL_GSET;
-	ifr->ifr_data = (caddr_t)&ecmd;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &ecmd);
 	if (err == 0) {
 		err = dump_ecmd(&ecmd);
 		if (err)
@@ -2565,8 +2531,7 @@ static int do_gset(int fd, struct ifreq *ifr)
 	}
 
 	wolinfo.cmd = ETHTOOL_GWOL;
-	ifr->ifr_data = (caddr_t)&wolinfo;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &wolinfo);
 	if (err == 0) {
 		err = dump_wol(&wolinfo);
 		if (err)
@@ -2577,8 +2542,7 @@ static int do_gset(int fd, struct ifreq *ifr)
 	}
 
 	edata.cmd = ETHTOOL_GMSGLVL;
-	ifr->ifr_data = (caddr_t)&edata;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &edata);
 	if (err == 0) {
 		fprintf(stdout, "	Current message level: 0x%08x (%d)\n"
 			"			       ",
@@ -2592,8 +2556,7 @@ static int do_gset(int fd, struct ifreq *ifr)
 	}
 
 	edata.cmd = ETHTOOL_GLINK;
-	ifr->ifr_data = (caddr_t)&edata;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &edata);
 	if (err == 0) {
 		fprintf(stdout, "	Link detected: %s\n",
 			edata.data ? "yes":"no");
@@ -2609,7 +2572,7 @@ static int do_gset(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-static int do_sset(int fd, struct ifreq *ifr)
+static int do_sset(struct cmd_context *ctx)
 {
 	int err;
 
@@ -2617,8 +2580,7 @@ static int do_sset(int fd, struct ifreq *ifr)
 		struct ethtool_cmd ecmd;
 
 		ecmd.cmd = ETHTOOL_GSET;
-		ifr->ifr_data = (caddr_t)&ecmd;
-		err = send_ioctl(fd, ifr);
+		err = send_ioctl(ctx, &ecmd);
 		if (err < 0) {
 			perror("Cannot get current device settings");
 		} else {
@@ -2671,8 +2633,7 @@ static int do_sset(int fd, struct ifreq *ifr)
 
 			/* Try to perform the update. */
 			ecmd.cmd = ETHTOOL_SSET;
-			ifr->ifr_data = (caddr_t)&ecmd;
-			err = send_ioctl(fd, ifr);
+			err = send_ioctl(ctx, &ecmd);
 			if (err < 0)
 				perror("Cannot set new settings");
 		}
@@ -2696,8 +2657,7 @@ static int do_sset(int fd, struct ifreq *ifr)
 		struct ethtool_wolinfo wol;
 
 		wol.cmd = ETHTOOL_GWOL;
-		ifr->ifr_data = (caddr_t)&wol;
-		err = send_ioctl(fd, ifr);
+		err = send_ioctl(ctx, &wol);
 		if (err < 0) {
 			perror("Cannot get current wake-on-lan settings");
 		} else {
@@ -2714,8 +2674,7 @@ static int do_sset(int fd, struct ifreq *ifr)
 
 			/* Try to perform the update. */
 			wol.cmd = ETHTOOL_SWOL;
-			ifr->ifr_data = (caddr_t)&wol;
-			err = send_ioctl(fd, ifr);
+			err = send_ioctl(ctx, &wol);
 			if (err < 0)
 				perror("Cannot set new wake-on-lan settings");
 		}
@@ -2731,16 +2690,14 @@ static int do_sset(int fd, struct ifreq *ifr)
 		struct ethtool_value edata;
 
 		edata.cmd = ETHTOOL_GMSGLVL;
-		ifr->ifr_data = (caddr_t)&edata;
-		err = send_ioctl(fd, ifr);
+		err = send_ioctl(ctx, &edata);
 		if (err < 0) {
 			perror("Cannot get msglvl");
 		} else {
 			edata.cmd = ETHTOOL_SMSGLVL;
 			edata.data = ((edata.data & ~msglvl_mask) |
 				      msglvl_wanted);
-			ifr->ifr_data = (caddr_t)&edata;
-			err = send_ioctl(fd, ifr);
+			err = send_ioctl(ctx, &edata);
 			if (err < 0)
 				perror("Cannot set new msglvl");
 		}
@@ -2749,15 +2706,14 @@ static int do_sset(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-static int do_gregs(int fd, struct ifreq *ifr)
+static int do_gregs(struct cmd_context *ctx)
 {
 	int err;
 	struct ethtool_drvinfo drvinfo;
 	struct ethtool_regs *regs;
 
 	drvinfo.cmd = ETHTOOL_GDRVINFO;
-	ifr->ifr_data = (caddr_t)&drvinfo;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &drvinfo);
 	if (err < 0) {
 		perror("Cannot get driver information");
 		return 72;
@@ -2770,8 +2726,7 @@ static int do_gregs(int fd, struct ifreq *ifr)
 	}
 	regs->cmd = ETHTOOL_GREGS;
 	regs->len = drvinfo.regdump_len;
-	ifr->ifr_data = (caddr_t)regs;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, regs);
 	if (err < 0) {
 		perror("Cannot get register dump");
 		free(regs);
@@ -2787,29 +2742,27 @@ static int do_gregs(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-static int do_nway_rst(int fd, struct ifreq *ifr)
+static int do_nway_rst(struct cmd_context *ctx)
 {
 	struct ethtool_value edata;
 	int err;
 
 	edata.cmd = ETHTOOL_NWAY_RST;
-	ifr->ifr_data = (caddr_t)&edata;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &edata);
 	if (err < 0)
 		perror("Cannot restart autonegotiation");
 
 	return err;
 }
 
-static int do_geeprom(int fd, struct ifreq *ifr)
+static int do_geeprom(struct cmd_context *ctx)
 {
 	int err;
 	struct ethtool_drvinfo drvinfo;
 	struct ethtool_eeprom *eeprom;
 
 	drvinfo.cmd = ETHTOOL_GDRVINFO;
-	ifr->ifr_data = (caddr_t)&drvinfo;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &drvinfo);
 	if (err < 0) {
 		perror("Cannot get driver information");
 		return 74;
@@ -2829,8 +2782,7 @@ static int do_geeprom(int fd, struct ifreq *ifr)
 	eeprom->cmd = ETHTOOL_GEEPROM;
 	eeprom->len = geeprom_length;
 	eeprom->offset = geeprom_offset;
-	ifr->ifr_data = (caddr_t)eeprom;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, eeprom);
 	if (err < 0) {
 		perror("Cannot get EEPROM data");
 		free(eeprom);
@@ -2842,15 +2794,14 @@ static int do_geeprom(int fd, struct ifreq *ifr)
 	return err;
 }
 
-static int do_seeprom(int fd, struct ifreq *ifr)
+static int do_seeprom(struct cmd_context *ctx)
 {
 	int err;
 	struct ethtool_drvinfo drvinfo;
 	struct ethtool_eeprom *eeprom;
 
 	drvinfo.cmd = ETHTOOL_GDRVINFO;
-	ifr->ifr_data = (caddr_t)&drvinfo;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &drvinfo);
 	if (err < 0) {
 		perror("Cannot get driver information");
 		return 74;
@@ -2881,8 +2832,7 @@ static int do_seeprom(int fd, struct ifreq *ifr)
 	if (!seeprom_value_seen)
 		eeprom->len = fread(eeprom->data, 1, eeprom->len, stdin);
 
-	ifr->ifr_data = (caddr_t)eeprom;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, eeprom);
 	if (err < 0) {
 		perror("Cannot set EEPROM data");
 		err = 87;
@@ -2892,7 +2842,7 @@ static int do_seeprom(int fd, struct ifreq *ifr)
 	return err;
 }
 
-static int do_test(int fd, struct ifreq *ifr)
+static int do_test(struct cmd_context *ctx)
 {
 	int err;
 	struct ethtool_drvinfo drvinfo;
@@ -2900,8 +2850,7 @@ static int do_test(int fd, struct ifreq *ifr)
 	struct ethtool_gstrings *strings;
 
 	drvinfo.cmd = ETHTOOL_GDRVINFO;
-	ifr->ifr_data = (caddr_t)&drvinfo;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &drvinfo);
 	if (err < 0) {
 		perror("Cannot get driver information");
 		return 72;
@@ -2921,8 +2870,7 @@ static int do_test(int fd, struct ifreq *ifr)
 		test->flags = ETH_TEST_FL_OFFLINE;
 	else
 		test->flags = 0;
-	ifr->ifr_data = (caddr_t)test;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, test);
 	if (err < 0) {
 		perror("Cannot test");
 		free (test);
@@ -2940,8 +2888,7 @@ static int do_test(int fd, struct ifreq *ifr)
 	strings->cmd = ETHTOOL_GSTRINGS;
 	strings->string_set = ETH_SS_TEST;
 	strings->len = drvinfo.testinfo_len;
-	ifr->ifr_data = (caddr_t)strings;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, strings);
 	if (err < 0) {
 		perror("Cannot get strings");
 		free (test);
@@ -2955,22 +2902,21 @@ static int do_test(int fd, struct ifreq *ifr)
 	return err;
 }
 
-static int do_phys_id(int fd, struct ifreq *ifr)
+static int do_phys_id(struct cmd_context *ctx)
 {
 	int err;
 	struct ethtool_value edata;
 
 	edata.cmd = ETHTOOL_PHYS_ID;
 	edata.data = phys_id_time;
-	ifr->ifr_data = (caddr_t)&edata;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &edata);
 	if (err < 0)
 		perror("Cannot identify NIC");
 
 	return err;
 }
 
-static int do_gstats(int fd, struct ifreq *ifr)
+static int do_gstats(struct cmd_context *ctx)
 {
 	struct ethtool_drvinfo drvinfo;
 	struct ethtool_gstrings *strings;
@@ -2979,8 +2925,7 @@ static int do_gstats(int fd, struct ifreq *ifr)
 	int err;
 
 	drvinfo.cmd = ETHTOOL_GDRVINFO;
-	ifr->ifr_data = (caddr_t)&drvinfo;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &drvinfo);
 	if (err < 0) {
 		perror("Cannot get driver information");
 		return 71;
@@ -3005,8 +2950,7 @@ static int do_gstats(int fd, struct ifreq *ifr)
 	strings->cmd = ETHTOOL_GSTRINGS;
 	strings->string_set = ETH_SS_STATS;
 	strings->len = n_stats;
-	ifr->ifr_data = (caddr_t) strings;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, strings);
 	if (err < 0) {
 		perror("Cannot get stats strings information");
 		free(strings);
@@ -3016,8 +2960,7 @@ static int do_gstats(int fd, struct ifreq *ifr)
 
 	stats->cmd = ETHTOOL_GSTATS;
 	stats->n_stats = n_stats;
-	ifr->ifr_data = (caddr_t) stats;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, stats);
 	if (err < 0) {
 		perror("Cannot get stats information");
 		free(strings);
@@ -3040,7 +2983,7 @@ static int do_gstats(int fd, struct ifreq *ifr)
 }
 

-static int do_srxclass(int fd, struct ifreq *ifr)
+static int do_srxclass(struct cmd_context *ctx)
 {
 	int err;
 
@@ -3051,8 +2994,7 @@ static int do_srxclass(int fd, struct ifreq *ifr)
 		nfccmd.flow_type = rx_fhash_set;
 		nfccmd.data = rx_fhash_val;
 
-		ifr->ifr_data = (caddr_t)&nfccmd;
-		err = ioctl(fd, SIOCETHTOOL, ifr);
+		err = send_ioctl(ctx, &nfccmd);
 		if (err < 0)
 			perror("Cannot change RX network flow hashing options");
 
@@ -3061,7 +3003,7 @@ static int do_srxclass(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-static int do_grxclass(int fd, struct ifreq *ifr)
+static int do_grxclass(struct cmd_context *ctx)
 {
 	int err;
 
@@ -3070,8 +3012,7 @@ static int do_grxclass(int fd, struct ifreq *ifr)
 
 		nfccmd.cmd = ETHTOOL_GRXFH;
 		nfccmd.flow_type = rx_fhash_get;
-		ifr->ifr_data = (caddr_t)&nfccmd;
-		err = ioctl(fd, SIOCETHTOOL, ifr);
+		err = send_ioctl(ctx, &nfccmd);
 		if (err < 0)
 			perror("Cannot get RX network flow hashing options");
 		else
@@ -3081,7 +3022,7 @@ static int do_grxclass(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-static int do_grxfhindir(int fd, struct ifreq *ifr)
+static int do_grxfhindir(struct cmd_context *ctx)
 {
 	struct ethtool_rxnfc ring_count;
 	struct ethtool_rxfh_indir indir_head;
@@ -3090,8 +3031,7 @@ static int do_grxfhindir(int fd, struct ifreq *ifr)
 	int err;
 
 	ring_count.cmd = ETHTOOL_GRXRINGS;
-	ifr->ifr_data = (caddr_t) &ring_count;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &ring_count);
 	if (err < 0) {
 		perror("Cannot get RX ring count");
 		return 102;
@@ -3099,8 +3039,7 @@ static int do_grxfhindir(int fd, struct ifreq *ifr)
 
 	indir_head.cmd = ETHTOOL_GRXFHINDIR;
 	indir_head.size = 0;
-	ifr->ifr_data = (caddr_t) &indir_head;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &indir_head);
 	if (err < 0) {
 		perror("Cannot get RX flow hash indirection table size");
 		return 103;
@@ -3110,8 +3049,7 @@ static int do_grxfhindir(int fd, struct ifreq *ifr)
 		       indir_head.size * sizeof(*indir->ring_index));
 	indir->cmd = ETHTOOL_GRXFHINDIR;
 	indir->size = indir_head.size;
-	ifr->ifr_data = (caddr_t) indir;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, indir);
 	if (err < 0) {
 		perror("Cannot get RX flow hash indirection table");
 		return 103;
@@ -3129,7 +3067,7 @@ static int do_grxfhindir(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-static int do_srxfhindir(int fd, struct ifreq *ifr)
+static int do_srxfhindir(struct cmd_context *ctx)
 {
 	struct ethtool_rxfh_indir indir_head;
 	struct ethtool_rxfh_indir *indir;
@@ -3141,8 +3079,7 @@ static int do_srxfhindir(int fd, struct ifreq *ifr)
 
 	indir_head.cmd = ETHTOOL_GRXFHINDIR;
 	indir_head.size = 0;
-	ifr->ifr_data = (caddr_t) &indir_head;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &indir_head);
 	if (err < 0) {
 		perror("Cannot get RX flow hash indirection table size");
 		return 104;
@@ -3188,8 +3125,7 @@ static int do_srxfhindir(int fd, struct ifreq *ifr)
 		}
 	}
 
-	ifr->ifr_data = (caddr_t) indir;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, indir);
 	if (err < 0) {
 		perror("Cannot set RX flow hash indirection table");
 		return 105;
@@ -3198,7 +3134,7 @@ static int do_srxfhindir(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-static int do_flash(int fd, struct ifreq *ifr)
+static int do_flash(struct cmd_context *ctx)
 {
 	struct ethtool_flash efl;
 	int err;
@@ -3222,15 +3158,14 @@ static int do_flash(int fd, struct ifreq *ifr)
 	else
 		efl.region = flash_region;
 
-	ifr->ifr_data = (caddr_t)&efl;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &efl);
 	if (err < 0)
 		perror("Flashing failed");
 
 	return err;
 }
 
-static int do_permaddr(int fd, struct ifreq *ifr)
+static int do_permaddr(struct cmd_context *ctx)
 {
 	int i, err;
 	struct ethtool_perm_addr *epaddr;
@@ -3238,9 +3173,8 @@ static int do_permaddr(int fd, struct ifreq *ifr)
 	epaddr = malloc(sizeof(struct ethtool_perm_addr) + MAX_ADDR_LEN);
 	epaddr->cmd = ETHTOOL_GPERMADDR;
 	epaddr->size = MAX_ADDR_LEN;
-	ifr->ifr_data = (caddr_t)epaddr;
 
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, epaddr);
 	if (err < 0)
 		perror("Cannot read permanent address");
 	else {
@@ -3332,7 +3266,7 @@ static int flow_spec_to_ntuple(struct ethtool_rx_flow_spec *fsp,
 	return 0;
 }
 
-static int do_srxntuple(int fd, struct ifreq *ifr)
+static int do_srxntuple(struct cmd_context *ctx)
 {
 	struct ethtool_rx_ntuple ntuplecmd;
 	struct ethtool_value eval;
@@ -3349,15 +3283,13 @@ static int do_srxntuple(int fd, struct ifreq *ifr)
 	 * flag not being set on the device
 	 */
 	eval.cmd = ETHTOOL_GFLAGS;
-	ifr->ifr_data = (caddr_t)&eval;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
+	err = send_ioctl(ctx, &eval);
 	if (err || !(eval.data & ETH_FLAG_NTUPLE))
 		return -1;
 
 	/* send rule via N-tuple */
 	ntuplecmd.cmd = ETHTOOL_SRXNTUPLE;
-	ifr->ifr_data = (caddr_t)&ntuplecmd;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
+	err = send_ioctl(ctx, &ntuplecmd);
 
 	/*
 	 * Display error only if reponse is something other than op not
@@ -3373,25 +3305,25 @@ static int do_srxntuple(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-static int do_srxclsrule(int fd, struct ifreq *ifr)
+static int do_srxclsrule(struct cmd_context *ctx)
 {
 	int err;
 
 	if (rx_class_rule_added) {
 		/* attempt to add rule via N-tuple specifier */
-		err = do_srxntuple(fd, ifr);
+		err = do_srxntuple(ctx);
 		if (!err)
 			return 0;
 
 		/* attempt to add rule via network flow classifier */
-		err = rxclass_rule_ins(fd, ifr, &rx_rule_fs);
+		err = rxclass_rule_ins(ctx, &rx_rule_fs);
 		if (err < 0) {
 			fprintf(stderr, "Cannot insert"
 				" classification rule\n");
 			return 1;
 		}
 	} else if (rx_class_rule_del >= 0) {
-		err = rxclass_rule_del(fd, ifr, rx_class_rule_del);
+		err = rxclass_rule_del(ctx, rx_class_rule_del);
 
 		if (err < 0) {
 			fprintf(stderr, "Cannot delete"
@@ -3405,28 +3337,27 @@ static int do_srxclsrule(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-static int do_grxclsrule(int fd, struct ifreq *ifr)
+static int do_grxclsrule(struct cmd_context *ctx)
 {
 	struct ethtool_rxnfc nfccmd;
 	int err;
 
 	if (rx_class_rule_get >= 0) {
-		err = rxclass_rule_get(fd, ifr, rx_class_rule_get);
+		err = rxclass_rule_get(ctx, rx_class_rule_get);
 		if (err < 0)
 			fprintf(stderr, "Cannot get RX classification rule\n");
 		return err ? 1 : 0;
 	}
 
 	nfccmd.cmd = ETHTOOL_GRXRINGS;
-	ifr->ifr_data = (caddr_t)&nfccmd;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
+	err = send_ioctl(ctx, &nfccmd);
 	if (err < 0)
 		perror("Cannot get RX rings");
 	else
 		fprintf(stdout, "%d RX rings available\n",
 			(int)nfccmd.data);
 
-	err = rxclass_rule_getall(fd, ifr);
+	err = rxclass_rule_getall(ctx);
 	if (err < 0)
 		fprintf(stderr, "RX classification rule retrieval failed\n");
 
@@ -3459,7 +3390,7 @@ static int do_writefwdump(struct ethtool_dump *dump)
 	return err;
 }
 
-static int do_getfwdump(int fd, struct ifreq *ifr)
+static int do_getfwdump(struct cmd_context *ctx)
 {
 	int err;
 	struct ethtool_dump edata;
@@ -3467,8 +3398,7 @@ static int do_getfwdump(int fd, struct ifreq *ifr)
 
 	edata.cmd = ETHTOOL_GET_DUMP_FLAG;
 
-	ifr->ifr_data = (caddr_t) &edata;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &edata);
 	if (err < 0) {
 		perror("Can not get dump level\n");
 		return 1;
@@ -3485,8 +3415,7 @@ static int do_getfwdump(int fd, struct ifreq *ifr)
 	}
 	data->cmd = ETHTOOL_GET_DUMP_DATA;
 	data->len = edata.len;
-	ifr->ifr_data = (caddr_t) data;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, data);
 	if (err < 0) {
 		perror("Can not get dump data\n");
 		err = 1;
@@ -3498,15 +3427,14 @@ free:
 	return err;
 }
 
-static int do_setfwdump(int fd, struct ifreq *ifr)
+static int do_setfwdump(struct cmd_context *ctx)
 {
 	int err;
 	struct ethtool_dump dump;
 
 	dump.cmd = ETHTOOL_SET_DUMP;
 	dump.flag = dump_flag;
-	ifr->ifr_data = (caddr_t)&dump;
-	err = send_ioctl(fd, ifr);
+	err = send_ioctl(ctx, &dump);
 	if (err < 0) {
 		perror("Can not set dump level\n");
 		return 1;
@@ -3514,9 +3442,10 @@ static int do_setfwdump(int fd, struct ifreq *ifr)
 	return 0;
 }
 
-static int send_ioctl(int fd, struct ifreq *ifr)
+int send_ioctl(struct cmd_context *ctx, void *cmd)
 {
-	return ioctl(fd, SIOCETHTOOL, ifr);
+	ctx->ifr.ifr_data = cmd;
+	return ioctl(ctx->fd, SIOCETHTOOL, &ctx->ifr);
 }
 
 int main(int argc, char **argp, char **envp)
diff --git a/internal.h b/internal.h
index 2b6a54a..c2f504a 100644
--- a/internal.h
+++ b/internal.h
@@ -88,6 +88,14 @@ static inline int test_bit(unsigned int nr, const unsigned long *addr)
 
 #define	RX_CLS_LOC_UNSPEC	0xffffffffUL
 
+/* Context for sub-commands */
+struct cmd_context {
+	int fd;			/* socket suitable for ethtool ioctl */
+	struct ifreq ifr;	/* ifreq suitable for ethtool ioctl */
+};
+
+int send_ioctl(struct cmd_context *ctx, void *cmd);
+
 /* National Semiconductor DP83815, DP83816 */
 int natsemi_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 int natsemi_dump_eeprom(struct ethtool_drvinfo *info,
@@ -155,10 +163,10 @@ int st_gmac_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 /* Rx flow classification */
 int rxclass_parse_ruleopts(char **optstr, int opt_cnt,
 			   struct ethtool_rx_flow_spec *fsp);
-int rxclass_rule_getall(int fd, struct ifreq *ifr);
-int rxclass_rule_get(int fd, struct ifreq *ifr, __u32 loc);
-int rxclass_rule_ins(int fd, struct ifreq *ifr,
+int rxclass_rule_getall(struct cmd_context *ctx);
+int rxclass_rule_get(struct cmd_context *ctx, __u32 loc);
+int rxclass_rule_ins(struct cmd_context *ctx,
 		     struct ethtool_rx_flow_spec *fsp);
-int rxclass_rule_del(int fd, struct ifreq *ifr, __u32 loc);
+int rxclass_rule_del(struct cmd_context *ctx, __u32 loc);
 
 #endif /* ETHTOOL_INTERNAL_H__ */
diff --git a/rxclass.c b/rxclass.c
index 809b073..dec9dd5 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -203,7 +203,7 @@ static void rxclass_print_rule(struct ethtool_rx_flow_spec *fsp)
 	}
 }
 
-static int rxclass_get_count(int fd, struct ifreq *ifr, __u32 *count)
+static int rxclass_get_count(struct cmd_context *ctx, __u32 *count)
 {
 	struct ethtool_rxnfc nfccmd;
 	int err;
@@ -211,8 +211,7 @@ static int rxclass_get_count(int fd, struct ifreq *ifr, __u32 *count)
 	/* request count and store */
 	nfccmd.cmd = ETHTOOL_GRXCLSRLCNT;
 	nfccmd.rule_cnt = 0;
-	ifr->ifr_data = (caddr_t)&nfccmd;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
+	err = send_ioctl(ctx, &nfccmd);
 	*count = nfccmd.rule_cnt;
 	if (err < 0)
 		perror("rxclass: Cannot get RX class rule count");
@@ -220,7 +219,7 @@ static int rxclass_get_count(int fd, struct ifreq *ifr, __u32 *count)
 	return err;
 }
 
-int rxclass_rule_get(int fd, struct ifreq *ifr, __u32 loc)
+int rxclass_rule_get(struct cmd_context *ctx, __u32 loc)
 {
 	struct ethtool_rxnfc nfccmd;
 	int err;
@@ -229,8 +228,7 @@ int rxclass_rule_get(int fd, struct ifreq *ifr, __u32 loc)
 	nfccmd.cmd = ETHTOOL_GRXCLSRULE;
 	memset(&nfccmd.fs, 0, sizeof(struct ethtool_rx_flow_spec));
 	nfccmd.fs.location = loc;
-	ifr->ifr_data = (caddr_t)&nfccmd;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
+	err = send_ioctl(ctx, &nfccmd);
 	if (err < 0) {
 		perror("rxclass: Cannot get RX class rule");
 		return err;
@@ -241,7 +239,7 @@ int rxclass_rule_get(int fd, struct ifreq *ifr, __u32 loc)
 	return err;
 }
 
-int rxclass_rule_getall(int fd, struct ifreq *ifr)
+int rxclass_rule_getall(struct cmd_context *ctx)
 {
 	struct ethtool_rxnfc *nfccmd;
 	__u32 *rule_locs;
@@ -249,7 +247,7 @@ int rxclass_rule_getall(int fd, struct ifreq *ifr)
 	__u32 count;
 
 	/* determine rule count */
-	err = rxclass_get_count(fd, ifr, &count);
+	err = rxclass_get_count(ctx, &count);
 	if (err < 0)
 		return err;
 
@@ -266,8 +264,7 @@ int rxclass_rule_getall(int fd, struct ifreq *ifr)
 	/* request location list */
 	nfccmd->cmd = ETHTOOL_GRXCLSRLALL;
 	nfccmd->rule_cnt = count;
-	ifr->ifr_data = (caddr_t)nfccmd;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
+	err = send_ioctl(ctx, nfccmd);
 	if (err < 0) {
 		perror("rxclass: Cannot get RX class rules");
 		free(nfccmd);
@@ -277,7 +274,7 @@ int rxclass_rule_getall(int fd, struct ifreq *ifr)
 	/* write locations to bitmap */
 	rule_locs = nfccmd->rule_locs;
 	for (i = 0; i < count; i++) {
-		err = rxclass_rule_get(fd, ifr, rule_locs[i]);
+		err = rxclass_rule_get(ctx, rule_locs[i]);
 		if (err < 0)
 			break;
 	}
@@ -372,7 +369,7 @@ static int rmgr_find_empty_slot(struct ethtool_rx_flow_spec *fsp)
 	return -1;
 }
 
-static int rmgr_init(int fd, struct ifreq *ifr)
+static int rmgr_init(struct cmd_context *ctx)
 {
 	struct ethtool_rxnfc *nfccmd;
 	int err, i;
@@ -385,7 +382,7 @@ static int rmgr_init(int fd, struct ifreq *ifr)
 	memset(&rmgr, 0, sizeof(struct rmgr_ctrl));
 
 	/* request count and store in rmgr.n_rules */
-	err = rxclass_get_count(fd, ifr, &rmgr.n_rules);
+	err = rxclass_get_count(ctx, &rmgr.n_rules);
 	if (err < 0)
 		return err;
 
@@ -400,8 +397,7 @@ static int rmgr_init(int fd, struct ifreq *ifr)
 	/* request location list */
 	nfccmd->cmd = ETHTOOL_GRXCLSRLALL;
 	nfccmd->rule_cnt = rmgr.n_rules;
-	ifr->ifr_data = (caddr_t)nfccmd;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
+	err = send_ioctl(ctx, nfccmd);
 	if (err < 0) {
 		perror("rmgr: Cannot get RX class rules");
 		free(nfccmd);
@@ -449,13 +445,13 @@ static void rmgr_cleanup(void)
 	rmgr.size = 0;
 }
 
-static int rmgr_set_location(int fd, struct ifreq *ifr,
+static int rmgr_set_location(struct cmd_context *ctx,
 			     struct ethtool_rx_flow_spec *fsp)
 {
 	int err;
 
 	/* init table of available rules */
-	err = rmgr_init(fd, ifr);
+	err = rmgr_init(ctx);
 	if (err < 0)
 		return err;
 
@@ -468,7 +464,7 @@ static int rmgr_set_location(int fd, struct ifreq *ifr,
 	return err;
 }
 
-int rxclass_rule_ins(int fd, struct ifreq *ifr,
+int rxclass_rule_ins(struct cmd_context *ctx,
 		     struct ethtool_rx_flow_spec *fsp)
 {
 	struct ethtool_rxnfc nfccmd;
@@ -480,7 +476,7 @@ int rxclass_rule_ins(int fd, struct ifreq *ifr,
 	 * and allocate a free rule for our use
 	 */
 	if (loc == RX_CLS_LOC_UNSPEC) {
-		err = rmgr_set_location(fd, ifr, fsp);
+		err = rmgr_set_location(ctx, fsp);
 		if (err < 0)
 			return err;
 	}
@@ -488,8 +484,7 @@ int rxclass_rule_ins(int fd, struct ifreq *ifr,
 	/* notify netdev of new rule */
 	nfccmd.cmd = ETHTOOL_SRXCLSRLINS;
 	nfccmd.fs = *fsp;
-	ifr->ifr_data = (caddr_t)&nfccmd;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
+	err = send_ioctl(ctx, &nfccmd);
 	if (err < 0)
 		perror("rmgr: Cannot insert RX class rule");
 	else if (loc == RX_CLS_LOC_UNSPEC)
@@ -498,7 +493,7 @@ int rxclass_rule_ins(int fd, struct ifreq *ifr,
 	return 0;
 }
 
-int rxclass_rule_del(int fd, struct ifreq *ifr, __u32 loc)
+int rxclass_rule_del(struct cmd_context *ctx, __u32 loc)
 {
 	struct ethtool_rxnfc nfccmd;
 	int err;
@@ -506,8 +501,7 @@ int rxclass_rule_del(int fd, struct ifreq *ifr, __u32 loc)
 	/* notify netdev of rule removal */
 	nfccmd.cmd = ETHTOOL_SRXCLSRLDEL;
 	nfccmd.fs.location = loc;
-	ifr->ifr_data = (caddr_t)&nfccmd;
-	err = ioctl(fd, SIOCETHTOOL, ifr);
+	err = send_ioctl(ctx, &nfccmd);
 	if (err < 0)
 		perror("rmgr: Cannot delete RX class rule");
 
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
