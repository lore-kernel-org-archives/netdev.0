From: jamal <hadi@cyberus.ca>
Subject: [PATCH][IPROUTE2]  see SAD info
Date: Wed, 02 May 2007 18:31:56 -0400
Message-ID: <1178145116.4078.13.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-YLE2nAUMJ81pyjhwzwLL"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.226]:14878 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1766739AbXEBWcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 18:32:00 -0400
Received: by wx-out-0506.google.com with SMTP id h31so271960wxd
        for <netdev@vger.kernel.org>; Wed, 02 May 2007 15:32:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-YLE2nAUMJ81pyjhwzwLL
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Stephen,
You need to pull the latest net-2.6 include/linux/xfrm.h for this 
(and the earlier migrate stuff from Nakamura-san)...

cheers,
jamal

--=-YLE2nAUMJ81pyjhwzwLL
Content-Disposition: attachment; filename=xfrmu_sadinfo-1
Content-Type: text/plain; name=xfrmu_sadinfo-1; charset=us-ascii
Content-Transfer-Encoding: 7bit

[XFRM] see SAD info

i.e instead of something like ip xfrm state ls | grep -i src | wc -l
do:

ip xfrm state count
And you get the count; you can also pass -s to the command line and
get the hash info.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 32ad83a9c67bf149e72933472f4371ecf2dbfc4f
tree 2d0964c5af081aae29419bc82459a584f872b94d
parent ab4c2f14fb93700c9aefeb02ed9918565ba332a1
author Jamal Hadi Salim <hadi@cyberus.ca> Wed, 02 May 2007 15:41:07 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Wed, 02 May 2007 15:41:07 -0400

 ip/xfrm.h            |    1 +
 ip/xfrm_state.c      |   76 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 157 insertions(+), 0 deletions(-)

diff --git a/ip/xfrm.h b/ip/xfrm.h
index d1959bb..71345b9 100644
--- a/ip/xfrm.h
+++ b/ip/xfrm.h
@@ -57,6 +57,7 @@
 
 #define XFRMREP_RTA(x)	((struct rtattr*)(((char*)(x)) + NLMSG_ALIGN(sizeof(struct xfrm_user_report))))
 
+#define XFRMSAPD_RTA(x)	((struct rtattr*)(((char*)(x)) + NLMSG_ALIGN(sizeof(__u32))))
 #define XFRM_FLAG_PRINT(fp, flags, f, s) \
 	do { \
 		if (flags & f) { \
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 42e3949..11535e2 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -64,6 +64,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip xfrm state { deleteall | list } [ ID ] [ mode MODE ] [ reqid REQID ]\n");
 	fprintf(stderr, "        [ flag FLAG_LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm state flush [ proto XFRM_PROTO ]\n");
+	fprintf(stderr, "Usage: ip xfrm state count \n");
 
 	fprintf(stderr, "ID := [ src ADDR ] [ dst ADDR ] [ proto XFRM_PROTO ] [ spi SPI ]\n");
 	//fprintf(stderr, "XFRM_PROTO := [ esp | ah | comp ]\n");
@@ -933,6 +934,78 @@ static int xfrm_state_list_or_deleteall(int argc, char **argv, int deleteall)
 	exit(0);
 }
 
+int print_sadinfo(struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = (FILE*)arg;
+	__u32 *f = NLMSG_DATA(n);
+	struct rtattr *tb[XFRMA_SAD_MAX+1];
+	struct rtattr *rta;
+	struct xfrmu_sadinfo *si;	
+
+	int len = n->nlmsg_len;
+
+	len -= NLMSG_LENGTH(sizeof(__u32));
+	if (len < 0) {
+		fprintf(stderr, "SADinfo: Wrong len %d\n", len);
+		return -1;
+	}
+
+	rta = XFRMSAPD_RTA(f);
+	parse_rtattr(tb, XFRMA_SAD_MAX, rta, len);
+
+	if (tb[XFRMA_SADINFO]) {
+		if (RTA_PAYLOAD(tb[XFRMA_SADINFO]) < sizeof(*si)) {
+			fprintf(fp,"BAD SAD length returned\n");
+			return -1;
+		}
+
+		fprintf(fp,"\t SAD");
+		si = (struct xfrmu_sadinfo *)RTA_DATA(tb[XFRMA_SADINFO]);
+		fprintf(fp," count %d", si->sadcnt);
+		if (show_stats ) {
+			fprintf(fp," (buckets ");
+			fprintf(fp,"count %d", si->sadhcnt);
+			fprintf(fp," Max %d", si->sadhmcnt);
+			fprintf(fp,")");
+		}
+		fprintf(fp,"\n");
+	} else {
+		fprintf(fp,"BAD SAD info returned\n");
+		return -1;
+	}
+
+
+        return 0;
+}
+
+static int xfrm_sad_getinfo(int argc, char **argv)
+{
+	struct rtnl_handle rth;
+	struct {
+		struct nlmsghdr			n;
+		__u32				flags;
+		char				ans[64];
+	} req;
+
+	memset(&req, 0, sizeof(req));
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.flags));
+	req.n.nlmsg_flags = NLM_F_REQUEST;
+	req.n.nlmsg_type = XFRM_MSG_GETSADINFO;
+	req.flags = 0XFFFFFFFF;
+
+	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
+		exit(1);
+
+	if (rtnl_talk(&rth, &req.n, 0, 0, &req.n, NULL, NULL) < 0)
+		exit(2);
+
+	print_sadinfo(&req.n, (void*)stdout);
+
+	rtnl_close(&rth);
+
+	return 0;
+}
+
 static int xfrm_state_flush(int argc, char **argv)
 {
 	struct rtnl_handle rth;
@@ -1010,6 +1083,9 @@ int do_xfrm_state(int argc, char **argv)
 		return xfrm_state_get_or_delete(argc-1, argv+1, 0);
 	if (matches(*argv, "flush") == 0)
 		return xfrm_state_flush(argc-1, argv+1);
+	if (matches(*argv, "count") == 0) {
+		return xfrm_sad_getinfo(argc, argv);
+	}
 	if (matches(*argv, "help") == 0)
 		usage();
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip xfrm state help\".\n", *argv);

--=-YLE2nAUMJ81pyjhwzwLL--

