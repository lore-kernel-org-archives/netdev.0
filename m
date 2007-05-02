From: jamal <hadi@cyberus.ca>
Subject: [PATCH][IPROUTE2]  see SPD info
Date: Wed, 02 May 2007 18:35:16 -0400
Message-ID: <1178145316.4078.17.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Yr5B5onXeBeOsr5NbTsj"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:16571 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1766739AbXEBWfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 18:35:21 -0400
Received: by wx-out-0506.google.com with SMTP id h31so272686wxd
        for <netdev@vger.kernel.org>; Wed, 02 May 2007 15:35:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Yr5B5onXeBeOsr5NbTsj
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Stephen,
This depends on the SAD info patch (and the net-2.6 xfrm.h)

cheers,
jamal


--=-Yr5B5onXeBeOsr5NbTsj
Content-Disposition: attachment; filename=xfrmu_spdinfo-1
Content-Type: text/plain; name=xfrmu_spdinfo-1; charset=us-ascii
Content-Transfer-Encoding: 7bit

[XFRM] see SPD info

i.e instead of something like ip xfrm policy ls | grep -i src | wc -l
do:

ip xfrm policy count
And you get the count; you can also pass -s or -s -s to see more
details

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit bf6d889ba384b4aa8d167e86561171f188cacb01
tree cf91b880408aea7c7cddc3285226faa161eaa73a
parent 32ad83a9c67bf149e72933472f4371ecf2dbfc4f
author Jamal Hadi Salim <hadi@cyberus.ca> Wed, 02 May 2007 15:48:33 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Wed, 02 May 2007 15:48:33 -0400

 ip/xfrm_policy.c |   83 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 82 insertions(+), 1 deletions(-)

diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index ddbda78..600a26f 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -59,7 +59,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip xfrm policy { deleteall | list } [ dir DIR ] [ SELECTOR ]\n");
 	fprintf(stderr, "        [ index INDEX ] [ action ACTION ] [ priority PRIORITY ]\n");
 	fprintf(stderr, "Usage: ip xfrm policy flush [ ptype PTYPE ]\n");
-
+	fprintf(stderr, "Usage: ip xfrm count\n");
 	fprintf(stderr, "PTYPE := [ main | sub ](default=main)\n");
 	fprintf(stderr, "DIR := [ in | out | fwd ]\n");
 
@@ -774,6 +774,85 @@ static int xfrm_policy_list_or_deleteall(int argc, char **argv, int deleteall)
 	exit(0);
 }
 
+int print_spdinfo( struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = (FILE*)arg;
+	__u32 *f = NLMSG_DATA(n);
+	struct rtattr * tb[XFRMA_SPD_MAX+1];
+	struct rtattr * rta;
+	struct xfrmu_spdinfo *si;
+
+	int len = n->nlmsg_len;
+
+	len -= NLMSG_LENGTH(sizeof(__u32));
+	if (len < 0) {
+		fprintf(stderr, "SPDinfo: Wrong len %d\n", len);
+		return -1;
+	}
+
+	rta = XFRMSAPD_RTA(f);
+	parse_rtattr(tb, XFRMA_SPD_MAX, rta, len);
+
+	fprintf(fp,"\t SPD");
+	if (tb[XFRMA_SPDINFO]) {
+		if (RTA_PAYLOAD(tb[XFRMA_SADINFO]) < sizeof(*si)) {
+			fprintf(stderr, "SPDinfo: Wrong len %d\n", len);
+			return -1;
+		}
+		si = (struct xfrmu_spdinfo *)RTA_DATA(tb[XFRMA_SPDINFO]);
+		fprintf(fp," IN  %d", si->incnt);
+		fprintf(fp," OUT %d", si->outcnt);
+		fprintf(fp," FWD %d", si->fwdcnt);
+
+		if (show_stats) {
+			fprintf(fp," (Sock:");
+			fprintf(fp," IN %d", si->inscnt);
+			fprintf(fp," OUT %d", si->outscnt);
+			fprintf(fp," FWD %d", si->fwdscnt);
+			fprintf(fp,")");
+		}
+
+		fprintf(fp,"\n");
+		if (show_stats > 1) {
+			fprintf(fp,"\t SPD buckets:");
+			fprintf(fp," count %d", si->spdhcnt);
+			fprintf(fp," Max %d", si->spdhmcnt);
+		}
+	}
+	fprintf(fp,"\n");
+
+        return 0;
+}
+
+static int xfrm_spd_getinfo(int argc, char **argv)
+{
+	struct rtnl_handle rth;
+	struct {
+		struct nlmsghdr			n;
+		__u32				flags;
+		char 				ans[128];
+	} req;
+
+	memset(&req, 0, sizeof(req));
+
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(__u32));
+	req.n.nlmsg_flags = NLM_F_REQUEST;
+	req.n.nlmsg_type = XFRM_MSG_GETSPDINFO;
+	req.flags = 0XFFFFFFFF;
+
+	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
+		exit(1);
+
+	if (rtnl_talk(&rth, &req.n, 0, 0, &req.n, NULL, NULL) < 0)
+		exit(2);
+
+	print_spdinfo(&req.n, (void*)stdout);
+
+	rtnl_close(&rth);
+
+	return 0;
+}
+
 static int xfrm_policy_flush(int argc, char **argv)
 {
 	struct rtnl_handle rth;
@@ -848,6 +927,8 @@ int do_xfrm_policy(int argc, char **argv)
 		return xfrm_policy_get(argc-1, argv+1);
 	if (matches(*argv, "flush") == 0)
 		return xfrm_policy_flush(argc-1, argv+1);
+	if (matches(*argv, "count") == 0)
+		return xfrm_spd_getinfo(argc, argv);
 	if (matches(*argv, "help") == 0)
 		usage();
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip xfrm policy help\".\n", *argv);

--=-Yr5B5onXeBeOsr5NbTsj--

