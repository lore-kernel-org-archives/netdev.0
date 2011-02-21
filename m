From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 1/5] ethtool: Split show_usage() into two functions
Date: Mon, 21 Feb 2011 19:17:50 +0000
Message-ID: <1298315870.2608.69.camel@bwh-desktop>
References: <1298315809.2608.68.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:10148 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228Ab1BUTRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 14:17:53 -0500
In-Reply-To: <1298315809.2608.68.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

show_usage(0) and show_usage(1) now do unrelated things; split it
into show_usage() and exit_bad_args().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |  144 +++++++++++++++++++++++++++++++------------------------------
 1 files changed, 73 insertions(+), 71 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index f680b6d..b9422d3 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -268,32 +268,32 @@ static struct option {
 };
 

-static void show_usage(int badarg) __attribute__((noreturn));
+static void exit_bad_args(void) __attribute__((noreturn));
 
-static void show_usage(int badarg)
+static void exit_bad_args(void)
+{
+	fprintf(stderr,
+		"ethtool: bad command line argument(s)\n"
+		"For more information run ethtool -h\n");
+	exit(1);
+}
+
+static void show_usage(void)
 {
 	int i;
-	if (badarg != 0) {
-		fprintf(stderr,
-			"ethtool: bad command line argument(s)\n"
-			"For more information run ethtool -h\n"
-		);
-	}
-	else {
-		/* ethtool -h */
-		fprintf(stdout, PACKAGE " version " VERSION "\n");
-		fprintf(stdout,
+
+	/* ethtool -h */
+	fprintf(stdout, PACKAGE " version " VERSION "\n");
+	fprintf(stdout,
 		"Usage:\n"
 		"ethtool DEVNAME\tDisplay standard information about device\n");
-		for (i = 0; args[i].srt; i++) {
-			fprintf(stdout, "        ethtool %s|%s %s\t%s\n%s",
-				args[i].srt, args[i].lng,
-				strstr(args[i].srt, "-h") ? "\t" : "DEVNAME",
-				args[i].help,
-				args[i].opthelp ? args[i].opthelp : "");
-		}
+	for (i = 0; args[i].srt; i++) {
+		fprintf(stdout, "        ethtool %s|%s %s\t%s\n%s",
+			args[i].srt, args[i].lng,
+			strstr(args[i].srt, "-h") ? "\t" : "DEVNAME",
+			args[i].help,
+			args[i].opthelp ? args[i].opthelp : "");
 	}
-	exit(badarg);
 }
 
 static char *devname = NULL;
@@ -612,11 +612,11 @@ get_int_range(char *str, int base, long long min, long long max)
 	char *endp;
 
 	if (!str)
-		show_usage(1);
+		exit_bad_args();
 	errno = 0;
 	v = strtoll(str, &endp, base);
 	if (errno || *endp || v < min || v > max)
-		show_usage(1);
+		exit_bad_args();
 	return v;
 }
 
@@ -627,11 +627,11 @@ get_uint_range(char *str, int base, unsigned long long max)
 	char *endp;
 
 	if (!str)
-		show_usage(1);
+		exit_bad_args();
 	errno = 0;
 	v = strtoull(str, &endp, base);
 	if ( errno || *endp || v > max)
-		show_usage(1);
+		exit_bad_args();
 	return v;
 }
 
@@ -664,7 +664,7 @@ static void parse_generic_cmdline(int argc, char **argp,
 					*(int *)info[idx].seen_val = 1;
 				i += 1;
 				if (i >= argc)
-					show_usage(1);
+					exit_bad_args();
 				switch (info[idx].type) {
 				case CMDL_BOOL: {
 					int *p = info[idx].wanted_val;
@@ -673,7 +673,7 @@ static void parse_generic_cmdline(int argc, char **argp,
 					else if (!strcmp(argp[i], "off"))
 						*p = 0;
 					else
-						show_usage(1);
+						exit_bad_args();
 					break;
 				}
 				case CMDL_S32: {
@@ -712,7 +712,7 @@ static void parse_generic_cmdline(int argc, char **argp,
 					u32 *p = info[idx].wanted_val;
 					struct in_addr in;
 					if (!inet_aton(argp[i], &in))
-						show_usage(1);
+						exit_bad_args();
 					*p = in.s_addr;
 					break;
 				}
@@ -728,7 +728,7 @@ static void parse_generic_cmdline(int argc, char **argp,
 						p = info[idx].wanted_val;
 						*p |= info[idx].flag_val;
 					} else if (strcmp(argp[i], "off")) {
-						show_usage(1);
+						exit_bad_args();
 					}
 					break;
 				}
@@ -738,13 +738,13 @@ static void parse_generic_cmdline(int argc, char **argp,
 					break;
 				}
 				default:
-					show_usage(1);
+					exit_bad_args();
 				}
 				break;
 			}
 		}
 		if( !found)
-			show_usage(1);
+			exit_bad_args();
 	}
 }
 
@@ -808,10 +808,12 @@ static void parse_cmdline(int argc, char **argp)
 					break;
 				}
 			if (mode == MODE_HELP ||
-			    (!args[k].srt && argp[i][0] == '-'))
-				show_usage(0);
-			else
+			    (!args[k].srt && argp[i][0] == '-')) {
+				show_usage();
+				exit(0);
+			} else {
 				devname = argp[i];
+			}
 			break;
 		case 2:
 			if ((mode == MODE_SSET) ||
@@ -850,7 +852,7 @@ static void parse_cmdline(int argc, char **argp)
 				} else if (!strcmp(argp[i], "offline")) {
 					test_type = OFFLINE;
 				} else {
-					show_usage(1);
+					exit_bad_args();
 				}
 				break;
 			} else if (mode == MODE_PHYS_ID) {
@@ -923,14 +925,14 @@ static void parse_cmdline(int argc, char **argp)
 				if (!strcmp(argp[i], "flow-type")) {
 					i += 1;
 					if (i >= argc) {
-						show_usage(1);
+						exit_bad_args();
 						break;
 					}
 					parse_rxntupleopts(argc, argp, i);
 					i = argc;
 					break;
 				} else {
-					show_usage(1);
+					exit_bad_args();
 				}
 				break;
 			}
@@ -938,54 +940,54 @@ static void parse_cmdline(int argc, char **argp)
 				if (!strcmp(argp[i], "rx-flow-hash")) {
 					i += 1;
 					if (i >= argc) {
-						show_usage(1);
+						exit_bad_args();
 						break;
 					}
 					rx_fhash_get =
 						rxflow_str_to_type(argp[i]);
 					if (!rx_fhash_get)
-						show_usage(1);
+						exit_bad_args();
 				} else
-					show_usage(1);
+					exit_bad_args();
 				break;
 			}
 			if (mode == MODE_FLASHDEV) {
 				flash_region = strtol(argp[i], NULL, 0);
 				if ((flash_region < 0))
-					show_usage(1);
+					exit_bad_args();
 				break;
 			}
 			if (mode == MODE_SNFC) {
 				if (!strcmp(argp[i], "rx-flow-hash")) {
 					i += 1;
 					if (i >= argc) {
-						show_usage(1);
+						exit_bad_args();
 						break;
 					}
 					rx_fhash_set =
 						rxflow_str_to_type(argp[i]);
 					if (!rx_fhash_set) {
-						show_usage(1);
+						exit_bad_args();
 						break;
 					}
 					i += 1;
 					if (i >= argc) {
-						show_usage(1);
+						exit_bad_args();
 						break;
 					}
 					if (parse_rxfhashopts(argp[i],
 						&rx_fhash_val) < 0)
-						show_usage(1);
+						exit_bad_args();
 					else
 						rx_fhash_changed = 1;
 				} else
-					show_usage(1);
+					exit_bad_args();
 				break;
 			}
 			if (mode == MODE_SRXFHINDIR) {
 				if (!strcmp(argp[i], "equal")) {
 					if (argc != i + 2) {
-						show_usage(1);
+						exit_bad_args();
 						break;
 					}
 					i += 1;
@@ -996,42 +998,42 @@ static void parse_cmdline(int argc, char **argp)
 				} else if (!strcmp(argp[i], "weight")) {
 					i += 1;
 					if (i >= argc) {
-						show_usage(1);
+						exit_bad_args();
 						break;
 					}
 					rxfhindir_weight = argp + i;
 					i = argc;
 				} else {
-					show_usage(1);
+					exit_bad_args();
 				}
 				break;
 			}
 			if (mode != MODE_SSET)
-				show_usage(1);
+				exit_bad_args();
 			if (!strcmp(argp[i], "speed")) {
 				gset_changed = 1;
 				i += 1;
 				if (i >= argc)
-					show_usage(1);
+					exit_bad_args();
 				speed_wanted = get_int(argp[i],10);
 				break;
 			} else if (!strcmp(argp[i], "duplex")) {
 				gset_changed = 1;
 				i += 1;
 				if (i >= argc)
-					show_usage(1);
+					exit_bad_args();
 				if (!strcmp(argp[i], "half"))
 					duplex_wanted = DUPLEX_HALF;
 				else if (!strcmp(argp[i], "full"))
 					duplex_wanted = DUPLEX_FULL;
 				else
-					show_usage(1);
+					exit_bad_args();
 				break;
 			} else if (!strcmp(argp[i], "port")) {
 				gset_changed = 1;
 				i += 1;
 				if (i >= argc)
-					show_usage(1);
+					exit_bad_args();
 				if (!strcmp(argp[i], "tp"))
 					port_wanted = PORT_TP;
 				else if (!strcmp(argp[i], "aui"))
@@ -1043,12 +1045,12 @@ static void parse_cmdline(int argc, char **argp)
 				else if (!strcmp(argp[i], "fibre"))
 					port_wanted = PORT_FIBRE;
 				else
-					show_usage(1);
+					exit_bad_args();
 				break;
 			} else if (!strcmp(argp[i], "autoneg")) {
 				i += 1;
 				if (i >= argc)
-					show_usage(1);
+					exit_bad_args();
 				if (!strcmp(argp[i], "on")) {
 					gset_changed = 1;
 					autoneg_wanted = AUTONEG_ENABLE;
@@ -1056,56 +1058,56 @@ static void parse_cmdline(int argc, char **argp)
 					gset_changed = 1;
 					autoneg_wanted = AUTONEG_DISABLE;
 				} else {
-					show_usage(1);
+					exit_bad_args();
 				}
 				break;
 			} else if (!strcmp(argp[i], "advertise")) {
 				gset_changed = 1;
 				i += 1;
 				if (i >= argc)
-					show_usage(1);
+					exit_bad_args();
 				advertising_wanted = get_int(argp[i], 16);
 				break;
 			} else if (!strcmp(argp[i], "phyad")) {
 				gset_changed = 1;
 				i += 1;
 				if (i >= argc)
-					show_usage(1);
+					exit_bad_args();
 				phyad_wanted = get_int(argp[i], 0);
 				break;
 			} else if (!strcmp(argp[i], "xcvr")) {
 				gset_changed = 1;
 				i += 1;
 				if (i >= argc)
-					show_usage(1);
+					exit_bad_args();
 				if (!strcmp(argp[i], "internal"))
 					xcvr_wanted = XCVR_INTERNAL;
 				else if (!strcmp(argp[i], "external"))
 					xcvr_wanted = XCVR_EXTERNAL;
 				else
-					show_usage(1);
+					exit_bad_args();
 				break;
 			} else if (!strcmp(argp[i], "wol")) {
 				gwol_changed = 1;
 				i++;
 				if (i >= argc)
-					show_usage(1);
+					exit_bad_args();
 				if (parse_wolopts(argp[i], &wol_wanted) < 0)
-					show_usage(1);
+					exit_bad_args();
 				wol_change = 1;
 				break;
 			} else if (!strcmp(argp[i], "sopass")) {
 				gwol_changed = 1;
 				i++;
 				if (i >= argc)
-					show_usage(1);
+					exit_bad_args();
 				get_mac_addr(argp[i], sopass_wanted);
 				sopass_change = 1;
 				break;
 			} else if (!strcmp(argp[i], "msglvl")) {
 				i++;
 				if (i >= argc)
-					show_usage(1);
+					exit_bad_args();
 				if (isdigit((unsigned char)argp[i][0])) {
 					msglvl_changed = 1;
 					msglvl_mask = ~0;
@@ -1122,7 +1124,7 @@ static void parse_cmdline(int argc, char **argp)
 				}
 				break;
 			}
-			show_usage(1);
+			exit_bad_args();
 		}
 	}
 
@@ -1159,9 +1161,9 @@ static void parse_cmdline(int argc, char **argp)
 	}
 
 	if (devname == NULL)
-		show_usage(1);
+		exit_bad_args();
 	if (strlen(devname) >= IFNAMSIZ)
-		show_usage(1);
+		exit_bad_args();
 }
 
 static void dump_supported(struct ethtool_cmd *ep)
@@ -1512,7 +1514,7 @@ static void get_mac_addr(char *src, unsigned char *dest)
 	count = sscanf(src, "%2x:%2x:%2x:%2x:%2x:%2x",
 		&buf[0], &buf[1], &buf[2], &buf[3], &buf[4], &buf[5]);
 	if (count != ETH_ALEN)
-		show_usage(1);
+		exit_bad_args();
 
 	for (i = 0; i < count; i++) {
 		dest[i] = buf[i];
@@ -3026,7 +3028,7 @@ static int do_srxfhindir(int fd, struct ifreq *ifr)
 	int err;
 
 	if (!rxfhindir_equal && !rxfhindir_weight)
-		show_usage(1);
+		exit_bad_args();
 
 	indir_head.cmd = ETHTOOL_GRXFHINDIR;
 	indir_head.size = 0;
@@ -3094,7 +3096,7 @@ static int do_flash(int fd, struct ifreq *ifr)
 
 	if (flash < 0) {
 		fprintf(stdout, "Missing filename argument\n");
-		show_usage(1);
+		exit_bad_args();
 		return 98;
 	}
 
@@ -3160,7 +3162,7 @@ static int do_srxntuple(int fd, struct ifreq *ifr)
 		if (err < 0)
 			perror("Cannot add new RX n-tuple filter");
 	} else {
-		show_usage(1);
+		exit_bad_args();
 	}
 
 	return 0;
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

