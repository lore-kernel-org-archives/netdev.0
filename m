From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH RFC] ethtool: add multiple queue support to
 {get,set}_ringparams
Date: Sun, 14 Mar 2010 07:13:50 +0530
Message-ID: <20100314014337.GA17256@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f176.google.com ([209.85.223.176]:45005 "EHLO
	mail-iw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759452Ab0CNBny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Mar 2010 20:43:54 -0500
Received: by mail-iw0-f176.google.com with SMTP id 6so901334iwn.4
        for <netdev@vger.kernel.org>; Sat, 13 Mar 2010 17:43:54 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With network devices and hence device drivers supporting
multiple Tx and Rx rings, currently there is no way for
ethtool to specify which Tx/Rx ring the user wants to get/set.
This patch enhances the get/set ring params option by allowing
the user to specify the Tx/Rx ring id of interest.
Please review.

Current Usage:
ethtool -g <interface name>

ethtool -G <interface name> [new parameters to set]

New Usage:
ethtool -g <interface name> [ RING-ID ]

ethtool -G <interface name> [ RING-ID ] [new parameters to set]

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 ethtool-copy.h |    1 +
 ethtool.8      |    8 ++++++++
 ethtool.c      |   19 +++++++++++++++++--
 3 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 8681f5e..1ac6beb 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -199,6 +199,7 @@ struct ethtool_coalesce {
 /* for configuring RX/TX ring parameters */
 struct ethtool_ringparam {
 	__u32	cmd;	/* ETHTOOL_{G,S}RINGPARAM */
+	__u32	ring_id;
 
 	/* Read only attributes.  These indicate the maximum number
 	 * of pending RX/TX ring entries the driver will allow the
diff --git a/ethtool.8 b/ethtool.8
index eb6430b..14b8984 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -116,9 +116,11 @@ ethtool \- Display or change ethernet card settings
 
 .B ethtool \-g|\-\-show\-ring
 .I ethX
+.RI [ N ]
 
 .B ethtool \-G|\-\-set\-ring
 .I ethX
+.RI [ N ]
 .RB [ rx
 .IR N ]
 .RB [ rx-mini
@@ -287,9 +289,15 @@ Changes the coalescing settings of the specified ethernet device.
 .B \-g \-\-show\-ring
 Queries the specified ethernet device for rx/tx ring parameter information.
 .TP
+.B N
+The tx/rx ring id.
+.TP
 .B \-G \-\-set\-ring
 Changes the rx/tx ring parameters of the specified ethernet device.
 .TP
+.B N
+The tx/rx ring id.
+.TP
 .BI rx \ N
 Changes the number of ring entries for the Rx ring.
 .TP
diff --git a/ethtool.c b/ethtool.c
index fc9e419..650bb8c 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -156,8 +156,10 @@ static struct option {
 		"		[tx-usecs-high N]\n"
 		"		[tx-frames-high N]\n"
 	        "		[sample-interval N]\n" },
-    { "-g", "--show-ring", MODE_GRING, "Query RX/TX ring parameters" },
+    { "-g", "--show-ring", MODE_GRING, "Query RX/TX ring parameters",
+		"		[ RING ID ]\n" },
     { "-G", "--set-ring", MODE_SRING, "Set RX/TX ring parameters",
+		"		[ RING ID ]\n"		
 		"		[ rx N ]\n"
 		"		[ rx-mini N ]\n"
 		"		[ rx-jumbo N ]\n"
@@ -265,6 +267,7 @@ static int pause_rx_wanted = -1;
 static int pause_tx_wanted = -1;
 
 static struct ethtool_ringparam ering;
+static int ring_id = 0;
 static int gring_changed = 0;
 static int ring_rx_wanted = -1;
 static int ring_rx_mini_wanted = -1;
@@ -605,6 +608,10 @@ static void parse_cmdline(int argc, char **argp)
 				flash = 1;
 				break;
 			}
+			if (mode == MODE_SRING) {
+				ring_id = get_int(argp[i], 10);
+				break;
+			}
 			/* fallthrough */
 		default:
 			if (mode == MODE_GREGS) {
@@ -639,6 +646,10 @@ static void parse_cmdline(int argc, char **argp)
 				i = argc;
 				break;
 			}
+			if (mode == MODE_GRING) {
+				ring_id = get_int(argp[i], 10);
+				break;
+			}
 			if (mode == MODE_SRING) {
 				parse_generic_cmdline(argc, argp, i,
 					&gring_changed,
@@ -1761,6 +1772,7 @@ static int do_sring(int fd, struct ifreq *ifr)
 	int err, changed = 0;
 
 	ering.cmd = ETHTOOL_GRINGPARAM;
+	ering.ring_id = ring_id;
 	ifr->ifr_data = (caddr_t)&ering;
 	err = send_ioctl(fd, ifr);
 	if (err) {
@@ -1776,6 +1788,7 @@ static int do_sring(int fd, struct ifreq *ifr)
 	}
 
 	ering.cmd = ETHTOOL_SRINGPARAM;
+	ering.ring_id = ring_id;
 	ifr->ifr_data = (caddr_t)&ering;
 	err = send_ioctl(fd, ifr);
 	if (err) {
@@ -1790,9 +1803,11 @@ static int do_gring(int fd, struct ifreq *ifr)
 {
 	int err;
 
-	fprintf(stdout, "Ring parameters for %s:\n", devname);
+	fprintf(stdout, "Ring parameters for ring id %d for %s:\n",
+							ring_id, devname);
 
 	ering.cmd = ETHTOOL_GRINGPARAM;
+	ering.ring_id = ring_id;
 	ifr->ifr_data = (caddr_t)&ering;
 	err = send_ioctl(fd, ifr);
 	if (err == 0) {
-- 
1.6.3.3

