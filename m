From: Ben Greear <greearb@candelatech.com>
Subject: tg3 patch to enable GMII test modes
Date: Wed, 28 Apr 2004 17:02:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4090460C.1000606@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have been trying to get a GigE adapter to go into the
GMII test modes described in section 40 of the 802.3 spec.

I was able to get e1000 into those modes, but it was transmitting
a 100bt pulse code instead of gigE (according to the guy with
the scope).

I'm now trying to get the tg3 to use these test modes.  I should
have confirmation from the scope guy in a few days, but in the
mean time I thought I'd run the patch buy you all.

If this is something that is desired in the main kernel, I have
the rest of the ethtool parts as well, and a user-space application
to drive it.

Comments welcome.

Thanks,
Ben


--- linux-2.4.25/drivers/net/tg3.h	2003-11-28 10:26:20.000000000 -0800
+++ linux-2.4.25.p4/drivers/net/tg3.h	2004-04-28 15:56:04.000000000 -0700
@@ -1417,6 +1417,13 @@
  #define  MII_TG3_CTRL_AS_MASTER		0x0800
  #define  MII_TG3_CTRL_ENABLE_AS_MASTER	0x1000

+/* Hoping these are the same as in the e1000 --Ben */
+#define  MII_TG3_1000T_TEST_MODE_NORMAL   0x0000 /* Normal Operation */
+#define  MII_TG3_TEST_MODE_1              0x2000 /* Transmit Waveform test */
+#define  MII_TG3_TEST_MODE_2              0x4000 /* Master Transmit Jitter test */
+#define  MII_TG3_TEST_MODE_3              0x6000 /* Slave Transmit Jitter test */
+#define  MII_TG3_TEST_MODE_4              0x8000 /* Transmitter Distortion test */
+
  #define MII_TG3_EXT_CTRL		0x10 /* Extended control register */
  #define  MII_TG3_EXT_CTRL_LNK3_LED_MODE	0x0002
  #define  MII_TG3_EXT_CTRL_TBI		0x8000
@@ -1994,6 +2001,9 @@
  	struct tg3_hw_stats		*hw_stats;
  	dma_addr_t			stats_mapping;
  	struct tq_struct		reset_task;
+
+	u32 gmii_test; /* See ethtool.h for GMII_TEST_MODE* definitions */
+
  };

  #endif /* !(_T3_H) */
--- linux-2.4.25/drivers/net/tg3.c	2004-02-18 05:36:31.000000000 -0800
+++ linux-2.4.25.p4/drivers/net/tg3.c	2004-04-28 16:54:32.000000000 -0700
@@ -559,6 +559,88 @@
  	return 0;
  }

+
+/**
+ * e1000_GMII_test_mode - Set various GMII test modes.
+ * @adapter:
+ **/
+
+static void
+tg3_GMII_test_mode(struct tg3 *adapter)
+{
+	u32 phy_ctrl;
+	const char* old_mode = NULL;
+	const char* new_mode = NULL;
+
+        tg3_readphy(adapter, MII_TG3_CTRL, &phy_ctrl);
+
+	if ((phy_ctrl & (MII_TG3_TEST_MODE_3)) == MII_TG3_TEST_MODE_3) {
+		old_mode = "MODE-3";
+	}
+	else if (phy_ctrl & (MII_TG3_TEST_MODE_1)) {
+		old_mode = "MODE-1";
+	}
+	else if (phy_ctrl & (MII_TG3_TEST_MODE_2)) {
+		old_mode = "MODE-2";
+	}
+	else if (phy_ctrl & (MII_TG3_TEST_MODE_4)) {
+		old_mode = "MODE-4";
+	}
+	else {
+		old_mode = "NONE";
+	}
+	
+	/* Initialize them to all off, will enabled as needed below */
+	phy_ctrl &= ~(MII_TG3_TEST_MODE_1);
+	phy_ctrl &= ~(MII_TG3_TEST_MODE_2);
+	phy_ctrl &= ~(MII_TG3_TEST_MODE_3);
+	phy_ctrl &= ~(MII_TG3_TEST_MODE_4);
+
+	switch(adapter->gmii_test) {
+	case GMII_TEST_MODE1:
+		phy_ctrl |= MII_TG3_TEST_MODE_1;
+		break;
+	case GMII_TEST_MODE2:
+		phy_ctrl |= MII_TG3_TEST_MODE_2;
+		break;
+	case GMII_TEST_MODE3:
+		phy_ctrl |= MII_TG3_TEST_MODE_3;
+		break;
+	case GMII_TEST_MODE4:
+		phy_ctrl |= MII_TG3_TEST_MODE_4;
+		break;
+	default:
+		/* drop through */
+		break;
+	}/* switch */
+
+	if ((phy_ctrl & (MII_TG3_TEST_MODE_3)) == MII_TG3_TEST_MODE_3) {
+		new_mode = "MODE-3";
+	}
+	else if (phy_ctrl & (MII_TG3_TEST_MODE_1)) {
+		new_mode = "MODE-1";
+	}
+	else if (phy_ctrl & (MII_TG3_TEST_MODE_2)) {
+		new_mode = "MODE-2";
+	}
+	else if (phy_ctrl & (MII_TG3_TEST_MODE_4)) {
+		new_mode = "MODE-4";
+	}
+	else {
+		new_mode = "NONE";
+	}
+
+	if (strcmp(new_mode, old_mode) != 0) {
+		printk("tg3: %s:  Changing GMII Test Mode from: %s to %s (register: 0x%2hx)\n",
+		
+		       adapter->dev->name, old_mode, new_mode, phy_ctrl);
+		tg3_writephy(adapter, MII_TG3_CTRL, phy_ctrl);
+	}
+	
+} /* tg3_GMII_test_mode */
+
+
+
  static int tg3_phy_reset_5703_4_5(struct tg3 *tp)
  {
  	u32 reg32, phy9_orig;
@@ -656,6 +738,7 @@

  out:
  	tg3_phy_set_wirespeed(tp);
+        tg3_GMII_test_mode(tp);
  	return 0;
  }

@@ -1996,6 +2079,7 @@
  		err = tg3_setup_fiber_phy(tp);
  	} else {
  		err = tg3_setup_copper_phy(tp);
+                tg3_GMII_test_mode(tp); /* Set the GMII test mode as desired. */
  	}

  	if (tp->link_config.active_speed == SPEED_1000 &&
@@ -6043,7 +6127,32 @@
  	return ethtool_op_set_tso(dev, value);
  }
  #endif
+
+static int tg3_set_gmii_test(struct net_device *dev, u32 v)
+{
+	struct tg3 *tp = dev->priv;
+
+	spin_lock_irq(&tp->lock);
+        spin_lock(&tp->tx_lock);
+
+        tp->gmii_test = v;
+        /* printk("Setting gmii_test to: %d\n", v); */
+        tg3_setup_phy(tp);
+
+	spin_unlock(&tp->tx_lock);
+	spin_unlock_irq(&tp->lock);

+	return 0;
+}
+
+static int tg3_get_gmii_test(struct net_device *dev, u32* v)
+{
+	struct tg3 *tp = dev->priv;
+        *v = tp->gmii_test;
+        /* printk("Getting gmii_test: %d\n", *v); */
+        return 0;
+}
+
  static int tg3_nway_reset(struct net_device *dev)
  {
  	struct tg3 *tp = dev->priv;
@@ -6285,6 +6394,8 @@
  	.get_tso		= ethtool_op_get_tso,
  	.set_tso		= tg3_set_tso,
  #endif
+        .set_gmii_test          = tg3_set_gmii_test,
+        .get_gmii_test          = tg3_get_gmii_test,
  };

  /* Chips other than 5700/5701 use the NVRAM for fetching info. */
@@ -6608,6 +6719,9 @@
  	/* Enable Ethernet@WireSpeed */
  	tg3_phy_set_wirespeed(tp);

+        /* Enable test modes if desired */
+        tg3_GMII_test_mode(tp);
+
  	if (!err && ((tp->phy_id & PHY_ID_MASK) == PHY_ID_BCM5401)) {
  		err = tg3_init_5401phy_dsp(tp);
  	}

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
