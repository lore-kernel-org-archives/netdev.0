From: David L Stevens <dlstevens@us.ibm.com>
Subject: [PATCH iproute2] add DOVE extensions for iproute2
Date: Tue, 13 Nov 2012 15:25:17 -0500
Message-ID: <201211132026.qADKPHUn018881@lab1.dls>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:55155 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755825Ab2KMUaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 15:30:20 -0500
Received: from /spool/local
	by e5.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Tue, 13 Nov 2012 15:30:19 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 4E94438C804D
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2012 15:29:30 -0500 (EST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qADKTSad265312
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2012 15:29:28 -0500
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qADKRmXQ001693
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2012 13:27:49 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	This patch adds a new flag to iproute2 for vxlan devices to enable
DOVE features. It also adds support for L2 and L3 switch lookup miss
netlink messages to "ip monitor".

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 012d95a..cbfe1fd 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -283,6 +283,7 @@ enum {
 	IFLA_VXLAN_AGEING,
 	IFLA_VXLAN_LIMIT,
 	IFLA_VXLAN_PORT_RANGE,
+	IFLA_VXLAN_DOVE,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index ba5c4ab..b7a987a 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -26,6 +26,7 @@ static void explain(void)
 	fprintf(stderr, "Usage: ... vxlan id VNI [ group ADDR ] [ local ADDR ]\n");
 	fprintf(stderr, "                 [ ttl TTL ] [ tos TOS ] [ dev PHYS_DEV ]\n");
 	fprintf(stderr, "                 [ port MIN MAX ] [ [no]learning ]\n");
+	fprintf(stderr, "                 [ [no]dove]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: VNI := 0-16777215\n");
 	fprintf(stderr, "       ADDR := { IP_ADDRESS | any }\n");
@@ -44,6 +45,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u8 tos = 0;
 	__u8 ttl = 0;
 	__u8 learning = 1;
+	__u8 dove = 0;
 	__u8 noage = 0;
 	__u32 age = 0;
 	__u32 maxaddr = 0;
@@ -123,6 +125,10 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			learning = 0;
 		} else if (!matches(*argv, "learning")) {
 			learning = 1;
+		} else if (!matches(*argv, "nodove")) {
+			dove = 0;
+		} else if (!matches(*argv, "dove")) {
+			dove = 1;
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -148,6 +154,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	addattr8(n, 1024, IFLA_VXLAN_TTL, ttl);
 	addattr8(n, 1024, IFLA_VXLAN_TOS, tos);
 	addattr8(n, 1024, IFLA_VXLAN_LEARNING, learning);
+	addattr8(n, 1024, IFLA_VXLAN_DOVE, dove);
 	if (noage)
 		addattr32(n, 1024, IFLA_VXLAN_AGEING, 0);
 	else if (age)
@@ -213,6 +220,10 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_VXLAN_LEARNING] &&
 	    !rta_getattr_u8(tb[IFLA_VXLAN_LEARNING]))
 		fputs("nolearning ", f);
+ 
+	if (tb[IFLA_VXLAN_DOVE] &&
+	    rta_getattr_u8(tb[IFLA_VXLAN_DOVE]))
+		fputs("dove ", f);
 	
 	if (tb[IFLA_VXLAN_TOS] &&
 	    (tos = rta_getattr_u8(tb[IFLA_VXLAN_TOS]))) {
diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 4b1d469..7a7cc88 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -67,7 +67,8 @@ int accept_msg(const struct sockaddr_nl *who,
 		print_addrlabel(who, n, arg);
 		return 0;
 	}
-	if (n->nlmsg_type == RTM_NEWNEIGH || n->nlmsg_type == RTM_DELNEIGH) {
+	if (n->nlmsg_type == RTM_NEWNEIGH || n->nlmsg_type == RTM_DELNEIGH ||
+	    n->nlmsg_type == RTM_GETNEIGH) {
 		if (prefix_banner)
 			fprintf(fp, "[NEIGH]");
 		print_neigh(who, n, arg);
diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index 56e56b2..1b7600b 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -189,7 +189,8 @@ int print_neigh(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	struct rtattr * tb[NDA_MAX+1];
 	char abuf[256];
 
-	if (n->nlmsg_type != RTM_NEWNEIGH && n->nlmsg_type != RTM_DELNEIGH) {
+	if (n->nlmsg_type != RTM_NEWNEIGH && n->nlmsg_type != RTM_DELNEIGH &&
+	    n->nlmsg_type != RTM_GETNEIGH) {
 		fprintf(stderr, "Not RTM_NEWNEIGH: %08x %08x %08x\n",
 			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
 
@@ -251,6 +252,8 @@ int print_neigh(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 	if (n->nlmsg_type == RTM_DELNEIGH)
 		fprintf(fp, "delete ");
+	else if (n->nlmsg_type == RTM_GETNEIGH)
+		fprintf(fp, "miss ");
 	if (tb[NDA_DST]) {
 		fprintf(fp, "%s ",
 			format_host(r->ndm_family,
