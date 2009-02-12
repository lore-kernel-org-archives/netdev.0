From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH] Remove mutex_trylock and associated WARN on failure.
Date: Thu, 12 Feb 2009 01:53:10 -0800
Message-ID: <20090212095304.6369.47737.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	dave graham <david.graham@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:35926 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755564AbZBLJxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 04:53:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Graham <david.graham@intel.com>

Single-thread access must be ensured for ICH8 NVM and PHY operations.
This synchronization is provided by the nvm_mutex. To assist in
understanding the contexts from which this code could be reached,
a WARN was output if the mutex was not going to be immediately
acquirable (if !mutex_trylock()). The code has now been optimized,
and we have verified that the few remaining mutex contentions are
reasonable and non-blocking, and it is time to remove the
mutex_trylock() and WARN messages.

Signed-off-by: dave graham <david.graham@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |   17 +----------------
 1 files changed, 1 insertions(+), 16 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index e415e81..6d1aab6 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -390,8 +390,6 @@ static s32 e1000_get_variants_ich8lan(struct e1000_adapter *adapter)
 }
 
 static DEFINE_MUTEX(nvm_mutex);
-static pid_t nvm_owner_pid = -1;
-static char nvm_owner_name[TASK_COMM_LEN] = "";
 
 /**
  *  e1000_acquire_swflag_ich8lan - Acquire software control flag
@@ -408,16 +406,7 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 
 	might_sleep();
 
-	if (!mutex_trylock(&nvm_mutex)) {
-		WARN(1, KERN_ERR "e1000e mutex contention. Owned by process "
-		     "%s (pid %d), required by process %s (pid %d)\n",
-		     nvm_owner_name, nvm_owner_pid,
-		     current->comm, current->pid);
-
-		mutex_lock(&nvm_mutex);
-	}
-	nvm_owner_pid = current->pid;
-	strncpy(nvm_owner_name, current->comm, TASK_COMM_LEN);
+	mutex_lock(&nvm_mutex);
 
 	while (timeout) {
 		extcnf_ctrl = er32(EXTCNF_CTRL);
@@ -435,8 +424,6 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 		hw_dbg(hw, "FW or HW has locked the resource for too long.\n");
 		extcnf_ctrl &= ~E1000_EXTCNF_CTRL_SWFLAG;
 		ew32(EXTCNF_CTRL, extcnf_ctrl);
-		nvm_owner_pid = -1;
-		strcpy(nvm_owner_name, "");
 		mutex_unlock(&nvm_mutex);
 		return -E1000_ERR_CONFIG;
 	}
@@ -460,8 +447,6 @@ static void e1000_release_swflag_ich8lan(struct e1000_hw *hw)
 	extcnf_ctrl &= ~E1000_EXTCNF_CTRL_SWFLAG;
 	ew32(EXTCNF_CTRL, extcnf_ctrl);
 
-	nvm_owner_pid = -1;
-	strcpy(nvm_owner_name, "");
 	mutex_unlock(&nvm_mutex);
 }
 

