From: Kusanagi Kouichi <slash@ac.auone-net.jp>
Subject: [PATCH iproute2] veth: Handle flags correctry
Date: Wed, 2 Apr 2014 01:09:18 +0900
Message-ID: <533ae4ae0008a03800006db900006dbec00001330dca@amlmta034.auone-net.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ae2-f130.auone-net.jp ([111.87.219.130]:43664 "EHLO
	dmta01.auone-net.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752702AbaDAQUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 12:20:17 -0400
Received: from amlmta034.auone-net.jp (amlmta034-MM [10.188.22.53])
	by dmta01.auone-net.jp (au one net mail) with ESMTP id DBFC456035F
	for <netdev@vger.kernel.org>; Wed,  2 Apr 2014 01:09:18 +0900 (JST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flags for a peer override flags for the other and not used for the
peer.

before:
# ip link add up type veth peer down multicast off
# ip link
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: veth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 2e:5c:cd:f5:63:d2 brd ff:ff:ff:ff:ff:ff
3: veth1: <BROADCAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 72:b0:fa:1e:76:7a brd ff:ff:ff:ff:ff:ff

after:
# ip link add up type veth peer down multicast off
# ip link
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: veth0: <BROADCAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 6e:db:03:b3:bd:ff brd ff:ff:ff:ff:ff:ff
3: veth1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN mode DEFAULT group default qlen 1000
    link/ether a6:62:d9:84:f0:73 brd ff:ff:ff:ff:ff:ff

Signed-off-by: Kusanagi Kouichi <slash@ac.auone-net.jp>
---
 ip/link_veth.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/ip/link_veth.c b/ip/link_veth.c
index 3cbeb54..1196a1b 100644
--- a/ip/link_veth.c
+++ b/ip/link_veth.c
@@ -34,12 +34,20 @@ static int veth_parse_opt(struct link_util *lu, int argc, char **argv,
 	int err, len;
 	struct rtattr * data;
 	int group;
+	struct ifinfomsg *ifm, *peer_ifm;
+	unsigned int ifi_flags, ifi_change;
 
 	if (strcmp(argv[0], "peer") != 0) {
 		usage();
 		return -1;
 	}
 
+	ifm = NLMSG_DATA(hdr);
+	ifi_flags = ifm->ifi_flags;
+	ifi_change = ifm->ifi_change;
+	ifm->ifi_flags = 0;
+	ifm->ifi_change = 0;
+
 	data = NLMSG_TAIL(hdr);
 	addattr_l(hdr, 1024, VETH_INFO_PEER, NULL, 0);
 
@@ -57,10 +65,12 @@ static int veth_parse_opt(struct link_util *lu, int argc, char **argv,
 		addattr_l(hdr, 1024, IFLA_IFNAME, name, len);
 	}
 
-	if (index) {
-		struct ifinfomsg *ifi = (struct ifinfomsg *)(data + 1);
-		ifi->ifi_index = index;
-	}
+	peer_ifm = RTA_DATA(data);
+	peer_ifm->ifi_index = index;
+	peer_ifm->ifi_flags = ifm->ifi_flags;
+	peer_ifm->ifi_change = ifm->ifi_change;
+	ifm->ifi_flags = ifi_flags;
+	ifm->ifi_change = ifi_change;
 
 	if (group != -1)
 		addattr32(hdr, 1024, IFLA_GROUP, group);
-- 
1.9.1
