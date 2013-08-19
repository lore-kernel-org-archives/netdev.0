From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: raise IP_MAX_MTU to theoretical limit
Date: Sun, 18 Aug 2013 19:08:07 -0700
Message-ID: <1376878087.4226.41.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33818 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754281Ab3HSCIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 22:08:11 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj1so4036492pad.28
        for <netdev@vger.kernel.org>; Sun, 18 Aug 2013 19:08:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

As discussed last year [1], there is no compelling reason
to limit IPv4 MTU to 0xFFF0, while real limit is 0xFFFF

[1] : http://marc.info/?l=linux-netdev&m=135607247609434&w=2

Willem raised this issue again because some of our internal
regression tests broke after lo mtu being set to 65536.

IP_MTU reports 0xFFF0, and the test attempts to send a RAW datagram of
mtu + 1 bytes, expecting the send() to fail, but it does not.

Alexey raised interesting points about TCP MSS, that should be addressed
in follow-up patches in TCP stack if needed, as someone could also set
an odd mtu anyway.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/route.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e805481..727f436 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -112,7 +112,8 @@
 #define RT_FL_TOS(oldflp4) \
 	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
 
-#define IP_MAX_MTU	0xFFF0
+/* IPv4 datagram length is stored into 16bit field (tot_len) */
+#define IP_MAX_MTU	0xFFFF
 
 #define RT_GC_TIMEOUT (300*HZ)
 
@@ -1227,10 +1228,7 @@ static unsigned int ipv4_mtu(const struct dst_entry *dst)
 			mtu = 576;
 	}
 
-	if (mtu > IP_MAX_MTU)
-		mtu = IP_MAX_MTU;
-
-	return mtu;
+	return min_t(unsigned int, mtu, IP_MAX_MTU);
 }
 
 static struct fib_nh_exception *find_exception(struct fib_nh *nh, __be32 daddr)
