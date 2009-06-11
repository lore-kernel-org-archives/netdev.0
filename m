From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 12/21] wimax/i2400m: if a device reboot happens during probe, handle it
Date: Thu, 11 Jun 2009 14:35:49 -0700
Message-ID: <b4013f91cdda10f3f15530914f3c7f39738b0b50.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17677 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751912AbZFKVgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:47 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a device reboot happens when we are under probe, with init_mutex
taken, make sure we can recover. Have dev_reset_handle set boot mode
and i2400m_msg_to_dev() will see it and fail gracefully instead of
timing out.

Found and diagnosed by Cindy H. Kao.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/control.c |    1 +
 drivers/net/wimax/i2400m/driver.c  |    2 ++
 drivers/net/wimax/i2400m/fw.c      |    2 ++
 3 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index d8e0cdf..f9399f2 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -695,6 +695,7 @@ struct sk_buff *i2400m_msg_to_dev(struct i2400m *i2400m,
 	d_fnstart(3, dev, "(i2400m %p buf %p len %zu)\n",
 		  i2400m, buf, buf_len);
 
+	rmb();		/* Make sure we see what i2400m_dev_reset_handle() */
 	if (i2400m->boot_mode)
 		return ERR_PTR(-ENODEV);
 
diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 897794c..e8d022d 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -610,6 +610,8 @@ out:
  */
 int i2400m_dev_reset_handle(struct i2400m *i2400m)
 {
+	i2400m->boot_mode = 1;
+	wmb();		/* Make sure i2400m_msg_to_dev() sees boot_mode */
 	return i2400m_schedule_work(i2400m, __i2400m_dev_reset_handle,
 				    GFP_ATOMIC);
 }
diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 26924f1..01c926e 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -985,6 +985,7 @@ int i2400m_fw_dnload(struct i2400m *i2400m, const struct i2400m_bcf_hdr *bcf,
 	d_fnstart(5, dev, "(i2400m %p bcf %p size %zu)\n",
 		  i2400m, bcf, bcf_size);
 	i2400m->boot_mode = 1;
+	wmb();		/* Make sure other readers see it */
 hw_reboot:
 	if (count-- == 0) {
 		ret = -ERESTARTSYS;
@@ -1033,6 +1034,7 @@ hw_reboot:
 	d_printf(2, dev, "fw %s successfully uploaded\n",
 		 i2400m->fw_name);
 	i2400m->boot_mode = 0;
+	wmb();		/* Make sure i2400m_msg_to_dev() sees boot_mode */
 error_dnload_finalize:
 error_dnload_bcf:
 error_dnload_init:
-- 
1.6.2.3

