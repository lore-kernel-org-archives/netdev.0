From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 6/8] xfrm: check user specified spi for IPComp
Date: Thu, 19 Dec 2013 07:36:43 +0100
Message-ID: <1387435005-8987-7-git-send-email-steffen.klassert@secunet.com>
References: <1387435005-8987-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48204 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752232Ab3LSGhW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 01:37:22 -0500
In-Reply-To: <1387435005-8987-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>

IPComp connection between two hosts is broken if given spi bigger
than 0xffff.

OUTSPI=0x87
INSPI=0x11112

ip xfrm policy update dst 192.168.1.101 src 192.168.1.109 dir out action allow \
       tmpl dst 192.168.1.101 src 192.168.1.109 proto comp spi $OUTSPI
ip xfrm policy update src 192.168.1.101 dst 192.168.1.109 dir in action allow \
       tmpl src 192.168.1.101 dst 192.168.1.109 proto comp spi $INSPI

ip xfrm state add src 192.168.1.101 dst 192.168.1.109  proto comp spi $INSPI \
		comp deflate
ip xfrm state add dst 192.168.1.101 src 192.168.1.109  proto comp spi $OUTSPI \
		comp deflate

tcpdump can capture outbound ping packet, but inbound packet is
dropped with XfrmOutNoStates errors. It looks like spi value used
for IPComp is expected to be 16bits wide only.

Signed-off-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 16c8460..4027c42 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -181,7 +181,9 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 		    attrs[XFRMA_ALG_AEAD]	||
 		    attrs[XFRMA_ALG_CRYPT]	||
 		    attrs[XFRMA_ALG_COMP]	||
-		    attrs[XFRMA_TFCPAD])
+		    attrs[XFRMA_TFCPAD]		||
+		    (ntohl(p->id.spi) >= 0x10000))
+
 			goto out;
 		break;
 
-- 
1.7.9.5
