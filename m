From: Lorenzo Colitti <lorenzo@google.com>
Subject: [iputils PATCH 1/2] ping: Add a function to check if a packet is ours
Date: Mon,  3 Jun 2013 21:50:32 +0900
Message-ID: <1370263833-27271-1-git-send-email-lorenzo@google.com>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Vasiliy Kulikov <segoon@openwall.com>,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f201.google.com ([209.85.213.201]:46192 "EHLO
	mail-ye0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958Ab3FCMuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 08:50:37 -0400
Received: by mail-ye0-f201.google.com with SMTP id q9so361856yen.2
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 05:50:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
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
index c39864d..019d9e4 100644
--- a/ping6.c
+++ b/ping6.c
@@ -1305,7 +1305,7 @@ int receive_error_msg()
 		if (res < sizeof(icmph) ||
 		    memcmp(&target.sin6_addr, &whereto.sin6_addr, 16) ||
 		    icmph.icmp6_type != ICMP6_ECHO_REQUEST ||
-		    icmph.icmp6_id != ident) {
+		    !is_ours(icmph.icmp6_id)) {
 			/* Not our error, not an error at all. Clear. */
 			saved_errno = 0;
 			goto out;
@@ -1602,7 +1602,7 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
 	}
 
 	if (icmph->icmp6_type == ICMP6_ECHO_REPLY) {
-		if (icmph->icmp6_id != ident)
+		if (!is_ours(icmph->icmp6_id))
 			return 1;
 		if (gather_statistics((__u8*)icmph, sizeof(*icmph), cc,
 				      ntohs(icmph->icmp6_seq),
@@ -1645,7 +1645,7 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
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
 
+inline int is_ours(uint8_t id) {
+       return id == ident;
+}
+
diff --git a/ping_common.h b/ping_common.h
index 27ae0f0..d7513a2 100644
--- a/ping_common.h
+++ b/ping_common.h
@@ -273,6 +273,7 @@ extern int send_probe(void);
 extern int receive_error_msg(void);
 extern int parse_reply(struct msghdr *msg, int len, void *addr, struct timeval *);
 extern void install_filter(void);
+extern int is_ours(uint8_t id);
 
 extern int pinger(void);
 extern void sock_setbufs(int icmp_sock, int alloc);
-- 
1.8.2.1
