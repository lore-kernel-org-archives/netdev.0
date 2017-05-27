From: David Ahern <dsahern@gmail.com>
Subject: [PATCH iproute2 1/4] ip address: Export ip_linkaddr_list
Date: Sat, 27 May 2017 17:34:47 -0600
Message-ID: <20170527233450.58015-2-dsahern@gmail.com>
References: <20170527233450.58015-1-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36668 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750751AbdE0Xe4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 19:34:56 -0400
Received: by mail-pg0-f65.google.com with SMTP id h64so2561388pge.3
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 16:34:56 -0700 (PDT)
In-Reply-To: <20170527233450.58015-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipaddr_list_flush_or_save generates a list of nlmsg's for links and
optionally for addresses. Move the code into ip_linkaddr_list and
export it along with the supporting infrastructure.

API to use this function is:
        struct nlmsg_chain linfo = { NULL, NULL};
        struct nlmsg_chain ainfo = { NULL, NULL};

        ip_linkaddr_list(family, filter_req, &linfo, &ainfo);

        ... error checking and code looping over linfo/ainfo ...

        free_nlmsg_chain(&linfo);
        free_nlmsg_chain(&ainfo);

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/libnetlink.h | 10 ++++++
 ip/ip_common.h       |  4 +++
 ip/ipaddress.c       | 87 +++++++++++++++++++++++++++++-----------------------
 3 files changed, 63 insertions(+), 38 deletions(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index c43ab0a2d9d9..643c3bc56929 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -25,6 +25,16 @@ struct rtnl_handle {
 	int			flags;
 };
 
+struct nlmsg_list {
+	struct nlmsg_list *next;
+	struct nlmsghdr   h;
+};
+
+struct nlmsg_chain {
+	struct nlmsg_list *head;
+	struct nlmsg_list *tail;
+};
+
 extern int rcvbuf;
 
 int rtnl_open(struct rtnl_handle *rth, unsigned int subscriptions)
diff --git a/ip/ip_common.h b/ip/ip_common.h
index 202fc399e61a..450b45ac2b60 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -65,6 +65,10 @@ int do_seg6(int argc, char **argv);
 int iplink_get(unsigned int flags, char *name, __u32 filt_mask);
 int iplink_ifla_xstats(int argc, char **argv);
 
+int ip_linkaddr_list(int family, req_filter_fn_t filter_fn,
+		     struct nlmsg_chain *linfo, struct nlmsg_chain *ainfo);
+void free_nlmsg_chain(struct nlmsg_chain *info);
+
 static inline int rtm_get_table(struct rtmsg *r, struct rtattr **tb)
 {
 	__u32 table = r->rtm_table;
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index b8d9c7d917fe..c805b929134d 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1211,16 +1211,6 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	return 0;
 }
 
-struct nlmsg_list {
-	struct nlmsg_list *next;
-	struct nlmsghdr	  h;
-};
-
-struct nlmsg_chain {
-	struct nlmsg_list *head;
-	struct nlmsg_list *tail;
-};
-
 static int print_selected_addrinfo(struct ifinfomsg *ifi,
 				   struct nlmsg_list *ainfo, FILE *fp)
 {
@@ -1371,7 +1361,7 @@ static int ipaddr_restore(void)
 	exit(rtnl_from_file(stdin, &restore_handler, NULL));
 }
 
-static void free_nlmsg_chain(struct nlmsg_chain *info)
+void free_nlmsg_chain(struct nlmsg_chain *info)
 {
 	struct nlmsg_list *l, *n;
 
@@ -1534,10 +1524,43 @@ static int iplink_filter_req(struct nlmsghdr *nlh, int reqlen)
 	return 0;
 }
 
+/* fills in linfo with link data and optionally ainfo with address info
+ * caller can walk lists as desired and must call free_nlmsg_chain for
+ * both when done
+ */
+int ip_linkaddr_list(int family, req_filter_fn_t filter_fn,
+		     struct nlmsg_chain *linfo, struct nlmsg_chain *ainfo)
+{
+	if (rtnl_wilddump_req_filter_fn(&rth, preferred_family, RTM_GETLINK,
+					filter_fn) < 0) {
+		perror("Cannot send dump request");
+		return 1;
+	}
+
+	if (rtnl_dump_filter(&rth, store_nlmsg, linfo) < 0) {
+		fprintf(stderr, "Dump terminated\n");
+		return 1;
+	}
+
+	if (ainfo) {
+		if (rtnl_wilddump_request(&rth, family, RTM_GETADDR) < 0) {
+			perror("Cannot send dump request");
+			return 1;
+		}
+
+		if (rtnl_dump_filter(&rth, store_nlmsg, ainfo) < 0) {
+			fprintf(stderr, "Dump terminated\n");
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
 static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 {
 	struct nlmsg_chain linfo = { NULL, NULL};
-	struct nlmsg_chain ainfo = { NULL, NULL};
+	struct nlmsg_chain _ainfo = { NULL, NULL}, *ainfo = NULL;
 	struct nlmsg_list *l;
 	char *filter_dev = NULL;
 	int no_link = 0;
@@ -1714,33 +1737,19 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 		exit(0);
 	}
 
-	if (rtnl_wilddump_req_filter_fn(&rth, preferred_family, RTM_GETLINK,
-					iplink_filter_req) < 0) {
-		perror("Cannot send dump request");
-		exit(1);
-	}
-
-	if (rtnl_dump_filter(&rth, store_nlmsg, &linfo) < 0) {
-		fprintf(stderr, "Dump terminated\n");
-		exit(1);
-	}
-
 	if (filter.family != AF_PACKET) {
+		ainfo = &_ainfo;
+
 		if (filter.oneline)
 			no_link = 1;
+	}
 
-		if (rtnl_wilddump_request(&rth, filter.family, RTM_GETADDR) < 0) {
-			perror("Cannot send dump request");
-			exit(1);
-		}
-
-		if (rtnl_dump_filter(&rth, store_nlmsg, &ainfo) < 0) {
-			fprintf(stderr, "Dump terminated\n");
-			exit(1);
-		}
+	if (ip_linkaddr_list(filter.family, iplink_filter_req,
+			     &linfo, ainfo) != 0)
+		goto out;
 
-		ipaddr_filter(&linfo, &ainfo);
-	}
+	if (filter.family != AF_PACKET)
+		ipaddr_filter(&linfo, ainfo);
 
 	for (l = linfo.head; l; l = l->next) {
 		int res = 0;
@@ -1750,20 +1759,22 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 			if (print_linkinfo_brief(NULL, &l->h, stdout) == 0)
 				if (filter.family != AF_PACKET)
 					print_selected_addrinfo(ifi,
-								ainfo.head,
+								ainfo->head,
 								stdout);
 		} else if (no_link ||
-			 (res = print_linkinfo(NULL, &l->h, stdout)) >= 0) {
+			  (res = print_linkinfo(NULL, &l->h, stdout)) >= 0) {
 			if (filter.family != AF_PACKET)
 				print_selected_addrinfo(ifi,
-							ainfo.head, stdout);
+							ainfo->head, stdout);
 			if (res > 0 && !do_link && show_stats)
 				print_link_stats(stdout, &l->h);
 		}
 	}
 	fflush(stdout);
 
-	free_nlmsg_chain(&ainfo);
+out:
+	if (ainfo)
+		free_nlmsg_chain(ainfo);
 	free_nlmsg_chain(&linfo);
 
 	return 0;
-- 
2.11.0 (Apple Git-81)
