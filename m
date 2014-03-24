From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: optimize csum_replace2()
Date: Sun, 23 Mar 2014 19:51:36 -0700
Message-ID: <1395629496.9117.47.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140321.140730.1007660405690890605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, hkchu@google.com, mwdalton@google.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:34846 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbaCXCvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2014 22:51:39 -0400
Received: by mail-ie0-f179.google.com with SMTP id lx4so4965876iec.10
        for <netdev@vger.kernel.org>; Sun, 23 Mar 2014 19:51:39 -0700 (PDT)
In-Reply-To: <20140321.140730.1007660405690890605.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When changing one 16bit value by another in IP header, we can adjust the
IP checksum by doing a simple operation described in RFC 1624,
as reminded by David.

csum_partial() is a complex function on x86_64, not really suited
for small number of checksummed bytes.

I spotted csum_partial() being in the top 20 most consuming
functions (more than 1 %) in a GRO workload, which was rather
unexpected.

The caller was inet_gro_complete() doing a csum_replace2() when
building the new IP header for the GRO packet.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/checksum.h |   23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff --git a/include/net/checksum.h b/include/net/checksum.h
index 37a0e24adbe7..a28f4e0f6251 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -69,6 +69,19 @@ static inline __wsum csum_sub(__wsum csum, __wsum addend)
 	return csum_add(csum, ~addend);
 }
 
+static inline __sum16 csum16_add(__sum16 csum, __be16 addend)
+{
+	u16 res = (__force u16)csum;
+
+	res += (__force u16)addend;
+	return (__force __sum16)(res + (res < (__force u16)addend));
+}
+
+static inline __sum16 csum16_sub(__sum16 csum, __be16 addend)
+{
+	return csum16_add(csum, ~addend);
+}
+
 static inline __wsum
 csum_block_add(__wsum csum, __wsum csum2, int offset)
 {
@@ -112,9 +125,15 @@ static inline void csum_replace4(__sum16 *sum, __be32 from, __be32 to)
 	*sum = csum_fold(csum_partial(diff, sizeof(diff), ~csum_unfold(*sum)));
 }
 
-static inline void csum_replace2(__sum16 *sum, __be16 from, __be16 to)
+/* Implements RFC 1624 (Incremental Internet Checksum)
+ * 3. Discussion states :
+ *     HC' = ~(~HC + ~m + m')
+ *  m : old value of a 16bit field
+ *  m' : new value of a 16bit field
+ */
+static inline void csum_replace2(__sum16 *sum, __be16 old, __be16 new)
 {
-	csum_replace4(sum, (__force __be32)from, (__force __be32)to);
+	*sum = ~csum16_add(csum16_sub(~(*sum), old), new);
 }
 
 struct sk_buff;
