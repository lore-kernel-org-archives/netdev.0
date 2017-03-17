From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 14/18] net, lapb: convert lapb_cb.refcnt from atomic_t to refcount_t
Date: Fri, 17 Mar 2017 13:12:55 +0200
Message-ID: <1489749179-12063-15-git-send-email-elena.reshetova@intel.com>
References: <1489749179-12063-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net, davem@davemloft.net,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru, 3chas3@gmail.com, ralf@linux-mips.org,
        stephen@networkplumber.org, jchapman@katalix.com, jhs@mojatatu.com,
        bridge@lists.linux-foundation.org, linux-hams@vger.kernel.org,
        linux-x25@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        marcel@holtmann.org, johan.hedberg@gmail.com, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:3494 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751425AbdCQLPu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Mar 2017 07:15:50 -0400
In-Reply-To: <1489749179-12063-1-git-send-email-elena.reshetova@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 include/net/lapb.h    | 3 ++-
 net/lapb/lapb_iface.c | 6 +++---
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/net/lapb.h b/include/net/lapb.h
index 9510f87..85e7737 100644
--- a/include/net/lapb.h
+++ b/include/net/lapb.h
@@ -1,6 +1,7 @@
 #ifndef _LAPB_H
 #define _LAPB_H 
 #include <linux/lapb.h>
+#include <linux/refcount.h>
 
 #define	LAPB_HEADER_LEN	20		/* LAPB over Ethernet + a bit more */
 
@@ -101,7 +102,7 @@ struct lapb_cb {
 	struct lapb_frame	frmr_data;
 	unsigned char		frmr_type;
 
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 };
 
 /* lapb_iface.c */
diff --git a/net/lapb/lapb_iface.c b/net/lapb/lapb_iface.c
index b50b64a..e15314e 100644
--- a/net/lapb/lapb_iface.c
+++ b/net/lapb/lapb_iface.c
@@ -54,12 +54,12 @@ static void lapb_free_cb(struct lapb_cb *lapb)
 
 static __inline__ void lapb_hold(struct lapb_cb *lapb)
 {
-	atomic_inc(&lapb->refcnt);
+	refcount_inc(&lapb->refcnt);
 }
 
 static __inline__ void lapb_put(struct lapb_cb *lapb)
 {
-	if (atomic_dec_and_test(&lapb->refcnt))
+	if (refcount_dec_and_test(&lapb->refcnt))
 		lapb_free_cb(lapb);
 }
 
@@ -136,7 +136,7 @@ static struct lapb_cb *lapb_create_cb(void)
 	lapb->mode    = LAPB_DEFAULT_MODE;
 	lapb->window  = LAPB_DEFAULT_WINDOW;
 	lapb->state   = LAPB_STATE_0;
-	atomic_set(&lapb->refcnt, 1);
+	refcount_set(&lapb->refcnt, 1);
 out:
 	return lapb;
 }
-- 
2.7.4
