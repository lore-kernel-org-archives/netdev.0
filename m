From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] iproute: Add ability to save, restore and show the interfaces'
 addresses (resend)
Date: Tue, 11 Sep 2012 19:47:00 +0400
Message-ID: <504F5CF4.1040202@parallels.com>
References: <50121F4D.8090606@parallels.com> <50121FB0.6060200@parallels.com> <5012211A.4040307@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:41656 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752702Ab2IKPrG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2012 11:47:06 -0400
In-Reply-To: <5012211A.4040307@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This functionality is required by checkpoint-restore project. Since the
dump and restore for routes is already done in ip tool it's naturally to
dump and restore addresses in the ip tool as well.

The implementation logic is the same as for the respective one for routes.
The magic number digits are taken from the Seattle coordinates.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index cbff143..6c11ce4 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -34,6 +34,11 @@
 #include "ll_map.h"
 #include "ip_common.h"
 
+enum {
+	IPADD_LIST,
+	IPADD_FLUSH,
+	IPADD_SAVE,
+};
 
 static struct
 {
@@ -65,8 +70,9 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip addr {add|change|replace} IFADDR dev STRING [ LIFETIME ]\n");
 	fprintf(stderr, "                                                      [ CONFFLAG-LIST ]\n");
 	fprintf(stderr, "       ip addr del IFADDR dev STRING\n");
-	fprintf(stderr, "       ip addr {show|flush} [ dev STRING ] [ scope SCOPE-ID ]\n");
+	fprintf(stderr, "       ip addr {show|save|flush} [ dev STRING ] [ scope SCOPE-ID ]\n");
 	fprintf(stderr, "                            [ to PREFIX ] [ FLAG-LIST ] [ label PATTERN ]\n");
+	fprintf(stderr, "       ip addr {showdump|restore}\n");
 	fprintf(stderr, "IFADDR := PREFIX | ADDR peer PREFIX\n");
 	fprintf(stderr, "          [ broadcast ADDR ] [ anycast ADDR ]\n");
 	fprintf(stderr, "          [ label STRING ] [ scope SCOPE-ID ]\n");
@@ -768,6 +774,99 @@ static int store_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	return 0;
 }
 
+static __u32 ipadd_dump_magic = 0x47361222;
+
+static int ipadd_save_prep(void)
+{
+	int ret;
+
+	if (isatty(STDOUT_FILENO)) {
+		fprintf(stderr, "Not sending binary stream to stdout\n");
+		return -1;
+	}
+
+	ret = write(STDOUT_FILENO, &ipadd_dump_magic, sizeof(ipadd_dump_magic));
+	if (ret != sizeof(ipadd_dump_magic)) {
+		fprintf(stderr, "Can't write magic to dump file\n");
+		return -1;
+	}
+
+	return 0;
+}
+
+static int ipadd_dump_check_magic(void)
+{
+	int ret;
+	__u32 magic = 0;
+
+	if (isatty(STDIN_FILENO)) {
+		fprintf(stderr, "Can't restore addr dump from a terminal\n");
+		return -1;
+	}
+
+	ret = fread(&magic, sizeof(magic), 1, stdin);
+	if (magic != ipadd_dump_magic) {
+		fprintf(stderr, "Magic mismatch (%d elems, %x magic)\n", ret, magic);
+		return -1;
+	}
+
+	return 0;
+}
+
+static int save_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
+		       void *arg)
+{
+	int ret;
+
+	ret = write(STDOUT_FILENO, n, n->nlmsg_len);
+	if ((ret > 0) && (ret != n->nlmsg_len)) {
+		fprintf(stderr, "Short write while saving nlmsg\n");
+		ret = -EIO;
+	}
+
+	return ret == n->nlmsg_len ? 0 : ret;
+}
+
+static int show_handler(const struct sockaddr_nl *nl, struct nlmsghdr *n, void *arg)
+{
+	struct ifaddrmsg *ifa = NLMSG_DATA(n);
+
+	printf("if%d:\n", ifa->ifa_index);
+	print_addrinfo(NULL, n, stdout);
+	return 0;
+}
+
+static int ipaddr_showdump(void)
+{
+	if (ipadd_dump_check_magic())
+		exit(-1);
+
+	exit(rtnl_from_file(stdin, &show_handler, NULL));
+}
+
+static int restore_handler(const struct sockaddr_nl *nl, struct nlmsghdr *n, void *arg)
+{
+	int ret;
+
+	n->nlmsg_flags |= NLM_F_REQUEST | NLM_F_CREATE | NLM_F_ACK;
+
+	ll_init_map(&rth);
+
+	ret = rtnl_talk(&rth, n, 0, 0, n);
+	if ((ret < 0) && (errno == EEXIST))
+		ret = 0;
+
+	return ret;
+}
+
+static int ipaddr_restore(void)
+{
+	if (ipadd_dump_check_magic())
+		exit(-1);
+
+	exit(rtnl_from_file(stdin, &restore_handler, NULL));
+}
+
 static void free_nlmsg_chain(struct nlmsg_chain *info)
 {
 	struct nlmsg_list *l, *n;
@@ -902,7 +1001,7 @@ static int ipaddr_flush(void)
 	return 1;
 }
 
-static int ipaddr_list_or_flush(int argc, char **argv, int flush)
+static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 {
 	struct nlmsg_chain linfo = { NULL, NULL};
 	struct nlmsg_chain ainfo = { NULL, NULL};
@@ -918,7 +1017,7 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 
 	filter.group = INIT_NETDEV_GROUP;
 
-	if (flush) {
+	if (action == IPADD_FLUSH) {
 		if (argc <= 0) {
 			fprintf(stderr, "Flush requires arguments.\n");
 
@@ -1005,9 +1104,26 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 		}
 	}
 
-	if (flush)
+	if (action == IPADD_FLUSH)
 		return ipaddr_flush();
 
+	if (action == IPADD_SAVE) {
+		if (ipadd_save_prep())
+			exit(1);
+
+		if (rtnl_wilddump_request(&rth, preferred_family, RTM_GETADDR) < 0) {
+			perror("Cannot send dump request");
+			exit(1);
+		}
+
+		if (rtnl_dump_filter(&rth, save_nlmsg, stdout) < 0) {
+			fprintf(stderr, "Save terminated\n");
+			exit(1);
+		}
+
+		exit(0);
+	}
+
 	if (rtnl_wilddump_request(&rth, preferred_family, RTM_GETLINK) < 0) {
 		perror("Cannot send dump request");
 		exit(1);
@@ -1055,7 +1171,7 @@ int ipaddr_list_link(int argc, char **argv)
 {
 	preferred_family = AF_PACKET;
 	do_link = 1;
-	return ipaddr_list_or_flush(argc, argv, 0);
+	return ipaddr_list_flush_or_save(argc, argv, IPADD_LIST);
 }
 
 void ipaddr_reset_filter(int oneline)
@@ -1271,7 +1387,7 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 int do_ipaddr(int argc, char **argv)
 {
 	if (argc < 1)
-		return ipaddr_list_or_flush(0, NULL, 0);
+		return ipaddr_list_flush_or_save(0, NULL, IPADD_LIST);
 	if (matches(*argv, "add") == 0)
 		return ipaddr_modify(RTM_NEWADDR, NLM_F_CREATE|NLM_F_EXCL, argc-1, argv+1);
 	if (matches(*argv, "change") == 0 ||
@@ -1283,9 +1399,15 @@ int do_ipaddr(int argc, char **argv)
 		return ipaddr_modify(RTM_DELADDR, 0, argc-1, argv+1);
 	if (matches(*argv, "list") == 0 || matches(*argv, "show") == 0
 	    || matches(*argv, "lst") == 0)
-		return ipaddr_list_or_flush(argc-1, argv+1, 0);
+		return ipaddr_list_flush_or_save(argc-1, argv+1, IPADD_LIST);
 	if (matches(*argv, "flush") == 0)
-		return ipaddr_list_or_flush(argc-1, argv+1, 1);
+		return ipaddr_list_flush_or_save(argc-1, argv+1, IPADD_FLUSH);
+	if (matches(*argv, "save") == 0)
+		return ipaddr_list_flush_or_save(argc-1, argv+1, IPADD_SAVE);
+	if (matches(*argv, "showdump") == 0)
+		return ipaddr_showdump();
+	if (matches(*argv, "restore") == 0)
+		return ipaddr_restore();
 	if (matches(*argv, "help") == 0)
 		usage();
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip addr help\".\n", *argv);
