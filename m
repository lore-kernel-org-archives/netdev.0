From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2 5/7] ip/xfrm: Command syntax should not expect a key for compression
Date: Mon, 25 Mar 2013 10:23:17 -0400
Message-ID: <1364221399-1024-5-git-send-email-david.ward@ll.mit.edu>
References: <1364221399-1024-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:42077 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758257Ab3CYOX3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 10:23:29 -0400
Received: from LLE2K7-HUB01.mitll.ad.local (LLE2K7-HUB01.mitll.ad.local) by mx2.ll.mit.edu (unknown) with ESMTP id r2PEN2cw023593 for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 10:23:28 -0400
In-Reply-To: <1364221399-1024-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compression algorithms do not use a key.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 ip/xfrm_state.c    |   26 +++++++++++++++++---------
 man/man8/ip-xfrm.8 |   13 ++++++++-----
 2 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 08a4980..9b374ee 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -78,13 +78,14 @@ static void usage(void)
 	fprintf(stderr, "ALGO-LIST := [ ALGO-LIST ] ALGO\n");
 	fprintf(stderr, "ALGO := { ");
 	fprintf(stderr, "%s | ", strxf_algotype(XFRMA_ALG_CRYPT));
-	fprintf(stderr, "%s | ", strxf_algotype(XFRMA_ALG_AUTH));
-	fprintf(stderr, "%s", strxf_algotype(XFRMA_ALG_COMP));
+	fprintf(stderr, "%s", strxf_algotype(XFRMA_ALG_AUTH));
 	fprintf(stderr, " } ALGO-NAME ALGO-KEY |\n");
+	fprintf(stderr, "        %s", strxf_algotype(XFRMA_ALG_AUTH_TRUNC));
+	fprintf(stderr, " ALGO-NAME ALGO-KEY ALGO-TRUNC-LEN |\n");
 	fprintf(stderr, "        %s", strxf_algotype(XFRMA_ALG_AEAD));
 	fprintf(stderr, " ALGO-NAME ALGO-KEY ALGO-ICV-LEN |\n");
-	fprintf(stderr, "        %s", strxf_algotype(XFRMA_ALG_AUTH_TRUNC));
-	fprintf(stderr, " ALGO-NAME ALGO-KEY ALGO-TRUNC-LEN\n");
+	fprintf(stderr, "        %s", strxf_algotype(XFRMA_ALG_COMP));
+	fprintf(stderr, " ALGO-NAME\n");
  	fprintf(stderr, "MODE := transport | tunnel | ro | in_trigger | beet\n");
 	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
 	fprintf(stderr, "FLAG := noecn | decap-dscp | nopmtudisc | wildrecv | icmp | af-unspec | align4\n");
@@ -374,7 +375,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 				int len;
 				__u32 icvlen, trunclen;
 				char *name;
-				char *key;
+				char *key = "";
 				char *buf;
 
 				switch (type) {
@@ -409,10 +410,17 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 				NEXT_ARG();
 				name = *argv;
 
-				if (!NEXT_ARG_OK())
-					missarg("ALGO-KEY");
-				NEXT_ARG();
-				key = *argv;
+				switch (type) {
+				case XFRMA_ALG_AEAD:
+				case XFRMA_ALG_CRYPT:
+				case XFRMA_ALG_AUTH:
+				case XFRMA_ALG_AUTH_TRUNC:
+					if (!NEXT_ARG_OK())
+						missarg("ALGO-KEY");
+					NEXT_ARG();
+					key = *argv;
+					break;
+				}
 
 				buf = alg.u.alg.alg_key;
 				len = sizeof(alg.u.alg);
diff --git a/man/man8/ip-xfrm.8 b/man/man8/ip-xfrm.8
index f359773..6017bc2 100644
--- a/man/man8/ip-xfrm.8
+++ b/man/man8/ip-xfrm.8
@@ -117,14 +117,17 @@ ip-xfrm \- transform configuration
 
 .ti -8
 .IR ALGO " :="
-.RB "{ " enc " | " auth " | " comp " } " 
+.RB "{ " enc " | " auth " } " 
 .IR ALGO-NAME " " ALGO-KEY " |"
 .br
-.B  aead
-.IR ALGO-NAME " " ALGO-KEY " " ALGO-ICV-LEN  " |"
-.br
 .B auth-trunc
-.IR ALGO-NAME " " ALGO-KEY " " ALGO-TRUNC-LEN
+.IR ALGO-NAME " " ALGO-KEY " " ALGO-TRUNC-LEN " |"
+.br
+.B aead
+.IR ALGO-NAME " " ALGO-KEY " " ALGO-ICV-LEN " |"
+.br
+.B comp
+.IR ALGO-NAME
 
 .ti -8
 .IR MODE " := "
-- 
1.7.1
