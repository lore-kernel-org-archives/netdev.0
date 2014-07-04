From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 PATCH 1/1] iproute2 bridge: bring to above par with brctl show macs
Date: Fri,  4 Jul 2014 08:37:10 -0400
Message-ID: <1404477430-12261-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:48215 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbaGDMhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2014 08:37:20 -0400
Received: by mail-ig0-f169.google.com with SMTP id c1so8414488igq.2
        for <netdev@vger.kernel.org>; Fri, 04 Jul 2014 05:37:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

root@moja-mojo:bridge# ./bridge fdb help
Usage: bridge fdb { add | append | del | replace } ADDR dev DEV {self|master} [ temp ]
              [router] [ dst IPADDR] [ vlan VID ]
              [ port PORT] [ vni VNI ] [via DEV]
       bridge fdb {show} [ br BRDEV ] [ brport DEV ]

 Lets start with two bridges each with a port...

root@moja-mojo:bridge# ./bridge link
10: sw1-p1 state DOWN : <BROADCAST,NOARP> mtu 1500 master sw1 state disabled priority 32 cost 100
11: eth1 state DOWN : <BROADCAST,NOARP> mtu 1500 master br0 state disabled priority 32 cost 100

show all...
root@moja-mojo:bridge# ./bridge fdb show
33:33:00:00:00:01 dev ifb0 self permanent
33:33:00:00:00:01 dev ifb1 self permanent
33:33:00:00:00:01 dev eth0 self permanent
01:00:5e:00:00:01 dev eth0 self permanent
33:33:ff:92:c0:60 dev eth0 self permanent
33:33:00:00:00:fb dev eth0 self permanent
01:00:5e:00:00:fb dev eth0 self permanent
01:00:5e:7f:ff:fd dev eth0 self permanent
01:00:5e:00:00:01 dev wlan0 self permanent
33:33:00:00:00:01 dev wlan0 self permanent
33:33:ff:c2:84:3b dev wlan0 self permanent
33:33:00:00:00:fb dev wlan0 self permanent
01:00:5e:00:00:01 dev virbr0 self permanent
01:00:5e:00:00:fb dev virbr0 self permanent
33:33:00:00:00:01 dev br0 self permanent
33:33:00:00:00:01 dev sw1 self permanent
33:33:00:00:00:01 dev dummy0 self permanent
5e:f4:03:44:da:9a dev sw1-p1 vlan 0 master sw1 permanent
33:33:00:00:00:01 dev sw1-p1 self permanent
b6:5e:dd:ce:d7:5e dev eth1 vlan 0 master br0 permanent
33:33:00:00:00:01 dev eth1 self permanent

Lets see a netdev that is *not* attached to a bridge

root@moja-mojo:bridge# ./bridge fdb show brport eth0
33:33:00:00:00:01 self permanent
01:00:5e:00:00:01 self permanent
33:33:ff:92:c0:60 self permanent
33:33:00:00:00:fb self permanent
01:00:5e:00:00:fb self permanent
01:00:5e:7f:ff:fd self permanent

Lets see a netdev that is bridge port
root@moja-mojo:bridge# ./bridge fdb show brport eth1
hadi@jhs-1:/media/MT1/other-gits/iproute-jul04/bridge$ ./bridge fdb show brport eth1
b6:5e:dd:ce:d7:5e vlan 0 master br0 permanent
33:33:00:00:00:01 self permanent

Specify the correct bridge and you get good stuff
root@moja-mojo:bridge# ./bridge fdb show brport eth1 br br0
6:5e:dd:ce:d7:5e vlan 0 master br0 permanent
33:33:00:00:00:01 self permanent

Specify the wrong bridge and you get good nada
root@moja-mojo:bridge# ./bridge fdb show brport eth1 br sw1

dump br0
root@moja-mojo:bridge# ./bridge fdb show br br0
33:33:00:00:00:01 dev br0 self permanent
b6:5e:dd:ce:d7:5e dev eth1 vlan 0 master br0 permanent
33:33:00:00:00:01 dev eth1 self permanent

dump sw1
root@moja-mojo:bridge# ./bridge fdb show br sw1
33:33:00:00:00:01 dev sw1 self permanent
5e:f4:03:44:da:9a dev sw1-p1 vlan 0 master sw1 permanent
33:33:00:00:00:01 dev sw1-p1 self permanent

Lets move a port from one bridge to another for shits-and-giggles
(as the New Brunswickians like to say)
root@moja-mojo:bridge# ip link set sw1-p1 master br0

Now dump again br0
root@moja-mojo:bridge# ./bridge fdb show br br0
33:33:00:00:00:01 dev br0 self permanent
5e:f4:03:44:da:9a dev sw1-p1 vlan 0 master br0 permanent
33:33:00:00:00:01 dev sw1-p1 self permanent
b6:5e:dd:ce:d7:5e dev eth1 vlan 0 master br0 permanent
33:33:00:00:00:01 dev eth1 self permanent

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 bridge/fdb.c |   38 +++++++++++++++++++++++++++++++++-----
 1 file changed, 33 insertions(+), 5 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index 9a07a32..a55fac1 100644
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
 
@@ -161,18 +161,45 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
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
@@ -180,9 +207,10 @@ static int fdb_show(int argc, char **argv)
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
-- 
1.7.9.5
