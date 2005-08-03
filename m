From: raghavendra.koushik@neterion.com
Subject: [PATCH 2.6.13-rc4 7/13] S2io: Timer based slowpath handling
Date: Wed,  3 Aug 2005 12:34:11 -0700 (PDT)
Message-ID: <20050803193411.54C9498336@linux.site>
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
This patch implements the slow-path handling functions(link
state change, hardware errors) as a timer. It is not 
handled in interrupt handler as was done previously.


Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
Signed-off-by: Raghavendra Koushik <raghavendra.koushik@neterion.com>
---
diff -uprN vanilla_linux/drivers/net/s2io.c linux-2.6.13-rc4/drivers/net/s2io.c
--- vanilla_linux/drivers/net/s2io.c	2005-08-02 06:25:21.000000000 -0700
+++ linux-2.6.13-rc4/drivers/net/s2io.c	2005-08-02 06:25:31.000000000 -0700
@@ -168,6 +168,12 @@ static char ethtool_stats_keys[][ETH_GST
 #define S2IO_TEST_LEN	sizeof(s2io_gstrings) / ETH_GSTRING_LEN
 #define S2IO_STRINGS_LEN	S2IO_TEST_LEN * ETH_GSTRING_LEN
 
+#define S2IO_TIMER_CONF(timer, handle, arg, exp)		\
+			init_timer(&timer);			\
+			timer.function = handle;		\
+			timer.data = (unsigned long) arg;	\
+			mod_timer(&timer, (jiffies + exp))	\
+
 /*
  * Constants to be programmed into the Xena's registers, to configure
  * the XAUI.
@@ -2741,6 +2747,7 @@ int s2io_open(struct net_device *dev)
 setting_mac_address_failed:
 	free_irq(sp->pdev->irq, dev);
 isr_registration_failed:
+	del_timer_sync(&sp->alarm_timer);
 	s2io_reset(sp);
 hw_init_failed:
 	return err;
@@ -2898,6 +2905,15 @@ int s2io_xmit(struct sk_buff *skb, struc
 	return 0;
 }
 
+static void
+s2io_alarm_handle(unsigned long data)
+{
+	nic_t *sp = (nic_t *)data;
+
+	alarm_intr_handler(sp);
+	mod_timer(&sp->alarm_timer, jiffies + HZ / 2);
+}
+
 /**
  *  s2io_isr - ISR handler of the device .
  *  @irq: the irq of the device.
@@ -2942,9 +2958,6 @@ static irqreturn_t s2io_isr(int irq, voi
 		return IRQ_NONE;
 	}
 
-	if (reason & (GEN_ERROR_INTR))
-		alarm_intr_handler(sp);
-
 #ifdef CONFIG_S2IO_NAPI
 	if (reason & GEN_INTR_RXTRAFFIC) {
 		if (netif_rx_schedule_prep(dev)) {
@@ -4394,6 +4407,7 @@ static void s2io_card_down(nic_t * sp)
 	unsigned long flags;
 	register u64 val64 = 0;
 
+	del_timer_sync(&sp->alarm_timer);
 	/* If s2io_set_link task is executing, wait till it completes. */
 	while (test_and_set_bit(0, &(sp->link_state))) {
 		msleep(50);
@@ -4496,6 +4510,8 @@ static int s2io_card_up(nic_t * sp)
 		return -ENODEV;
 	}
 
+	S2IO_TIMER_CONF(sp->alarm_timer, s2io_alarm_handle, sp, (HZ/2));
+
 	atomic_set(&sp->card_state, CARD_UP);
 	return 0;
 }
diff -uprN vanilla_linux/drivers/net/s2io.h linux-2.6.13-rc4/drivers/net/s2io.h
--- vanilla_linux/drivers/net/s2io.h	2005-08-02 06:25:21.000000000 -0700
+++ linux-2.6.13-rc4/drivers/net/s2io.h	2005-08-02 06:25:31.000000000 -0700
@@ -624,6 +624,9 @@ struct s2io_nic {
 	struct tasklet_struct task;
 	volatile unsigned long tasklet_status;
 
+	/* Timer that handles I/O errors/exceptions */
+	struct timer_list alarm_timer;
+
 	/* Space to back up the PCI config space */
 	u32 config_space[256 / sizeof(u32)];
 
@@ -819,6 +822,7 @@ static int s2io_poll(struct net_device *
 #endif
 static void s2io_init_pci(nic_t * sp);
 int s2io_set_mac_addr(struct net_device *dev, u8 * addr);
+static void s2io_alarm_handle(unsigned long data);
 static irqreturn_t s2io_isr(int irq, void *dev_id, struct pt_regs *regs);
 static int verify_xena_quiescence(nic_t *sp, u64 val64, int flag);
 static struct ethtool_ops netdev_ethtool_ops;
