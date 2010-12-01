From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH v1] iproute2: add IFLA_TC support to 'ip link'
Date: Wed, 01 Dec 2010 10:27:58 -0800
Message-ID: <20101201182758.3297.34345.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@infradead.org,
	eric.dumazet@gmail.com, davem@davemloft.net,
	john.r.fastabend@intel.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47937 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756069Ab0LASab (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Dec 2010 13:30:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to return IFLA_TC qos settings to the 'ip link'
command. The following sets the number of traffic classes
supported in HW and builds a priority map.

#ip link set eth3 tc num 8 map 0 1 2 3 4 5 6 7 0 0 0 0 0 0 0 0

With the output from 'ip link' showing maps for interfaces with
the ability to use HW traffic classes.

#ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:30:48:f0:fc:88 brdff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
    link/ether 00:30:48:f0:fc:89 brdff:ff:ff:ff:ff:ff
6: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc mq state DOWN qlen 1000
    link/ether 00:1b:21:55:23:58 brdff:ff:ff:ff:ff:ff
    tc 0:8
7: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
    link/ether 00:1b:21:55:23:59 brdff:ff:ff:ff:ff:ff
    tc 8:8 map: { 0 1 2 3 4 5 6 7 0 0 0 0 0 0 0 0 }
    txqs: (0:8) (8:16) (16:24) (24:32) (32:40) (40:48) (48:56) (56:64)

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/if_link.h |   51 ++++++++++++++++++++++++++++++++++++++
 ip/ipaddress.c          |   48 ++++++++++++++++++++++++++++++++++--
 ip/iplink.c             |   63 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 160 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index f5bb2dc..190c70d 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -116,6 +116,8 @@ enum {
 	IFLA_STATS64,
 	IFLA_VF_PORTS,
 	IFLA_PORT_SELF,
+	IFLA_AF_SPEC,
+	IFLA_TC,
 	__IFLA_MAX
 };
 
@@ -348,4 +350,53 @@ struct ifla_port_vsi {
 	__u8 pad[3];
 };
 
+/* HW QOS management section
+ *
+ *	Nested layout of set/get msg is:
+ *
+ *		[IFLA_TC]
+ *			[IFLA_TC_MAX_TC]
+ *			[IFLA_TC_NUM_TC]
+ *			[IFLA_TC_TXQS]
+ *				[IFLA_TC_TXQ]
+ *				...
+ *			[IFLA_TC_MAPS]
+ *				[IFLA_TC_MAP]
+ *				...
+ */
+enum {
+	IFLA_TC_UNSPEC,
+	IFLA_TC_TXMAX,
+	IFLA_TC_TXNUM,
+	IFLA_TC_TXQS,
+	IFLA_TC_MAPS,
+	__IFLA_TC_MAX,
+};
+#define IFLA_TC_MAX (__IFLA_TC_MAX - 1)
+
+struct ifla_tc_txq {
+	__u8 num;
+	__u16 count;
+	__u16 offset;
+};
+
+enum {
+	IFLA_TC_TXQ_UNSPEC,
+	IFLA_TC_TXQ,
+	__IFLA_TC_TCQ_MAX,
+};
+#define IFLA_TC_TXQS_MAX (__IFLA_TC_TCQ_MAX - 1)
+
+struct ifla_tc_map {
+	__u8 prio;
+	__u8 tc;
+};
+
+enum {
+	IFLA_TC_MAP_UNSPEC,
+	IFLA_TC_MAP,
+	__IFLA_TC_MAP_MAX,
+};
+#define IFLA_TC_MAP_MAX (__IFLA_TC_MAP_MAX - 1)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 19b3d6e..39b357f 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -152,6 +152,47 @@ static void print_queuelen(FILE *f, const char *name)
 		fprintf(f, "qlen %d", ifr.ifr_qlen);
 }
 
+static void print_tc_table(FILE *fp, struct rtattr *tb)
+{
+	struct rtattr *table[IFLA_TC_MAX+1];
+	struct rtattr *attr;
+	struct ifla_tc_map *map;
+	struct ifla_tc_txq *txq;
+	__u8 max, num;
+	int rem;
+
+	parse_rtattr_nested(table, IFLA_TC_MAX, tb);
+
+	if (table[IFLA_TC_MAX])
+		max = * (__u8 *) RTA_DATA(table[IFLA_TC_TXMAX]);
+	if (table[IFLA_TC_MAX])
+		num = * (__u8 *) RTA_DATA(table[IFLA_TC_TXNUM]);
+
+
+	fprintf(fp, "\n    tc %d:%d ", num, max);
+
+	if (!num)
+		return;
+
+	rem = RTA_PAYLOAD(table[IFLA_TC_MAPS]);
+	attr = RTA_DATA(table[IFLA_TC_MAPS]);
+	fprintf(fp, "map: {");
+	for (; RTA_OK(attr, rem); attr = RTA_NEXT(attr, rem)) {
+		map = RTA_DATA(attr);
+		fprintf(fp, " %d", map->tc);
+	}
+	fprintf(fp, " }");
+
+	rem = RTA_PAYLOAD(table[IFLA_TC_TXQS]);
+	attr = RTA_DATA(table[IFLA_TC_TXQS]);
+	fprintf(fp, "\n    txqs: ");
+	for (; RTA_OK(attr, rem); attr = RTA_NEXT(attr, rem)) {
+		txq = RTA_DATA(attr);
+		fprintf(fp, "(%d:%d) ",
+			txq->offset, txq->offset + txq->count);
+	}
+}
+
 static void print_linktype(FILE *fp, struct rtattr *tb)
 {
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
@@ -299,8 +340,8 @@ int print_linkinfo(const struct sockaddr_nl *who,
 			if (ifi->ifi_flags&IFF_POINTOPOINT)
 				fprintf(fp, " peer ");
 			else
-				fprintf(fp, " brd ");
-			fprintf(fp, "%s", ll_addr_n2a(RTA_DATA(tb[IFLA_BROADCAST]),
+				fprintf(fp, " brd");
+			fprintf(fp, "%s ", ll_addr_n2a(RTA_DATA(tb[IFLA_BROADCAST]),
 						      RTA_PAYLOAD(tb[IFLA_BROADCAST]),
 						      ifi->ifi_type,
 						      b1, sizeof(b1)));
@@ -421,6 +462,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
 			print_vfinfo(fp, i);
 	}
 
+	if (tb[IFLA_TC])
+		print_tc_table(fp, tb[IFLA_TC]);
+
 	fprintf(fp, "\n");
 	fflush(fp);
 	return 0;
diff --git a/ip/iplink.c b/ip/iplink.c
index cb2c4f5..fa9236e 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -71,6 +71,8 @@ void iplink_usage(void)
 	fprintf(stderr, "	                  [ vf NUM [ mac LLADDR ]\n");
 	fprintf(stderr, "				   [ vlan VLANID [ qos VLAN-QOS ] ]\n");
 	fprintf(stderr, "				   [ rate TXRATE ] ] \n");
+	fprintf(stderr, "	                  [ tc [ num NUMTC ]\n");
+	fprintf(stderr, "			       [ map PRIO1 PRIO2 ... ] ]\n");
 	fprintf(stderr, "       ip link show [ DEVICE ]\n");
 
 	if (iplink_have_newlink()) {
@@ -242,6 +244,58 @@ int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 	return 0;
 }
 
+int iplink_parse_tc(int *argcp, char ***argvp, struct iplink_req *req)
+{
+	int argc = *argcp;
+	char **argv = *argvp;
+
+	while (NEXT_ARG_OK()) {
+		NEXT_ARG();
+		if (matches(*argv, "num") == 0) {
+			__u8 numtc;
+			NEXT_ARG();
+			if (get_u8(&numtc,  *argv, 0))
+				invarg("Invalid \"num\" value\n", *argv);
+			addattr_l(&req->n, sizeof(*req), IFLA_TC_TXNUM,
+				  &numtc, 1);
+		}
+
+		if (matches(*argv, "map") == 0) {
+			struct ifla_tc_map map;
+			struct rtattr *maps;
+			int i;
+
+			maps = addattr_nest(&req->n, sizeof(*req),
+					      IFLA_TC_MAPS);
+
+			for (i = 0; NEXT_ARG_OK(); i++) {
+				NEXT_ARG(); 
+				if (i > 15)
+					invarg("\"map\" value exceeds "
+					       "prio map\n", *argv);
+				map.prio = i;
+				if (get_u8(&map.tc,  *argv, 0))
+					invarg("Invalid \"map\" value\n", *argv);
+
+				if (map.tc > 15)
+					invarg("\"map\" value exceeds max tc",
+					       *argv);
+
+				addattr_l(&req->n, sizeof(*req), IFLA_TC_MAP,
+				  	  &map, sizeof(map));
+			}
+
+			addattr_nest_end(&req->n, maps);
+		}
+	}
+
+	if (argc == *argcp)
+		incomplete_command();
+	*argcp = argc;
+	*argvp = argv;
+	return 0;
+}
+
 
 int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		char **name, char **type, char **link, char **dev)
@@ -361,6 +415,15 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			if (len < 0)
 				return -1;
 			addattr_nest_end(&req->n, vflist);
+		} else if (strcmp(*argv, "tc") == 0) {
+			struct rtattr *table;
+
+			table = addattr_nest(&req->n, sizeof(*req),
+					     IFLA_TC);
+			len = iplink_parse_tc(&argc, &argv, req);
+			if (len < 0)
+				return -1;
+			addattr_nest_end(&req->n, table);
 #ifdef IFF_DYNAMIC
 		} else if (matches(*argv, "dynamic") == 0) {
 			NEXT_ARG();

