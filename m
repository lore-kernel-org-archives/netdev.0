From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2 3/7] ip/xfrm: Improve transform protocol-specific parameter checking
Date: Mon, 25 Mar 2013 10:23:15 -0400
Message-ID: <1364221399-1024-3-git-send-email-david.ward@ll.mit.edu>
References: <1364221399-1024-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:42070 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758167Ab3CYOX3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 10:23:29 -0400
Received: from LLE2K7-HUB01.mitll.ad.local (LLE2K7-HUB01.mitll.ad.local) by mx2.ll.mit.edu (unknown) with ESMTP id r2PEN2cu023593 for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 10:23:28 -0400
In-Reply-To: <1364221399-1024-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ensure that only algorithms and modes supported by the transform
protocol are specified (so that errors are more obvious).

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 ip/xfrm_state.c |  108 ++++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 80 insertions(+), 28 deletions(-)

diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 85d3e35..08a4980 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -486,52 +486,104 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 		}
 	}
 
-	switch (req.xsinfo.mode) {
-	case XFRM_MODE_TRANSPORT:
-	case XFRM_MODE_TUNNEL:
-		if (!xfrm_xfrmproto_is_ipsec(req.xsinfo.id.proto)) {
-			fprintf(stderr, "\"mode\" is invalid with proto=%s\n",
+	if (xfrm_xfrmproto_is_ipsec(req.xsinfo.id.proto)) {
+		switch (req.xsinfo.mode) {
+		case XFRM_MODE_TRANSPORT:
+		case XFRM_MODE_TUNNEL:
+			break;
+		case XFRM_MODE_BEET:
+			if (req.xsinfo.id.proto == IPPROTO_ESP)
+				break;
+		default:
+			fprintf(stderr, "MODE value is invalid with XFRM-PROTO value \"%s\"\n",
 				strxf_xfrmproto(req.xsinfo.id.proto));
 			exit(1);
 		}
-		break;
-	case XFRM_MODE_ROUTEOPTIMIZATION:
-	case XFRM_MODE_IN_TRIGGER:
-		if (!xfrm_xfrmproto_is_ro(req.xsinfo.id.proto)) {
-			fprintf(stderr, "\"mode\" is invalid with proto=%s\n",
+
+		switch (req.xsinfo.id.proto) {
+		case IPPROTO_ESP:
+			if (calgop) {
+				fprintf(stderr, "ALGO-TYPE value \"%s\" is invalid with XFRM-PROTO value \"%s\"\n",
+					strxf_algotype(XFRMA_ALG_COMP),
+					strxf_xfrmproto(req.xsinfo.id.proto));
+				exit(1);
+			}
+			if (!ealgop && !aeadop) {
+				fprintf(stderr, "ALGO-TYPE value \"%s\" or \"%s\" is required with XFRM-PROTO value \"%s\"\n",
+					strxf_algotype(XFRMA_ALG_CRYPT),
+					strxf_algotype(XFRMA_ALG_AEAD),
+					strxf_xfrmproto(req.xsinfo.id.proto));
+				exit(1);
+			}
+			break;
+		case IPPROTO_AH:
+			if (ealgop || aeadop || calgop) {
+				fprintf(stderr, "ALGO-TYPE values \"%s\", \"%s\", and \"%s\" are invalid with XFRM-PROTO value \"%s\"\n",
+					strxf_algotype(XFRMA_ALG_CRYPT),
+					strxf_algotype(XFRMA_ALG_AEAD),
+					strxf_algotype(XFRMA_ALG_COMP),
+					strxf_xfrmproto(req.xsinfo.id.proto));
+				exit(1);
+			}
+			if (!aalgop) {
+				fprintf(stderr, "ALGO-TYPE value \"%s\" or \"%s\" is required with XFRM-PROTO value \"%s\"\n",
+					strxf_algotype(XFRMA_ALG_AUTH),
+					strxf_algotype(XFRMA_ALG_AUTH_TRUNC),
+					strxf_xfrmproto(req.xsinfo.id.proto));
+				exit(1);
+			}
+			break;
+		case IPPROTO_COMP:
+			if (ealgop || aalgop || aeadop) {
+				fprintf(stderr, "ALGO-TYPE values \"%s\", \"%s\", \"%s\", and \"%s\" are invalid with XFRM-PROTO value \"%s\"\n",
+					strxf_algotype(XFRMA_ALG_CRYPT),
+					strxf_algotype(XFRMA_ALG_AUTH),
+					strxf_algotype(XFRMA_ALG_AUTH_TRUNC),
+					strxf_algotype(XFRMA_ALG_AEAD),
+					strxf_xfrmproto(req.xsinfo.id.proto));
+				exit(1);
+			}
+			if (!calgop) {
+				fprintf(stderr, "ALGO-TYPE value \"%s\" is required with XFRM-PROTO value \"%s\"\n",
+					strxf_algotype(XFRMA_ALG_COMP),
+					strxf_xfrmproto(req.xsinfo.id.proto));
+				exit(1);
+			}
+			break;
+		}
+	} else {
+		if (ealgop || aalgop || aeadop || calgop) {
+			fprintf(stderr, "ALGO is invalid with XFRM-PROTO value \"%s\"\n",
 				strxf_xfrmproto(req.xsinfo.id.proto));
 			exit(1);
 		}
-		break;
-	default:
-		break;
 	}
 
-	if (aeadop || ealgop || aalgop || calgop) {
-		if (!xfrm_xfrmproto_is_ipsec(req.xsinfo.id.proto)) {
-			fprintf(stderr, "\"ALGO\" is invalid with proto=%s\n",
+	if (xfrm_xfrmproto_is_ro(req.xsinfo.id.proto)) {
+		switch (req.xsinfo.mode) {
+		case XFRM_MODE_ROUTEOPTIMIZATION:
+		case XFRM_MODE_IN_TRIGGER:
+			break;
+		case 0:
+			fprintf(stderr, "\"mode\" is required with XFRM-PROTO value \"%s\"\n",
 				strxf_xfrmproto(req.xsinfo.id.proto));
 			exit(1);
-		}
-	} else {
-		if (xfrm_xfrmproto_is_ipsec(req.xsinfo.id.proto)) {
-			fprintf(stderr, "\"ALGO\" is required with proto=%s\n",
+		default:
+			fprintf(stderr, "MODE value is invalid with XFRM-PROTO value \"%s\"\n",
 				strxf_xfrmproto(req.xsinfo.id.proto));
-			exit (1);
+			exit(1);
 		}
-	}
 
-	if (coap) {
-		if (!xfrm_xfrmproto_is_ro(req.xsinfo.id.proto)) {
-			fprintf(stderr, "\"coa\" is invalid with proto=%s\n",
+		if (!coap) {
+			fprintf(stderr, "\"coa\" is required with XFRM-PROTO value \"%s\"\n",
 				strxf_xfrmproto(req.xsinfo.id.proto));
 			exit(1);
 		}
 	} else {
-		if (xfrm_xfrmproto_is_ro(req.xsinfo.id.proto)) {
-			fprintf(stderr, "\"coa\" is required with proto=%s\n",
+		if (coap) {
+			fprintf(stderr, "\"coa\" is invalid with XFRM-PROTO value \"%s\"\n",
 				strxf_xfrmproto(req.xsinfo.id.proto));
-			exit (1);
+			exit(1);
 		}
 	}
 
-- 
1.7.1
