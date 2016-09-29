From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH net-next v3] netfilter: xt_hashlimit: Fix link error in 32bit
 arch because of 64bit division
Date: Thu, 29 Sep 2016 13:39:50 -0400
Message-ID: <20160929173950.GA27689@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johunt@akamai.com, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        pai.vishwain@gmail.com, kaber@trash.net, kadlec@blackhole.kfki.hu,
        zlpnobody@gmail.com, hannes@stressinduktion.org, maze@google.com,
        eric.dumazet@gmail.com, akpm@linux-foundation.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:54589 "EHLO
        prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934123AbcI2Rjv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 13:39:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2:
Remove unnecessary div64_u64 around constants

v3:
remove backslashes

--

Fix link error in 32bit arch because of 64bit division

Division of 64bit integers will cause linker error undefined reference
to `__udivdi3'. Fix this by replacing divisions with div64_64

Signed-off-by: Vishwanath Pai <vpai@akamai.com>
Fixes: 11d5f15723c9 ("netfilter: xt_hashlimit: Create revision 2 to ...")

---
 net/netfilter/xt_hashlimit.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 44a095e..faf65f1 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -467,17 +467,18 @@ static u64 user2credits(u64 user, int revision)
 		/* If multiplying would overflow... */
 		if (user > 0xFFFFFFFF / (HZ*CREDITS_PER_JIFFY_v1))
 			/* Divide first. */
-			return (user / XT_HASHLIMIT_SCALE) *\
-						HZ * CREDITS_PER_JIFFY_v1;
+			return div64_u64(user, XT_HASHLIMIT_SCALE)
+				* HZ * CREDITS_PER_JIFFY_v1;
 
-		return (user * HZ * CREDITS_PER_JIFFY_v1) \
-						/ XT_HASHLIMIT_SCALE;
+		return div64_u64((user * HZ * CREDITS_PER_JIFFY_v1),
+				 XT_HASHLIMIT_SCALE);
 	} else {
 		if (user > 0xFFFFFFFFFFFFFFFF / (HZ*CREDITS_PER_JIFFY))
-			return (user / XT_HASHLIMIT_SCALE_v2) *\
-						HZ * CREDITS_PER_JIFFY;
+			return div64_u64(user, XT_HASHLIMIT_SCALE_v2)
+				* HZ * CREDITS_PER_JIFFY;
 
-		return (user * HZ * CREDITS_PER_JIFFY) / XT_HASHLIMIT_SCALE_v2;
+		return div64_u64((user * HZ * CREDITS_PER_JIFFY),
+				 XT_HASHLIMIT_SCALE_v2);
 	}
 }
 
-- 
1.9.1
