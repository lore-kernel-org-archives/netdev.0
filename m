From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] bug.h: Add WARN_RATELIMIT
Date: Sat, 21 May 2011 10:48:39 -0700
Message-ID: <2dfb6f4e8110e5b09dbf4c8a1502bdf8955bb6ff.1305999731.git.joe@perches.com>
References: <1305666832.1722.62.camel@Joe-Laptop>
Cc: linux-arch@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>, Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305666832.1722.62.camel@Joe-Laptop>
In-Reply-To: <cover.1305999731.git.joe@perches.com>
References: <cover.1305999731.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a generic mechanism to ratelimit WARN(foo, fmt, ...) messages
using a hidden per call site static struct ratelimit_state.

Also add an __WARN_RATELIMIT variant to be able to use a specific
struct ratelimit_state.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/asm-generic/bug.h |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/include/asm-generic/bug.h b/include/asm-generic/bug.h
index e5a3f58..12b250c 100644
--- a/include/asm-generic/bug.h
+++ b/include/asm-generic/bug.h
@@ -165,6 +165,22 @@ extern void warn_slowpath_null(const char *file, const int line);
 #define WARN_ON_RATELIMIT(condition, state)			\
 		WARN_ON((condition) && __ratelimit(state))
 
+#define __WARN_RATELIMIT(condition, state, format...)		\
+({								\
+	int rtn = 0;						\
+	if (unlikely(__ratelimit(state)))			\
+		rtn = WARN(condition, format);			\
+	rtn;							\
+})
+
+#define WARN_RATELIMIT(condition, format...)			\
+({								\
+	static DEFINE_RATELIMIT_STATE(_rs,			\
+				      DEFAULT_RATELIMIT_INTERVAL,	\
+				      DEFAULT_RATELIMIT_BURST);	\
+	__WARN_RATELIMIT(condition, &_rs, format);		\
+})
+
 /*
  * WARN_ON_SMP() is for cases that the warning is either
  * meaningless for !SMP or may even cause failures.
-- 
1.7.5.rc3.dirty
