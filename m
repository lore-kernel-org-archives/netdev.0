From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2 1/7] ip/xfrm: Extend SPI validity checking
Date: Mon, 25 Mar 2013 10:23:13 -0400
Message-ID: <1364221399-1024-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:42066 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756682Ab3CYOX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 10:23:28 -0400
Received: from LLE2K7-HUB01.mitll.ad.local (LLE2K7-HUB01.mitll.ad.local) by mx2.ll.mit.edu (unknown) with ESMTP id r2PEN2cs023593 for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 10:23:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A Security Policy Index (SPI) is not used with Mobile IPv6. IPComp
uses a smaller 16-bit Compression Parameter Index (CPI) which is
passed as the SPI value. Perform checks whenever specifying an ID.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 ip/ipxfrm.c     |   12 ++++++++++++
 ip/xfrm_state.c |    5 -----
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index db51918..2576938 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -1067,6 +1067,18 @@ int xfrm_id_parse(xfrm_address_t *saddr, struct xfrm_id *id, __u16 *family,
 	if (src.family && dst.family && (src.family != dst.family))
 		invarg("the same address family is required between \"src\" and \"dst\"", *argv);
 
+	if (id->spi && id->proto) {
+		if (xfrm_xfrmproto_is_ro(id->proto)) {
+			fprintf(stderr, "\"spi\" is invalid with XFRM-PROTO value \"%s\"\n",
+			        strxf_xfrmproto(id->proto));
+			exit(1);
+		} else if (id->proto == IPPROTO_COMP && ntohl(id->spi) >= 0x10000) {
+			fprintf(stderr, "SPI value is too large with XFRM-PROTO value \"%s\"\n",
+			        strxf_xfrmproto(id->proto));
+			exit(1);
+		}
+	}
+
 	if (loose == 0 && id->proto == 0)
 		missarg("XFRM-PROTO");
 	if (argc == *argcp)
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index c0cf88c..3c01ec5 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -502,11 +502,6 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 				strxf_xfrmproto(req.xsinfo.id.proto));
 			exit(1);
 		}
-		if (req.xsinfo.id.spi != 0) {
-			fprintf(stderr, "\"spi\" must be 0 with proto=%s\n",
-				strxf_xfrmproto(req.xsinfo.id.proto));
-			exit(1);
-		}
 		break;
 	default:
 		break;
-- 
1.7.1
