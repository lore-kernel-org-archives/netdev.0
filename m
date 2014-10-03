From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH iproute2] ip address: print stats with -s
Date: Fri,  3 Oct 2014 15:25:02 +0200
Message-ID: <27994ada1acf56bc276a97a7d6c6a19131d84be1.1412342498.git.jbenc@redhat.com>
Cc: netdev@vger.kernel.org, Pavel Simerda <psimerda@redhat.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40487 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751462AbaJCN2Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 09:28:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make ip address show accept the -s option similarly to ip link. This creates
an one command replacement for "ifconfig -a" useful for people who still
stay with ifconfig because of this feature.

Print the stats as the last thing for the interface. This requires some code
shuffling.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 ip/ipaddress.c | 43 +++++++++++++++++++++++++++++++------------
 1 file changed, 31 insertions(+), 12 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 245df39179a9..45729d890abd 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -322,7 +322,6 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
                                const struct rtattr *carrier_changes)
 {
-	fprintf(fp, "%s", _SL_);
 	fprintf(fp, "    RX: bytes  packets  errors  dropped overrun mcast   %s%s",
 		s->rx_compressed ? "compressed" : "", _SL_);
 	fprintf(fp, "    %-10"PRIu64" %-8"PRIu64" %-7"PRIu64" %-7"PRIu64" %-7"PRIu64" %-7"PRIu64"",
@@ -375,10 +374,9 @@ static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
 	}
 }
 
-static void print_link_stats(FILE *fp, const struct rtnl_link_stats *s,
-			     const struct rtattr *carrier_changes)
+static void print_link_stats32(FILE *fp, const struct rtnl_link_stats *s,
+			       const struct rtattr *carrier_changes)
 {
-	fprintf(fp, "%s", _SL_);
 	fprintf(fp, "    RX: bytes  packets  errors  dropped overrun mcast   %s%s",
 		s->rx_compressed ? "compressed" : "", _SL_);
 	fprintf(fp, "    %-10u %-8u %-7u %-7u %-7u %-7u",
@@ -425,6 +423,27 @@ static void print_link_stats(FILE *fp, const struct rtnl_link_stats *s,
 	}
 }
 
+static void __print_link_stats(FILE *fp, struct rtattr **tb)
+{
+	if (tb[IFLA_STATS64])
+		print_link_stats64(fp, RTA_DATA(tb[IFLA_STATS64]),
+					tb[IFLA_CARRIER_CHANGES]);
+	else if (tb[IFLA_STATS])
+		print_link_stats32(fp, RTA_DATA(tb[IFLA_STATS]),
+					tb[IFLA_CARRIER_CHANGES]);
+}
+
+static void print_link_stats(FILE *fp, struct nlmsghdr *n)
+{
+	struct ifinfomsg *ifi = NLMSG_DATA(n);
+	struct rtattr * tb[IFLA_MAX+1];
+
+	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi),
+		     n->nlmsg_len - NLMSG_LENGTH(sizeof(*ifi)));
+	__print_link_stats(fp, tb);
+	fprintf(fp, "%s", _SL_);
+}
+
 int print_linkinfo(const struct sockaddr_nl *who,
 		   struct nlmsghdr *n, void *arg)
 {
@@ -550,12 +569,8 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	}
 
 	if (do_link && show_stats) {
-		if (tb[IFLA_STATS64])
-			print_link_stats64(fp, RTA_DATA(tb[IFLA_STATS64]),
-					   tb[IFLA_CARRIER_CHANGES]);
-		else if (tb[IFLA_STATS])
-			print_link_stats(fp, RTA_DATA(tb[IFLA_STATS]),
-					 tb[IFLA_CARRIER_CHANGES]);
+		fprintf(fp, "%s", _SL_);
+		__print_link_stats(fp, tb);
 	}
 
 	if (do_link && tb[IFLA_VFINFO_LIST] && tb[IFLA_NUM_VF]) {
@@ -567,7 +582,7 @@ int print_linkinfo(const struct sockaddr_nl *who,
 
 	fprintf(fp, "\n");
 	fflush(fp);
-	return 0;
+	return 1;
 }
 
 static int flush_update(void)
@@ -1282,11 +1297,15 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 	}
 
 	for (l = linfo.head; l; l = l->next) {
-		if (no_link || print_linkinfo(NULL, &l->h, stdout) == 0) {
+		int res = 0;
+
+		if (no_link || (res = print_linkinfo(NULL, &l->h, stdout)) >= 0) {
 			struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
 			if (filter.family != AF_PACKET)
 				print_selected_addrinfo(ifi->ifi_index,
 							ainfo.head, stdout);
+			if (res > 0 && !do_link && show_stats)
+				print_link_stats(stdout, &l->h);
 		}
 	}
 	fflush(stdout);
-- 
1.8.3.1
