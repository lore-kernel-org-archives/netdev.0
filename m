From: Carolyn Wyborny <carolyn.wyborny@intel.com>
Subject: [RFC, 1/2] ethtool:  Implement private flags interface for ethtool application.
Date: Fri,  2 Sep 2011 13:50:30 -0700
Message-ID: <1314996631-4773-1-git-send-email-carolyn.wyborny@intel.com>
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56428 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755791Ab1IBUvN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Sep 2011 16:51:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch completes the user space implementation of the private
flags inteface in ethtool. Using -b/-B options.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
---
 ethtool.8.in |   16 +++++++++
 ethtool.c    |   98 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 113 insertions(+), 1 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 7a0bd43..ebcb233 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -134,6 +134,13 @@ ethtool \- query or control network driver and hardware settings
 .B2 rx on off
 .B2 tx on off
 .HP
+.B ethtool \-b|\-\-show\-priv\-flags
+.I ethX
+.HP
+.B ethtool \-B|\-\-set\-priv\-flags
+.I ethX
+.BN bit
+.HP
 .B ethtool \-c|\-\-show\-coalesce
 .I ethX
 .HP
@@ -342,6 +349,15 @@ Specifies whether RX pause should be enabled.
 .A2 tx on off
 Specifies whether TX pause should be enabled.
 .TP
+.B \-b \-\-show\-priv_flags
+Queries the specified network device for private flags set.
+.TP
+.B \-B \-\-set\-priv_flags
+Changes the private flags of the specified network device.
+.TP
+.BI bit \ N
+Sets the specific bit number in the private flagsg field.
+.TP
 .B \-c \-\-show\-coalesce
 Queries the specified network device for coalescing information.
 .TP
diff --git a/ethtool.c b/ethtool.c
index 943dfb7..4702d04 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -99,6 +99,8 @@ static int do_flash(int fd, struct ifreq *ifr);
 static int do_permaddr(int fd, struct ifreq *ifr);
 static int do_getfwdump(int fd, struct ifreq *ifr);
 static int do_setfwdump(int fd, struct ifreq *ifr);
+static int do_gpflags(int fd, struct ifreq *ifr);
+static int do_spflags(int fd, struct ifreq *ifr);
 
 static int send_ioctl(int fd, struct ifreq *ifr);
 
@@ -133,6 +135,8 @@ static enum {
 	MODE_PERMADDR,
 	MODE_SET_DUMP,
 	MODE_GET_DUMP,
+	MODE_GET_PFLAGS,
+	MODE_SET_PFLAGS,
 } mode = MODE_GSET;
 
 static struct option {
@@ -157,6 +161,9 @@ static struct option {
       "		[ autoneg on|off ]\n"
       "		[ rx on|off ]\n"
       "		[ tx on|off ]\n" },
+    { "-b", "--show-pflags", MODE_GET_PFLAGS, "Show private flags set." },
+    { "-B", "--set-pflags", MODE_SET_PFLAGS, "Set private flags.",
+		"		[value N | bit N]\n" },
     { "-c", "--show-coalesce", MODE_GCOALESCE, "Show coalesce options" },
     { "-C", "--coalesce", MODE_SCOALESCE, "Set coalesce options",
 		"		[adaptive-rx on|off]\n"
@@ -405,6 +412,11 @@ static int rx_class_rule_del = -1;
 static int rx_class_rule_added = 0;
 static struct ethtool_rx_flow_spec rx_rule_fs;
 
+static u32 priv_flags;
+static int priv_flags_changed;
+static u32 priv_flags_val_wanted;
+static u8 priv_flags_bit_wanted;
+
 static enum {
 	ONLINE=0,
 	OFFLINE,
@@ -552,6 +564,10 @@ static struct cmdline_info cmdline_msglvl[] = {
 	  NETIF_MSG_WOL, &msglvl_mask },
 };
 
+static struct cmdline_info cmdline_pflags[] = {
+	{ "value", CMDL_U32, &priv_flags_val_wanted, &priv_flags },
+};
+
 static long long
 get_int_range(char *str, int base, long long min, long long max)
 {
@@ -800,7 +816,9 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_FLASHDEV) ||
 			    (mode == MODE_PERMADDR) ||
 			    (mode == MODE_SET_DUMP) ||
-			    (mode == MODE_GET_DUMP)) {
+			    (mode == MODE_GET_DUMP) ||
+			    (mode == MODE_GET_PFLAGS) ||
+			    (mode == MODE_SET_PFLAGS)) {
 				devname = argp[i];
 				break;
 			}
@@ -884,6 +902,28 @@ static void parse_cmdline(int argc, char **argp)
 				i = argc;
 				break;
 			}
+			if (mode == MODE_SET_PFLAGS) {
+				if (!strcmp(argp[i], "value")) {
+					priv_flags_changed = 1;
+					i++;
+					if (i >= argc)
+						exit_bad_args();
+					priv_flags_val_wanted =
+						get_u32(argp[i], 0);
+				} else if (!strcmp(argp[i], "bit")) {
+					priv_flags_changed = 1;
+					i++;
+					if (i >= argc)
+						exit_bad_args();
+					priv_flags_bit_wanted =
+						get_int(argp[i], 0);
+					priv_flags_val_wanted =
+						(1 >> priv_flags_bit_wanted);
+				} else
+					exit_bad_args();
+				i = argc;
+				break;
+			}
 			if (mode == MODE_SCLSRULE) {
 				if (!strcmp(argp[i], "flow-type")) {
 					i += 1;
@@ -1957,6 +1997,10 @@ static int doit(void)
 		return do_getfwdump(fd, &ifr);
 	} else if (mode == MODE_SET_DUMP) {
 		return do_setfwdump(fd, &ifr);
+	} else if (mode == MODE_GET_PFLAGS) {
+		return do_gpflags(fd, &ifr);
+	} else if (mode == MODE_SET_PFLAGS) {
+		return do_spflags(fd, &ifr);
 	}
 
 	return 69;
@@ -3346,6 +3390,58 @@ static int do_setfwdump(int fd, struct ifreq *ifr)
 	return 0;
 }
 
+static int do_gpflags(int fd, struct ifreq *ifr)
+{
+	int err;
+	struct ethtool_value eval;
+
+	eval.cmd = ETHTOOL_GPFLAGS;
+	ifr->ifr_data = (caddr_t)&eval;
+	err = send_ioctl(fd, ifr);
+	if (err) {
+		perror("Cannot get device private flags");
+	} else {
+		fprintf(stdout, "	Current flags set: 0x%08x (%d)\n"
+			"			       ",
+			eval.data, eval.data);
+		print_flags(cmdline_pflags, ARRAY_SIZE(cmdline_pflags),
+			    eval.data);
+		fprintf(stdout, "\n");
+	}
+	return err;
+}
+
+static int do_spflags(int fd, struct ifreq *ifr)
+{
+	struct ethtool_value eval;
+	int err, changed = 0;
+	eval.cmd = ETHTOOL_GPFLAGS;
+	ifr->ifr_data = (caddr_t)&eval;
+	err = send_ioctl(fd, ifr);
+	if (err) {
+		perror("Cannot get device private flags");
+		return err;
+	}
+
+	priv_flags = eval.data;
+	do_generic_set(cmdline_pflags, ARRAY_SIZE(cmdline_pflags),
+		&changed);
+	if (!changed) {
+		fprintf(stderr, "No private flags have changed, aborting\n");
+			return 1;
+	} else {
+		eval.cmd = ETHTOOL_SPFLAGS;
+		eval.data = priv_flags_val_wanted;
+		ifr->ifr_data = (caddr_t)&eval;
+		err = send_ioctl(fd, ifr);
+		if (err) {
+			perror("Cannot set device private flags.\n");
+			return err;
+		}
+		return 0;
+	}
+}
+
 static int send_ioctl(int fd, struct ifreq *ifr)
 {
 	return ioctl(fd, SIOCETHTOOL, ifr);
-- 
1.7.4.4
