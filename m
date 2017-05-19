From: Antony Antony <antony@phenome.org>
Subject: [PATCH v2] xfrm: fix state migration copy replay sequence numbers
Date: Fri, 19 May 2017 12:47:00 +0200
Message-ID: <1495190820-14657-1-git-send-email-antony@phenome.org>
References: <20170518143953.GA64905@AntonyAntony.local>
Cc: Antony Antony <antony@phenome.org>,
        Richard Guy Briggs <rgb@tricolour.ca>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb3-smtp-cloud2.xs4all.net ([194.109.24.29]:36146 "EHLO
        lb3-smtp-cloud2.xs4all.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751143AbdESKrY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 06:47:24 -0400
In-Reply-To: <20170518143953.GA64905@AntonyAntony.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
Changes in v2:
  - include tcpdump output showing the problem in the commit message.

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
2.9.3
