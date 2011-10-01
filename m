From: Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH] bluetooth: macroize two small inlines to avoid module.h
Date: Fri, 30 Sep 2011 22:12:07 -0400
Message-ID: <1317435127-15649-1-git-send-email-paul.gortmaker@windriver.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
To: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

These two small inlines make calls to try_module_get() and
module_put() which would force us to keep module.h present
within yet another common include header.  We can avoid this
by turning them into macros.  The hci_dev_hold construct
is patterned off of raw_spin_trylock_irqsave() in spinlock.h

Signed-off-by: Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>

---

[This is something I've added to the module.h cleanup tree since
 the original module.h cleanup RFC patchset; sending here just for
 transparency and for any review comments.]

diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
index 8f441b8..9a77e8a 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -498,11 +498,15 @@ static inline void __hci_dev_put(struct hci_dev *d)
 		d->destruct(d);
 }
 
-static inline void hci_dev_put(struct hci_dev *d)
-{
-	__hci_dev_put(d);
-	module_put(d->owner);
-}
+/*
+ * hci_dev_put and hci_dev_hold are macros to avoid dragging all the
+ * overhead of all the modular infrastructure into this header.
+ */
+#define hci_dev_put(d)		\
+do {				\
+	__hci_dev_put(d);	\
+	module_put(d->owner);	\
+} while (0)
 
 static inline struct hci_dev *__hci_dev_hold(struct hci_dev *d)
 {
@@ -510,12 +514,10 @@ static inline struct hci_dev *__hci_dev_hold(struct hci_dev *d)
 	return d;
 }
 
-static inline struct hci_dev *hci_dev_hold(struct hci_dev *d)
-{
-	if (try_module_get(d->owner))
-		return __hci_dev_hold(d);
-	return NULL;
-}
+#define hci_dev_hold(d)						\
+({								\
+	try_module_get(d->owner) ? __hci_dev_hold(d) : NULL;	\
+})
 
 #define hci_dev_lock(d)		spin_lock(&d->lock)
 #define hci_dev_unlock(d)	spin_unlock(&d->lock)
-- 
1.7.6
