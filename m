From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 4/4] i2400m/usb: wrap USB power saving in #ifdef CONFIG_PM
Date: Wed,  7 Jan 2009 11:22:22 -0800
Message-ID: <0e511f3772ac9887551bec34ee682fa5bf63fb69.1231355768.git.inaky@linux.intel.com>
References: <cover.1231355768.git.inaky@linux.intel.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, wimax@linuxwimax.org,
	greg@kroah.com, LKML <linux-kernel@vger.kernel.org>,
	linux-wimax@intel.com, linux-next@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1231355768.git.inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

Current code was assuming PM was always enabled, which is not
correct. Code which accesses members in the struct usb_device that are
dependant on CONFIG_PM must be protected the same.

Reported by Randy Dunlap from a build error in the linux-next tree on
07/01/2009.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/wimax/i2400m/usb.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 6d4b65f..c6d9346 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -397,11 +397,13 @@ int i2400mu_probe(struct usb_interface *iface,
 	i2400m->bus_fw_name = I2400MU_FW_FILE_NAME;
 	i2400m->bus_bm_mac_addr_impaired = 0;
 
+#ifdef CONFIG_PM
 	iface->needs_remote_wakeup = 1;		/* autosuspend (15s delay) */
 	device_init_wakeup(dev, 1);
 	usb_autopm_enable(i2400mu->usb_iface);
 	usb_dev->autosuspend_delay = 15 * HZ;
 	usb_dev->autosuspend_disabled = 0;
+#endif
 
 	result = i2400m_setup(i2400m, I2400M_BRI_MAC_REINIT);
 	if (result < 0) {
@@ -493,7 +495,9 @@ int i2400mu_suspend(struct usb_interface *iface, pm_message_t pm_msg)
 	int result = 0;
 	struct device *dev = &iface->dev;
 	struct i2400mu *i2400mu = usb_get_intfdata(iface);
+#ifdef CONFIG_PM
 	struct usb_device *usb_dev = i2400mu->usb_dev;
+#endif
 	struct i2400m *i2400m = &i2400mu->i2400m;
 
 	d_fnstart(3, dev, "(iface %p pm_msg %u)\n", iface, pm_msg.event);
@@ -503,11 +507,13 @@ int i2400mu_suspend(struct usb_interface *iface, pm_message_t pm_msg)
 	atomic_dec(&i2400mu->do_autopm);
 	result = i2400m_cmd_enter_powersave(i2400m);
 	atomic_inc(&i2400mu->do_autopm);
+#ifdef CONFIG_PM
 	if (result < 0 && usb_dev->auto_pm == 0) {
 		/* System suspend, can't fail */
 		dev_err(dev, "failed to suspend, will reset on resume\n");
 		result = 0;
 	}
+#endif
 	if (result < 0)
 		goto error_enter_powersave;
 	i2400mu_notification_release(i2400mu);
-- 
1.5.6.5
