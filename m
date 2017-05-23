From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/5] xfrm: fix state migration copy replay sequence numbers
Date: Tue, 23 May 2017 07:33:44 +0200
Message-ID: <1495517624-27096-6-git-send-email-steffen.klassert@secunet.com>
References: <1495517624-27096-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:45158 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934866AbdEWFdz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 01:33:55 -0400
In-Reply-To: <1495517624-27096-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antony Antony <antony@phenome.org>

During xfrm migration copy replay and preplay sequence numbers
from the previous state.

Here is a tcpdump output showing the problem.
10.0.10.46 is running vanilla kernel, is the IKE/IPsec responder.
After the migration it sent wrong sequence number, reset to 1.
The migration is from 10.0.0.52 to 10.0.0.53.

IP 10.0.0.52.4500 > 10.0.10.46.4500: UDP-encap: ESP(spi=0x43ef462d,seq=0x7cf), length 136
IP 10.0.10.46.4500 > 10.0.0.52.4500: UDP-encap: ESP(spi=0xca1c282d,seq=0x7cf), length 136
IP 10.0.0.52.4500 > 10.0.10.46.4500: UDP-encap: ESP(spi=0x43ef462d,seq=0x7d0), length 136
IP 10.0.10.46.4500 > 10.0.0.52.4500: UDP-encap: ESP(spi=0xca1c282d,seq=0x7d0), length 136

IP 10.0.0.53.4500 > 10.0.10.46.4500: NONESP-encap: isakmp: child_sa  inf2[I]
IP 10.0.10.46.4500 > 10.0.0.53.4500: NONESP-encap: isakmp: child_sa  inf2[R]
IP 10.0.0.53.4500 > 10.0.10.46.4500: NONESP-encap: isakmp: child_sa  inf2[I]
IP 10.0.10.46.4500 > 10.0.0.53.4500: NONESP-encap: isakmp: child_sa  inf2[R]

IP 10.0.0.53.4500 > 10.0.10.46.4500: UDP-encap: ESP(spi=0x43ef462d,seq=0x7d1), length 136

NOTE: next sequence is wrong 0x1

IP 10.0.10.46.4500 > 10.0.0.53.4500: UDP-encap: ESP(spi=0xca1c282d,seq=0x1), length 136
IP 10.0.0.53.4500 > 10.0.10.46.4500: UDP-encap: ESP(spi=0x43ef462d,seq=0x7d2), length 136
IP 10.0.10.46.4500 > 10.0.0.53.4500: UDP-encap: ESP(spi=0xca1c282d,seq=0x2), length 136

Signed-off-by: Antony Antony <antony@phenome.org>
Reviewed-by: Richard Guy Briggs <rgb@tricolour.ca>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index fc3c5aa..2e291bc 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1383,6 +1383,8 @@ static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig)
 	x->curlft.add_time = orig->curlft.add_time;
 	x->km.state = orig->km.state;
 	x->km.seq = orig->km.seq;
+	x->replay = orig->replay;
+	x->preplay = orig->preplay;
 
 	return x;
 
-- 
2.7.4
