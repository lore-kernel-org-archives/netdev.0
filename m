From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: fix sparse error in csum_replace4()
Date: Fri, 15 May 2015 08:52:19 -0700
Message-ID: <1431705139.27831.106.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:37031 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934569AbbEOPwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 11:52:22 -0400
Received: by igbsb11 with SMTP id sb11so132817287igb.0
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 08:52:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

make C=2 CF=-D__CHECK_ENDIAN__ net/ipv4/netfilter/nf_nat_l3proto_ipv4.o
  CHECK   net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
include/net/checksum.h:125:64: warning: incorrect type in argument 2 (different base types)
include/net/checksum.h:125:64:    expected restricted __wsum [usertype] addend
include/net/checksum.h:125:64:    got restricted __be32 [usertype] from
include/net/checksum.h:125:71: warning: incorrect type in argument 2 (different base types)
include/net/checksum.h:125:71:    expected restricted __wsum [usertype] addend
include/net/checksum.h:125:71:    got restricted __be32 [usertype] to
include/net/checksum.h:125:64: warning: incorrect type in argument 2 (different base types)
include/net/checksum.h:125:64:    expected restricted __wsum [usertype] addend
include/net/checksum.h:125:64:    got restricted __be32 [usertype] from
include/net/checksum.h:125:71: warning: incorrect type in argument 2 (different base types)
include/net/checksum.h:125:71:    expected restricted __wsum [usertype] addend
include/net/checksum.h:125:71:    got restricted __be32 [usertype] to

Fixes: 4565af0d406b ("net: optimise csum_replace4()")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/checksum.h |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/checksum.h b/include/net/checksum.h
index 0a55ac715077d0aad820916f9daf979ae3dfd0fd..2d1d73cb773e9bd160f5c43bb58981ee8597b87c 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -122,7 +122,9 @@ static inline __wsum csum_partial_ext(const void *buff, int len, __wsum sum)
 
 static inline void csum_replace4(__sum16 *sum, __be32 from, __be32 to)
 {
-	*sum = csum_fold(csum_add(csum_sub(~csum_unfold(*sum), from), to));
+	__wsum tmp = csum_sub(~csum_unfold(*sum), (__force __wsum)from);
+
+	*sum = csum_fold(csum_add(tmp, (__force __wsum)to));
 }
 
 /* Implements RFC 1624 (Incremental Internet Checksum)
