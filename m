From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next 1/3] xfrm: check user specified spi for IPComp
Date: Thu, 28 Nov 2013 10:52:39 +0800
Message-ID: <1385607161-27597-2-git-send-email-fan.du@windriver.com>
References: <1385607161-27597-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62447 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758668Ab3K1Cws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 21:52:48 -0500
In-Reply-To: <1385607161-27597-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPComp connection between two hosts is broken if given spi bigger
than 0xffff.

OUTSPI=0x87
INSPI=0x11112

ip xfrm policy update dst 192.168.1.101 src 192.168.1.109 dir out action allow \
       tmpl dst 192.168.1.101 src 192.168.1.109 proto comp spi $OUTSPI
ip xfrm policy update src 192.168.1.101 dst 192.168.1.109 dir in action allow \
       tmpl src 192.168.1.101 dst 192.168.1.109 proto comp spi $INSPI

ip xfrm state add src 192.168.1.101 dst 192.168.1.109  proto comp spi $INSPI \
		comp deflate "0x1111"
ip xfrm state add dst 192.168.1.101 src 192.168.1.109  proto comp spi $OUTSPI \
		comp deflate "0x1111"

tcpdump can capture outbound ping packet, but inbound packet is
dropped with XfrmOutNoStates errors. It looks like spi value used
for IPComp is expected to be 16bits wide only.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/xfrm/xfrm_user.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index f964d4c..52efe71 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -209,7 +209,8 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 		    attrs[XFRMA_ALG_AUTH]	||
 		    attrs[XFRMA_ALG_AUTH_TRUNC]	||
 		    attrs[XFRMA_ALG_CRYPT]	||
-		    attrs[XFRMA_TFCPAD])
+		    attrs[XFRMA_TFCPAD] ||
+			(ntohl(p->id.spi) >= 0x10000))
 			goto out;
 		break;
 
-- 
1.7.9.5
