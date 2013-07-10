From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH] ip: add support for queue attributes
Date: Wed, 10 Jul 2013 07:13:18 -0700
Message-ID: <20130710141312.7205.25585.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	therbert@google.com
To: stephen@networkplumber.org, ben@decadent.org.uk,
	jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:64727 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754500Ab3GJONi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 10:13:38 -0400
Received: by mail-oa0-f51.google.com with SMTP id i4so9507752oah.24
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 07:13:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Test patch to demonstrat and test queue attributes. The 'show'
formatting could likely be improved.

# ./ip/ip link set dev p3p2 queue 1 rate 1000
# ./ip/ip link set dev p3p2 queue 5 rate 1000
# ./ip/ip link show dev p3p2
4: p3p2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT qlen 1000
    link/ether 00:1b:21:69:9f:09 brd ff:ff:ff:ff:ff:ff queues:  (1: rate 1000Mbps) (5: rate 1000Mbps)

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/if_link.h |   24 +++++++++++++++++++++
 ip/ipaddress.c          |   26 +++++++++++++++++++++++
 ip/iplink.c             |   54 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 104 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 965dc9f..dcb2cea 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -143,6 +143,7 @@ enum {
 	IFLA_NUM_TX_QUEUES,
 	IFLA_NUM_RX_QUEUES,
 	IFLA_CARRIER,
+	IFLA_QUEUE_ATTRIBS,
 	__IFLA_MAX
 };
 
@@ -432,6 +433,29 @@ struct ifla_port_vsi {
 	__u8 pad[3];
 };
 
+/* Queue Attributes management
+ *	Netsted layout of queue attributes is:
+ *	[IFLA_QUEUE_ATTRIBS]
+ *		[IFLA_QUEUE_ATTRIB]
+ *			[IFLA_QUEUE_INDEX]	<required>
+ *			[IFLA_QUEUE_RATE]	<optional>
+ *		[IFLA_QUEUE_ATTRIB]
+ *			[...]
+ */
+enum {
+	IFLA_QUEUE_ATTRIB_UNSPEC,
+	IFLA_QUEUE_ATTRIB,			/* nest */
+	__IFLA_QUEUE_ATTRIB_MAX,
+};
+#define IFLA_QUEUE_ATTRIB_MAX (__IFLA_QUEUE_ATTRIB_MAX - 1)
+
+enum {
+	IFLA_QUEUE_UNSPEC,
+	IFLA_QUEUE_INDEX,		/* __u32 */
+	IFLA_QUEUE_RATE,		/* __u32 */
+	__IFLA_QUEUE_MAX,
+};
+#define IFLA_QUEUE_MAX (__IFLA_QUEUE_MAX - 1)
 
 /* IPoIB section */
 
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 5b9a438..5e55798 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -272,6 +272,23 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 	}
 }
 
+static void print_queue_attribs(FILE *fp, struct rtattr *queue)
+{
+	struct rtattr *q[IFLA_QUEUE_MAX+1];
+
+	parse_rtattr_nested(q, IFLA_QUEUE_MAX, queue);
+
+	if (q[IFLA_QUEUE_INDEX]) {
+		int index = *(int *) RTA_DATA(q[IFLA_QUEUE_INDEX]);
+		int rate = 0;
+
+		if (q[IFLA_QUEUE_RATE])
+			rate = *(int *) RTA_DATA(q[IFLA_QUEUE_RATE]);
+
+		fprintf(fp, " (%u: rate %uMbps)", index, rate);
+	}
+}
+
 static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s) {
 	fprintf(fp, "%s", _SL_);
 	fprintf(fp, "    RX: bytes  packets  errors  dropped overrun mcast   %s%s",
@@ -487,6 +504,15 @@ int print_linkinfo(const struct sockaddr_nl *who,
 			print_vfinfo(fp, i);
 	}
 
+	if (do_link && tb[IFLA_QUEUE_ATTRIBS]) {
+		struct rtattr *i, *queue_attribs = tb[IFLA_QUEUE_ATTRIBS];
+		int rem = RTA_PAYLOAD(queue_attribs);
+
+		fprintf(fp, " queues: ");
+		for (i = RTA_DATA(queue_attribs); RTA_OK(i, rem); i = RTA_NEXT(i, rem))
+			print_queue_attribs(fp, i);
+	}
+
 	fprintf(fp, "\n");
 	fflush(fp);
 	return 0;
diff --git a/ip/iplink.c b/ip/iplink.c
index dc98019..ecae3b7 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -79,6 +79,7 @@ void iplink_usage(void)
 	fprintf(stderr, "				   [ spoofchk { on | off} ] ] \n");
 	fprintf(stderr, "			  [ master DEVICE ]\n");
 	fprintf(stderr, "			  [ nomaster ]\n");
+	fprintf(stderr, "			  [ queues QUEUE [ rate RATE ]\n");
 	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up]\n");
 
 	if (iplink_have_newlink()) {
@@ -194,6 +195,45 @@ struct iplink_req {
 	char			buf[1024];
 };
 
+static int iplink_parse_queues(int index, int *argcp, char ***argvp,
+			       struct iplink_req *req)
+{
+	struct rtattr *queue;
+	char **argv = *argvp;
+	int argc = *argcp;
+	int rate = -1;
+
+	queue = addattr_nest(&req->n, sizeof(*req), IFLA_QUEUE_ATTRIB);
+	addattr_l(&req->n, sizeof(*req), IFLA_QUEUE_INDEX, &index, 4);
+
+	while (NEXT_ARG_OK()) {
+		NEXT_ARG();
+		if (matches(*argv, "rate") == 0) {
+
+			NEXT_ARG();
+			if (rate != -1)
+				duparg("rate", *argv);
+			if (get_integer(&rate, *argv, 0))
+				invarg("Invalid \"rate\" value\n", *argv);
+			addattr_l(&req->n, sizeof(*req), IFLA_QUEUE_RATE,
+				  &rate, 4);
+		} else {
+			/* rewind arg */
+			PREV_ARG();
+			break;
+		}
+	}
+
+	if (argc == *argcp)
+		incomplete_command();
+
+	addattr_nest_end(&req->n, queue);
+
+	*argcp = argc;
+	*argvp = argv;
+	return 0;
+}
+
 static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 			   struct iplink_req *req)
 {
@@ -466,6 +506,20 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 				invarg("Invalid \"numrxqueues\" value\n", *argv);
 			addattr_l(&req->n, sizeof(*req), IFLA_NUM_RX_QUEUES,
 				  &numrxqueues, 4);
+		} else if (matches(*argv, "queues") == 0) {
+			struct rtattr *queues;
+			int index;
+
+			NEXT_ARG();
+			if (get_integer(&index,  *argv, 0)) {
+				invarg("Invalid \"index\" value\n", *argv);
+			}
+			queues = addattr_nest(&req->n, sizeof(*req),
+					      IFLA_QUEUE_ATTRIBS);
+			len = iplink_parse_queues(index, &argc, &argv, req);
+			if (len < 0)
+				return -1;
+			addattr_nest_end(&req->n, queues);
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
