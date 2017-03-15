From: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Subject: [PATCH] SUNRPC: fix include for cmpxhg_relaxed()
Date: Wed, 15 Mar 2017 10:35:42 +0000
Message-ID: <1489574142-20856-1-git-send-email-mark.rutland@arm.com>
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
        Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
        "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
        Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Currently net/sunrpc/xprtmultipath.c is the only file outside of arch/
headers and asm-generic/ headers to include <asm/cmpxhcg.h>, apparently
for the use of cmpxchg_relaxed().

However, many architectures do not provide cmpxchg_relaxed() in their
<asm/cmpxhcg.h>, and it is necessary to include <linux/atomic.h> to get
this definition, as noted in Documentation/core-api/atomic_ops.rst:

  If someone wants to use xchg(), cmpxchg() and their variants,
  linux/atomic.h should be included rather than asm/cmpxchg.h, unless
  the code is in arch/* and can take care of itself.

Evidently we're getting the right header this via some transitive
include today, but this isn't something we can/should rely upon,
especially with ongoing rework of the atomic headers for KASAN
instrumentation.

Let's fix the code to include <linux/atomic.h>, avoiding fragility.

Signed-off-by: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Cc: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Cc: Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Cc: J. Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>
Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 net/sunrpc/xprtmultipath.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtmultipath.c b/net/sunrpc/xprtmultipath.c
index ae92a9e..3b1e856 100644
--- a/net/sunrpc/xprtmultipath.c
+++ b/net/sunrpc/xprtmultipath.c
@@ -12,7 +12,7 @@
 #include <linux/rcupdate.h>
 #include <linux/rculist.h>
 #include <linux/slab.h>
-#include <asm/cmpxchg.h>
+#include <linux/atomic.h>
 #include <linux/spinlock.h>
 #include <linux/sunrpc/xprt.h>
 #include <linux/sunrpc/addr.h>
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
