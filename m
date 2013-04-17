From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] [IrDA]: small read past the end of array in debug code
Date: Wed, 17 Apr 2013 10:10:38 +0300
Message-ID: <20130417071038.GA7923@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40460 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965736Ab3DQHLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 03:11:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "reason" can come from skb->data[] and it hasn't been capped so it
can be from 0-255 instead of just 0-6.  For example in irlmp_state_dtr()
the code does:

	reason = skb->data[3];
	...
	irlmp_disconnect_indication(self, reason, skb);

Also LMREASON has a couple other values which don't have entries in the
irlmp_reasons[] array.  And 0xff is a valid reason as well which means
"unknown".

So far as I can see we don't actually care about "reason" except for in
the debug code.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/include/net/irda/irlmp.h b/include/net/irda/irlmp.h
index f741091..f132924 100644
--- a/include/net/irda/irlmp.h
+++ b/include/net/irda/irlmp.h
@@ -256,7 +256,8 @@ static inline __u32 irlmp_get_daddr(const struct lsap_cb *self)
 	return (self && self->lap) ? self->lap->daddr : 0;
 }
 
-extern const char *irlmp_reasons[];
+const char *irlmp_reason_str(LM_REASON reason);
+
 extern int sysctl_discovery_timeout;
 extern int sysctl_discovery_slots;
 extern int sysctl_discovery;
diff --git a/net/irda/irlmp.c b/net/irda/irlmp.c
index 6115a44..1064621 100644
--- a/net/irda/irlmp.c
+++ b/net/irda/irlmp.c
@@ -66,8 +66,15 @@ const char *irlmp_reasons[] = {
 	"LM_LAP_RESET",
 	"LM_INIT_DISCONNECT",
 	"ERROR, NOT USED",
+	"UNKNOWN",
 };
 
+const char *irlmp_reason_str(LM_REASON reason)
+{
+	reason = min_t(size_t, reason, ARRAY_SIZE(irlmp_reasons) - 1);
+	return irlmp_reasons[reason];
+}
+
 /*
  * Function irlmp_init (void)
  *
@@ -747,7 +754,8 @@ void irlmp_disconnect_indication(struct lsap_cb *self, LM_REASON reason,
 {
 	struct lsap_cb *lsap;
 
-	IRDA_DEBUG(1, "%s(), reason=%s\n", __func__, irlmp_reasons[reason]);
+	IRDA_DEBUG(1, "%s(), reason=%s [%d]\n", __func__,
+		   irlmp_reason_str(reason), reason);
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
 
diff --git a/net/irda/iriap.c b/net/irda/iriap.c
index 29340a9..e1b37f5 100644
--- a/net/irda/iriap.c
+++ b/net/irda/iriap.c
@@ -303,7 +303,8 @@ static void iriap_disconnect_indication(void *instance, void *sap,
 {
 	struct iriap_cb *self;
 
-	IRDA_DEBUG(4, "%s(), reason=%s\n", __func__, irlmp_reasons[reason]);
+	IRDA_DEBUG(4, "%s(), reason=%s [%d]\n", __func__,
+		   irlmp_reason_str(reason), reason);
 
 	self = instance;
 
