From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RESEND][PATCH][IPROUTE2]  see SAD info
Date: Tue, 19 Jun 2007 16:25:53 -0700
Message-ID: <20070619162553.2b4babff@localhost.localdomain>
References: <1178233781.4068.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33804 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753084AbXFSX16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 19:27:58 -0400
In-Reply-To: <1178233781.4068.6.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 03 May 2007 19:09:41 -0400
jamal <hadi@cyberus.ca> wrote:

> Stephen,
> Use this patch instead of the one i sent yesterday.
> As before, you will need to pull include/linux/xfrm.h from
> net-2.6 once Dave applies the kernel patch.
> 
> cheers,
> jamal
> 

Using current xfrm.h from kernel headers, causes conflicts.
Instead of XFRMA_SADCNT, it should be using XFRMA_SAD_CNT.

---
 ip/xfrm_policy.c |   18 ++++++++++--------
 ip/xfrm_state.c  |   31 ++++++++++++++++---------------
 2 files changed, 26 insertions(+), 23 deletions(-)

diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 07793d8..c1086f1 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -780,8 +780,6 @@ int print_spdinfo( struct nlmsghdr *n, void *arg)
 	__u32 *f = NLMSG_DATA(n);
 	struct rtattr * tb[XFRMA_SPD_MAX+1];
 	struct rtattr * rta;
-	struct xfrmu_spdinfo *si;
-	struct xfrmu_spdhinfo *sh;
 
 	int len = n->nlmsg_len;
 
@@ -795,12 +793,14 @@ int print_spdinfo( struct nlmsghdr *n, void *arg)
 	parse_rtattr(tb, XFRMA_SPD_MAX, rta, len);
 
 	fprintf(fp,"\t SPD");
-	if (tb[XFRMA_SPDINFO]) {
-		if (RTA_PAYLOAD(tb[XFRMA_SPDINFO]) < sizeof(*si)) {
+	if (tb[XFRMA_SPD_INFO]) {
+		struct xfrmu_spdinfo *si;
+
+		if (RTA_PAYLOAD(tb[XFRMA_SPD_INFO]) < sizeof(*si)) {
 			fprintf(stderr, "SPDinfo: Wrong len %d\n", len);
 			return -1;
 		}
-		si = (struct xfrmu_spdinfo *)RTA_DATA(tb[XFRMA_SPDINFO]);
+		si = RTA_DATA(tb[XFRMA_SPD_INFO]);
 		fprintf(fp," IN  %d", si->incnt);
 		fprintf(fp," OUT %d", si->outcnt);
 		fprintf(fp," FWD %d", si->fwdcnt);
@@ -816,12 +816,14 @@ int print_spdinfo( struct nlmsghdr *n, void *arg)
 		fprintf(fp,"\n");
 	}
 	if (show_stats > 1) {
-		if (tb[XFRMA_SPDHINFO]) {
-			if (RTA_PAYLOAD(tb[XFRMA_SPDHINFO]) < sizeof(*sh)) {
+		struct xfrmu_spdhinfo *sh;
+
+		if (tb[XFRMA_SPD_HINFO]) {
+			if (RTA_PAYLOAD(tb[XFRMA_SPD_HINFO]) < sizeof(*sh)) {
 				fprintf(stderr, "SPDinfo: Wrong len %d\n", len);
 				return -1;
 			}
-			sh = (struct xfrmu_spdhinfo *)RTA_DATA(tb[XFRMA_SPDHINFO]);
+			sh = RTA_DATA(tb[XFRMA_SPD_HINFO]);
 			fprintf(fp,"\t SPD buckets:");
 			fprintf(fp," count %d", sh->spdhcnt);
 			fprintf(fp," Max %d", sh->spdhmcnt);
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 39b0f27..54e1330 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -686,7 +686,7 @@ int xfrm_state_print(const struct sockaddr_nl *who, struct nlmsghdr *n,
 			fprintf(stderr, "Buggy XFRM_MSG_DELPOLICY: too short XFRMA_POLICY len\n");
 			return -1;
 		}
-		xsinfo = (struct xfrm_usersa_info *)RTA_DATA(tb[XFRMA_SA]);
+		xsinfo = RTA_DATA(tb[XFRMA_SA]);
 	}
 
 	xfrm_state_info_print(xsinfo, tb, fp, NULL, NULL);
@@ -940,7 +940,6 @@ int print_sadinfo(struct nlmsghdr *n, void *arg)
 	__u32 *f = NLMSG_DATA(n);
 	struct rtattr *tb[XFRMA_SAD_MAX+1];
 	struct rtattr *rta;
-	struct xfrmu_sadhinfo *si;	
 	__u32 *cnt;
 
 	int len = n->nlmsg_len;
@@ -954,9 +953,9 @@ int print_sadinfo(struct nlmsghdr *n, void *arg)
 	rta = XFRMSAPD_RTA(f);
 	parse_rtattr(tb, XFRMA_SAD_MAX, rta, len);
 
-	if (tb[XFRMA_SADCNT]) {
+	if (tb[XFRMA_SAD_CNT]) {
 		fprintf(fp,"\t SAD");
-		cnt = (__u32 *)RTA_DATA(tb[XFRMA_SADCNT]);
+		cnt = (__u32 *)RTA_DATA(tb[XFRMA_SAD_CNT]);
 		fprintf(fp," count %d", *cnt);
 	} else {
 		fprintf(fp,"BAD SAD info returned\n");
@@ -964,18 +963,20 @@ int print_sadinfo(struct nlmsghdr *n, void *arg)
 	}
 
 	if (show_stats) {
-		if (!tb[XFRMA_SADHINFO]) {
-		}
-		if (RTA_PAYLOAD(tb[XFRMA_SADHINFO]) < sizeof(*si)) {
-			fprintf(fp,"BAD SAD length returned\n");
-			return -1;
-		}
+		if (tb[XFRMA_SAD_HINFO]) {
+			struct xfrmu_sadhinfo *si;
 
-		si = (struct xfrmu_sadhinfo *)RTA_DATA(tb[XFRMA_SADHINFO]);
-		fprintf(fp," (buckets ");
-		fprintf(fp,"count %d", si->sadhcnt);
-		fprintf(fp," Max %d", si->sadhmcnt);
-		fprintf(fp,")");
+			if (RTA_PAYLOAD(tb[XFRMA_SAD_HINFO]) < sizeof(*si)) {
+				fprintf(fp,"BAD SAD length returned\n");
+				return -1;
+			}
+				
+			si = RTA_DATA(tb[XFRMA_SAD_HINFO]);
+			fprintf(fp," (buckets ");
+			fprintf(fp,"count %d", si->sadhcnt);
+			fprintf(fp," Max %d", si->sadhmcnt);
+			fprintf(fp,")");
+		}
 	}
 	fprintf(fp,"\n");
 
-- 
1.5.2.1


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
