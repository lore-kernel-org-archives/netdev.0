From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 2/2] ethtool: Add support for control of RX flow
 hash indirection
Date: Wed, 30 Jun 2010 16:13:12 +0100
Message-ID: <1277910792.2082.18.camel@achroite.uk.solarflarecom.com>
References: <1277910740.2082.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8619 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753470Ab0F3PNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 11:13:15 -0400
In-Reply-To: <1277910740.2082.17.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many NICs use an indirection table to map an RX flow hash value to one
of an arbitrary number of queues (not necessarily a power of 2).  It
can be useful to remove some queues from this indirection table so
that they are only used for flows that are specifically filtered
there.  It may also be useful to weight the mapping to account for
user processes with the same CPU-affinity as the RX interrupts.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.8 |   26 ++++++++++
 ethtool.c |  162 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 188 insertions(+), 0 deletions(-)

diff --git a/ethtool.8 b/ethtool.8
index 5983d0e..6003743 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -214,6 +214,17 @@ ethtool \- Display or change ethernet card settings
 .RB [ rx-flow-hash \ \*(FL
 .RB \ \*(HO]
 
+.B ethtool \-x|\-\-show\-rxfh\-indir
+.I ethX
+
+.B ethtool \-X|\-\-set\-rxfh\-indir
+.I ethX
+.RB [\  equal
+.IR N \ |
+.BI weight\  W0
+.IR W1
+.RB ...\ ]
+
 .B ethtool \-f|\-\-flash
 .I ethX
 .RI FILE
@@ -606,6 +617,21 @@ Discard all packets of this flow type. When this option is set, all other option
 .PD
 .RE
 .TP
+.B \-x \-\-show\-rxfh\-indir
+Retrieves the receive flow hash indirection table.
+.TP
+.B \-X \-\-set\-rxfh\-indir
+Configures the receive flow hash indirection table.
+.TP
+.BI equal\  N
+Sets the receive flow hash indirection table to spread flows evenly
+between the first \fIN\fR receive queues.
+.TP
+\fBweight\fR \fIW0 W1\fR ...
+Sets the receive flow hash indirection table to spread flows between
+receive queues according to the given weights.  The sum of the weights
+must be non-zero and must not exceed the size of the indirection table.
+.TP
 .B \-f \-\-flash \ FILE
 Flash firmware image from the specified file to a region on the adapter.
 By default this will flash all the regions on the adapter.
diff --git a/ethtool.c b/ethtool.c
index 4073745..c7c269d 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -98,6 +98,8 @@ static char *unparse_rxfhashopts(u64 opts);
 static int dump_rxfhash(int fhash, u64 val);
 static int do_srxclass(int fd, struct ifreq *ifr);
 static int do_grxclass(int fd, struct ifreq *ifr);
+static int do_grxfhindir(int fd, struct ifreq *ifr);
+static int do_srxfhindir(int fd, struct ifreq *ifr);
 static int do_srxntuple(int fd, struct ifreq *ifr);
 static int do_grxntuple(int fd, struct ifreq *ifr);
 static int do_flash(int fd, struct ifreq *ifr);
@@ -125,6 +127,8 @@ static enum {
 	MODE_GSTATS,
 	MODE_GNFC,
 	MODE_SNFC,
+	MODE_GRXFHINDIR,
+	MODE_SRXFHINDIR,
 	MODE_SNTUPLE,
 	MODE_GNTUPLE,
 	MODE_FLASHDEV,
@@ -225,6 +229,10 @@ static struct option {
 		"classification options",
 		"		[ rx-flow-hash tcp4|udp4|ah4|sctp4|"
 		"tcp6|udp6|ah6|sctp6 m|v|t|s|d|f|n|r... ]\n" },
+    { "-x", "--show-rxfh-indir", MODE_GRXFHINDIR, "Show Rx flow hash "
+		"indirection" },
+    { "-X", "--set-rxfh-indir", MODE_SRXFHINDIR, "Set Rx flow hash indirection",
+		"		equal N | weight W0 W1 ...\n" },
     { "-U", "--config-ntuple", MODE_SNTUPLE, "Configure Rx ntuple filters "
 		"and actions",
 		"               [ flow-type tcp4|udp4|sctp4 src-ip <addr> "
@@ -350,6 +358,8 @@ static int rx_fhash_get = 0;
 static int rx_fhash_set = 0;
 static u32 rx_fhash_val = 0;
 static int rx_fhash_changed = 0;
+static int rxfhindir_equal = 0;
+static char **rxfhindir_weight = NULL;
 static int sntuple_changed = 0;
 static struct ethtool_rx_ntuple_flow_spec ntuple_fs;
 static char *flash_file = NULL;
@@ -549,6 +559,11 @@ static int get_int(char *str, int base)
 	return get_int_range(str, base, INT_MIN, INT_MAX);
 }
 
+static u32 get_u32(char *str, int base)
+{
+	return get_uint_range(str, base, 0xffffffff);
+}
+
 static void parse_generic_cmdline(int argc, char **argp,
 				  int first_arg, int *changed,
 				  struct cmdline_info *info,
@@ -725,6 +740,8 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_GSTATS) ||
 			    (mode == MODE_GNFC) ||
 			    (mode == MODE_SNFC) ||
+			    (mode == MODE_GRXFHINDIR) ||
+			    (mode == MODE_SRXFHINDIR) ||
 			    (mode == MODE_SNTUPLE) ||
 			    (mode == MODE_GNTUPLE) ||
 			    (mode == MODE_PHYS_ID) ||
@@ -878,6 +895,30 @@ static void parse_cmdline(int argc, char **argp)
 					show_usage(1);
 				break;
 			}
+			if (mode == MODE_SRXFHINDIR) {
+				if (!strcmp(argp[i], "equal")) {
+					if (argc != i + 2) {
+						show_usage(1);
+						break;
+					}
+					i += 1;
+					rxfhindir_equal =
+						get_int_range(argp[i], 0, 1,
+							      INT_MAX);
+					i += 1;
+				} else if (!strcmp(argp[i], "weight")) {
+					i += 1;
+					if (i >= argc) {
+						show_usage(1);
+						break;
+					}
+					rxfhindir_weight = argp + i;
+					i = argc;
+				} else {
+					show_usage(1);
+				}
+				break;
+			}
 			if (mode != MODE_SSET)
 				show_usage(1);
 			if (!strcmp(argp[i], "speed")) {
@@ -1812,6 +1853,10 @@ static int doit(void)
 		return do_grxclass(fd, &ifr);
 	} else if (mode == MODE_SNFC) {
 		return do_srxclass(fd, &ifr);
+	} else if (mode == MODE_GRXFHINDIR) {
+		return do_grxfhindir(fd, &ifr);
+	} else if (mode == MODE_SRXFHINDIR) {
+		return do_srxfhindir(fd, &ifr);
 	} else if (mode == MODE_SNTUPLE) {
 		return do_srxntuple(fd, &ifr);
 	} else if (mode == MODE_GNTUPLE) {
@@ -2751,6 +2796,123 @@ static int do_grxclass(int fd, struct ifreq *ifr)
 	return 0;
 }
 
+static int do_grxfhindir(int fd, struct ifreq *ifr)
+{
+	struct ethtool_rxnfc ring_count;
+	struct ethtool_rxfh_indir indir_head;
+	struct ethtool_rxfh_indir *indir;
+	u32 i;
+	int err;
+
+	ring_count.cmd = ETHTOOL_GRXRINGS;
+	ifr->ifr_data = (caddr_t) &ring_count;
+	err = send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Cannot get RX ring count");
+		return 102;
+	}
+
+	indir_head.cmd = ETHTOOL_GRXFHINDIR;
+	indir_head.size = 0;
+	ifr->ifr_data = (caddr_t) &indir_head;
+	err = send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Cannot get RX flow hash indirection table size");
+		return 103;
+	}
+
+	indir = malloc(sizeof(*indir) +
+		       indir_head.size * sizeof(*indir->ring_index));
+	indir->cmd = ETHTOOL_GRXFHINDIR;
+	indir->size = indir_head.size;
+	ifr->ifr_data = (caddr_t) indir;
+	err = send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Cannot get RX flow hash indirection table");
+		return 103;
+	}
+
+	printf("RX flow hash indirection table for %s with %llu RX ring(s):\n",
+	       devname, ring_count.data);
+	for (i = 0; i < indir->size; i++) {
+		if (i % 8 == 0)
+			printf("%5zu: ", i);
+		printf(" %5u", indir->ring_index[i]);
+		if (i % 8 == 7)
+			fputc('\n', stdout);
+	}
+	return 0;
+}
+
+static int do_srxfhindir(int fd, struct ifreq *ifr)
+{
+	struct ethtool_rxfh_indir indir_head;
+	struct ethtool_rxfh_indir *indir;
+	u32 i;
+	int err;
+
+	if (!rxfhindir_equal && !rxfhindir_weight)
+		show_usage(1);
+
+	indir_head.cmd = ETHTOOL_GRXFHINDIR;
+	indir_head.size = 0;
+	ifr->ifr_data = (caddr_t) &indir_head;
+	err = send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Cannot get RX flow hash indirection table size");
+		return 104;
+	}
+
+	indir = malloc(sizeof(*indir) +
+		       indir_head.size * sizeof(*indir->ring_index));
+	indir->cmd = ETHTOOL_SRXFHINDIR;
+	indir->size = indir_head.size;
+
+	if (rxfhindir_equal) {
+		for (i = 0; i < indir->size; i++)
+			indir->ring_index[i] = i % rxfhindir_equal;
+	} else {
+		u32 j, weight, sum = 0, partial = 0;
+
+		for (j = 0; rxfhindir_weight[j]; j++) {
+			weight = get_u32(rxfhindir_weight[j], 0);
+			sum += weight;
+		}
+
+		if (sum == 0) {
+			fprintf(stderr,
+				"At least one weight must be non-zero\n");
+			exit(1);
+		}
+
+		if (sum > indir->size) {
+			fprintf(stderr,
+				"Total weight exceeds the size of the "
+				"indirection table\n");
+			exit(1);
+		}
+
+		j = -1;
+		for (i = 0; i < indir->size; i++) {
+			if (i >= indir->size * partial / sum) {
+				j += 1;
+				weight = get_u32(rxfhindir_weight[j], 0);
+				partial += weight;
+			}
+			indir->ring_index[i] = j;
+		}
+	}
+
+	ifr->ifr_data = (caddr_t) indir;
+	err = send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Cannot set RX flow hash indirection table");
+		return 105;
+	}
+
+	return 0;
+}
+
 static int do_flash(int fd, struct ifreq *ifr)
 {
 	struct ethtool_flash efl;
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

