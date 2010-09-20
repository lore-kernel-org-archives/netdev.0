From: Ohad Ben-Cohen <ohad@wizery.com>
Subject: idr_get_new_exact ?
Date: Mon, 20 Sep 2010 16:11:31 +0200
Message-ID: <AANLkTi=ZLupVyFR0e2v-TLpeNWdw1bVMZUAhgyxLJ7OV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Jean Delvare (PC drivers, core)" <khali@linux-fr.org>,
	"Ben Dooks (embedded platforms)" <ben-linux@fluff.org>,
	Roland Dreier <rolandd@cisco.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Steve Wise <swise@chelsio.com>, Neil Brown <neilb@suse.de>,
	Paul Mackerras <paulus@samba.org>, linux-i2c@vger.kernel.org,
	linux-rdma@vger.kernel.org, dm-devel@redhat.com,
	linux-raid@vger.kernel.org, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Occasionally, drivers care about the value that idr associates with
their pointers.

Today we have idr_get_new_above() which allocates a new idr entry
above or equal to a given starting id, but sometimes drivers need to
force an exact value.

To overcome this small API gap, drivers are wrapping idr_get_new_above
and then either BUG_ON() or just call idr_remove() and returns -EBUSY
when idr allocates them an id which is different than their requested
value.

There are only a handful of users who need this (see below. especially
note the i2c comment :), but it might be nice to have such an API (a
bit less of code, and a bit less error prone).

Would something like the below be desirable/acceptable ?

(untested. and i just picked the simplest and straight-forward way to
implement this; obviously it's not optimal since there's no reason to
even allocate an id if we know it's not the id we're looking for. but
it's enough to get the idea, it's not a hot path, and it's what
drivers are doing today)

---
 drivers/i2c/i2c-core.c                 |    9 +------
 drivers/infiniband/core/cma.c          |    9 +------
 drivers/infiniband/hw/cxgb3/iwch.h     |    3 +-
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h |    3 +-
 drivers/md/dm.c                        |    8 +-----
 drivers/net/ppp_generic.c              |    7 +-----
 include/linux/idr.h                    |    1 +
 lib/idr.c                              |   39 ++++++++++++++++++++++++++++++++
 8 files changed, 46 insertions(+), 33 deletions(-)

diff --git a/drivers/i2c/i2c-core.c b/drivers/i2c/i2c-core.c
index 6649176..6220900 100644
--- a/drivers/i2c/i2c-core.c
+++ b/drivers/i2c/i2c-core.c
@@ -964,14 +964,7 @@ retry:
 		return -ENOMEM;

 	mutex_lock(&core_lock);
-	/* "above" here means "above or equal to", sigh;
-	 * we need the "equal to" result to force the result
-	 */
-	status = idr_get_new_above(&i2c_adapter_idr, adap, adap->nr, &id);
-	if (status == 0 && id != adap->nr) {
-		status = -EBUSY;
-		idr_remove(&i2c_adapter_idr, id);
-	}
+	status = idr_get_new_exact(&i2c_adapter_idr, adap, adap->nr, &id);
 	mutex_unlock(&core_lock);
 	if (status == -EAGAIN)
 		goto retry;
diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index b930b81..1756c99 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1945,23 +1945,16 @@ static int cma_alloc_port(struct idr *ps,
struct rdma_id_private *id_priv,
 		return -ENOMEM;

 	do {
-		ret = idr_get_new_above(ps, bind_list, snum, &port);
+		ret = idr_get_new_exact(ps, bind_list, snum, &port);
 	} while ((ret == -EAGAIN) && idr_pre_get(ps, GFP_KERNEL));

 	if (ret)
 		goto err1;

-	if (port != snum) {
-		ret = -EADDRNOTAVAIL;
-		goto err2;
-	}
-
 	bind_list->ps = ps;
 	bind_list->port = (unsigned short) port;
 	cma_bind_port(bind_list, id_priv);
 	return 0;
-err2:
-	idr_remove(ps, port);
 err1:
 	kfree(bind_list);
 	return ret;
diff --git a/drivers/infiniband/hw/cxgb3/iwch.h
b/drivers/infiniband/hw/cxgb3/iwch.h
index a1c4457..71d9cae 100644
--- a/drivers/infiniband/hw/cxgb3/iwch.h
+++ b/drivers/infiniband/hw/cxgb3/iwch.h
@@ -160,8 +160,7 @@ static inline int insert_handle(struct iwch_dev
*rhp, struct idr *idr,
 			return -ENOMEM;
 		}
 		spin_lock_irq(&rhp->lock);
-		ret = idr_get_new_above(idr, handle, id, &newid);
-		BUG_ON(newid != id);
+		ret = idr_get_new_exact(idr, handle, id, &newid);
 		spin_unlock_irq(&rhp->lock);
 	} while (ret == -EAGAIN);

diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
index ed459b8..45567b1 100644
--- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
+++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
@@ -190,8 +190,7 @@ static inline int insert_handle(struct c4iw_dev
*rhp, struct idr *idr,
 		if (!idr_pre_get(idr, GFP_KERNEL))
 			return -ENOMEM;
 		spin_lock_irq(&rhp->lock);
-		ret = idr_get_new_above(idr, handle, id, &newid);
-		BUG_ON(newid != id);
+		ret = idr_get_new_exact(idr, handle, id, &newid);
 		spin_unlock_irq(&rhp->lock);
 	} while (ret == -EAGAIN);

diff --git a/drivers/md/dm.c b/drivers/md/dm.c
index ac384b2..dee497c 100644
--- a/drivers/md/dm.c
+++ b/drivers/md/dm.c
@@ -1873,16 +1873,10 @@ static int specific_minor(int minor)
 		goto out;
 	}

-	r = idr_get_new_above(&_minor_idr, MINOR_ALLOCED, minor, &m);
+	r = idr_get_new_exact(&_minor_idr, MINOR_ALLOCED, minor, &m);
 	if (r)
 		goto out;

-	if (m != minor) {
-		idr_remove(&_minor_idr, m);
-		r = -EBUSY;
-		goto out;
-	}
-
 out:
 	spin_unlock(&_minor_lock);
 	return r;
diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 736b917..3bb63e5 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -2865,15 +2865,10 @@ again:
 		return -ENOMEM;
 	}

-	err = idr_get_new_above(p, ptr, n, &unit);
+	err = idr_get_new_exact(p, ptr, n, &unit);
 	if (err == -EAGAIN)
 		goto again;

-	if (unit != n) {
-		idr_remove(p, unit);
-		return -EINVAL;
-	}
-
 	return unit;
 }

diff --git a/include/linux/idr.h b/include/linux/idr.h
index e968db7..748b67e 100644
--- a/include/linux/idr.h
+++ b/include/linux/idr.h
@@ -104,6 +104,7 @@ void *idr_find(struct idr *idp, int id);
 int idr_pre_get(struct idr *idp, gfp_t gfp_mask);
 int idr_get_new(struct idr *idp, void *ptr, int *id);
 int idr_get_new_above(struct idr *idp, void *ptr, int starting_id, int *id);
+int idr_get_new_exact(struct idr *idp, void *ptr, int requested_id, int *id);
 int idr_for_each(struct idr *idp,
 		 int (*fn)(int id, void *p, void *data), void *data);
 void *idr_get_next(struct idr *idp, int *nextid);
diff --git a/lib/idr.c b/lib/idr.c
index 7f1a4f0..53cc161 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -430,6 +430,45 @@ void idr_remove(struct idr *idp, int id)
 EXPORT_SYMBOL(idr_remove);

 /**
+ * idr_get_new_exact - allocate new idr entry equal to a requested id
+ * @idp: idr handle
+ * @ptr: pointer you want associated with the id
+ * @requested_id: id to search for
+ * @id: pointer to the allocated handle
+ *
+ * This is the allocate id function.  It should be called with any
+ * required locks.
+ *
+ * If memory is required, it will return -EAGAIN, you should unlock
+ * and go back to the idr_pre_get() call.  If the idr is full, it will
+ * return -ENOSPC. If the requested id is already taken, it will return
+ * -EBUSY.
+ *
+ * @id returns @requested_id on success
+ */
+int idr_get_new_exact(struct idr *idp, void *ptr, int requested_id, int *id)
+{
+	int rv;
+
+	rv = idr_get_new_above_int(idp, ptr, requested_id);
+	/*
+	 * This is a cheap hack until the IDR code can be fixed to
+	 * return proper error values.
+	 */
+	if (rv < 0)
+		return _idr_rc_to_errno(rv);
+
+	if (requested_id != rv) {
+		idr_remove(idp, rv);
+		return -EBUSY;
+	}
+
+	*id = rv;
+	return 0;
+}
+EXPORT_SYMBOL(idr_get_new_exact);
+
+/**
  * idr_remove_all - remove all ids from the given idr tree
  * @idp: idr handle
  *
-- 
1.7.0.4
