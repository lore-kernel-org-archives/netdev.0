From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH 1/1] iproute2 bridge: bring to above par with brctl show macs
Date: Sun,  1 Jun 2014 08:06:05 -0400
Message-ID: <1401624365-5103-1-git-send-email-jhs@emojatatu.com>
Cc: vyasevic@redhat.com, sfeldma@cumulusnetworks.com,
	john.r.fastabend@intel.com, roopa@cumulusnetworks.com,
	netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:51723 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757125AbaFAMGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 08:06:19 -0400
Received: by mail-ie0-f171.google.com with SMTP id to1so3433084ieb.30
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 05:06:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

root@moja-mojo:bridge# ./bridge fdb help
Usage: bridge fdb { add | append | del | replace } ADDR dev DEV
{self|master} [ temp ]
              [router] [ dst IPADDR] [ vlan VID ]
              [ port PORT] [ vni VNI ] [via DEV]
       bridge fdb {show} [ br BRDEV ] [ brport DEV ]

Lets start with two bridges each with a port...

root@moja-mojo:bridge# ./bridge link
8: eth1 state DOWN : <BROADCAST,MULTICAST> mtu 1500 master br0 state disabled priority 32 cost 19
17: sw1-p1 state DOWN : <BROADCAST,NOARP> mtu 1500 master sw1 state disabled priority 32 cost 100

show all...
root@moja-mojo:bridge# ./bridge fdb show
33:33:00:00:00:01 dev bond0 self permanent
33:33:00:00:00:01 dev dummy0 self permanent
33:33:00:00:00:01 dev ifb0 self permanent
33:33:00:00:00:01 dev ifb1 self permanent
33:33:00:00:00:01 dev eth0 self permanent
01:00:5e:00:00:01 dev eth0 self permanent
33:33:ff:22:01:01 dev eth0 self permanent
02:00:00:12:01:02 dev eth1 vlan 0 master br0 permanent
00:17:42:8a:b4:05 dev eth1 vlan 0 master br0 permanent
00:17:42:8a:b4:07 dev eth1 self permanent
33:33:00:00:00:01 dev eth1 self permanent
33:33:00:00:00:01 dev gretap0 self permanent
33:33:00:00:00:01 dev br0 self permanent
33:33:00:00:00:01 dev sw1 self permanent
a2:fb:21:4c:47:25 dev sw1-p1 vlan 0 master sw1 permanent
33:33:00:00:00:01 dev sw1-p1 self permanent

Lets see a port that is not attached to a bridge

root@moja-mojo:bridge# ./bridge fdb show brport eth0
33:33:00:00:00:01 self permanent
01:00:5e:00:00:01 self permanent
33:33:ff:22:01:01 self permanent

Lets see a port that is attached to a bridge
root@moja-mojo:bridge# ./bridge fdb show brport eth1
02:00:00:12:01:02 vlan 0 master br0 permanent
00:17:42:8a:b4:05 vlan 0 master br0 permanent
00:17:42:8a:b4:07 self permanent
33:33:00:00:00:01 self permanent

Specify the correct bridge and you get good stuff
root@moja-mojo:bridge# ./bridge fdb show brport eth1 br br0
02:00:00:12:01:02 vlan 0 master br0 permanent
00:17:42:8a:b4:05 vlan 0 master br0 permanent
00:17:42:8a:b4:07 self permanent
33:33:00:00:00:01 self permanent

Specify the wrong bridge and you get good nada
root@moja-mojo:bridge# ./bridge fdb show brport eth1 br sw1

dump only br0
root@moja-mojo:bridge# ./bridge fdb show br br0
02:00:00:12:01:02 dev eth1 vlan 0 master br0 permanent
00:17:42:8a:b4:05 dev eth1 vlan 0 master br0 permanent
00:17:42:8a:b4:07 dev eth1 self permanent
33:33:00:00:00:01 dev eth1 self permanent

Lets move a port from one bridge to another for shits-and-giggles
(as they say in New Brunswick)
root@moja-mojo:bridge# ip link set sw1-p1 master br0

Now dump again br0

root@moja-mojo:bridge# ./bridge fdb show br br0
02:00:00:12:01:02 dev eth1 vlan 0 master br0 permanent
00:17:42:8a:b4:05 dev eth1 vlan 0 master br0 permanent
00:17:42:8a:b4:07 dev eth1 self permanent
33:33:00:00:00:01 dev eth1 self permanent
a2:fb:21:4c:47:25 dev sw1-p1 vlan 0 master br0 permanent
33:33:00:00:00:01 dev sw1-p1 self permanent

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 bridge/fdb.c |   42 ++++++++++++++++++++++++++++++++++++------
 1 file changed, 36 insertions(+), 6 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index 91ab5cd..1b7802e 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -34,7 +34,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: bridge fdb { add | append | del | replace } ADDR dev DEV {self|master} [ temp ]\n"
 		        "              [router] [ dst IPADDR] [ vlan VID ]\n"
 		        "              [ port PORT] [ vni VNI ] [via DEV]\n");
-	fprintf(stderr, "       bridge fdb {show} [ dev DEV ]\n");
+	fprintf(stderr, "       bridge fdb {show} [ br BRDEV ] [ brport DEV ]\n");
 	exit(-1);
 }
 
@@ -81,8 +81,9 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (r->ndm_family != AF_BRIDGE)
 		return 0;
 
-	if (filter_index && filter_index != r->ndm_ifindex)
+	if (filter_index && filter_index != r->ndm_ifindex) {
 		return 0;
+	}
 
 	parse_rtattr(tb, NDA_MAX, NDA_RTA(r),
 		     n->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
@@ -161,18 +162,45 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 static int fdb_show(int argc, char **argv)
 {
+	struct {
+		struct nlmsghdr 	n;
+		struct ifinfomsg	ifm;
+		char   			buf[256];
+	} req;
+
 	char *filter_dev = NULL;
+	char *br = NULL;
+	int msg_size = sizeof(struct ifinfomsg);
+
+	memset(&req, 0, sizeof(req));
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
+	req.ifm.ifi_family = PF_BRIDGE;
 
 	while (argc > 0) {
-		if (strcmp(*argv, "dev") == 0) {
+		if ((strcmp(*argv, "brport") == 0) || strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
-			if (filter_dev)
-				duparg("dev", *argv);
 			filter_dev = *argv;
+		} else if (strcmp(*argv, "br") == 0) {
+			NEXT_ARG();
+			br = *argv;
+		} else {
+			if (matches(*argv, "help") == 0)
+				usage();
 		}
 		argc--; argv++;
 	}
 
+	if (br) {
+		int br_ifindex = ll_name_to_index(br);
+		if (br_ifindex == 0) {
+			fprintf(stderr, "Cannot find bridge device \"%s\"\n", br);
+			return -1;
+		}
+		addattr32(&req.n, sizeof(req), IFLA_MASTER, br_ifindex);
+		msg_size += RTA_LENGTH(4);
+	}
+
+	/*we'll keep around filter_dev for older kernels */
 	if (filter_dev) {
 		filter_index = if_nametoindex(filter_dev);
 		if (filter_index == 0) {
@@ -180,13 +208,15 @@ static int fdb_show(int argc, char **argv)
 				filter_dev);
 			return -1;
 		}
+		req.ifm.ifi_index = filter_index;
 	}
 
-	if (rtnl_wilddump_request(&rth, PF_BRIDGE, RTM_GETNEIGH) < 0) {
+	if (rtnl_dump_request(&rth, RTM_GETNEIGH, &req.ifm, msg_size) < 0) {
 		perror("Cannot send dump request");
 		exit(1);
 	}
 
+
 	if (rtnl_dump_filter(&rth, print_fdb, stdout) < 0) {
 		fprintf(stderr, "Dump terminated\n");
 		exit(1);
-- 
1.7.9.5
