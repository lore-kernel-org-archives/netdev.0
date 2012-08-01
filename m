From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 2/6] fix up strict-aliasing warnings
Date: Wed,  1 Aug 2012 11:45:24 -0400
Message-ID: <1343835928-21541-2-git-send-email-vapier@gentoo.org>
References: <1343835928-21541-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:51061 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751569Ab2HAPp3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2012 11:45:29 -0400
In-Reply-To: <1343835928-21541-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current build of some tools results in gcc warning about strict-aliasing
violations.  So change those freaky casts to memcpy's.  When the pointer
types work out, gcc will optimize this away anyways.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 ping.c       |    4 ++--
 ping6.c      |   13 +++++++++----
 tracepath.c  |    2 +-
 tracepath6.c |    2 +-
 4 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/ping.c b/ping.c
index 1425d1d..1110a1a 100644
--- a/ping.c
+++ b/ping.c
@@ -444,7 +444,7 @@ main(int argc, char **argv)
 			int i;
 			rspace[1] = 4+nroute*8;
 			for (i=0; i<nroute; i++)
-				*(__u32*)&rspace[4+i*8] = route[i];
+				memcpy(&rspace[4+i*8], &route[i], 4);
 		}
 		if (setsockopt(icmp_sock, IPPROTO_IP, IP_OPTIONS, rspace, rspace[1]) < 0) {
 			rspace[3] = 2;
@@ -464,7 +464,7 @@ main(int argc, char **argv)
 		rspace[1+IPOPT_OLEN] = 3 + nroute*4;
 		rspace[1+IPOPT_OFFSET] = IPOPT_MINOFF;
 		for (i=0; i<nroute; i++)
-			*(__u32*)&rspace[4+i*4] = route[i];
+			memcpy(&rspace[4+i*4], &route[i], 4);
 
 		if (setsockopt(icmp_sock, IPPROTO_IP, IP_OPTIONS, rspace, 4 + nroute*4) < 0) {
 			perror("ping: record route");
diff --git a/ping6.c b/ping6.c
index 1673937..ce102d0 100644
--- a/ping6.c
+++ b/ping6.c
@@ -1142,18 +1142,21 @@ int build_niquery(__u8 *_nih)
 {
 	struct ni_hdr *nih;
 	int cc;
+	__u16 this_nonce;
 
 	nih = (struct ni_hdr *)_nih;
 	nih->ni_cksum = 0;
 
-	CLR(ntohs((*(__u16*)(nih->ni_nonce))) % mx_dup_ck);
+	memcpy(&this_nonce, &nih->ni_nonce, sizeof(this_nonce));
+	CLR(ntohs(this_nonce) % mx_dup_ck);
 
 	nih->ni_type = ICMPV6_NI_QUERY;
 	cc = sizeof(*nih);
 	datalen = 0;
 
 	memcpy(nih->ni_nonce, ni_nonce, sizeof(nih->ni_nonce));
-	*(__u16*)(nih->ni_nonce) = htons(ntransmitted + 1);
+	this_nonce = htons(ntransmitted + 1);
+	memcpy(&nih->ni_nonce, &this_nonce, sizeof(this_nonce));
 
 	nih->ni_code = ni_subject_type;
 	nih->ni_qtype = htons(ni_query);
@@ -1367,7 +1370,7 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
 #endif
 			if (c->cmsg_len < CMSG_LEN(sizeof(int)))
 				continue;
-			hops = *(int*)CMSG_DATA(c);
+			memcpy(&hops, CMSG_DATA(c), sizeof(int));
 		}
 	}
 
@@ -1391,7 +1394,9 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
 			return 0;
 	} else if (icmph->icmp6_type == ICMPV6_NI_REPLY) {
 		struct ni_hdr *nih = (struct ni_hdr *)icmph;
-		__u16 seq = ntohs(*(__u16 *)nih->ni_nonce);
+		__u16 seq;
+		memcpy(&seq, &nih->ni_nonce, sizeof(seq));
+		seq = ntohs(seq);
 		if (memcmp(&nih->ni_nonce[2], &ni_nonce[2], sizeof(ni_nonce) - sizeof(__u16)))
 			return 1;
 		if (gather_statistics((__u8*)icmph, sizeof(*icmph), cc,
diff --git a/tracepath.c b/tracepath.c
index ca84a69..0a14b1b 100644
--- a/tracepath.c
+++ b/tracepath.c
@@ -142,7 +142,7 @@ restart:
 			if (cmsg->cmsg_type == IP_RECVERR) {
 				e = (struct sock_extended_err *) CMSG_DATA(cmsg);
 			} else if (cmsg->cmsg_type == IP_TTL) {
-				rethops = *(int*)CMSG_DATA(cmsg);
+				memcpy(&rethops, CMSG_DATA(cmsg), sizeof(int));
 			} else {
 				printf("cmsg:%d\n ", cmsg->cmsg_type);
 			}
diff --git a/tracepath6.c b/tracepath6.c
index 5c2db8f..77a3563 100644
--- a/tracepath6.c
+++ b/tracepath6.c
@@ -170,7 +170,7 @@ restart:
 #ifdef IPV6_2292HOPLIMIT
 			case IPV6_2292HOPLIMIT:
 #endif
-				rethops = *(int*)CMSG_DATA(cmsg);
+				memcpy(&rethops, CMSG_DATA(cmsg), sizeof(int));
 				break;
 			default:
 				printf("cmsg6:%d\n ", cmsg->cmsg_type);
-- 
1.7.9.7
