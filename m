From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH v2] netfilter: xt_hashlimit: Fix link error in 32bit arch
 because of 64bit division
Date: Tue, 27 Sep 2016 09:57:18 -0400
Message-ID: <20160927135718.GA31297@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johunt@akamai.com, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        pai.vishwain@gmail.com, kaber@trash.net, kadlec@blackhole.kfki.hu,
        zlpnobody@gmail.com, hannes@stressinduktion.org, maze@google.com,
        eric.dumazet@gmail.com
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v2:
Remove unnecessary div64_u64 around constants

--

Fix link error in 32bit arch because of 64bit division

Division of 64bit integers will cause linker error undefined reference
to `__udivdi3'. Fix this by replacing divisions with div64_64

Signed-off-by: Vishwanath Pai <vpai@akamai.com>

---
 net/netfilter/xt_hashlimit.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 44a095e..200a9d8 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -467,17 +467,18 @@ static u64 user2credits(u64 user, int revision)
 		/* If multiplying would overflow... */
 		if (user > 0xFFFFFFFF / (HZ*CREDITS_PER_JIFFY_v1))
 			/* Divide first. */
-			return (user / XT_HASHLIMIT_SCALE) *\
+			return div64_u64(user, XT_HASHLIMIT_SCALE) *\
 						HZ * CREDITS_PER_JIFFY_v1;
 
-		return (user * HZ * CREDITS_PER_JIFFY_v1) \
-						/ XT_HASHLIMIT_SCALE;
+		return div64_u64((user * HZ * CREDITS_PER_JIFFY_v1),
+				  XT_HASHLIMIT_SCALE);
 	} else {
 		if (user > 0xFFFFFFFFFFFFFFFF / (HZ*CREDITS_PER_JIFFY))
-			return (user / XT_HASHLIMIT_SCALE_v2) *\
+			return div64_u64(user, XT_HASHLIMIT_SCALE_v2) *\
 						HZ * CREDITS_PER_JIFFY;
 
-		return (user * HZ * CREDITS_PER_JIFFY) / XT_HASHLIMIT_SCALE_v2;
+		return div64_u64((user * HZ * CREDITS_PER_JIFFY),
+				 XT_HASHLIMIT_SCALE_v2);
 	}
 }
 
-- 
1.9.1

