From: David L Stevens <dlstevens@us.ibm.com>
Subject: [PATCHv3] iproute2: generalize VXLAN forwarding tables
Date: Fri, 29 Mar 2013 11:54:20 -0400
Message-ID: <201303291554.r2TFsKH8003947@lab1.dls>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:45626 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756344Ab3C2Pzd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Mar 2013 11:55:33 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Fri, 29 Mar 2013 11:55:32 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id B31286E803A
	for <netdev@vger.kernel.org>; Fri, 29 Mar 2013 11:55:25 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2TFtRUF203462
	for <netdev@vger.kernel.org>; Fri, 29 Mar 2013 11:55:27 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2TFtPg1010557
	for <netdev@vger.kernel.org>; Fri, 29 Mar 2013 09:55:25 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[arrggg -- made the same mistake -- this version actually has the missing
	line I intended to add in the v2 -- sorry for the noise]

iproute2 patch to generalize VXLAN forwarding tables

This is the iproute2 support allowing an administrator to specify alternate
ports, vnis and outgoing interfaces for VXLAN device forwarding tables.

Changes since v2: fixed missing port assignment for ports-by-name

Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>

diff --git a/bridge/fdb.c b/bridge/fdb.c
index 6ad8118..e05644f 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -9,6 +9,7 @@
 #include <stdio.h>
 #include <stdlib.h>
 #include <unistd.h>
+#include <netdb.h>
 #include <time.h>
 #include <fcntl.h>
 #include <sys/socket.h>
@@ -30,7 +31,8 @@ int filter_index;
 static void usage(void)
 {
 	fprintf(stderr, "Usage: bridge fdb { add | del } ADDR dev DEV {self|master} [ temp ]\n"
-		        "              [ dst IPADDR] [ vlan VID ]\n");
+		        "              [ dst IPADDR] [ vlan VID ]\n"
+		        "              [ port PORT] [ vni VNI ] [via DEV]\n");
 	fprintf(stderr, "       bridge fdb {show} [ dev DEV ]\n");
 	exit(-1);
 }
@@ -113,6 +115,23 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "vlan %hu ", vid);
 	}
 
+	if (tb[NDA_PORT])
+		fprintf(fp, "port %d ", rta_getattr_u32(tb[NDA_PORT]));
+	if (tb[NDA_VNI])
+		fprintf(fp, "vni %d ", rta_getattr_u32(tb[NDA_VNI]));
+	if (tb[NDA_IFINDEX]) {
+		unsigned int ifindex = rta_getattr_u32(tb[NDA_IFINDEX]);
+
+		if (ifindex) {
+			char ifname[IF_NAMESIZE];
+
+			if (if_indextoname(ifindex, ifname))
+				fprintf(fp, "via %s ", ifname);
+			else
+				fprintf(fp, "via ifindex %u ", ifindex);
+		}
+	}
+
 	if (show_stats && tb[NDA_CACHEINFO]) {
 		struct nda_cacheinfo *ci = RTA_DATA(tb[NDA_CACHEINFO]);
 		int hz = get_user_hz();
@@ -177,6 +196,10 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 	char abuf[ETH_ALEN];
 	int dst_ok = 0;
 	inet_prefix dst;
+	unsigned long port = 0;
+	unsigned long vni = ~0;
+	unsigned int via = 0;
+	char *endptr;
 	short vid = -1;
 
 	memset(&req, 0, sizeof(req));
@@ -197,6 +220,30 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 				duparg2("dst", *argv);
 			get_addr(&dst, *argv, preferred_family);
 			dst_ok = 1;
+		} else if (strcmp(*argv, "port") == 0) {
+
+			NEXT_ARG();
+			port = strtoul(*argv, &endptr, 0);
+			if (endptr && *endptr) {
+				struct servent *pse;
+
+				pse = getservbyname(*argv, "udp");
+				if (!pse)
+					invarg("invalid port\n", *argv);
+				port = ntohs(pse->s_port);
+			} else if (port > 0xffff)
+				invarg("invalid port\n", *argv);
+		} else if (strcmp(*argv, "vni") == 0) {
+			NEXT_ARG();
+			vni = strtoul(*argv, &endptr, 0);
+			if ((endptr && *endptr) ||
+			    (vni >> 24) || vni == ULONG_MAX)
+				invarg("invalid VNI\n", *argv);
+		} else if (strcmp(*argv, "via") == 0) {
+			NEXT_ARG();
+			via = if_nametoindex(*argv);
+			if (via == 0)
+				invarg("invalid device\n", *argv);
 		} else if (strcmp(*argv, "self") == 0) {
 			req.ndm.ndm_flags |= NTF_SELF;
 		} else if (matches(*argv, "master") == 0) {
@@ -251,6 +298,13 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 	if (vid >= 0)
 		addattr16(&req.n, sizeof(req), NDA_VLAN, vid);
 
+	if (port)
+		addattr32(&req.n, sizeof(req), NDA_PORT, port);
+	if (vni != ~0)
+		addattr32(&req.n, sizeof(req), NDA_VNI, vni);
+	if (via)
+		addattr32(&req.n, sizeof(req), NDA_IFINDEX, via);
+
 	req.ndm.ndm_ifindex = ll_name_to_index(d);
 	if (req.ndm.ndm_ifindex == 0) {
 		fprintf(stderr, "Cannot find device \"%s\"\n", d);
@@ -270,6 +324,8 @@ int do_fdb(int argc, char **argv)
 	if (argc > 0) {
 		if (matches(*argv, "add") == 0)
 			return fdb_modify(RTM_NEWNEIGH, NLM_F_CREATE|NLM_F_EXCL, argc-1, argv+1);
+		if (matches(*argv, "append") == 0)
+			return fdb_modify(RTM_NEWNEIGH, NLM_F_CREATE|NLM_F_APPEND, argc-1, argv+1);
 		if (matches(*argv, "delete") == 0)
 			return fdb_modify(RTM_DELNEIGH, 0, argc-1, argv+1);
 		if (matches(*argv, "show") == 0 ||
diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
index adb068c..f175212 100644
--- a/include/linux/neighbour.h
+++ b/include/linux/neighbour.h
@@ -21,6 +21,9 @@ enum {
 	NDA_CACHEINFO,
 	NDA_PROBES,
 	NDA_VLAN,
+	NDA_PORT,
+	NDA_VNI,
+	NDA_IFINDEX,
 	__NDA_MAX
 };
 
