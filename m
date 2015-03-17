From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH RFC] wimax/i2400m: fixup completion handling for resetting a device
Date: Tue, 17 Mar 2015 05:49:34 -0400
Message-ID: <1426585774-24204-1-git-send-email-hofrat@osadl.org>
Cc: linux-wimax@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

wait_for_completion_timeout return 0 (timeout) or >=1 (completion) so the check
for > 0 in the else branch is always true and can be dropped. The comment seems
misleading as it is always going to pass the result up.

The sync of the completion access with __i2400m_dev_reset_handle (which checks
for   if (i2400m->reset_ctx)   could race if i2400m_reset() returns negative so
the resetting of i2400m->reset_ctx == NULL is moved to the out: path.

As wait_for_completion_timeout returns unsigned long not int, an appropriately
named variable of type unsigned long is added and assignments fixed up.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Not completely sure if moving i2400m->reset_ctx == NULL is really necessary,
but I was not able to see what would prevent completion from being called
after it went out of context (struct completion is on the stack here)
This change needs a review by someone that knows the details of the reset
cases.

Patch was only compile tested with x86_64_defconfig + CONFIG_WIMAX=m
CONFIG_WIMAX_I2400M_USB=m (implies CONFIG_WIMAX_I2400M=m)

Patch is against 4.0-rc4 (localversion-next is -next-20150317)

 drivers/net/wimax/i2400m/driver.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 9c78090..bc98b64 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -178,6 +178,7 @@ static
 int i2400m_op_reset(struct wimax_dev *wimax_dev)
 {
 	int result;
+	unsigned long time_left;
 	struct i2400m *i2400m = wimax_dev_to_i2400m(wimax_dev);
 	struct device *dev = i2400m_dev(i2400m);
 	struct i2400m_reset_ctx ctx = {
@@ -192,17 +193,17 @@ int i2400m_op_reset(struct wimax_dev *wimax_dev)
 	result = i2400m_reset(i2400m, I2400M_RT_WARM);
 	if (result < 0)
 		goto out;
-	result = wait_for_completion_timeout(&ctx.completion, 4*HZ);
-	if (result == 0)
+	time_left = wait_for_completion_timeout(&ctx.completion, 4 * HZ);
+	if (!time_left)
 		result = -ETIMEDOUT;
-	else if (result > 0)
+	else
 		result = ctx.result;
-	/* if result < 0, pass it on */
+
+out:
+	d_fnend(4, dev, "(wimax_dev %p) = %d\n", wimax_dev, result);
 	mutex_lock(&i2400m->init_mutex);
 	i2400m->reset_ctx = NULL;
 	mutex_unlock(&i2400m->init_mutex);
-out:
-	d_fnend(4, dev, "(wimax_dev %p) = %d\n", wimax_dev, result);
 	return result;
 }
 
-- 
1.7.10.4
