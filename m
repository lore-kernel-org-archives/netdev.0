From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: [PATCH v4 5/5] iproute2: add can-j1939 support
Date: Wed, 27 Apr 2011 11:03:02 +0200
Message-ID: <20110427090302.GF757@kurt.e-circ.dyndns.org>
References: <20110427085330.GA757@kurt.e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110427085330.GA757-ozGf4kBk5synFtIcQ8t7k3L8HoS0Hn3T@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Add j1939 support to iproute2

Signed-off-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
---
diff --git a/Makefile b/Makefile
index d1ace1f..06bf281 100644
--- a/Makefile
+++ b/Makefile
@@ -27,9 +27,12 @@ ADDLIB+=dnet_ntop.o dnet_pton.o
 #options for ipx
 ADDLIB+=ipx_ntop.o ipx_pton.o
 
+#options for j1939
+ADDLIB+=j1939.o
+
 CC = gcc
 HOSTCC = gcc
-CCOPTS = -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall
+CCOPTS = -D_GNU_SOURCE -Wstrict-prototypes -Wall
 CFLAGS = $(CCOPTS) -I../include $(DEFINES)
 YACCFLAGS = -d -t -v
 
diff --git a/include/linux/can.h b/include/linux/can.h
new file mode 100644
index 0000000..9c2523c
--- /dev/null
+++ b/include/linux/can.h
@@ -0,0 +1,129 @@
+/*
+ * linux/can.h
+ *
+ * Definitions for CAN network layer (socket addr / CAN frame / CAN filter)
+ *
+ * Authors: Oliver Hartkopp <oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org>
+ *          Urs Thuermann   <urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org>
+ * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
+ * All rights reserved.
+ *
+ * Send feedback to <socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
+ *
+ */
+
+#ifndef CAN_H
+#define CAN_H
+
+#include <linux/types.h>
+#include <linux/socket.h>
+
+/* controller area network (CAN) kernel definitions */
+
+/* special address description flags for the CAN_ID */
+#define CAN_EFF_FLAG 0x80000000U /* EFF/SFF is set in the MSB */
+#define CAN_RTR_FLAG 0x40000000U /* remote transmission request */
+#define CAN_ERR_FLAG 0x20000000U /* error frame */
+
+/* valid bits in CAN ID for frame formats */
+#define CAN_SFF_MASK 0x000007FFU /* standard frame format (SFF) */
+#define CAN_EFF_MASK 0x1FFFFFFFU /* extended frame format (EFF) */
+#define CAN_ERR_MASK 0x1FFFFFFFU /* omit EFF, RTR, ERR flags */
+
+/*
+ * Controller Area Network Identifier structure
+ *
+ * bit 0-28	: CAN identifier (11/29 bit)
+ * bit 29	: error frame flag (0 = data frame, 1 = error frame)
+ * bit 30	: remote transmission request flag (1 = rtr frame)
+ * bit 31	: frame format flag (0 = standard 11 bit, 1 = extended 29 bit)
+ */
+typedef __u32 canid_t;
+
+/*
+ * Controller Area Network Error Frame Mask structure
+ *
+ * bit 0-28	: error class mask (see include/linux/can/error.h)
+ * bit 29-31	: set to zero
+ */
+typedef __u32 can_err_mask_t;
+
+/**
+ * struct can_frame - basic CAN frame structure
+ * @can_id:  the CAN ID of the frame and CAN_*_FLAG flags, see above.
+ * @can_dlc: the data length field of the CAN frame
+ * @data:    the CAN frame payload.
+ */
+struct can_frame {
+	canid_t can_id;  /* 32 bit CAN_ID + EFF/RTR/ERR flags */
+	__u8    can_dlc; /* data length code: 0 .. 8 */
+	__u8    data[8] __attribute__((aligned(8)));
+};
+
+/* particular protocols of the protocol family PF_CAN */
+#define CAN_RAW		1 /* RAW sockets */
+#define CAN_BCM		2 /* Broadcast Manager */
+#define CAN_TP16	3 /* VAG Transport Protocol v1.6 */
+#define CAN_TP20	4 /* VAG Transport Protocol v2.0 */
+#define CAN_MCNET	5 /* Bosch MCNet */
+#define CAN_ISOTP	6 /* ISO 15765-2 Transport Protocol */
+#define CAN_J1939	7 /* SAE J1939 */
+#define CAN_NPROTO	8
+
+#define SOL_CAN_BASE 100
+
+/**
+ * struct sockaddr_can - the sockaddr structure for CAN sockets
+ * @can_family:  address family number AF_CAN.
+ * @can_ifindex: CAN network interface index.
+ * @can_addr:    protocol specific address information
+ */
+struct sockaddr_can {
+	sa_family_t can_family;
+	int         can_ifindex;
+	union {
+		/* transport protocol class address information (e.g. ISOTP) */
+		struct { canid_t rx_id, tx_id; } tp;
+
+		/* J1939 address information */
+		struct {
+			/* 8 byte name when using dynamic addressing */
+			__u64 name;
+			/*
+			 * pgn:
+			 * 8bit: PS in PDU2 case, else 0
+			 * 8bit: PF
+			 * 1bit: DP
+			 * 1bit: reserved
+			 */
+			__u32 pgn;
+
+			/* 1byte address */
+			__u8 addr;
+		} j1939;
+
+		/* reserved for future CAN protocols address information */
+	} can_addr;
+};
+
+/**
+ * struct can_filter - CAN ID based filter in can_register().
+ * @can_id:   relevant bits of CAN ID which are not masked out.
+ * @can_mask: CAN mask (see description)
+ *
+ * Description:
+ * A filter matches, when
+ *
+ *          <received_can_id> & mask == can_id & mask
+ *
+ * The filter can be inverted (CAN_INV_FILTER bit set in can_id) or it can
+ * filter for error frames (CAN_ERR_FLAG bit set in mask).
+ */
+struct can_filter {
+	canid_t can_id;
+	canid_t can_mask;
+};
+
+#define CAN_INV_FILTER 0x20000000U /* to be set in can_filter.can_id */
+
+#endif /* CAN_H */
diff --git a/include/linux/can/j1939.h b/include/linux/can/j1939.h
new file mode 100644
index 0000000..fa62562
--- /dev/null
+++ b/include/linux/can/j1939.h
@@ -0,0 +1,93 @@
+/*
+ * j1939.h
+ *
+ */
+
+#ifndef _J1939_H_
+#define _J1939_H_
+
+#include <linux/types.h>
+#include <linux/socket.h>
+#include <linux/can.h>
+
+#define J1939_NO_ADDR	0xff
+#define J1939_NO_NAME	0
+#define J1939_NO_PGN	0x7ffff
+/*
+ * J1939 Parameter Group Number
+ *
+ * bit 0-7	: PDU Specific (PS)
+ * bit 8-15	: PDU Format (PF)
+ * bit 16	: Data Page (DP)
+ * bit 17	: Reserved (R)
+ * bit 19-31	: set to zero
+ */
+typedef __u32 pgn_t;
+
+/*
+ * J1939 Priority
+ *
+ * bit 0-2	: Priority (P)
+ * bit 3-7	: set to zero
+ */
+typedef __u8 priority_t;
+
+/*
+ * J1939 NAME
+ *
+ * bit 0-20	: Identity Number
+ * bit 21-31	: Manufacturer Code
+ * bit 32-34	: ECU Instance
+ * bit 35-39	: Function Instance
+ * bit 40-47	: Function
+ * bit 48	: Reserved
+ * bit 49-55	: Vehicle System
+ * bit 56-59	: Vehicle System Instance
+ * bit 60-62	: Industry Group
+ * bit 63	: Arbitrary Address Capable
+ */
+typedef __u64 name_t;
+
+/*
+ * J1939 socket options
+ */
+#define SOL_CAN_J1939 (SOL_CAN_BASE + CAN_J1939)
+enum {
+	SO_J1939_FILTER = 1,	/* set filters */
+	SO_J1939_PROMISC = 2,	/* set/clr promiscuous mode */
+	SO_J1939_RECV_OWN = 3,
+	SO_J1939_RECV_DEST = 4, /* set/clr attach dest control message */
+	SO_J1939_RECV_PRIO = 5,
+	SO_J1939_SEND_PRIO = 6,
+	SO_J1939_DEST_MASK = 7, /* mask names in connect() & sendto() */
+};
+
+#define SCM_J1939_DEST SO_J1939_RECV_DEST
+#define SCM_J1939_PRIO SO_J1939_RECV_PRIO
+
+struct j1939_filter {
+	name_t name;
+	name_t name_mask;
+	__u8 addr;
+	__u8 addr_mask;
+	pgn_t pgn;
+	pgn_t pgn_mask;
+};
+
+/*
+ * RTNETLINK
+ */
+enum {
+	IFLA_J1939_UNSPEC,
+	IFLA_J1939_ENABLE,
+	IFLA_J1939_MAX,
+};
+
+enum {
+	IFA_J1939_UNSPEC,
+	IFA_J1939_ADDR,
+	IFA_J1939_NAME,
+	IFA_J1939_MAX,
+};
+
+#endif /* _J1939_H_ */
diff --git a/include/utils.h b/include/utils.h
index 47f8e07..cbd249a 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -95,8 +95,15 @@ extern __u8* hexstring_a2n(const char *str, __u8 *buf, int blen);
 
 extern const char *format_host(int af, int len, const void *addr,
 			       char *buf, int buflen);
-extern const char *rt_addr_n2a(int af, int len, const void *addr,
+/* 'address with protocol' n2a */
+extern const char *rt_addrpr_n2a(int af, int protocol, int len, const void *addr,
 			       char *buf, int buflen);
+static inline const char *rt_addr_n2a(int af, int len, const void *addr,
+			       char *buf, int buflen)
+{
+	return rt_addrpr_n2a(af, 0, len, addr, buf, buflen);
+
+}
 
 void missarg(const char *) __attribute__((noreturn));
 void invarg(const char *, const char *) __attribute__((noreturn));
@@ -111,6 +118,16 @@ int dnet_pton(int af, const char *src, void *addr);
 const char *ipx_ntop(int af, const void *addr, char *str, size_t len);
 int ipx_pton(int af, const char *src, void *addr);
 
+/* j1939 */
+extern const char *j1939_ntop(int af, const void *addr, size_t vlen,
+		char *str, size_t len);
+extern const char *j1939_link_attrtop(struct rtattr *nla);
+
+extern int j1939_addr_args(int argc, char *argv[],
+		struct nlmsghdr *msg, int msg_size);
+extern int j1939_link_args(int argc, char *argv[],
+		struct nlmsghdr *msg, int msg_size);
+
 extern int __iproute2_hz_internal;
 extern int __get_hz(void);
 
diff --git a/ip/ip.c b/ip/ip.c
index b127d57..50fcb1c 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -46,7 +46,7 @@ static void usage(void)
 "where  OBJECT := { link | addr | addrlabel | route | rule | neigh | ntable |\n"
 "                   tunnel | tuntap | maddr | mroute | mrule | monitor | xfrm }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
-"                    -f[amily] { inet | inet6 | ipx | dnet | link } |\n"
+"                    -f[amily] { inet | inet6 | ipx | dnet | link  | can} |\n"
 "                    -l[oops] { maximum-addr-flush-attempts } |\n"
 "                    -o[neline] | -t[imestamp] | -b[atch] [filename] |\n"
 "                    -rc[vbuf] [size]}\n");
@@ -181,6 +181,8 @@ int main(int argc, char **argv)
 				preferred_family = AF_PACKET;
 			else if (strcmp(argv[1], "ipx") == 0)
 				preferred_family = AF_IPX;
+			else if (strcmp(argv[1], "can") == 0)
+				preferred_family = AF_CAN;
 			else if (strcmp(argv[1], "help") == 0)
 				usage();
 			else
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index a1f78b9..d7ee83a 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -27,6 +27,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <linux/sockios.h>
+#include <linux/can.h>
 
 #include "rt_names.h"
 #include "utils.h"
@@ -69,6 +70,8 @@ static void usage(void)
 	fprintf(stderr, "IFADDR := PREFIX | ADDR peer PREFIX\n");
 	fprintf(stderr, "          [ broadcast ADDR ] [ anycast ADDR ]\n");
 	fprintf(stderr, "          [ label STRING ] [ scope SCOPE-ID ]\n");
+	fprintf(stderr, "          | j1939 J1939IFADDR\n");
+	fprintf(stderr, "          \n");
 	fprintf(stderr, "SCOPE-ID := [ host | link | global | NUMBER ]\n");
 	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
 	fprintf(stderr, "FLAG  := [ permanent | dynamic | secondary | primary |\n");
@@ -78,6 +81,10 @@ static void usage(void)
 	fprintf(stderr, "CONFFLAG  := [ home | nodad ]\n");
 	fprintf(stderr, "LIFETIME := [ valid_lft LFT ] [ preferred_lft LFT ]\n");
 	fprintf(stderr, "LFT := forever | SECONDS\n");
+	fprintf(stderr, "          \n");
+	fprintf(stderr, "J1939IFADDR := [SA] [ name NODENAME ]\n");
+	fprintf(stderr, "SA := U8\n");
+	fprintf(stderr, "NODENAME := U64\n");
 
 	exit(-1);
 }
@@ -426,6 +433,19 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	}
 
 	fprintf(fp, "\n");
+
+	if (do_link && tb[IFLA_AF_SPEC]) {
+		struct rtattr *af[AF_MAX];
+
+		parse_rtattr_nested(af, AF_MAX, tb[IFLA_AF_SPEC]);
+		if (af[AF_CAN]) {
+			struct rtattr *prot[CAN_NPROTO];
+
+			parse_rtattr_nested(prot, CAN_NPROTO, af[AF_CAN]);
+			if (prot[CAN_J1939])
+				fprintf(fp, "    %s\n", j1939_link_attrtop(prot[CAN_J1939]));
+		}
+	}
 	fflush(fp);
 	return 0;
 }
@@ -450,6 +470,13 @@ static int set_lifetime(unsigned int *lifetime, char *argv)
 	return 0;
 }
 
+static const int af_use_prefix[AF_MAX] = {
+	[AF_INET] = 1,
+	[AF_INET6] = 1,
+	[AF_DECnet] = 1,
+	[AF_IPX] = 1,
+};
+
 int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		   void *arg)
 {
@@ -457,6 +484,7 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	struct ifaddrmsg *ifa = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	int deprecated = 0;
+	int protocol = 0;
 	/* Use local copy of ifa_flags to not interfere with filtering code */
 	unsigned int ifa_flags;
 	struct rtattr * rta_tb[IFA_MAX+1];
@@ -476,10 +504,12 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 
 	parse_rtattr(rta_tb, IFA_MAX, IFA_RTA(ifa), n->nlmsg_len - NLMSG_LENGTH(sizeof(*ifa)));
 
-	if (!rta_tb[IFA_LOCAL])
-		rta_tb[IFA_LOCAL] = rta_tb[IFA_ADDRESS];
-	if (!rta_tb[IFA_ADDRESS])
-		rta_tb[IFA_ADDRESS] = rta_tb[IFA_LOCAL];
+	if (af_use_prefix[ifa->ifa_family]) {
+		if (!rta_tb[IFA_LOCAL])
+			rta_tb[IFA_LOCAL] = rta_tb[IFA_ADDRESS];
+		if (!rta_tb[IFA_ADDRESS])
+			rta_tb[IFA_ADDRESS] = rta_tb[IFA_LOCAL];
+	}
 
 	if (filter.ifindex && filter.ifindex != ifa->ifa_index)
 		return 0;
@@ -541,38 +571,64 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		fprintf(fp, "    dnet ");
 	else if (ifa->ifa_family == AF_IPX)
 		fprintf(fp, "     ipx ");
+	else if (ifa->ifa_family == AF_CAN) {
+		/* ifa->ifa_prefixlen is abused for protocol number */
+		const char *sprotocol;
+		char num[16];
+
+		/* 1st: set protocol, as this is rather tricky */
+		protocol = ifa->ifa_prefixlen;
+
+		/* 2nd: set label */
+		switch (protocol) {
+		case CAN_J1939:
+			sprotocol = "j1939";
+			break;
+		default:
+			sprintf(num, "%i", ifa->ifa_prefixlen);
+			sprotocol = num;
+			break;
+		}
+		fprintf(fp, "    can-%s ", sprotocol);
+	}
 	else
 		fprintf(fp, "    family %d ", ifa->ifa_family);
 
 	if (rta_tb[IFA_LOCAL]) {
-		fprintf(fp, "%s", rt_addr_n2a(ifa->ifa_family,
+		fprintf(fp, "%s", rt_addrpr_n2a(ifa->ifa_family, protocol,
 					      RTA_PAYLOAD(rta_tb[IFA_LOCAL]),
 					      RTA_DATA(rta_tb[IFA_LOCAL]),
 					      abuf, sizeof(abuf)));
 
 		if (rta_tb[IFA_ADDRESS] == NULL ||
 		    memcmp(RTA_DATA(rta_tb[IFA_ADDRESS]), RTA_DATA(rta_tb[IFA_LOCAL]), 4) == 0) {
-			fprintf(fp, "/%d ", ifa->ifa_prefixlen);
 		} else {
-			fprintf(fp, " peer %s/%d ",
-				rt_addr_n2a(ifa->ifa_family,
+			fprintf(fp, " peer %s",
+				rt_addrpr_n2a(ifa->ifa_family, protocol,
 					    RTA_PAYLOAD(rta_tb[IFA_ADDRESS]),
 					    RTA_DATA(rta_tb[IFA_ADDRESS]),
-					    abuf, sizeof(abuf)),
-				ifa->ifa_prefixlen);
+					    abuf, sizeof(abuf)));
 		}
+		if (af_use_prefix[ifa->ifa_family])
+			fprintf(fp, "/%d", ifa->ifa_prefixlen);
+		fprintf(fp, " ");
+	} else if (rta_tb[IFA_ADDRESS]) {
+		fprintf(fp, "peer %s ", rt_addrpr_n2a(ifa->ifa_family, protocol,
+					RTA_PAYLOAD(rta_tb[IFA_ADDRESS]),
+					RTA_DATA(rta_tb[IFA_ADDRESS]),
+					abuf, sizeof(abuf)));
 	}
 
 	if (rta_tb[IFA_BROADCAST]) {
 		fprintf(fp, "brd %s ",
-			rt_addr_n2a(ifa->ifa_family,
+			rt_addrpr_n2a(ifa->ifa_family, protocol,
 				    RTA_PAYLOAD(rta_tb[IFA_BROADCAST]),
 				    RTA_DATA(rta_tb[IFA_BROADCAST]),
 				    abuf, sizeof(abuf)));
 	}
 	if (rta_tb[IFA_ANYCAST]) {
 		fprintf(fp, "any %s ",
-			rt_addr_n2a(ifa->ifa_family,
+			rt_addrpr_n2a(ifa->ifa_family, protocol,
 				    RTA_PAYLOAD(rta_tb[IFA_ANYCAST]),
 				    RTA_DATA(rta_tb[IFA_ANYCAST]),
 				    abuf, sizeof(abuf)));
@@ -1103,12 +1159,18 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 			req.ifa.ifa_flags |= IFA_F_HOMEADDRESS;
 		} else if (strcmp(*argv, "nodad") == 0) {
 			req.ifa.ifa_flags |= IFA_F_NODAD;
+		} else if (matches(*argv, "j1939") == 0) {
+			int ret;
+
+			ret = j1939_addr_args(argc, argv, &req.n, sizeof(req));
+			if (ret < 0)
+				return ret;
+			argc -= ret;
+			argv += ret;
 		} else {
 			if (strcmp(*argv, "local") == 0) {
 				NEXT_ARG();
 			}
-			if (matches(*argv, "help") == 0)
-				usage();
 			if (local_len)
 				duparg2("local", *argv);
 			lcl_arg = *argv;
@@ -1214,8 +1276,9 @@ int do_ipaddr(int argc, char **argv)
 		return ipaddr_list_or_flush(argc-1, argv+1, 0);
 	if (matches(*argv, "flush") == 0)
 		return ipaddr_list_or_flush(argc-1, argv+1, 1);
-	if (matches(*argv, "help") == 0)
+	if (matches(*argv, "help") == 0) {
 		usage();
+	}
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip addr help\".\n", *argv);
 	exit(-1);
 }
diff --git a/ip/iplink.c b/ip/iplink.c
index 48c0254..cd8d906 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -27,6 +27,7 @@
 #include <string.h>
 #include <sys/ioctl.h>
 #include <linux/sockios.h>
+#include <linux/can.h>
 
 #include "rt_names.h"
 #include "utils.h"
@@ -73,6 +74,7 @@ void iplink_usage(void)
 	fprintf(stderr, "				   [ rate TXRATE ] ] \n");
 	fprintf(stderr, "			  [ master DEVICE ]\n");
 	fprintf(stderr, "			  [ nomaster ]\n");
+	fprintf(stderr, "			  [ j1939 { on | off } ]\n");
 	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ]\n");
 
 	if (iplink_have_newlink()) {
@@ -402,6 +404,12 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 				duparg("group", *argv);
 			if (rtnl_group_a2n(group, *argv))
 				invarg("Invalid \"group\" value\n", *argv);
+		} else if (matches(*argv, "j1939") == 0) {
+			ret = j1939_link_args(argc, argv, &req->n, sizeof(*req));
+			if (ret < 0)
+				return ret;
+			argc -= ret;
+			argv += ret;
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
diff --git a/lib/j1939.c b/lib/j1939.c
new file mode 100644
index 0000000..157a8ce
--- /dev/null
+++ b/lib/j1939.c
@@ -0,0 +1,153 @@
+#include <string.h>
+#include <errno.h>
+#include <sys/types.h>
+#include <netinet/in.h>
+#include <endian.h>
+#include <linux/can/j1939.h>
+
+#include "utils.h"
+
+#ifndef htobe64
+# if __BYTE_ORDER == __LITTLE_ENDIAN
+#  define htobe64(x) __bswap_64 (x)
+#  define htole64(x) (x)
+#  define be64toh(x) __bswap_64 (x)
+#  define le64toh(x) (x)
+# else
+#  define htobe64(x) (x)
+#  define htole64(x) __bswap_64 (x)
+#  define be64toh(x) (x)
+#  define le64toh(x) __bswap_64 (x)
+# endif
+#endif
+/*
+ * print J1939 name
+ * for use from rt_addr_n2a
+ */
+const char *j1939_ntop(int af, const void *vaddr, size_t vlen,
+		char *str, size_t len)
+{
+	struct rtattr *tb[IFA_J1939_MAX];
+	int strdone = 0;
+
+	/* cast vaddr to non-const pointer */
+	parse_rtattr(tb, IFA_J1939_MAX-1, (void *)vaddr, vlen);
+	if (tb[IFA_J1939_ADDR]) {
+		strdone += sprintf(&str[strdone], "0x%02x",
+				*(uint8_t *)RTA_DATA(tb[IFA_J1939_ADDR]));
+		if (tb[IFA_J1939_NAME])
+			str[strdone++] = ' ';
+	}
+	if (tb[IFA_J1939_NAME])
+		strdone += sprintf(&str[strdone], "name %016llx",
+				(unsigned long long)be64toh(*(uint64_t *)RTA_DATA(tb[IFA_J1939_NAME])));
+	errno = 0;
+	return str;
+}
+
+/*
+ * fill an ifaddr message from program arguments
+ */
+int j1939_addr_args(int argc, char *argv[], struct nlmsghdr *msg, int msg_size)
+{
+	int saved_argc = argc;
+	struct ifaddrmsg *ifa = (void *)&msg[1];
+	struct rtattr *local;
+
+	if (ifa->ifa_family == AF_UNSPEC)
+		ifa->ifa_family = AF_CAN;
+	else {
+		fprintf(stderr, "j1939 only allowed for AF_CAN\n");
+		return -1;
+	}
+	if (!ifa->ifa_prefixlen)
+		ifa->ifa_prefixlen = CAN_J1939;
+	else {
+		fprintf(stderr, "CAN protocol %i already specified",
+				ifa->ifa_prefixlen);
+		return -1;
+	}
+	NEXT_ARG();
+	/* j1939 SA & NAME never need to be specified together */
+	if (matches(*argv, "name") == 0) {
+		uint64_t name;
+
+		NEXT_ARG();
+		name = htobe64(strtoull(*argv, 0, 16));
+		if (!name) {
+			fprintf(stderr, "0 name is not valid\n");
+			return -1;
+		}
+		local = addattr_nest(msg, msg_size, IFA_LOCAL);
+		addattr_l(msg, msg_size, IFA_J1939_NAME, &name, sizeof(name));
+		addattr_nest_end(msg, local);
+	} else {
+		unsigned int laddr;
+		uint8_t addr;
+
+		addr = laddr = strtoul(*argv, 0, 0);
+		if (laddr >= 0xfe) {
+			fprintf(stderr, "address '%s' not valid\n", *argv);
+			return -1;
+		}
+		local = addattr_nest(msg, msg_size, IFA_LOCAL);
+		addattr_l(msg, msg_size, IFA_J1939_ADDR, &addr, sizeof(addr));
+		addattr_nest_end(msg, local);
+	}
+
+	return saved_argc - argc;
+}
+
+/*
+ * fill an link_af message from program arguments
+ */
+int j1939_link_args(int argc, char *argv[], struct nlmsghdr *msg, int msg_size)
+{
+	int saved_argc = argc;
+	struct rtattr *afspec, *can, *j1939;
+	uint8_t enable;
+
+	NEXT_ARG();
+	if (strcmp(*argv, "on") == 0) {
+		enable = 1;
+	} else if (strcmp(*argv, "off") == 0) {
+		enable = 0;
+	} else {
+		enable = 1;
+		/* revert arguments */
+		++argc;
+		--argv;
+	}
+
+	afspec = addattr_nest(msg, msg_size, IFLA_AF_SPEC);
+	can = addattr_nest(msg, msg_size, AF_CAN);
+	j1939 = addattr_nest(msg, msg_size, CAN_J1939);
+	addattr_l(msg, msg_size, IFLA_J1939_ENABLE, &enable, sizeof(enable));
+	addattr_nest_end(msg, j1939);
+	addattr_nest_end(msg, can);
+	addattr_nest_end(msg, afspec);
+
+	return saved_argc - argc;
+}
+
+/*
+ * process the returned IFLA_AF_SPEC/AF_CAN/CAN_J1939 attribute
+ */
+const char *j1939_link_attrtop(struct rtattr *nla)
+{
+	static char str[32];
+	int pos;
+	struct rtattr *tb[IFLA_J1939_MAX];
+
+	pos = 0;
+	str[0] = 0;
+	parse_rtattr_nested(tb, IFLA_J1939_MAX-1, nla);
+	if (tb[IFLA_J1939_ENABLE]) {
+		uint8_t *u8ptr;
+
+		u8ptr = RTA_DATA(tb[IFLA_J1939_ENABLE]);
+		pos += sprintf(&str[pos], "j1939 %s", *u8ptr ? "on" : "off");
+	}
+	return str;
+}
+
diff --git a/lib/utils.c b/lib/utils.c
index 1b42222..570e43f 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -25,6 +25,7 @@
 #include <linux/pkt_sched.h>
 #include <time.h>
 #include <sys/time.h>
+#include <linux/can.h>
 
 
 #include "utils.h"
@@ -499,7 +500,8 @@ int __get_user_hz(void)
 	return sysconf(_SC_CLK_TCK);
 }
 
-const char *rt_addr_n2a(int af, int len, const void *addr, char *buf, int buflen)
+const char *rt_addrpr_n2a(int af, int protocol, int len, const void *addr,
+		char *buf, int buflen)
 {
 	switch (af) {
 	case AF_INET:
@@ -513,6 +515,11 @@ const char *rt_addr_n2a(int af, int len, const void *addr, char *buf, int buflen
 		memcpy(dna.a_addr, addr, 2);
 		return dnet_ntop(af, &dna, buf, buflen);
 	}
+	case AF_CAN:
+		switch (protocol) {
+		case CAN_J1939:
+			return j1939_ntop(af, addr, len, buf, buflen);
+		}
 	default:
 		return "???";
 	}
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index c5248ef..eab2fd4 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -23,7 +23,7 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 \fB\-s\fR[\fItatistics\fR] |
 \fB\-r\fR[\fIesolve\fR] |
 \fB\-f\fR[\fIamily\fR] {
-.BR inet " | " inet6 " | " ipx " | " dnet " | " link " } | "
+.BR inet " | " inet6 " | " ipx " | " dnet " | " link " | " can " } | "
 \fB\-o\fR[\fIneline\fR] }
 
 .ti -8
@@ -103,6 +103,8 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 .IR DEVICE
 .br
 .B nomaster
+.br
+.BR j1939 " { " on " | " off " }"
 
 .ti -8
 .B ip link show
@@ -135,7 +137,9 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 .B  label
 .IR STRING " ] [ "
 .B  scope
-.IR SCOPE-ID " ]"
+.IR SCOPE-ID " ] | "
+.B  j1939
+.IR IFADDRJ1939 " ] "
 
 .ti -8
 .IR SCOPE-ID " := "
@@ -151,6 +155,15 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 tentative " | " deprecated " | " dadfailed " | " temporary " ]"
 
 .ti -8
+.IR J1939IFADDR " := [ " SA " ] [ "
+.B  name
+.IR " NODENAME " ]
+.br
+.IR SA " := " U8
+.br
+.IR NODENAME " := " U64
+
+.ti -8
 .BR "ip addrlabel" " { " add " | " del " } " prefix
 .BR PREFIX " [ "
 .B dev
@@ -1067,6 +1080,9 @@ set master device of the device (enslave device).
 .TP
 .BI nomaster
 unset master device of the device (release device).
+.BR "j1939 on " or "j1939 off"
+Enable or disable SAE J1939 on the device. This will only
+work when the device is a CAN device.
 
 .PP
 .B Warning:
