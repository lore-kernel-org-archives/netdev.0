From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: [PATCH iproute2 1/2] xfrm: add command for configuring SPD hash table
Date: Thu,  9 Apr 2015 17:39:32 +0200
Message-ID: <1428593973-12780-2-git-send-email-christophe.gouault@6wind.com>
References: <1428593973-12780-1-git-send-email-christophe.gouault@6wind.com>
Cc: netdev@vger.kernel.org,
	Christophe Gouault <christophe.gouault@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:36374 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755531AbbDIPjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 11:39:45 -0400
Received: by wizk4 with SMTP id k4so97196130wiz.1
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 08:39:44 -0700 (PDT)
In-Reply-To: <1428593973-12780-1-git-send-email-christophe.gouault@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add a new command to configure the SPD hash table:
   ip xfrm policy set [ hthresh4 LBITS RBITS ] [ hthresh6 LBITS RBITS ]

and code to display the SPD hash configuration:
  ip -s -s xfrm policy count

hthresh4: defines minimum local and remote IPv4 prefix lengths of
selectors to hash a policy. If prefix lengths are greater or equal
to the thresholds, then the policy is hashed, otherwise it falls back
in the policy_inexact chained list.

hthresh6: defines minimum local and remote IPv6 prefix lengths of
selectors to hash a policy, otherwise it falls back
in the policy_inexact chained list.

Example:

% ip -s -s xfrm policy count
         SPD IN  0 OUT 0 FWD 0 (Sock: IN 0 OUT 0 FWD 0)
         SPD buckets: count 7 Max 1048576
         SPD IPv4 thresholds: local 32 remote 32
         SPD IPv6 thresholds: local 128 remote 128

% ip xfrm pol set hthresh4 24 16 hthresh6 64 56

% ip -s -s xfrm policy count
         SPD IN  0 OUT 0 FWD 0 (Sock: IN 0 OUT 0 FWD 0)
         SPD buckets: count 7 Max 1048576
         SPD IPv4 thresholds: local 24 remote 16
         SPD IPv6 thresholds: local 64 remote 56

Signed-off-by: Christophe Gouault <christophe.gouault@6wind.com>
---
 ip/xfrm_policy.c |  105 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 102 insertions(+), 3 deletions(-)

diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 2337d35246fa..7333dc5f536e 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -63,7 +63,8 @@ static void usage(void)
 	fprintf(stderr, "        [ index INDEX ] [ ptype PTYPE ] [ action ACTION ] [ priority PRIORITY ]\n");
 	fprintf(stderr, "        [ flag FLAG-LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm policy flush [ ptype PTYPE ]\n");
-	fprintf(stderr, "Usage: ip xfrm count\n");
+	fprintf(stderr, "Usage: ip xfrm policy count\n");
+	fprintf(stderr, "Usage: ip xfrm policy set [ hthresh4 LBITS RBITS ] [ hthresh6 LBITS RBITS ]\n");
 	fprintf(stderr, "SELECTOR := [ src ADDR[/PLEN] ] [ dst ADDR[/PLEN] ] [ dev DEV ] [ UPSPEC ]\n");
 	fprintf(stderr, "UPSPEC := proto { { ");
 	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_TCP));
@@ -934,7 +935,7 @@ static int print_spdinfo( struct nlmsghdr *n, void *arg)
 			fprintf(fp,")");
 		}
 
-		fprintf(fp,"\n");
+		fprintf(fp, "%s", _SL_);
 	}
 	if (show_stats > 1) {
 		struct xfrmu_spdhinfo *sh;
@@ -948,13 +949,109 @@ static int print_spdinfo( struct nlmsghdr *n, void *arg)
 			fprintf(fp,"\t SPD buckets:");
 			fprintf(fp," count %d", sh->spdhcnt);
 			fprintf(fp," Max %d", sh->spdhmcnt);
+			fprintf(fp, "%s", _SL_);
+		}
+		if (tb[XFRMA_SPD_IPV4_HTHRESH]) {
+			struct xfrmu_spdhthresh *th;
+			if (RTA_PAYLOAD(tb[XFRMA_SPD_IPV4_HTHRESH]) < sizeof(*th)) {
+				fprintf(stderr, "SPDinfo: Wrong len %d\n", len);
+				return -1;
+			}
+			th = RTA_DATA(tb[XFRMA_SPD_IPV4_HTHRESH]);
+			fprintf(fp,"\t SPD IPv4 thresholds:");
+			fprintf(fp," local %d", th->lbits);
+			fprintf(fp," remote %d", th->rbits);
+			fprintf(fp, "%s", _SL_);
+
+		}
+		if (tb[XFRMA_SPD_IPV6_HTHRESH]) {
+			struct xfrmu_spdhthresh *th;
+			if (RTA_PAYLOAD(tb[XFRMA_SPD_IPV6_HTHRESH]) < sizeof(*th)) {
+				fprintf(stderr, "SPDinfo: Wrong len %d\n", len);
+				return -1;
+			}
+			th = RTA_DATA(tb[XFRMA_SPD_IPV6_HTHRESH]);
+			fprintf(fp,"\t SPD IPv6 thresholds:");
+			fprintf(fp," local %d", th->lbits);
+			fprintf(fp," remote %d", th->rbits);
+			fprintf(fp, "%s", _SL_);
 		}
 	}
-	fprintf(fp,"\n");
+
+	if (oneline)
+		fprintf(fp, "\n");
 
         return 0;
 }
 
+static int xfrm_spd_setinfo(int argc, char **argv)
+{
+	struct rtnl_handle rth;
+	struct {
+		struct nlmsghdr			n;
+		__u32				flags;
+		char				buf[RTA_BUF_SIZE];
+	} req;
+
+	char *thr4 = NULL;
+	char *thr6 = NULL;
+
+	memset(&req, 0, sizeof(req));
+
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(__u32));
+	req.n.nlmsg_flags = NLM_F_REQUEST;
+	req.n.nlmsg_type = XFRM_MSG_NEWSPDINFO;
+	req.flags = 0XFFFFFFFF;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "hthresh4") == 0) {
+			struct xfrmu_spdhthresh thr;
+
+			if (thr4)
+				duparg("hthresh4", *argv);
+			thr4 = *argv;
+			NEXT_ARG();
+			if (get_u8(&thr.lbits, *argv, 0) || thr.lbits > 32)
+				invarg("hthresh4 LBITS value is invalid", *argv);
+			NEXT_ARG();
+			if (get_u8(&thr.rbits, *argv, 0) || thr.rbits > 32)
+				invarg("hthresh4 RBITS value is invalid", *argv);
+
+			addattr_l(&req.n, sizeof(req), XFRMA_SPD_IPV4_HTHRESH,
+				  (void *)&thr, sizeof(thr));
+		} else if (strcmp(*argv, "hthresh6") == 0) {
+			struct xfrmu_spdhthresh thr;
+
+			if (thr6)
+				duparg("hthresh6", *argv);
+			thr6 = *argv;
+			NEXT_ARG();
+			if (get_u8(&thr.lbits, *argv, 0) || thr.lbits > 128)
+				invarg("hthresh6 LBITS value is invalid", *argv);
+			NEXT_ARG();
+			if (get_u8(&thr.rbits, *argv, 0) || thr.rbits > 128)
+				invarg("hthresh6 RBITS value is invalid", *argv);
+
+			addattr_l(&req.n, sizeof(req), XFRMA_SPD_IPV6_HTHRESH,
+				  (void *)&thr, sizeof(thr));
+		} else {
+			invarg("unknown", *argv);
+		}
+
+		argc--; argv++;
+	}
+
+	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
+		exit(1);
+
+	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+		exit(2);
+
+	rtnl_close(&rth);
+
+	return 0;
+}
+
 static int xfrm_spd_getinfo(int argc, char **argv)
 {
 	struct rtnl_handle rth;
@@ -1058,6 +1155,8 @@ int do_xfrm_policy(int argc, char **argv)
 		return xfrm_policy_flush(argc-1, argv+1);
 	if (matches(*argv, "count") == 0)
 		return xfrm_spd_getinfo(argc, argv);
+	if (matches(*argv, "set") == 0)
+		return xfrm_spd_setinfo(argc-1, argv+1);
 	if (matches(*argv, "help") == 0)
 		usage();
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip xfrm policy help\".\n", *argv);
-- 
1.7.10.4
