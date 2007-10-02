From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: Re: Blackfin Ethernet MAC driver compile error
Date: Tue, 2 Oct 2007 11:36:38 -0400
Message-ID: <200710021136.38514.rgetz@blackfin.uclinux.org>
References: <a425f86c0710020430o3507eeb2veb104dc936f230dd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bryan.wu@analog.com
To: "Kalle Pokki" <kalle.pokki@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:45797 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbXJBPgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 11:36:11 -0400
In-Reply-To: <a425f86c0710020430o3507eeb2veb104dc936f230dd@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue 2 Oct 2007 07:30, Kalle Pokki pondered:
> The Blackfin Ethernet MAC driver does not compile. It seems the driver is
> missing some pinmux defines.
> 
>   CC      drivers/net/bfin_mac.o
> drivers/net/bfin_mac.c: In function 'setup_pin_mux':
> drivers/net/bfin_mac.c:275: error: 'P_MII0' undeclared (first use in
> this function)
> drivers/net/bfin_mac.c:275: error: (Each undeclared identifier is
> reported only once
> drivers/net/bfin_mac.c:275: error: for each function it appears in.)

Unfortunately, Bryan is out for the week, so he can't update things..

The updates to include/asm-blackfin/mach-bf537/portmux.h seem to have been 
missing from Bryan's git tree, and therefore were not pushed to Linus's tree.

Sigh. - Sorry about that.

When Bryan gets back, he will update things, but for now, this might work. (I 
don't know if there are any other interdependencies).


--- portmux.h	2007-10-02 11:18:34.000000000 -0400
+++ ./linux-2.6.x/include/asm-blackfin/mach-bf537/portmux.h	2007-08-18 
19:37:22.000000000 -0400
@@ -99,11 +99,44 @@
 #define P_SPORT0_DRPRI	(P_DEFINED | P_IDENT(PORT_PJ8) | P_FUNCT(0))
 #define P_SPORT0_TSCLK	(P_DEFINED | P_IDENT(PORT_PJ9) | P_FUNCT(0))
 #define P_SPORT0_TFS	(P_DEFINED | P_IDENT(PORT_PJ10) | P_FUNCT(0))
-#define P_SPORT0_DTPRI	(P_DEFINED | P_IDENT(PORT_PJ11) | P_FUNCT(1))
+#define P_SPORT0_DTPRI	(P_DEFINED | P_IDENT(PORT_PJ11) | P_FUNCT(0))
 #define P_CAN0_RX	(P_DEFINED | P_IDENT(PORT_PJ4) | P_FUNCT(1))
 #define P_CAN0_TX	(P_DEFINED | P_IDENT(PORT_PJ5) | P_FUNCT(1))
 #define P_SPI0_SSEL3	(P_DEFINED | P_IDENT(PORT_PJ10) | P_FUNCT(1))
 #define P_SPI0_SSEL2	(P_DEFINED | P_IDENT(PORT_PJ11) | P_FUNCT(1))
 #define P_SPI0_SSEL7	(P_DEFINED | P_IDENT(PORT_PJ5) | P_FUNCT(2))
 
-#endif /* _MACH_PORTMUX_H_ */
+#define P_MII0 {\
+	P_MII0_ETxD0, \
+	P_MII0_ETxD1, \
+	P_MII0_ETxD2, \
+	P_MII0_ETxD3, \
+	P_MII0_ETxEN, \
+	P_MII0_TxCLK, \
+	P_MII0_PHYINT, \
+	P_MII0_COL, \
+	P_MII0_ERxD0, \
+	P_MII0_ERxD1, \
+	P_MII0_ERxD2, \
+	P_MII0_ERxD3, \
+	P_MII0_ERxDV, \
+	P_MII0_ERxCLK, \
+	P_MII0_ERxER, \
+	P_MII0_CRS, \
+	P_MDC, \
+	P_MDIO, 0}
+
+
+#define P_RMII0 {\
+	P_MII0_ETxD0, \
+	P_MII0_ETxD1, \
+	P_MII0_ETxEN, \
+	P_MII0_ERxD0, \
+	P_MII0_ERxD1, \
+	P_MII0_ERxER, \
+	P_RMII0_REF_CLK, \
+	P_RMII0_MDINT, \
+	P_RMII0_CRS_DV, \
+	P_MDC, \
+	P_MDIO, 0}
+#endif			        	/* _MACH_PORTMUX_H_ */

> drivers/net/bfin_mac.c:279: error: implicit declaration of function
> 'peripheral_request_list'
> drivers/net/bfin_mac.c:285: error: implicit declaration of function
> 'peripheral_free_list'

Arg.

This was in an arch/blackfin/kernel/bfin_gpio.c update that hasn't seem to 
made it either.

In the future - we will make sure driver submissions are done in the correct 
order - so the proper infrastructure is in the tree before the driver is 
submitted. - Sorry.



Index: arch/blackfin/kernel/bfin_gpio.c
===================================================================
--- arch/blackfin/kernel/bfin_gpio.c	(revision 3403)
+++ arch/blackfin/kernel/bfin_gpio.c	(revision 3404)
@@ -84,6 +84,7 @@
 #include <linux/err.h>
 #include <asm/blackfin.h>
 #include <asm/gpio.h>
+#include <asm/portmux.h>
 #include <linux/irq.h>
 
 #ifdef BF533_FAMILY
@@ -115,8 +116,12 @@
 };
 #endif
 
-static unsigned short reserved_map[gpio_bank(MAX_BLACKFIN_GPIOS)];
+static unsigned short reserved_gpio_map[gpio_bank(MAX_BLACKFIN_GPIOS)];
+static unsigned short reserved_peri_map[gpio_bank(MAX_BLACKFIN_GPIOS + 16)];
+char *str_ident = NULL;
 
+#define RESOURCE_LABEL_SIZE 16
+
 #ifdef CONFIG_PM
 static unsigned short wakeup_map[gpio_bank(MAX_BLACKFIN_GPIOS)];
 static unsigned char wakeup_flags_map[MAX_BLACKFIN_GPIOS];
@@ -143,13 +148,39 @@
 	return 0;
 }
 
+static void set_label(unsigned short ident, const char *label)
+{
+
+	if (label && str_ident) {
+		strncpy(str_ident + ident * RESOURCE_LABEL_SIZE, label,
+			 RESOURCE_LABEL_SIZE);
+		str_ident[ident * RESOURCE_LABEL_SIZE +
+			 RESOURCE_LABEL_SIZE - 1] = 0;
+	}
+}
+
+static char *get_label(unsigned short ident)
+{
+	if (!str_ident)
+		return "UNKNOWN";
+
+	return (str_ident[ident * RESOURCE_LABEL_SIZE] ?
+		(str_ident + ident * RESOURCE_LABEL_SIZE) : "UNKNOWN");
+}
+
+static int cmp_label(unsigned short ident, const char *label)
+{
+	if (label && str_ident)
+		return strncmp(str_ident + ident * RESOURCE_LABEL_SIZE,
+				 label, strlen(label));
+	else
+		return -EINVAL;
+}
+
 #ifdef BF537_FAMILY
 static void port_setup(unsigned short gpio, unsigned short usage)
 {
 	if (usage == GPIO_USAGE) {
-		if (*port_fer[gpio_bank(gpio)] & gpio_bit(gpio))
-			printk(KERN_WARNING "bfin-gpio: Possible Conflict with Peripheral "
-			       "usage and GPIO %d detected!\n", gpio);
 		*port_fer[gpio_bank(gpio)] &= ~gpio_bit(gpio);
 	} else
 		*port_fer[gpio_bank(gpio)] |= gpio_bit(gpio);
@@ -159,7 +190,57 @@
 # define port_setup(...)  do { } while (0)
 #endif
 
+#ifdef BF537_FAMILY
 
+#define PMUX_LUT_RES		0
+#define PMUX_LUT_OFFSET		1
+#define PMUX_LUT_ENTRIES	41
+#define PMUX_LUT_SIZE		2
+
+static unsigned short port_mux_lut[PMUX_LUT_ENTRIES][PMUX_LUT_SIZE] = {
+	{P_PPI0_D13, 11}, {P_PPI0_D14, 11}, {P_PPI0_D15, 11},
+	{P_SPORT1_TFS, 11}, {P_SPORT1_TSCLK, 11}, {P_SPORT1_DTPRI, 11},
+	{P_PPI0_D10, 10}, {P_PPI0_D11, 10}, {P_PPI0_D12, 10},
+	{P_SPORT1_RSCLK, 10}, {P_SPORT1_RFS, 10}, {P_SPORT1_DRPRI, 10},
+	{P_PPI0_D8, 9}, {P_PPI0_D9, 9}, {P_SPORT1_DRSEC, 9},
+	{P_SPORT1_DTSEC, 9}, {P_TMR2, 8}, {P_PPI0_FS3, 8}, {P_TMR3, 7},
+	{P_SPI0_SSEL4, 7}, {P_TMR4, 6}, {P_SPI0_SSEL5, 6}, {P_TMR5, 5},
+	{P_SPI0_SSEL6, 5}, {P_UART1_RX, 4}, {P_UART1_TX, 4}, {P_TMR6, 4},
+	{P_TMR7, 4}, {P_UART0_RX, 3}, {P_UART0_TX, 3}, {P_DMAR0, 3},
+	{P_DMAR1, 3}, {P_SPORT0_DTSEC, 1}, {P_SPORT0_DRSEC, 1},
+	{P_CAN0_RX, 1}, {P_CAN0_TX, 1}, {P_SPI0_SSEL7, 1},
+	{P_SPORT0_TFS, 0}, {P_SPORT0_DTPRI, 0}, {P_SPI0_SSEL2, 0},
+	{P_SPI0_SSEL3, 0}
+};
+
+static void portmux_setup(unsigned short per, unsigned short function)
+{
+	u16 y, muxreg, offset;
+
+	for (y = 0; y < PMUX_LUT_ENTRIES; y++) {
+		if (port_mux_lut[y][PMUX_LUT_RES] == per) {
+
+			/* SET PORTMUX REG */
+
+			offset = port_mux_lut[y][PMUX_LUT_OFFSET];
+			muxreg = bfin_read_PORT_MUX();
+
+			if (offset != 1) {
+				muxreg &= ~(1 << offset);
+			} else {
+				muxreg &= ~(3 << 1);
+			}
+
+			muxreg |= (function << offset);
+			bfin_write_PORT_MUX(muxreg);
+		}
+	}
+}
+
+#else
+# define portmux_setup(...)  do { } while (0)
+#endif
+
 static void default_gpio(unsigned short gpio)
 {
 	unsigned short bank, bitmask;
@@ -179,22 +260,15 @@
 
 static int __init bfin_gpio_init(void)
 {
-	int i;
 
+	str_ident = kzalloc(RESOURCE_LABEL_SIZE * 256, GFP_KERNEL);
+	if (!str_ident)
+		return -ENOMEM;
+
 	printk(KERN_INFO "Blackfin GPIO Controller\n");
 
-	for (i = 0; i < MAX_BLACKFIN_GPIOS; i += GPIO_BANKSIZE)
-		reserved_map[gpio_bank(i)] = 0;
+	return 0;
 
-#if defined(BF537_FAMILY) && (defined(CONFIG_BFIN_MAC) || 
defined(CONFIG_BFIN_MAC_MODULE))
-# if defined(CONFIG_BFIN_MAC_RMII)
-	reserved_map[gpio_bank(PORT_H)] = 0xC373;
-# else
-	reserved_map[gpio_bank(PORT_H)] = 0xFFFF;
-# endif
-#endif
-
-	return 0;
 }
 
 arch_initcall(bfin_gpio_init);
@@ -223,7 +297,7 @@
 void set_gpio_ ## name(unsigned short gpio, unsigned short arg) \
 { \
 	unsigned long flags; \
-	BUG_ON(!(reserved_map[gpio_bank(gpio)] & gpio_bit(gpio))); \
+	BUG_ON(!(reserved_gpio_map[gpio_bank(gpio)] & gpio_bit(gpio))); \
 	local_irq_save(flags); \
 	if (arg) \
 		gpio_bankb[gpio_bank(gpio)]->name |= gpio_bit(gpio); \
@@ -243,7 +317,7 @@
 #define SET_GPIO_SC(name) \
 void set_gpio_ ## name(unsigned short gpio, unsigned short arg) \
 { \
-	BUG_ON(!(reserved_map[gpio_bank(gpio)] & gpio_bit(gpio))); \
+	BUG_ON(!(reserved_gpio_map[gpio_bank(gpio)] & gpio_bit(gpio))); \
 	if (arg) \
 		gpio_bankb[gpio_bank(gpio)]->name ## _set = gpio_bit(gpio); \
 	else \
@@ -258,7 +332,7 @@
 void set_gpio_data(unsigned short gpio, unsigned short arg)
 {
 	unsigned long flags;
-	BUG_ON(!(reserved_map[gpio_bank(gpio)] & gpio_bit(gpio)));
+	BUG_ON(!(reserved_gpio_map[gpio_bank(gpio)] & gpio_bit(gpio)));
 	local_irq_save(flags);
 	if (arg)
 		gpio_bankb[gpio_bank(gpio)]->data_set = gpio_bit(gpio);
@@ -277,7 +351,7 @@
 void set_gpio_toggle(unsigned short gpio)
 {
 	unsigned long flags;
-	BUG_ON(!(reserved_map[gpio_bank(gpio)] & gpio_bit(gpio)));
+	BUG_ON(!(reserved_gpio_map[gpio_bank(gpio)] & gpio_bit(gpio)));
 	local_irq_save(flags);
 	gpio_bankb[gpio_bank(gpio)]->toggle = gpio_bit(gpio);
 	bfin_read_CHIPID();
@@ -286,7 +360,7 @@
 #else
 void set_gpio_toggle(unsigned short gpio)
 {
-	BUG_ON(!(reserved_map[gpio_bank(gpio)] & gpio_bit(gpio)));
+	BUG_ON(!(reserved_gpio_map[gpio_bank(gpio)] & gpio_bit(gpio)));
 	gpio_bankb[gpio_bank(gpio)]->toggle = gpio_bit(gpio);
 }
 #endif
@@ -350,7 +424,7 @@
 {
 	unsigned long flags;
 	unsigned short ret;
-	BUG_ON(!(reserved_map[gpio_bank(gpio)] & gpio_bit(gpio)));
+	BUG_ON(!(reserved_gpio_map[gpio_bank(gpio)] & gpio_bit(gpio)));
 	local_irq_save(flags);
 	ret = 0x01 & (gpio_bankb[gpio_bank(gpio)]->data >> gpio_sub_n(gpio));
 	bfin_read_CHIPID();
@@ -494,13 +568,14 @@
 			gpio_bank_saved[bank].dir   = gpio_bankb[bank]->dir;
 			gpio_bank_saved[bank].edge  = gpio_bankb[bank]->edge;
 			gpio_bank_saved[bank].both  = gpio_bankb[bank]->both;
-			gpio_bank_saved[bank].reserved = reserved_map[bank];
+			gpio_bank_saved[bank].reserved =
+						reserved_gpio_map[bank];
 
 			gpio = i;
 
 			while (mask) {
 				if (mask & 1) {
-					reserved_map[gpio_bank(gpio)] |=
+					reserved_gpio_map[gpio_bank(gpio)] |=
 							gpio_bit(gpio);
 					bfin_gpio_wakeup_type(gpio,
 						wakeup_flags_map[gpio]);
@@ -540,7 +615,8 @@
 			gpio_bankb[bank]->edge  = gpio_bank_saved[bank].edge;
 			gpio_bankb[bank]->both  = gpio_bank_saved[bank].both;
 
-			reserved_map[bank] = gpio_bank_saved[bank].reserved;
+			reserved_gpio_map[bank] =
+					gpio_bank_saved[bank].reserved;
 
 		}
 
@@ -550,6 +626,140 @@
 
 #endif
 
+
+
+
+int peripheral_request(unsigned short per, const char *label)
+{
+	unsigned long flags;
+	unsigned short ident = P_IDENT(per);
+
+	/*
+	 * Don't cares are pins with only one dedicated function
+	 */
+
+	if (per & P_DONTCARE)
+		return 0;
+
+	if (!(per & P_DEFINED))
+		return -ENODEV;
+
+	if (check_gpio(ident) < 0)
+		return -EINVAL;
+
+	local_irq_save(flags);
+
+	if (unlikely(reserved_gpio_map[gpio_bank(ident)] & gpio_bit(ident))) {
+		printk(KERN_ERR
+		       "%s: Peripheral %d is already reserved as GPIO by %s !\n",
+		       __FUNCTION__, ident, get_label(ident));
+		dump_stack();
+		local_irq_restore(flags);
+		return -EBUSY;
+	}
+
+	if (unlikely(reserved_peri_map[gpio_bank(ident)] & gpio_bit(ident))) {
+
+	/*
+	 * Pin functions like AMC address strobes my
+	 * be requested and used by several drivers
+	 */
+
+	if (!(per & P_MAYSHARE)) {
+
+	/*
+	 * Allow that the identical pin function can
+	 * be requested from the same driver twice
+	 */
+
+		if (cmp_label(ident, label) == 0)
+			goto anyway;
+
+			printk(KERN_ERR
+			       "%s: Peripheral %d function %d is already"
+			       "reserved by %s !\n",
+			       __FUNCTION__, ident, P_FUNCT2MUX(per),
+				get_label(ident));
+			dump_stack();
+			local_irq_restore(flags);
+			return -EBUSY;
+		}
+
+	}
+
+anyway:
+
+
+	portmux_setup(per, P_FUNCT2MUX(per));
+
+	port_setup(ident, PERIPHERAL_USAGE);
+
+	reserved_peri_map[gpio_bank(ident)] |= gpio_bit(ident);
+	local_irq_restore(flags);
+	set_label(ident, label);
+
+	return 0;
+}
+EXPORT_SYMBOL(peripheral_request);
+
+int peripheral_request_list(unsigned short per[], const char *label)
+{
+	u16 cnt;
+	int ret;
+
+	for (cnt = 0; per[cnt] != 0; cnt++) {
+		ret = peripheral_request(per[cnt], label);
+		if (ret < 0)
+			return ret;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(peripheral_request_list);
+
+void peripheral_free(unsigned short per)
+{
+	unsigned long flags;
+	unsigned short ident = P_IDENT(per);
+
+	if (per & P_DONTCARE)
+		return;
+
+	if (!(per & P_DEFINED))
+		return;
+
+	if (check_gpio(ident) < 0)
+		return;
+
+	local_irq_save(flags);
+
+	if (unlikely(!(reserved_peri_map[gpio_bank(ident)]
+			 & gpio_bit(ident)))) {
+		local_irq_restore(flags);
+		return;
+	}
+
+	if (!(per & P_MAYSHARE)) {
+		port_setup(ident, GPIO_USAGE);
+	}
+
+	reserved_peri_map[gpio_bank(ident)] &= ~gpio_bit(ident);
+
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(peripheral_free);
+
+void peripheral_free_list(unsigned short per[])
+{
+	u16 cnt;
+
+	for (cnt = 0; per[cnt] != 0; cnt++) {
+		peripheral_free(per[cnt]);
+	}
+
+}
+EXPORT_SYMBOL(peripheral_free_list);
+
 /***********************************************************
 *
 * FUNCTIONS: Blackfin GPIO Driver
@@ -574,13 +784,13 @@
 
 	local_irq_save(flags);
 
-	if (unlikely(reserved_map[gpio_bank(gpio)] & gpio_bit(gpio))) {
+	if (unlikely(reserved_gpio_map[gpio_bank(gpio)] & gpio_bit(gpio))) {
 		printk(KERN_ERR "bfin-gpio: GPIO %d is already reserved!\n", gpio);
 		dump_stack();
 		local_irq_restore(flags);
 		return -EBUSY;
 	}
-	reserved_map[gpio_bank(gpio)] |= gpio_bit(gpio);
+	reserved_gpio_map[gpio_bank(gpio)] |= gpio_bit(gpio);
 
 	local_irq_restore(flags);
 
@@ -599,7 +809,7 @@
 
 	local_irq_save(flags);
 
-	if (unlikely(!(reserved_map[gpio_bank(gpio)] & gpio_bit(gpio)))) {
+	if (unlikely(!(reserved_gpio_map[gpio_bank(gpio)] & gpio_bit(gpio)))) {
 		printk(KERN_ERR "bfin-gpio: GPIO %d wasn't reserved!\n", gpio);
 		dump_stack();
 		local_irq_restore(flags);
@@ -608,7 +818,7 @@
 
 	default_gpio(gpio);
 
-	reserved_map[gpio_bank(gpio)] &= ~gpio_bit(gpio);
+	reserved_gpio_map[gpio_bank(gpio)] &= ~gpio_bit(gpio);
 
 	local_irq_restore(flags);
 }
@@ -618,7 +828,7 @@
 {
 	unsigned long flags;
 
-	BUG_ON(!(reserved_map[gpio_bank(gpio)] & gpio_bit(gpio)));
+	BUG_ON(!(reserved_gpio_map[gpio_bank(gpio)] & gpio_bit(gpio)));
 
 	local_irq_save(flags);
 	gpio_bankb[gpio_bank(gpio)]->dir &= ~gpio_bit(gpio);
@@ -631,7 +841,7 @@
 {
 	unsigned long flags;
 
-	BUG_ON(!(reserved_map[gpio_bank(gpio)] & gpio_bit(gpio)));
+	BUG_ON(!(reserved_gpio_map[gpio_bank(gpio)] & gpio_bit(gpio)));
 
 	local_irq_save(flags);
 	gpio_bankb[gpio_bank(gpio)]->inen &= ~gpio_bit(gpio);

