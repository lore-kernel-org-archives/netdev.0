From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH 2.6.27-rc8 5/6] e1000e: debug contention on NVM SWFLAG
Date: Thu, 02 Oct 2008 16:33:40 -0700
Message-ID: <20081002233340.12556.33137.stgit@jbrandeb-bw.jf.intel.com>
References: <20081002233314.12556.49143.stgit@jbrandeb-bw.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	tglx@linutronix.de, arjan@linux.intel.com, airlied@gmail.com,
	davem@davemloft.net, jeff@garzik.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57967 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755702AbYJBXdl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 19:33:41 -0400
In-Reply-To: <20081002233314.12556.49143.stgit@jbrandeb-bw.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>

This patch adds a mutex to the e1000e driver that would help
catch any collisions of two e1000e threads accessing hardware
at the same time.

description and patch updated by Jesse

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/e1000e/ich8lan.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index f4b6744..0b6095b 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -380,6 +380,9 @@ static s32 e1000_get_variants_ich8lan(struct e1000_adapter *adapter)
 	return 0;
 }
 
+static DEFINE_MUTEX(nvm_mutex);
+static pid_t nvm_owner = -1;
+
 /**
  *  e1000_acquire_swflag_ich8lan - Acquire software control flag
  *  @hw: pointer to the HW structure
@@ -393,6 +396,15 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 	u32 extcnf_ctrl;
 	u32 timeout = PHY_CFG_TIMEOUT;
 
+	WARN_ON(preempt_count());
+
+	if (!mutex_trylock(&nvm_mutex)) {
+		WARN(1, KERN_ERR "e1000e mutex contention. Owned by pid %d\n",
+		     nvm_owner);
+		mutex_lock(&nvm_mutex);
+	}
+	nvm_owner = current->pid;
+
 	while (timeout) {
 		extcnf_ctrl = er32(EXTCNF_CTRL);
 		extcnf_ctrl |= E1000_EXTCNF_CTRL_SWFLAG;
@@ -407,6 +419,8 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 
 	if (!timeout) {
 		hw_dbg(hw, "FW or HW has locked the resource for too long.\n");
+		nvm_owner = -1;
+		mutex_unlock(&nvm_mutex);
 		return -E1000_ERR_CONFIG;
 	}
 
@@ -428,6 +442,9 @@ static void e1000_release_swflag_ich8lan(struct e1000_hw *hw)
 	extcnf_ctrl = er32(EXTCNF_CTRL);
 	extcnf_ctrl &= ~E1000_EXTCNF_CTRL_SWFLAG;
 	ew32(EXTCNF_CTRL, extcnf_ctrl);
+
+	nvm_owner = -1;
+	mutex_unlock(&nvm_mutex);
 }
 
 /**

