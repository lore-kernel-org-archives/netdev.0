From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] ethtool: Add support for setting multiple rx/tx queues
Date: Tue, 31 Jul 2007 13:21:56 -0700
Message-ID: <20070731202156.15813.98302.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43068 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751667AbXGaUV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 16:21:57 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 ethtool-copy.h |   23 +++++++++++++
 ethtool.8      |   23 +++++++++++++
 ethtool.c      |  103 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 149 insertions(+), 0 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index ab9d688..aefd580 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -196,6 +196,23 @@ struct ethtool_ringparam {
 	__u32	tx_pending;
 };
 
+/* for configuring RX/TX queue count */
+struct ethtool_queueparam {
+	__u32	cmd;	/* ETHTOOL_{G,S}QUEUEPARAM */
+
+	/* Read only attributes.  These indicate the maximum number
+	 * of RX/TX queues the driver will allow the user to set.
+	 */
+	__u32	rx_max;
+	__u32	tx_max;
+
+	/* Values changeable by the user.  The valid values are
+	 * in the range 1 to the "*_max" counterpart above.
+	 */
+	__u32	rx;
+	__u32	tx;
+};
+
 /* for configuring link flow control parameters */
 struct ethtool_pauseparam {
 	__u32	cmd;	/* ETHTOOL_{G,S}PAUSEPARAM */
@@ -295,6 +312,8 @@ int ethtool_op_set_lro(struct net_device *dev, u32 data);
  * set_coalesce: Set interrupt coalescing parameters
  * get_ringparam: Report ring sizes
  * set_ringparam: Set ring sizes
+ * get_queueparam: Report ring sizes
+ * set_queueparam: Set ring sizes
  * get_pauseparam: Report pause parameters
  * set_pauseparam: Set pause paramters
  * get_rx_csum: Report whether receive checksums are turned on or off
@@ -356,6 +375,8 @@ struct ethtool_ops {
 	int	(*set_coalesce)(struct net_device *, struct ethtool_coalesce *);
 	void	(*get_ringparam)(struct net_device *, struct ethtool_ringparam *);
 	int	(*set_ringparam)(struct net_device *, struct ethtool_ringparam *);
+	void	(*get_queueparam)(struct net_device *, struct ethtool_queueparam *);
+	int	(*set_queueparam)(struct net_device *, struct ethtool_queueparam *);
 	void	(*get_pauseparam)(struct net_device *, struct ethtool_pauseparam*);
 	int	(*set_pauseparam)(struct net_device *, struct ethtool_pauseparam*);
 	u32	(*get_rx_csum)(struct net_device *);
@@ -422,6 +443,8 @@ struct ethtool_ops {
 #define ETHTOOL_SGSO		0x00000024 /* Set GSO enable (ethtool_value) */
 #define ETHTOOL_GLRO		0x00000025 /* Get LRO enable (ethtool_value) */
 #define ETHTOOL_SLRO		0x00000026 /* Set LRO enable (ethtool_value) */
+#define ETHTOOL_GQUEUEPARAM	0x00000027 /* Get queue parameters */
+#define ETHTOOL_SQUEUEPARAM	0x00000028 /* Set queue parameters. */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/ethtool.8 b/ethtool.8
index 89abf08..3f2e0c0 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -120,6 +120,17 @@ ethtool \- Display or change ethernet card settings
 .RB [ tx
 .IR N ]
 
+
+.B ethtool \-q|\-\-show\-queue
+.I ethX
+
+.B ethtool \-Q|\-\-set\-queue
+.I ethX
+.RB [ rx
+.IR N ]
+.RB [ tx
+.IR N ]
+
 .B ethtool \-i|\-\-driver
 .I ethX
 
@@ -243,6 +254,18 @@ Changes the number of ring entries for the Rx Jumbo ring.
 .BI tx \ N
 Changes the number of ring entries for the Tx ring.
 .TP
+.B \-q \-\-show\-queue
+Queries the specified ethernet device for rx/tx queue parameter information.
+.TP
+.B \-Q \-\-set\-queue
+Changes the rx/tx queue parameters of the specified ethernet device.
+.TP
+.BI rx \ N
+Changes the number of Rx queues.
+.TP
+.BI tx \ N
+Changes the number of Tx queues.
+.TP
 .B \-i \-\-driver
 Queries the specified ethernet device for associated driver information.
 .TP
diff --git a/ethtool.c b/ethtool.c
index 4c9844a..227349f 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -64,6 +64,8 @@ static int do_gpause(int fd, struct ifreq *ifr);
 static int do_spause(int fd, struct ifreq *ifr);
 static int do_gring(int fd, struct ifreq *ifr);
 static int do_sring(int fd, struct ifreq *ifr);
+static int do_gqueue(int fd, struct ifreq *ifr);
+static int do_squeue(int fd, struct ifreq *ifr);
 static int do_gcoalesce(int fd, struct ifreq *ifr);
 static int do_scoalesce(int fd, struct ifreq *ifr);
 static int do_goffload(int fd, struct ifreq *ifr);
@@ -87,6 +89,8 @@ static enum {
 	MODE_SCOALESCE,
 	MODE_GRING,
 	MODE_SRING,
+	MODE_GQUEUE,
+	MODE_SQUEUE,
 	MODE_GOFFLOAD,
 	MODE_SOFFLOAD,
 	MODE_GSTATS,
@@ -144,6 +148,10 @@ static struct option {
 		"		[ rx-mini N ]\n"
 		"		[ rx-jumbo N ]\n"
 	        "		[ tx N ]\n" },
+    { "-q", "--show-queue", MODE_GQUEUE, "Query RX/TX queue parameters" },
+    { "-Q", "--set-queue", MODE_SQUEUE, "Set RX/TX queue parameters",
+		"		[ rx N ]\n"
+	        "		[ tx N ]\n" },
     { "-k", "--show-offload", MODE_GOFFLOAD, "Get protocol offload information" },
     { "-K", "--offload", MODE_SOFFLOAD, "Set protocol offload",
 		"		[ rx on|off ]\n"
@@ -216,6 +224,11 @@ static int ring_rx_mini_wanted = -1;
 static int ring_rx_jumbo_wanted = -1;
 static int ring_tx_wanted = -1;
 
+static struct ethtool_queueparam equeue;
+static int gqueue_changed = 0;
+static int queue_rx = -1;
+static int queue_tx = -1;
+
 static struct ethtool_coalesce ecoal;
 static int gcoalesce_changed = 0;
 static int coal_stats_wanted = -1;
@@ -328,6 +341,11 @@ static struct cmdline_info cmdline_ring[] = {
 	{ "tx", CMDL_INT, &ring_tx_wanted, &ering.tx_pending },
 };
 
+static struct cmdline_info cmdline_queue[] = {
+	{ "rx", CMDL_INT, &queue_rx, &equeue.rx},
+	{ "tx", CMDL_INT, &queue_tx, &equeue.tx},
+};
+
 static struct cmdline_info cmdline_coalesce[] = {
 	{ "adaptive-rx", CMDL_BOOL, &coal_adaptive_rx_wanted, &ecoal.use_adaptive_rx_coalesce },
 	{ "adaptive-tx", CMDL_BOOL, &coal_adaptive_tx_wanted, &ecoal.use_adaptive_tx_coalesce },
@@ -430,6 +448,8 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_SCOALESCE) ||
 			    (mode == MODE_GRING) ||
 			    (mode == MODE_SRING) ||
+			    (mode == MODE_GQUEUE) ||
+			    (mode == MODE_SQUEUE) ||
 			    (mode == MODE_GOFFLOAD) ||
 			    (mode == MODE_SOFFLOAD) ||
 			    (mode == MODE_GSTATS) ||
@@ -496,6 +516,14 @@ static void parse_cmdline(int argc, char **argp)
 				i = argc;
 				break;
 			}
+			if (mode == MODE_SQUEUE) {
+				parse_generic_cmdline(argc, argp, i,
+					&gqueue_changed,
+					cmdline_ring,
+					ARRAY_SIZE(cmdline_queue));
+				i = argc;
+				break;
+			}
 			if (mode == MODE_SCOALESCE) {
 				parse_generic_cmdline(argc, argp, i,
 					&gcoalesce_changed,
@@ -1150,6 +1178,26 @@ static int dump_ring(void)
 	return 0;
 }
 
+static int dump_queue(void)
+{
+	fprintf(stdout,
+		"Pre-set maximums:\n"
+		"RX:		%u\n"
+		"TX:		%u\n",
+		equeue.rx_max,
+		equeue.tx_max);
+
+	fprintf(stdout,
+		"Current hardware settings:\n"
+		"RX:		%u\n"
+		"TX:		%u\n",
+		equeue.rx,
+		equeue.tx);
+
+	fprintf(stdout, "\n");
+	return 0;
+}
+
 static int dump_coalesce(void)
 {
 	fprintf(stdout, "Adaptive RX: %s  TX: %s\n",
@@ -1278,6 +1326,10 @@ static int doit(void)
 		return do_gring(fd, &ifr);
 	} else if (mode == MODE_SRING) {
 		return do_sring(fd, &ifr);
+	} else if (mode == MODE_GQUEUE) {
+		return do_gqueue(fd, &ifr);
+	} else if (mode == MODE_SQUEUE) {
+		return do_squeue(fd, &ifr);
 	} else if (mode == MODE_GOFFLOAD) {
 		return do_goffload(fd, &ifr);
 	} else if (mode == MODE_SOFFLOAD) {
@@ -1435,6 +1487,57 @@ static int do_gring(int fd, struct ifreq *ifr)
 	return 0;
 }
 
+static int do_squeue(int fd, struct ifreq *ifr)
+{
+	int err, changed = 0;
+
+	equeue.cmd = ETHTOOL_GQUEUEPARAM;
+	ifr->ifr_data = (caddr_t)&equeue;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err) {
+		perror("Cannot get device queue settings");
+		return 76;
+	}
+
+	do_generic_set(cmdline_queue, ARRAY_SIZE(cmdline_queue), &changed);
+
+	if (!changed) {
+		fprintf(stderr, "no queue parameters changed, aborting\n");
+		return 80;
+	}
+
+	equeue.cmd = ETHTOOL_SQUEUEPARAM;
+	ifr->ifr_data = (caddr_t)&equeue;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err) {
+		perror("Cannot set device queue parameters");
+		return 81;
+	}
+
+	return 0;
+}
+
+static int do_gqueue(int fd, struct ifreq *ifr)
+{
+	int err;
+
+	fprintf(stdout, "Queue parameters for %s:\n", devname);
+
+	equeue.cmd = ETHTOOL_GQUEUEPARAM;
+	ifr->ifr_data = (caddr_t)&equeue;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err == 0) {
+		err = dump_queue();
+		if (err)
+			return err;
+	} else {
+		perror("Cannot get device queue settings");
+		return 76;
+	}
+
+	return 0;
+}
+
 static int do_gcoalesce(int fd, struct ifreq *ifr)
 {
 	int err;
