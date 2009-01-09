From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] e1000e: Add process name to WARN message when detecting Mutex
	contention
Date: Thu, 08 Jan 2009 18:03:29 -0800
Message-ID: <20090109020328.16029.47388.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	David Graham <david.graham@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:43848 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752101AbZAICDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 21:03:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Graham <david.graham@intel.com>

Adds process name of the current mutex holder to the WARN message output
when the e1000e driver attempts to acquire the nvm_mutex and finds that
it is already being held. With this patch the WARN message indicates
both the process name of the current mutex holder and the process name of
the attempted acquisition, which together will help to identify the
contending codepaths.

Signed-off-by: David Graham <david.graham@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index f2a5963..e415e81 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -390,7 +390,8 @@ static s32 e1000_get_variants_ich8lan(struct e1000_adapter *adapter)
 }
 
 static DEFINE_MUTEX(nvm_mutex);
-static pid_t nvm_owner = -1;
+static pid_t nvm_owner_pid = -1;
+static char nvm_owner_name[TASK_COMM_LEN] = "";
 
 /**
  *  e1000_acquire_swflag_ich8lan - Acquire software control flag
@@ -408,11 +409,15 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 	might_sleep();
 
 	if (!mutex_trylock(&nvm_mutex)) {
-		WARN(1, KERN_ERR "e1000e mutex contention. Owned by pid %d\n",
-		     nvm_owner);
+		WARN(1, KERN_ERR "e1000e mutex contention. Owned by process "
+		     "%s (pid %d), required by process %s (pid %d)\n",
+		     nvm_owner_name, nvm_owner_pid,
+		     current->comm, current->pid);
+
 		mutex_lock(&nvm_mutex);
 	}
-	nvm_owner = current->pid;
+	nvm_owner_pid = current->pid;
+	strncpy(nvm_owner_name, current->comm, TASK_COMM_LEN);
 
 	while (timeout) {
 		extcnf_ctrl = er32(EXTCNF_CTRL);
@@ -430,7 +435,8 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 		hw_dbg(hw, "FW or HW has locked the resource for too long.\n");
 		extcnf_ctrl &= ~E1000_EXTCNF_CTRL_SWFLAG;
 		ew32(EXTCNF_CTRL, extcnf_ctrl);
-		nvm_owner = -1;
+		nvm_owner_pid = -1;
+		strcpy(nvm_owner_name, "");
 		mutex_unlock(&nvm_mutex);
 		return -E1000_ERR_CONFIG;
 	}
@@ -454,7 +460,8 @@ static void e1000_release_swflag_ich8lan(struct e1000_hw *hw)
 	extcnf_ctrl &= ~E1000_EXTCNF_CTRL_SWFLAG;
 	ew32(EXTCNF_CTRL, extcnf_ctrl);
 
-	nvm_owner = -1;
+	nvm_owner_pid = -1;
+	strcpy(nvm_owner_name, "");
 	mutex_unlock(&nvm_mutex);
 }
 

