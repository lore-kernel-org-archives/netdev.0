From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next iproute2 v2] iproute2: allow to change slave options via type_slave
Date: Wed,  3 Sep 2014 17:57:30 +0200
Message-ID: <1409759850-15812-1-git-send-email-nikolay@redhat.com>
References: <20140903150215.GA1843@nanopsycho.lan>
Cc: jiri@resnulli.us, stephen@networkplumber.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59044 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756100AbaICP6g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 11:58:36 -0400
In-Reply-To: <20140903150215.GA1843@nanopsycho.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary changes to allow altering a slave device's
options via ip link set <device> type <master type>_slave specific-option.
It also adds support to set the bonding slaves' queue_id.

Example:
 ip link set eth0 type bond_slave queue_id 10

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v2: change the usage from <master type>_slave to bond_slave as Jiri suggested

 ip/iplink.c            | 22 +++++++++++++++++++---
 ip/iplink_bond_slave.c | 19 +++++++++++++++++++
 2 files changed, 38 insertions(+), 3 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 1a907d998a87..0992923c83bc 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -88,7 +88,8 @@ void iplink_usage(void)
 		fprintf(stderr, "\n");
 		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n");
 		fprintf(stderr, "          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan |\n");
-		fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti | nlmon }\n");
+		fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti | nlmon |\n");
+		fprintf(stderr, "          bond_slave }\n");
 	}
 	exit(-1);
 }
@@ -697,14 +698,29 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 
 	if (type) {
 		struct rtattr *linkinfo = NLMSG_TAIL(&req.n);
+		char slavebuf[128], *ulinep = strchr(type, '_');
+		int iflatype;
+
 		addattr_l(&req.n, sizeof(req), IFLA_LINKINFO, NULL, 0);
 		addattr_l(&req.n, sizeof(req), IFLA_INFO_KIND, type,
 			 strlen(type));
 
-		lu = get_link_kind(type);
+		if (ulinep && !strcmp(ulinep, "_slave")) {
+			strncpy(slavebuf, type, sizeof(slavebuf));
+			slavebuf[sizeof(slavebuf) - 1] = '\0';
+			ulinep = strchr(slavebuf, '_');
+			/* check in case it was after sizeof(slavebuf) - 1*/
+			if (ulinep)
+				*ulinep = '\0';
+			lu = get_link_slave_kind(slavebuf);
+			iflatype = IFLA_INFO_SLAVE_DATA;
+		} else {
+			lu = get_link_kind(type);
+			iflatype = IFLA_INFO_DATA;
+		}
 		if (lu && argc) {
 			struct rtattr * data = NLMSG_TAIL(&req.n);
-			addattr_l(&req.n, sizeof(req), IFLA_INFO_DATA, NULL, 0);
+			addattr_l(&req.n, sizeof(req), iflatype, NULL, 0);
 
 			if (lu->parse_opt &&
 			    lu->parse_opt(lu, argc, argv, &req.n))
diff --git a/ip/iplink_bond_slave.c b/ip/iplink_bond_slave.c
index 8f3fc6cec6fa..aacba14aef9c 100644
--- a/ip/iplink_bond_slave.c
+++ b/ip/iplink_bond_slave.c
@@ -80,10 +80,29 @@ static void bond_slave_print_opt(struct link_util *lu, FILE *f, struct rtattr *t
 			rta_getattr_u16(tb[IFLA_BOND_SLAVE_AD_AGGREGATOR_ID]));
 }
 
+static int bond_slave_parse_opt(struct link_util *lu, int argc, char **argv,
+				struct nlmsghdr *n)
+{
+	__u16 queue_id;
+
+	while (argc > 0) {
+		if (matches(*argv, "queue_id") == 0) {
+			NEXT_ARG();
+			if (get_u16(&queue_id, *argv, 0))
+				invarg("queue_id is invalid", *argv);
+			addattr16(n, 1024, IFLA_BOND_SLAVE_QUEUE_ID, queue_id);
+		}
+		argc--, argv++;
+	}
+
+	return 0;
+}
+
 struct link_util bond_slave_link_util = {
 	.id		= "bond",
 	.maxattr	= IFLA_BOND_SLAVE_MAX,
 	.print_opt	= bond_slave_print_opt,
+	.parse_opt	= bond_slave_parse_opt,
 	.slave		= true,
 };
 
-- 
1.9.3
