From: David L Stevens <dlstevens@us.ibm.com>
Subject: [PATCH] iproute2: support NTF_ROUTER flag in VXLAN fdb entries
Date: Mon, 06 May 2013 08:09:50 -0400
Message-ID: <201305061209.r46C9oen002801@lab1.dls>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:44293 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751525Ab3EFMLg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 May 2013 08:11:36 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Mon, 6 May 2013 08:11:35 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id ADC126E803F
	for <netdev@vger.kernel.org>; Mon,  6 May 2013 08:11:30 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r46CBX5e307280
	for <netdev@vger.kernel.org>; Mon, 6 May 2013 08:11:33 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r46CBX8x002919
	for <netdev@vger.kernel.org>; Mon, 6 May 2013 06:11:33 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch allows setting the "NTF_ROUTER" flag in VXLAN forwarding table
entries to enable L3 switching for router destinations while still allowing
L2 redirection appliances for non-router MAC destinations.

Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>

diff --git a/bridge/fdb.c b/bridge/fdb.c
index e05644f..b3c1594 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -30,7 +30,7 @@ int filter_index;
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: bridge fdb { add | del } ADDR dev DEV {self|master} [ temp ]\n"
+	fprintf(stderr, "Usage: bridge fdb { add | del } ADDR dev DEV {self|master} [ temp ] [router]\n"
 		        "              [ dst IPADDR] [ vlan VID ]\n"
 		        "              [ port PORT] [ vni VNI ] [via DEV]\n");
 	fprintf(stderr, "       bridge fdb {show} [ dev DEV ]\n");
@@ -143,6 +143,8 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "self ");
 	if (r->ndm_flags & NTF_MASTER)
 		fprintf(fp, "master ");
+	if (r->ndm_flags & NTF_ROUTER)
+		fprintf(fp, "router ");
 
 	fprintf(fp, "%s\n", state_n2a(r->ndm_state));
 	return 0;
@@ -248,6 +250,8 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 			req.ndm.ndm_flags |= NTF_SELF;
 		} else if (matches(*argv, "master") == 0) {
 			req.ndm.ndm_flags |= NTF_MASTER;
+		} else if (matches(*argv, "router") == 0) {
+			req.ndm.ndm_flags |= NTF_ROUTER;
 		} else if (matches(*argv, "local") == 0||
 			   matches(*argv, "permanent") == 0) {
 			req.ndm.ndm_state |= NUD_PERMANENT;
