From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] i40e: during LED interaction ignore activity LED src modes
Date: Thu,  5 Mar 2015 08:46:20 -0800
Message-ID: <1425573992-30955-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matt Jared <matthew.a.jared@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8609 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757797AbbCEQqw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 11:46:52 -0500
In-Reply-To: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Jared <matthew.a.jared@intel.com>

Modify our get and set LED functions so they ignore activity LEDs,
as we are required to blink the link LEDs only.

Change-ID: I647ea67a6fc95cbbab6e3cd01d81ec9ae096a9ad
Signed-off-by: Matt Jared <matthew.a.jared@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 35 ++++++++++++++++++++++++++-
 1 file changed, 34 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 1da7d05..cc10303 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1083,8 +1083,11 @@ static u32 i40e_led_is_mine(struct i40e_hw *hw, int idx)
 	return gpio_val;
 }
 
-#define I40E_LED0 22
+#define I40E_COMBINED_ACTIVITY 0xA
+#define I40E_FILTER_ACTIVITY 0xE
 #define I40E_LINK_ACTIVITY 0xC
+#define I40E_MAC_ACTIVITY 0xD
+#define I40E_LED0 22
 
 /**
  * i40e_led_get - return current on/off mode
@@ -1097,6 +1100,7 @@ static u32 i40e_led_is_mine(struct i40e_hw *hw, int idx)
  **/
 u32 i40e_led_get(struct i40e_hw *hw)
 {
+	u32 current_mode = 0;
 	u32 mode = 0;
 	int i;
 
@@ -1109,6 +1113,20 @@ u32 i40e_led_get(struct i40e_hw *hw)
 		if (!gpio_val)
 			continue;
 
+		/* ignore gpio LED src mode entries related to the activity
+		 * LEDs
+		 */
+		current_mode = ((gpio_val & I40E_GLGEN_GPIO_CTL_LED_MODE_MASK)
+				>> I40E_GLGEN_GPIO_CTL_LED_MODE_SHIFT);
+		switch (current_mode) {
+		case I40E_COMBINED_ACTIVITY:
+		case I40E_FILTER_ACTIVITY:
+		case I40E_MAC_ACTIVITY:
+			continue;
+		default:
+			break;
+		}
+
 		mode = (gpio_val & I40E_GLGEN_GPIO_CTL_LED_MODE_MASK) >>
 			I40E_GLGEN_GPIO_CTL_LED_MODE_SHIFT;
 		break;
@@ -1128,6 +1146,7 @@ u32 i40e_led_get(struct i40e_hw *hw)
  **/
 void i40e_led_set(struct i40e_hw *hw, u32 mode, bool blink)
 {
+	u32 current_mode = 0;
 	int i;
 
 	if (mode & 0xfffffff0)
@@ -1142,6 +1161,20 @@ void i40e_led_set(struct i40e_hw *hw, u32 mode, bool blink)
 		if (!gpio_val)
 			continue;
 
+		/* ignore gpio LED src mode entries related to the activity
+		 * LEDs
+		 */
+		current_mode = ((gpio_val & I40E_GLGEN_GPIO_CTL_LED_MODE_MASK)
+				>> I40E_GLGEN_GPIO_CTL_LED_MODE_SHIFT);
+		switch (current_mode) {
+		case I40E_COMBINED_ACTIVITY:
+		case I40E_FILTER_ACTIVITY:
+		case I40E_MAC_ACTIVITY:
+			continue;
+		default:
+			break;
+		}
+
 		gpio_val &= ~I40E_GLGEN_GPIO_CTL_LED_MODE_MASK;
 		/* this & is a bit of paranoia, but serves as a range check */
 		gpio_val |= ((mode << I40E_GLGEN_GPIO_CTL_LED_MODE_SHIFT) &
-- 
1.9.3
