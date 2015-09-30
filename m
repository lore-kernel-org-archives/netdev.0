From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/17] i40e/i40evf: fix up type clash in i40e_aq_rc_to_posix conversion
Date: Wed, 30 Sep 2015 05:52:27 -0700
Message-ID: <1443617561-40490-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8321 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755397AbbI3Mwo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 08:52:44 -0400
In-Reply-To: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The error code sent into i40e_aq_rc_to_posix() are signed values, so we
really need to treat them as such.

Change-ID: I3d1ae0ee9ae0b1b6f5fc424f8b8cc58b0ea93203
Reported-by: Helin Zhang <helin.zhang@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.h   | 9 ++++++---
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h | 9 ++++++---
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.h b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
index b67b34c..ca81b0b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
@@ -109,9 +109,10 @@ struct i40e_adminq_info {
 
 /**
  * i40e_aq_rc_to_posix - convert errors to user-land codes
- * aq_rc: AdminQ error code to convert
+ * aq_ret: AdminQ handler error code can override aq_rc
+ * aq_rc: AdminQ firmware error code to convert
  **/
-static inline int i40e_aq_rc_to_posix(u32 aq_ret, u16 aq_rc)
+static inline int i40e_aq_rc_to_posix(int aq_ret, int aq_rc)
 {
 	int aq_to_posix[] = {
 		0,           /* I40E_AQ_RC_OK */
@@ -143,8 +144,10 @@ static inline int i40e_aq_rc_to_posix(u32 aq_ret, u16 aq_rc)
 	if (aq_ret == I40E_ERR_ADMIN_QUEUE_TIMEOUT)
 		return -EAGAIN;
 
-	if (aq_rc >= ARRAY_SIZE(aq_to_posix))
+	if (aq_rc >= (sizeof(aq_to_posix) / sizeof((aq_to_posix)[0])) ||
+	    aq_rc < 0)
 		return -ERANGE;
+
 	return aq_to_posix[aq_rc];
 }
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
index 547b79b..e62e951 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
@@ -109,9 +109,10 @@ struct i40e_adminq_info {
 
 /**
  * i40e_aq_rc_to_posix - convert errors to user-land codes
- * aq_rc: AdminQ error code to convert
+ * aq_ret: AdminQ handler error code can override aq_rc
+ * aq_rc: AdminQ firmware error code to convert
  **/
-static inline int i40e_aq_rc_to_posix(u32 aq_ret, u16 aq_rc)
+static inline int i40e_aq_rc_to_posix(int aq_ret, int aq_rc)
 {
 	int aq_to_posix[] = {
 		0,           /* I40E_AQ_RC_OK */
@@ -143,8 +144,10 @@ static inline int i40e_aq_rc_to_posix(u32 aq_ret, u16 aq_rc)
 	if (aq_ret == I40E_ERR_ADMIN_QUEUE_TIMEOUT)
 		return -EAGAIN;
 
-	if (aq_rc >= ARRAY_SIZE(aq_to_posix))
+	if (aq_rc >= (sizeof(aq_to_posix) / sizeof((aq_to_posix)[0])) ||
+	    aq_rc < 0)
 		return -ERANGE;
+
 	return aq_to_posix[aq_rc];
 }
 
-- 
2.4.3
