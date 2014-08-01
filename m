From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: [PATCH RFC iproute2 2/2] ipxfrm: add command for configuring SPD hash table
Date: Fri,  1 Aug 2014 15:01:10 +0200
Message-ID: <1406898070-15942-3-git-send-email-christophe.gouault@6wind.com>
References: <1406884348-12423-3-git-send-email-christophe.gouault@6wind.com>
 <1406898070-15942-1-git-send-email-christophe.gouault@6wind.com>
Cc: netdev@vger.kernel.org,
	Christophe Gouault <christophe.gouault@6wind.com>
To: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:58721 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755280AbaHANB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 09:01:58 -0400
Received: by mail-wg0-f48.google.com with SMTP id x13so4231430wgg.19
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2014 06:01:55 -0700 (PDT)
In-Reply-To: <1406898070-15942-1-git-send-email-christophe.gouault@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add a new command to configure the SPD hash table:
   ip xfrm policy set [ hthresh4 LBITS RBITS ] [ hthresh6 LBITS RBITS ]

hthresh4: defines minimum local and remote IPv4 prefix lengths of
selectors to hash a policy. If prefix lengths are greater or equal
to the thresholds, then the policy is hashed, otherwise it falls back
in the policy_inexact chained list.

hthresh6: defines minimum local and remote IPv6 prefix lengths of
selectors to hash a policy, otherwise it falls back
in the policy_inexact chained list.

Signed-off-by: Christophe Gouault <christophe.gouault@6wind.com>
---
 ip/xfrm_policy.c | 106 ++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 102 insertions(+), 4 deletions(-)

diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 2337d35..dbca894 100644
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
@@ -933,9 +934,9 @@ static int print_spdinfo( struct nlmsghdr *n, void *arg)
 			fprintf(fp," FWD %d", si->fwdscnt);
 			fprintf(fp,")");
 		}
-
-		fprintf(fp,"\n");
 	}
+	fprintf(fp,"\n");
+
 	if (show_stats > 1) {
 		struct xfrmu_spdhinfo *sh;
 
@@ -948,13 +949,108 @@ static int print_spdinfo( struct nlmsghdr *n, void *arg)
 			fprintf(fp,"\t SPD buckets:");
 			fprintf(fp," count %d", sh->spdhcnt);
 			fprintf(fp," Max %d", sh->spdhmcnt);
+			fprintf(fp,"\n");
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
+			fprintf(fp,"\n");
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
+			fprintf(fp,"\n");
 		}
 	}
-	fprintf(fp,"\n");
 
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
+	if (rtnl_talk(&rth, &req.n, 0, 0, &req.n) < 0)
+		exit(2);
+
+	print_spdinfo(&req.n, (void*)stdout);
+
+	rtnl_close(&rth);
+
+	return 0;
+}
+
 static int xfrm_spd_getinfo(int argc, char **argv)
 {
 	struct rtnl_handle rth;
@@ -1058,6 +1154,8 @@ int do_xfrm_policy(int argc, char **argv)
 		return xfrm_policy_flush(argc-1, argv+1);
 	if (matches(*argv, "count") == 0)
 		return xfrm_spd_getinfo(argc, argv);
+	if (matches(*argv, "set") == 0)
+		return xfrm_spd_setinfo(argc-1, argv+1);
 	if (matches(*argv, "help") == 0)
 		usage();
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip xfrm policy help\".\n", *argv);
-- 
1.9.1
