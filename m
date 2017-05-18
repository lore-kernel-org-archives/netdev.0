From: Antony Antony <antony@phenome.org>
Subject: [PATCH] xfrm: fix state migration replay sequence numbers
Date: Thu, 18 May 2017 16:39:53 +0200
Message-ID: <20170518143953.GA64905@AntonyAntony.local>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="45Z9DzgjV8m4Oswq"
Cc: Richard Guy Briggs <rgb@tricolour.ca>,
        Antony Antony <antony@phenome.org>
To: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb3-smtp-cloud3.xs4all.net ([194.109.24.30]:54610 "EHLO
        lb3-smtp-cloud3.xs4all.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932593AbdEROkJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:40:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

During xfrm migration replay and preplay sequence numbers are not 
copied from the previous state. 

Here is tcpdump output showing the problem.
10.0.10.46 is running vanilla kernel, IKE/IPsec responder.
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

The attached patch fix it by copying replay and preplay.

regards,
-antony

Antony Antony (1):
  xfrm: fix state migration replay sequence numbers

 net/xfrm/xfrm_state.c | 2 ++
 1 file changed, 2 insertions(+)

-- 
2.9.3


--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-xfrm-fix-state-migration.patch"

>From 1241e8b4c38ad2bf7399599165f763af38aba8d9 Mon Sep 17 00:00:00 2001
From: Antony Antony <antony@phenome.org>
Date: Thu, 18 May 2017 12:19:32 +0200
Subject: [PATCH] xfrm: fix state migration copy replay sequence numbers
To: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Steffen Klassert <steffen.klassert@secunet.com>
Cc: Richard Guy Briggs <rgb@tricolour.ca>

During xfrm migration copy replay and preplay sequence numbers
from the previous state.

Signed-off-by: Antony Antony <antony@phenome.org>
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
2.9.3


--45Z9DzgjV8m4Oswq--
