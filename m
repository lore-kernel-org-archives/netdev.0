From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/4 07/13] wimax/i2400m: when stopping the device, cancel any pending message
Date: Wed,  4 Nov 2009 13:40:02 -0800
Message-ID: <5eeae35b9a2e304fc4ae3d9eed63afeea23b482c.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:45636 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932769AbZKDVmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:12 -0500
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The stop procedure for the device must make sure that any task that is
waiting on a message is properly cancelled.

This was being taken care of only by the __i2400m_dev_reset_handle()
path and the rest was working by chance because the waits have a
timeout.

Fixed by adding a proper cancellation in __i2400m_dev_stop().

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 1f6aa2a..810eda7 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -537,6 +537,8 @@ void __i2400m_dev_stop(struct i2400m *i2400m)
 
 	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
 	wimax_state_change(wimax_dev, __WIMAX_ST_QUIESCING);
+	i2400m_msg_to_dev_cancel_wait(i2400m, -EL3RST);
+	complete(&i2400m->msg_completion);
 	i2400m_net_wake_stop(i2400m);
 	i2400m_dev_shutdown(i2400m);
 	/*
-- 
1.6.2.5

