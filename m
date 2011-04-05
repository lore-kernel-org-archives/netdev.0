From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/8] s2io: convert to set_phys_id (v2)
Date: Mon, 4 Apr 2011 18:09:25 -0700
Message-ID: <20110404180925.0d91989b@nehalam>
References: <20110404210634.840793593@linuxplumber.net>
	<20110404210805.593573200@linuxplumber.net>
	<1301959036.2935.58.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jon Mason <jdmason@kudzu.us>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49993 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199Ab1DEBJ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 21:09:27 -0400
In-Reply-To: <1301959036.2935.58.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to new ethtool set physical id model. Remove no longer used
timer, and fix docbook comment.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v2 - store last gpio value in unused part of s2io_nic

--- a/drivers/net/s2io.c	2011-04-04 18:02:15.842923454 -0700
+++ b/drivers/net/s2io.c	2011-04-04 18:06:53.070404512 -0700
@@ -5484,83 +5484,79 @@ static void s2io_ethtool_gregs(struct ne
 	}
 }
 
-/**
- *  s2io_phy_id  - timer function that alternates adapter LED.
- *  @data : address of the private member of the device structure, which
- *  is a pointer to the s2io_nic structure, provided as an u32.
- * Description: This is actually the timer function that alternates the
- * adapter LED bit of the adapter control bit to set/reset every time on
- * invocation. The timer is set for 1/2 a second, hence tha NIC blinks
- *  once every second.
+/*
+ *  s2io_set_led - control NIC led
  */
-static void s2io_phy_id(unsigned long data)
+static void s2io_set_led(struct s2io_nic *sp, bool on)
 {
-	struct s2io_nic *sp = (struct s2io_nic *)data;
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
-	u64 val64 = 0;
-	u16 subid;
+	u16 subid = sp->pdev->subsystem_device;
+	u64 val64;
 
-	subid = sp->pdev->subsystem_device;
 	if ((sp->device_type == XFRAME_II_DEVICE) ||
 	    ((subid & 0xFF) >= 0x07)) {
 		val64 = readq(&bar0->gpio_control);
-		val64 ^= GPIO_CTRL_GPIO_0;
+		if (on)
+			val64 |= GPIO_CTRL_GPIO_0;
+		else
+			val64 &= ~GPIO_CTRL_GPIO_0;
+
 		writeq(val64, &bar0->gpio_control);
 	} else {
 		val64 = readq(&bar0->adapter_control);
-		val64 ^= ADAPTER_LED_ON;
+		if (on)
+			val64 |= ADAPTER_LED_ON;
+		else
+			val64 &= ~ADAPTER_LED_ON;
+
 		writeq(val64, &bar0->adapter_control);
 	}
 
-	mod_timer(&sp->id_timer, jiffies + HZ / 2);
 }
 
 /**
- * s2io_ethtool_idnic - To physically identify the nic on the system.
- * @sp : private member of the device structure, which is a pointer to the
- * s2io_nic structure.
- * @id : pointer to the structure with identification parameters given by
- * ethtool.
+ * s2io_ethtool_set_led - To physically identify the nic on the system.
+ * @dev : network device
+ * @state: led setting
+ *
  * Description: Used to physically identify the NIC on the system.
  * The Link LED will blink for a time specified by the user for
  * identification.
  * NOTE: The Link has to be Up to be able to blink the LED. Hence
  * identification is possible only if it's link is up.
- * Return value:
- * int , returns 0 on success
  */
 
-static int s2io_ethtool_idnic(struct net_device *dev, u32 data)
+static int s2io_ethtool_set_led(struct net_device *dev,
+				enum ethtool_phys_id_state state)
 {
-	u64 val64 = 0, last_gpio_ctrl_val;
 	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
-	u16 subid;
+	u16 subid = sp->pdev->subsystem_device;
 
-	subid = sp->pdev->subsystem_device;
-	last_gpio_ctrl_val = readq(&bar0->gpio_control);
 	if ((sp->device_type == XFRAME_I_DEVICE) && ((subid & 0xFF) < 0x07)) {
-		val64 = readq(&bar0->adapter_control);
+		u64 val64 = readq(&bar0->adapter_control);
 		if (!(val64 & ADAPTER_CNTL_EN)) {
 			pr_err("Adapter Link down, cannot blink LED\n");
-			return -EFAULT;
+			return -EAGAIN;
 		}
 	}
-	if (sp->id_timer.function == NULL) {
-		init_timer(&sp->id_timer);
-		sp->id_timer.function = s2io_phy_id;
-		sp->id_timer.data = (unsigned long)sp;
-	}
-	mod_timer(&sp->id_timer, jiffies);
-	if (data)
-		msleep_interruptible(data * HZ);
-	else
-		msleep_interruptible(MAX_FLICKER_TIME);
-	del_timer_sync(&sp->id_timer);
 
-	if (CARDS_WITH_FAULTY_LINK_INDICATORS(sp->device_type, subid)) {
-		writeq(last_gpio_ctrl_val, &bar0->gpio_control);
-		last_gpio_ctrl_val = readq(&bar0->gpio_control);
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		sp->adapt_ctrl_org = readq(&bar0->gpio_control);
+		return -EINVAL;
+
+	case ETHTOOL_ID_ON:
+		s2io_set_led(sp, true);
+		break;
+
+	case ETHTOOL_ID_OFF:
+		s2io_set_led(sp, false);
+		break;
+
+	case ETHTOOL_ID_INACTIVE:
+		if (CARDS_WITH_FAULTY_LINK_INDICATORS(sp->device_type, subid))
+			writeq(sp->adapt_ctrl_org, &bar0->gpio_control);
 	}
 
 	return 0;
@@ -6776,7 +6772,7 @@ static const struct ethtool_ops netdev_e
 	.set_ufo = ethtool_op_set_ufo,
 	.self_test = s2io_ethtool_test,
 	.get_strings = s2io_ethtool_get_strings,
-	.phys_id = s2io_ethtool_idnic,
+	.set_phys_id = s2io_ethtool_set_led,
 	.get_ethtool_stats = s2io_get_ethtool_stats,
 	.get_sset_count = s2io_get_sset_count,
 };
--- a/drivers/net/s2io.h	2011-04-04 18:02:15.878923843 -0700
+++ b/drivers/net/s2io.h	2011-04-04 18:06:40.518243198 -0700
@@ -893,9 +893,6 @@ struct s2io_nic {
 	u16 all_multi_pos;
 	u16 promisc_flg;
 
-	/*  Id timer, used to blink NIC to physically identify NIC. */
-	struct timer_list id_timer;
-
 	/*  Restart timer, used to restart NIC if the device is stuck and
 	 *  a schedule task that will set the correct Link state once the
 	 *  NIC's PHY has stabilized after a state change.
