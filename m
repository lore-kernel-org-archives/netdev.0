From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH iproute2-next] ss: output dctcp diag information
Date: Mon, 29 Sep 2014 10:47:32 +0200
Message-ID: <1411980452-4669-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57977 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751037AbaI2Irj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 04:47:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dump useful DCTCP state/debug information gathered from diag.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/inet_diag.h | 13 +++++++++++--
 misc/ss.c                 | 13 +++++++++++++
 2 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index e34f247..7438dad 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -110,10 +110,10 @@ enum {
 	INET_DIAG_TCLASS,
 	INET_DIAG_SKMEMINFO,
 	INET_DIAG_SHUTDOWN,
+	INET_DIAG_DCTCPINFO,
 };
 
-#define INET_DIAG_MAX INET_DIAG_SHUTDOWN
-
+#define INET_DIAG_MAX INET_DIAG_DCTCPINFO
 
 /* INET_DIAG_MEM */
 
@@ -133,5 +133,14 @@ struct tcpvegas_info {
 	__u32	tcpv_minrtt;
 };
 
+/* INET_DIAG_DCTCPINFO */
+
+struct tcp_dctcp_info {
+	__u16	dctcp_enabled;
+	__u16	dctcp_ce_state;
+	__u32	dctcp_alpha;
+	__u32	dctcp_ab_ecn;
+	__u32	dctcp_ab_tot;
+};
 
 #endif /* _INET_DIAG_H_ */
diff --git a/misc/ss.c b/misc/ss.c
index c847954..f5019e1 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1576,6 +1576,19 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 				rtt =  vinfo->tcpv_rtt;
 		}
 
+		if (tb[INET_DIAG_DCTCPINFO]) {
+			const struct tcp_dctcp_info *dinfo
+				= RTA_DATA(tb[INET_DIAG_DCTCPINFO]);
+
+			if (dinfo->dctcp_enabled) {
+				printf(" ce_state %u alpha %u ab_ecn %u ab_tot %u",
+				       dinfo->dctcp_ce_state, dinfo->dctcp_alpha,
+				       dinfo->dctcp_ab_ecn, dinfo->dctcp_ab_tot);
+			} else {
+				printf(" fallback_mode");
+			}
+		}
+
 		if (rtt > 0 && info->tcpi_snd_mss && info->tcpi_snd_cwnd) {
 			printf(" send %sbps",
 			       sprint_bw(b1, (double) info->tcpi_snd_cwnd *
-- 
1.9.0
