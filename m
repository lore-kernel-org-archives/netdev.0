From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/5] netfilter: xt_hashlimit: Fix link error in 32bit arch because of 64bit division
Date: Thu,  6 Oct 2016 02:07:47 +0200
Message-ID: <1475712469-17000-4-git-send-email-pablo@netfilter.org>
References: <1475712469-17000-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1475712469-17000-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vishwanath Pai <vpai@akamai.com>

Division of 64bit integers will cause linker error undefined reference
to `__udivdi3'. Fix this by replacing divisions with div64_64

Fixes: 11d5f15723c9 ("netfilter: xt_hashlimit: Create revision 2 to ...")
Signed-off-by: Vishwanath Pai <vpai@akamai.com>
Acked-by: Maciej Żenczykowski <maze@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_hashlimit.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 44a095ecc7b7..2fab0c65aa94 100644
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
+		return div64_u64(user * HZ * CREDITS_PER_JIFFY_v1,
+				 XT_HASHLIMIT_SCALE);
 	} else {
 		if (user > 0xFFFFFFFFFFFFFFFF / (HZ*CREDITS_PER_JIFFY))
-			return (user / XT_HASHLIMIT_SCALE_v2) *\
-						HZ * CREDITS_PER_JIFFY;
+			return div64_u64(user, XT_HASHLIMIT_SCALE_v2)
+				* HZ * CREDITS_PER_JIFFY;
 
-		return (user * HZ * CREDITS_PER_JIFFY) / XT_HASHLIMIT_SCALE_v2;
+		return div64_u64(user * HZ * CREDITS_PER_JIFFY,
+				 XT_HASHLIMIT_SCALE_v2);
 	}
 }
 
-- 
2.1.4

