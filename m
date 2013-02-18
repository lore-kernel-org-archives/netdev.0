From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 1/9] bnx2x: Prevent NULL pointer dereference in
 vlan-mac
Date: Mon, 18 Feb 2013 10:16:30 +0200
Message-ID: <1361175398-12888-2-git-send-email-yuvalmin@broadcom.com>
References: <1361175398-12888-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2381 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757409Ab3BRJVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 04:21:22 -0500
In-Reply-To: <1361175398-12888-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When setting the vlan mac configuration in the bnx2x driver, there is a
registry list (shadow list) which was accessed without a lock.

Under specific stress-testing tests, it was possible to have a NULL pointer
dereference as one context would have emptied the list while the other
accessed its elements.

This adds a variation on a classical single writer, multiple reader lock
in which writers don't wait for the list to be accessible but rather pend
their request to be performed once the list is available. This prevents said
issue.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c    |  433 ++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h    |   18 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |    9 +-
 3 files changed, 448 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 7306416..96dcc92 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -184,6 +184,7 @@ static inline void bnx2x_exe_queue_reset_pending(struct bnx2x *bp,
  * (Atomicy is ensured using the exe_queue->lock).
  */
 static inline int bnx2x_exe_queue_step(struct bnx2x *bp,
+				       struct bnx2x_vlan_mac_obj *vobj,
 				       struct bnx2x_exe_queue_obj *o,
 				       unsigned long *ramrod_flags)
 {
@@ -194,6 +195,13 @@ static inline int bnx2x_exe_queue_step(struct bnx2x *bp,
 
 	spin_lock_bh(&o->lock);
 
+	/* From here on we're under the context of the execution queue lock.
+	 * Whether or not an execution will be made, we can clear the vlan_mac
+	 * head pending execution reference, since accessing it must also be
+	 * done under this lock (there's no chance for race)
+	 */
+	vobj->head_exe = false;
+
 	/*
 	 * Next step should not be performed until the current is finished,
 	 * unless a DRV_CLEAR_ONLY bit is set. In this case we just want to
@@ -443,12 +451,333 @@ static bool bnx2x_put_credit_vlan_mac(struct bnx2x_vlan_mac_obj *o)
 	return true;
 }
 
+#define BNX2X_VLAN_MAC_H_LOCK_TIMEOUT	(5000)
+/**
+ * __bnx2x_vlan_mac_h_write_trylock - try getting the writer lock on vlan mac
+ * head list.
+ *
+ * @bp:		device handle
+ * @o:		vlan_mac object
+ *
+ * @details: Non-blocking implementation; should be called under execution
+ *           queue lock.
+ */
+static int __bnx2x_vlan_mac_h_write_trylock(struct bnx2x *bp,
+					    struct bnx2x_vlan_mac_obj *o)
+{
+	if (o->head_writer || o->head_reader) {
+		DP(BNX2X_MSG_SP, "vlan_mac_lock writer - Can't take; Busy\n");
+		return -EBUSY;
+	}
+
+	o->head_writer = true;
+	o->head_exe = true;
+	DP(BNX2X_MSG_SP, "vlan_mac_lock writer - Taken\n");
+	return 0;
+}
+
+/**
+ * __bnx2x_vlan_mac_h_write_lock - takes writer lock on vlan mac head list
+ *
+ * @bp:		device handle
+ * @o:		vlan_mac object
+ *
+ * @details May sleep. Should be called under execution queue lock; notice it
+ *          might release and reclaim it during its run.
+ */
+static int __bnx2x_vlan_mac_h_write_lock(struct bnx2x *bp,
+					   struct bnx2x_vlan_mac_obj *o)
+{
+	spinlock_t *lock = &o->exe_queue.lock;
+	int rc = 0, time_left = BNX2X_VLAN_MAC_H_LOCK_TIMEOUT;
+
+	DP(BNX2X_MSG_SP, "vlan_mac_lock - Trying to lock writer...\n");
+	while (time_left &&
+	       (__bnx2x_vlan_mac_h_write_trylock(bp, o) != 0)) {
+		spin_unlock_bh(lock);
+		usleep_range(1000, 2000);
+		time_left--;
+		spin_lock_bh(lock);
+	}
+
+	if (!time_left) {
+		BNX2X_ERR("Failed to get vlan_mac_lock (writer)\n");
+#ifdef BNX2X_STOP_ON_ERROR
+		bnx2x_panic();
+#endif
+		rc = -EBUSY;
+	} else {
+		DP(BNX2X_MSG_SP, "Got vlan_mac_lock (writer) after %d iterations\n",
+		   BNX2X_VLAN_MAC_H_LOCK_TIMEOUT - time_left);
+	}
+
+	return rc;
+}
+
+/**
+ * bnx2x_vlan_mac_h_write_lock - takes writer lock on vlan mac head list
+ *
+ * @bp:		device handle
+ * @o:		vlan_mac object
+ *
+ * @details May sleep. Notice it claims & releases the execution queue's lock.
+ */
+int bnx2x_vlan_mac_h_write_lock(struct bnx2x *bp,
+				struct bnx2x_vlan_mac_obj *o)
+{
+	int rc;
+
+	spin_lock_bh(&o->exe_queue.lock);
+	rc = __bnx2x_vlan_mac_h_write_lock(bp, o);
+	spin_unlock_bh(&o->exe_queue.lock);
+
+	return rc;
+}
+
+/**
+ * __bnx2x_vlan_mac_h_exec_pending - execute step instead of a previous step
+ * which wasn't able to run due to a taken lock on vlan mac head list.
+ *
+ * @bp:		device handle
+ * @o:		vlan_mac object
+ *
+ * @details Should be called under execution queue lock; notice it might release
+ *          and reclaim it during its run.
+ */
+static void __bnx2x_vlan_mac_h_exec_pending(struct bnx2x *bp,
+					    struct bnx2x_vlan_mac_obj *o)
+{
+	int rc;
+	unsigned long ramrod_flags = o->saved_ramrod_flags;
+
+	if (!o->head_writer) {
+		BNX2X_ERR("vlan_mac_lock - Need to execute pending command, but writer isn't marked\n");
+#ifdef BNX2X_STOP_ON_ERROR
+		bnx2x_panic();
+#endif
+	}
+
+	DP(BNX2X_MSG_SP, "vlan_mac_lock execute pending command with ramrod flags %lu\n",
+	   ramrod_flags);
+	o->head_exe = true;
+	o->head_exe_request = false;
+	o->saved_ramrod_flags = 0;
+	spin_unlock_bh(&o->exe_queue.lock);
+	rc = bnx2x_exe_queue_step(bp, o, &o->exe_queue, &ramrod_flags);
+	if (rc != 0) {
+		BNX2X_ERR("execution of pending commands failed with rc %d\n",
+			  rc);
+#ifdef BNX2X_STOP_ON_ERROR
+		bnx2x_panic();
+#endif
+	}
+	spin_lock_bh(&o->exe_queue.lock);
+}
+
+/**
+ * __bnx2x_vlan_mac_h_pend - Pend an execution step which couldn't have been
+ * called due to vlan mac head list lock being taken.
+ *
+ * @bp:			device handle
+ * @o:			vlan_mac object
+ * @ramrod_flags:	ramrod flags of missed execution
+ *
+ * @details Should be called under execution queue lock.
+ */
+static void __bnx2x_vlan_mac_h_pend(struct bnx2x *bp,
+				    struct bnx2x_vlan_mac_obj *o,
+				    unsigned long ramrod_flags)
+{
+	if (!o->head_exe) {
+		o->head_exe_request = true;
+		o->saved_ramrod_flags = ramrod_flags;
+		DP(BNX2X_MSG_SP, "Placing pending execution with ramrod flags %lu\n",
+		   ramrod_flags);
+	} else {
+		/* Since an executor is on the field, he will step whatever
+		 * we do. We can simply cease - no need to pend a command.
+		 */
+		DP(BNX2X_MSG_SP, "Skipping pending execution with ramrod flags %lu\n",
+		   ramrod_flags);
+	}
+}
+
+/**
+ * __bnx2x_vlan_mac_h_write_unlock - unlock the vlan mac head list writer lock
+ *
+ * @bp:			device handle
+ * @o:			vlan_mac object
+ *
+ * @details Should be called under execution queue lock. Notice if a pending
+ *          execution exists, it would perform it - possibly releasing and
+ *          reclaiming the execution queue lock.
+ */
+static void __bnx2x_vlan_mac_h_write_unlock(struct bnx2x *bp,
+					    struct bnx2x_vlan_mac_obj *o)
+{
+	/* When releasing a writer lock, exec. was supposed to prev. happen */
+	if (!o->head_writer) {
+		BNX2X_ERR("Need to release vlan mac writer lock, but lock isn't taken properly (%d)\n",
+			  o->head_writer);
+#ifdef BNX2X_STOP_ON_ERROR
+		bnx2x_panic();
+#endif
+	}
+	if (o->head_exe)
+		BNX2X_ERR("Need to release vlan mac writer lock, but execution wasn't performed (%d)\n",
+			  o->head_exe);
+
+	/* It's possible a new pending execution was added since this writer
+	 * executed. If so, execute again. [Ad infinitum]
+	 */
+	while (o->head_exe_request) {
+		DP(BNX2X_MSG_SP, "vlan_mac_lock - writer release encountered a pending request\n");
+		__bnx2x_vlan_mac_h_exec_pending(bp, o);
+	}
+
+	o->head_writer = false;
+}
+
+/**
+ * bnx2x_vlan_mac_h_write_unlock - unlock the vlan mac head list writer lock
+ *
+ * @bp:			device handle
+ * @o:			vlan_mac object
+ *
+ * @details Notice if a pending execution exists, it would perform it -
+ *          possibly releasing and reclaiming the execution queue lock.
+ */
+void bnx2x_vlan_mac_h_write_unlock(struct bnx2x *bp,
+				   struct bnx2x_vlan_mac_obj *o)
+{
+	spin_lock_bh(&o->exe_queue.lock);
+	__bnx2x_vlan_mac_h_write_unlock(bp, o);
+	spin_unlock_bh(&o->exe_queue.lock);
+}
+
+/**
+ * __bnx2x_vlan_mac_h_read_lock - lock the vlan mac head list reader lock
+ *
+ * @bp:			device handle
+ * @o:			vlan_mac object
+ *
+ * @details Should be called under the execution queue lock. May sleep. May
+ *          release and reclaim execution queue lock during its run.
+ */
+static int __bnx2x_vlan_mac_h_read_lock(struct bnx2x *bp,
+					struct bnx2x_vlan_mac_obj *o)
+{
+	spinlock_t *lock = &o->exe_queue.lock;
+	int rc = 0, time_left = BNX2X_VLAN_MAC_H_LOCK_TIMEOUT;
+
+	DP(BNX2X_MSG_SP, "vlan_mac_lock - Trying to lock reader...\n");
+	while (time_left && o->head_writer) {
+		spin_unlock_bh(lock);
+		usleep_range(1000, 2000);
+		time_left--;
+		spin_lock_bh(lock);
+	}
+
+	if (!time_left) {
+		BNX2X_ERR("vlan_mac_lock - Failed to get reader lock\n");
+#ifdef BNX2X_STOP_ON_ERROR
+		bnx2x_panic();
+#endif
+		rc = -EBUSY;
+	} else {
+		o->head_reader++;
+		DP(BNX2X_MSG_SP, "vlan_mac_lock - locked reader - number %d\n",
+		   o->head_reader);
+	}
+
+	return rc;
+}
+
+/**
+ * bnx2x_vlan_mac_h_read_lock - lock the vlan mac head list reader lock
+ *
+ * @bp:			device handle
+ * @o:			vlan_mac object
+ *
+ * @details May sleep. Claims and releases execution queue lock during its run.
+ */
+int bnx2x_vlan_mac_h_read_lock(struct bnx2x *bp,
+			       struct bnx2x_vlan_mac_obj *o)
+{
+	int rc;
+
+	spin_lock_bh(&o->exe_queue.lock);
+	rc = __bnx2x_vlan_mac_h_read_lock(bp, o);
+	spin_unlock_bh(&o->exe_queue.lock);
+
+	return rc;
+}
+
+/**
+ * __bnx2x_vlan_mac_h_read_unlock - unlock the vlan mac head list reader lock
+ *
+ * @bp:			device handle
+ * @o:			vlan_mac object
+ *
+ * @details Should be called under execution queue lock. Notice if a pending
+ *          execution exists, it would be performed if this was the last
+ *          reader. possibly releasing and reclaiming the execution queue lock.
+ */
+static void __bnx2x_vlan_mac_h_read_unlock(struct bnx2x *bp,
+					  struct bnx2x_vlan_mac_obj *o)
+{
+	if (!o->head_reader) {
+		BNX2X_ERR("Need to release vlan mac reader lock, but lock isn't taken\n");
+#ifdef BNX2X_STOP_ON_ERROR
+		bnx2x_panic();
+#endif
+	} else {
+		o->head_reader--;
+		DP(BNX2X_MSG_SP, "vlan_mac_lock - decreased readers to %d\n",
+		   o->head_reader);
+	}
+
+	/* It's possible a new pending execution was added, and that this reader
+	 * was last - if so we need to execute the command.
+	 */
+	if (!o->head_reader && o->head_exe_request) {
+		DP(BNX2X_MSG_SP, "vlan_mac_lock - reader release encountered a pending request\n");
+
+		/* Writer release will do the trick */
+		o->head_writer = true;
+		__bnx2x_vlan_mac_h_write_unlock(bp, o);
+	}
+}
+
+/**
+ * bnx2x_vlan_mac_h_read_unlock - unlock the vlan mac head list reader lock
+ *
+ * @bp:			device handle
+ * @o:			vlan_mac object
+ *
+ * @details Notice if a pending execution exists, it would be performed if this
+ *          was the last reader. Claims and releases the execution queue lock
+ *          during its run.
+ */
+void bnx2x_vlan_mac_h_read_unlock(struct bnx2x *bp,
+				  struct bnx2x_vlan_mac_obj *o)
+{
+	spin_lock_bh(&o->exe_queue.lock);
+	__bnx2x_vlan_mac_h_read_unlock(bp, o);
+	spin_unlock_bh(&o->exe_queue.lock);
+}
+
 static int bnx2x_get_n_elements(struct bnx2x *bp, struct bnx2x_vlan_mac_obj *o,
 				int n, u8 *buf)
 {
 	struct bnx2x_vlan_mac_registry_elem *pos;
 	u8 *next = buf;
-	int counter = 0;
+	int counter = 0, read_lock;
+
+	DP(BNX2X_MSG_SP, "get_n_elements - taking vlan_mac_lock (reader)\n");
+	read_lock = bnx2x_vlan_mac_h_read_lock(bp, o);
+	if (read_lock != 0)
+		BNX2X_ERR("get_n_elements failed to get vlan mac reader lock; Access without lock\n");
 
 	/* traverse list */
 	list_for_each_entry(pos, &o->head, link) {
@@ -470,6 +799,12 @@ static int bnx2x_get_n_elements(struct bnx2x *bp, struct bnx2x_vlan_mac_obj *o,
 			   counter, next, pos->u.mac.mac);
 		}
 	}
+
+	if (read_lock == 0) {
+		DP(BNX2X_MSG_SP, "get_n_elements - releasing vlan_mac_lock (reader)\n");
+		bnx2x_vlan_mac_h_read_unlock(bp, o);
+	}
+
 	return counter * ETH_ALEN;
 }
 
@@ -1095,7 +1430,7 @@ static int bnx2x_vlan_mac_restore(struct bnx2x *bp,
 	/* Set a restore bit */
 	__set_bit(RAMROD_RESTORE, &p->ramrod_flags);
 
-	return bnx2x_config_vlan_mac(bp, p);
+	return bnx2x_config_vlan_mac_locked(bp, p);
 }
 
 /*
@@ -1417,6 +1752,52 @@ static int bnx2x_wait_vlan_mac(struct bnx2x *bp,
 	return -EBUSY;
 }
 
+static int __bnx2x_vlan_mac_execute_step(struct bnx2x *bp,
+					 struct bnx2x_vlan_mac_obj *o,
+					 unsigned long *ramrod_flags,
+					 bool pre_locked)
+{
+	bool current_lock;
+	int rc;
+
+	spin_lock_bh(&o->exe_queue.lock);
+
+	if (!pre_locked) {
+		DP(BNX2X_MSG_SP, "vlan_mac_execute_step - trying to take writer lock\n");
+		rc = __bnx2x_vlan_mac_h_write_trylock(bp, o);
+		current_lock = (rc == 0) ? true : false;
+	} else {
+		/* Since there's an outside lock, it's possible there've
+		 * been repeated calls to this functions. As every call to
+		 * exe_queue_step would clear the execution index, we need
+		 * to clean any pending request to execute and re-set the
+		 * execution status.
+		 */
+		o->head_exe_request = false;
+		o->saved_ramrod_flags = 0;
+		o->head_exe = true;
+
+		current_lock = true;
+	}
+
+	if (!current_lock) {
+		__bnx2x_vlan_mac_h_pend(bp, o, *ramrod_flags);
+		spin_unlock_bh(&o->exe_queue.lock);
+	} else {
+		spin_unlock_bh(&o->exe_queue.lock);
+
+		rc = bnx2x_exe_queue_step(bp, o, &o->exe_queue, ramrod_flags);
+		if (!pre_locked) {
+			DP(BNX2X_MSG_SP, "vlan_mac_execute_step - trying to release writer lock\n");
+			bnx2x_vlan_mac_h_write_unlock(bp, o);
+		}
+		if (rc < 0)
+			return rc;
+	}
+
+	return 0;
+}
+
 /**
  * bnx2x_complete_vlan_mac - complete one VLAN-MAC ramrod
  *
@@ -1446,7 +1827,9 @@ static int bnx2x_complete_vlan_mac(struct bnx2x *bp,
 
 	/* Run the next bulk of pending commands if requested */
 	if (test_bit(RAMROD_CONT, ramrod_flags)) {
-		rc = bnx2x_exe_queue_step(bp, &o->exe_queue, ramrod_flags);
+		rc = __bnx2x_vlan_mac_execute_step(bp, o,
+						   ramrod_flags, false);
+
 		if (rc < 0)
 			return rc;
 	}
@@ -1737,15 +2120,15 @@ static inline int bnx2x_vlan_mac_push_new_cmd(
 }
 
 /**
- * bnx2x_config_vlan_mac - configure VLAN/MAC/VLAN_MAC filtering rules.
+ * __bnx2x_config_vlan_mac - configure VLAN/MAC/VLAN_MAC filtering rules.
  *
  * @bp:	  device handle
  * @p:
  *
  */
-int bnx2x_config_vlan_mac(
-	struct bnx2x *bp,
-	struct bnx2x_vlan_mac_ramrod_params *p)
+static int __bnx2x_config_vlan_mac(struct bnx2x *bp,
+				   struct bnx2x_vlan_mac_ramrod_params *p,
+				   bool pre_locked)
 {
 	int rc = 0;
 	struct bnx2x_vlan_mac_obj *o = p->vlan_mac_obj;
@@ -1777,7 +2160,9 @@ int bnx2x_config_vlan_mac(
 	/* Execute commands if required */
 	if (cont || test_bit(RAMROD_EXEC, ramrod_flags) ||
 	    test_bit(RAMROD_COMP_WAIT, ramrod_flags)) {
-		rc = bnx2x_exe_queue_step(bp, &o->exe_queue, ramrod_flags);
+		rc = __bnx2x_vlan_mac_execute_step(bp, p->vlan_mac_obj,
+						   &p->ramrod_flags,
+						   pre_locked);
 		if (rc < 0)
 			return rc;
 	}
@@ -1802,8 +2187,10 @@ int bnx2x_config_vlan_mac(
 				return rc;
 
 			/* Make a next step */
-			rc = bnx2x_exe_queue_step(bp, &o->exe_queue,
-						  ramrod_flags);
+			rc = __bnx2x_vlan_mac_execute_step(bp,
+							   p->vlan_mac_obj,
+							   &p->ramrod_flags,
+							   pre_locked);
 			if (rc < 0)
 				return rc;
 		}
@@ -1814,7 +2201,17 @@ int bnx2x_config_vlan_mac(
 	return rc;
 }
 
+int bnx2x_config_vlan_mac(struct bnx2x *bp,
+			  struct bnx2x_vlan_mac_ramrod_params *p)
+{
+	return __bnx2x_config_vlan_mac(bp, p, false);
+}
 
+int bnx2x_config_vlan_mac_locked(struct bnx2x *bp,
+					 struct bnx2x_vlan_mac_ramrod_params *p)
+{
+	return __bnx2x_config_vlan_mac(bp, p, true);
+}
 
 /**
  * bnx2x_vlan_mac_del_all - delete elements with given vlan_mac_flags spec
@@ -1835,7 +2232,7 @@ static int bnx2x_vlan_mac_del_all(struct bnx2x *bp,
 				  unsigned long *ramrod_flags)
 {
 	struct bnx2x_vlan_mac_registry_elem *pos = NULL;
-	int rc = 0;
+	int rc = 0, read_lock;
 	struct bnx2x_vlan_mac_ramrod_params p;
 	struct bnx2x_exe_queue_obj *exeq = &o->exe_queue;
 	struct bnx2x_exeq_elem *exeq_pos, *exeq_pos_n;
@@ -1873,6 +2270,11 @@ static int bnx2x_vlan_mac_del_all(struct bnx2x *bp,
 	__clear_bit(RAMROD_EXEC, &p.ramrod_flags);
 	__clear_bit(RAMROD_CONT, &p.ramrod_flags);
 
+	DP(BNX2X_MSG_SP, "vlan_mac_del_all -- taking vlan_mac_lock (reader)\n");
+	read_lock = bnx2x_vlan_mac_h_read_lock(bp, o);
+	if (read_lock != 0)
+		return read_lock;
+
 	list_for_each_entry(pos, &o->head, link) {
 		if (pos->vlan_mac_flags == *vlan_mac_flags) {
 			p.user_req.vlan_mac_flags = pos->vlan_mac_flags;
@@ -1880,11 +2282,15 @@ static int bnx2x_vlan_mac_del_all(struct bnx2x *bp,
 			rc = bnx2x_config_vlan_mac(bp, &p);
 			if (rc < 0) {
 				BNX2X_ERR("Failed to add a new DEL command\n");
+				bnx2x_vlan_mac_h_read_unlock(bp, o);
 				return rc;
 			}
 		}
 	}
 
+	DP(BNX2X_MSG_SP, "vlan_mac_del_all -- releasing vlan_mac_lock (reader)\n");
+	bnx2x_vlan_mac_h_read_unlock(bp, o);
+
 	p.ramrod_flags = *ramrod_flags;
 	__set_bit(RAMROD_CONT, &p.ramrod_flags);
 
@@ -1916,6 +2322,11 @@ static inline void bnx2x_init_vlan_mac_common(struct bnx2x_vlan_mac_obj *o,
 	struct bnx2x_credit_pool_obj *vlans_pool)
 {
 	INIT_LIST_HEAD(&o->head);
+	o->head_writer = false;
+	o->head_reader = 0;
+	o->head_exe = false;
+	o->head_exe_request = false;
+	o->saved_ramrod_flags = 0;
 
 	o->macs_pool = macs_pool;
 	o->vlans_pool = vlans_pool;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index ff90760..3ec795b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -290,6 +290,14 @@ struct bnx2x_vlan_mac_obj {
 	 * entries.
 	 */
 	struct list_head		head;
+	/* Implement a simple reader/writer lock on the head list.
+	 * all these fields should only be accessed under the exe_queue lock
+	 */
+	bool		head_writer; /* Writer accessing head list. */
+	bool		head_exe; /* Writer will exec a step */
+	u8		head_reader; /* Num. of readers accessing head list */
+	bool		head_exe_request; /* Pending execution request. */
+	unsigned long	saved_ramrod_flags; /* Ramrods of pending execution */
 
 	/* TODO: Add it's initialization in the init functions */
 	struct bnx2x_exe_queue_obj	exe_queue;
@@ -1297,8 +1305,18 @@ void bnx2x_init_vlan_mac_obj(struct bnx2x *bp,
 			     struct bnx2x_credit_pool_obj *macs_pool,
 			     struct bnx2x_credit_pool_obj *vlans_pool);
 
+int bnx2x_vlan_mac_h_read_lock(struct bnx2x *bp,
+					struct bnx2x_vlan_mac_obj *o);
+void bnx2x_vlan_mac_h_read_unlock(struct bnx2x *bp,
+				  struct bnx2x_vlan_mac_obj *o);
+int bnx2x_vlan_mac_h_write_lock(struct bnx2x *bp,
+				struct bnx2x_vlan_mac_obj *o);
+void bnx2x_vlan_mac_h_write_unlock(struct bnx2x *bp,
+					  struct bnx2x_vlan_mac_obj *o);
 int bnx2x_config_vlan_mac(struct bnx2x *bp,
 			  struct bnx2x_vlan_mac_ramrod_params *p);
+int bnx2x_config_vlan_mac_locked(struct bnx2x *bp,
+				 struct bnx2x_vlan_mac_ramrod_params *p);
 
 int bnx2x_vlan_mac_move(struct bnx2x *bp,
 			struct bnx2x_vlan_mac_ramrod_params *p,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 6adfa20..89c6fa1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -489,12 +489,19 @@ static inline void bnx2x_vfop_credit(struct bnx2x *bp,
 	 * and a valid credit counter
 	 */
 	if (!vfop->rc && args->credit) {
-		int cnt = 0;
+		int cnt = 0, read_lock;
 		struct list_head *pos;
 
+		read_lock = bnx2x_vlan_mac_h_read_lock(bp, obj);
+		if (read_lock)
+			DP(BNX2X_MSG_SP, "Failed to take vlan mac read head; continuing anyway\n");
+
 		list_for_each(pos, &obj->head)
 			cnt++;
 
+		if (!read_lock)
+			bnx2x_vlan_mac_h_read_unlock(bp, obj);
+
 		atomic_set(args->credit, cnt);
 	}
 }
-- 
1.7.9.GIT
