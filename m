From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [PATCH v3 1/2] iputils ping/ping6: Add a function to check if a packet is ours
Date: Tue, 14 Apr 2015 17:16:04 +0200
Message-ID: <4826115.h2pPsjneLg@msg-id>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	Vasiliy Kulikov <segooon@gmail.com>,
	Tyler Hicks <tyhicks@canonical.com>, s.mesoraca16@gmail.com,
	netdev@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:33263 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754963AbbDNPQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 11:16:10 -0400
Received: by wgin8 with SMTP id n8so15710538wgi.0
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 08:16:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Almost identical to Lorenzo Colitti's original patch except that this solves
an issues that broke ping's ident check.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
---
 ping.c        | 6 +++---
 ping6.c       | 6 +++---
 ping_common.c | 4 ++++
 ping_common.h | 1 +
 4 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/ping.c b/ping.c
index c0366cd..aa6f19f 100644
--- a/ping.c
+++ b/ping.c
@@ -646,7 +646,7 @@ int receive_error_msg()
 		if (res < sizeof(icmph) ||
 		    target.sin_addr.s_addr != whereto.sin_addr.s_addr ||
 		    icmph.type != ICMP_ECHO ||
-		    icmph.un.echo.id != ident) {
+		    !is_ours(icmph.un.echo.id)) {
 			/* Not our error, not an error at all. Clear. */
 			saved_errno = 0;
 			goto out;
@@ -782,7 +782,7 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
 	csfailed = in_cksum((u_short *)icp, cc, 0);

 	if (icp->type == ICMP_ECHOREPLY) {
-		if (icp->un.echo.id != ident)
+		if (!is_ours(icp->un.echo.id))
 			return 1;			/* 'Twas not our ECHO */
 		if (gather_statistics((__u8*)icp, sizeof(*icp), cc,
 				      ntohs(icp->un.echo.sequence),
@@ -812,7 +812,7 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
 					return 1;
 				if (icp1->type != ICMP_ECHO ||
 				    iph->daddr != whereto.sin_addr.s_addr ||
-				    icp1->un.echo.id != ident)
+				    !is_ours(icp1->un.echo.id))
 					return 1;
 				error_pkt = (icp->type != ICMP_REDIRECT &&
 					     icp->type != ICMP_SOURCE_QUENCH);
diff --git a/ping6.c b/ping6.c
index 6d83462..e8f581f 100644
--- a/ping6.c
+++ b/ping6.c
@@ -1301,7 +1301,7 @@ int receive_error_msg()
 		if (res < sizeof(icmph) ||
 		    memcmp(&target.sin6_addr, &whereto.sin6_addr, 16) ||
 		    icmph.icmp6_type != ICMP6_ECHO_REQUEST ||
-		    icmph.icmp6_id != ident) {
+		    !is_ours(icmph.icmp6_id)) {
 			/* Not our error, not an error at all. Clear. */
 			saved_errno = 0;
 			goto out;
@@ -1598,7 +1598,7 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
 	}

 	if (icmph->icmp6_type == ICMP6_ECHO_REPLY) {
-		if (icmph->icmp6_id != ident)
+		if (!is_ours(icmph->icmp6_id))
 			return 1;
 		if (gather_statistics((__u8*)icmph, sizeof(*icmph), cc,
 				      ntohs(icmph->icmp6_seq),
@@ -1641,7 +1641,7 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
 		}
 		if (nexthdr == IPPROTO_ICMPV6) {
 			if (icmph1->icmp6_type != ICMP6_ECHO_REQUEST ||
-			    icmph1->icmp6_id != ident)
+			    !is_ours(icmph1->icmp6_id))
 				return 1;
 			acknowledge(ntohs(icmph1->icmp6_seq));
 			if (working_recverr)
diff --git a/ping_common.c b/ping_common.c
index 8d6b145..b0a14dc 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -1072,3 +1072,7 @@ void status(void)
 	fprintf(stderr, "\n");
 }

+inline int is_ours(uint16_t id) {
+       return id == ident;
+}
+
diff --git a/ping_common.h b/ping_common.h
index 84091b2..a915b95 100644
--- a/ping_common.h
+++ b/ping_common.h
@@ -274,6 +274,7 @@ extern int send_probe(void);
 extern int receive_error_msg(void);
 extern int parse_reply(struct msghdr *msg, int len, void *addr, struct timeval *);
 extern void install_filter(void);
+extern int is_ours(uint16_t id);

 extern int pinger(void);
 extern void sock_setbufs(int icmp_sock, int alloc);
--
2.0.5
