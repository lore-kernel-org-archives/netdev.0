From: Santwona Behera <Santwona.Behera@Sun.COM>
Subject: [PATCH 1/3] Add support for rx flow hash configuration in a network
 device - [ethtool]
Date: Fri, 27 Jun 2008 17:06:20 -0700
Message-ID: <4865807C.9080003@Sun.COM>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_YwbK8Ps2XXYbSscO+bp4JA)"
Cc: Matheos Worku <Matheos.Worku@Sun.COM>,
	Michael Speer <Michael.Speer@Sun.COM>,
	gkernel-commit@lists.sourceforge.net,
	Santwona Behera <Santwona.Behera@Sun.COM>
To: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:54135 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753960AbYF1AGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 20:06:23 -0400
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m5S06Mbu022016
	for <netdev@vger.kernel.org>; Fri, 27 Jun 2008 17:06:22 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0K3500E01CAB0V00@fe-sfbay-10.sun.com>
 (original mail from Santwona.Behera@Sun.COM) for netdev@vger.kernel.org; Fri,
 27 Jun 2008 17:06:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--Boundary_(ID_YwbK8Ps2XXYbSscO+bp4JA)
Content-type: text/plain; format=flowed; charset=ISO-8859-1
Content-transfer-encoding: 7BIT



--Boundary_(ID_YwbK8Ps2XXYbSscO+bp4JA)
Content-type: text/x-patch; name=ethtool_rx_flow_hash_cfg.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=ethtool_rx_flow_hash_cfg.patch

From: Santwona Behera <santwona.behera@sun.com>

Added new interfaces to ethtool to configure receive network flow distribution across multiple rx rings using hashing.

Patch is against ethtool version 6.

Signed-off-by: Santwona Behera <santwona.behera@sun.com>
---
 ethtool-copy.h |   33 +++++++
 ethtool.8      |   80 ++++++++++++++++++
 ethtool.c      |  254 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 367 insertions(+), 0 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 3a63224..e2a72f1 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -256,6 +256,12 @@ struct ethtool_perm_addr {
 	__u8	data[0];
 };
 
+struct ethtool_rxnfc {
+	__u32		cmd;
+	__u32		flow_type;
+	__u64		data;
+};
+
 #ifdef __KERNEL__
 
 struct net_device;
@@ -373,6 +379,8 @@ struct ethtool_ops {
 	void	(*complete)(struct net_device *);
 	u32     (*get_ufo)(struct net_device *);
 	int     (*set_ufo)(struct net_device *, u32);
+	int	(*get_rxhash)(struct net_device *, struct ethtool_rxnfc *);
+	int	(*set_rxhash)(struct net_device *, struct ethtool_rxnfc *);
 };
 #endif /* __KERNEL__ */
 
@@ -415,6 +423,9 @@ struct ethtool_ops {
 #define ETHTOOL_GGSO		0x00000023 /* Get GSO enable (ethtool_value) */
 #define ETHTOOL_SGSO		0x00000024 /* Set GSO enable (ethtool_value) */
 
+#define	ETHTOOL_GRXFH		0x00000029 /* Get RX flow hash configuration */
+#define	ETHTOOL_SRXFH		0x0000002a /* Set RX flow hash configuration */
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
@@ -501,4 +512,26 @@ struct ethtool_ops {
 #define WAKE_MAGIC		(1 << 5)
 #define WAKE_MAGICSECURE	(1 << 6) /* only meaningful if WAKE_MAGIC */
 
+/* L3-L4 network traffic flow types */
+#define	TCP_V4_FLOW	0x01
+#define	UDP_V4_FLOW	0x02
+#define	SCTP_V4_FLOW	0x03
+#define	AH_ESP_V4_FLOW	0x04
+#define	TCP_V6_FLOW	0x05
+#define	UDP_V6_FLOW	0x06
+#define	SCTP_V6_FLOW	0x07
+#define	AH_ESP_V6_FLOW	0x08
+
+/* L3-L4 network traffic flow hash options */
+#define	RXH_DEV_PORT		(1 << 0)
+#define	RXH_L2DA		(1 << 1)
+#define	RXH_VLAN		(1 << 2)
+#define	RXH_L3_PROTO		(1 << 3)
+#define	RXH_IP_SRC		(1 << 4)
+#define	RXH_IP_DST		(1 << 5)
+#define	RXH_L4_BYTES_0_1	(1 << 6) /* src port in case of TCP/UDP/SCTP */
+#define	RXH_L4_BYTES_2_3	(1 << 7) /* dst port in case of TCP/UDP/SCTP */
+#define	RXH_DISCARD		(1 << 31)
+
+
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/ethtool.8 b/ethtool.8
index cc6a46e..1beb387 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -40,6 +40,14 @@
 .\"	\(*WO - wol flags
 .\"
 .ds WO \fBp\fP|\fBu\fP|\fBm\fP|\fBb\fP|\fBa\fP|\fBg\fP|\fBs\fP|\fBd\fP...
+.\"
+.\"	\(*FL - flow type values
+.\"
+.ds FL \fBtcp4\fP|\fBudp4\fP|\fBah4\fP|\fBsctp4\fP|\fBtcp6\fP|\fBudp6\fP|\fBah6\fP|\fBsctp6\fP
+.\"
+.\"	\(*HO - hash options
+.\"
+.ds HO \fBp\fP|\fm\fP|\fBv\fP|\fBt\fP|\fBs\fP|\fBd\fP|\fBf\fP|\fBn\fP|\fBr\fP...
 .TH ETHTOOL 8 "July 2007" "Ethtool version 6"
 .SH NAME
 ethtool \- Display or change ethernet card settings
@@ -188,6 +196,15 @@ ethtool \- Display or change ethernet card settings
 .RB [ sopass \ \*(MA]
 .RB [ msglvl
 .IR N ]
+
+.B ethtool \-n
+.I ethX
+.RB [ rx-flow-hash \ \*(FL]
+
+.B ethtool \-N
+.I ethX
+.RB [ rx-flow-hash \ \*(FL
+.RB \ \*(HO]
 .SH DESCRIPTION
 .BI ethtool
 is used for querying settings of an ethernet device and changing them.
@@ -413,6 +430,69 @@ bytes in ethernet MAC hex format (\*(MA).
 .TP
 .BI msglvl \ N
 Sets the driver message level. Meanings differ per driver.
+.TP
+.B \-n \-\-show-nfc
+Retrieves the receive network flow classification configurations.
+.TP
+.BR rx-flow-hash \ \*(FL
+Retrieves the hash options for the specified network traffic type.
+.RS
+.PD 0
+.TP 3
+.BR "tcp4" "    TCP over IPv4"
+.TP 3
+.BR "udp4" "    UDP over IPv4"
+.TP 3
+.BR "ah4" "     IPSEC AH/ESP over IPv4"
+.TP 3
+.BR "sctp4" "   SCTP over IPv4"
+.TP 3
+.BR "tcp6" "    TCP over IPv6"
+.TP 3
+.BR "udp6" "    UDP over IPv6"
+.TP 3
+.BR "ah6" "     IPSEC AH/ESP over IPv6"
+.TP 3
+.BR "sctp6" "   SCTP over IPv6"
+.PD
+.RE
+.TP
+.B \-N \-\-config-nfc
+Configures the receive network flow classification.
+.TP
+.BR rx-flow-hash \ \*(FL \ \*(HO
+Configures the hash options for the specified network traffic type.
+.RS
+.PD 0
+.TP 3
+.B p
+Hash on the device port number on which the packet was received.
+.TP 3
+.B m
+Hash on the Layer 2 destination address of the rx packet.
+.TP 3
+.B v
+Hash on the VLAN tag of the rx packet.
+.TP 3
+.B t
+Hash on the Layer 3 protocol field of the rx packet.
+.TP 3
+.B s
+Hash on the IP source address of the rx packet.
+.TP 3
+.B d
+Hash on the IP destination address of the rx packet.
+.TP 3
+.B f
+Hash on bytes 0 and 1 of the Layer 4 header of the rx packet.
+.TP 3
+.B n
+Hash on bytes 2 and 3 of the Layer 4 header of the rx packet.
+.TP 3
+.B r
+Discard all packets of this flow type. When this option is set, all other options are ignored.
+.PD
+.RE
 .SH BUGS
 Not supported (in part or whole) on all ethernet drivers.
 .SH AUTHOR
diff --git a/ethtool.c b/ethtool.c
index a668b49..46a63bd 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -69,6 +69,12 @@ static int do_scoalesce(int fd, struct ifreq *ifr);
 static int do_goffload(int fd, struct ifreq *ifr);
 static int do_soffload(int fd, struct ifreq *ifr);
 static int do_gstats(int fd, struct ifreq *ifr);
+static int rxflow_str_to_type(const char *str);
+static int parse_rxfhashopts(char *optstr, u32 *data);
+static char *unparse_rxfhashopts(u64 opts);
+static int dump_rxfhash(int fhash, u64 val);
+static int do_srxclass(int fd, struct ifreq *ifr);
+static int do_grxclass(int fd, struct ifreq *ifr);
 
 static enum {
 	MODE_HELP = -1,
@@ -90,6 +96,8 @@ static enum {
 	MODE_GOFFLOAD,
 	MODE_SOFFLOAD,
 	MODE_GSTATS,
+	MODE_GNFC,
+	MODE_SNFC,
 } mode = MODE_GSET;
 
 static struct option {
@@ -170,6 +178,14 @@ static struct option {
     { "-t", "--test", MODE_TEST, "Execute adapter self test",
                 "               [ online | offline ]\n" },
     { "-S", "--statistics", MODE_GSTATS, "Show adapter statistics" },
+    { "-n", "--show-nfc", MODE_GNFC, "Show Rx network flow classification"
+		"options",
+		"		[ rx-flow-hash tcp4|udp4|ah4|sctp4|"
+		"tcp6|udp6|ah6|sctp6 ]\n" },
+    { "-N", "--config-nfc", MODE_SNFC, "Configure Rx network flow "
+		"classification options",
+		"		[ rx-flow-hash tcp4|udp4|ah4|sctp4|"
+		"tcp6|udp6|ah6|sctp6 p|m|v|t|s|d|f|n|r... ]\n" },
     { "-h", "--help", MODE_HELP, "Show this help" },
     {}
 };
@@ -266,6 +282,10 @@ static int seeprom_changed = 0;
 static int seeprom_magic = 0;
 static int seeprom_offset = -1;
 static int seeprom_value = 0;
+static int rx_fhash_get = 0;
+static int rx_fhash_set = 0;
+static u32 rx_fhash_val = 0;
+static int rx_fhash_changed = 0;
 static enum {
 	ONLINE=0,
 	OFFLINE,
@@ -394,6 +414,30 @@ static void parse_generic_cmdline(int argc, char **argp,
 	}
 }
 
+static int rxflow_str_to_type(const char *str)
+{
+	int flow_type = 0;
+
+	if (!strcmp(str, "tcp4"))
+		flow_type = TCP_V4_FLOW;
+	else if (!strcmp(str, "udp4"))
+		flow_type = UDP_V4_FLOW;
+	else if (!strcmp(str, "ah4"))
+		flow_type = AH_ESP_V4_FLOW;
+	else if (!strcmp(str, "sctp4"))
+		flow_type = SCTP_V4_FLOW;
+	else if (!strcmp(str, "tcp6"))
+		flow_type = TCP_V6_FLOW;
+	else if (!strcmp(str, "udp6"))
+		flow_type = UDP_V6_FLOW;
+	else if (!strcmp(str, "ah6"))
+		flow_type = AH_ESP_V6_FLOW;
+	else if (!strcmp(str, "sctp6"))
+		flow_type = SCTP_V6_FLOW;
+
+	return flow_type;
+}
+
 static void parse_cmdline(int argc, char **argp)
 {
 	int i, k;
@@ -430,6 +474,8 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_GOFFLOAD) ||
 			    (mode == MODE_SOFFLOAD) ||
 			    (mode == MODE_GSTATS) ||
+			    (mode == MODE_GNFC) ||
+			    (mode == MODE_SNFC) ||
 			    (mode == MODE_PHYS_ID)) {
 				devname = argp[i];
 				break;
@@ -509,6 +555,48 @@ static void parse_cmdline(int argc, char **argp)
 				i = argc;
 				break;
 			}
+			if (mode == MODE_GNFC) {
+				if (!strcmp(argp[i], "rx-flow-hash")) {
+					i += 1;
+					if (i >= argc) {
+						show_usage(1);
+						break;
+					}
+					rx_fhash_get =
+						rxflow_str_to_type(argp[i]);
+					if (!rx_fhash_get)
+						show_usage(1);
+				} else
+					show_usage(1);
+				break;
+			}
+			if (mode == MODE_SNFC) {
+				if (!strcmp(argp[i], "rx-flow-hash")) {
+					i += 1;
+					if (i >= argc) {
+						show_usage(1);
+						break;
+					}
+					rx_fhash_set =
+						rxflow_str_to_type(argp[i]);
+					if (!rx_fhash_set) {
+						show_usage(1);
+						break;
+					}
+					i += 1;
+					if (i >= argc) {
+						show_usage(1);
+						break;
+					}
+					if (parse_rxfhashopts(argp[i],
+						&rx_fhash_val) < 0)
+						show_usage(1);
+					else
+						rx_fhash_changed = 1;
+				} else
+					show_usage(1);
+				break;
+			}
 			if (mode != MODE_SSET)
 				show_usage(1);
 			if (!strcmp(argp[i], "speed")) {
@@ -1000,6 +1088,84 @@ static int parse_sopass(char *src, unsigned char *dest)
 	return 0;
 }
 
+static int parse_rxfhashopts(char *optstr, u32 *data)
+{
+	*data = 0;
+	while (*optstr) {
+		switch (*optstr) {
+			case 'p':
+				*data |= RXH_DEV_PORT;
+				break;
+			case 'm':
+				*data |= RXH_L2DA;
+				break;
+			case 'v':
+				*data |= RXH_VLAN;
+				break;
+			case 't':
+				*data |= RXH_L3_PROTO;
+				break;
+			case 's':
+				*data |= RXH_IP_SRC;
+				break;
+			case 'd':
+				*data |= RXH_IP_DST;
+				break;
+			case 'f':
+				*data |= RXH_L4_BYTES_0_1;
+				break;
+			case 'n':
+				*data |= RXH_L4_BYTES_2_3;
+				break;
+			case 'r':
+				*data |= RXH_DISCARD;
+				break;
+			default:
+				return -1;
+		}
+		optstr++;
+	}
+	return 0;
+}
+
+static char *unparse_rxfhashopts(u64 opts)
+{
+	static char buf[300];
+
+	memset(buf, 0, sizeof(buf));
+
+	if (opts) {
+		if (opts & RXH_DEV_PORT) {
+			strcat(buf, "Dev port\n");
+		}
+		if (opts & RXH_L2DA) {
+			strcat(buf, "L2DA\n");
+		}
+		if (opts & RXH_VLAN) {
+			strcat(buf, "VLAN tag\n");
+		}
+		if (opts & RXH_L3_PROTO) {
+			strcat(buf, "L3 proto\n");
+		}
+		if (opts & RXH_IP_SRC) {
+			strcat(buf, "IP SA\n");
+		}
+		if (opts & RXH_IP_DST) {
+			strcat(buf, "IP DA\n");
+		}
+		if (opts & RXH_L4_BYTES_0_1) {
+			strcat(buf, "L4 bytes 0 & 1 [TCP/UDP src port]\n");
+		}
+		if (opts & RXH_L4_BYTES_2_3) {
+			strcat(buf, "L4 bytes 2 & 3 [TCP/UDP dst port]\n");
+		}
+	} else {
+		sprintf(buf, "None");
+	}
+
+	return buf;
+}
+
 static struct {
 	const char *name;
 	int (*func)(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
@@ -1236,6 +1402,48 @@ static int dump_offload (int rx, int tx, int sg, int tso, int ufo, int gso)
 	return 0;
 }
 
+static int dump_rxfhash(int fhash, u64 val)
+{
+	switch (fhash) {
+	case TCP_V4_FLOW:
+		fprintf(stdout, "TCP over IPV4 flows");
+		break;
+	case UDP_V4_FLOW:
+		fprintf(stdout, "UDP over IPV4 flows");
+		break;
+	case SCTP_V4_FLOW:
+		fprintf(stdout, "SCTP over IPV4 flows");
+		break;
+	case AH_ESP_V4_FLOW:
+		fprintf(stdout, "IPSEC AH over IPV4 flows");
+		break;
+	case TCP_V6_FLOW:
+		fprintf(stdout, "TCP over IPV6 flows");
+		break;
+	case UDP_V6_FLOW:
+		fprintf(stdout, "UDP over IPV6 flows");
+		break;
+	case SCTP_V6_FLOW:
+		fprintf(stdout, "SCTP over IPV6 flows");
+		break;
+	case AH_ESP_V6_FLOW:
+		fprintf(stdout, "IPSEC AH over IPV6 flows");
+		break;
+	default:
+		break;
+	}
+
+	if (val & RXH_DISCARD) {
+		fprintf(stdout, " - All matching flows discarded on RX\n");
+		return 0;
+	}
+	fprintf(stdout, " use these fields for computing Hash flow key:\n");
+
+	fprintf(stdout, "%s\n", unparse_rxfhashopts(val));
+		
+	return 0;
+}
+
 static int doit(void)
 {
 	struct ifreq ifr;
@@ -1289,6 +1497,10 @@ static int doit(void)
 		return do_soffload(fd, &ifr);
 	} else if (mode == MODE_GSTATS) {
 		return do_gstats(fd, &ifr);
+	} else if (mode == MODE_GNFC) {
+		return do_grxclass(fd, &ifr);
+	} else if (mode == MODE_SNFC) {
+		return do_srxclass(fd, &ifr);
 	}
 
 	return 69;
@@ -2085,6 +2297,48 @@ static int do_gstats(int fd, struct ifreq *ifr)
 	return 0;
 }
 
+
+static int do_srxclass(int fd, struct ifreq *ifr)
+{
+	int err;
+
+	if (rx_fhash_changed) {
+		struct ethtool_rxnfc nfccmd;
+
+		nfccmd.cmd = ETHTOOL_SRXFH;
+		nfccmd.flow_type = rx_fhash_set;
+		nfccmd.data = rx_fhash_val;
+
+		ifr->ifr_data = (caddr_t)&nfccmd;
+		err = ioctl(fd, SIOCETHTOOL, ifr);
+		if (err < 0)
+			perror("Cannot change RX network flow hashing options");
+
+	}
+
+	return 0;
+}
+
+static int do_grxclass(int fd, struct ifreq *ifr)
+{
+	int err;
+
+	if (rx_fhash_get) {
+		struct ethtool_rxnfc nfccmd;
+
+		nfccmd.cmd = ETHTOOL_GRXFH;
+		nfccmd.flow_type = rx_fhash_get;
+		ifr->ifr_data = (caddr_t)&nfccmd;
+		err = ioctl(fd, SIOCETHTOOL, ifr);
+		if (err < 0)
+			perror("Cannot get RX network flow hashing options");
+		else
+			dump_rxfhash(rx_fhash_get, nfccmd.data);
+	}
+
+	return 0;
+}
+
 int main(int argc, char **argp, char **envp)
 {
 	parse_cmdline(argc, argp);
-- 
1.5.2


--Boundary_(ID_YwbK8Ps2XXYbSscO+bp4JA)--
