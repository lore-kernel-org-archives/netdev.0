From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [pull 2.6.30 2/2] wimax: oops: wimax_dev_add() is the only one that can initialize the state
Date: Wed,  6 May 2009 14:47:23 -0700
Message-ID: <94c7f2d49521b0bb3ab91cbeb3518ac34355d47f.1241646234.git.inaky@linux.intel.com>
References: <cover.1241646234.git.inaky@linux.intel.com>
 <d1a2627a29667fe7c4a9d06e1579a2d65bd39bba.1241646234.git.inaky@linux.intel.com>
Cc: netdev@vger.kernel.org
To: wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:24427 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756378AbZEFVrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 17:47:45 -0400
In-Reply-To: <d1a2627a29667fe7c4a9d06e1579a2d65bd39bba.1241646234.git.inaky@linux.intel.com>
In-Reply-To: <cover.1241646234.git.inaky@linux.intel.com>
References: <cover.1241646234.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a new wimax_dev is created, it's state has to be __WIMAX_ST_NULL
until wimax_dev_add() is succesfully called. This allows calls into
the stack that happen before said time to be rejected.

Until now, the state was being set (by mistake) to UNINITIALIZED,
which was allowing calls such as wimax_report_rfkill_hw() to go
through even when a call to wimax_dev_add() had failed; that was
causing an oops when touching uninitialized data.

This situation is normal when the device starts reporting state before
the whole initialization has been completed. It just has to be dealt
with.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 net/wimax/stack.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index a0ee76b..933e142 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -338,8 +338,21 @@ out:
  */
 void wimax_state_change(struct wimax_dev *wimax_dev, enum wimax_st new_state)
 {
+	/*
+	 * A driver cannot take the wimax_dev out of the
+	 * __WIMAX_ST_NULL state unless by calling wimax_dev_add(). If
+	 * the wimax_dev's state is still NULL, we ignore any request
+	 * to change its state because it means it hasn't been yet
+	 * registered.
+	 *
+	 * There is no need to complain about it, as routines that
+	 * call this might be shared from different code paths that
+	 * are called before or after wimax_dev_add() has done its
+	 * job.
+	 */
 	mutex_lock(&wimax_dev->mutex);
-	__wimax_state_change(wimax_dev, new_state);
+	if (wimax_dev->state > __WIMAX_ST_NULL)
+		__wimax_state_change(wimax_dev, new_state);
 	mutex_unlock(&wimax_dev->mutex);
 	return;
 }
@@ -376,7 +389,7 @@ EXPORT_SYMBOL_GPL(wimax_state_get);
 void wimax_dev_init(struct wimax_dev *wimax_dev)
 {
 	INIT_LIST_HEAD(&wimax_dev->id_table_node);
-	__wimax_state_set(wimax_dev, WIMAX_ST_UNINITIALIZED);
+	__wimax_state_set(wimax_dev, __WIMAX_ST_NULL);
 	mutex_init(&wimax_dev->mutex);
 	mutex_init(&wimax_dev->mutex_reset);
 }
-- 
1.6.2.3

