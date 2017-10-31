From: Greg Greenway <ggreenway@apple.com>
Subject: [PATCH iproute2] Add "show" subcommand to "ip fou"
Date: Tue, 31 Oct 2017 13:00:47 -0700
Message-ID: <BC879902-DED4-4AFC-B2AA-8C4F4C4B4C99@apple.com>
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out25.apple.com ([17.171.2.35]:62207 "EHLO
        mail-in25.apple.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932356AbdJaUPu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 16:15:50 -0400
Received: from [17.234.128.96] (unknown [17.234.128.96])
 by haralson.apple.com (Oracle Communications Messaging Server 8.0.1.3.20170825
 64bit (built Aug 25 2017))
 with ESMTPSA id <0OYP00936E9C0N20@haralson.apple.com> for
 netdev@vger.kernel.org; Tue, 31 Oct 2017 13:00:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sample output:

$ ip fou show
port 4 af AF_INET ipproto 4

Signed-off-by: Greg Greenway <ggreenway@apple.com>
---
 ip/ipfou.c | 66 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 66 insertions(+)

diff --git a/ip/ipfou.c b/ip/ipfou.c
index 00dbe15..2eb5bfd 100644
--- a/ip/ipfou.c
+++ b/ip/ipfou.c
@@ -28,6 +28,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip fou add port PORT "
 		"{ ipproto PROTO  | gue } [ -6 ]\n");
 	fprintf(stderr, "       ip fou del port PORT [ -6 ]\n");
+	fprintf(stderr, "       ip fou show\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: PROTO { ipproto-name | 1..255 }\n");
 	fprintf(stderr, "       PORT { 1..65535 }\n");
@@ -134,6 +135,69 @@ static int do_del(int argc, char **argv)
 	return 0;
 }
 
+static int print_fou_mapping(const struct sockaddr_nl *who,
+				 struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = (FILE *)arg;
+	struct genlmsghdr *ghdr;
+	struct rtattr *tb[FOU_ATTR_MAX + 1];
+	int len = n->nlmsg_len;
+	unsigned family;
+	char *family_str;
+
+	if (n->nlmsg_type != genl_family)
+		return 0;
+
+	len -= NLMSG_LENGTH(GENL_HDRLEN);
+	if (len < 0)
+		return -1;
+
+	ghdr = NLMSG_DATA(n);
+	parse_rtattr(tb, FOU_ATTR_MAX, (void *) ghdr + GENL_HDRLEN, len);
+
+	if (tb[FOU_ATTR_PORT])
+		fprintf(fp, "port %u ", ntohs(rta_getattr_u16(tb[FOU_ATTR_PORT])));
+	if (tb[FOU_ATTR_AF]) {
+		family = rta_getattr_u8(tb[FOU_ATTR_AF]);
+		if (family == AF_INET)
+			family_str = "AF_INET";
+		else if (family == AF_INET6)
+			family_str = "AF_INET6";
+		else
+			family_str = "unknown";
+		fprintf(fp, "af %s ", family_str);
+	}
+	if (tb[FOU_ATTR_TYPE] && rta_getattr_u8(tb[FOU_ATTR_TYPE]) == FOU_ENCAP_GUE)
+		fprintf(fp, "gue ");
+	else if (tb[FOU_ATTR_IPPROTO])
+		fprintf(fp, "ipproto %u ", rta_getattr_u8(tb[FOU_ATTR_IPPROTO]));
+	fprintf(fp, "\n");
+
+	return 0;
+}
+
+static int do_show(int argc, char **argv)
+{
+	FOU_REQUEST(req, 4096, FOU_CMD_GET, NLM_F_REQUEST | NLM_F_DUMP);
+
+	if (argc > 0) {
+		fprintf(stderr, "\"ip fou show\" does not take any arguments.\n");
+		return -1;
+	}
+
+	if (rtnl_send(&genl_rth, &req.n, req.n.nlmsg_len) < 0) {
+		perror("Cannot send show request");
+		exit(1);
+	}
+
+	if (rtnl_dump_filter(&genl_rth, print_fou_mapping, stdout) < 0) {
+		fprintf(stderr, "Dump terminated\n");
+		return 1;
+	}
+
+	return 0;
+}
+
 int do_ipfou(int argc, char **argv)
 {
 	if (argc < 1)
@@ -149,6 +213,8 @@ int do_ipfou(int argc, char **argv)
 		return do_add(argc-1, argv+1);
 	if (matches(*argv, "delete") == 0)
 		return do_del(argc-1, argv+1);
+	if (matches(*argv, "show") == 0)
+		return do_show(argc-1, argv+1);
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip fou help\".\n", *argv);
 	exit(-1);
 }
-- 
2.7.4
