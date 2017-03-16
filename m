From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 10/17] net: convert in_device.refcnt from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 17:29:00 +0200
Message-ID: <1489678147-21404-11-git-send-email-elena.reshetova@intel.com>
References: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
Cc: bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        stephen@networkplumber.org, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 include/linux/inetdevice.h | 11 ++++++-----
 net/ipv4/devinet.c         |  2 +-
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index ee971f3..5cd9671 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -11,6 +11,7 @@
 #include <linux/timer.h>
 #include <linux/sysctl.h>
 #include <linux/rtnetlink.h>
+#include <linux/refcount.h>
 
 struct ipv4_devconf {
 	void	*sysctl;
@@ -22,7 +23,7 @@ struct ipv4_devconf {
 
 struct in_device {
 	struct net_device	*dev;
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 	int			dead;
 	struct in_ifaddr	*ifa_list;	/* IP ifaddr chain		*/
 
@@ -212,7 +213,7 @@ static inline struct in_device *in_dev_get(const struct net_device *dev)
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dev);
 	if (in_dev)
-		atomic_inc(&in_dev->refcnt);
+		refcount_inc(&in_dev->refcnt);
 	rcu_read_unlock();
 	return in_dev;
 }
@@ -233,12 +234,12 @@ void in_dev_finish_destroy(struct in_device *idev);
 
 static inline void in_dev_put(struct in_device *idev)
 {
-	if (atomic_dec_and_test(&idev->refcnt))
+	if (refcount_dec_and_test(&idev->refcnt))
 		in_dev_finish_destroy(idev);
 }
 
-#define __in_dev_put(idev)  atomic_dec(&(idev)->refcnt)
-#define in_dev_hold(idev)   atomic_inc(&(idev)->refcnt)
+#define __in_dev_put(idev)  refcount_dec(&(idev)->refcnt)
+#define in_dev_hold(idev)   refcount_inc(&(idev)->refcnt)
 
 #endif /* __KERNEL__ */
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index cebedd5..1527146 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -251,7 +251,7 @@ static struct in_device *inetdev_init(struct net_device *dev)
 	/* Reference in_dev->dev */
 	dev_hold(dev);
 	/* Account for reference dev->ip_ptr (below) */
-	in_dev_hold(in_dev);
+	refcount_set(&in_dev->refcnt, 1);
 
 	err = devinet_sysctl_register(in_dev);
 	if (err) {
-- 
2.7.4
