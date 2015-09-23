From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] ip: Add type and master filters to brief output
Date: Wed, 23 Sep 2015 16:44:56 -0600
Message-ID: <1443048296-66539-1-git-send-email-dsa@cumulusnetworks.com>
Cc: gospo@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, shemming@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34518 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633AbbIWWpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 18:45:04 -0400
Received: by padhy16 with SMTP id hy16so52779990pad.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 15:45:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The brief format does not honer the master and type filters:

$ ip link show master vrf-mgmt
7: dummy0: <BROADCAST,NOARP,SLAVE> mtu 1500 qdisc noop master vrf-mgmt state DOWN mode DEFAULT group default qlen 1000
    link/ether 66:39:cc:2b:e9:bd brd ff:ff:ff:ff:ff:ff

$ ip -br link show master vrf-mgmt
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>
eth0             UP             08:00:27:de:14:c8 <BROADCAST,MULTICAST,UP,LOWER_UP>
eth1             UP             08:00:27:87:02:f1 <BROADCAST,MULTICAST,UP,LOWER_UP>
eth2             UP             08:00:27:61:1e:fd <BROADCAST,MULTICAST,UP,LOWER_UP>
vrf-blue         UNKNOWN        a6:3f:09:34:7e:74 <NOARP,MASTER,UP,LOWER_UP>
vrf-red          DOWN           fe:a2:2d:e1:bc:ac <NOARP,MASTER>
dummy0           DOWN           66:39:cc:2b:e9:bd <BROADCAST,NOARP,SLAVE>
dummy1           DOWN           4a:4f:13:91:64:b1 <BROADCAST,NOARP,SLAVE>
dummy2           DOWN           b2:4f:b6:cd:bd:a6 <BROADCAST,NOARP>
dummy3           DOWN           1e:06:3d:40:b8:c2 <BROADCAST,NOARP,SLAVE>
vrf-mgmt         DOWN           ce:b2:74:41:21:df <NOARP,MASTER>

With this patch the expected output is shown:

$ ip -br link show master vrf-mgmt
dummy0           DOWN           66:39:cc:2b:e9:bd <BROADCAST,NOARP,SLAVE>

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ipaddress.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 2aa5fbfb7ace..e53984720d3c 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -637,6 +637,25 @@ int print_linkinfo_brief(const struct sockaddr_nl *who,
 			return -1;
 	}
 
+	if (tb[IFLA_MASTER]) {
+		int master = *(int*)RTA_DATA(tb[IFLA_MASTER]);
+		if (filter.master > 0 && master != filter.master)
+			return -1;
+	}
+	else if (filter.master > 0)
+		return -1;
+
+	if (filter.kind) {
+		if (tb[IFLA_LINKINFO]) {
+			char *kind = parse_link_kind(tb[IFLA_LINKINFO]);
+
+			if (strcmp(kind, filter.kind))
+				return -1;
+		} else {
+			return -1;
+		}
+	}
+
 	if (n->nlmsg_type == RTM_DELLINK)
 		fprintf(fp, "Deleted ");
 
-- 
2.3.8 (Apple Git-58)
