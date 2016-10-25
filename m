From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: [RFC PATCH  ethtool 2/2] ethtool: Support for FEC encoding control
Date: Tue, 25 Oct 2016 14:39:22 -0700
Message-ID: <1477431562-38455-3-git-send-email-vidya@cumulusnetworks.com>
Cc: roees@mellanox.com, dustin@cumulusnetworks.com,
        roopa@cumulusnetworks.com, aviadr@mellanox.com
To: davem@davemloft.net, netdev@vger.kernel.org,
        linville@tuxdriver.com, saeedm@mellanox.com, galp@mellanox.com,
        odedw@mellanox.com, ariela@mellanox.com, tzahio@mellanox.com,
        ddecotig@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34594 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966364AbcJYVjb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 17:39:31 -0400
Received: by mail-pf0-f179.google.com with SMTP id n85so9367929pfi.1
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 14:39:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

 As FEC settings and different FEC modes are mandatory
 and configurable across various interfaces of 25G/50G/100G/40G ,
 the lack of FEC encoding control and reporting today is a source
 for interoperability issues for many vendors

set-fec/show-fec option(s) are  designed to provide  control and report
the FEC encoding on the link.

root@tor: ethtool --set-fec  swp1 encoding [off | RS | BaseR | auto] autoneg [off | on]

Encoding: Types of encoding
Off    :  Turning off any encoding
RS     :  enforcing RS-FEC encoding on supported speeds
BaseR  :  enforcing Base R encoding on supported speeds
Auto   :  Default FEC settings  for  divers , and would represent
          asking the hardware to essentially go into a best effort mode.

Here are a few examples of what we would expect if encoding=auto:
- if autoneg is on, we are  expecting FEC to be negotiated as on or off
  as long as protocol supports it
- if the hardware is capable of detecting the FEC encoding on it's
      receiver it will reconfigure its encoder to match
- in absence of the above, the configuration would be set to IEEE
  defaults.

>From our  understanding , this is essentially what most hardware/driver
combinations are doing today in the absence of a way for users to
control the behavior.

root@tor: ethtool --show-fec  swp1
FEC parameters for swp1:
Autonegotiate:  off
FEC encodings:  RS

ethtool devname output:
root@tor:~# ethtool swp1
Settings for swp1:
root@hpe-7712-03:~# ethtool swp18
Settings for swp18:
    Supported ports: [ FIBRE ]
    Supported link modes:   40000baseCR4/Full
                            40000baseSR4/Full
                            40000baseLR4/Full
                            100000baseSR4/Full
                            100000baseCR4/Full
                            100000baseLR4_ER4/Full
    Supported pause frame use: No
    Supports auto-negotiation: Yes
    Supported FEC modes: [RS | BaseR | None | Not reported]
    Advertised link modes:  Not reported
    Advertised pause frame use: No
    Advertised auto-negotiation: No
    Advertised FEC modes: [RS | BaseR | None | Not reported]
    Speed: 100000Mb/s
    Duplex: Full
    Port: FIBRE
    PHYAD: 106
    Transceiver: internal
    Auto-negotiation: off
    Link detected: yes

Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
---
 ethtool.c | 152 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 152 insertions(+)

diff --git a/ethtool.c b/ethtool.c
index 49ac94e..7fa058c 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -684,6 +684,7 @@ static void dump_link_caps(const char *prefix, const char *an_prefix,
 	};
 	int indent;
 	int did1, new_line_pend, i;
+	int fecreported = 0;
 
 	/* Indent just like the separate functions used to */
 	indent = strlen(prefix) + 14;
@@ -735,6 +736,26 @@ static void dump_link_caps(const char *prefix, const char *an_prefix,
 			fprintf(stdout, "Yes\n");
 		else
 			fprintf(stdout, "No\n");
+
+		fprintf(stdout, "	%s FEC modes: ", prefix);
+		if (ethtool_link_mode_test_bit(
+			    ETHTOOL_LINK_MODE_FEC_NONE_BIT, mask)) {
+			fprintf(stdout, "None\n");
+			fecreported = 1;
+		}
+		if (ethtool_link_mode_test_bit(
+			    ETHTOOL_LINK_MODE_FEC_BASER_BIT, mask)) {
+			fprintf(stdout, "BaseR\n");
+			fecreported = 1;
+		}
+		if (ethtool_link_mode_test_bit(
+			    ETHTOOL_LINK_MODE_FEC_RS_BIT, mask)) {
+			fprintf(stdout, "RS\n");
+			fecreported = 1;
+		}
+		if (!fecreported) {
+			fprintf(stdout, "Not reported\n");
+		}
 	}
 }
 
@@ -1562,6 +1583,42 @@ static void dump_eeecmd(struct ethtool_eee *ep)
 	dump_link_caps("Link partner advertised EEE", "", link_mode, 1);
 }
 
+static void dump_feccmd(struct ethtool_fecparam *ep)
+{
+	static char buf[300];
+
+	memset(buf, 0, sizeof(buf));
+
+	bool first = true;
+
+	fprintf(stdout,
+		"Auto-negotiation: %s\n",
+		ep->autoneg ? "on" : "off");
+	fprintf(stdout, "FEC encodings   :");
+
+	if(ep->fec & ETHTOOL_FEC_NONE) {
+		strcat(buf, "NotSupported");
+		first = false;
+	}
+	if(ep->fec & ETHTOOL_FEC_OFF) {
+		strcat(buf, "None");
+		first = false;
+	}
+	if(ep->fec & ETHTOOL_FEC_BASER) {
+		if (!first)
+			strcat(buf, " | ");
+		strcat(buf, "BaseR");
+		first = false;
+	}
+	if(ep->fec & ETHTOOL_FEC_RS) {
+		if (!first)
+			strcat(buf, " | ");
+		strcat(buf, "RS");
+		first = false;
+	}
+	fprintf(stdout," %s\n", buf);
+}
+
 #define N_SOTS 7
 
 static char *so_timestamping_labels[N_SOTS] = {
@@ -4520,6 +4577,97 @@ static int do_seee(struct cmd_context *ctx)
 	return 0;
 }
 
+static int fecmode_str_to_type(const char *str)
+{
+	int fecmode = 0;
+
+	if (str == NULL) 
+		return fecmode;
+
+	if (!strcmp(str, "auto"))
+		fecmode |= ETHTOOL_FEC_AUTO;
+	else if (!strcmp(str, "off"))
+		fecmode |= ETHTOOL_FEC_OFF;
+	else if (!strcmp(str, "rs"))
+		fecmode |= ETHTOOL_FEC_RS;
+	else if (!strcmp(str, "baser"))
+		fecmode |= ETHTOOL_FEC_BASER;
+
+	return fecmode;
+}
+
+static int do_gfec(struct cmd_context *ctx)
+{
+	struct ethtool_fecparam feccmd;
+
+	if (ctx->argc != 0)
+		exit_bad_args();
+
+	fprintf(stdout, "FEC parameters for %s:\n", ctx->devname);
+
+	feccmd.cmd = ETHTOOL_GFECPARAM;
+	if (send_ioctl(ctx, &feccmd)) {
+		perror("Cannot get FEC settings");
+		return 1;
+	}
+
+	dump_feccmd(&feccmd);
+	return 0;
+}
+
+static int do_sfec(struct cmd_context *ctx)
+{
+	int fec_changed = -1;
+	int changed = 1;
+	struct ethtool_fecparam feccmd;
+	int autoneg_val = -1;
+	int fecmode;
+	char *fecmode_str = NULL;
+	struct cmdline_info cmdline_fec[] = {
+		{ "autoneg", CMDL_BOOL, &autoneg_val,
+		  &feccmd.autoneg },
+		{ "encoding", CMDL_STR,  &fecmode_str,  &feccmd.fec},
+	};
+
+	parse_generic_cmdline(ctx, &fec_changed,
+			cmdline_fec, ARRAY_SIZE(cmdline_fec));
+
+	if(fecmode_str == NULL) 
+                exit_bad_args();
+
+	fecmode = fecmode_str_to_type(fecmode_str);
+        if (!fecmode)
+                exit_bad_args();
+
+	/* Get current FEC parameters */
+	feccmd.cmd = ETHTOOL_GFECPARAM;
+	if (send_ioctl(ctx, &feccmd)) {
+		perror("Cannot get FEC settings");
+		return 1;
+	}
+
+	/* Compare autoneg and fec parameter and if they are same, reject it */
+	if (feccmd.fec == fecmode) {
+		if (feccmd.autoneg == autoneg_val) {
+			changed = 0;
+		}
+	}
+
+	if (!changed) {
+		fprintf(stderr, "no fec parameters changed, aborting\n");
+		return 93;
+	}
+
+	feccmd.cmd = ETHTOOL_SFECPARAM;
+	feccmd.fec = fecmode;
+	feccmd.autoneg = autoneg_val;
+	if (send_ioctl(ctx, &feccmd)) {
+		perror("Cannot set FEC settings");
+		return 1;
+	}
+	return 0;
+}
+
 #ifndef TEST_ETHTOOL
 int send_ioctl(struct cmd_context *ctx, void *cmd)
 {
@@ -4681,6 +4829,10 @@ static const struct option {
 	  "		[ advertise %x ]\n"
 	  "		[ tx-lpi on|off ]\n"
 	  "		[ tx-timer %d ]\n"},
+	{ "--show-fec", 1, do_gfec, "Show FEC settings"},
+	{ "--set-fec", 1, do_sfec, "Set FEC settings",
+	  "		[ autoneg on|off ]\n"
+	  "		[ encoding on|off|RS|BaseR ]\n"},
 	{ "-h|--help", 0, show_usage, "Show this help" },
 	{ "--version", 0, do_version, "Show version number" },
 	{}
-- 
2.1.4
