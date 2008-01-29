From: Mitch Williams <mitch.a.williams@intel.com>
Subject: [PATCH 3/3]  Add flexible wake filter support to ethtool-6
Date: Tue, 29 Jan 2008 13:02:16 -0800
Message-ID: <1201640536.11148.34.camel@strongmad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:18854 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752156AbYA2VVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 16:21:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for Wake-on-Lan flexible filters to ethtool.To set a filter:

$ ethtool -F ethx <filter num> <filter spec>
  where <filter spec> is a string of hex digits (or xx for ignore)
describing bytes from the beginning of the expected packet.
For example:  $ ethtool -F eth0 0 00a055667788xxxx449976xx32

To show a filter:
$ ethtool -f ethx <filter num>

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 3a63224..dbad8dc 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -55,6 +55,16 @@ struct ethtool_wolinfo {
 	__u8	sopass[SOPASS_MAX]; /* SecureOn(tm) password */
 };
 
+#define WOL_FILTER_MAX_LEN 256
+#define WOL_FILTER_IGNORE_OCTET 0x100
+/* wake-on-lan flexible filters */
+struct ethtool_wol_filter {
+	u32	cmd;
+	u32	index;
+	u32	len;
+	u16	mask_val[0];
+};
+
 /* for passing single values */
 struct ethtool_value {
 	__u32	cmd;
@@ -414,6 +424,9 @@ struct ethtool_ops {
 #define ETHTOOL_SUFO		0x00000022 /* Set UFO enable (ethtool_value) */
 #define ETHTOOL_GGSO		0x00000023 /* Get GSO enable (ethtool_value) */
 #define ETHTOOL_SGSO		0x00000024 /* Set GSO enable (ethtool_value) */
+#define ETHTOOL_GNUMWOLFILT	0x00000029
+#define ETHTOOL_GWOLFILTER	0x0000002a /* Get WOL flex filter */
+#define ETHTOOL_SWOLFILTER	0x0000002b /* Set WOL flex filter */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -500,5 +513,6 @@ struct ethtool_ops {
 #define WAKE_ARP		(1 << 4)
 #define WAKE_MAGIC		(1 << 5)
 #define WAKE_MAGICSECURE	(1 << 6) /* only meaningful if WAKE_MAGIC */
+#define WAKE_FILTER		(1 << 7)
 
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/ethtool.c b/ethtool.c
index a668b49..febd7e6 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -69,6 +69,9 @@ static int do_scoalesce(int fd, struct ifreq *ifr);
 static int do_goffload(int fd, struct ifreq *ifr);
 static int do_soffload(int fd, struct ifreq *ifr);
 static int do_gstats(int fd, struct ifreq *ifr);
+static int do_gwolfilter(int fd, struct ifreq *ifr);
+static int do_swolfilter(int fd, struct ifreq *ifr);
+static void parse_filter(char *cmdline);
 
 static enum {
 	MODE_HELP = -1,
@@ -90,6 +93,8 @@ static enum {
 	MODE_GOFFLOAD,
 	MODE_SOFFLOAD,
 	MODE_GSTATS,
+	MODE_GFILTER,
+	MODE_SFILTER,
 } mode = MODE_GSET;
 
 static struct option {
@@ -170,6 +175,8 @@ static struct option {
     { "-t", "--test", MODE_TEST, "Execute adapter self test",
                 "               [ online | offline ]\n" },
     { "-S", "--statistics", MODE_GSTATS, "Show adapter statistics" },
+    { "-f", "--show-filter", MODE_GFILTER, "Show WOL filter N\n"},
+    { "-F", "--change-filter", MODE_SFILTER, "Set WOL filter N\n"},
     { "-h", "--help", MODE_HELP, "Show this help" },
     {}
 };
@@ -266,6 +273,10 @@ static int seeprom_changed = 0;
 static int seeprom_magic = 0;
 static int seeprom_offset = -1;
 static int seeprom_value = 0;
+static int gfilter_num = 0;
+static int sfilter_num = 0;
+static u16 filter[WOL_FILTER_MAX_LEN];
+static int filter_len = 0;
 static enum {
 	ONLINE=0,
 	OFFLINE,
@@ -430,6 +441,8 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_GOFFLOAD) ||
 			    (mode == MODE_SOFFLOAD) ||
 			    (mode == MODE_GSTATS) ||
+			    (mode == MODE_GFILTER) ||
+			    (mode == MODE_SFILTER) ||
 			    (mode == MODE_PHYS_ID)) {
 				devname = argp[i];
 				break;
@@ -509,6 +522,26 @@ static void parse_cmdline(int argc, char **argp)
 				i = argc;
 				break;
 			}
+			if (mode == MODE_GFILTER) {
+				long v;
+				v = strtol(argp[i], NULL, 0);
+				if (v < 0)
+					show_usage(1);
+				gfilter_num = (int) v;
+				break;
+			}
+			if (mode == MODE_SFILTER) {
+				long v;
+				v = strtol(argp[i], NULL, 0);
+				if (v < 0)
+					show_usage(1);
+				sfilter_num = (int) v;
+				i += 1;
+				if (i >= argc)
+					show_usage(1);
+				parse_filter(argp[i]);
+				break;
+			}
 			if (mode != MODE_SSET)
 				show_usage(1);
 			if (!strcmp(argp[i], "speed")) {
@@ -942,6 +975,9 @@ static int parse_wolopts(char *optstr, u32 *data)
 			case 's':
 				*data |= WAKE_MAGICSECURE;
 				break;
+			case 'f':
+				*data |= WAKE_FILTER;
+				break;
 			case 'd':
 				*data = 0;
 				break;
@@ -973,6 +1009,8 @@ static char *unparse_wolopts(int wolopts)
 			*p++ = 'a';
 		if (wolopts & WAKE_MAGIC)
 			*p++ = 'g';
+		if (wolopts & WAKE_FILTER)
+			*p++ = 'f';
 		if (wolopts & WAKE_MAGICSECURE)
 			*p++ = 's';
 	} else {
@@ -982,6 +1020,75 @@ static char *unparse_wolopts(int wolopts)
 	return buf;
 }
 
+static void parse_filter(char *cmdline)
+{
+	int i = 0;
+	int j = 0;
+	u16 temp = 0;
+	while (i < strlen(cmdline)) {
+		if (i & 1) /* i is odd */
+			temp = temp << 4;
+		else
+			temp = 0;
+			
+		switch (cmdline[i]) {
+		case '0' ... '9':
+			temp |= (cmdline[i] - '0');
+			break;
+		case 'a' ... 'f':
+			temp |= (cmdline[i] - 'a' + 0xa);
+			break;
+		case 'A' ... 'F':
+			temp |= (cmdline[i] - 'A' + 0xa);
+			break;
+		case 'X':
+		case 'x':
+			if (i & 1)
+				show_usage(1);
+			i++;
+			if ((cmdline[i] != 'x') && (cmdline[i] != 'X'))
+				show_usage(1);
+			temp = WOL_FILTER_IGNORE_OCTET;
+			break;
+		default:
+			show_usage(1);
+			break;
+		} /* switch */
+		if (i & 1) {
+			filter[j++] = temp;
+		}
+		i++;
+	}
+	filter_len = j;
+}
+
+static int dump_wol_filter(struct ethtool_wol_filter *wolfilt)
+{
+	int i = 0;
+	u16 *mask_val;
+	
+	mask_val = (u16 *)((void *)wolfilt + sizeof(struct ethtool_wol_filter));
+
+	fprintf(stdout, "Wake-on-LAN filter %d, length %d\n",wolfilt->index, wolfilt->len);
+	if (wolfilt->mask_val[i] & WOL_FILTER_IGNORE_OCTET)
+		fprintf(stdout, "\txx");
+	else
+		fprintf(stdout, "\t%2.2x", wolfilt->mask_val[i]);
+	for (i = 1; i < wolfilt->len; i++) {
+		if (wolfilt->mask_val[i] & 0xFF00)
+			fprintf(stdout, ":xx");
+		else
+			fprintf(stdout, ":%2.2x", wolfilt->mask_val[i]);
+		if ((i % 22) == 0)
+			fprintf(stdout, "\n\t");
+	}
+
+	fprintf(stdout, "\n");
+
+	return 0;
+}
+
+
 static int parse_sopass(char *src, unsigned char *dest)
 {
 	int count;
@@ -1289,6 +1396,10 @@ static int doit(void)
 		return do_soffload(fd, &ifr);
 	} else if (mode == MODE_GSTATS) {
 		return do_gstats(fd, &ifr);
+	} else if (mode == MODE_GFILTER) {
+		return do_gwolfilter(fd, &ifr);
+	} else if (mode == MODE_SFILTER) {
+		return do_swolfilter(fd, &ifr);
 	}
 
 	return 69;
@@ -1653,6 +1764,7 @@ static int do_gset(int fd, struct ifreq *ifr)
 	int err;
 	struct ethtool_cmd ecmd;
 	struct ethtool_wolinfo wolinfo;
+	struct ethtool_wol_filter wolfilt;
 	struct ethtool_value edata;
 	int allfail = 1;
 
@@ -1682,6 +1794,18 @@ static int do_gset(int fd, struct ifreq *ifr)
 		perror("Cannot get wake-on-lan settings");
 	}
 
+	if (wolinfo.supported | WAKE_FILTER) {
+		wolfilt.cmd = ETHTOOL_GNUMWOLFILT;
+		ifr->ifr_data = (caddr_t)&wolfilt;
+		err = ioctl(fd, SIOCETHTOOL, ifr);
+		if (err == 0) {
+			fprintf(stdout, "	Wake filters supported: %d\n", wolfilt.index);
+			allfail = 0;
+		} else {
+			perror("Cannot get wake filter settings");
+		}
+	}
+
 	edata.cmd = ETHTOOL_GMSGLVL;
 	ifr->ifr_data = (caddr_t)&edata;
 	err = ioctl(fd, SIOCETHTOOL, ifr);
@@ -1940,6 +2064,46 @@ static int do_seeprom(int fd, struct ifreq *ifr)
 	return err;
 }
 
+static int do_gwolfilter(int fd, struct ifreq *ifr)
+{
+	int err;
+	struct ethtool_wol_filter *gfilter;
+
+	gfilter = calloc(1, sizeof(struct ethtool_wol_filter)+ WOL_FILTER_MAX_LEN * 2);
+	if (!gfilter) {
+		perror("Cannot allocate memory for filter data");
+		return 75;
+	}
+	gfilter->cmd = ETHTOOL_GWOLFILTER;
+	gfilter->index = gfilter_num;
+	ifr->ifr_data = (caddr_t)gfilter;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	dump_wol_filter(gfilter);
+	free(gfilter);
+	return err;
+}
+
+static int do_swolfilter(int fd, struct ifreq *ifr)
+{
+	int err;
+	struct ethtool_wol_filter *sfilter;
+
+	sfilter = calloc(1, sizeof(*sfilter)+ WOL_FILTER_MAX_LEN * 2);
+	if (!filter) {
+		perror("Cannot allocate memory for filter data");
+		return 75;
+	}
+	sfilter->cmd = ETHTOOL_SWOLFILTER;
+	sfilter->index = sfilter_num;
+	sfilter->len = filter_len;
+	memcpy((void *)sfilter + sizeof(struct ethtool_wol_filter), filter, filter_len * 2);
+	ifr->ifr_data = (caddr_t)sfilter;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	free(sfilter);
+	return err;
+}
+
+
 static int do_test(int fd, struct ifreq *ifr)
 {
 	int err;


