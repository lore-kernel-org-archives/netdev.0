From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: Submission #4  for S2io 10GbE driver
Date: Fri, 19 Mar 2004 20:35:49 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <001001c40e34$d2c3c4b0$0300a8c0@S2IOtech.com>
References: <4040F866.9040200@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_0011_01C40DF1.C4A084B0"
Cc: <netdev@oss.sgi.com>, "'ravinandan arakali'" <ravinandan.arakali@s2io.com>,
        <raghavendra.koushik@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>
In-Reply-To: <4040F866.9040200@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_0011_01C40DF1.C4A084B0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

All the issues are addressed, except for the ones that were discussed
and resolved over e-mail.

Best Regards, 
Leonid

> -----Original Message-----
> From: Jeff Garzik [mailto:jgarzik@pobox.com]
> Sent: Saturday, February 28, 2004 12:22 PM
> To: Leonid Grossman
> Cc: netdev@oss.sgi.com; 'Stephen Hemminger'; 'Christoph 
> Hellwig'; 'ravinandan arakali'; raghavendra.koushik@s2io.com
> Subject: Re: Submission #3 for S2io 10GbE driver
> 
> 
> Looking a lot better.  A few merge issues remain, and some
> operational 
> ones as well.  There are 39 issues in this review, but IMO they are 
> mostly minor issues that don't require much thought or work.
> 
> 
> Comments:
> 
> 0) to repeat myself from an earlier review...  grumble...
> You CANNOT use NETIF_F_HW_CSUM, when your hardware does not
> provide the 
> checksum value.  You must use NETIF_F_IP_CSUM.  Your use of 
> NETIF_F_HW_CSUM + CHECKSUM_UNNECESSARY is flat out incorrect.
> 
> 1) the makefile is for out-of-tree stuff.  The proper
> makefile will be 
> much smaller.  So just submit a proper in-tree Makefile.
> 
> 2) (in general) we don't want the compatibility stuff in-tree, that's
> for out-of-tree as well.
> 
> 3) just submit a patch to include/linux/pci_ids.h instead of
> the following
> 
> +/* VENDOR and DEVICE ID of XENA. */
> +#ifndef PCI_VENDOR_ID_S2IO
> +#define PCI_VENDOR_ID_S2IO      0x17D5
> +#define PCI_DEVICE_ID_S2IO_WIN  0x5731
> +#define PCI_DEVICE_ID_S2IO_UNI  0x5831
> +#endif
> 
> 4) just delete the SET_NETDEV_DEV(), FREE_NETDEV, and IRQ_NONE
> compatibility defines.  these are in 2.4 just like 2.6.
> 
> 5) Many PCI posting bugs remain.  FixMacAddress is an excellent
> illustration:
> 
> +       write64(&bar0->gpio_control, 0x0040600000000000ULL);
> +       udelay(10);
> +       write64(&bar0->gpio_control, 0x0000600000000000ULL);
> +       udelay(10);
> +       write64(&bar0->gpio_control, 0x0020600000000000ULL);
> +       udelay(10);
> +       write64(&bar0->gpio_control, 0x0060600000000000ULL);
> +       udelay(10);
> 
> The delay is _not_ guaranteed at all, because you do not know
> when that 
> write64() will actually be sent to the PCI bus.  Only a 
> read[bwl,64] is 
> guaranteed to flush the write to the PCI device.
> 
> So, the above code does not function as you would expect, on
> all platforms.
> 
> 6) More examples of PCI posting bugs, in startNic:
> 
> +       write64(&bar0->mc_rldram_mrs, val64);
> +       set_current_state(TASK_UNINTERRUPTIBLE);
> +       schedule_timeout(HZ / 10);
> 
> and
> 
> +       write64(&bar0->dtx_control, 0x8007051500000000ULL);
> +       udelay(50);
> +       write64(&bar0->dtx_control, 0x80070515000000E0ULL);
> +       udelay(50);
> +       write64(&bar0->dtx_control, 0x80070515001F00E4ULL);
> +       udelay(50);
> 
> 7) for fragmented skb's, you should be using pci_map_page() not
> pci_map_single().  Example in drivers/net/tg3.c.
> 
> 8) (style) in alarmIntrHandler, due to line wrapping, Lindent has
> rendered the 'do' loop rather unreadable.
> 
> 9) you cannot sleep inside the interrupt handler.  Therefore the
> schedule_timeout() in alarmIntrHandler is very wrong.
> 
> 10) never use a plain constant when calling
> schedule_timeout(), such as 
> in waitForCmdComplete.  Always calculate the desired delay 
> based on the 
> HZ constant.  Otherwise, your delay varies depending on platform.  HZ 
> represents one second, in jiffies.  So half a second delay 
> would be "HZ 
> / 2", etc.  Also, when fixing, be careful that your HZ-based 
> calculation 
> will never evaluate to zero.
> 
> 11) ditto s2io_reset
> 
> 12) ditto s2io_close.  etc.
> 
> 13) in s2io_xmit, kfree the skb (drop it) if you don't have
> enough free 
> space to queue it.  this is normally a BUG condition, since 
> proper use 
> of netif_{start,stop,wake}_queue() will guarantee that s2io_xmit will 
> only be called when there is free space to queue another skb.
> 
> 14) spin_lock(), not spin_lock_irqsave(), in your interrupt handler.
> spin_lock_irqsave() is normally used in any of three cases:  
> (1) don't 
> know whether you're in an ISR or not, (2) definitely not in 
> an ISR, or 
> (3) your ISR is called from more than one hardware interrupt. 
>  None of 
> these three is the case.
> 
> 15) does s2io_get_stats need locking?
> 
> 16) (style) If you are going to comment each function, you
> might as well 
> do it in the "kernel-doc" style, which allows the comments to 
> be picked 
> up by automated tools.  The format is
> 
> 	/**
> 	 *	function_name - short description
> 	 *	@argument1: argument 1 description
> 	 *	@argument2: argument 2 description
> 	 *	...
> 	 * SOMETHING:
> 	 * blah blah blah
> 	 * SOMETHING ELSE:
> 	 * blah blah blah
> 
> The "ALL_CAPS:" indicates a new section/paragraph, in the document.
> 
> Once this is done, you may add a stub document to
> Documentation/DocBook/ 
> and then create your driver's nicely-formatted documentation 
> using "make 
> pdfdocs", "make psdocs", or "make htmldocs".
> 
> 17) this define belongs in include/linux/ethtool.h, if it's not there
> already...
> +#define SPEED_10000 10000
> 
> 18) remove #ifdefs such as
> +#if defined(ETHTOOL_GREGS)
> +       info->regdump_len = XENA_REG_SPACE;
> +#endif
> 
> since this exists in both 2.4 and 2.6 kernels.
> 
> 19) ditto:
> +#ifdef ETHTOOL_PHYS_ID
> 
> 20) for the ethtool EEPROM and register dumps, it would be nice to
> submit a patch to me for ethtool (http://sf.net/projects/gkernel/), 
> which generates a verbose dump rather than a bunch of hex numbers 
> incomprehensible to the user.  This is a long, boring, but easy task 
> suitable to an intern, so I understand if it's not done 
> immediately ;-)
> 
> 21) s2io_ethtool_nway_reset should restart PHY autonegotiation, not
> reset the entire card
> 
> 22) eliminate s2io_ethtool_get_link, it duplicates a generic (and
> equivalent) function in net/core/ethtool.c
> 
> 23) ditto, for the s2io_ethtool_{get,set}_{sg,rx,tx}_csum stuff
> 
> 24) don't explicitly set members to NULL in netdev_ethtool_ops
> 
> 25) the update to s2io_tx_watchdog still leaves something to
> be desired. 
>   You are no longer performing the could-take-a-long-time card reset 
> inside of spin_lock_bh()... you are now doing it inside the timer 
> interrupt :(  Move this to process context by using schedule_work() 
> [2.6] or schedule_task [2.4]
> 
> 27) Unconditional netif_wake_queue() in s2io_link() still
> unfixed.  You 
> must check for room for additional TX, before calling 
> netif_{start,wake}_queue().  Consider what happens if the 
> link goes down 
> under the TX-full condition [netif_stop_queue]... instant bug.
> 
> 28) do NOT specify PCI latency timer value as non-zero.
> pci_set_master() chooses an appropriate latency timer value.  It is 
> acceptable to leave this in as an option, as long as the 
> module option's 
> default is zero:
> 
> +static u8 latency_timer = 0xff;
> 
> 29) (style) don't bother casting a void pointer:
> 
> +/*  Private member variable initialized to s2io NIC structure */
> +       sp = (nic_t *) dev->priv;
> 
> 30) redundant assignment of 'sp':
> 
> +       dev->irq = pdev->irq;
> +       dev->base_addr = (unsigned long) sp->bar0;
> +       sp = (nic_t *) dev->priv;
> 
> 31) kill the #ifdef
> 
> +#ifdef SET_ETHTOOL_OPS
> +       SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
> +#endif
> 
> This one is particularly silly, because SET_ETHTOOL_OPS() is
> -designed- 
> to eliminate ifdefs.  A driver wishing to be compatible will 
> provide its 
> own SET_ETHTOOL_OPS definition, guaranteeing it can be used 
> unconditionally in the driver code here.
> 
> 32) mark s2io_starter with "__init"
> 
> 33) kill this:
> 
> +#ifndef ETH_ALEN
> +#define ETH_ALEN    6
> +#endif
> 
> 34) the definitions of SUCCESS and FAILURE are incorrect.  The driver
> should return 0 on success, and a negative errno-based error code on 
> failure.  -EBUSY, -EOPNOTSUPP, etc.
> 
> 35) kill this:
> 
> +#ifndef SUPPORTED_10000baseT_Full
> +#define SUPPORTED_10000baseT_Full (1 << 12)
> +#endif
> 
> 36) (feature addition) you have a ton of NIC-specific
> statistics.  You 
> should make those available to users, via ethtool.
> 
> 37) kill all of this:
> 
> +/*  OS related system calls */
> +
> +#ifndef readq
> +static inline u64 read64(void *addr)
> +{
> +       u64 ret = 0;
> +       ret = readl(addr + 4);
> +       (u64) ret <<= 32;
> +       (u64) ret |= readl(addr);
> +
> +       return ret;
> +}
> +#else
> +static inline u64 read64(void *addr)
> +{
> +       u64 ret = readq(addr);
> +       return ret;
> +}
> +#endif
> +#define read32(addr, ret)  ret =  readl(addr);
> +#define read16(addr, ret)  ret =  readw(addr);
> +#define read8(addr, ret)   ret =  readb(addr);
> +
> +#ifndef writeq
> +static inline void write64(void *addr, u64 val)
> +{
> +       writel((u32) (val), addr);
> +       writel((u32) (val >> 32), (addr + 4));
> +}
> +#else
> +#define write64(addr, ret) writeq(ret,(void *)addr)
> +#endif
> +#define write32(addr, ret) writel(ret,(void *)addr);
> +#define write16(addr, ret) writew(ret,(void *)addr);
> +#define write8(addr, ret)  writeb(ret,(void *)addr);
> 
> 38) sysctl_xframe.conf belongs somewhere in Documentation/*
> 
> 
> 

------=_NextPart_000_0011_01C40DF1.C4A084B0
Content-Type: application/octet-stream;
	name="s2ioDriver.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="s2ioDriver.patch"

diff -urN vanilla-linux/Documentation/networking/s2io.txt =
vanilla-linux-patch/Documentation/networking/s2io.txt=0A=
--- vanilla-linux/Documentation/networking/s2io.txt	1970-01-01 =
05:30:00.000000000 +0530=0A=
+++ vanilla-linux-patch/Documentation/networking/s2io.txt	2004-03-15 =
16:04:25.000000000 +0530=0A=
@@ -0,0 +1,48 @@=0A=
+S2IO Technologies XFrame 10 Gig adapter.
+-------------------------------------------
+
+I. Module loadable parameters.
+When loaded as a module, the driver provides a host of Module loadable
+parameters, so the device can be tuned as per the users needs.
+A list of the Module params is given below.
+(i)	ring_num: This can be used to program the number of
+		 receive rings used in the driver.
+(ii)	ring_len: This defines the number of descriptors each ring
+		 can have. There can be a maximum of 8 rings.
+(iii)	frame_len: This is an array of size 8. Using this we can=20
+		 set the maximum size of the received frame that can
+		 be steered into the corrsponding receive ring.=09
+(iv)	fifo_num: This defines the number of Tx FIFOs thats used in
+		 the driver.=20
+(v)	fifo_len: Each element defines the number of=20
+ 		 Tx descriptors that can be associated with each=20
+		 corresponding FIFO. There are a maximum of 8 FIFOs.
+(vi)	tx_prio: This is a bool, if module is loaded with a non-zero
+		value for tx_prio multi FIFO scheme is activated.
+(vii)	rx_prio: This is a bool, if module is loaded with a non-zero
+		value for tx_prio multi RING scheme is activated.
+(viii)	latency_timer: The value given against this param will be
+		 loaded	into the latency timer register in PCI Config
+		 space, else the register is left with its reset value.
+
+II. Performance tuning.
+ By changing a few sysctl parameters.
+	Copy the following lines into a file and run the following command,
+	"sysctl -p <file_name>"
+### IPV4 specific settings
+net.ipv4.tcp_timestamps =3D 0 # turns TCP timestamp support off, =
default 1, reduces CPU use
+net.ipv4.tcp_sack =3D 0 # turn SACK support off, default on
+# on systems with a VERY fast bus -> memory interface this is the big =
gainer
+net.ipv4.tcp_rmem =3D 10000000 10000000 10000000 # sets min/default/max =
TCP read buffer, default 4096 87380 174760
+net.ipv4.tcp_wmem =3D 10000000 10000000 10000000 # sets =
min/pressure/max TCP write buffer, default 4096 16384 131072
+net.ipv4.tcp_mem =3D 10000000 10000000 10000000 # sets min/pressure/max =
TCP buffer space, default 31744 32256 32768
+                                                                        =
       =20
+### CORE settings (mostly for socket and UDP effect)
+net.core.rmem_max =3D 524287 # maximum receive socket buffer size, =
default 131071
+net.core.wmem_max =3D 524287 # maximum send socket buffer size, default =
131071
+net.core.rmem_default =3D 524287 # default receive socket buffer size, =
default 65535
+net.core.wmem_default =3D 524287 # default send socket buffer size, =
default 65535
+net.core.optmem_max =3D 524287 # maximum amount of option memory =
buffers, default 10240
+net.core.netdev_max_backlog =3D 300000 # number of unprocessed input =
packets before kernel starts dropping them, default 300
+---End of performance tuning file---
+
diff -urN vanilla-linux/drivers/net/Kconfig =
vanilla-linux-patch/drivers/net/Kconfig=0A=
--- vanilla-linux/drivers/net/Kconfig	2003-10-26 00:14:36.000000000 +0530=0A=
+++ vanilla-linux-patch/drivers/net/Kconfig	2004-02-27 =
20:26:00.000000000 +0530=0A=
@@ -2058,6 +2058,18 @@=0A=
 	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"=0A=
 	depends on IXGB && EXPERIMENTAL=0A=
 =0A=
+config S2IO=0A=
+	tristate "S2IO 10Gbe XFrame NIC"=0A=
+	depends on PCI=0A=
+	---help---=0A=
+	  This driver supports the 10Gbe XFrame NIC of S2IO. =0A=
+	  For help regarding driver compilation, installation and =0A=
+	  tuning please look into ~/drivers/net/s2io/README.txt.=0A=
+=0A=
+config S2IO_NAPI=0A=
+	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"=0A=
+	depends on S2IO && EXPERIMENTAL=0A=
+=0A=
 endmenu=0A=
 =0A=
 =0A=
diff -urN vanilla-linux/drivers/net/s2io/Makefile =
vanilla-linux-patch/drivers/net/s2io/Makefile=0A=
--- vanilla-linux/drivers/net/s2io/Makefile	1970-01-01 =
05:30:00.000000000 +0530=0A=
+++ vanilla-linux-patch/drivers/net/s2io/Makefile	2004-03-17 =
11:52:20.000000000 +0530=0A=
@@ -0,0 +1,5 @@=0A=
+#=0A=
+# Makefile for the S2IO Technologies XFrame 10Gig NIC=0A=
+#=0A=
+=0A=
+obj-$(CONFIG_S2IO) +=3D s2io.o=0A=
diff -urN vanilla-linux/drivers/net/s2io/regs.h =
vanilla-linux-patch/drivers/net/s2io/regs.h=0A=
--- vanilla-linux/drivers/net/s2io/regs.h	1970-01-01 05:30:00.000000000 =
+0530=0A=
+++ vanilla-linux-patch/drivers/net/s2io/regs.h	2004-03-17 =
11:52:25.000000000 +0530=0A=
@@ -0,0 +1,775 @@=0A=
+/***********************************************************************=
*=0A=
+ * regs.h: A Linux PCI-X Ethernet driver for S2IO 10GbE Server NIC=0A=
+ * Copyright 2002 Raghavendra Koushik (raghavendra.koushik@s2io.com)=0A=
+=0A=
+ * This software may be used and distributed according to the terms of=0A=
+ * the GNU General Public License (GPL), incorporated herein by =
reference.=0A=
+ * Drivers based on or derived from this code fall under the GPL and =
must=0A=
+ * retain the authorship, copyright and license notice.  This file is =
not=0A=
+ * a complete program and may only be used when the entire operating=0A=
+ * system is licensed under the GPL.=0A=
+ * See the file COPYING in this distribution for more information.=0A=
+ =
************************************************************************/=0A=
+#ifndef _REGS_H=0A=
+#define _REGS_H=0A=
+=0A=
+#define TBD 0=0A=
+=0A=
+typedef struct _XENA_dev_config {=0A=
+/* Convention: mHAL_XXX is mask, vHAL_XXX is value */=0A=
+=0A=
+/* General Control-Status Registers */=0A=
+	u64 general_int_status;=0A=
+#define GEN_INTR_TXPIC             BIT(0)=0A=
+#define GEN_INTR_TXDMA             BIT(1)=0A=
+#define GEN_INTR_TXMAC             BIT(2)=0A=
+#define GEN_INTR_TXXGXS            BIT(3)=0A=
+#define GEN_INTR_TXTRAFFIC         BIT(8)=0A=
+#define GEN_INTR_RXPIC             BIT(32)=0A=
+#define GEN_INTR_RXDMA             BIT(33)=0A=
+#define GEN_INTR_RXMAC             BIT(34)=0A=
+#define GEN_INTR_MC                BIT(35)=0A=
+#define GEN_INTR_RXXGXS            BIT(36)=0A=
+#define GEN_INTR_RXTRAFFIC         BIT(40)=0A=
+#define GEN_ERROR_INTR             GEN_INTR_TXPIC | GEN_INTR_RXPIC | \=0A=
+                                   GEN_INTR_TXDMA | GEN_INTR_RXDMA | \=0A=
+                                   GEN_INTR_TXMAC | GEN_INTR_RXMAC | \=0A=
+                                   GEN_INTR_TXXGXS| GEN_INTR_RXXGXS| \=0A=
+                                   GEN_INTR_MC=0A=
+=0A=
+	u64 general_int_mask;=0A=
+=0A=
+	u8 unused0[0x100 - 0x10];=0A=
+=0A=
+	u64 sw_reset;=0A=
+/* XGXS must be removed from reset only once. */=0A=
+#define SW_RESET_XENA              vBIT(0xA5,0,8)=0A=
+#define SW_RESET_FLASH             vBIT(0xA5,8,8)=0A=
+#define SW_RESET_EOI               vBIT(0xA5,16,8)=0A=
+#define SW_RESET_ALL               (SW_RESET_XENA     |   \=0A=
+                                    SW_RESET_FLASH    |   \=0A=
+                                    SW_RESET_EOI)=0A=
+/* The SW_RESET register must read this value after a successful reset. =
*/=0A=
+#define	SW_RESET_RAW_VAL			0xA5000000=0A=
+=0A=
+=0A=
+	u64 adapter_status;=0A=
+#define ADAPTER_STATUS_TDMA_READY          BIT(0)=0A=
+#define ADAPTER_STATUS_RDMA_READY          BIT(1)=0A=
+#define ADAPTER_STATUS_PFC_READY           BIT(2)=0A=
+#define ADAPTER_STATUS_TMAC_BUF_EMPTY      BIT(3)=0A=
+#define ADAPTER_STATUS_PIC_QUIESCENT       BIT(5)=0A=
+#define ADAPTER_STATUS_RMAC_REMOTE_FAULT   BIT(6)=0A=
+#define ADAPTER_STATUS_RMAC_LOCAL_FAULT    BIT(7)=0A=
+#define ADAPTER_STATUS_RMAC_PCC_IDLE       vBIT(0xFF,8,8)=0A=
+#define ADAPTER_STATUS_RC_PRC_QUIESCENT    vBIT(0xFF,16,8)=0A=
+#define ADAPTER_STATUS_MC_DRAM_READY       BIT(24)=0A=
+#define ADAPTER_STATUS_MC_QUEUES_READY     BIT(25)=0A=
+#define ADAPTER_STATUS_M_PLL_LOCK          BIT(30)=0A=
+#define ADAPTER_STATUS_P_PLL_LOCK          BIT(31)=0A=
+=0A=
+	u64 adapter_control;=0A=
+#define ADAPTER_CNTL_EN                    BIT(7)=0A=
+#define ADAPTER_EOI_TX_ON                  BIT(15)=0A=
+#define ADAPTER_LED_ON                     BIT(23)=0A=
+#define ADAPTER_UDPI(val)                  vBIT(val,36,4)=0A=
+#define ADAPTER_WAIT_INT                   BIT(48)=0A=
+#define ADAPTER_ECC_EN                     BIT(55)=0A=
+=0A=
+	u64 serr_source;=0A=
+#define SERR_SOURCE_PIC					BIT(0)=0A=
+#define SERR_SOURCE_TXDMA				BIT(1)=0A=
+#define SERR_SOURCE_RXDMA				BIT(2)=0A=
+#define SERR_SOURCE_MAC                 BIT(3)=0A=
+#define SERR_SOURCE_MC                  BIT(4)=0A=
+#define SERR_SOURCE_XGXS                BIT(5)=0A=
+#define	SERR_SOURCE_ANY					(SERR_SOURCE_PIC		| \=0A=
+										SERR_SOURCE_TXDMA	| \=0A=
+										SERR_SOURCE_RXDMA	| \=0A=
+										SERR_SOURCE_MAC		| \=0A=
+										SERR_SOURCE_MC      | \=0A=
+										SERR_SOURCE_XGXS)=0A=
+=0A=
+=0A=
+	u8 unused_0[0x800 - 0x120];=0A=
+=0A=
+/* PCI-X Controller registers */=0A=
+	u64 pic_int_status;=0A=
+	u64 pic_int_mask;=0A=
+#define PIC_INT_TX                     BIT(0)=0A=
+#define PIC_INT_FLSH                   BIT(1)=0A=
+#define PIC_INT_MDIO                   BIT(2)=0A=
+#define PIC_INT_IIC                    BIT(3)=0A=
+#define PIC_INT_GPIO                   BIT(4)=0A=
+#define PIC_INT_RX                     BIT(32)=0A=
+=0A=
+	u64 txpic_int_reg;=0A=
+	u64 txpic_int_mask;=0A=
+#define PCIX_INT_REG_ECC_SG_ERR                BIT(0)=0A=
+#define PCIX_INT_REG_ECC_DB_ERR                BIT(1)=0A=
+#define PCIX_INT_REG_FLASHR_R_FSM_ERR          BIT(8)=0A=
+#define PCIX_INT_REG_FLASHR_W_FSM_ERR          BIT(9)=0A=
+#define PCIX_INT_REG_INI_TX_FSM_SERR           BIT(10)=0A=
+#define PCIX_INT_REG_INI_TXO_FSM_ERR           BIT(11)=0A=
+#define PCIX_INT_REG_TRT_FSM_SERR              BIT(13)=0A=
+#define PCIX_INT_REG_SRT_FSM_SERR              BIT(14)=0A=
+#define PCIX_INT_REG_PIFR_FSM_SERR             BIT(15)=0A=
+#define PCIX_INT_REG_WRC_TX_SEND_FSM_SERR      BIT(21)=0A=
+#define PCIX_INT_REG_RRC_TX_REQ_FSM_SERR       BIT(23)=0A=
+#define PCIX_INT_REG_INI_RX_FSM_SERR           BIT(48)=0A=
+#define PCIX_INT_REG_RA_RX_FSM_SERR            BIT(50)=0A=
+/*=0A=
+#define PCIX_INT_REG_WRC_RX_SEND_FSM_SERR      BIT(52)=0A=
+#define PCIX_INT_REG_RRC_RX_REQ_FSM_SERR       BIT(54)=0A=
+#define PCIX_INT_REG_RRC_RX_SPLIT_FSM_SERR     BIT(58)=0A=
+*/=0A=
+	u64 txpic_alarms;=0A=
+	u64 rxpic_int_reg;=0A=
+	u64 rxpic_int_mask;=0A=
+	u64 rxpic_alarms;=0A=
+=0A=
+	u64 flsh_int_reg;=0A=
+	u64 flsh_int_mask;=0A=
+#define PIC_FLSH_INT_REG_CYCLE_FSM_ERR         BIT(63)=0A=
+#define PIC_FLSH_INT_REG_ERR                   BIT(62)=0A=
+	u64 flash_alarms;=0A=
+=0A=
+	u64 mdio_int_reg;=0A=
+	u64 mdio_int_mask;=0A=
+#define MDIO_INT_REG_MDIO_BUS_ERR              BIT(0)=0A=
+#define MDIO_INT_REG_DTX_BUS_ERR               BIT(8)=0A=
+#define MDIO_INT_REG_LASI                      BIT(39)=0A=
+	u64 mdio_alarms;=0A=
+=0A=
+	u64 iic_int_reg;=0A=
+	u64 iic_int_mask;=0A=
+#define IIC_INT_REG_BUS_FSM_ERR                BIT(4)=0A=
+#define IIC_INT_REG_BIT_FSM_ERR                BIT(5)=0A=
+#define IIC_INT_REG_CYCLE_FSM_ERR              BIT(6)=0A=
+#define IIC_INT_REG_REQ_FSM_ERR                BIT(7)=0A=
+#define IIC_INT_REG_ACK_ERR                    BIT(8)=0A=
+	u64 iic_alarms;=0A=
+=0A=
+	u8 unused4[0x08];=0A=
+=0A=
+	u64 gpio_int_reg;=0A=
+	u64 gpio_int_mask;=0A=
+	u64 gpio_alarms;=0A=
+=0A=
+	u8 unused5[0x38];=0A=
+=0A=
+	u64 tx_traffic_int;=0A=
+#define TX_TRAFFIC_INT_n(n)                    BIT(n)=0A=
+	u64 tx_traffic_mask;=0A=
+=0A=
+	u64 rx_traffic_int;=0A=
+#define RX_TRAFFIC_INT_n(n)                    BIT(n)=0A=
+	u64 rx_traffic_mask;=0A=
+=0A=
+/* PIC Control registers */=0A=
+	u64 pic_control;=0A=
+#define PIC_CNTL_RX_ALARM_MAP_1                BIT(0)=0A=
+#define PIC_CNTL_SHARED_SPLITS(n)              vBIT(n,11,4)=0A=
+=0A=
+	u64 swapper_ctrl;=0A=
+#define SWAPPER_CTRL_PIF_R_FE                  BIT(0)=0A=
+#define SWAPPER_CTRL_PIF_R_SE                  BIT(1)=0A=
+#define SWAPPER_CTRL_PIF_W_FE                  BIT(8)=0A=
+#define SWAPPER_CTRL_PIF_W_SE                  BIT(9)=0A=
+#define SWAPPER_CTRL_TXP_FE                    BIT(16)=0A=
+#define SWAPPER_CTRL_TXP_SE                    BIT(17)=0A=
+#define SWAPPER_CTRL_TXD_R_FE                  BIT(18)=0A=
+#define SWAPPER_CTRL_TXD_R_SE                  BIT(19)=0A=
+#define SWAPPER_CTRL_TXD_W_FE                  BIT(20)=0A=
+#define SWAPPER_CTRL_TXD_W_SE                  BIT(21)=0A=
+#define SWAPPER_CTRL_TXF_R_FE                  BIT(22)=0A=
+#define SWAPPER_CTRL_TXF_R_SE                  BIT(23)=0A=
+#define SWAPPER_CTRL_RXD_R_FE                  BIT(32)=0A=
+#define SWAPPER_CTRL_RXD_R_SE                  BIT(33)=0A=
+#define SWAPPER_CTRL_RXD_W_FE                  BIT(34)=0A=
+#define SWAPPER_CTRL_RXD_W_SE                  BIT(35)=0A=
+#define SWAPPER_CTRL_RXF_W_FE                  BIT(36)=0A=
+#define SWAPPER_CTRL_RXF_W_SE                  BIT(37)=0A=
+#define SWAPPER_CTRL_XMSI_FE                   BIT(40)=0A=
+#define SWAPPER_CTRL_XMSI_SE                   BIT(41)=0A=
+#define SWAPPER_CTRL_STATS_FE                  BIT(48)=0A=
+#define SWAPPER_CTRL_STATS_SE                  BIT(49)=0A=
+=0A=
+	u64 pif_rd_swapper_fb;=0A=
+#define IF_RD_SWAPPER_FB                            0x0123456789ABCDEF=0A=
+=0A=
+	u64 scheduled_int_ctrl;=0A=
+#define SCHED_INT_CTRL_TIMER_EN                BIT(0)=0A=
+#define SCHED_INT_CTRL_ONE_SHOT                BIT(1)=0A=
+#define SCHED_INT_CTRL_INT2MSI                 TBD=0A=
+#define SCHED_INT_PERIOD                       TBD=0A=
+=0A=
+	u64 txreqtimeout;=0A=
+#define TXREQTO_VAL(val)						vBIT(val,0,32)=0A=
+#define TXREQTO_EN								BIT(63)=0A=
+=0A=
+	u64 statsreqtimeout;=0A=
+#define STATREQTO_VAL(n)                       TBD=0A=
+#define STATREQTO_EN                           BIT(63)=0A=
+=0A=
+	u64 read_retry_delay;=0A=
+	u64 read_retry_acceleration;=0A=
+	u64 write_retry_delay;=0A=
+	u64 write_retry_acceleration;=0A=
+=0A=
+	u64 xmsi_control;=0A=
+	u64 xmsi_access;=0A=
+	u64 xmsi_address;=0A=
+	u64 xmsi_data;=0A=
+=0A=
+	u64 rx_mat;=0A=
+=0A=
+	u8 unused6[0x8];=0A=
+=0A=
+	u64 tx_mat0_7;=0A=
+	u64 tx_mat8_15;=0A=
+	u64 tx_mat16_23;=0A=
+	u64 tx_mat24_31;=0A=
+	u64 tx_mat32_39;=0A=
+	u64 tx_mat40_47;=0A=
+	u64 tx_mat48_55;=0A=
+	u64 tx_mat56_63;=0A=
+=0A=
+	u8 unused_1[0x10];=0A=
+=0A=
+	/* Automated statistics collection */=0A=
+	u64 stat_cfg;=0A=
+#define STAT_CFG_STAT_EN           BIT(0)=0A=
+#define STAT_CFG_ONE_SHOT_EN       BIT(1)=0A=
+#define STAT_CFG_STAT_NS_EN        BIT(8)=0A=
+#define STAT_CFG_STAT_RO           BIT(9)=0A=
+#define STAT_TRSF_PER(n)           TBD=0A=
+#define	PER_SEC					   0x208d5=0A=
+#define	SET_UPDT_PERIOD(n)		   vBIT((PER_SEC*n),32,32)=0A=
+=0A=
+	u64 stat_addr;=0A=
+=0A=
+	/* General Configuration */=0A=
+	u64 mdio_control;=0A=
+=0A=
+	u64 dtx_control;=0A=
+=0A=
+	u64 i2c_control;=0A=
+#define	I2C_CONTROL_DEV_ID(id)		vBIT(id,1,3)=0A=
+#define	I2C_CONTROL_ADDR(addr)		vBIT(addr,5,11)=0A=
+#define	I2C_CONTROL_BYTE_CNT(cnt)	vBIT(cnt,22,2)=0A=
+#define	I2C_CONTROL_READ			BIT(24)=0A=
+#define	I2C_CONTROL_NACK			BIT(25)=0A=
+#define	I2C_CONTROL_CNTL_START		vBIT(0xE,28,4)=0A=
+#define	I2C_CONTROL_CNTL_END(val)	(val & vBIT(0x1,28,4))=0A=
+#define	I2C_CONTROL_GET_DATA(val)	(u32)(val & 0xFFFFFFFF)=0A=
+#define	I2C_CONTROL_SET_DATA(val)	vBIT(val,32,32)=0A=
+=0A=
+	u64 gpio_control;=0A=
+#define GPIO_CTRL_GPIO_0		BIT(8)=0A=
+=0A=
+	u8 unused7[0x600];=0A=
+=0A=
+/* TxDMA registers */=0A=
+	u64 txdma_int_status;=0A=
+	u64 txdma_int_mask;=0A=
+#define TXDMA_PFC_INT                  BIT(0)=0A=
+#define TXDMA_TDA_INT                  BIT(1)=0A=
+#define TXDMA_PCC_INT                  BIT(2)=0A=
+#define TXDMA_TTI_INT                  BIT(3)=0A=
+#define TXDMA_LSO_INT                  BIT(4)=0A=
+#define TXDMA_TPA_INT                  BIT(5)=0A=
+#define TXDMA_SM_INT                   BIT(6)=0A=
+	u64 pfc_err_reg;=0A=
+	u64 pfc_err_mask;=0A=
+	u64 pfc_err_alarm;=0A=
+=0A=
+	u64 tda_err_reg;=0A=
+	u64 tda_err_mask;=0A=
+	u64 tda_err_alarm;=0A=
+=0A=
+	u64 pcc_err_reg;=0A=
+	u64 pcc_err_mask;=0A=
+	u64 pcc_err_alarm;=0A=
+=0A=
+	u64 tti_err_reg;=0A=
+	u64 tti_err_mask;=0A=
+	u64 tti_err_alarm;=0A=
+=0A=
+	u64 lso_err_reg;=0A=
+	u64 lso_err_mask;=0A=
+	u64 lso_err_alarm;=0A=
+=0A=
+	u64 tpa_err_reg;=0A=
+	u64 tpa_err_mask;=0A=
+	u64 tpa_err_alarm;=0A=
+=0A=
+	u64 sm_err_reg;=0A=
+	u64 sm_err_mask;=0A=
+	u64 sm_err_alarm;=0A=
+=0A=
+	u8 unused8[0x100 - 0xB8];=0A=
+=0A=
+/* TxDMA arbiter */=0A=
+	u64 tx_dma_wrap_stat;=0A=
+=0A=
+/* Tx FIFO controller */=0A=
+#define X_MAX_FIFOS                        8=0A=
+#define X_FIFO_MAX_LEN                     0x1FFF	/*8191 */=0A=
+	u64 tx_fifo_partition_0;=0A=
+#define TX_FIFO_PARTITION_EN               BIT(0)=0A=
+#define TX_FIFO_PARTITION_0_PRI(val)       vBIT(val,5,3)=0A=
+#define TX_FIFO_PARTITION_0_LEN(val)       vBIT(val,19,13)=0A=
+#define TX_FIFO_PARTITION_1_PRI(val)       vBIT(val,37,3)=0A=
+#define TX_FIFO_PARTITION_1_LEN(val)       vBIT(val,51,13  )=0A=
+=0A=
+	u64 tx_fifo_partition_1;=0A=
+#define TX_FIFO_PARTITION_2_PRI(val)       vBIT(val,5,3)=0A=
+#define TX_FIFO_PARTITION_2_LEN(val)       vBIT(val,19,13)=0A=
+#define TX_FIFO_PARTITION_3_PRI(val)       vBIT(val,37,3)=0A=
+#define TX_FIFO_PARTITION_3_LEN(val)       vBIT(val,51,13)=0A=
+=0A=
+	u64 tx_fifo_partition_2;=0A=
+#define TX_FIFO_PARTITION_4_PRI(val)       vBIT(val,5,3)=0A=
+#define TX_FIFO_PARTITION_4_LEN(val)       vBIT(val,19,13)=0A=
+#define TX_FIFO_PARTITION_5_PRI(val)       vBIT(val,37,3)=0A=
+#define TX_FIFO_PARTITION_5_LEN(val)       vBIT(val,51,13)=0A=
+=0A=
+	u64 tx_fifo_partition_3;=0A=
+#define TX_FIFO_PARTITION_6_PRI(val)       vBIT(val,5,3)=0A=
+#define TX_FIFO_PARTITION_6_LEN(val)       vBIT(val,19,13)=0A=
+#define TX_FIFO_PARTITION_7_PRI(val)       vBIT(val,37,3)=0A=
+#define TX_FIFO_PARTITION_7_LEN(val)       vBIT(val,51,13)=0A=
+=0A=
+#define TX_FIFO_PARTITION_PRI_0                 0	/* highest */=0A=
+#define TX_FIFO_PARTITION_PRI_1                 1=0A=
+#define TX_FIFO_PARTITION_PRI_2                 2=0A=
+#define TX_FIFO_PARTITION_PRI_3                 3=0A=
+#define TX_FIFO_PARTITION_PRI_4                 4=0A=
+#define TX_FIFO_PARTITION_PRI_5                 5=0A=
+#define TX_FIFO_PARTITION_PRI_6                 6=0A=
+#define TX_FIFO_PARTITION_PRI_7                 7	/* lowest */=0A=
+=0A=
+	u64 tx_w_round_robin_0;=0A=
+	u64 tx_w_round_robin_1;=0A=
+	u64 tx_w_round_robin_2;=0A=
+	u64 tx_w_round_robin_3;=0A=
+	u64 tx_w_round_robin_4;=0A=
+=0A=
+	u64 tti_command_mem;=0A=
+#define TTI_CMD_MEM_WE                     BIT(7)=0A=
+#define TTI_CMD_MEM_STROBE_NEW_CMD         BIT(15)=0A=
+#define TTI_CMD_MEM_STROBE_BEING_EXECUTED  BIT(15)=0A=
+#define TTI_CMD_MEM_OFFSET(n)              vBIT(n,26,6)=0A=
+=0A=
+	u64 tti_data1_mem;=0A=
+#define TTI_DATA1_MEM_TX_TIMER_VAL(n)      vBIT(n,6,26)=0A=
+#define TTI_DATA1_MEM_TX_TIMER_AC_CI(n)    vBIT(n,38,2)=0A=
+#define TTI_DATA1_MEM_TX_TIMER_AC_EN       BIT(38)=0A=
+#define TTI_DATA1_MEM_TX_TIMER_CI_EN       BIT(39)=0A=
+#define TTI_DATA1_MEM_TX_URNG_A(n)         vBIT(n,41,7)=0A=
+#define TTI_DATA1_MEM_TX_URNG_B(n)         vBIT(n,49,7)=0A=
+#define TTI_DATA1_MEM_TX_URNG_C(n)         vBIT(n,57,7)=0A=
+=0A=
+	u64 tti_data2_mem;=0A=
+#define TTI_DATA2_MEM_TX_UFC_A(n)          vBIT(n,0,16)=0A=
+#define TTI_DATA2_MEM_TX_UFC_B(n)          vBIT(n,16,16)=0A=
+#define TTI_DATA2_MEM_TX_UFC_C(n)          vBIT(n,32,16)=0A=
+#define TTI_DATA2_MEM_TX_UFC_D(n)          vBIT(n,48,16)=0A=
+=0A=
+/* Tx Protocol assist */=0A=
+	u64 tx_pa_cfg;=0A=
+#define TX_PA_CFG_IGNORE_FRM_ERR           BIT(1)=0A=
+#define TX_PA_CFG_IGNORE_SNAP_OUI          BIT(2)=0A=
+#define TX_PA_CFG_IGNORE_LLC_CTRL          BIT(3)=0A=
+#define	TX_PA_CFG_IGNORE_L2_ERR			   BIT(6)=0A=
+=0A=
+/* Recent add, used only debug purposes. */=0A=
+	u64 pcc_enable;=0A=
+=0A=
+	u8 unused9[0x700 - 0x178];=0A=
+=0A=
+	u64 txdma_debug_ctrl;=0A=
+=0A=
+	u8 unused10[0x1800 - 0x1708];=0A=
+=0A=
+/* RxDMA Registers */=0A=
+	u64 rxdma_int_status;=0A=
+	u64 rxdma_int_mask;=0A=
+#define RXDMA_INT_RC_INT_M             BIT(0)=0A=
+#define RXDMA_INT_RPA_INT_M            BIT(1)=0A=
+#define RXDMA_INT_RDA_INT_M            BIT(2)=0A=
+#define RXDMA_INT_RTI_INT_M            BIT(3)=0A=
+=0A=
+	u64 rda_err_reg;=0A=
+	u64 rda_err_mask;=0A=
+	u64 rda_err_alarm;=0A=
+=0A=
+	u64 rc_err_reg;=0A=
+	u64 rc_err_mask;=0A=
+	u64 rc_err_alarm;=0A=
+=0A=
+	u64 prc_pcix_err_reg;=0A=
+	u64 prc_pcix_err_mask;=0A=
+	u64 prc_pcix_err_alarm;=0A=
+=0A=
+	u64 rpa_err_reg;=0A=
+	u64 rpa_err_mask;=0A=
+	u64 rpa_err_alarm;=0A=
+=0A=
+	u64 rti_err_reg;=0A=
+	u64 rti_err_mask;=0A=
+	u64 rti_err_alarm;=0A=
+=0A=
+	u8 unused11[0x100 - 0x88];=0A=
+=0A=
+/* DMA arbiter */=0A=
+	u64 rx_queue_priority;=0A=
+#define RX_QUEUE_0_PRIORITY(val)       vBIT(val,5,3)=0A=
+#define RX_QUEUE_1_PRIORITY(val)       vBIT(val,13,3)=0A=
+#define RX_QUEUE_2_PRIORITY(val)       vBIT(val,21,3)=0A=
+#define RX_QUEUE_3_PRIORITY(val)       vBIT(val,29,3)=0A=
+#define RX_QUEUE_4_PRIORITY(val)       vBIT(val,37,3)=0A=
+#define RX_QUEUE_5_PRIORITY(val)       vBIT(val,45,3)=0A=
+#define RX_QUEUE_6_PRIORITY(val)       vBIT(val,53,3)=0A=
+#define RX_QUEUE_7_PRIORITY(val)       vBIT(val,61,3)=0A=
+=0A=
+#define RX_QUEUE_PRI_0                 0	/* highest */=0A=
+#define RX_QUEUE_PRI_1                 1=0A=
+#define RX_QUEUE_PRI_2                 2=0A=
+#define RX_QUEUE_PRI_3                 3=0A=
+#define RX_QUEUE_PRI_4                 4=0A=
+#define RX_QUEUE_PRI_5                 5=0A=
+#define RX_QUEUE_PRI_6                 6=0A=
+#define RX_QUEUE_PRI_7                 7	/* lowest */=0A=
+=0A=
+	u64 rx_w_round_robin_0;=0A=
+	u64 rx_w_round_robin_1;=0A=
+	u64 rx_w_round_robin_2;=0A=
+	u64 rx_w_round_robin_3;=0A=
+	u64 rx_w_round_robin_4;=0A=
+=0A=
+	/* Per-ring controller regs */=0A=
+#define RX_MAX_RINGS                8=0A=
+#if 0=0A=
+#define RX_MAX_RINGS_SZ             0xFFFF	/* 65536 */=0A=
+#define RX_MIN_RINGS_SZ             0x3F	/* 63 */=0A=
+#endif=0A=
+	u64 prc_rxd0_n[RX_MAX_RINGS];=0A=
+	u64 prc_ctrl_n[RX_MAX_RINGS];=0A=
+#define PRC_CTRL_RC_ENABLED                    BIT(7)=0A=
+#define PRC_CTRL_RING_MODE                     (BIT(14)|BIT(15))=0A=
+#define PRC_CTRL_RING_MODE_1                   vBIT(0,14,2)=0A=
+#define PRC_CTRL_RING_MODE_3                   vBIT(1,14,2)=0A=
+#define PRC_CTRL_RING_MODE_5                   vBIT(2,14,2)=0A=
+#define PRC_CTRL_RING_MODE_x                   vBIT(3,14,2)=0A=
+#define PRC_CTRL_NO_SNOOP                      (BIT(22)|BIT(23))=0A=
+#define PRC_CTRL_NO_SNOOP_DESC                 BIT(22)=0A=
+#define PRC_CTRL_NO_SNOOP_BUFF                 BIT(23)=0A=
+#define PRC_CTRL_RXD_BACKOFF_INTERVAL(val)     vBIT(val,40,24)=0A=
+=0A=
+	u64 prc_alarm_action;=0A=
+#define PRC_ALARM_ACTION_RR_R0_STOP            BIT(3)=0A=
+#define PRC_ALARM_ACTION_RW_R0_STOP            BIT(7)=0A=
+#define PRC_ALARM_ACTION_RR_R1_STOP            BIT(11)=0A=
+#define PRC_ALARM_ACTION_RW_R1_STOP            BIT(15)=0A=
+#define PRC_ALARM_ACTION_RR_R2_STOP            BIT(19)=0A=
+#define PRC_ALARM_ACTION_RW_R2_STOP            BIT(23)=0A=
+#define PRC_ALARM_ACTION_RR_R3_STOP            BIT(27)=0A=
+#define PRC_ALARM_ACTION_RW_R3_STOP            BIT(31)=0A=
+#define PRC_ALARM_ACTION_RR_R4_STOP            BIT(35)=0A=
+#define PRC_ALARM_ACTION_RW_R4_STOP            BIT(39)=0A=
+#define PRC_ALARM_ACTION_RR_R5_STOP            BIT(43)=0A=
+#define PRC_ALARM_ACTION_RW_R5_STOP            BIT(47)=0A=
+#define PRC_ALARM_ACTION_RR_R6_STOP            BIT(51)=0A=
+#define PRC_ALARM_ACTION_RW_R6_STOP            BIT(55)=0A=
+#define PRC_ALARM_ACTION_RR_R7_STOP            BIT(59)=0A=
+#define PRC_ALARM_ACTION_RW_R7_STOP            BIT(63)=0A=
+=0A=
+/* Receive traffic interrupts */=0A=
+	u64 rti_command_mem;=0A=
+#define RTI_CMD_MEM_WE                          BIT(7)=0A=
+#define RTI_CMD_MEM_STROBE                      BIT(15)=0A=
+#define RTI_CMD_MEM_STROBE_NEW_CMD              BIT(15)=0A=
+#define RTI_CMD_MEM_STROBE_CMD_BEING_EXECUTED   BIT(15)=0A=
+#define RTI_CMD_MEM_OFFSET(n)                   vBIT(n,29,3)=0A=
+=0A=
+	u64 rti_data1_mem;=0A=
+#define RTI_DATA1_MEM_RX_TIMER_VAL(n)      vBIT(n,3,29)=0A=
+#define RTI_DATA1_MEM_RX_TIMER_AC_EN       BIT(38)=0A=
+#define RTI_DATA1_MEM_RX_TIMER_CI_EN       BIT(39)=0A=
+#define RTI_DATA1_MEM_RX_URNG_A(n)         vBIT(n,41,7)=0A=
+#define RTI_DATA1_MEM_RX_URNG_B(n)         vBIT(n,49,7)=0A=
+#define RTI_DATA1_MEM_RX_URNG_C(n)         vBIT(n,57,7)=0A=
+=0A=
+	u64 rti_data2_mem;=0A=
+#define RTI_DATA2_MEM_RX_UFC_A(n)          vBIT(n,0,16)=0A=
+#define RTI_DATA2_MEM_RX_UFC_B(n)          vBIT(n,16,16)=0A=
+#define RTI_DATA2_MEM_RX_UFC_C(n)          vBIT(n,32,16)=0A=
+#define RTI_DATA2_MEM_RX_UFC_D(n)          vBIT(n,48,16)=0A=
+=0A=
+	u64 rx_pa_cfg;=0A=
+#define RX_PA_CFG_IGNORE_FRM_ERR           BIT(1)=0A=
+#define RX_PA_CFG_IGNORE_SNAP_OUI          BIT(2)=0A=
+#define RX_PA_CFG_IGNORE_LLC_CTRL          BIT(3)=0A=
+=0A=
+	u8 unused12[0x700 - 0x1D8];=0A=
+=0A=
+	u64 rxdma_debug_ctrl;=0A=
+=0A=
+	u8 unused13[0x2000 - 0x1f08];=0A=
+=0A=
+/* Media Access Controller Register */=0A=
+	u64 mac_int_status;=0A=
+	u64 mac_int_mask;=0A=
+#define MAC_INT_STATUS_TMAC_INT            BIT(0)=0A=
+#define MAC_INT_STATUS_RMAC_INT            BIT(1)=0A=
+=0A=
+	u64 mac_tmac_err_reg;=0A=
+#define TMAC_ERR_REG_TMAC_ECC_DB_ERR       BIT(15)=0A=
+#define TMAC_ERR_REG_TMAC_TX_BUF_OVRN      BIT(23)=0A=
+#define TMAC_ERR_REG_TMAC_TX_CRI_ERR       BIT(31)=0A=
+	u64 mac_tmac_err_mask;=0A=
+	u64 mac_tmac_err_alarm;=0A=
+=0A=
+	u64 mac_rmac_err_reg;=0A=
+#define RMAC_ERR_REG_RX_BUFF_OVRN          BIT(0)=0A=
+#define RMAC_ERR_REG_RTS_ECC_DB_ERR        BIT(14)=0A=
+#define RMAC_ERR_REG_ECC_DB_ERR            BIT(15)=0A=
+#define RMAC_LINK_STATE_CHANGE_INT         BIT(31)=0A=
+	u64 mac_rmac_err_mask;=0A=
+	u64 mac_rmac_err_alarm;=0A=
+=0A=
+	u8 unused14[0x100 - 0x40];=0A=
+=0A=
+	u64 mac_cfg;=0A=
+#define MAC_CFG_TMAC_ENABLE             BIT(0)=0A=
+#define MAC_CFG_RMAC_ENABLE             BIT(1)=0A=
+#define MAC_CFG_LAN_NOT_WAN             BIT(2)=0A=
+#define MAC_CFG_TMAC_LOOPBACK           BIT(3)=0A=
+#define MAC_CFG_TMAC_APPEND_PAD         BIT(4)=0A=
+#define MAC_CFG_RMAC_STRIP_FCS          BIT(5)=0A=
+#define MAC_CFG_RMAC_STRIP_PAD          BIT(6)=0A=
+#define MAC_CFG_RMAC_PROM_ENABLE        BIT(7)=0A=
+#define MAC_RMAC_DISCARD_PFRM           BIT(8)=0A=
+#define MAC_RMAC_BCAST_ENABLE           BIT(9)=0A=
+#define MAC_RMAC_ALL_ADDR_ENABLE        BIT(10)=0A=
+#define MAC_RMAC_INVLD_IPG_THR(val)     vBIT(val,16,8)=0A=
+=0A=
+	u64 tmac_avg_ipg;=0A=
+#define TMAC_AVG_IPG(val)           vBIT(val,0,8)=0A=
+=0A=
+	u64 rmac_max_pyld_len;=0A=
+#define RMAC_MAX_PYLD_LEN(val)      vBIT(val,2,14)=0A=
+#define RMAC_MAX_PYLD_LEN_DEF       vBIT(1500,2,14)=0A=
+#define RMAC_MAX_PYLD_LEN_JUMBO_DEF vBIT(9600,2,14)=0A=
+=0A=
+	u64 rmac_err_cfg;=0A=
+#define RMAC_ERR_FCS                    BIT(0)=0A=
+#define RMAC_ERR_FCS_ACCEPT             BIT(1)=0A=
+#define RMAC_ERR_TOO_LONG               BIT(1)=0A=
+#define RMAC_ERR_TOO_LONG_ACCEPT        BIT(1)=0A=
+#define RMAC_ERR_RUNT                   BIT(2)=0A=
+#define RMAC_ERR_RUNT_ACCEPT            BIT(2)=0A=
+#define RMAC_ERR_LEN_MISMATCH           BIT(3)=0A=
+#define RMAC_ERR_LEN_MISMATCH_ACCEPT    BIT(3)=0A=
+=0A=
+	u64 rmac_cfg_key;=0A=
+#define RMAC_CFG_KEY(val)               vBIT(val,0,16)=0A=
+=0A=
+#define MAX_MAC_ADDRESSES           16=0A=
+#define MAX_MC_ADDRESSES            32	/* Multicast addresses */=0A=
+#define MAC_MAC_ADDR_START_OFFSET   0=0A=
+#define MAC_MC_ADDR_START_OFFSET    16=0A=
+#define MAC_MC_ALL_MC_ADDR_OFFSET   63	/* enables all multicast pkts */=0A=
+	u64 rmac_addr_cmd_mem;=0A=
+#define RMAC_ADDR_CMD_MEM_WE                    BIT(7)=0A=
+#define RMAC_ADDR_CMD_MEM_RD                    0=0A=
+#define RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD        BIT(15)=0A=
+#define RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING  BIT(15)=0A=
+#define RMAC_ADDR_CMD_MEM_OFFSET(n)             vBIT(n,26,6)=0A=
+=0A=
+	u64 rmac_addr_data0_mem;=0A=
+#define RMAC_ADDR_DATA0_MEM_ADDR(n)    vBIT(n,0,48)=0A=
+#define RMAC_ADDR_DATA0_MEM_USER       BIT(48)=0A=
+=0A=
+	u64 rmac_addr_data1_mem;=0A=
+#define RMAC_ADDR_DATA1_MEM_MASK(n)    vBIT(n,0,48)=0A=
+=0A=
+	u8 unused15[0x8];=0A=
+=0A=
+/*=0A=
+        u64 rmac_addr_cfg;=0A=
+#define RMAC_ADDR_UCASTn_EN(n)     mBIT(0)_n(n)=0A=
+#define RMAC_ADDR_MCASTn_EN(n)     mBIT(0)_n(n)=0A=
+#define RMAC_ADDR_BCAST_EN         vBIT(0)_48 =0A=
+#define RMAC_ADDR_ALL_ADDR_EN      vBIT(0)_49 =0A=
+*/=0A=
+	u64 tmac_ipg_cfg;=0A=
+=0A=
+	u64 rmac_pause_cfg;=0A=
+#define RMAC_PAUSE_GEN             BIT(0)=0A=
+#define RMAC_PAUSE_GEN_ENABLE      BIT(0)=0A=
+#define RMAC_PAUSE_RX              BIT(1)=0A=
+#define RMAC_PAUSE_RX_ENABLE       BIT(1)=0A=
+#define RMAC_PAUSE_HG_PTIME_DEF    vBIT(0xFFFF,16,16)=0A=
+#define RMAC_PAUSE_HG_PTIME(val)    vBIT(val,16,16)=0A=
+=0A=
+	u64 rmac_red_cfg;=0A=
+=0A=
+	u64 rmac_red_rate_q0q3;=0A=
+	u64 rmac_red_rate_q4q7;=0A=
+=0A=
+	u64 mac_link_util;=0A=
+#define MAC_TX_LINK_UTIL           vBIT(0xFE,1,7)=0A=
+#define MAC_TX_LINK_UTIL_DISABLE   vBIT(0xF, 8,4)=0A=
+#define MAC_TX_LINK_UTIL_VAL( n )  vBIT(n,8,4)=0A=
+#define MAC_RX_LINK_UTIL           vBIT(0xFE,33,7)=0A=
+#define MAC_RX_LINK_UTIL_DISABLE   vBIT(0xF,40,4)=0A=
+#define MAC_RX_LINK_UTIL_VAL( n )  vBIT(n,40,4)=0A=
+=0A=
+#define MAC_LINK_UTIL_DISABLE      MAC_TX_LINK_UTIL_DISABLE | \=0A=
+                                   MAC_RX_LINK_UTIL_DISABLE=0A=
+=0A=
+	u64 rmac_invalid_ipg;=0A=
+=0A=
+/* rx traffic steering */=0A=
+#define	MAC_RTS_FRM_LEN_SET(len)	vBIT(len,2,14)=0A=
+	u64 rts_frm_len_n[8];=0A=
+=0A=
+	u64 rts_qos_steering;=0A=
+=0A=
+#define MAX_DIX_MAP                         4=0A=
+	u64 rts_dix_map_n[MAX_DIX_MAP];=0A=
+#define RTS_DIX_MAP_ETYPE(val)             vBIT(val,0,16)=0A=
+#define RTS_DIX_MAP_SCW(val)               BIT(val,21)=0A=
+=0A=
+	u64 rts_q_alternates;=0A=
+	u64 rts_default_q;=0A=
+=0A=
+	u64 rts_ctrl;=0A=
+#define RTS_CTRL_IGNORE_SNAP_OUI           BIT(2)=0A=
+#define RTS_CTRL_IGNORE_LLC_CTRL           BIT(3)=0A=
+=0A=
+	u64 rts_pn_cam_ctrl;=0A=
+#define RTS_PN_CAM_CTRL_WE                 BIT(7)=0A=
+#define RTS_PN_CAM_CTRL_STROBE_NEW_CMD     BIT(15)=0A=
+#define RTS_PN_CAM_CTRL_STROBE_BEING_EXECUTED   BIT(15)=0A=
+#define RTS_PN_CAM_CTRL_OFFSET(n)          vBIT(n,24,8)=0A=
+	u64 rts_pn_cam_data;=0A=
+#define RTS_PN_CAM_DATA_TCP_SELECT         BIT(7)=0A=
+#define RTS_PN_CAM_DATA_PORT(val)          vBIT(val,8,16)=0A=
+#define RTS_PN_CAM_DATA_SCW(val)           vBIT(val,24,8)=0A=
+=0A=
+	u64 rts_ds_mem_ctrl;=0A=
+#define RTS_DS_MEM_CTRL_WE                 BIT(7)=0A=
+#define RTS_DS_MEM_CTRL_STROBE_NEW_CMD     BIT(15)=0A=
+#define RTS_DS_MEM_CTRL_STROBE_CMD_BEING_EXECUTED   BIT(15)=0A=
+#define RTS_DS_MEM_CTRL_OFFSET(n)          vBIT(n,26,6)=0A=
+	u64 rts_ds_mem_data;=0A=
+#define RTS_DS_MEM_DATA(n)                 vBIT(n,0,8)=0A=
+=0A=
+	u8 unused16[0x700 - 0x220];=0A=
+=0A=
+	u64 mac_debug_ctrl;=0A=
+#define MAC_DBG_ACTIVITY_VALUE		   0x411040400000000ULL=0A=
+=0A=
+	u8 unused17[0x2800 - 0x2708];=0A=
+=0A=
+/* memory controller registers */=0A=
+	u64 mc_int_status;=0A=
+#define MC_INT_STATUS_MC_INT               BIT(0)=0A=
+	u64 mc_int_mask;=0A=
+#define MC_INT_MASK_MC_INT                 BIT(0)=0A=
+=0A=
+	u64 mc_err_reg;=0A=
+#define MC_ERR_REG_ECC_DB_ERR_L            BIT(14)=0A=
+#define MC_ERR_REG_ECC_DB_ERR_U            BIT(15)=0A=
+#define MC_ERR_REG_MIRI_CRI_ERR_0          BIT(22)=0A=
+#define MC_ERR_REG_MIRI_CRI_ERR_1          BIT(23)=0A=
+#define MC_ERR_REG_SM_ERR                  BIT(31)=0A=
+	u64 mc_err_mask;=0A=
+	u64 mc_err_alarm;=0A=
+=0A=
+	u8 unused18[0x100 - 0x28];=0A=
+=0A=
+/* MC configuration */=0A=
+	u64 rx_queue_cfg;=0A=
+#define RX_QUEUE_CFG_Q0_SZ(n)              vBIT(n,0,8)=0A=
+#define RX_QUEUE_CFG_Q1_SZ(n)              vBIT(n,8,8)=0A=
+#define RX_QUEUE_CFG_Q2_SZ(n)              vBIT(n,16,8)=0A=
+#define RX_QUEUE_CFG_Q3_SZ(n)              vBIT(n,24,8)=0A=
+#define RX_QUEUE_CFG_Q4_SZ(n)              vBIT(n,32,8)=0A=
+#define RX_QUEUE_CFG_Q5_SZ(n)              vBIT(n,40,8)=0A=
+#define RX_QUEUE_CFG_Q6_SZ(n)              vBIT(n,48,8)=0A=
+#define RX_QUEUE_CFG_Q7_SZ(n)              vBIT(n,56,8)=0A=
+=0A=
+	u64 mc_rldram_mrs;=0A=
+#define	MC_RLDRAM_QUEUE_SIZE_ENABLE			BIT(39)=0A=
+#define	MC_RLDRAM_MRS_ENABLE				BIT(47)=0A=
+=0A=
+	u64 mc_rldram_interleave;=0A=
+=0A=
+	u64 mc_pause_thresh_q0q3;=0A=
+	u64 mc_pause_thresh_q4q7;=0A=
+=0A=
+	u64 mc_red_thresh_q[8];=0A=
+=0A=
+	u8 unused19[0x200 - 0x168];=0A=
+	u64 mc_rldram_ref_per;=0A=
+	u8 unused20[0x220 - 0x208];=0A=
+	u64 mc_rldram_test_ctrl;=0A=
+#define MC_RLDRAM_TEST_MODE		BIT(47)=0A=
+#define MC_RLDRAM_TEST_WRITE	BIT(7)=0A=
+#define MC_RLDRAM_TEST_GO		BIT(15)=0A=
+#define MC_RLDRAM_TEST_DONE		BIT(23)=0A=
+#define MC_RLDRAM_TEST_PASS		BIT(31)=0A=
+=0A=
+	u8 unused21[0x240 - 0x228];=0A=
+	u64 mc_rldram_test_add;=0A=
+	u8 unused22[0x260 - 0x248];=0A=
+	u64 mc_rldram_test_d0;=0A=
+	u8 unused23[0x280 - 0x268];=0A=
+	u64 mc_rldram_test_d1;=0A=
+	u8 unused24[0x300 - 0x288];=0A=
+	u64 mc_rldram_test_d2;=0A=
+	u8 unused25[0x700 - 0x308];=0A=
+	u64 mc_debug_ctrl;=0A=
+=0A=
+	u8 unused26[0x3000 - 0x2f08];=0A=
+=0A=
+/* XGXG */=0A=
+	/* XGXS control registers */=0A=
+=0A=
+	u64 xgxs_int_status;=0A=
+#define XGXS_INT_STATUS_TXGXS              BIT(0)=0A=
+#define XGXS_INT_STATUS_RXGXS              BIT(1)=0A=
+	u64 xgxs_int_mask;=0A=
+#define XGXS_INT_MASK_TXGXS                BIT(0)=0A=
+#define XGXS_INT_MASK_RXGXS                BIT(1)=0A=
+=0A=
+	u64 xgxs_txgxs_err_reg;=0A=
+#define TXGXS_ECC_DB_ERR                   BIT(15)=0A=
+	u64 xgxs_txgxs_err_mask;=0A=
+	u64 xgxs_txgxs_err_alarm;=0A=
+=0A=
+	u64 xgxs_rxgxs_err_reg;=0A=
+	u64 xgxs_rxgxs_err_mask;=0A=
+	u64 xgxs_rxgxs_err_alarm;=0A=
+=0A=
+	u8 unused27[0x100 - 0x40];=0A=
+=0A=
+	u64 xgxs_cfg;=0A=
+	u64 xgxs_status;=0A=
+=0A=
+	u64 xgxs_cfg_key;=0A=
+	u64 xgxs_efifo_cfg;	/* CHANGED */=0A=
+	u64 rxgxs_ber_0;	/* CHANGED */=0A=
+	u64 rxgxs_ber_1;	/* CHANGED */=0A=
+=0A=
+} XENA_dev_config_t;=0A=
+=0A=
+#define XENA_REG_SPACE	sizeof(XENA_dev_config_t)=0A=
+#define	XENA_EEPROM_SPACE (0x01 << 11)=0A=
+=0A=
+#endif				/* _REGS_H */=0A=
diff -urN vanilla-linux/drivers/net/s2io/s2io.c =
vanilla-linux-patch/drivers/net/s2io/s2io.c=0A=
--- vanilla-linux/drivers/net/s2io/s2io.c	1970-01-01 05:30:00.000000000 =
+0530=0A=
+++ vanilla-linux-patch/drivers/net/s2io/s2io.c	2004-03-18 =
18:00:12.000000000 +0530=0A=
@@ -0,0 +1,4389 @@=0A=
+/***********************************************************************=
*=0A=
+ * s2io.c: A Linux PCI-X Ethernet driver for S2IO 10GbE Server NIC=0A=
+ * Copyright(c) 2002-2005 S2IO Technologies=0A=
+=0A=
+ * This software may be used and distributed according to the terms of=0A=
+ * the GNU General Public License (GPL), incorporated herein by =
reference.=0A=
+ * Drivers based on or derived from this code fall under the GPL and =
must=0A=
+ * retain the authorship, copyright and license notice.  This file is =
not=0A=
+ * a complete program and may only be used when the entire operating=0A=
+ * system is licensed under the GPL.=0A=
+ * See the file COPYING in this distribution for more information.=0A=
+ *=0A=
+ * Credits:=0A=
+ * Jeff Garzik		: For pointing out the improper error condition =0A=
+ *			  check in the s2io_xmit routine and also some =0A=
+ * 			  issues in the Tx watch dog function. Also for=0A=
+ *			  patiently answering all those innumerable =0A=
+ *			  questions regaring the 2.6 porting issues.=0A=
+ * Stephen Hemminger	: Providing proper 2.6 porting mechanism for some=0A=
+ *			  macros available only in 2.6 Kernel.=0A=
+ * Francois Romieu	: For pointing out all code part that were =0A=
+ *			  deprecated and also styling related comments.=0A=
+ * Grant Grundler	: For helping me get rid of some Architecture =0A=
+ *			  dependent code.=0A=
+ * Christopher Hellwig	: Some more 2.6 specific issues in the driver.=0A=
+ *			  	=0A=
+ * The module loadable parameters that are supported by the driver and =
a brief=0A=
+ * explaination of all the variables.=0A=
+ * ring_num : This can be used to program the number of receive rings =
used =0A=
+ * in the driver.  					=0A=
+ * frame_len: This is an array of size 8. Using this we can set the =
maximum =0A=
+ * size of the received frame that can be steered into the corrsponding =0A=
+ * receive ring.=0A=
+ * ring_len: This defines the number of descriptors each ring can have. =
This =0A=
+ * is also an array of size 8.=0A=
+ * fifo_num: This defines the number of Tx FIFOs thats used int the =
driver.=0A=
+ * fifo_len: This too is an array of 8. Each element defines the number =
of =0A=
+ * Tx descriptors that can be associated with each corresponding FIFO.=0A=
+ * latency_timer: This input is programmed into the Latency timer =
register=0A=
+ * in PCI Configuration space.=0A=
+ =
************************************************************************/=0A=
+=0A=
+#include<linux/config.h>=0A=
+#include<linux/module.h>=0A=
+#include<linux/types.h>=0A=
+#include<linux/errno.h>=0A=
+#include<linux/ioport.h>=0A=
+#include<linux/pci.h>=0A=
+#include<linux/kernel.h>=0A=
+#include<linux/netdevice.h>=0A=
+#include<linux/etherdevice.h>=0A=
+#include<linux/skbuff.h>=0A=
+#include<linux/init.h>=0A=
+#include<linux/delay.h>=0A=
+#include<linux/stddef.h>=0A=
+#include<linux/ioctl.h>=0A=
+#include<linux/timex.h>=0A=
+#include<linux/sched.h>=0A=
+#include<linux/ethtool.h>=0A=
+#include<asm/system.h>=0A=
+#include<asm/uaccess.h>=0A=
+#include<linux/version.h>=0A=
+#include<asm/io.h>=0A=
+#include<linux/workqueue.h>=0A=
+=0A=
+/* local include */=0A=
+#include "s2io.h"=0A=
+#include "regs.h"=0A=
+=0A=
+/* S2io Driver name & version. */=0A=
+static char s2io_driver_name[] =3D "s2io";=0A=
+static char s2io_driver_version[] =3D "Version 1.0";=0A=
+=0A=
+#define LINK_IS_UP(val64) (!(val64 & (ADAPTER_STATUS_RMAC_REMOTE_FAULT =
| \=0A=
+				      ADAPTER_STATUS_RMAC_LOCAL_FAULT)))=0A=
+#define TASKLET_IN_USE test_and_set_bit(0, \=0A=
+				(unsigned long *)(&sp->tasklet_status))=0A=
+#define PANIC	1=0A=
+#define LOW	2=0A=
+static inline int rx_buffer_level(nic_t * sp, int rxb_size, int ring)=0A=
+{=0A=
+	int level =3D 0;=0A=
+	if ((sp->pkt_cnt[ring] - rxb_size) > 128) {=0A=
+		level =3D LOW;=0A=
+		if (rxb_size < sp->pkt_cnt[ring] / 8)=0A=
+			level =3D PANIC;=0A=
+	}=0A=
+=0A=
+	return level;=0A=
+}=0A=
+=0A=
+/* Ethtool related variables and Macros. */=0A=
+static char s2io_gstrings[][ETH_GSTRING_LEN] =3D {=0A=
+	"Register test\t(offline)",=0A=
+	"Eeprom test\t(offline)",=0A=
+	"Link test\t(online)",=0A=
+	"RLDRAM test\t(offline)",=0A=
+	"BIST Test\t(offline)"=0A=
+};=0A=
+=0A=
+static char ethtool_stats_keys[][ETH_GSTRING_LEN] =3D {=0A=
+	{"tmac_frms"},=0A=
+	{"tmac_data_octets"},=0A=
+	{"tmac_drop_frms"},=0A=
+	{"tmac_mcst_frms"},=0A=
+	{"tmac_bcst_frms"},=0A=
+	{"tmac_pause_ctrl_frms"},=0A=
+	{"tmac_any_err_frms"},=0A=
+	{"tmac_vld_ip_octets"},=0A=
+	{"tmac_vld_ip"},=0A=
+	{"tmac_drop_ip"},=0A=
+	{"tmac_icmp"},=0A=
+	{"tmac_rst_tcp"},=0A=
+	{"tmac_tcp"},=0A=
+	{"tmac_udp"},=0A=
+	{"rmac_vld_frms"},=0A=
+	{"rmac_data_octets"},=0A=
+	{"rmac_fcs_err_frms"},=0A=
+	{"rmac_drop_frms"},=0A=
+	{"rmac_vld_mcst_frms"},=0A=
+	{"rmac_vld_bcst_frms"},=0A=
+	{"rmac_in_rng_len_err_frms"},=0A=
+	{"rmac_long_frms"},=0A=
+	{"rmac_pause_ctrl_frms"},=0A=
+	{"rmac_discarded_frms"},=0A=
+	{"rmac_usized_frms"},=0A=
+	{"rmac_osized_frms"},=0A=
+	{"rmac_frag_frms"},=0A=
+	{"rmac_jabber_frms"},=0A=
+	{"rmac_ip"},=0A=
+	{"rmac_ip_octets"},=0A=
+	{"rmac_hdr_err_ip"},=0A=
+	{"rmac_drop_ip"},=0A=
+	{"rmac_icmp"},=0A=
+	{"rmac_tcp"},=0A=
+	{"rmac_udp"},=0A=
+	{"rmac_err_drp_udp"},=0A=
+	{"rmac_pause_cnt"},=0A=
+	{"rmac_accepted_ip"},=0A=
+	{"rmac_err_tcp"},=0A=
+};=0A=
+=0A=
+#define S2IO_STAT_LEN sizeof(ethtool_stats_keys)/ ETH_GSTRING_LEN=0A=
+#define S2IO_STAT_STRINGS_LEN S2IO_STAT_LEN * ETH_GSTRING_LEN=0A=
+=0A=
+#define S2IO_TEST_LEN	sizeof(s2io_gstrings) / ETH_GSTRING_LEN=0A=
+#define S2IO_STRINGS_LEN	S2IO_TEST_LEN * ETH_GSTRING_LEN=0A=
+=0A=
+=0A=
+/* Constants to be programmed into the Xena's registers to configure=0A=
+ * the XAUI.=0A=
+ */=0A=
+=0A=
+#define SWITCH_SIGN	0xA5A5A5A5A5A5A5A5ULL=0A=
+#define	END_SIGN	0x0=0A=
+=0A=
+static u64 default_mdio_cfg[] =3D {=0A=
+	/* Reset PMA PLL */=0A=
+	0xC001010000000000ULL, 0xC0010100000000E0ULL,=0A=
+	0xC0010100008000E4ULL,=0A=
+	/* Remove Reset from PMA PLL */=0A=
+	0xC001010000000000ULL, 0xC0010100000000E0ULL,=0A=
+	0xC0010100000000E4ULL,=0A=
+	END_SIGN=0A=
+};=0A=
+=0A=
+static u64 default_dtx_cfg[] =3D {=0A=
+	0x8000051500000000ULL, 0x80000515000000E0ULL,=0A=
+	0x80000515D93500E4ULL, 0x8001051500000000ULL,=0A=
+	0x80010515000000E0ULL, 0x80010515001E00E4ULL,=0A=
+	0x8002051500000000ULL, 0x80020515000000E0ULL,=0A=
+	0x80020515F21000E4ULL,=0A=
+	/* Set PADLOOPBACKN */=0A=
+	0x8002051500000000ULL, 0x80020515000000E0ULL,=0A=
+	0x80020515B20000E4ULL, 0x8003051500000000ULL,=0A=
+	0x80030515000000E0ULL, 0x80030515B20000E4ULL,=0A=
+	0x8004051500000000ULL, 0x80040515000000E0ULL,=0A=
+	0x80040515B20000E4ULL, 0x8005051500000000ULL,=0A=
+	0x80050515000000E0ULL, 0x80050515B20000E4ULL,=0A=
+	SWITCH_SIGN,=0A=
+	/* Remove PADLOOPBACKN */=0A=
+	0x8002051500000000ULL, 0x80020515000000E0ULL,=0A=
+	0x80020515F20000E4ULL, 0x8003051500000000ULL,=0A=
+	0x80030515000000E0ULL, 0x80030515F20000E4ULL,=0A=
+	0x8004051500000000ULL, 0x80040515000000E0ULL,=0A=
+	0x80040515F20000E4ULL, 0x8005051500000000ULL,=0A=
+	0x80050515000000E0ULL, 0x80050515F20000E4ULL,=0A=
+	END_SIGN=0A=
+};=0A=
+=0A=
+/* Constants for Fixing the MacAddress problem seen mostly on=0A=
+ * Alpha machines.=0A=
+ */=0A=
+static u64 fix_mac[] =3D {=0A=
+	0x0060000000000000ULL, 0x0060600000000000ULL,=0A=
+	0x0040600000000000ULL, 0x0000600000000000ULL,=0A=
+	0x0020600000000000ULL, 0x0060600000000000ULL,=0A=
+	0x0020600000000000ULL, 0x0060600000000000ULL,=0A=
+	0x0020600000000000ULL, 0x0060600000000000ULL,=0A=
+	0x0020600000000000ULL, 0x0060600000000000ULL,=0A=
+	0x0020600000000000ULL, 0x0060600000000000ULL,=0A=
+	0x0020600000000000ULL, 0x0060600000000000ULL,=0A=
+	0x0020600000000000ULL, 0x0060600000000000ULL,=0A=
+	0x0020600000000000ULL, 0x0060600000000000ULL,=0A=
+	0x0020600000000000ULL, 0x0060600000000000ULL,=0A=
+	0x0020600000000000ULL, 0x0060600000000000ULL,=0A=
+	0x0020600000000000ULL, 0x0000600000000000ULL,=0A=
+	0x0040600000000000ULL, 0x0060600000000000ULL,=0A=
+	END_SIGN=0A=
+};=0A=
+=0A=
+=0A=
+/* Module Loadable parameters. */=0A=
+static u32 ring_num;=0A=
+static u32 frame_len[MAX_RX_RINGS];=0A=
+static u32 ring_len[MAX_RX_RINGS];=0A=
+static u32 fifo_num;=0A=
+static u32 fifo_len[MAX_TX_FIFOS];=0A=
+static u32 rx_prio;=0A=
+static u32 tx_prio;=0A=
+static u8 latency_timer =3D 0;=0A=
+=0A=
+/* =0A=
+ * S2IO device table.=0A=
+ * This table lists all the devices that this driver supports. =0A=
+ */=0A=
+static struct pci_device_id s2io_tbl[] __devinitdata =3D {=0A=
+	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_S2IO_WIN,=0A=
+	 PCI_ANY_ID, PCI_ANY_ID},=0A=
+	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_S2IO_UNI,=0A=
+	 PCI_ANY_ID, PCI_ANY_ID},=0A=
+	{0,}=0A=
+};=0A=
+=0A=
+MODULE_DEVICE_TABLE(pci, s2io_tbl);=0A=
+=0A=
+static struct pci_driver s2io_driver =3D {=0A=
+      name:"S2IO",=0A=
+      id_table:s2io_tbl,=0A=
+      probe:s2io_init_nic,=0A=
+      remove:s2io_rem_nic,=0A=
+};=0A=
+=0A=
+/*  =0A=
+ *  Input Arguments: =0A=
+ *  Device private variable.=0A=
+ *  Return Value: =0A=
+ *  SUCCESS on success and an appropriate -ve value on failure.=0A=
+ *  Description: =0A=
+ *  The function allocates the all memory areas shared =0A=
+ *  between the NIC and the driver. This includes Tx descriptors, =0A=
+ *  Rx descriptors and the statistics block.=0A=
+ */=0A=
+static int initSharedMem(struct s2io_nic *nic)=0A=
+{=0A=
+	u32 size;=0A=
+	void *tmp_v_addr, *tmp_v_addr_next;=0A=
+	dma_addr_t tmp_p_addr, tmp_p_addr_next;=0A=
+	RxD_block_t *pre_rxd_blk =3D NULL;=0A=
+	int i, j, blk_cnt;=0A=
+	struct net_device *dev =3D nic->dev;=0A=
+=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+=0A=
+	mac_control =3D &nic->mac_control;=0A=
+	config =3D &nic->config;=0A=
+=0A=
+=0A=
+	/* Allocation and initialization of TXDLs in FIOFs */=0A=
+	size =3D 0;=0A=
+	for (i =3D 0; i < config->TxFIFONum; i++) {=0A=
+		size +=3D config->TxCfg[i].FifoLen;=0A=
+	}=0A=
+	if (size > MAX_AVAILABLE_TXDS) {=0A=
+		DBG_PRINT(ERR_DBG, "%s: Total number of Tx FIFOs ",=0A=
+			  dev->name);=0A=
+		DBG_PRINT(ERR_DBG, "exceeds the maximum value ");=0A=
+		DBG_PRINT(ERR_DBG, "that can be used\n");=0A=
+		return FAILURE;=0A=
+	}=0A=
+	size *=3D (sizeof(TxD_t) * config->MaxTxDs);=0A=
+=0A=
+	mac_control->txd_list_mem =3D pci_alloc_consistent=0A=
+	    (nic->pdev, size, &mac_control->txd_list_mem_phy);=0A=
+	if (!mac_control->txd_list_mem) {=0A=
+		return -ENOMEM;=0A=
+	}=0A=
+	mac_control->txd_list_mem_sz =3D size;=0A=
+=0A=
+	tmp_v_addr =3D mac_control->txd_list_mem;=0A=
+	tmp_p_addr =3D mac_control->txd_list_mem_phy;=0A=
+	memset(tmp_v_addr, 0, size);=0A=
+=0A=
+	DBG_PRINT(INIT_DBG, "%s:List Mem PHY: 0x%llx\n", dev->name,=0A=
+		  (unsigned long long) tmp_p_addr);=0A=
+=0A=
+	for (i =3D 0; i < config->TxFIFONum; i++) {=0A=
+		mac_control->txdl_start_phy[i] =3D tmp_p_addr;=0A=
+		mac_control->txdl_start[i] =3D (TxD_t *) tmp_v_addr;=0A=
+		mac_control->tx_curr_put_info[i].offset =3D 0;=0A=
+		mac_control->tx_curr_put_info[i].fifo_len =3D=0A=
+		    config->TxCfg[i].FifoLen - 1;=0A=
+		mac_control->tx_curr_get_info[i].offset =3D 0;=0A=
+		mac_control->tx_curr_get_info[i].fifo_len =3D=0A=
+		    config->TxCfg[i].FifoLen - 1;=0A=
+=0A=
+		tmp_p_addr +=3D=0A=
+		    (config->TxCfg[i].FifoLen * (sizeof(TxD_t)) *=0A=
+		     config->MaxTxDs);=0A=
+		tmp_v_addr +=3D=0A=
+		    (config->TxCfg[i].FifoLen * (sizeof(TxD_t)) *=0A=
+		     config->MaxTxDs);=0A=
+	}=0A=
+=0A=
+	/* Allocation and initialization of RXDs in Rings */=0A=
+	size =3D 0;=0A=
+	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
+		if (config->RxCfg[i].NumRxd % (MAX_RXDS_PER_BLOCK + 1)) {=0A=
+			DBG_PRINT(ERR_DBG, "%s: RxD count of ", dev->name);=0A=
+			DBG_PRINT(ERR_DBG, "Ring%d is not a multiple of ",=0A=
+				  i);=0A=
+			DBG_PRINT(ERR_DBG, "RxDs per Block");=0A=
+			return FAILURE;=0A=
+		}=0A=
+		size +=3D config->RxCfg[i].NumRxd;=0A=
+		nic->block_count[i] =3D=0A=
+		    config->RxCfg[i].NumRxd / (MAX_RXDS_PER_BLOCK + 1);=0A=
+		nic->pkt_cnt[i] =3D=0A=
+		    config->RxCfg[i].NumRxd - nic->block_count[i];=0A=
+	}=0A=
+	size =3D (size * (sizeof(RxD_t)));=0A=
+	mac_control->rxd_ring_mem_sz =3D size;=0A=
+=0A=
+	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
+		mac_control->rx_curr_get_info[i].block_index =3D 0;=0A=
+		mac_control->rx_curr_get_info[i].offset =3D 0;=0A=
+		mac_control->rx_curr_get_info[i].ring_len =3D=0A=
+		    config->RxCfg[i].NumRxd - 1;=0A=
+		mac_control->rx_curr_put_info[i].block_index =3D 0;=0A=
+		mac_control->rx_curr_put_info[i].offset =3D 0;=0A=
+		mac_control->rx_curr_put_info[i].ring_len =3D=0A=
+		    config->RxCfg[i].NumRxd - 1;=0A=
+		blk_cnt =3D=0A=
+		    config->RxCfg[i].NumRxd / (MAX_RXDS_PER_BLOCK + 1);=0A=
+		/*  Allocating all the Rx blocks */=0A=
+		for (j =3D 0; j < blk_cnt; j++) {=0A=
+			size =3D (MAX_RXDS_PER_BLOCK + 1) * (sizeof(RxD_t));=0A=
+			tmp_v_addr =3D pci_alloc_consistent(nic->pdev, size,=0A=
+							  &tmp_p_addr);=0A=
+			if (tmp_v_addr =3D=3D NULL) {=0A=
+				/* In case of failure, freeSharedMem() =0A=
+				 * is called, which should free any =0A=
+				 * memory that was alloced till the =0A=
+				 * failure happened.=0A=
+				 */=0A=
+				nic->rx_blocks[i][j].block_virt_addr =3D=0A=
+				    tmp_v_addr;=0A=
+				return -ENOMEM;=0A=
+			}=0A=
+			memset(tmp_v_addr, 0, size);=0A=
+			nic->rx_blocks[i][j].block_virt_addr =3D tmp_v_addr;=0A=
+			nic->rx_blocks[i][j].block_dma_addr =3D tmp_p_addr;=0A=
+		}=0A=
+		/* Interlinking all Rx Blocks */=0A=
+		for (j =3D 0; j < blk_cnt; j++) {=0A=
+			tmp_v_addr =3D nic->rx_blocks[i][j].block_virt_addr;=0A=
+			tmp_v_addr_next =3D=0A=
+			    nic->rx_blocks[i][(j + 1) %=0A=
+					      blk_cnt].block_virt_addr;=0A=
+			tmp_p_addr =3D nic->rx_blocks[i][j].block_dma_addr;=0A=
+			tmp_p_addr_next =3D=0A=
+			    nic->rx_blocks[i][(j + 1) %=0A=
+					      blk_cnt].block_dma_addr;=0A=
+=0A=
+			pre_rxd_blk =3D (RxD_block_t *) tmp_v_addr;=0A=
+			pre_rxd_blk->reserved_1 =3D END_OF_BLOCK;	/* last RxD =0A=
+								 * marker.=0A=
+								 */=0A=
+			pre_rxd_blk->reserved_2_pNext_RxD_block =3D=0A=
+			    (unsigned long) tmp_v_addr_next;=0A=
+			pre_rxd_blk->pNext_RxD_Blk_physical =3D=0A=
+			    (u64) tmp_p_addr_next;=0A=
+		}=0A=
+	}=0A=
+=0A=
+	/* Allocation and initialization of Statistics block */=0A=
+	size =3D sizeof(StatInfo_t);=0A=
+	mac_control->stats_mem =3D pci_alloc_consistent=0A=
+	    (nic->pdev, size, &mac_control->stats_mem_phy);=0A=
+=0A=
+	if (!mac_control->stats_mem) {=0A=
+		/* In case of failure, freeSharedMem() is called, which =0A=
+		 * should free any memory that was alloced till the =0A=
+		 * failure happened.=0A=
+		 */=0A=
+		return -ENOMEM;=0A=
+	}=0A=
+	mac_control->stats_mem_sz =3D size;=0A=
+=0A=
+	tmp_v_addr =3D mac_control->stats_mem;=0A=
+	mac_control->StatsInfo =3D (StatInfo_t *) tmp_v_addr;=0A=
+	memset(tmp_v_addr, 0, size);=0A=
+=0A=
+	DBG_PRINT(INIT_DBG, "%s:Ring Mem PHY: 0x%llx\n", dev->name,=0A=
+		  (unsigned long long) tmp_p_addr);=0A=
+=0A=
+	return SUCCESS;=0A=
+}=0A=
+=0A=
+/*  =0A=
+ *  Input Arguments: =0A=
+ *  Device peivate variable.=0A=
+ *  Return Value: =0A=
+ *  NONE=0A=
+ *  Description: =0A=
+ *  This function is to free all memory locations allocated by=0A=
+ *  the initSharedMem() function and return it to the kernel.=0A=
+ */=0A=
+static void freeSharedMem(struct s2io_nic *nic)=0A=
+{=0A=
+	int i, j, blk_cnt, size;=0A=
+	void *tmp_v_addr;=0A=
+	dma_addr_t tmp_p_addr;=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+=0A=
+=0A=
+	if (!nic)=0A=
+		return;=0A=
+=0A=
+	mac_control =3D &nic->mac_control;=0A=
+	config =3D &nic->config;=0A=
+=0A=
+	if (mac_control->txd_list_mem) {=0A=
+		pci_free_consistent(nic->pdev,=0A=
+				    mac_control->txd_list_mem_sz,=0A=
+				    mac_control->txd_list_mem,=0A=
+				    mac_control->txd_list_mem_phy);=0A=
+	}=0A=
+=0A=
+	size =3D (MAX_RXDS_PER_BLOCK + 1) * (sizeof(RxD_t));=0A=
+	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
+		blk_cnt =3D nic->block_count[i];=0A=
+		for (j =3D 0; j < blk_cnt; j++) {=0A=
+			tmp_v_addr =3D nic->rx_blocks[i][j].block_virt_addr;=0A=
+			tmp_p_addr =3D nic->rx_blocks[i][j].block_dma_addr;=0A=
+			if (tmp_v_addr =3D=3D NULL)=0A=
+				break;=0A=
+			pci_free_consistent(nic->pdev, size,=0A=
+					    tmp_v_addr, tmp_p_addr);=0A=
+		}=0A=
+	}=0A=
+=0A=
+	if (mac_control->stats_mem) {=0A=
+		pci_free_consistent(nic->pdev,=0A=
+				    mac_control->stats_mem_sz,=0A=
+				    mac_control->stats_mem,=0A=
+				    mac_control->stats_mem_phy);=0A=
+	}=0A=
+}=0A=
+=0A=
+/*  =0A=
+ *  Input Arguments: =0A=
+ *  device peivate variable=0A=
+ *  Return Value: =0A=
+ *  SUCCESS on success and '-1' on failure (endian settings incorrect).=0A=
+ *  Description: =0A=
+ *  The function sequentially configures every block =0A=
+ *  of the H/W from their reset values. =0A=
+ */=0A=
+static int initNic(struct s2io_nic *nic)=0A=
+{=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;=0A=
+	struct net_device *dev =3D nic->dev;=0A=
+	register u64 val64 =3D 0;=0A=
+	void *add;=0A=
+	u32 time;=0A=
+	int i, j;=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+	int mdio_cnt =3D 0, dtx_cnt =3D 0;=0A=
+	unsigned long long print_var, mem_share;=0A=
+=0A=
+	mac_control =3D &nic->mac_control;=0A=
+	config =3D &nic->config;=0A=
+=0A=
+	/*  Set proper endian settings and verify the same by =0A=
+	 *  reading the PIF Feed-back register.=0A=
+	 */=0A=
+#ifdef  __BIG_ENDIAN=0A=
+	/* The device by default set to a big endian format, so =0A=
+	 * a big endian driver need not set anything.=0A=
+	 */=0A=
+	writeq(0xffffffffffffffffULL, &bar0->swapper_ctrl);=0A=
+	val64 =3D (SWAPPER_CTRL_PIF_R_FE |=0A=
+		 SWAPPER_CTRL_PIF_R_SE |=0A=
+		 SWAPPER_CTRL_PIF_W_FE |=0A=
+		 SWAPPER_CTRL_PIF_W_SE |=0A=
+		 SWAPPER_CTRL_TXP_FE |=0A=
+		 SWAPPER_CTRL_TXP_SE |=0A=
+		 SWAPPER_CTRL_TXD_R_FE |=0A=
+		 SWAPPER_CTRL_TXD_W_FE |=0A=
+		 SWAPPER_CTRL_TXF_R_FE |=0A=
+		 SWAPPER_CTRL_RXD_R_FE |=0A=
+		 SWAPPER_CTRL_RXD_W_FE |=0A=
+		 SWAPPER_CTRL_RXF_W_FE |=0A=
+		 SWAPPER_CTRL_XMSI_FE |=0A=
+		 SWAPPER_CTRL_XMSI_SE |=0A=
+		 SWAPPER_CTRL_STATS_FE | SWAPPER_CTRL_STATS_SE);=0A=
+	writeq(val64, &bar0->swapper_ctrl);=0A=
+#else=0A=
+	/* Initially we enable all bits to make it accessible by =0A=
+	 * the driver, then we selectively enable only those bits =0A=
+	 * that we want to set.=0A=
+	 */=0A=
+	writeq(0xffffffffffffffffULL, &bar0->swapper_ctrl);=0A=
+	val64 =3D (SWAPPER_CTRL_PIF_R_FE |=0A=
+		 SWAPPER_CTRL_PIF_R_SE |=0A=
+		 SWAPPER_CTRL_PIF_W_FE |=0A=
+		 SWAPPER_CTRL_PIF_W_SE |=0A=
+		 SWAPPER_CTRL_TXP_FE |=0A=
+		 SWAPPER_CTRL_TXP_SE |=0A=
+		 SWAPPER_CTRL_TXD_R_FE |=0A=
+		 SWAPPER_CTRL_TXD_R_SE |=0A=
+		 SWAPPER_CTRL_TXD_W_FE |=0A=
+		 SWAPPER_CTRL_TXD_W_SE |=0A=
+		 SWAPPER_CTRL_TXF_R_FE |=0A=
+		 SWAPPER_CTRL_RXD_R_FE |=0A=
+		 SWAPPER_CTRL_RXD_R_SE |=0A=
+		 SWAPPER_CTRL_RXD_W_FE |=0A=
+		 SWAPPER_CTRL_RXD_W_SE |=0A=
+		 SWAPPER_CTRL_RXF_W_FE |=0A=
+		 SWAPPER_CTRL_XMSI_FE |=0A=
+		 SWAPPER_CTRL_XMSI_SE |=0A=
+		 SWAPPER_CTRL_STATS_FE | SWAPPER_CTRL_STATS_SE);=0A=
+	writeq(val64, &bar0->swapper_ctrl);=0A=
+#endif=0A=
+=0A=
+	/* Verifying if endian settings are accurate by reading =0A=
+	 * a feedback register.=0A=
+	 */=0A=
+	val64 =3D readq(&bar0->pif_rd_swapper_fb);=0A=
+	if (val64 !=3D 0x0123456789ABCDEFULL) {=0A=
+		/* Endian settings are incorrect, calls for another dekko. */=0A=
+		print_var =3D (unsigned long long) val64;=0A=
+		DBG_PRINT(INIT_DBG, "%s: Endian settings are wrong",=0A=
+			  dev->name);=0A=
+		DBG_PRINT(ERR_DBG, ", feedback read %llx\n", print_var);=0A=
+=0A=
+		return FAILURE;=0A=
+	}=0A=
+=0A=
+	/* Remove XGXS from reset state */=0A=
+	val64 =3D 0;=0A=
+	writeq(val64, &bar0->sw_reset);=0A=
+	val64 =3D readq(&bar0->sw_reset);=0A=
+	set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+	schedule_timeout(HZ / 2);=0A=
+=0A=
+	/*  Enable Receiving broadcasts */=0A=
+	val64 =3D readq(&bar0->mac_cfg);=0A=
+	val64 |=3D MAC_RMAC_BCAST_ENABLE;=0A=
+	writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);=0A=
+	writeq(val64, &bar0->mac_cfg);=0A=
+=0A=
+	/* Read registers in all blocks */=0A=
+	val64 =3D readq(&bar0->mac_int_mask);=0A=
+	val64 =3D readq(&bar0->mc_int_mask);=0A=
+	val64 =3D readq(&bar0->xgxs_int_mask);=0A=
+=0A=
+	/*  Set MTU */=0A=
+	val64 =3D dev->mtu;=0A=
+	writeq(vBIT(val64, 2, 14), &bar0->rmac_max_pyld_len);=0A=
+=0A=
+	/* Configuring the XAUI Interface of Xena. =0A=
+	 *****************************************=0A=
+	 * To Configure the Xena's XAUI, one has to write a series =0A=
+	 * of 64 bit values into two registers in a particular =0A=
+	 * sequence. Hence a macro 'SWITCH_SIGN' has been defined =0A=
+	 * which will be defined in the array of configuration values =0A=
+	 * (default_dtx_cfg & default_mdio_cfg) at appropriate places =0A=
+	 * to switch writing from one regsiter to another. We continue =0A=
+	 * writing these values until we encounter the 'END_SIGN' macro.=0A=
+	 * For example, After making a series of 21 writes into =0A=
+	 * dtx_control register the 'SWITCH_SIGN' appears and hence we =0A=
+	 * start writing into mdio_control until we encounter END_SIGN.=0A=
+	 */=0A=
+	while (1) {=0A=
+	      dtx_cfg:=0A=
+		while (default_dtx_cfg[dtx_cnt] !=3D END_SIGN) {=0A=
+			if (default_dtx_cfg[dtx_cnt] =3D=3D SWITCH_SIGN) {=0A=
+				dtx_cnt++;=0A=
+				goto mdio_cfg;=0A=
+			}=0A=
+			writeq(default_dtx_cfg[dtx_cnt],=0A=
+			       &bar0->dtx_control);=0A=
+			val64 =3D readq(&bar0->dtx_control);=0A=
+			dtx_cnt++;=0A=
+		}=0A=
+	      mdio_cfg:=0A=
+		while (default_mdio_cfg[mdio_cnt] !=3D END_SIGN) {=0A=
+			if (default_mdio_cfg[mdio_cnt] =3D=3D SWITCH_SIGN) {=0A=
+				mdio_cnt++;=0A=
+				goto dtx_cfg;=0A=
+			}=0A=
+			writeq(default_mdio_cfg[mdio_cnt],=0A=
+			       &bar0->mdio_control);=0A=
+			val64 =3D readq(&bar0->mdio_control);=0A=
+			mdio_cnt++;=0A=
+		}=0A=
+		if ((default_dtx_cfg[dtx_cnt] =3D=3D END_SIGN) &&=0A=
+		    (default_mdio_cfg[mdio_cnt] =3D=3D END_SIGN)) {=0A=
+			break;=0A=
+		} else {=0A=
+			goto dtx_cfg;=0A=
+		}=0A=
+	}=0A=
+=0A=
+	/*  Tx DMA Initialization */=0A=
+	val64 =3D 0;=0A=
+	writeq(val64, &bar0->tx_fifo_partition_0);=0A=
+	writeq(val64, &bar0->tx_fifo_partition_1);=0A=
+	writeq(val64, &bar0->tx_fifo_partition_2);=0A=
+	writeq(val64, &bar0->tx_fifo_partition_3);=0A=
+=0A=
+=0A=
+	for (i =3D 0, j =3D 0; i < config->TxFIFONum; i++) {=0A=
+		val64 |=3D=0A=
+		    vBIT(config->TxCfg[i].FifoLen - 1, ((i * 32) + 19),=0A=
+			 13) | vBIT(config->TxCfg[i].FifoPriority,=0A=
+				    ((i * 32) + 5), 3);=0A=
+=0A=
+		if (i =3D=3D (config->TxFIFONum - 1)) {=0A=
+			if (i % 2 =3D=3D 0)=0A=
+				i++;=0A=
+		}=0A=
+=0A=
+		switch (i) {=0A=
+		case 1:=0A=
+			writeq(val64, &bar0->tx_fifo_partition_0);=0A=
+			val64 =3D 0;=0A=
+			break;=0A=
+		case 3:=0A=
+			writeq(val64, &bar0->tx_fifo_partition_1);=0A=
+			val64 =3D 0;=0A=
+			break;=0A=
+		case 5:=0A=
+			writeq(val64, &bar0->tx_fifo_partition_2);=0A=
+			val64 =3D 0;=0A=
+			break;=0A=
+		case 7:=0A=
+			writeq(val64, &bar0->tx_fifo_partition_3);=0A=
+			break;=0A=
+		}=0A=
+	}=0A=
+=0A=
+	/* Enable Tx FIFO partition 0. */=0A=
+	val64 =3D readq(&bar0->tx_fifo_partition_0);=0A=
+	val64 |=3D BIT(0);	/* To enable the FIFO partition. */=0A=
+	writeq(val64, &bar0->tx_fifo_partition_0);=0A=
+=0A=
+	val64 =3D readq(&bar0->tx_fifo_partition_0);=0A=
+	DBG_PRINT(INIT_DBG, "Fifo partition at: 0x%p is: 0x%llx\n",=0A=
+		  &bar0->tx_fifo_partition_0, (unsigned long long) val64);=0A=
+=0A=
+	/* =0A=
+	 * Initialization of Tx_PA_CONFIG register to ignore packet =0A=
+	 * integrity checking.=0A=
+	 */=0A=
+	val64 =3D readq(&bar0->tx_pa_cfg);=0A=
+	val64 |=3D TX_PA_CFG_IGNORE_FRM_ERR | TX_PA_CFG_IGNORE_SNAP_OUI |=0A=
+	    TX_PA_CFG_IGNORE_LLC_CTRL | TX_PA_CFG_IGNORE_L2_ERR;=0A=
+	writeq(val64, &bar0->tx_pa_cfg);=0A=
+=0A=
+	/* Rx DMA intialization. */=0A=
+	val64 =3D 0;=0A=
+	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
+		val64 |=3D=0A=
+		    vBIT(config->RxCfg[i].RingPriority, (5 + (i * 8)), 3);=0A=
+	}=0A=
+	writeq(val64, &bar0->rx_queue_priority);=0A=
+=0A=
+	/* Allocating equal share of memory to all the configured =0A=
+	 * Rings.=0A=
+	 */=0A=
+	val64 =3D 0;=0A=
+	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
+		switch (i) {=0A=
+		case 0:=0A=
+			mem_share =3D (64 / config->RxRingNum +=0A=
+				     64 % config->RxRingNum);=0A=
+			val64 |=3D RX_QUEUE_CFG_Q0_SZ(mem_share);=0A=
+			continue;=0A=
+		case 1:=0A=
+			mem_share =3D (64 / config->RxRingNum);=0A=
+			val64 |=3D RX_QUEUE_CFG_Q1_SZ(mem_share);=0A=
+			continue;=0A=
+		case 2:=0A=
+			mem_share =3D (64 / config->RxRingNum);=0A=
+			val64 |=3D RX_QUEUE_CFG_Q2_SZ(mem_share);=0A=
+			continue;=0A=
+		case 3:=0A=
+			mem_share =3D (64 / config->RxRingNum);=0A=
+			val64 |=3D RX_QUEUE_CFG_Q3_SZ(mem_share);=0A=
+			continue;=0A=
+		case 4:=0A=
+			mem_share =3D (64 / config->RxRingNum);=0A=
+			val64 |=3D RX_QUEUE_CFG_Q4_SZ(mem_share);=0A=
+			continue;=0A=
+		case 5:=0A=
+			mem_share =3D (64 / config->RxRingNum);=0A=
+			val64 |=3D RX_QUEUE_CFG_Q5_SZ(mem_share);=0A=
+			continue;=0A=
+		case 6:=0A=
+			mem_share =3D (64 / config->RxRingNum);=0A=
+			val64 |=3D RX_QUEUE_CFG_Q6_SZ(mem_share);=0A=
+			continue;=0A=
+		case 7:=0A=
+			mem_share =3D (64 / config->RxRingNum);=0A=
+			val64 |=3D RX_QUEUE_CFG_Q7_SZ(mem_share);=0A=
+			continue;=0A=
+		}=0A=
+	}=0A=
+	writeq(val64, &bar0->rx_queue_cfg);=0A=
+=0A=
+	/* Initializing the Tx round robin registers to 0.=0A=
+	 * Filling Tx and Rx round robin registers as per the =0A=
+	 * number of FIFOs and Rings is still TODO.=0A=
+	 */=0A=
+	writeq(0, &bar0->tx_w_round_robin_0);=0A=
+	writeq(0, &bar0->tx_w_round_robin_1);=0A=
+	writeq(0, &bar0->tx_w_round_robin_2);=0A=
+	writeq(0, &bar0->tx_w_round_robin_3);=0A=
+	writeq(0, &bar0->tx_w_round_robin_4);=0A=
+=0A=
+	/* Disable Rx steering. Hard coding all packets be steered to=0A=
+	 * Queue 0 for now. =0A=
+	 * TODO*/=0A=
+	if (rx_prio) {=0A=
+		u64 def =3D 0x8000000000000000ULL, tmp;=0A=
+		for (i =3D 0; i < MAX_RX_RINGS; i++) {=0A=
+			tmp =3D (u64) (def >> (i % config->RxRingNum));=0A=
+			val64 |=3D (u64) (tmp >> (i * 8));=0A=
+		}=0A=
+		writeq(val64, &bar0->rts_qos_steering);=0A=
+	} else {=0A=
+		val64 =3D 0x8080808080808080ULL;=0A=
+		writeq(val64, &bar0->rts_qos_steering);=0A=
+	}=0A=
+=0A=
+	/* UDP Fix */=0A=
+	val64 =3D 0;=0A=
+	for (i =3D 1; i < 8; i++)=0A=
+		writeq(val64, &bar0->rts_frm_len_n[i]);=0A=
+=0A=
+	/* Set rts_frm_len register for fifo 0 */=0A=
+	writeq(MAC_RTS_FRM_LEN_SET(dev->mtu + 22),=0A=
+	       &bar0->rts_frm_len_n[0]);=0A=
+=0A=
+	/* Enable statistics */=0A=
+	writeq(mac_control->stats_mem_phy, &bar0->stat_addr);=0A=
+	val64 =3D SET_UPDT_PERIOD(8) | STAT_CFG_STAT_RO | STAT_CFG_STAT_EN;=0A=
+	writeq(val64, &bar0->stat_cfg);=0A=
+=0A=
+	/* Initializing the sampling rate for the device to calculate the=0A=
+	 * bandwidth utilization.=0A=
+	 */=0A=
+	val64 =3D MAC_TX_LINK_UTIL_VAL(0x5) | MAC_RX_LINK_UTIL_VAL(0x5);=0A=
+	writeq(val64, &bar0->mac_link_util);=0A=
+=0A=
+=0A=
+	/* Initializing the Transmit and Receive Traffic Interrupt =0A=
+	 * Scheme.=0A=
+	 */=0A=
+	/* TTI Initialization */=0A=
+	val64 =3D TTI_DATA1_MEM_TX_TIMER_VAL(0xFFF) |=0A=
+	    TTI_DATA1_MEM_TX_URNG_A(0xA) | TTI_DATA1_MEM_TX_URNG_B(0x10) |=0A=
+	    TTI_DATA1_MEM_TX_URNG_C(0x30) | TTI_DATA1_MEM_TX_TIMER_AC_EN;=0A=
+	writeq(val64, &bar0->tti_data1_mem);=0A=
+=0A=
+	val64 =3D=0A=
+	    TTI_DATA2_MEM_TX_UFC_A(0x10) | TTI_DATA2_MEM_TX_UFC_B(0x20) |=0A=
+	    TTI_DATA2_MEM_TX_UFC_C(0x40) | TTI_DATA2_MEM_TX_UFC_D(0x80);=0A=
+	writeq(val64, &bar0->tti_data2_mem);=0A=
+=0A=
+	val64 =3D TTI_CMD_MEM_WE | TTI_CMD_MEM_STROBE_NEW_CMD;=0A=
+	writeq(val64, &bar0->tti_command_mem);=0A=
+=0A=
+	/* Once the operation completes, the Strobe bit of the command=0A=
+	 * register will be reset. We poll for this particular condition=0A=
+	 * We wait for a maximum of 500ms for the operation to complete,=0A=
+	 * if it's not complete by then we return error.=0A=
+	 */=0A=
+	time =3D 0;=0A=
+	while (TRUE) {=0A=
+		val64 =3D readq(&bar0->tti_command_mem);=0A=
+		if (!(val64 & TTI_CMD_MEM_STROBE_NEW_CMD)) {=0A=
+			break;=0A=
+		}=0A=
+		if (time > 10) {=0A=
+			DBG_PRINT(ERR_DBG, "%s: TTI init Failed\n",=0A=
+				  dev->name);=0A=
+			return -1;=0A=
+		}=0A=
+		set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+		schedule_timeout(HZ / 20);=0A=
+		time++;=0A=
+	}=0A=
+=0A=
+	/* RTI Initialization */=0A=
+	val64 =3D RTI_DATA1_MEM_RX_TIMER_VAL(0xFFF) |=0A=
+	    RTI_DATA1_MEM_RX_URNG_A(0xA) | RTI_DATA1_MEM_RX_URNG_B(0x10) |=0A=
+	    RTI_DATA1_MEM_RX_URNG_C(0x30) | RTI_DATA1_MEM_RX_TIMER_AC_EN;=0A=
+	writeq(val64, &bar0->rti_data1_mem);=0A=
+=0A=
+	val64 =3D RTI_DATA2_MEM_RX_UFC_A(0x1) | RTI_DATA2_MEM_RX_UFC_B(0x2) |=0A=
+	    RTI_DATA2_MEM_RX_UFC_C(0x40) | RTI_DATA2_MEM_RX_UFC_D(0x80);=0A=
+	writeq(val64, &bar0->rti_data2_mem);=0A=
+=0A=
+	val64 =3D RTI_CMD_MEM_WE | RTI_CMD_MEM_STROBE_NEW_CMD;=0A=
+	writeq(val64, &bar0->rti_command_mem);=0A=
+=0A=
+	/* Once the operation completes, the Strobe bit of the command=0A=
+	 * register will be reset. We poll for this particular condition=0A=
+	 * We wait for a maximum of 500ms for the operation to complete,=0A=
+	 * if it's not complete by then we return error.=0A=
+	 */=0A=
+	time =3D 0;=0A=
+	while (TRUE) {=0A=
+		val64 =3D readq(&bar0->rti_command_mem);=0A=
+		if (!(val64 & TTI_CMD_MEM_STROBE_NEW_CMD)) {=0A=
+			break;=0A=
+		}=0A=
+		if (time > 10) {=0A=
+			DBG_PRINT(ERR_DBG, "%s: RTI init Failed\n",=0A=
+				  dev->name);=0A=
+			return -1;=0A=
+		}=0A=
+		time++;=0A=
+		set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+		schedule_timeout(HZ / 20);=0A=
+	}=0A=
+=0A=
+	/* Initializing proper values as Pause threshold into all =0A=
+	 * the 8 Queues on Rx side.=0A=
+	 */=0A=
+	writeq(0xffbbffbbffbbffbbULL, &bar0->mc_pause_thresh_q0q3);=0A=
+	writeq(0xffbbffbbffbbffbbULL, &bar0->mc_pause_thresh_q4q7);=0A=
+=0A=
+	/* Disable RMAC PAD STRIPPING */=0A=
+	add =3D (void *) &bar0->mac_cfg;=0A=
+	val64 =3D readq(&bar0->mac_cfg);=0A=
+	val64 &=3D ~(MAC_CFG_RMAC_STRIP_PAD);=0A=
+	writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);=0A=
+	writel((u32) (val64), add);=0A=
+	writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);=0A=
+	writel((u32) (val64 >> 32), (add + 4));=0A=
+	val64 =3D readq(&bar0->mac_cfg);=0A=
+=0A=
+	return SUCCESS;=0A=
+}=0A=
+=0A=
+/*  =0A=
+ *  Input Arguments: =0A=
+ *  device private variable,=0A=
+ *  A mask indicating which Intr block must be modified and,=0A=
+ *  A flag indicating whether to enable or disable the Intrs.=0A=
+ *  Return Value: =0A=
+ *  NONE.=0A=
+ *  Description: =0A=
+ *  This function will either disable or enable the interrupts =0A=
+ *  depending on the flag argument. The mask argument can be used to =0A=
+ *  enable/disable any Intr block. =0A=
+ */=0A=
+static void en_dis_able_NicIntrs(struct s2io_nic *nic, u16 mask, int =
flag)=0A=
+{=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;=0A=
+	register u64 val64 =3D 0, temp64 =3D 0;=0A=
+=0A=
+	/*  Top level interrupt classification */=0A=
+	/*  PIC Interrupts */=0A=
+	if ((mask & (TX_PIC_INTR | RX_PIC_INTR))) {=0A=
+		/*  Enable PIC Intrs in the general intr mask register */=0A=
+		val64 =3D TXPIC_INT_M | PIC_RX_INT_M;=0A=
+		if (flag =3D=3D ENABLE_INTRS) {=0A=
+			temp64 =3D readq(&bar0->general_int_mask);=0A=
+			temp64 &=3D ~((u64) val64);=0A=
+			writeq(temp64, &bar0->general_int_mask);=0A=
+			/*  Disabled all PCIX, Flash, MDIO, IIC and GPIO=0A=
+			 *  interrupts for now. =0A=
+			 * TODO */=0A=
+			writeq(DISABLE_ALL_INTRS, &bar0->pic_int_mask);=0A=
+			/*  No MSI Support is available presently, so TTI and=0A=
+			 * RTI interrupts are also disabled.=0A=
+			 */=0A=
+		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
+			/*  Disable PIC Intrs in the general intr mask register =0A=
+			 */=0A=
+			writeq(DISABLE_ALL_INTRS, &bar0->pic_int_mask);=0A=
+			temp64 =3D readq(&bar0->general_int_mask);=0A=
+			val64 |=3D temp64;=0A=
+			writeq(val64, &bar0->general_int_mask);=0A=
+		}=0A=
+	}=0A=
+=0A=
+	/*  DMA Interrupts */=0A=
+	/*  Enabling/Disabling Tx DMA interrupts */=0A=
+	if (mask & TX_DMA_INTR) {=0A=
+		/*  Enable TxDMA Intrs in the general intr mask register */=0A=
+		val64 =3D TXDMA_INT_M;=0A=
+		if (flag =3D=3D ENABLE_INTRS) {=0A=
+			temp64 =3D readq(&bar0->general_int_mask);=0A=
+			temp64 &=3D ~((u64) val64);=0A=
+			writeq(temp64, &bar0->general_int_mask);=0A=
+			/* Disable all interrupts other than PFC interrupt in =0A=
+			 * DMA level.=0A=
+			 */=0A=
+			val64 =3D DISABLE_ALL_INTRS & (~TXDMA_PFC_INT_M);=0A=
+			writeq(val64, &bar0->txdma_int_mask);=0A=
+			/* Enable only the MISC error 1 interrupt in PFC block =0A=
+			 */=0A=
+			val64 =3D DISABLE_ALL_INTRS & (~PFC_MISC_ERR_1);=0A=
+			writeq(val64, &bar0->pfc_err_mask);=0A=
+		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
+			/*  Disable TxDMA Intrs in the general intr mask =0A=
+			 *  register */=0A=
+			writeq(DISABLE_ALL_INTRS, &bar0->txdma_int_mask);=0A=
+			writeq(DISABLE_ALL_INTRS, &bar0->pfc_err_mask);=0A=
+			temp64 =3D readq(&bar0->general_int_mask);=0A=
+			val64 |=3D temp64;=0A=
+			writeq(val64, &bar0->general_int_mask);=0A=
+		}=0A=
+	}=0A=
+=0A=
+	/*  Enabling/Disabling Rx DMA interrupts */=0A=
+	if (mask & RX_DMA_INTR) {=0A=
+		/*  Enable RxDMA Intrs in the general intr mask register */=0A=
+		val64 =3D RXDMA_INT_M;=0A=
+		if (flag =3D=3D ENABLE_INTRS) {=0A=
+			temp64 =3D readq(&bar0->general_int_mask);=0A=
+			temp64 &=3D ~((u64) val64);=0A=
+			writeq(temp64, &bar0->general_int_mask);=0A=
+			/* All RxDMA block interrupts are disabled for now =0A=
+			 * TODO */=0A=
+			writeq(DISABLE_ALL_INTRS, &bar0->rxdma_int_mask);=0A=
+		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
+			/*  Disable RxDMA Intrs in the general intr mask =0A=
+			 *  register */=0A=
+			writeq(DISABLE_ALL_INTRS, &bar0->rxdma_int_mask);=0A=
+			temp64 =3D readq(&bar0->general_int_mask);=0A=
+			val64 |=3D temp64;=0A=
+			writeq(val64, &bar0->general_int_mask);=0A=
+		}=0A=
+	}=0A=
+=0A=
+	/*  MAC Interrupts */=0A=
+	/*  Enabling/Disabling MAC interrupts */=0A=
+	if (mask & (TX_MAC_INTR | RX_MAC_INTR)) {=0A=
+		val64 =3D TXMAC_INT_M | RXMAC_INT_M;=0A=
+		if (flag =3D=3D ENABLE_INTRS) {=0A=
+			temp64 =3D readq(&bar0->general_int_mask);=0A=
+			temp64 &=3D ~((u64) val64);=0A=
+			writeq(temp64, &bar0->general_int_mask);=0A=
+			/* All MAC block error interrupts are disabled for now =0A=
+			 * except the link status change interrupt.=0A=
+			 * TODO*/=0A=
+			val64 =3D MAC_INT_STATUS_RMAC_INT;=0A=
+			temp64 =3D readq(&bar0->mac_int_mask);=0A=
+			temp64 &=3D ~((u64) val64);=0A=
+			writeq(temp64, &bar0->mac_int_mask);=0A=
+=0A=
+			val64 =3D readq(&bar0->mac_rmac_err_mask);=0A=
+			val64 &=3D ~((u64) RMAC_LINK_STATE_CHANGE_INT);=0A=
+			writeq(val64, &bar0->mac_rmac_err_mask);=0A=
+		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
+			/*  Disable MAC Intrs in the general intr mask register =0A=
+			 */=0A=
+			writeq(DISABLE_ALL_INTRS, &bar0->mac_int_mask);=0A=
+			writeq(DISABLE_ALL_INTRS,=0A=
+			       &bar0->mac_rmac_err_mask);=0A=
+=0A=
+			temp64 =3D readq(&bar0->general_int_mask);=0A=
+			val64 |=3D temp64;=0A=
+			writeq(val64, &bar0->general_int_mask);=0A=
+		}=0A=
+	}=0A=
+=0A=
+	/*  XGXS Interrupts */=0A=
+	if (mask & (TX_XGXS_INTR | RX_XGXS_INTR)) {=0A=
+		val64 =3D TXXGXS_INT_M | RXXGXS_INT_M;=0A=
+		if (flag =3D=3D ENABLE_INTRS) {=0A=
+			temp64 =3D readq(&bar0->general_int_mask);=0A=
+			temp64 &=3D ~((u64) val64);=0A=
+			writeq(temp64, &bar0->general_int_mask);=0A=
+			/* All XGXS block error interrupts are disabled for now=0A=
+			 *  TODO */=0A=
+			writeq(DISABLE_ALL_INTRS, &bar0->xgxs_int_mask);=0A=
+		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
+			/*  Disable MC Intrs in the general intr mask register =0A=
+			 */=0A=
+			writeq(DISABLE_ALL_INTRS, &bar0->xgxs_int_mask);=0A=
+			temp64 =3D readq(&bar0->general_int_mask);=0A=
+			val64 |=3D temp64;=0A=
+			writeq(val64, &bar0->general_int_mask);=0A=
+		}=0A=
+	}=0A=
+=0A=
+	/*  Memory Controller(MC) interrupts */=0A=
+	if (mask & MC_INTR) {=0A=
+		val64 =3D MC_INT_M;=0A=
+		if (flag =3D=3D ENABLE_INTRS) {=0A=
+			temp64 =3D readq(&bar0->general_int_mask);=0A=
+			temp64 &=3D ~((u64) val64);=0A=
+			writeq(temp64, &bar0->general_int_mask);=0A=
+			/* All MC block error interrupts are disabled for now=0A=
+			 * TODO */=0A=
+			writeq(DISABLE_ALL_INTRS, &bar0->mc_int_mask);=0A=
+		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
+			/*  Disable MC Intrs in the general intr mask register=0A=
+			 */=0A=
+			writeq(DISABLE_ALL_INTRS, &bar0->mc_int_mask);=0A=
+			temp64 =3D readq(&bar0->general_int_mask);=0A=
+			val64 |=3D temp64;=0A=
+			writeq(val64, &bar0->general_int_mask);=0A=
+		}=0A=
+	}=0A=
+=0A=
+=0A=
+	/*  Tx traffic interrupts */=0A=
+	if (mask & TX_TRAFFIC_INTR) {=0A=
+		val64 =3D TXTRAFFIC_INT_M;=0A=
+		if (flag =3D=3D ENABLE_INTRS) {=0A=
+			temp64 =3D readq(&bar0->general_int_mask);=0A=
+			temp64 &=3D ~((u64) val64);=0A=
+			writeq(temp64, &bar0->general_int_mask);=0A=
+			/* Enable all the Tx side interrupts */=0A=
+			writeq(0x0, &bar0->tx_traffic_mask);	/* '0' Enables =0A=
+								 * all 64 TX =0A=
+								 * interrupt =0A=
+								 * levels.=0A=
+								 */=0A=
+		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
+			/*  Disable Tx Traffic Intrs in the general intr mask =0A=
+			 *  register.=0A=
+			 */=0A=
+			writeq(DISABLE_ALL_INTRS, &bar0->tx_traffic_mask);=0A=
+			temp64 =3D readq(&bar0->general_int_mask);=0A=
+			val64 |=3D temp64;=0A=
+			writeq(val64, &bar0->general_int_mask);=0A=
+		}=0A=
+	}=0A=
+=0A=
+	/*  Rx traffic interrupts */=0A=
+	if (mask & RX_TRAFFIC_INTR) {=0A=
+		val64 =3D RXTRAFFIC_INT_M;=0A=
+		if (flag =3D=3D ENABLE_INTRS) {=0A=
+			temp64 =3D readq(&bar0->general_int_mask);=0A=
+			temp64 &=3D ~((u64) val64);=0A=
+			writeq(temp64, &bar0->general_int_mask);=0A=
+			writeq(0x0, &bar0->rx_traffic_mask);	/* '0' Enables =0A=
+								 * all 8 RX =0A=
+								 * interrupt =0A=
+								 * levels.=0A=
+								 */=0A=
+		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
+			/*  Disable Rx Traffic Intrs in the general intr mask =0A=
+			 *  register.=0A=
+			 */=0A=
+			writeq(DISABLE_ALL_INTRS, &bar0->rx_traffic_mask);=0A=
+			temp64 =3D readq(&bar0->general_int_mask);=0A=
+			val64 |=3D temp64;=0A=
+			writeq(val64, &bar0->general_int_mask);=0A=
+		}=0A=
+	}=0A=
+}=0A=
+=0A=
+/*  =0A=
+ *  Input Arguments: =0A=
+ *   val64 - Value read from adapter status register.=0A=
+ *   flag - indicates if the adapter enable bit was ever written once =
before.=0A=
+ *  Return Value: =0A=
+ *   void.=0A=
+ *  Description: =0A=
+ *   Returns whether the H/W is ready to go or not. Depending on =
whether =0A=
+ *   adapter enable bit was written or not the comparison differs and =
the =0A=
+ *   calling function passes the input argument flag to indicate this.=0A=
+ */=0A=
+static int verify_xena_quiescence(u64 val64, int flag)=0A=
+{=0A=
+	int ret =3D 0;=0A=
+	u64 tmp64 =3D ~((u64) val64);=0A=
+=0A=
+	if (!=0A=
+	    (tmp64 &=0A=
+	     (ADAPTER_STATUS_TDMA_READY | ADAPTER_STATUS_RDMA_READY |=0A=
+	      ADAPTER_STATUS_PFC_READY | ADAPTER_STATUS_TMAC_BUF_EMPTY |=0A=
+	      ADAPTER_STATUS_PIC_QUIESCENT | ADAPTER_STATUS_MC_DRAM_READY |=0A=
+	      ADAPTER_STATUS_MC_QUEUES_READY | ADAPTER_STATUS_M_PLL_LOCK |=0A=
+	      ADAPTER_STATUS_P_PLL_LOCK))) {=0A=
+		if (flag =3D=3D FALSE) {=0A=
+			if (!(val64 & ADAPTER_STATUS_RMAC_PCC_IDLE) &&=0A=
+			    ((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) =3D=3D=0A=
+			     ADAPTER_STATUS_RC_PRC_QUIESCENT)) {=0A=
+=0A=
+				ret =3D 1;=0A=
+=0A=
+			}=0A=
+		} else {=0A=
+			if (((val64 & ADAPTER_STATUS_RMAC_PCC_IDLE) =3D=3D=0A=
+			     ADAPTER_STATUS_RMAC_PCC_IDLE) &&=0A=
+			    (!(val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ||=0A=
+			     ((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) =3D=3D=0A=
+			      ADAPTER_STATUS_RC_PRC_QUIESCENT))) {=0A=
+=0A=
+				ret =3D 1;=0A=
+=0A=
+			}=0A=
+		}=0A=
+	}=0A=
+=0A=
+	return ret;=0A=
+}=0A=
+=0A=
+/* =0A=
+ * New procedure to clear mac address reading  problems on Alpha =
platforms=0A=
+ *=0A=
+ */=0A=
+void FixMacAddress(nic_t * sp)=0A=
+{=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+	u64 val64;=0A=
+	int i =3D 0;=0A=
+=0A=
+	while (fix_mac[i] !=3D END_SIGN) {=0A=
+		writeq(fix_mac[i++], &bar0->gpio_control);=0A=
+		val64 =3D readq(&bar0->gpio_control);=0A=
+	}=0A=
+}=0A=
+=0A=
+/*  =0A=
+ *  Input Arguments: =0A=
+ *  device private variable.=0A=
+ *  Return Value: =0A=
+ *  SUCCESS on success and -1 on failure.=0A=
+ *  Description: =0A=
+ *  This function actually turns the device on. Before this =0A=
+ *  function is called, all Registers are configured from their reset =
states =0A=
+ *  and shared memory is allocated but the NIC is still quiescent. On =0A=
+ *  calling this function, the device interrupts are cleared and the =
NIC is=0A=
+ *  literally switched on by writing into the adapter control register.=0A=
+ */=0A=
+static int startNic(struct s2io_nic *nic)=0A=
+{=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;=0A=
+	struct net_device *dev =3D nic->dev;=0A=
+	register u64 val64 =3D 0;=0A=
+	u16 interruptible, i;=0A=
+	u16 subid;=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+=0A=
+	mac_control =3D &nic->mac_control;=0A=
+	config =3D &nic->config;=0A=
+=0A=
+	/*  PRC Initialization and configuration */=0A=
+	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
+		writeq((u64) nic->rx_blocks[i][0].block_dma_addr,=0A=
+		       &bar0->prc_rxd0_n[i]);=0A=
+=0A=
+		val64 =3D readq(&bar0->prc_ctrl_n[i]);=0A=
+		val64 |=3D PRC_CTRL_RC_ENABLED;=0A=
+		writeq(val64, &bar0->prc_ctrl_n[i]);=0A=
+	}=0A=
+=0A=
+	/* Enabling MC-RLDRAM. After enabling the device, we timeout=0A=
+	 * for around 100ms, which is approximately the time required=0A=
+	 * for the device to be ready for operation.=0A=
+	 */=0A=
+	val64 =3D readq(&bar0->mc_rldram_mrs);=0A=
+	val64 |=3D MC_RLDRAM_QUEUE_SIZE_ENABLE | MC_RLDRAM_MRS_ENABLE;=0A=
+	writeq(val64, &bar0->mc_rldram_mrs);=0A=
+	val64 =3D readq(&bar0->mc_rldram_mrs);=0A=
+=0A=
+	set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+	schedule_timeout(HZ / 10);	/* Delay by around 100 ms. */=0A=
+=0A=
+	/* Enabling ECC Protection. */=0A=
+	val64 =3D readq(&bar0->adapter_control);=0A=
+	val64 &=3D ~ADAPTER_ECC_EN;=0A=
+	writeq(val64, &bar0->adapter_control);=0A=
+=0A=
+	/* Clearing any possible Link state change interrupts that =0A=
+	 * could have popped up just before Enabling the card.=0A=
+	 */=0A=
+	val64 =3D readq(&bar0->mac_rmac_err_reg);=0A=
+	if (val64)=0A=
+		writeq(val64, &bar0->mac_rmac_err_reg);=0A=
+=0A=
+	/* Verify if the device is ready to be enabled, if so enable =0A=
+	 * it.=0A=
+	 */=0A=
+	val64 =3D readq(&bar0->adapter_status);=0A=
+	if (!verify_xena_quiescence(val64, nic->device_enabled_once)) {=0A=
+		DBG_PRINT(ERR_DBG, "%s: device is not ready, ", dev->name);=0A=
+		DBG_PRINT(ERR_DBG, "Adapter status reads: 0x%llx\n",=0A=
+			  (unsigned long long) val64);=0A=
+		return FAILURE;=0A=
+	}=0A=
+=0A=
+	/*  Enable select interrupts */=0A=
+	interruptible =3D TX_TRAFFIC_INTR | RX_TRAFFIC_INTR | TX_MAC_INTR |=0A=
+	    RX_MAC_INTR;=0A=
+	en_dis_able_NicIntrs(nic, interruptible, ENABLE_INTRS);=0A=
+=0A=
+	/* With some switches, link might be already up at this point.=0A=
+	 * Because of this weird behavior, when we enable laser, =0A=
+	 * we may not get link. We need to handle this. We cannot =0A=
+	 * figure out which switch is misbehaving. So we are forced to =0A=
+	 * make a global change. =0A=
+	 */=0A=
+=0A=
+	/* Enabling Laser. */=0A=
+	val64 =3D readq(&bar0->adapter_control);=0A=
+	val64 |=3D ADAPTER_EOI_TX_ON;=0A=
+	writeq(val64, &bar0->adapter_control);=0A=
+=0A=
+	/* SXE-002: Initialize link and activity LED */=0A=
+	subid =3D nic->pdev->subsystem_device;=0A=
+	if ((subid & 0xFF) >=3D 0x07) {=0A=
+		val64 =3D readq(&bar0->gpio_control);=0A=
+		val64 |=3D 0x0000800000000000ULL;=0A=
+		writeq(val64, &bar0->gpio_control);=0A=
+		val64 =3D 0x0411040400000000ULL;=0A=
+		writeq(val64, (void *) ((u8 *) bar0 + 0x2700));=0A=
+	}=0A=
+=0A=
+	/* =0A=
+	 * Here we are performing soft reset on XGXS to =0A=
+	 * force link down. Since link is already up, we will get=0A=
+	 * link state change interrupt after this reset=0A=
+	 */=0A=
+	writeq(0x8007051500000000ULL, &bar0->dtx_control);=0A=
+	val64 =3D readq(&bar0->dtx_control);=0A=
+	writeq(0x80070515000000E0ULL, &bar0->dtx_control);=0A=
+	val64 =3D readq(&bar0->dtx_control);=0A=
+	writeq(0x80070515001F00E4ULL, &bar0->dtx_control);=0A=
+	val64 =3D readq(&bar0->dtx_control);=0A=
+=0A=
+	return SUCCESS;=0A=
+}=0A=
+=0A=
+/*  =0A=
+ *  Input Arguments: =0A=
+ *   nic - device private variable.=0A=
+ *  Return Value: =0A=
+ *   void.=0A=
+ *  Description: =0A=
+ *   Free all queued Tx buffers.=0A=
+ */=0A=
+void freeTxBuffers(struct s2io_nic *nic)=0A=
+{=0A=
+	struct net_device *dev =3D nic->dev;=0A=
+	struct sk_buff *skb;=0A=
+	TxD_t *txdp;=0A=
+	int i, j;=0A=
+#if DEBUG_ON=0A=
+	int cnt =3D 0;=0A=
+#endif=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+=0A=
+	mac_control =3D &nic->mac_control;=0A=
+	config =3D &nic->config;=0A=
+=0A=
+	for (i =3D 0; i < config->TxFIFONum; i++) {=0A=
+		for (j =3D 0; j < config->TxCfg[i].FifoLen - 1; j++) {=0A=
+			txdp =3D mac_control->txdl_start[i] +=0A=
+			    (config->MaxTxDs * j);=0A=
+=0A=
+			if (!(txdp->Control_1 & TXD_LIST_OWN_XENA)) {=0A=
+				/* If owned by host, ignore */=0A=
+				continue;=0A=
+			}=0A=
+			skb =3D=0A=
+			    (struct sk_buff *) ((unsigned long) txdp->=0A=
+						Host_Control);=0A=
+			if (skb =3D=3D NULL) {=0A=
+				DBG_PRINT(ERR_DBG, "%s: NULL skb ",=0A=
+					  dev->name);=0A=
+				DBG_PRINT(ERR_DBG, "in Tx Int\n");=0A=
+				return;=0A=
+			}=0A=
+#if DEBUG_ON=0A=
+			cnt++;=0A=
+#endif=0A=
+			dev_kfree_skb(skb);=0A=
+			memset(txdp, 0, sizeof(TxD_t));=0A=
+		}=0A=
+#if DEBUG_ON=0A=
+		DBG_PRINT(INTR_DBG,=0A=
+			  "%s:forcibly freeing %d skbs on FIFO%d\n",=0A=
+			  dev->name, cnt, i);=0A=
+#endif=0A=
+	}=0A=
+}=0A=
+=0A=
+/*  =0A=
+ *  Input Arguments: =0A=
+ *   nic - device private variable.=0A=
+ *  Return Value: =0A=
+ *   void.=0A=
+ *  Description: =0A=
+ *   This function does exactly the opposite of what the startNic() =0A=
+ *   function does. This function is called to stop =0A=
+ *   the device.=0A=
+ */=0A=
+static void stopNic(struct s2io_nic *nic)=0A=
+{=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;=0A=
+	register u64 val64 =3D 0;=0A=
+	u16 interruptible, i;=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+=0A=
+	mac_control =3D &nic->mac_control;=0A=
+	config =3D &nic->config;=0A=
+=0A=
+/*  Disable all interrupts */=0A=
+	interruptible =3D TX_TRAFFIC_INTR | RX_TRAFFIC_INTR | TX_MAC_INTR |=0A=
+	    RX_MAC_INTR;=0A=
+	en_dis_able_NicIntrs(nic, interruptible, DISABLE_INTRS);=0A=
+=0A=
+/*  Disable PRCs */=0A=
+	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
+		val64 =3D readq(&bar0->prc_ctrl_n[i]);=0A=
+		val64 &=3D ~((u64) PRC_CTRL_RC_ENABLED);=0A=
+		writeq(val64, &bar0->prc_ctrl_n[i]);=0A=
+	}=0A=
+}=0A=
+=0A=
+/*  =0A=
+ *  Input Arguments: =0A=
+ *  device private variable=0A=
+ *  Return Value: =0A=
+ *  SUCCESS on success or an appropriate -ve value on failure.=0A=
+ *  Description: =0A=
+ *  The function allocates Rx side skbs and puts the physical=0A=
+ *  address of these buffers into the RxD buffer pointers, so that the =
NIC=0A=
+ *  can DMA the received frame into these locations.=0A=
+ *  The NIC supports 3 receive modes, viz=0A=
+ *  1. single buffer,=0A=
+ *  2. three buffer and=0A=
+ *  3. Five buffer modes.=0A=
+ *  Each mode defines how many fragments the received frame will be =
split =0A=
+ *  up into by the NIC. The frame is split into L3 header, L4 Header, =0A=
+ *  L4 payload in three buffer mode and in 5 buffer mode, L4 payload =
itself =0A=
+ *  is split into 3 fragments. As of now only single buffer mode is =
supported.=0A=
+ */=0A=
+int fill_rx_buffers(struct s2io_nic *nic, int ring_no)=0A=
+{=0A=
+	struct net_device *dev =3D nic->dev;=0A=
+	struct sk_buff *skb;=0A=
+	RxD_t *rxdp;=0A=
+	int off, off1, size, block_no, block_no1;=0A=
+	int offset, offset1;=0A=
+	u32 alloc_tab =3D 0;=0A=
+	u32 alloc_cnt =3D nic->pkt_cnt[ring_no] -=0A=
+	    atomic_read(&nic->rx_bufs_left[ring_no]);=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+=0A=
+	mac_control =3D &nic->mac_control;=0A=
+	config =3D &nic->config;=0A=
+=0A=
+	if (frame_len[ring_no]) {=0A=
+		if (frame_len[ring_no] > dev->mtu)=0A=
+			dev->mtu =3D frame_len[ring_no];=0A=
+		size =3D frame_len[ring_no] + HEADER_ETHERNET_II_802_3_SIZE +=0A=
+		    HEADER_802_2_SIZE + HEADER_SNAP_SIZE;=0A=
+	} else {=0A=
+		size =3D dev->mtu + HEADER_ETHERNET_II_802_3_SIZE +=0A=
+		    HEADER_802_2_SIZE + HEADER_SNAP_SIZE;=0A=
+	}=0A=
+=0A=
+	while (alloc_tab < alloc_cnt) {=0A=
+		block_no =3D mac_control->rx_curr_put_info[ring_no].=0A=
+		    block_index;=0A=
+		block_no1 =3D mac_control->rx_curr_get_info[ring_no].=0A=
+		    block_index;=0A=
+		off =3D mac_control->rx_curr_put_info[ring_no].offset;=0A=
+		off1 =3D mac_control->rx_curr_get_info[ring_no].offset;=0A=
+		offset =3D block_no * (MAX_RXDS_PER_BLOCK + 1) + off;=0A=
+		offset1 =3D block_no1 * (MAX_RXDS_PER_BLOCK + 1) + off1;=0A=
+=0A=
+		rxdp =3D nic->rx_blocks[ring_no][block_no].=0A=
+		    block_virt_addr + off;=0A=
+		if ((offset =3D=3D offset1) && (rxdp->Host_Control)) {=0A=
+			DBG_PRINT(INTR_DBG, "%s: Get and Put", dev->name);=0A=
+			DBG_PRINT(INTR_DBG, " info equated\n");=0A=
+			goto end;=0A=
+		}=0A=
+=0A=
+		if (rxdp->Control_1 =3D=3D END_OF_BLOCK) {=0A=
+			mac_control->rx_curr_put_info[ring_no].=0A=
+			    block_index++;=0A=
+			mac_control->rx_curr_put_info[ring_no].=0A=
+			    block_index %=3D nic->block_count[ring_no];=0A=
+			block_no =3D mac_control->rx_curr_put_info=0A=
+			    [ring_no].block_index;=0A=
+			off++;=0A=
+			off %=3D (MAX_RXDS_PER_BLOCK + 1);=0A=
+			mac_control->rx_curr_put_info[ring_no].offset =3D=0A=
+			    off;=0A=
+			/*rxdp =3D nic->rx_blocks[ring_no][block_no].=0A=
+			   block_virt_addr + off; */=0A=
+			rxdp =3D (RxD_t *) ((unsigned long) rxdp->Control_2);=0A=
+			DBG_PRINT(INTR_DBG, "%s: Next block at: %p\n",=0A=
+				  dev->name, rxdp);=0A=
+		}=0A=
+=0A=
+		if (rxdp->Control_1 & RXD_OWN_XENA) {=0A=
+			mac_control->rx_curr_put_info[ring_no].=0A=
+			    offset =3D off;=0A=
+			goto end;=0A=
+		}=0A=
+=0A=
+		skb =3D dev_alloc_skb(size + HEADER_ALIGN_LAYER_3);=0A=
+		if (!skb) {=0A=
+			DBG_PRINT(ERR_DBG, "%s: Out of ", dev->name);=0A=
+			DBG_PRINT(ERR_DBG, "memory to allocate SKBs\n");=0A=
+			return -ENOMEM;=0A=
+		}=0A=
+		skb_reserve(skb, HEADER_ALIGN_LAYER_3);=0A=
+		memset(rxdp, 0, sizeof(RxD_t));=0A=
+		rxdp->Buffer0_ptr =3D pci_map_single=0A=
+		    (nic->pdev, skb->data, size, PCI_DMA_FROMDEVICE);=0A=
+		rxdp->Control_2 &=3D (~MASK_BUFFER0_SIZE);=0A=
+		rxdp->Control_2 |=3D SET_BUFFER0_SIZE(size);=0A=
+		rxdp->Host_Control =3D (unsigned long) (skb);=0A=
+		rxdp->Control_1 |=3D RXD_OWN_XENA;=0A=
+		off++;=0A=
+		off %=3D (MAX_RXDS_PER_BLOCK + 1);=0A=
+		mac_control->rx_curr_put_info[ring_no].offset =3D off;=0A=
+		atomic_inc(&nic->rx_bufs_left[ring_no]);=0A=
+		alloc_tab++;=0A=
+	}=0A=
+=0A=
+      end:=0A=
+	return SUCCESS;=0A=
+}=0A=
+=0A=
+/*  =0A=
+ *  Input Arguments: =0A=
+ *  device private variable.=0A=
+ *  Return Value: =0A=
+ *  NONE.=0A=
+ *  Description: =0A=
+ *  This function will free all Rx buffers allocated by host.=0A=
+ */=0A=
+static void freeRxBuffers(struct s2io_nic *sp)=0A=
+{=0A=
+	struct net_device *dev =3D sp->dev;=0A=
+	int i, j, blk =3D 0, off, buf_cnt =3D 0;=0A=
+	RxD_t *rxdp;=0A=
+	struct sk_buff *skb;=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+=0A=
+	mac_control =3D &sp->mac_control;=0A=
+	config =3D &sp->config;=0A=
+=0A=
+	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
+		for (j =3D 0, blk =3D 0; j < config->RxCfg[i].NumRxd; j++) {=0A=
+			off =3D j % (MAX_RXDS_PER_BLOCK + 1);=0A=
+			rxdp =3D sp->rx_blocks[i][blk].block_virt_addr + off;=0A=
+=0A=
+			if (rxdp->Control_1 =3D=3D END_OF_BLOCK) {=0A=
+				rxdp =3D=0A=
+				    (RxD_t *) ((unsigned long) rxdp->=0A=
+					       Control_2);=0A=
+				j++;=0A=
+				blk++;=0A=
+			}=0A=
+=0A=
+			skb =3D=0A=
+			    (struct sk_buff *) ((unsigned long) rxdp->=0A=
+						Host_Control);=0A=
+			if (skb) {=0A=
+				pci_unmap_single(sp->pdev, (dma_addr_t)=0A=
+						 rxdp->Buffer0_ptr,=0A=
+						 dev->mtu +=0A=
+						 HEADER_ETHERNET_II_802_3_SIZE=0A=
+						 + HEADER_802_2_SIZE +=0A=
+						 HEADER_SNAP_SIZE,=0A=
+						 PCI_DMA_FROMDEVICE);=0A=
+				dev_kfree_skb(skb);=0A=
+				atomic_dec(&sp->rx_bufs_left[i]);=0A=
+				buf_cnt++;=0A=
+			}=0A=
+			memset(rxdp, 0, sizeof(RxD_t));=0A=
+		}=0A=
+		mac_control->rx_curr_put_info[i].block_index =3D 0;=0A=
+		mac_control->rx_curr_get_info[i].block_index =3D 0;=0A=
+		mac_control->rx_curr_put_info[i].offset =3D 0;=0A=
+		mac_control->rx_curr_get_info[i].offset =3D 0;=0A=
+		atomic_set(&sp->rx_bufs_left[i], 0);=0A=
+		DBG_PRINT(INIT_DBG, "%s:Freed 0x%x Rx Buffers on ring%d\n",=0A=
+			  dev->name, buf_cnt, i);=0A=
+	}=0A=
+}=0A=
+=0A=
+/*=0A=
+ *  Input Argument: =0A=
+ *   dev - pointer to the device structure.=0A=
+ *   budget - The number of packets that were budgeted to be processed =
during=0A=
+ *   one pass through the 'Poll" function.=0A=
+ *  Return value:=0A=
+ *   0 on success and 1 if there are No Rx packets to be processed.=0A=
+ *  Description:=0A=
+ *   Comes into picture only if NAPI support has been incorporated. It =
does=0A=
+ *   the same thing that rxIntrHandler does, but not in a interrupt =
context=0A=
+ *   also It will process only a given number of packets.=0A=
+ */=0A=
+#ifdef CONFIG_S2IO_NAPI=0A=
+static int s2io_poll(struct net_device *dev, int *budget)=0A=
+{=0A=
+	nic_t *nic =3D dev->priv;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;=0A=
+	int pkts_to_process =3D *budget, pkt_cnt =3D 0;=0A=
+	register u64 val64 =3D 0;=0A=
+	rx_curr_get_info_t offset_info;=0A=
+	int i, block_no;=0A=
+	u16 val16, cksum;=0A=
+	struct sk_buff *skb;=0A=
+	RxD_t *rxdp;=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+=0A=
+	mac_control =3D &nic->mac_control;=0A=
+	config =3D &nic->config;=0A=
+=0A=
+	if (pkts_to_process > dev->quota)=0A=
+		pkts_to_process =3D dev->quota;=0A=
+=0A=
+	val64 =3D readq(&bar0->rx_traffic_int);=0A=
+	writeq(val64, &bar0->rx_traffic_int);=0A=
+=0A=
+	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
+		if (--pkts_to_process < 0) {=0A=
+			goto no_rx;=0A=
+		}=0A=
+		offset_info =3D mac_control->rx_curr_get_info[i];=0A=
+		block_no =3D offset_info.block_index;=0A=
+		rxdp =3D nic->rx_blocks[i][block_no].block_virt_addr +=0A=
+		    offset_info.offset;=0A=
+		while (!(rxdp->Control_1 & RXD_OWN_XENA)) {=0A=
+			if (rxdp->Control_1 =3D=3D END_OF_BLOCK) {=0A=
+				rxdp =3D=0A=
+				    (RxD_t *) ((unsigned long) rxdp->=0A=
+					       Control_2);=0A=
+				offset_info.offset++;=0A=
+				offset_info.offset %=3D=0A=
+				    (MAX_RXDS_PER_BLOCK + 1);=0A=
+				block_no++;=0A=
+				block_no %=3D nic->block_count[i];=0A=
+				mac_control->rx_curr_get_info[i].=0A=
+				    offset =3D offset_info.offset;=0A=
+				mac_control->rx_curr_get_info[i].=0A=
+				    block_index =3D block_no;=0A=
+				continue;=0A=
+			}=0A=
+			skb =3D=0A=
+			    (struct sk_buff *) ((unsigned long) rxdp->=0A=
+						Host_Control);=0A=
+			if (skb =3D=3D NULL) {=0A=
+				DBG_PRINT(ERR_DBG, "%s: The skb is ",=0A=
+					  dev->name);=0A=
+				DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");=0A=
+				return 0;=0A=
+			}=0A=
+			val64 =3D RXD_GET_BUFFER0_SIZE(rxdp->Control_2);=0A=
+			val16 =3D (u16) (val64 >> 48);=0A=
+			cksum =3D RXD_GET_L4_CKSUM(rxdp->Control_1);=0A=
+			pci_unmap_single(nic->pdev, (dma_addr_t)=0A=
+					 rxdp->Buffer0_ptr,=0A=
+					 dev->mtu +=0A=
+					 HEADER_ETHERNET_II_802_3_SIZE +=0A=
+					 HEADER_802_2_SIZE +=0A=
+					 HEADER_SNAP_SIZE,=0A=
+					 PCI_DMA_FROMDEVICE);=0A=
+			rxOsmHandler(nic, val16, rxdp, i);=0A=
+			pkt_cnt++;=0A=
+			offset_info.offset++;=0A=
+			offset_info.offset %=3D (MAX_RXDS_PER_BLOCK + 1);=0A=
+			rxdp =3D=0A=
+			    nic->rx_blocks[i][block_no].block_virt_addr +=0A=
+			    offset_info.offset;=0A=
+			mac_control->rx_curr_get_info[i].offset =3D=0A=
+			    offset_info.offset;=0A=
+		}=0A=
+	}=0A=
+	if (!pkt_cnt)=0A=
+		pkt_cnt =3D 1;=0A=
+=0A=
+	for (i =3D 0; i < config->RxRingNum; i++)=0A=
+		fill_rx_buffers(nic, i);=0A=
+=0A=
+	dev->quota -=3D pkt_cnt;=0A=
+	*budget -=3D pkt_cnt;=0A=
+	netif_rx_complete(dev);=0A=
+=0A=
+/* Re enable the Rx interrupts. */=0A=
+	en_dis_able_NicIntrs(nic, RX_TRAFFIC_INTR, ENABLE_INTRS);=0A=
+	return 0;=0A=
+=0A=
+      no_rx:=0A=
+	for (i =3D 0; i < config->RxRingNum; i++)=0A=
+		fill_rx_buffers(nic, i);=0A=
+	dev->quota -=3D pkt_cnt;=0A=
+	*budget -=3D pkt_cnt;=0A=
+	return 1;=0A=
+}=0A=
+#else=0A=
+/*  =0A=
+ *  Input Arguments: =0A=
+ *  device private variable.=0A=
+ *  Return Value: =0A=
+ *  NONE.=0A=
+ *  Description: =0A=
+ * If the interrupt is because of a received frame or if the =0A=
+ *  receive ring contains fresh as yet un-processed frames, this =
function is=0A=
+ *  called. It picks out the RxD at which place the last Rx processing =
had =0A=
+ *  stopped and sends the skb to the OSM's Rx handler and then =
increments =0A=
+ *  the offset.=0A=
+ */=0A=
+static void rxIntrHandler(struct s2io_nic *nic)=0A=
+{=0A=
+	struct net_device *dev =3D (struct net_device *) nic->dev;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;=0A=
+	rx_curr_get_info_t offset_info;=0A=
+	RxD_t *rxdp;=0A=
+	struct sk_buff *skb;=0A=
+	u16 val16, cksum;=0A=
+	register u64 val64 =3D 0;=0A=
+	int i, block_no;=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+=0A=
+	mac_control =3D &nic->mac_control;=0A=
+	config =3D &nic->config;=0A=
+=0A=
+#if DEBUG_ON=0A=
+	nic->rxint_cnt++;=0A=
+#endif=0A=
+=0A=
+/* rx_traffic_int reg is an R1 register, hence we read and write back =0A=
+ * the samevalue in the register to clear it.=0A=
+ */=0A=
+	val64 =3D readq(&bar0->rx_traffic_int);=0A=
+	writeq(val64, &bar0->rx_traffic_int);=0A=
+=0A=
+	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
+		offset_info =3D mac_control->rx_curr_get_info[i];=0A=
+		block_no =3D offset_info.block_index;=0A=
+		rxdp =3D nic->rx_blocks[i][block_no].block_virt_addr +=0A=
+		    offset_info.offset;=0A=
+		while (!(rxdp->Control_1 & RXD_OWN_XENA)) {=0A=
+			if (rxdp->Control_1 =3D=3D END_OF_BLOCK) {=0A=
+				rxdp =3D (RxD_t *) ((unsigned long)=0A=
+						  rxdp->Control_2);=0A=
+				offset_info.offset++;=0A=
+				offset_info.offset %=3D=0A=
+				    (MAX_RXDS_PER_BLOCK + 1);=0A=
+				block_no++;=0A=
+				block_no %=3D nic->block_count[i];=0A=
+				mac_control->rx_curr_get_info[i].=0A=
+				    offset =3D offset_info.offset;=0A=
+				mac_control->rx_curr_get_info[i].=0A=
+				    block_index =3D block_no;=0A=
+				continue;=0A=
+			}=0A=
+			skb =3D (struct sk_buff *) ((unsigned long)=0A=
+						  rxdp->Host_Control);=0A=
+			if (skb =3D=3D NULL) {=0A=
+				DBG_PRINT(ERR_DBG, "%s: The skb is ",=0A=
+					  dev->name);=0A=
+				DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");=0A=
+				return;=0A=
+			}=0A=
+			val64 =3D RXD_GET_BUFFER0_SIZE(rxdp->Control_2);=0A=
+			val16 =3D (u16) (val64 >> 48);=0A=
+			cksum =3D RXD_GET_L4_CKSUM(rxdp->Control_1);=0A=
+			pci_unmap_single(nic->pdev, (dma_addr_t)=0A=
+					 rxdp->Buffer0_ptr,=0A=
+					 dev->mtu +=0A=
+					 HEADER_ETHERNET_II_802_3_SIZE +=0A=
+					 HEADER_802_2_SIZE +=0A=
+					 HEADER_SNAP_SIZE,=0A=
+					 PCI_DMA_FROMDEVICE);=0A=
+			rxOsmHandler(nic, val16, rxdp, i);=0A=
+			offset_info.offset++;=0A=
+			offset_info.offset %=3D (MAX_RXDS_PER_BLOCK + 1);=0A=
+			rxdp =3D=0A=
+			    nic->rx_blocks[i][block_no].block_virt_addr +=0A=
+			    offset_info.offset;=0A=
+			mac_control->rx_curr_get_info[i].offset =3D=0A=
+			    offset_info.offset;=0A=
+		}=0A=
+	}=0A=
+}=0A=
+#endif=0A=
+=0A=
+/*  =0A=
+ *  Input Arguments: =0A=
+ *  device private variable=0A=
+ *  Return Value: =0A=
+ *  NONE=0A=
+ *  Description: =0A=
+ *  If an interrupt was raised to indicate DMA complete of the =0A=
+ *  Tx packet, this function is called. It identifies the last TxD =
whose buffer=0A=
+ *  was freed and frees all skbs whose data have already DMA'ed into =
the NICs=0A=
+ *  internal memory.=0A=
+ */=0A=
+static void txIntrHandler(struct s2io_nic *nic)=0A=
+{=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;=0A=
+	struct net_device *dev =3D (struct net_device *) nic->dev;=0A=
+	tx_curr_get_info_t offset_info, offset_info1;=0A=
+	struct sk_buff *skb;=0A=
+	TxD_t *txdlp;=0A=
+	register u64 val64 =3D 0;=0A=
+	int i;=0A=
+	u16 j, frg_cnt;=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+#if DEBUG_ON=0A=
+	int cnt =3D 0;=0A=
+	nic->txint_cnt++;=0A=
+#endif=0A=
+=0A=
+	mac_control =3D &nic->mac_control;=0A=
+	config =3D &nic->config;=0A=
+=0A=
+	/* tx_traffic_int reg is an R1 register, hence we read and write =0A=
+	 * back the samevalue in the register to clear it.=0A=
+	 */=0A=
+	val64 =3D readq(&bar0->tx_traffic_int);=0A=
+	writeq(val64, &bar0->tx_traffic_int);=0A=
+=0A=
+	for (i =3D 0; i < config->TxFIFONum; i++) {=0A=
+		offset_info =3D mac_control->tx_curr_get_info[i];=0A=
+		offset_info1 =3D mac_control->tx_curr_put_info[i];=0A=
+		txdlp =3D mac_control->txdl_start[i] +=0A=
+		    (config->MaxTxDs * offset_info.offset);=0A=
+		while ((!(txdlp->Control_1 & TXD_LIST_OWN_XENA)) &&=0A=
+		       (offset_info.offset !=3D offset_info1.offset) &&=0A=
+		       (txdlp->Host_Control)) {=0A=
+			/* Check for TxD errors */=0A=
+			if (txdlp->Control_1 & TXD_T_CODE) {=0A=
+				unsigned long long err;=0A=
+				err =3D txdlp->Control_1 & TXD_T_CODE;=0A=
+				DBG_PRINT(ERR_DBG, "***TxD error %llx\n",=0A=
+					  err);=0A=
+			}=0A=
+=0A=
+			skb =3D (struct sk_buff *) ((unsigned long)=0A=
+						  txdlp->Host_Control);=0A=
+			if (skb =3D=3D NULL) {=0A=
+				DBG_PRINT(ERR_DBG, "%s: Null skb ",=0A=
+					  dev->name);=0A=
+				DBG_PRINT(ERR_DBG, "in Tx Free Intr\n");=0A=
+				return;=0A=
+			}=0A=
+			nic->tx_pkt_count++;=0A=
+=0A=
+			frg_cnt =3D skb_shinfo(skb)->nr_frags;=0A=
+=0A=
+			/*  For unfragmented skb */=0A=
+			pci_unmap_single(nic->pdev, (dma_addr_t)=0A=
+					 txdlp->Buffer_Pointer,=0A=
+					 skb->len - skb->data_len,=0A=
+					 PCI_DMA_TODEVICE);=0A=
+			if (frg_cnt) {=0A=
+				TxD_t *temp =3D txdlp;=0A=
+				txdlp++;=0A=
+				for (j =3D 0; j < frg_cnt; j++, txdlp++) {=0A=
+					skb_frag_t *frag =3D=0A=
+					    &skb_shinfo(skb)->frags[j];=0A=
+					pci_unmap_page(nic->pdev,=0A=
+						       (dma_addr_t)=0A=
+						       txdlp->=0A=
+						       Buffer_Pointer,=0A=
+						       frag->size,=0A=
+						       PCI_DMA_TODEVICE);=0A=
+				}=0A=
+				txdlp =3D temp;=0A=
+			}=0A=
+			memset(txdlp, 0,=0A=
+			       (sizeof(TxD_t) * config->MaxTxDs));=0A=
+=0A=
+			/* Updating the statistics block */=0A=
+			nic->stats.tx_packets++;=0A=
+			nic->stats.tx_bytes +=3D skb->len;=0A=
+#if DEBUG_ON=0A=
+			nic->txpkt_bytes +=3D skb->len;=0A=
+			cnt++;=0A=
+#endif=0A=
+			dev_kfree_skb_irq(skb);=0A=
+=0A=
+			offset_info.offset++;=0A=
+			offset_info.offset %=3D offset_info.fifo_len + 1;=0A=
+			txdlp =3D mac_control->txdl_start[i] +=0A=
+			    (config->MaxTxDs * offset_info.offset);=0A=
+			mac_control->tx_curr_get_info[i].offset =3D=0A=
+			    offset_info.offset;=0A=
+		}=0A=
+#if DEBUG_ON=0A=
+		DBG_PRINT(INTR_DBG, "%s: freed %d Tx Pkts\n", dev->name,=0A=
+			  cnt);=0A=
+#endif=0A=
+	}=0A=
+=0A=
+	spin_lock(&nic->tx_lock);=0A=
+	if (netif_queue_stopped(dev))=0A=
+		netif_wake_queue(dev);=0A=
+	spin_unlock(&nic->tx_lock);=0A=
+}=0A=
+=0A=
+/*  =0A=
+ *  Input Arguments: =0A=
+ *  device private variable=0A=
+ *  Return Value: =0A=
+ *  NONE=0A=
+ *  Description: =0A=
+ *  If the interrupt was neither because of Rx packet or Tx =0A=
+ *  complete, this function is called. If the interrupt was to indicate =
a loss=0A=
+ *  of link, the OSM link status handler is invoked for any other alarm =0A=
+ *  interrupt the block that raised the interrupt is displayed and a =
H/W reset =0A=
+ *  is issued.=0A=
+ */=0A=
+static void alarmIntrHandler(struct s2io_nic *nic)=0A=
+{=0A=
+	struct net_device *dev =3D (struct net_device *) nic->dev;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;=0A=
+	register u64 val64 =3D 0, err_reg =3D 0;=0A=
+=0A=
+=0A=
+	/* Handling link status change error Intr */=0A=
+	err_reg =3D readq(&bar0->mac_rmac_err_reg);=0A=
+	if (err_reg & RMAC_LINK_STATE_CHANGE_INT) {=0A=
+		schedule_work(&nic->set_link_task);=0A=
+	}=0A=
+=0A=
+	/* Handling SERR errors by stopping device Xmit queue and forcing =0A=
+	 * a H/W reset.=0A=
+	 */=0A=
+	val64 =3D readq(&bar0->serr_source);=0A=
+	if (val64 & SERR_SOURCE_ANY) {=0A=
+		DBG_PRINT(ERR_DBG, "%s: Device indicates ", dev->name);=0A=
+		DBG_PRINT(ERR_DBG, "serious error!!\n");=0A=
+		netif_stop_queue(dev);=0A=
+	}=0A=
+/* Other type of interrupts are not being handled now,  TODO*/=0A=
+}=0A=
+=0A=
+/*=0A=
+ *  Input Argument: =0A=
+ *  sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ *  Return value:=0A=
+ *   SUCCESS on success and FAILURE on failure.=0A=
+ *  Description:=0A=
+ *   Function that waits for a command to Write into RMAC ADDR DATA =
registers =0A=
+ *   to be completed and returns either success or error depending on =
whether =0A=
+ *   the command was complete or not. =0A=
+ */=0A=
+int waitForCmdComplete(nic_t * sp)=0A=
+{=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+	int ret =3D FAILURE, cnt =3D 0;=0A=
+	u64 val64;=0A=
+=0A=
+	while (TRUE) {=0A=
+		val64 =3D=0A=
+		    RMAC_ADDR_CMD_MEM_RD | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD=0A=
+		    | RMAC_ADDR_CMD_MEM_OFFSET(0);=0A=
+		writeq(val64, &bar0->rmac_addr_cmd_mem);=0A=
+		val64 =3D readq(&bar0->rmac_addr_cmd_mem);=0A=
+		if (!val64) {=0A=
+			ret =3D SUCCESS;=0A=
+			break;=0A=
+		}=0A=
+		set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+		schedule_timeout(HZ / 20);=0A=
+		if (cnt++ > 10)=0A=
+			break;=0A=
+	}=0A=
+=0A=
+	return ret;=0A=
+}=0A=
+=0A=
+/*=0A=
+ *  Input Argument: =0A=
+ *  sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ *  Return value:=0A=
+ *   void.=0A=
+ *  Description:=0A=
+ *   Function to Reset the card. This function then also restores the =
previously=0A=
+ *   saved PCI configuration space registers as the card reset also =
resets the=0A=
+ *   Configration space.=0A=
+ */=0A=
+void s2io_reset(nic_t * sp)=0A=
+{=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+	u64 val64;=0A=
+	u16 subid;=0A=
+=0A=
+	val64 =3D SW_RESET_ALL;=0A=
+	writeq(val64, &bar0->sw_reset);=0A=
+=0A=
+	/* At this stage, if the PCI write is indeed completed, the =0A=
+	 * card is reset and so is the PCI Config space of the device. =0A=
+	 * So a read cannot be issued at this stage on any of the =0A=
+	 * registers to ensure the write into "sw_reset" register=0A=
+	 * has gone through.=0A=
+	 * Question: Is there any system call that will explicitly force=0A=
+	 * all the write commands still pending on the bus to be pushed=0A=
+	 * through?=0A=
+	 * As of now I'am just giving a 250ms delay and hoping that the=0A=
+	 * PCI write to sw_reset register is done by this time.=0A=
+	 */=0A=
+	set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+	schedule_timeout(HZ / 4);=0A=
+=0A=
+	/* Restore the PCI state saved during initializarion. */=0A=
+	pci_restore_state(sp->pdev, sp->config_space);=0A=
+	s2io_init_pci(sp);=0A=
+=0A=
+	set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+	schedule_timeout(HZ / 4);=0A=
+=0A=
+	/* SXE-002: Configure link and activity LED to turn it off */=0A=
+	subid =3D sp->pdev->subsystem_device;=0A=
+	if ((subid & 0xFF) >=3D 0x07) {=0A=
+		val64 =3D readq(&bar0->gpio_control);=0A=
+		val64 |=3D 0x0000800000000000ULL;=0A=
+		writeq(val64, &bar0->gpio_control);=0A=
+		val64 =3D 0x0411040400000000ULL;=0A=
+		writeq(val64, (void *) ((u8 *) bar0 + 0x2700));=0A=
+	}=0A=
+=0A=
+	sp->device_enabled_once =3D FALSE;=0A=
+}=0A=
+=0A=
+/*=0A=
+ *  Input Argument: =0A=
+ *  sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ *  Return value:=0A=
+ *  SUCCESS on success and FAILURE on failure.=0A=
+ *  Description:=0A=
+ * Function to set the swapper control on the card correctly depending =
on the=0A=
+ * 'endianness' of the system.=0A=
+ */=0A=
+int s2io_set_swapper(nic_t * sp)=0A=
+{=0A=
+	struct net_device *dev =3D sp->dev;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+	u64 val64;=0A=
+=0A=
+/*  Set proper endian settings and verify the same by reading the PIF =0A=
+ *  Feed-back register.=0A=
+ */=0A=
+#ifdef  __BIG_ENDIAN=0A=
+/* The device by default set to a big endian format, so a big endian =0A=
+ * driver need not set anything.=0A=
+ */=0A=
+	writeq(0xffffffffffffffffULL, &bar0->swapper_ctrl);=0A=
+	val64 =3D (SWAPPER_CTRL_PIF_R_FE |=0A=
+		 SWAPPER_CTRL_PIF_R_SE |=0A=
+		 SWAPPER_CTRL_PIF_W_FE |=0A=
+		 SWAPPER_CTRL_PIF_W_SE |=0A=
+		 SWAPPER_CTRL_TXP_FE |=0A=
+		 SWAPPER_CTRL_TXP_SE |=0A=
+		 SWAPPER_CTRL_TXD_R_FE |=0A=
+		 SWAPPER_CTRL_TXD_W_FE |=0A=
+		 SWAPPER_CTRL_TXF_R_FE |=0A=
+		 SWAPPER_CTRL_RXD_R_FE |=0A=
+		 SWAPPER_CTRL_RXD_W_FE |=0A=
+		 SWAPPER_CTRL_RXF_W_FE |=0A=
+		 SWAPPER_CTRL_XMSI_FE |=0A=
+		 SWAPPER_CTRL_XMSI_SE |=0A=
+		 SWAPPER_CTRL_STATS_FE | SWAPPER_CTRL_STATS_SE);=0A=
+	writeq(val64, &bar0->swapper_ctrl);=0A=
+#else=0A=
+/* Initially we enable all bits to make it accessible by the driver,=0A=
+ * then we selectively enable only those bits that we want to set.=0A=
+ */=0A=
+	writeq(0xffffffffffffffffULL, &bar0->swapper_ctrl);=0A=
+	val64 =3D (SWAPPER_CTRL_PIF_R_FE |=0A=
+		 SWAPPER_CTRL_PIF_R_SE |=0A=
+		 SWAPPER_CTRL_PIF_W_FE |=0A=
+		 SWAPPER_CTRL_PIF_W_SE |=0A=
+		 SWAPPER_CTRL_TXP_FE |=0A=
+		 SWAPPER_CTRL_TXP_SE |=0A=
+		 SWAPPER_CTRL_TXD_R_FE |=0A=
+		 SWAPPER_CTRL_TXD_R_SE |=0A=
+		 SWAPPER_CTRL_TXD_W_FE |=0A=
+		 SWAPPER_CTRL_TXD_W_SE |=0A=
+		 SWAPPER_CTRL_TXF_R_FE |=0A=
+		 SWAPPER_CTRL_RXD_R_FE |=0A=
+		 SWAPPER_CTRL_RXD_R_SE |=0A=
+		 SWAPPER_CTRL_RXD_W_FE |=0A=
+		 SWAPPER_CTRL_RXD_W_SE |=0A=
+		 SWAPPER_CTRL_RXF_W_FE |=0A=
+		 SWAPPER_CTRL_XMSI_FE |=0A=
+		 SWAPPER_CTRL_XMSI_SE |=0A=
+		 SWAPPER_CTRL_STATS_FE | SWAPPER_CTRL_STATS_SE);=0A=
+	writeq(val64, &bar0->swapper_ctrl);=0A=
+#endif=0A=
+=0A=
+/*  Verifying if endian settings are accurate by reading a feedback=0A=
+ *  register.=0A=
+ */=0A=
+	val64 =3D readq(&bar0->pif_rd_swapper_fb);=0A=
+	if (val64 !=3D 0x0123456789ABCDEFULL) {=0A=
+		/* Endian settings are incorrect, calls for another dekko. */=0A=
+		DBG_PRINT(ERR_DBG, "%s: Endian settings are wrong, ",=0A=
+			  dev->name);=0A=
+		DBG_PRINT(ERR_DBG, "feedback read %llx\n",=0A=
+			  (unsigned long long) val64);=0A=
+		return FAILURE;=0A=
+	}=0A=
+=0A=
+	return SUCCESS;=0A=
+}=0A=
+=0A=
+/* ********************************************************* *=0A=
+ * Functions defined below concern the OS part of the driver *=0A=
+ * ********************************************************* */=0A=
+=0A=
+/*=0A=
+ *  Input Argument: =0A=
+ *  dev - pointer to the device structure.=0A=
+ *  Return value:=0A=
+ *  '0' on success and an appropriate (-)ve integer as defined in =
errno.h=0A=
+ *   file on failure.=0A=
+ *  Description:=0A=
+ *  This function is the open entry point of the driver. It mainly =
calls a=0A=
+ *  function to allocate Rx buffers and inserts them into the buffer=0A=
+ *  descriptors and then enables the Rx part of the NIC. =0A=
+ */=0A=
+int s2io_open(struct net_device *dev)=0A=
+{=0A=
+	nic_t *sp =3D dev->priv;=0A=
+	int i, ret =3D 0, err =3D 0;=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+=0A=
+=0A=
+/* Make sure you have link off by default every time Nic is =
initialized*/=0A=
+	netif_carrier_off(dev);=0A=
+	sp->last_link_state =3D LINK_DOWN;=0A=
+=0A=
+/*  Initialize the H/W I/O registers */=0A=
+	if (initNic(sp) !=3D 0) {=0A=
+		DBG_PRINT(ERR_DBG, "%s: H/W initialization failed\n",=0A=
+			  dev->name);=0A=
+		return -ENODEV;=0A=
+	}=0A=
+=0A=
+/*  After proper initialization of H/W, register ISR */=0A=
+	err =3D=0A=
+	    request_irq((int) sp->irq, s2io_isr, SA_SHIRQ, sp->name, dev);=0A=
+	if (err) {=0A=
+		s2io_reset(sp);=0A=
+		DBG_PRINT(ERR_DBG, "%s: ISR registration failed\n",=0A=
+			  dev->name);=0A=
+		return err;=0A=
+	}=0A=
+	if (s2io_set_mac_addr(dev, dev->dev_addr) =3D=3D FAILURE) {=0A=
+		DBG_PRINT(ERR_DBG, "Set Mac Address Failed\n");=0A=
+		s2io_reset(sp);=0A=
+		return -ENODEV;=0A=
+	}=0A=
+=0A=
+=0A=
+/*  Setting its receive mode */=0A=
+	s2io_set_multicast(dev);=0A=
+=0A=
+/*  Initializing the Rx buffers. For now we are considering only 1 Rx =
ring=0A=
+ * and initializing buffers into 1016 RxDs or 8 Rx blocks=0A=
+ */=0A=
+	mac_control =3D &sp->mac_control;=0A=
+	config =3D &sp->config;=0A=
+=0A=
+	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
+		if ((ret =3D fill_rx_buffers(sp, i))) {=0A=
+			DBG_PRINT(ERR_DBG, "%s: Out of memory in Open\n",=0A=
+				  dev->name);=0A=
+			s2io_reset(sp);=0A=
+			free_irq(dev->irq, dev);=0A=
+			freeRxBuffers(sp);=0A=
+			return -ENOMEM;=0A=
+		}=0A=
+		DBG_PRINT(INFO_DBG, "Buf in ring:%d is %d:\n", i,=0A=
+			  atomic_read(&sp->rx_bufs_left[i]));=0A=
+	}=0A=
+=0A=
+/*  Enable tasklet for the device */=0A=
+	tasklet_init(&sp->task, s2io_tasklet, (unsigned long) dev);=0A=
+=0A=
+/*  Enable Rx Traffic and interrupts on the NIC */=0A=
+	if (startNic(sp)) {=0A=
+		DBG_PRINT(ERR_DBG, "%s: Starting NIC failed\n", dev->name);=0A=
+		tasklet_kill(&sp->task);=0A=
+		s2io_reset(sp);=0A=
+		free_irq(dev->irq, dev);=0A=
+		freeRxBuffers(sp);=0A=
+		return -ENODEV;=0A=
+	}=0A=
+=0A=
+	sp->device_close_flag =3D FALSE;	/* Device is up and running. */=0A=
+	netif_start_queue(dev);=0A=
+=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+/*=0A=
+ *  Input Argument/s: =0A=
+ *  dev - device pointer.=0A=
+ *  Return value:=0A=
+ *  '0' on success and an appropriate (-)ve integer as defined in =
errno.h=0A=
+ *  file on failure.=0A=
+ *  Description:=0A=
+ *  This is the stop entry point of the driver. It needs to undo exactly=0A=
+ *  whatever was done by the open entry point, thus it's usually =
referred to=0A=
+ *  as the close function. Among other things this function mainly =
stops the=0A=
+ *  Rx side of the NIC and frees all the Rx buffers in the Rx rings.=0A=
+ */=0A=
+int s2io_close(struct net_device *dev)=0A=
+{=0A=
+	nic_t *sp =3D dev->priv;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+	register u64 val64 =3D 0;=0A=
+	u16 cnt =3D 0;=0A=
+=0A=
+	spin_lock(&sp->isr_lock);=0A=
+	netif_stop_queue(dev);=0A=
+=0A=
+/* disable Tx and Rx traffic on the NIC */=0A=
+	stopNic(sp);=0A=
+=0A=
+	spin_unlock(&sp->isr_lock);=0A=
+=0A=
+/* If the device tasklet is running, wait till its done before killing =
it */=0A=
+	while (atomic_read(&(sp->tasklet_status))) {=0A=
+		set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+		schedule_timeout(HZ / 10);=0A=
+	}=0A=
+	tasklet_kill(&sp->task);=0A=
+=0A=
+/* Check if the device is Quiescent and then Reset the NIC */=0A=
+	do {=0A=
+		val64 =3D readq(&bar0->adapter_status);=0A=
+		if (verify_xena_quiescence(val64, sp->device_enabled_once)) {=0A=
+			break;=0A=
+		}=0A=
+=0A=
+		set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+		schedule_timeout(HZ / 20);=0A=
+		cnt++;=0A=
+		if (cnt =3D=3D 10) {=0A=
+			DBG_PRINT(ERR_DBG,=0A=
+				  "s2io_close:Device not Quiescent ");=0A=
+			DBG_PRINT(ERR_DBG, "adaper status reads 0x%llx\n",=0A=
+				  (unsigned long long) val64);=0A=
+			break;=0A=
+		}=0A=
+	} while (1);=0A=
+	s2io_reset(sp);=0A=
+=0A=
+/*  Free the Registered IRQ */=0A=
+	free_irq(dev->irq, dev);=0A=
+=0A=
+/* Free all Tx Buffers waiting for transmission */=0A=
+	freeTxBuffers(sp);=0A=
+=0A=
+/*  Free all Rx buffers allocated by host */=0A=
+	freeRxBuffers(sp);=0A=
+=0A=
+	sp->device_close_flag =3D TRUE;	/* Device is shut down. */=0A=
+=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+/*=0A=
+ *  Input Argument/s: =0A=
+ *  skb - the socket buffer containing the Tx data.=0A=
+ *  dev - device pointer.=0A=
+ *  Return value:=0A=
+ *  '0' on success & 1 on failure. =0A=
+ *  NOTE: when device cant queue the pkt, just the trans_start variable =
will=0A=
+ *  not be upadted.=0A=
+ *  Description:=0A=
+ *  This function is the Tx entry point of the driver. S2IO NIC supports=0A=
+ *  certain protocol assist features on Tx side, namely  CSO, S/G, LSO.=0A=
+ */=0A=
+int s2io_xmit(struct sk_buff *skb, struct net_device *dev)=0A=
+{=0A=
+	nic_t *sp =3D dev->priv;=0A=
+	u16 off, txd_len, frg_cnt, frg_len, i, queue, off1, queue_len;=0A=
+	register u64 val64;=0A=
+	TxD_t *txdp;=0A=
+	TxFIFO_element_t *tx_fifo;=0A=
+	unsigned long flags;=0A=
+#ifdef NETIF_F_TSO=0A=
+	int mss;=0A=
+#endif=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+=0A=
+	mac_control =3D &sp->mac_control;=0A=
+	config =3D &sp->config;=0A=
+=0A=
+	DBG_PRINT(TX_DBG, "%s: In S2IO Tx routine\n", dev->name);=0A=
+=0A=
+	spin_lock_irqsave(&sp->tx_lock, flags);=0A=
+	queue =3D 0;=0A=
+	/* Multi FIFO Tx is disabled for now. */=0A=
+	if (!queue && tx_prio) {=0A=
+		u8 x =3D (skb->data)[5];=0A=
+		queue =3D x % config->TxFIFONum;=0A=
+	}=0A=
+=0A=
+=0A=
+	off =3D (u16) mac_control->tx_curr_put_info[queue].offset;=0A=
+	off1 =3D (u16) mac_control->tx_curr_get_info[queue].offset;=0A=
+	txd_len =3D mac_control->txdl_len;=0A=
+	txdp =3D mac_control->txdl_start[queue] + (config->MaxTxDs * off);=0A=
+=0A=
+	queue_len =3D mac_control->tx_curr_put_info[queue].fifo_len + 1;=0A=
+	/* Avoid "put" pointer going beyond "get" pointer */=0A=
+	if (txdp->Host_Control || (((off + 1) % queue_len) =3D=3D off1)) {=0A=
+		DBG_PRINT(ERR_DBG, "Error in xmit, No free TXDs.\n");=0A=
+		netif_stop_queue(dev);=0A=
+		dev_kfree_skb(skb);=0A=
+		spin_unlock_irqrestore(&sp->tx_lock, flags);=0A=
+		return 0;=0A=
+	}=0A=
+=0A=
+#ifdef NETIF_F_TSO=0A=
+	mss =3D skb_shinfo(skb)->tso_size;=0A=
+	if (mss) {=0A=
+		txdp->Control_1 |=3D TXD_TCP_LSO_EN;=0A=
+		txdp->Control_1 |=3D TXD_TCP_LSO_MSS(mss);=0A=
+	}=0A=
+#endif=0A=
+=0A=
+	frg_cnt =3D skb_shinfo(skb)->nr_frags;=0A=
+	frg_len =3D skb->len - skb->data_len;=0A=
+=0A=
+	txdp->Host_Control =3D (unsigned long) skb;=0A=
+	txdp->Buffer_Pointer =3D pci_map_single=0A=
+	    (sp->pdev, skb->data, frg_len, PCI_DMA_TODEVICE);=0A=
+	if (skb->ip_summed =3D=3D CHECKSUM_HW) {=0A=
+		txdp->Control_2 |=3D=0A=
+		    (TXD_TX_CKO_IPV4_EN | TXD_TX_CKO_TCP_EN |=0A=
+		     TXD_TX_CKO_UDP_EN);=0A=
+	}=0A=
+=0A=
+	txdp->Control_2 |=3D config->TxIntrType;=0A=
+=0A=
+	txdp->Control_1 |=3D (TXD_BUFFER0_SIZE(frg_len) |=0A=
+			    TXD_GATHER_CODE_FIRST);=0A=
+	txdp->Control_1 |=3D TXD_LIST_OWN_XENA;=0A=
+=0A=
+	/* For fragmented SKB. */=0A=
+	for (i =3D 0; i < frg_cnt; i++) {=0A=
+		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];=0A=
+		txdp++;=0A=
+		txdp->Buffer_Pointer =3D (u64) pci_map_page=0A=
+		    (sp->pdev, frag->page, frag->page_offset,=0A=
+		     frag->size, PCI_DMA_TODEVICE);=0A=
+		txdp->Control_1 |=3D TXD_BUFFER0_SIZE(frag->size);=0A=
+	}=0A=
+	txdp->Control_1 |=3D TXD_GATHER_CODE_LAST;=0A=
+=0A=
+	tx_fifo =3D mac_control->tx_FIFO_start[queue];=0A=
+	val64 =3D (mac_control->txdl_start_phy[queue] +=0A=
+		 (sizeof(TxD_t) * txd_len * off));=0A=
+	writeq(val64, &tx_fifo->TxDL_Pointer);=0A=
+=0A=
+	val64 =3D (TX_FIFO_LAST_TXD_NUM(frg_cnt) | TX_FIFO_FIRST_LIST |=0A=
+		 TX_FIFO_LAST_LIST);=0A=
+#ifdef NETIF_F_TSO=0A=
+	if (mss)=0A=
+		val64 |=3D TX_FIFO_SPECIAL_FUNC;=0A=
+#endif=0A=
+	writeq(val64, &tx_fifo->List_Control);=0A=
+=0A=
+	off++;=0A=
+	off %=3D mac_control->tx_curr_put_info[queue].fifo_len + 1;=0A=
+	mac_control->tx_curr_put_info[queue].offset =3D off;=0A=
+=0A=
+	/* Avoid "put" pointer going beyond "get" pointer */=0A=
+	if (((off + 1) % queue_len) =3D=3D off1) {=0A=
+		DBG_PRINT(TX_DBG, =0A=
+		  "No free TxDs for xmit, Put: 0x%x Get:0x%x\n",=0A=
+		  off, off1);=0A=
+		netif_stop_queue(dev);=0A=
+	}=0A=
+=0A=
+	dev->trans_start =3D jiffies;=0A=
+	spin_unlock_irqrestore(&sp->tx_lock, flags);=0A=
+=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+/*=0A=
+ *  Input Argument/s: =0A=
+ *  irq: the irq of the device.=0A=
+ *  dev_id: a void pointer to the dev structure of the NIC.=0A=
+ *  ptregs: pointer to the registers pushed on the stack.=0A=
+ *  Return value:=0A=
+ *  void.=0A=
+ *  Description:=0A=
+ *  This function is the ISR handler of the device. It identifies the =
reason =0A=
+ *  for the interrupt and calls the relevant service routines.=0A=
+ *  As a contongency measure, this ISR allocates the recv buffers, if =
their =0A=
+ *  numbers are below the panic value which is presently set to 25% of =
the=0A=
+ *  original number of rcv buffers allocated.=0A=
+ */=0A=
+=0A=
+static irqreturn_t s2io_isr(int irq, void *dev_id, struct pt_regs *regs)=0A=
+{=0A=
+	struct net_device *dev =3D (struct net_device *) dev_id;=0A=
+	nic_t *sp =3D dev->priv;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+#ifndef CONFIG_S2IO_NAPI=0A=
+	int i, ret;=0A=
+#endif=0A=
+	u64 reason =3D 0, general_mask =3D 0;=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+=0A=
+	mac_control =3D &sp->mac_control;=0A=
+	config =3D &sp->config;=0A=
+=0A=
+	spin_lock(&sp->isr_lock);=0A=
+=0A=
+	/* Identify the cause for interrupt and call the appropriate=0A=
+	 * interrupt handler. Causes for the interrupt could be;=0A=
+	 * 1. Rx of packet.=0A=
+	 * 2. Tx complete.=0A=
+	 * 3. Link down.=0A=
+	 * 4. Error in any functional blocks of the NIC. =0A=
+	 */=0A=
+	reason =3D readq(&bar0->general_int_status);=0A=
+=0A=
+	if (!reason) {=0A=
+		/* The interrupt was not raised by Xena. */=0A=
+		spin_unlock(&sp->isr_lock);=0A=
+		return IRQ_NONE;=0A=
+	}=0A=
+	/* Mask the interrupts on the NIC */=0A=
+	general_mask =3D readq(&bar0->general_int_mask);=0A=
+	writeq(0xFFFFFFFFFFFFFFFFULL, &bar0->general_int_mask);=0A=
+=0A=
+#if DEBUG_ON=0A=
+	sp->int_cnt++;=0A=
+#endif=0A=
+=0A=
+	/* If Intr is because of Tx Traffic */=0A=
+	if (reason & GEN_INTR_TXTRAFFIC) {=0A=
+		txIntrHandler(sp);=0A=
+	}=0A=
+=0A=
+	/* If Intr is because of an error */=0A=
+	if (reason & (GEN_ERROR_INTR))=0A=
+		alarmIntrHandler(sp);=0A=
+=0A=
+#ifdef CONFIG_S2IO_NAPI=0A=
+	if (reason & GEN_INTR_RXTRAFFIC) {=0A=
+		if (netif_rx_schedule_prep(dev)) {=0A=
+			en_dis_able_NicIntrs(sp, RX_TRAFFIC_INTR,=0A=
+					     DISABLE_INTRS);=0A=
+			/* We retake the snap shot of the general interrupt =0A=
+			 * register.=0A=
+			 */=0A=
+			general_mask =3D readq(&bar0->general_int_mask);=0A=
+			__netif_rx_schedule(dev);=0A=
+		}=0A=
+	}=0A=
+#else=0A=
+	/* If Intr is because of Rx Traffic */=0A=
+	if (reason & GEN_INTR_RXTRAFFIC) {=0A=
+		rxIntrHandler(sp);=0A=
+	}=0A=
+#endif=0A=
+=0A=
+/* If the Rx buffer count is below the panic threshold then reallocate =
the=0A=
+ * buffers from the interrupt handler itself, else schedule a tasklet =
to =0A=
+ * reallocate the buffers.=0A=
+ */=0A=
+#if 1=0A=
+	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
+		int rxb_size =3D atomic_read(&sp->rx_bufs_left[i]);=0A=
+		int level =3D rx_buffer_level(sp, rxb_size, i);=0A=
+=0A=
+		if ((level =3D=3D PANIC) && (!TASKLET_IN_USE)) {=0A=
+			DBG_PRINT(ERR_DBG, "%s: Rx BD hit ", dev->name);=0A=
+			DBG_PRINT(ERR_DBG, "PANIC levels\n");=0A=
+			if ((ret =3D fill_rx_buffers(sp, i)) =3D=3D -ENOMEM) {=0A=
+				DBG_PRINT(ERR_DBG, "%s:Out of memory",=0A=
+					  dev->name);=0A=
+				DBG_PRINT(ERR_DBG, " in ISR!!\n");=0A=
+				writeq(general_mask,=0A=
+				       &bar0->general_int_mask);=0A=
+				spin_unlock(&sp->isr_lock);=0A=
+				return IRQ_HANDLED;=0A=
+			}=0A=
+			clear_bit(0,=0A=
+				  (unsigned long *) (&sp->tasklet_status));=0A=
+		} else if ((level =3D=3D LOW)=0A=
+			   && (!atomic_read(&sp->tasklet_status))) {=0A=
+			tasklet_schedule(&sp->task);=0A=
+		}=0A=
+=0A=
+	}=0A=
+#else=0A=
+	tasklet_schedule(&sp->task);=0A=
+#endif=0A=
+=0A=
+	/* Unmask all the previously enabled interrupts on the NIC */=0A=
+	writeq(general_mask, &bar0->general_int_mask);=0A=
+=0A=
+	spin_unlock(&sp->isr_lock);=0A=
+	return IRQ_HANDLED;=0A=
+}=0A=
+=0A=
+/*=0A=
+ *  Input Argument/s: =0A=
+ *  dev - pointer to the device structure.=0A=
+ *  Return value:=0A=
+ *  pointer to the updated net_device_stats structure.=0A=
+ *  Description:=0A=
+ *  This function updates the device statistics structure in the =
s2io_nic =0A=
+ *  structure and returns a pointer to the same.=0A=
+ */=0A=
+struct net_device_stats *s2io_get_stats(struct net_device *dev)=0A=
+{=0A=
+	nic_t *sp =3D dev->priv;=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+=0A=
+	mac_control =3D &sp->mac_control;=0A=
+	config =3D &sp->config;=0A=
+=0A=
+	sp->stats.tx_errors =3D mac_control->StatsInfo->tmac_any_err_frms;=0A=
+	sp->stats.rx_errors =3D mac_control->StatsInfo->rmac_drop_frms;=0A=
+	sp->stats.multicast =3D mac_control->StatsInfo->rmac_vld_mcst_frms;=0A=
+	sp->stats.rx_length_errors =3D=0A=
+	    mac_control->StatsInfo->rmac_long_frms;=0A=
+=0A=
+	return (&sp->stats);=0A=
+}=0A=
+=0A=
+/*=0A=
+ *  Input Argument/s: =0A=
+ *  dev - pointer to the device structure=0A=
+ *  Return value:=0A=
+ *  void.=0A=
+ *  Description:=0A=
+ *  This function is a driver entry point which gets called by the =
kernel =0A=
+ *  whenever multicast addresses must be enabled/disabled. This also =
gets =0A=
+ *  called to set/reset promiscuous mode. Depending on the deivce flag, =
we=0A=
+ *  determine, if multicast address must be enabled or if promiscuous =
mode=0A=
+ *  is to be disabled etc.=0A=
+ */=0A=
+static void s2io_set_multicast(struct net_device *dev)=0A=
+{=0A=
+	int i, j, prev_cnt;=0A=
+	struct dev_mc_list *mclist;=0A=
+	nic_t *sp =3D dev->priv;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+	u64 val64 =3D 0, multi_mac =3D 0x010203040506ULL, mask =3D=0A=
+	    0xfeffffffffffULL;=0A=
+	u64 dis_addr =3D 0xffffffffffffULL, mac_addr =3D 0;=0A=
+	void *add;=0A=
+=0A=
+	if ((dev->flags & IFF_ALLMULTI) && (!sp->m_cast_flg)) {=0A=
+		/*  Enable all Multicast addresses */=0A=
+		writeq(RMAC_ADDR_DATA0_MEM_ADDR(multi_mac),=0A=
+		       &bar0->rmac_addr_data0_mem);=0A=
+		writeq(RMAC_ADDR_DATA1_MEM_MASK(mask),=0A=
+		       &bar0->rmac_addr_data1_mem);=0A=
+		val64 =3D RMAC_ADDR_CMD_MEM_WE |=0A=
+		    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |=0A=
+		    RMAC_ADDR_CMD_MEM_OFFSET(MAC_MC_ALL_MC_ADDR_OFFSET);=0A=
+		writeq(val64, &bar0->rmac_addr_cmd_mem);=0A=
+		/* Wait till command completes */=0A=
+		waitForCmdComplete(sp);=0A=
+=0A=
+		sp->m_cast_flg =3D 1;=0A=
+		sp->all_multi_pos =3D MAC_MC_ALL_MC_ADDR_OFFSET;=0A=
+	} else if ((dev->flags & IFF_ALLMULTI) && (sp->m_cast_flg)) {=0A=
+		/*  Disable all Multicast addresses */=0A=
+		writeq(RMAC_ADDR_DATA0_MEM_ADDR(dis_addr),=0A=
+		       &bar0->rmac_addr_data0_mem);=0A=
+		val64 =3D RMAC_ADDR_CMD_MEM_WE |=0A=
+		    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |=0A=
+		    RMAC_ADDR_CMD_MEM_OFFSET(sp->all_multi_pos);=0A=
+		writeq(val64, &bar0->rmac_addr_cmd_mem);=0A=
+		/* Wait till command completes */=0A=
+		waitForCmdComplete(sp);=0A=
+=0A=
+		sp->m_cast_flg =3D 0;=0A=
+		sp->all_multi_pos =3D 0;=0A=
+	}=0A=
+=0A=
+	if ((dev->flags & IFF_PROMISC) && (!sp->promisc_flg)) {=0A=
+		/*  Put the NIC into promiscuous mode */=0A=
+		add =3D (void *) &bar0->mac_cfg;=0A=
+		val64 =3D readq(&bar0->mac_cfg);=0A=
+		val64 |=3D MAC_CFG_RMAC_PROM_ENABLE;=0A=
+=0A=
+		writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);=0A=
+		writel((u32) val64, add);=0A=
+		writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);=0A=
+		writel((u32) (val64 >> 32), (add + 4));=0A=
+=0A=
+		val64 =3D readq(&bar0->mac_cfg);=0A=
+		sp->promisc_flg =3D 1;=0A=
+		DBG_PRINT(ERR_DBG, "%s: entered promiscuous mode\n",=0A=
+			  dev->name);=0A=
+	} else if (!(dev->flags & IFF_PROMISC) && (sp->promisc_flg)) {=0A=
+		/*  Remove the NIC from promiscuous mode */=0A=
+		add =3D (void *) &bar0->mac_cfg;=0A=
+		val64 =3D readq(&bar0->mac_cfg);=0A=
+		val64 &=3D ~MAC_CFG_RMAC_PROM_ENABLE;=0A=
+=0A=
+		writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);=0A=
+		writel((u32) val64, add);=0A=
+		writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);=0A=
+		writel((u32) (val64 >> 32), (add + 4));=0A=
+=0A=
+		val64 =3D readq(&bar0->mac_cfg);=0A=
+		sp->promisc_flg =3D 0;=0A=
+		DBG_PRINT(ERR_DBG, "%s: left promiscuous mode\n",=0A=
+			  dev->name);=0A=
+	}=0A=
+=0A=
+	/*  Update individual M_CAST address list */=0A=
+	if ((!sp->m_cast_flg) && dev->mc_count) {=0A=
+		if (dev->mc_count >=0A=
+		    (MAX_ADDRS_SUPPORTED - MAC_MC_ADDR_START_OFFSET - 1)) {=0A=
+			DBG_PRINT(ERR_DBG, "%s: No more Rx filters ",=0A=
+				  dev->name);=0A=
+			DBG_PRINT(ERR_DBG, "can be added, please enable ");=0A=
+			DBG_PRINT(ERR_DBG, "ALL_MULTI instead\n");=0A=
+			return;=0A=
+		}=0A=
+=0A=
+		prev_cnt =3D sp->mc_addr_count;=0A=
+		sp->mc_addr_count =3D dev->mc_count;=0A=
+=0A=
+		/* Clear out the previous list of Mc in the H/W. */=0A=
+		for (i =3D 0; i < prev_cnt; i++) {=0A=
+			writeq(RMAC_ADDR_DATA0_MEM_ADDR(dis_addr),=0A=
+			       &bar0->rmac_addr_data0_mem);=0A=
+			val64 =3D RMAC_ADDR_CMD_MEM_WE |=0A=
+			    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |=0A=
+			    RMAC_ADDR_CMD_MEM_OFFSET=0A=
+			    (MAC_MC_ADDR_START_OFFSET + i);=0A=
+			writeq(val64, &bar0->rmac_addr_cmd_mem);=0A=
+=0A=
+			/* Wait for command completes */=0A=
+			if (waitForCmdComplete(sp)) {=0A=
+				DBG_PRINT(ERR_DBG, "%s: Adding ",=0A=
+					  dev->name);=0A=
+				DBG_PRINT(ERR_DBG, "Multicasts failed\n");=0A=
+				return;=0A=
+			}=0A=
+		}=0A=
+=0A=
+		/* Create the new Rx filter list and update the same in H/W. */=0A=
+		for (i =3D 0, mclist =3D dev->mc_list; i < dev->mc_count;=0A=
+		     i++, mclist =3D mclist->next) {=0A=
+			memcpy(sp->usr_addrs[i].addr, mclist->dmi_addr,=0A=
+			       ETH_ALEN);=0A=
+			for (j =3D 0; j < ETH_ALEN; j++) {=0A=
+				mac_addr |=3D mclist->dmi_addr[j];=0A=
+				mac_addr <<=3D 8;=0A=
+			}=0A=
+			writeq(RMAC_ADDR_DATA0_MEM_ADDR(mac_addr),=0A=
+			       &bar0->rmac_addr_data0_mem);=0A=
+=0A=
+			val64 =3D RMAC_ADDR_CMD_MEM_WE |=0A=
+			    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |=0A=
+			    RMAC_ADDR_CMD_MEM_OFFSET=0A=
+			    (i + MAC_MC_ADDR_START_OFFSET);=0A=
+			writeq(val64, &bar0->rmac_addr_cmd_mem);=0A=
+=0A=
+			/* Wait for command completes */=0A=
+			if (waitForCmdComplete(sp)) {=0A=
+				DBG_PRINT(ERR_DBG, "%s: Adding ",=0A=
+					  dev->name);=0A=
+				DBG_PRINT(ERR_DBG, "Multicasts failed\n");=0A=
+				return;=0A=
+			}=0A=
+		}=0A=
+	}=0A=
+}=0A=
+=0A=
+/*=0A=
+ *  Input Argument/s: =0A=
+ *  dev - pointer to the device structure.=0A=
+ *  new_mac - a uchar pointer to the new mac address which is to be set.=0A=
+ *  Return value:=0A=
+ *  SUCCESS on success and an appropriate (-)ve integer as defined in =
errno.h=0A=
+ *  file on failure.=0A=
+ *  Description:=0A=
+ *  This procedure will program the Xframe to receive frames with new=0A=
+ *  Mac Address=0A=
+ */=0A=
+int s2io_set_mac_addr(struct net_device *dev, u8 * addr)=0A=
+{=0A=
+	nic_t *sp =3D dev->priv;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+	register u64 val64, mac_addr =3D 0;=0A=
+	int i;=0A=
+=0A=
+	/* =0A=
+	 * Set the new MAC address as the new unicast filter and reflect this=0A=
+	 * change on the device address registered with the OS. It will be=0A=
+	 * at offset 0. =0A=
+	 */=0A=
+	for (i =3D 0; i < ETH_ALEN; i++) {=0A=
+		mac_addr <<=3D 8;=0A=
+		mac_addr |=3D addr[i];=0A=
+	}=0A=
+=0A=
+	writeq(RMAC_ADDR_DATA0_MEM_ADDR(mac_addr),=0A=
+	       &bar0->rmac_addr_data0_mem);=0A=
+=0A=
+	val64 =3D=0A=
+	    RMAC_ADDR_CMD_MEM_WE | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |=0A=
+	    RMAC_ADDR_CMD_MEM_OFFSET(0);=0A=
+	writeq(val64, &bar0->rmac_addr_cmd_mem);=0A=
+	/* Wait till command completes */=0A=
+	if (waitForCmdComplete(sp)) {=0A=
+		DBG_PRINT(ERR_DBG, "%s: set_mac_addr failed\n", dev->name);=0A=
+		return FAILURE;=0A=
+	}=0A=
+=0A=
+	return SUCCESS;=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Input Argument/s: =0A=
+ *  sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ *  info - pointer to the structure with parameters given by ethtool to =
set=0A=
+ *  link information.=0A=
+ * Return value:=0A=
+ *  0 on success.=0A=
+ * Description:=0A=
+ *  The function sets different link parameters provided by the user =
onto =0A=
+ *  the NIC.=0A=
+ */=0A=
+static int s2io_ethtool_sset(struct net_device *dev,=0A=
+			     struct ethtool_cmd *info)=0A=
+{=0A=
+	nic_t *sp =3D dev->priv;=0A=
+	if ((info->autoneg =3D=3D AUTONEG_ENABLE) ||=0A=
+	    (info->speed !=3D SPEED_10000) || (info->duplex !=3D DUPLEX_FULL))=0A=
+		return -EINVAL;=0A=
+	else {=0A=
+		s2io_close(sp->dev);=0A=
+		s2io_open(sp->dev);=0A=
+	}=0A=
+=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Input Argument/s: =0A=
+ *  sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ *  info - pointer to the structure with parameters given by ethtool to =
return=0A=
+ *  link information.=0A=
+ * Return value:=0A=
+ *  void=0A=
+ * Description:=0A=
+ *  Returns link specefic information like speed, duplex etc.. to =
ethtool.=0A=
+ */=0A=
+int s2io_ethtool_gset(struct net_device *dev, struct ethtool_cmd *info)=0A=
+{=0A=
+	nic_t *sp =3D dev->priv;=0A=
+	info->supported =3D (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);=0A=
+	info->advertising =3D (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);=0A=
+	info->port =3D PORT_FIBRE;=0A=
+	/* info->transceiver?? TODO */=0A=
+=0A=
+	if (netif_carrier_ok(sp->dev)) {=0A=
+		info->speed =3D 10000;=0A=
+		info->duplex =3D DUPLEX_FULL;=0A=
+	} else {=0A=
+		info->speed =3D -1;=0A=
+		info->duplex =3D -1;=0A=
+	}=0A=
+=0A=
+	info->autoneg =3D AUTONEG_DISABLE;=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Input Argument/s: =0A=
+ *  sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ *  info - pointer to the structure with parameters given by ethtool to =
return=0A=
+ *  driver information.=0A=
+ * Return value:=0A=
+ *  void=0A=
+ * Description:=0A=
+ *  Returns driver specefic information like name, version etc.. to =
ethtool.=0A=
+ */=0A=
+static void s2io_ethtool_gdrvinfo(struct net_device *dev,=0A=
+				  struct ethtool_drvinfo *info)=0A=
+{=0A=
+	nic_t *sp =3D dev->priv;=0A=
+=0A=
+	strncpy(info->driver, s2io_driver_name, sizeof(s2io_driver_name));=0A=
+	strncpy(info->version, s2io_driver_version,=0A=
+		sizeof(s2io_driver_version));=0A=
+	strncpy(info->fw_version, "", 32);=0A=
+	strncpy(info->bus_info, sp->pdev->slot_name, 32);=0A=
+	info->regdump_len =3D XENA_REG_SPACE;=0A=
+	info->eedump_len =3D XENA_EEPROM_SPACE;=0A=
+	info->testinfo_len =3D S2IO_TEST_LEN;=0A=
+	info->n_stats =3D S2IO_STAT_LEN;=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Input Argument/s: =0A=
+ *  sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ *  regs - pointer to the structure with parameters given by ethtool =
for =0A=
+ *  dumping the registers.=0A=
+ *  reg_space - The input argumnet into which all the registers are =
dumped.=0A=
+ * Return value:=0A=
+ *  void=0A=
+ * Description:=0A=
+ *  Dumps the entire register space of xFrame NIC into the user given =
buffer =0A=
+ *  area.=0A=
+ */=0A=
+static void s2io_ethtool_gregs(struct net_device *dev,=0A=
+			       struct ethtool_regs *regs, void *space)=0A=
+{=0A=
+	int i;=0A=
+	u64 reg;=0A=
+	u8 *reg_space =3D (u8 *) space;=0A=
+	nic_t *sp =3D dev->priv;=0A=
+=0A=
+	regs->len =3D XENA_REG_SPACE;=0A=
+	regs->version =3D sp->pdev->subsystem_device;=0A=
+=0A=
+	for (i =3D 0; i < regs->len; i +=3D 8) {=0A=
+		reg =3D readq((void *) (sp->bar0 + i));=0A=
+		memcpy((reg_space + i), &reg, 8);=0A=
+	}=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Input Argument/s: =0A=
+ *  data - address of the private member of the device structure, which =0A=
+ *  is a pointer to the s2io_nic structure, provided as an u32.=0A=
+ * Return value:=0A=
+ *  void=0A=
+ * Description:=0A=
+ *  This is actually the timer function that alternates the adapter LED =
bit=0A=
+ *  of the adapter control bit to set/reset every time on invocation.=0A=
+ *  The timer is set for 1/2 a second, hence tha NIC blinks once every =
second.=0A=
+ */=0A=
+static void s2io_phy_id(unsigned long data)=0A=
+{=0A=
+	nic_t *sp =3D (nic_t *) data;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+	u64 val64 =3D 0;=0A=
+	u16 subid;=0A=
+=0A=
+	subid =3D sp->pdev->subsystem_device;=0A=
+	if ((subid & 0xFF) >=3D 0x07) {=0A=
+		val64 =3D readq(&bar0->gpio_control);=0A=
+		val64 ^=3D GPIO_CTRL_GPIO_0;=0A=
+		writeq(val64, &bar0->gpio_control);=0A=
+	} else {=0A=
+		val64 =3D readq(&bar0->adapter_control);=0A=
+		val64 ^=3D ADAPTER_LED_ON;=0A=
+		writeq(val64, &bar0->adapter_control);=0A=
+	}=0A=
+=0A=
+	mod_timer(&sp->id_timer, jiffies + HZ / 2);=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Input Argument/s: =0A=
+ *  sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ *  id - pointer to the structure with identification parameters given =
by =0A=
+ *  ethtool.=0A=
+ * Return value:=0A=
+ *  int , returns '0' on success=0A=
+ * Description:=0A=
+ *  Used to physically identify the NIC on the system. The Link LED =
will blink=0A=
+ *  for a time specified by the user for identification.=0A=
+ *  NOTE: The Link has to be Up to be able to blink the LED. Hence =0A=
+ *  identification is possible only if it's link is up.=0A=
+ */=0A=
+static int s2io_ethtool_idnic(struct net_device *dev, u32 data)=0A=
+{=0A=
+	u64 val64 =3D 0;=0A=
+	nic_t *sp =3D dev->priv;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+	u16 subid;=0A=
+=0A=
+	subid =3D sp->pdev->subsystem_device;=0A=
+	if ((subid & 0xFF) < 0x07) {=0A=
+		val64 =3D readq(&bar0->adapter_control);=0A=
+		if (!(val64 & ADAPTER_CNTL_EN)) {=0A=
+			printk(KERN_ERR=0A=
+			       "Adapter Link down, cannot blink LED\n");=0A=
+			return -EFAULT;=0A=
+		}=0A=
+	}=0A=
+	if (sp->id_timer.function =3D=3D NULL) {=0A=
+		init_timer(&sp->id_timer);=0A=
+		sp->id_timer.function =3D s2io_phy_id;=0A=
+		sp->id_timer.data =3D (unsigned long) sp;=0A=
+	}=0A=
+	mod_timer(&sp->id_timer, jiffies);=0A=
+	set_current_state(TASK_INTERRUPTIBLE);=0A=
+	if (data)=0A=
+		schedule_timeout(data * HZ);=0A=
+	else=0A=
+		schedule_timeout(MAX_SCHEDULE_TIMEOUT);=0A=
+	del_timer_sync(&sp->id_timer);=0A=
+=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Input Argument/s: =0A=
+ *  sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ *  ep - pointer to the structure with pause parameters given by =
ethtool.=0A=
+ * Return value:=0A=
+ *  void=0A=
+ * Description:=0A=
+ *  Returns the Pause frame generation and reception capability of the =
NIC.=0A=
+ */=0A=
+static void s2io_ethtool_getpause_data(struct net_device *dev,=0A=
+				       struct ethtool_pauseparam *ep)=0A=
+{=0A=
+	u64 val64;=0A=
+	nic_t *sp =3D dev->priv;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+=0A=
+	val64 =3D readq(&bar0->rmac_pause_cfg);=0A=
+	if (val64 & RMAC_PAUSE_GEN_ENABLE)=0A=
+		ep->tx_pause =3D TRUE;=0A=
+	if (val64 & RMAC_PAUSE_RX_ENABLE)=0A=
+		ep->rx_pause =3D TRUE;=0A=
+	ep->autoneg =3D FALSE;=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Input Argument/s: =0A=
+ * sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ * ep - pointer to the structure with pause parameters given by ethtool.=0A=
+ * Return value:=0A=
+ * int, returns '0' on Success=0A=
+ * Description:=0A=
+ * It can be used to set or reset Pause frame generation or reception =
support =0A=
+ * of the NIC.=0A=
+ */=0A=
+int s2io_ethtool_setpause_data(struct net_device *dev,=0A=
+			       struct ethtool_pauseparam *ep)=0A=
+{=0A=
+	u64 val64;=0A=
+	nic_t *sp =3D dev->priv;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+=0A=
+	val64 =3D readq(&bar0->rmac_pause_cfg);=0A=
+	if (ep->tx_pause)=0A=
+		val64 |=3D RMAC_PAUSE_GEN_ENABLE;=0A=
+	else=0A=
+		val64 &=3D ~RMAC_PAUSE_GEN_ENABLE;=0A=
+	if (ep->rx_pause)=0A=
+		val64 |=3D RMAC_PAUSE_RX_ENABLE;=0A=
+	else=0A=
+		val64 &=3D ~RMAC_PAUSE_RX_ENABLE;=0A=
+	writeq(val64, &bar0->rmac_pause_cfg);=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Input Argument/s: =0A=
+ *  sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ *  off - offset at which the data must be written=0A=
+ * Return value:=0A=
+ *  -1 on failure and the value read from the Eeprom if successful.=0A=
+ * Description:=0A=
+ *  Will read 4 bytes of data from the user given offset and return the =0A=
+ *  read data.=0A=
+ * NOTE: Will allow to read only part of the EEPROM visible through the=0A=
+ * 	 I2C bus.=0A=
+ */=0A=
+#define S2IO_DEV_ID		5=0A=
+static u32 readEeprom(nic_t * sp, int off)=0A=
+{=0A=
+	u32 data =3D -1, exit_cnt =3D 0;=0A=
+	u64 val64;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+=0A=
+	val64 =3D I2C_CONTROL_DEV_ID(S2IO_DEV_ID) | I2C_CONTROL_ADDR(off) |=0A=
+	    I2C_CONTROL_BYTE_CNT(0x3) | I2C_CONTROL_READ |=0A=
+	    I2C_CONTROL_CNTL_START;=0A=
+	writeq(val64, &bar0->i2c_control);=0A=
+=0A=
+	while (exit_cnt < 5) {=0A=
+		val64 =3D readq(&bar0->i2c_control);=0A=
+		if (I2C_CONTROL_CNTL_END(val64)) {=0A=
+			data =3D I2C_CONTROL_GET_DATA(val64);=0A=
+			break;=0A=
+		}=0A=
+		set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+		schedule_timeout(HZ / 20);=0A=
+		exit_cnt++;=0A=
+	}=0A=
+=0A=
+	return data;=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Input Argument/s: =0A=
+ *  sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ *  off - offset at which the data must be written=0A=
+ *  data - The data that is to be written=0A=
+ *  cnt - Number of bytes of the data that are actually to be written =
into =0A=
+ *  the Eeprom. (max of 3)=0A=
+ * Return value:=0A=
+ *  '0' on success, -1 on failure.=0A=
+ * Description:=0A=
+ *  Actually writes the relevant part of the data value into the Eeprom=0A=
+ *  through the I2C bus.=0A=
+ */=0A=
+static int writeEeprom(nic_t * sp, int off, u32 data, int cnt)=0A=
+{=0A=
+	int exit_cnt =3D 0, ret =3D -1;=0A=
+	u64 val64;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+=0A=
+	val64 =3D I2C_CONTROL_DEV_ID(S2IO_DEV_ID) | I2C_CONTROL_ADDR(off) |=0A=
+	    I2C_CONTROL_BYTE_CNT(cnt) | I2C_CONTROL_SET_DATA(data) |=0A=
+	    I2C_CONTROL_CNTL_START;=0A=
+	writeq(val64, &bar0->i2c_control);=0A=
+=0A=
+	while (exit_cnt < 5) {=0A=
+		val64 =3D readq(&bar0->i2c_control);=0A=
+		if (I2C_CONTROL_CNTL_END(val64)) {=0A=
+			if (!(val64 & I2C_CONTROL_NACK))=0A=
+				ret =3D 0;=0A=
+			break;=0A=
+		}=0A=
+		set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+		schedule_timeout(HZ / 20);=0A=
+		exit_cnt++;=0A=
+	}=0A=
+=0A=
+	return ret;=0A=
+}=0A=
+=0A=
+/* =0A=
+ * A helper function used to invert the 4 byte u32 data field=0A=
+ * byte by byte. This will be used by the Read Eeprom function=0A=
+ * for display purposes.=0A=
+ */=0A=
+u32 inv(u32 data)=0A=
+{=0A=
+	static u32 ret =3D 0;=0A=
+=0A=
+	if (data) {=0A=
+		u8 c =3D data;=0A=
+		ret =3D ((ret << 8) + c);=0A=
+		data >>=3D 8;=0A=
+		inv(data);=0A=
+	}=0A=
+=0A=
+	return ret;=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Input Argument/s: =0A=
+ *  sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ *  eeprom - pointer to the user level structure provided by ethtool, =0A=
+ *   containing all relevant information.=0A=
+ *  data_buf - user defined value to be written into Eeprom.=0A=
+ * Return value:=0A=
+ *  int  '0' on success=0A=
+ * Description:=0A=
+ *  Reads the values stored in the Eeprom at given offset for a given =
length.=0A=
+ *  Stores these values int the input argument data buffer 'data_buf' =
and=0A=
+ *  returns these to the caller (ethtool.)=0A=
+ */=0A=
+int s2io_ethtool_geeprom(struct net_device *dev,=0A=
+			 struct ethtool_eeprom *eeprom, u8 * data_buf)=0A=
+{=0A=
+	u32 data, i, valid;=0A=
+	nic_t *sp =3D dev->priv;=0A=
+=0A=
+	eeprom->magic =3D sp->pdev->vendor | (sp->pdev->device << 16);=0A=
+=0A=
+	if ((eeprom->offset + eeprom->len) > (XENA_EEPROM_SPACE))=0A=
+		eeprom->len =3D XENA_EEPROM_SPACE - eeprom->offset;=0A=
+=0A=
+	for (i =3D 0; i < eeprom->len; i +=3D 4) {=0A=
+		data =3D readEeprom(sp, eeprom->offset + i);=0A=
+		if (data < 0) {=0A=
+			DBG_PRINT(ERR_DBG, "Read of EEPROM failed\n");=0A=
+			return -EFAULT;=0A=
+		}=0A=
+		valid =3D inv(data);=0A=
+		memcpy((data_buf + i), &valid, 4);=0A=
+	}=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Input Argument/s: =0A=
+ *  sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ *  eeprom - pointer to the user level structure provided by ethtool, =0A=
+ *   containing all relevant information.=0A=
+ *  data_buf - user defined value to be written into Eeprom.=0A=
+ * Return value:=0A=
+ *  '0' on success, -EFAULT on failure.=0A=
+ * Description:=0A=
+ *  Tries to write the user provided value in the Eeprom, at the offset=0A=
+ *  given by the user.=0A=
+ */=0A=
+static int s2io_ethtool_seeprom(struct net_device *dev,=0A=
+				struct ethtool_eeprom *eeprom,=0A=
+				u8 * data_buf)=0A=
+{=0A=
+	int len =3D eeprom->len, cnt =3D 0;=0A=
+	u32 valid =3D 0, data;=0A=
+	nic_t *sp =3D dev->priv;=0A=
+=0A=
+	if (eeprom->magic !=3D (sp->pdev->vendor | (sp->pdev->device << 16))) {=0A=
+		DBG_PRINT(ERR_DBG,=0A=
+			  "ETHTOOL_WRITE_EEPROM Err: Magic value ");=0A=
+		DBG_PRINT(ERR_DBG, "is wrong, Its not 0x%x\n",=0A=
+			  eeprom->magic);=0A=
+		return -EFAULT;=0A=
+	}=0A=
+=0A=
+	while (len) {=0A=
+		data =3D (u32) data_buf[cnt] & 0x000000FF;=0A=
+		if (data) {=0A=
+			valid =3D (u32) (data << 24);=0A=
+		} else=0A=
+			valid =3D data;=0A=
+=0A=
+		if (writeEeprom(sp, (eeprom->offset + cnt), valid, 0)) {=0A=
+			DBG_PRINT(ERR_DBG,=0A=
+				  "ETHTOOL_WRITE_EEPROM Err: Cannot ");=0A=
+			DBG_PRINT(ERR_DBG,=0A=
+				  "write into the specified offset\n");=0A=
+			return -EFAULT;=0A=
+		}=0A=
+		cnt++;=0A=
+		len--;=0A=
+	}=0A=
+=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Input Argument/s: =0A=
+ *  sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ *  data - variable that returns the result of each of the test =
conducted by =0A=
+ *  	the driver.=0A=
+ * Return value:=0A=
+ *  '0' on success.=0A=
+ * Description:=0A=
+ *  Read and write into all clock domains. The NIC has 3 clock domains,=0A=
+ *  see that registers in all the three regions are accessible.=0A=
+ */=0A=
+static int s2io_registerTest(nic_t * sp, uint64_t * data)=0A=
+{=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+	u64 val64 =3D 0;=0A=
+	int fail =3D 0;=0A=
+=0A=
+	val64 =3D readq(&bar0->pcc_enable);=0A=
+	if (val64 !=3D 0xff00000000000000ULL) {=0A=
+		fail =3D 1;=0A=
+		DBG_PRINT(INFO_DBG, "Read Test level 1 fails\n");=0A=
+	}=0A=
+=0A=
+	val64 =3D readq(&bar0->rmac_pause_cfg);=0A=
+	if (val64 !=3D 0xc000ffff00000000ULL) {=0A=
+		fail =3D 1;=0A=
+		DBG_PRINT(INFO_DBG, "Read Test level 2 fails\n");=0A=
+	}=0A=
+=0A=
+	val64 =3D readq(&bar0->rx_queue_cfg);=0A=
+	if (val64 !=3D 0x0808080808080808ULL) {=0A=
+		fail =3D 1;=0A=
+		DBG_PRINT(INFO_DBG, "Read Test level 3 fails\n");=0A=
+	}=0A=
+=0A=
+	val64 =3D readq(&bar0->xgxs_efifo_cfg);=0A=
+	if (val64 !=3D 0x000000001923141EULL) {=0A=
+		fail =3D 1;=0A=
+		DBG_PRINT(INFO_DBG, "Read Test level 4 fails\n");=0A=
+	}=0A=
+=0A=
+	val64 =3D 0x5A5A5A5A5A5A5A5AULL;=0A=
+	writeq(val64, &bar0->xmsi_data);=0A=
+	val64 =3D readq(&bar0->xmsi_data);=0A=
+	if (val64 !=3D 0x5A5A5A5A5A5A5A5AULL) {=0A=
+		fail =3D 1;=0A=
+		DBG_PRINT(ERR_DBG, "Write Test level 1 fails\n");=0A=
+	}=0A=
+=0A=
+	val64 =3D 0xA5A5A5A5A5A5A5A5ULL;=0A=
+	writeq(val64, &bar0->xmsi_data);=0A=
+	val64 =3D readq(&bar0->xmsi_data);=0A=
+	if (val64 !=3D 0xA5A5A5A5A5A5A5A5ULL) {=0A=
+		fail =3D 1;=0A=
+		DBG_PRINT(ERR_DBG, "Write Test level 2 fails\n");=0A=
+	}=0A=
+=0A=
+	*data =3D fail;=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Input Argument/s: =0A=
+ *  sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ *  data - variable that returns the result of each of the test =
conducted by =0A=
+ *  	the driver.=0A=
+ * Return value:=0A=
+ *  '0' on success.=0A=
+ * Description:=0A=
+ *  Verify that EEPROM in the xena can be programmed using I2C_CONTROL =0A=
+ *  register.=0A=
+ */=0A=
+static int s2io_eepromTest(nic_t * sp, uint64_t * data)=0A=
+{=0A=
+	int fail =3D 0, ret_data;=0A=
+=0A=
+	/* Test Write Error at offset 0 */=0A=
+	if (!writeEeprom(sp, 0, 0, 3))=0A=
+		fail =3D 1;=0A=
+=0A=
+	/* Test Write at offset 4f0 */=0A=
+	if (writeEeprom(sp, 0x4F0, 0x01234567, 3))=0A=
+		fail =3D 1;=0A=
+	if ((ret_data =3D readEeprom(sp, 0x4f0)) < 0)=0A=
+		fail =3D 1;=0A=
+=0A=
+	if (ret_data !=3D 0x01234567)=0A=
+		fail =3D 1;=0A=
+=0A=
+	/* Reset the EEPROM data go FFFF */=0A=
+	writeEeprom(sp, 0x4F0, 0xFFFFFFFF, 3);=0A=
+=0A=
+	/* Test Write Request Error at offset 0x7c */=0A=
+	if (!writeEeprom(sp, 0x07C, 0, 3))=0A=
+		fail =3D 1;=0A=
+=0A=
+	/* Test Write Request at offset 0x7fc */=0A=
+	if (writeEeprom(sp, 0x7FC, 0x01234567, 3))=0A=
+		fail =3D 1;=0A=
+	if ((ret_data =3D readEeprom(sp, 0x7FC)) < 0)=0A=
+		fail =3D 1;=0A=
+=0A=
+	if (ret_data !=3D 0x01234567)=0A=
+		fail =3D 1;=0A=
+=0A=
+	/* Reset the EEPROM data go FFFF */=0A=
+	writeEeprom(sp, 0x7FC, 0xFFFFFFFF, 3);=0A=
+=0A=
+	/* Test Write Error at offset 0x80 */=0A=
+	if (!writeEeprom(sp, 0x080, 0, 3))=0A=
+		fail =3D 1;=0A=
+=0A=
+	/* Test Write Error at offset 0xfc */=0A=
+	if (!writeEeprom(sp, 0x0FC, 0, 3))=0A=
+		fail =3D 1;=0A=
+=0A=
+	/* Test Write Error at offset 0x100 */=0A=
+	if (!writeEeprom(sp, 0x100, 0, 3))=0A=
+		fail =3D 1;=0A=
+=0A=
+	/* Test Write Error at offset 4ec */=0A=
+	if (!writeEeprom(sp, 0x4EC, 0, 3))=0A=
+		fail =3D 1;=0A=
+=0A=
+	*data =3D fail;=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Input Argument/s: =0A=
+ *  sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ *  data - variable that returns the result of each of the test =
conducted by =0A=
+ *  	the driver.=0A=
+ * Return value:=0A=
+ *  '0' on success and -1 on failure.=0A=
+ * Description:=0A=
+ *  This invokes the MemBist test of the card. We give around=0A=
+ *  2 secs time for the Test to complete. If it's still not complete=0A=
+ *  within this peiod, we consider that the test failed. =0A=
+ */=0A=
+static int s2io_bistTest(nic_t * sp, uint64_t * data)=0A=
+{=0A=
+	u8 bist =3D 0;=0A=
+	int cnt =3D 0, ret =3D -1;=0A=
+=0A=
+	pci_read_config_byte(sp->pdev, PCI_BIST, &bist);=0A=
+	bist |=3D PCI_BIST_START;=0A=
+	pci_write_config_word(sp->pdev, PCI_BIST, bist);=0A=
+=0A=
+	while (cnt < 20) {=0A=
+		pci_read_config_byte(sp->pdev, PCI_BIST, &bist);=0A=
+		if (!(bist & PCI_BIST_START)) {=0A=
+			*data =3D (bist & PCI_BIST_CODE_MASK);=0A=
+			ret =3D 0;=0A=
+			break;=0A=
+		}=0A=
+		set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+		schedule_timeout(HZ / 10);=0A=
+		cnt++;=0A=
+	}=0A=
+=0A=
+	return ret;=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Input Argument/s: =0A=
+ *  sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ *  data - variable that returns the result of each of the test =
conducted by =0A=
+ *  	the driver.=0A=
+ * Return value:=0A=
+ *  '0' on success.=0A=
+ * Description:=0A=
+ *  The function verifies the link state of the NIC and updates the =
input =0A=
+ *  argument 'data' appropriately.=0A=
+ */=0A=
+static int s2io_linkTest(nic_t * sp, uint64_t * data)=0A=
+{=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+	u64 val64;=0A=
+=0A=
+	val64 =3D readq(&bar0->adapter_status);=0A=
+	if (val64 & ADAPTER_STATUS_RMAC_LOCAL_FAULT)=0A=
+		*data =3D 1;=0A=
+=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Input Argument/s: =0A=
+ *  sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ *  data - variable that returns the result of each of the test =
conducted by =0A=
+ *  	the driver.=0A=
+ * Return value:=0A=
+ *  '0' on success.=0A=
+ * Description:=0A=
+ *  This is one of the offline test that tests the read and write =0A=
+ *  access to the RldRam chip on the NIC.=0A=
+ */=0A=
+static int s2io_rldramTest(nic_t * sp, uint64_t * data)=0A=
+{=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+	u64 val64;=0A=
+	int cnt, iteration =3D 0, test_pass =3D 0;=0A=
+=0A=
+	val64 =3D readq(&bar0->adapter_control);=0A=
+	val64 &=3D ~ADAPTER_ECC_EN;=0A=
+	writeq(val64, &bar0->adapter_control);=0A=
+=0A=
+	val64 =3D readq(&bar0->mc_rldram_test_ctrl);=0A=
+	val64 |=3D MC_RLDRAM_TEST_MODE;=0A=
+	writeq(val64, &bar0->mc_rldram_test_ctrl);=0A=
+=0A=
+	val64 =3D readq(&bar0->mc_rldram_mrs);=0A=
+	val64 |=3D MC_RLDRAM_QUEUE_SIZE_ENABLE;=0A=
+	writeq(val64, &bar0->mc_rldram_mrs);=0A=
+=0A=
+	val64 |=3D MC_RLDRAM_MRS_ENABLE;=0A=
+	writeq(val64, &bar0->mc_rldram_mrs);=0A=
+=0A=
+	while (iteration < 2) {=0A=
+		val64 =3D 0x55555555aaaa0000ULL;=0A=
+		if (iteration =3D=3D 1) {=0A=
+			val64 ^=3D 0xFFFFFFFFFFFF0000ULL;=0A=
+		}=0A=
+		writeq(val64, &bar0->mc_rldram_test_d0);=0A=
+=0A=
+		val64 =3D 0xaaaa5a5555550000ULL;=0A=
+		if (iteration =3D=3D 1) {=0A=
+			val64 ^=3D 0xFFFFFFFFFFFF0000ULL;=0A=
+		}=0A=
+		writeq(val64, &bar0->mc_rldram_test_d1);=0A=
+=0A=
+		val64 =3D 0x55aaaaaaaa5a0000ULL;=0A=
+		if (iteration =3D=3D 1) {=0A=
+			val64 ^=3D 0xFFFFFFFFFFFF0000ULL;=0A=
+		}=0A=
+		writeq(val64, &bar0->mc_rldram_test_d2);=0A=
+=0A=
+		val64 =3D (u64) (0x0000003fffff0000ULL);=0A=
+		writeq(val64, &bar0->mc_rldram_test_add);=0A=
+=0A=
+=0A=
+		val64 =3D MC_RLDRAM_TEST_MODE;=0A=
+		writeq(val64, &bar0->mc_rldram_test_ctrl);=0A=
+=0A=
+		val64 |=3D=0A=
+		    MC_RLDRAM_TEST_MODE | MC_RLDRAM_TEST_WRITE |=0A=
+		    MC_RLDRAM_TEST_GO;=0A=
+		writeq(val64, &bar0->mc_rldram_test_ctrl);=0A=
+=0A=
+		for (cnt =3D 0; cnt < 5; cnt++) {=0A=
+			val64 =3D readq(&bar0->mc_rldram_test_ctrl);=0A=
+			if (val64 & MC_RLDRAM_TEST_DONE)=0A=
+				break;=0A=
+			set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+			schedule_timeout(HZ / 5);=0A=
+		}=0A=
+=0A=
+		if (cnt =3D=3D 5)=0A=
+			break;=0A=
+=0A=
+		val64 =3D MC_RLDRAM_TEST_MODE;=0A=
+		writeq(val64, &bar0->mc_rldram_test_ctrl);=0A=
+=0A=
+		val64 |=3D MC_RLDRAM_TEST_MODE | MC_RLDRAM_TEST_GO;=0A=
+		writeq(val64, &bar0->mc_rldram_test_ctrl);=0A=
+=0A=
+		for (cnt =3D 0; cnt < 5; cnt++) {=0A=
+			val64 =3D readq(&bar0->mc_rldram_test_ctrl);=0A=
+			if (val64 & MC_RLDRAM_TEST_DONE)=0A=
+				break;=0A=
+			set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+			schedule_timeout(HZ / 2);=0A=
+		}=0A=
+=0A=
+		if (cnt =3D=3D 5)=0A=
+			break;=0A=
+=0A=
+		val64 =3D readq(&bar0->mc_rldram_test_ctrl);=0A=
+		if (val64 & MC_RLDRAM_TEST_PASS)=0A=
+			test_pass =3D 1;=0A=
+=0A=
+		iteration++;=0A=
+	}=0A=
+=0A=
+	if (!test_pass)=0A=
+		*data =3D 1;=0A=
+	else=0A=
+		*data =3D 0;=0A=
+=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Input Argument/s: =0A=
+ *  sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   	s2io_nic structure.=0A=
+ *  ethtest - pointer to a ethtool command specific structure that will =
be=0A=
+ *  	returned to the user.=0A=
+ *  data - variable that returns the result of each of the test =
conducted by =0A=
+ *  	the driver.=0A=
+ * Return value:=0A=
+ *  SUCCESS on success and an appropriate -1 on failure.=0A=
+ * Description:=0A=
+ *  This function conducts 6 tests ( 4 offline and 2 online) to =
determine=0A=
+ *  	the health of the card.=0A=
+ */=0A=
+static void s2io_ethtool_test(struct net_device *dev,=0A=
+			      struct ethtool_test *ethtest,=0A=
+			      uint64_t * data)=0A=
+{=0A=
+	nic_t *sp =3D dev->priv;=0A=
+	int orig_state =3D netif_running(sp->dev);=0A=
+=0A=
+	if (ethtest->flags =3D=3D ETH_TEST_FL_OFFLINE) {=0A=
+		/* Offline Tests. */=0A=
+		if (orig_state) {=0A=
+			s2io_close(sp->dev);=0A=
+			s2io_set_swapper(sp);=0A=
+		} else=0A=
+			s2io_set_swapper(sp);=0A=
+=0A=
+		if (s2io_registerTest(sp, &data[0]))=0A=
+			ethtest->flags |=3D ETH_TEST_FL_FAILED;=0A=
+=0A=
+		s2io_reset(sp);=0A=
+		s2io_set_swapper(sp);=0A=
+=0A=
+		if (s2io_rldramTest(sp, &data[3]))=0A=
+			ethtest->flags |=3D ETH_TEST_FL_FAILED;=0A=
+=0A=
+		s2io_reset(sp);=0A=
+		s2io_set_swapper(sp);=0A=
+=0A=
+		if (s2io_eepromTest(sp, &data[1]))=0A=
+			ethtest->flags |=3D ETH_TEST_FL_FAILED;=0A=
+=0A=
+		if (s2io_bistTest(sp, &data[4]))=0A=
+			ethtest->flags |=3D ETH_TEST_FL_FAILED;=0A=
+=0A=
+		if (orig_state)=0A=
+			s2io_open(sp->dev);=0A=
+=0A=
+		data[2] =3D 0;=0A=
+	} else {=0A=
+		/* Online Tests. */=0A=
+		if (!orig_state) {=0A=
+			DBG_PRINT(ERR_DBG,=0A=
+				  "%s: is not up, cannot run test\n",=0A=
+				  dev->name);=0A=
+			data[0] =3D -1;=0A=
+			data[1] =3D -1;=0A=
+			data[2] =3D -1;=0A=
+			data[3] =3D -1;=0A=
+			data[4] =3D -1;=0A=
+		}=0A=
+=0A=
+		if (s2io_linkTest(sp, &data[2]))=0A=
+			ethtest->flags |=3D ETH_TEST_FL_FAILED;=0A=
+=0A=
+		data[0] =3D 0;=0A=
+		data[1] =3D 0;=0A=
+		data[3] =3D 0;=0A=
+		data[4] =3D 0;=0A=
+	}=0A=
+}=0A=
+=0A=
+static void s2io_get_ethtool_stats(struct net_device *dev,=0A=
+				   struct ethtool_stats *estats,=0A=
+				   u64 * tmp_stats)=0A=
+{=0A=
+	int i =3D 0;=0A=
+	nic_t *sp =3D dev->priv;=0A=
+	StatInfo_t *stat_info =3D sp->mac_control.StatsInfo;=0A=
+=0A=
+	tmp_stats[i++] =3D stat_info->tmac_frms;=0A=
+	tmp_stats[i++] =3D stat_info->tmac_data_octets;=0A=
+	tmp_stats[i++] =3D stat_info->tmac_drop_frms;=0A=
+	tmp_stats[i++] =3D stat_info->tmac_mcst_frms;=0A=
+	tmp_stats[i++] =3D stat_info->tmac_bcst_frms;=0A=
+	tmp_stats[i++] =3D stat_info->tmac_pause_ctrl_frms;=0A=
+	tmp_stats[i++] =3D stat_info->tmac_any_err_frms;=0A=
+	tmp_stats[i++] =3D stat_info->tmac_vld_ip_octets;=0A=
+	tmp_stats[i++] =3D stat_info->tmac_vld_ip;=0A=
+	tmp_stats[i++] =3D stat_info->tmac_drop_ip;=0A=
+	tmp_stats[i++] =3D stat_info->tmac_icmp;=0A=
+	tmp_stats[i++] =3D stat_info->tmac_rst_tcp;=0A=
+	tmp_stats[i++] =3D stat_info->tmac_tcp;=0A=
+	tmp_stats[i++] =3D stat_info->tmac_udp;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_vld_frms;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_data_octets;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_fcs_err_frms;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_drop_frms;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_vld_mcst_frms;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_vld_bcst_frms;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_in_rng_len_err_frms;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_long_frms;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_pause_ctrl_frms;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_discarded_frms;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_usized_frms;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_osized_frms;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_frag_frms;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_jabber_frms;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_ip;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_ip_octets;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_hdr_err_ip;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_drop_ip;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_icmp;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_tcp;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_udp;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_err_drp_udp;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_pause_cnt;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_accepted_ip;=0A=
+	tmp_stats[i++] =3D stat_info->rmac_err_tcp;=0A=
+}=0A=
+=0A=
+int s2io_ethtool_get_regs_len(struct net_device *dev)=0A=
+{=0A=
+	return (XENA_REG_SPACE);=0A=
+}=0A=
+=0A=
+=0A=
+u32 s2io_ethtool_get_rx_csum(struct net_device * dev)=0A=
+{=0A=
+	nic_t *sp =3D dev->priv;=0A=
+=0A=
+	return (sp->rx_csum);=0A=
+}=0A=
+int s2io_ethtool_set_rx_csum(struct net_device *dev, u32 data)=0A=
+{=0A=
+	nic_t *sp =3D dev->priv;=0A=
+=0A=
+	if (data)=0A=
+		sp->rx_csum =3D 1;=0A=
+	else=0A=
+		sp->rx_csum =3D 0;=0A=
+=0A=
+	return 0;=0A=
+}=0A=
+int s2io_get_eeprom_len(struct net_device *dev)=0A=
+{=0A=
+	return (XENA_EEPROM_SPACE);=0A=
+}=0A=
+=0A=
+int s2io_ethtool_self_test_count(struct net_device *dev)=0A=
+{=0A=
+	return (S2IO_TEST_LEN);=0A=
+}=0A=
+void s2io_ethtool_get_strings(struct net_device *dev,=0A=
+			      u32 stringset, u8 * data)=0A=
+{=0A=
+	switch (stringset) {=0A=
+	case ETH_SS_TEST:=0A=
+		memcpy(data, s2io_gstrings, S2IO_STRINGS_LEN);=0A=
+		break;=0A=
+	case ETH_SS_STATS:=0A=
+		memcpy(data, &ethtool_stats_keys,=0A=
+		       sizeof(ethtool_stats_keys));=0A=
+	}=0A=
+}=0A=
+static int s2io_ethtool_get_stats_count(struct net_device *dev)=0A=
+{=0A=
+	return (S2IO_STAT_LEN);=0A=
+}=0A=
+=0A=
+static struct ethtool_ops netdev_ethtool_ops =3D {=0A=
+	.get_settings =3D s2io_ethtool_gset,=0A=
+	.set_settings =3D s2io_ethtool_sset,=0A=
+	.get_drvinfo =3D s2io_ethtool_gdrvinfo,=0A=
+	.get_regs_len =3D s2io_ethtool_get_regs_len,=0A=
+	.get_regs =3D s2io_ethtool_gregs,=0A=
+	.get_link =3D ethtool_op_get_link,=0A=
+	.get_eeprom_len =3D s2io_get_eeprom_len,=0A=
+	.get_eeprom =3D s2io_ethtool_geeprom,=0A=
+	.set_eeprom =3D s2io_ethtool_seeprom,=0A=
+	.get_pauseparam =3D s2io_ethtool_getpause_data,=0A=
+	.set_pauseparam =3D s2io_ethtool_setpause_data,=0A=
+	.get_rx_csum =3D s2io_ethtool_get_rx_csum,=0A=
+	.set_rx_csum =3D s2io_ethtool_set_rx_csum,=0A=
+	.get_tx_csum =3D ethtool_op_get_tx_csum,=0A=
+	.set_tx_csum =3D ethtool_op_set_tx_csum,=0A=
+	.get_sg =3D ethtool_op_get_sg,=0A=
+	.set_sg =3D ethtool_op_set_sg,=0A=
+#ifdef NETIF_F_TSO=0A=
+	.get_tso =3D ethtool_op_get_tso,=0A=
+	.set_tso =3D ethtool_op_set_tso,=0A=
+#endif=0A=
+	.self_test_count =3D s2io_ethtool_self_test_count,=0A=
+	.self_test =3D s2io_ethtool_test,=0A=
+	.get_strings =3D s2io_ethtool_get_strings,=0A=
+	.phys_id =3D s2io_ethtool_idnic,=0A=
+	.get_stats_count =3D s2io_ethtool_get_stats_count,=0A=
+	.get_ethtool_stats =3D s2io_get_ethtool_stats=0A=
+};=0A=
+=0A=
+/*=0A=
+ *  Input Argument/s: =0A=
+ *  dev -   Device pointer.=0A=
+ *  ifr -   An IOCTL specefic structure, that can contain a pointer to=0A=
+ *      a proprietary structure used to pass information to the driver.=0A=
+ *  cmd -   This is used to distinguish between the different commands =
that=0A=
+ *      can be passed to the IOCTL functions.=0A=
+ *  Return value:=0A=
+ *  '0' on success and an appropriate (-)ve integer as defined in =
errno.h=0A=
+ *  file on failure.=0A=
+ *  Description:=0A=
+ *  This function has support for ethtool, adding multiple MAC =
addresses on =0A=
+ *  the NIC and some DBG commands for the util tool.=0A=
+ */=0A=
+int s2io_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)=0A=
+{=0A=
+	return -EOPNOTSUPP;=0A=
+}=0A=
+=0A=
+/*=0A=
+ *  Input Argument/s: =0A=
+ *   dev - device pointer.=0A=
+ *   new_mtu - the new MTU size for the device.=0A=
+ *  Return value:=0A=
+ *   '0' on success and an appropriate (-)ve integer as defined in =
errno.h=0A=
+ *   file on failure.=0A=
+ *  Description:=0A=
+ *   A driver entry point to change MTU size for the device. Before =
changing=0A=
+ *   the MTU the device must be stopped.=0A=
+ */=0A=
+int s2io_change_mtu(struct net_device *dev, int new_mtu)=0A=
+{=0A=
+	nic_t *sp =3D dev->priv;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+	register u64 val64;=0A=
+=0A=
+	if (netif_running(dev)) {=0A=
+		DBG_PRINT(ERR_DBG, "%s: Must be stopped to ", dev->name);=0A=
+		DBG_PRINT(ERR_DBG, "change its MTU \n");=0A=
+		return -EBUSY;=0A=
+	}=0A=
+=0A=
+	if ((new_mtu < MIN_MTU) || (new_mtu > S2IO_JUMBO_SIZE)) {=0A=
+		DBG_PRINT(ERR_DBG, "%s: MTU size is invalid.\n",=0A=
+			  dev->name);=0A=
+		return -EPERM;=0A=
+	}=0A=
+=0A=
+/* Set the new MTU into the PYLD register of the NIC */=0A=
+	val64 =3D new_mtu;=0A=
+	writeq(vBIT(val64, 2, 14), &bar0->rmac_max_pyld_len);=0A=
+=0A=
+	dev->mtu =3D new_mtu;=0A=
+=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+/*=0A=
+ *  Input Argument/s: =0A=
+ *  dev_adr - address of the device structure in dma_addr_t format.=0A=
+ *  Return value:=0A=
+ *  void.=0A=
+ *  Description:=0A=
+ *  This is the tasklet or the bottom half of the ISR. This is=0A=
+ *  an extension of the ISR which is scheduled by the scheduler to be =
run =0A=
+ *  when the load on the CPU is low. All low priority tasks of the ISR =
can=0A=
+ *  be pushed into the tasklet. For now the tasklet is used only to =0A=
+ *  replenish the Rx buffers in the Rx buffer descriptors.=0A=
+ */=0A=
+static void s2io_tasklet(unsigned long dev_addr)=0A=
+{=0A=
+	struct net_device *dev =3D (struct net_device *) dev_addr;=0A=
+	nic_t *sp =3D dev->priv;=0A=
+	int i, ret;=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+=0A=
+	mac_control =3D &sp->mac_control;=0A=
+	config =3D &sp->config;=0A=
+=0A=
+	if (!TASKLET_IN_USE) {=0A=
+		for (i =3D 0; i < config->RxRingNum; i++) {=0A=
+			ret =3D fill_rx_buffers(sp, i);=0A=
+			if (ret =3D=3D -ENOMEM) {=0A=
+				DBG_PRINT(ERR_DBG, "%s: Out of ",=0A=
+					  dev->name);=0A=
+				DBG_PRINT(ERR_DBG, "memory in tasklet\n");=0A=
+				return;=0A=
+			} else if (ret =3D=3D -EFILL) {=0A=
+				DBG_PRINT(ERR_DBG,=0A=
+					  "%s: Rx Ring %d is full\n",=0A=
+					  dev->name, i);=0A=
+				return;=0A=
+			}=0A=
+		}=0A=
+		clear_bit(0, (unsigned long *) (&sp->tasklet_status));=0A=
+	}=0A=
+}=0A=
+=0A=
+=0A=
+/*=0A=
+ * Description:=0A=
+ * =0A=
+ */=0A=
+static void s2io_set_link(unsigned long data)=0A=
+{=0A=
+	nic_t *nic =3D (nic_t *) data;=0A=
+	struct net_device *dev =3D nic->dev;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;=0A=
+	register u64 val64, err_reg;=0A=
+=0A=
+	/* Allow a small delay for the NICs self initiated =0A=
+	 * cleanup to complete.=0A=
+	 */=0A=
+	set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+	schedule_timeout(HZ / 10);=0A=
+=0A=
+	val64 =3D readq(&bar0->adapter_status);=0A=
+	if (verify_xena_quiescence(val64, nic->device_enabled_once)) {=0A=
+		/* Acknowledge interrupt and clear the R1 register */=0A=
+		err_reg =3D readq(&bar0->mac_rmac_err_reg);=0A=
+		writeq(err_reg, &bar0->mac_rmac_err_reg);=0A=
+=0A=
+		if (LINK_IS_UP(val64)) {=0A=
+			val64 =3D readq(&bar0->adapter_control);=0A=
+			val64 |=3D ADAPTER_CNTL_EN;=0A=
+			writeq(val64, &bar0->adapter_control);=0A=
+			val64 |=3D ADAPTER_LED_ON;=0A=
+			writeq(val64, &bar0->adapter_control);=0A=
+			val64 =3D readq(&bar0->adapter_status);=0A=
+			if (!LINK_IS_UP(val64)) {=0A=
+				DBG_PRINT(ERR_DBG, "%s:", dev->name);=0A=
+				DBG_PRINT(ERR_DBG, " Link down");=0A=
+				DBG_PRINT(ERR_DBG, "after ");=0A=
+				DBG_PRINT(ERR_DBG, "enabling ");=0A=
+				DBG_PRINT(ERR_DBG, "device \n");=0A=
+			}=0A=
+			if (nic->device_enabled_once =3D=3D FALSE) {=0A=
+				nic->device_enabled_once =3D TRUE;=0A=
+			}=0A=
+			s2io_link(nic, LINK_UP);=0A=
+		} else {=0A=
+			s2io_link(nic, LINK_DOWN);=0A=
+		}=0A=
+	} else {		/* NIC is not Quiescent. */=0A=
+		DBG_PRINT(ERR_DBG, "%s: Error: ", dev->name);=0A=
+		DBG_PRINT(ERR_DBG, "device is not Quiescent\n");=0A=
+		netif_stop_queue(dev);=0A=
+	}=0A=
+}=0A=
+=0A=
+/*=0A=
+ * Description:=0A=
+ * This function is scheduled to be run by the s2io_tx_watchdog=0A=
+ * function after 0.5 secs to reset the NIC. The idea is to reduce =0A=
+ * the run time of the watch dog routine which is run holding a=0A=
+ * spin lock.=0A=
+ */=0A=
+static void s2io_restart_nic(unsigned long data)=0A=
+{=0A=
+	struct net_device *dev =3D (struct net_device *) data;=0A=
+	nic_t *sp =3D dev->priv;=0A=
+=0A=
+	s2io_close(dev);=0A=
+	sp->device_close_flag =3D TRUE;=0A=
+	s2io_open(dev);=0A=
+	DBG_PRINT(ERR_DBG,=0A=
+		  "%s: was reset by Tx watchdog timer.\n", dev->name);=0A=
+}=0A=
+=0A=
+/*=0A=
+ *  Input Argument/s: =0A=
+ *  dev - device pointer.=0A=
+ *  Return value:=0A=
+ *  void=0A=
+ *  Description:=0A=
+ *  This function is triggered if the Tx Queue is stopped=0A=
+ *  for a pre-defined amount of time when the Interface is still up.=0A=
+ *  If the Interface is jammed in such a situation, the hardware is=0A=
+ *  reset (by s2io_close) and restarted again (by s2io_open) to=0A=
+ *  overcome any problem that might have been caused in the hardware.=0A=
+ */=0A=
+static void s2io_tx_watchdog(struct net_device *dev)=0A=
+{=0A=
+	nic_t *sp =3D dev->priv;=0A=
+=0A=
+	if (netif_carrier_ok(dev)) {=0A=
+		schedule_work(&sp->rst_timer_task);=0A=
+	}=0A=
+}=0A=
+=0A=
+/*=0A=
+ *  Input Argument/s: =0A=
+ *   sp - private member of the device structure, which is a pointer to =
the =0A=
+ *   s2io_nic structure.=0A=
+ *   skb - the socket buffer pointer.=0A=
+ *   len - length of the packet=0A=
+ *   cksum - FCS checksum of the frame.=0A=
+ *  ring_no - the ring from which this RxD was extracted.=0A=
+ *  Return value:=0A=
+ *   SUCCESS on success and -1 on failure.=0A=
+ *  Description: =0A=
+ *   This function is called by the Tx interrupt serivce routine to =
perform =0A=
+ *   some OS related operations on the SKB before passing it to the =
upper=0A=
+ *   layers. It mainly checks if the checksum is OK, if so adds it to =
the=0A=
+ *   SKBs cksum variable, increments the Rx packet count and passes the =
SKB=0A=
+ *   to the upper layer. If the checksum is wrong, it increments the Rx=0A=
+ *   packet error count, frees the SKB and returns error.=0A=
+ */=0A=
+static int rxOsmHandler(nic_t * sp, u16 len, RxD_t * rxdp, int ring_no)=0A=
+{=0A=
+	struct net_device *dev =3D (struct net_device *) sp->dev;=0A=
+	struct sk_buff *skb =3D=0A=
+	    (struct sk_buff *) ((unsigned long) rxdp->Host_Control);=0A=
+	u16 l3_csum, l4_csum;=0A=
+=0A=
+	l3_csum =3D RXD_GET_L3_CKSUM(rxdp->Control_1);=0A=
+	if ((rxdp->Control_1 & TCP_OR_UDP_FRAME) && (sp->rx_csum)) {=0A=
+		l4_csum =3D RXD_GET_L4_CKSUM(rxdp->Control_1);=0A=
+		if ((l3_csum =3D=3D L3_CKSUM_OK) && (l4_csum =3D=3D L4_CKSUM_OK)) {=0A=
+			/* NIC verifies if the Checksum of the received=0A=
+			 * frame is Ok or not and accordingly returns=0A=
+			 * a flag in the RxD.=0A=
+			 */=0A=
+			skb->ip_summed =3D CHECKSUM_UNNECESSARY;=0A=
+		} else {=0A=
+			/* =0A=
+			 * Packet with erroneous checksum, let the =0A=
+			 * upper layers deal with it.=0A=
+			 */=0A=
+			skb->ip_summed =3D CHECKSUM_NONE;=0A=
+		}=0A=
+	} else {=0A=
+		skb->ip_summed =3D CHECKSUM_NONE;=0A=
+	}=0A=
+=0A=
+	skb->dev =3D dev;=0A=
+	skb_put(skb, len);=0A=
+	skb->protocol =3D eth_type_trans(skb, dev);=0A=
+=0A=
+#ifdef CONFIG_S2IO_NAPI=0A=
+	netif_receive_skb(skb);=0A=
+#else=0A=
+	netif_rx(skb);=0A=
+#endif=0A=
+=0A=
+	dev->last_rx =3D jiffies;=0A=
+#if DEBUG_ON=0A=
+	sp->rxpkt_cnt++;=0A=
+#endif=0A=
+	sp->rx_pkt_count++;=0A=
+	sp->stats.rx_packets++;=0A=
+	sp->stats.rx_bytes +=3D len;=0A=
+	sp->rxpkt_bytes +=3D len;=0A=
+=0A=
+	atomic_dec(&sp->rx_bufs_left[ring_no]);=0A=
+	rxdp->Host_Control =3D 0;=0A=
+	return SUCCESS;=0A=
+}=0A=
+=0A=
+int check_for_txSpace(nic_t * sp)=0A=
+{=0A=
+	u32 put_off, get_off, queue_len;=0A=
+	int ret =3D TRUE, i;=0A=
+=0A=
+	for (i =3D 0; i < sp->config.TxFIFONum; i++) {=0A=
+		queue_len =3D sp->mac_control.tx_curr_put_info[i].fifo_len=0A=
+		    + 1;=0A=
+		put_off =3D sp->mac_control.tx_curr_put_info[i].offset;=0A=
+		get_off =3D sp->mac_control.tx_curr_get_info[i].offset;=0A=
+		if (((put_off + 1) % queue_len) =3D=3D get_off) {=0A=
+			ret =3D FALSE;=0A=
+			break;=0A=
+		}=0A=
+	}=0A=
+=0A=
+	return ret;=0A=
+}=0A=
+=0A=
+/*=0A=
+*  Input Argument/s: =0A=
+*   sp - private member of the device structure, which is a pointer to =
the =0A=
+*   s2io_nic structure.=0A=
+*   link - inidicates whether link is UP/DOWN.=0A=
+*  Return value:=0A=
+*   void.=0A=
+*  Description:=0A=
+*   This function stops/starts the Tx queue depending on whether the =
link=0A=
+*   status of the NIC is is down or up. This is called by the Alarm =
interrupt =0A=
+*  handler whenever a link change interrupt comes up. =0A=
+*/=0A=
+void s2io_link(nic_t * sp, int link)=0A=
+{=0A=
+	struct net_device *dev =3D (struct net_device *) sp->dev;=0A=
+=0A=
+	if (link !=3D sp->last_link_state) {=0A=
+		if (link =3D=3D LINK_DOWN) {=0A=
+			DBG_PRINT(ERR_DBG, "%s: Link down\n", dev->name);=0A=
+			netif_carrier_off(dev);=0A=
+			netif_stop_queue(dev);=0A=
+		} else {=0A=
+			DBG_PRINT(ERR_DBG, "%s: Link Up\n", dev->name);=0A=
+			netif_carrier_on(dev);=0A=
+			if (check_for_txSpace(sp) =3D=3D TRUE) {=0A=
+				/* Don't wake the queue, if we know there=0A=
+				 * are no free TxDs available.=0A=
+				 */=0A=
+				netif_wake_queue(dev);=0A=
+			}=0A=
+		}=0A=
+	}=0A=
+	sp->last_link_state =3D link;=0A=
+}=0A=
+=0A=
+/*=0A=
+*  Input Argument/s: =0A=
+*   pdev - structure containing the PCI related information of the =
device.=0A=
+*  Return value:=0A=
+*   returns the revision ID of the device.=0A=
+*  Description:=0A=
+*   Function to identify the Revision ID of xena.=0A=
+*/=0A=
+int get_xena_rev_id(struct pci_dev *pdev)=0A=
+{=0A=
+	u8 id =3D 0;=0A=
+	int ret;=0A=
+	ret =3D pci_read_config_byte(pdev, PCI_REVISION_ID, (u8 *) & id);=0A=
+	return id;=0A=
+}=0A=
+=0A=
+/*=0A=
+*  Input Argument/s: =0A=
+*   sp - private member of the device structure, which is a pointer to =
the =0A=
+*   s2io_nic structure.=0A=
+*  Return value:=0A=
+*   void=0A=
+*  Description:=0A=
+*   This function initializes a few of the PCI and PCI-X configuration =
registers=0A=
+*   with recommended values.=0A=
+*/=0A=
+static void s2io_init_pci(nic_t * sp)=0A=
+{=0A=
+	u16 pci_cmd =3D 0;=0A=
+=0A=
+/* Enable Data Parity Error Recovery in PCI-X command register. */=0A=
+	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,=0A=
+			     &(sp->pcix_cmd));=0A=
+	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,=0A=
+			      (sp->pcix_cmd | 1));=0A=
+	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,=0A=
+			     &(sp->pcix_cmd));=0A=
+=0A=
+/* Set the PErr Response bit in PCI command register. */=0A=
+	pci_read_config_word(sp->pdev, PCI_COMMAND, &pci_cmd);=0A=
+	pci_write_config_word(sp->pdev, PCI_COMMAND,=0A=
+			      (pci_cmd | PCI_COMMAND_PARITY));=0A=
+	pci_read_config_word(sp->pdev, PCI_COMMAND, &pci_cmd);=0A=
+=0A=
+/* Set user specified value in Latency Timer */=0A=
+	if (latency_timer) {=0A=
+		pci_write_config_byte(sp->pdev, PCI_LATENCY_TIMER,=0A=
+				      latency_timer);=0A=
+		pci_read_config_byte(sp->pdev, PCI_LATENCY_TIMER,=0A=
+				     &latency_timer);=0A=
+	}=0A=
+=0A=
+/* Set MMRB count to 4096 in PCI-X Command register. */=0A=
+	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,=0A=
+			      (sp->pcix_cmd | 0x0C));=0A=
+	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,=0A=
+			     &(sp->pcix_cmd));=0A=
+=0A=
+/* Setting Maximum outstanding splits to two for now. */=0A=
+	sp->pcix_cmd &=3D 0xFF1F;=0A=
+=0A=
+	sp->pcix_cmd |=3D=0A=
+	    XENA_MAX_OUTSTANDING_SPLITS(XENA_TWO_SPLIT_TRANSACTION);=0A=
+	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,=0A=
+			      sp->pcix_cmd);=0A=
+	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,=0A=
+			     &(sp->pcix_cmd));=0A=
+=0A=
+}=0A=
+=0A=
+MODULE_AUTHOR("Raghavendra Koushik <raghavendra.koushik@s2io.com>");=0A=
+MODULE_LICENSE("GPL");=0A=
+MODULE_PARM(ring_num, "1-" __MODULE_STRING(1) "i");=0A=
+MODULE_PARM(frame_len, "1-" __MODULE_STRING(8) "i");=0A=
+MODULE_PARM(ring_len, "1-" __MODULE_STRING(8) "i");=0A=
+MODULE_PARM(fifo_num, "1-" __MODULE_STRING(1) "i");=0A=
+MODULE_PARM(fifo_len, "1-" __MODULE_STRING(8) "i");=0A=
+MODULE_PARM(rx_prio, "1-" __MODULE_STRING(1) "i");=0A=
+MODULE_PARM(tx_prio, "1-" __MODULE_STRING(1) "i");=0A=
+MODULE_PARM(latency_timer, "1-" __MODULE_STRING(1) "i");=0A=
+=0A=
+/*=0A=
+*  Input Argument/s: =0A=
+*   pdev - structure containing the PCI related information of the =
device.=0A=
+*   pre -  the List of PCI devices supported by the driver listed in =
s2io_tbl.=0A=
+*  Return value:=0A=
+*   returns '0' on success and negative on failure.=0A=
+*  Description:=0A=
+*  The function initializes an adapter identified by the pci_dec =
structure.=0A=
+*  All OS related initialization including memory and device structure =
and =0A=
+*  initlaization of the device private variable is done. Also the =
swapper =0A=
+*  control register is initialized to enable read and write into the =
I/O =0A=
+*  registers of the device.=0A=
+*  =0A=
+*/=0A=
+static int __devinit=0A=
+s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)=0A=
+{=0A=
+	nic_t *sp;=0A=
+	struct net_device *dev;=0A=
+	char *dev_name =3D "S2IO 10GE NIC";=0A=
+	int i, j, ret;=0A=
+	int dma_flag =3D FALSE;=0A=
+	u32 mac_up, mac_down;=0A=
+	u64 val64 =3D 0, tmp64 =3D 0;=0A=
+	XENA_dev_config_t *bar0 =3D NULL;=0A=
+	u16 subid;=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+=0A=
+=0A=
+	if ((ret =3D pci_enable_device(pdev))) {=0A=
+		DBG_PRINT(ERR_DBG,=0A=
+			  "s2io_init_nic: pci_enable_device failed\n");=0A=
+		return ret;=0A=
+	}=0A=
+=0A=
+	if (!pci_set_dma_mask(pdev, 0xffffffffffffffffULL)) {=0A=
+		DBG_PRINT(INIT_DBG, "s2io_init_nic: Using 64bit DMA\n");=0A=
+		dma_flag =3D TRUE;=0A=
+		if (pci_set_consistent_dma_mask=0A=
+		    (pdev, 0xffffffffffffffffULL)) {=0A=
+			DBG_PRINT(ERR_DBG,=0A=
+				  "Unable to obtain 64bit DMA for \=0A=
+					consistent allocations\n");=0A=
+			pci_disable_device(pdev);=0A=
+			return -ENOMEM;=0A=
+		}=0A=
+	} else if (!pci_set_dma_mask(pdev, 0xffffffffUL)) {=0A=
+		DBG_PRINT(INIT_DBG, "s2io_init_nic: Using 32bit DMA\n");=0A=
+	} else {=0A=
+		pci_disable_device(pdev);=0A=
+		return -ENOMEM;=0A=
+	}=0A=
+=0A=
+	if (pci_request_regions(pdev, s2io_driver_name)) {=0A=
+		DBG_PRINT(ERR_DBG, "Request Regions failed\n"),=0A=
+		    pci_disable_device(pdev);=0A=
+		return -ENODEV;=0A=
+	}=0A=
+=0A=
+	dev =3D alloc_etherdev(sizeof(nic_t));=0A=
+	if (dev =3D=3D NULL) {=0A=
+		DBG_PRINT(ERR_DBG, "Device allocation failed\n");=0A=
+		pci_disable_device(pdev);=0A=
+		pci_release_regions(pdev);=0A=
+		return -ENODEV;=0A=
+	}=0A=
+=0A=
+	pci_set_master(pdev);=0A=
+	pci_set_drvdata(pdev, dev);=0A=
+	SET_MODULE_OWNER(dev);=0A=
+	SET_NETDEV_DEV(dev, &pdev->dev);=0A=
+=0A=
+	/*  Private member variable initialized to s2io NIC structure */=0A=
+	sp =3D dev->priv;=0A=
+	memset(sp, 0, sizeof(nic_t));=0A=
+	sp->dev =3D dev;=0A=
+	sp->pdev =3D pdev;=0A=
+	sp->vendor_id =3D pdev->vendor;=0A=
+	sp->device_id =3D pdev->device;=0A=
+	sp->high_dma_flag =3D dma_flag;=0A=
+	sp->irq =3D pdev->irq;=0A=
+	sp->device_enabled_once =3D FALSE;=0A=
+	strcpy(sp->name, dev_name);=0A=
+=0A=
+	/* Initialize some PCI/PCI-X fields of the NIC. */=0A=
+	s2io_init_pci(sp);=0A=
+=0A=
+	/* Setting the device configuration parameters.=0A=
+	 * Most of these parameters can be specified by the user during =0A=
+	 * module insertion as they are module loadable parameters. If =0A=
+	 * these parameters are not not specified during load time, they =0A=
+	 * are initialized with default values.=0A=
+	 */=0A=
+	mac_control =3D &sp->mac_control;=0A=
+	config =3D &sp->config;=0A=
+=0A=
+	/* Tx side parameters. */=0A=
+	config->TxFIFONum =3D fifo_num ? fifo_num : 1;=0A=
+=0A=
+	if (!fifo_len[0] && (fifo_num > 1)) {=0A=
+		printk(KERN_ERR "Fifo Lens not specified for all FIFOs\n");=0A=
+		goto init_failed;=0A=
+	}=0A=
+=0A=
+	if (fifo_len[0]) {=0A=
+		int cnt;=0A=
+=0A=
+		for (cnt =3D 0; fifo_len[cnt]; cnt++);=0A=
+		if (fifo_num) {=0A=
+			if (cnt < fifo_num) {=0A=
+				printk(KERN_ERR=0A=
+				       "Fifo Lens not specified for ");=0A=
+				printk(KERN_ERR "all FIFOs\n");=0A=
+				goto init_failed;=0A=
+			}=0A=
+		}=0A=
+		for (cnt =3D 0; cnt < config->TxFIFONum; cnt++) {=0A=
+			config->TxCfg[cnt].FifoLen =3D fifo_len[cnt];=0A=
+			config->TxCfg[cnt].FifoPriority =3D cnt;=0A=
+		}=0A=
+	} else {=0A=
+		config->TxCfg[0].FifoLen =3D DEFAULT_FIFO_LEN;=0A=
+		config->TxCfg[0].FifoPriority =3D 0;=0A=
+	}=0A=
+=0A=
+	config->TxIntrType =3D TXD_INT_TYPE_UTILZ;=0A=
+	for (i =3D 0; i < config->TxFIFONum; i++) {=0A=
+		if (config->TxCfg[i].FifoLen < 65) {=0A=
+			config->TxIntrType =3D TXD_INT_TYPE_PER_LIST;=0A=
+			break;=0A=
+		}=0A=
+	}=0A=
+=0A=
+	config->TxCfg[0].fNoSnoop =3D (NO_SNOOP_TXD | NO_SNOOP_TXD_BUFFER);=0A=
+	config->MaxTxDs =3D MAX_SKB_FRAGS;=0A=
+	config->TxFlow =3D TRUE;=0A=
+=0A=
+	/* Rx side parameters. */=0A=
+	config->RxRingNum =3D ring_num ? ring_num : 1;=0A=
+=0A=
+	if (ring_len[0]) {=0A=
+		int cnt;=0A=
+		for (cnt =3D 0; cnt < config->RxRingNum; cnt++) {=0A=
+			config->RxCfg[cnt].NumRxd =3D ring_len[cnt];=0A=
+			config->RxCfg[cnt].RingPriority =3D cnt;=0A=
+		}=0A=
+	} else {=0A=
+		int id;=0A=
+		if ((id =3D get_xena_rev_id(pdev)) =3D=3D 1) {=0A=
+			config->RxCfg[0].NumRxd =3D LARGE_RXD_CNT;=0A=
+=0A=
+		} else {=0A=
+			config->RxCfg[0].NumRxd =3D SMALL_RXD_CNT;=0A=
+		}=0A=
+		config->RxCfg[0].RingPriority =3D 0;=0A=
+	}=0A=
+	config->RxCfg[0].RingOrg =3D RING_ORG_BUFF1;=0A=
+	config->RxCfg[0].RxdThresh =3D DEFAULT_RXD_THRESHOLD;=0A=
+	config->RxCfg[0].fNoSnoop =3D (NO_SNOOP_RXD | NO_SNOOP_RXD_BUFFER);=0A=
+	config->RxCfg[0].RxD_BackOff_Interval =3D TBD;=0A=
+	config->RxFlow =3D TRUE;=0A=
+=0A=
+	/* Miscellaneous parameters. */=0A=
+	config->RxVLANEnable =3D TRUE;=0A=
+	config->MTU =3D MAX_MTU_VLAN;=0A=
+	config->JumboEnable =3D FALSE;=0A=
+=0A=
+	/*  Setting Mac Control parameters */=0A=
+	mac_control->txdl_len =3D MAX_SKB_FRAGS;=0A=
+	mac_control->rmac_pause_time =3D 0;=0A=
+=0A=
+	/* Initialize Ring buffer parameters. */=0A=
+	for (i =3D 0; i < config->RxRingNum; i++)=0A=
+		atomic_set(&sp->rx_bufs_left[i], 0);=0A=
+=0A=
+	/*  initialize the shared memory used by the NIC and the host */=0A=
+	if (initSharedMem(sp)) {=0A=
+		DBG_PRINT(ERR_DBG, "%s: Memory allocation failed\n",=0A=
+			  dev->name);=0A=
+		goto mem_alloc_failed;=0A=
+	}=0A=
+=0A=
+	sp->bar0 =3D (caddr_t) ioremap(pci_resource_start(pdev, 0),=0A=
+				     pci_resource_len(pdev, 0));=0A=
+	if (!sp->bar0) {=0A=
+		DBG_PRINT(ERR_DBG, "%s: S2IO: cannot remap io mem1\n",=0A=
+			  dev->name);=0A=
+		goto bar0_remap_failed;=0A=
+	}=0A=
+=0A=
+	sp->bar1 =3D (caddr_t) ioremap(pci_resource_start(pdev, 2),=0A=
+				     pci_resource_len(pdev, 2));=0A=
+	if (!sp->bar1) {=0A=
+		DBG_PRINT(ERR_DBG, "%s: S2IO: cannot remap io mem2\n",=0A=
+			  dev->name);=0A=
+		goto bar1_remap_failed;=0A=
+	}=0A=
+=0A=
+	dev->irq =3D pdev->irq;=0A=
+	dev->base_addr =3D (unsigned long) sp->bar0;=0A=
+=0A=
+	/* Initializing the BAR1 address as the start of the FIFO pointer. */=0A=
+	for (j =3D 0; j < MAX_TX_FIFOS; j++) {=0A=
+		mac_control->tx_FIFO_start[j] =3D (TxFIFO_element_t *)=0A=
+		    (sp->bar1 + (j * 0x00020000));=0A=
+	}=0A=
+=0A=
+	/*  Driver entry points */=0A=
+	dev->open =3D &s2io_open;=0A=
+	dev->stop =3D &s2io_close;=0A=
+	dev->hard_start_xmit =3D &s2io_xmit;=0A=
+	dev->get_stats =3D &s2io_get_stats;=0A=
+	dev->set_multicast_list =3D &s2io_set_multicast;=0A=
+	dev->do_ioctl =3D &s2io_ioctl;=0A=
+	dev->change_mtu =3D &s2io_change_mtu;=0A=
+	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);=0A=
+=0A=
+	/*=0A=
+	 * will use eth_mac_addr() for  dev->set_mac_address=0A=
+	 * mac address will be set every time dev->open() is called=0A=
+	 */=0A=
+#ifdef CONFIG_S2IO_NAPI=0A=
+	dev->poll =3D s2io_poll;=0A=
+	dev->weight =3D 128;	/* For now. */=0A=
+#endif=0A=
+=0A=
+	dev->features |=3D NETIF_F_SG | NETIF_F_IP_CSUM;=0A=
+	if (sp->high_dma_flag =3D=3D TRUE)=0A=
+		dev->features |=3D NETIF_F_HIGHDMA;=0A=
+#ifdef NETIF_F_TSO=0A=
+	dev->features |=3D NETIF_F_TSO;=0A=
+#endif=0A=
+=0A=
+	dev->tx_timeout =3D &s2io_tx_watchdog;=0A=
+	dev->watchdog_timeo =3D WATCH_DOG_TIMEOUT;=0A=
+	INIT_WORK(&sp->rst_timer_task,=0A=
+		  (void (*)(void *)) s2io_restart_nic, dev);=0A=
+	INIT_WORK(&sp->set_link_task,=0A=
+		  (void (*)(void *)) s2io_set_link, sp);=0A=
+=0A=
+	if (register_netdev(dev)) {=0A=
+		DBG_PRINT(ERR_DBG, "Device registration failed\n");=0A=
+		goto register_failed;=0A=
+	}=0A=
+=0A=
+	pci_save_state(sp->pdev, sp->config_space);=0A=
+=0A=
+	/* Setting swapper control on the NIC, for proper reset operation */=0A=
+	if (s2io_set_swapper(sp)) {=0A=
+		DBG_PRINT(ERR_DBG, "%s:swapper settings are wrong\n",=0A=
+			  dev->name);=0A=
+		goto set_swap_failed;=0A=
+	}=0A=
+=0A=
+	/* Fix for all "FFs" MAC address problems observed on Alpha platforms =
*/=0A=
+	FixMacAddress(sp);=0A=
+	s2io_reset(sp);=0A=
+=0A=
+	/* Setting swapper control on the NIC, so the MAC address can be read.=0A=
+	 */=0A=
+	if (s2io_set_swapper(sp)) {=0A=
+		DBG_PRINT(ERR_DBG,=0A=
+			  "%s: S2IO: swapper settings are wrong\n",=0A=
+			  dev->name);=0A=
+		goto set_swap_failed;=0A=
+	}=0A=
+=0A=
+	/*  MAC address initialization.=0A=
+	 *  For now only one mac address will be read and used.=0A=
+	 */=0A=
+	bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+	val64 =3D RMAC_ADDR_CMD_MEM_RD | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |=0A=
+	    RMAC_ADDR_CMD_MEM_OFFSET(0 + MAC_MAC_ADDR_START_OFFSET);=0A=
+	writeq(val64, &bar0->rmac_addr_cmd_mem);=0A=
+	waitForCmdComplete(sp);=0A=
+=0A=
+	tmp64 =3D readq(&bar0->rmac_addr_data0_mem);=0A=
+	mac_down =3D (u32) tmp64;=0A=
+	mac_up =3D (u32) (tmp64 >> 32);=0A=
+=0A=
+	memset(sp->defMacAddr[0].mac_addr, 0, sizeof(ETH_ALEN));=0A=
+=0A=
+	sp->defMacAddr[0].mac_addr[3] =3D (u8) (mac_up);=0A=
+	sp->defMacAddr[0].mac_addr[2] =3D (u8) (mac_up >> 8);=0A=
+	sp->defMacAddr[0].mac_addr[1] =3D (u8) (mac_up >> 16);=0A=
+	sp->defMacAddr[0].mac_addr[0] =3D (u8) (mac_up >> 24);=0A=
+	sp->defMacAddr[0].mac_addr[5] =3D (u8) (mac_down >> 16);=0A=
+	sp->defMacAddr[0].mac_addr[4] =3D (u8) (mac_down >> 24);=0A=
+=0A=
+	DBG_PRINT(INIT_DBG,=0A=
+		  "DEFAULT MAC ADDR:0x%02x-%02x-%02x-%02x-%02x-%02x\n",=0A=
+		  sp->defMacAddr[0].mac_addr[0],=0A=
+		  sp->defMacAddr[0].mac_addr[1],=0A=
+		  sp->defMacAddr[0].mac_addr[2],=0A=
+		  sp->defMacAddr[0].mac_addr[3],=0A=
+		  sp->defMacAddr[0].mac_addr[4],=0A=
+		  sp->defMacAddr[0].mac_addr[5]);=0A=
+=0A=
+	/*  Set the factory defined MAC address initially   */=0A=
+	dev->addr_len =3D ETH_ALEN;=0A=
+	memcpy(dev->dev_addr, sp->defMacAddr, ETH_ALEN);=0A=
+=0A=
+	/*  Initialize the tasklet status flag */=0A=
+	atomic_set(&(sp->tasklet_status), 0);=0A=
+=0A=
+=0A=
+	/* Initialize spinlocks */=0A=
+	spin_lock_init(&sp->isr_lock);=0A=
+	spin_lock_init(&sp->tx_lock);=0A=
+=0A=
+	/* SXE-002: Configure link and activity LED to init state =0A=
+	 * on driver load. =0A=
+	 */=0A=
+	subid =3D sp->pdev->subsystem_device;=0A=
+	if ((subid & 0xFF) >=3D 0x07) {=0A=
+		val64 =3D readq(&bar0->gpio_control);=0A=
+		val64 |=3D 0x0000800000000000ULL;=0A=
+		writeq(val64, &bar0->gpio_control);=0A=
+		val64 =3D 0x0411040400000000ULL;=0A=
+		writeq(val64, (u64 *) ((u8 *) bar0 + 0x2700));=0A=
+		val64 =3D readq(&bar0->gpio_control);=0A=
+	}=0A=
+=0A=
+	/* Make Link state as off at this point, when the Link change =0A=
+	 * interrupt comes the state will be automatically changed to =0A=
+	 * the right state.=0A=
+	 */=0A=
+	netif_carrier_off(dev);=0A=
+	sp->last_link_state =3D LINK_DOWN;=0A=
+=0A=
+	sp->rx_csum =3D 1;	/* Rx chksum verify enabled by default */=0A=
+=0A=
+	return 0;=0A=
+=0A=
+      set_swap_failed:=0A=
+	unregister_netdev(dev);=0A=
+      register_failed:=0A=
+	iounmap(sp->bar1);=0A=
+      bar1_remap_failed:=0A=
+	iounmap(sp->bar0);=0A=
+      bar0_remap_failed:=0A=
+      mem_alloc_failed:=0A=
+	freeSharedMem(sp);=0A=
+      init_failed:=0A=
+	pci_disable_device(pdev);=0A=
+	pci_release_regions(pdev);=0A=
+	pci_set_drvdata(pdev, NULL);=0A=
+	free_netdev(dev);=0A=
+=0A=
+	return -ENODEV;=0A=
+}=0A=
+=0A=
+/*=0A=
+*  Input Argument/s: =0A=
+*   pdev - structure containing the PCI related information of the =
device.=0A=
+*  Return value:=0A=
+*  void=0A=
+*  Description:=0A=
+*  This function is called by the Pci subsystem to release a PCI device =0A=
+*  and free up all resource held up by the device. This could be in =
response =0A=
+*  to a Hot plug event or when the driver is to be removed from memory.=0A=
+*/=0A=
+static void __exit s2io_rem_nic(struct pci_dev *pdev)=0A=
+{=0A=
+	struct net_device *dev =3D=0A=
+	    (struct net_device *) pci_get_drvdata(pdev);=0A=
+	nic_t *sp;=0A=
+=0A=
+	if (dev =3D=3D NULL) {=0A=
+		DBG_PRINT(ERR_DBG, "Driver Data is NULL!!\n");=0A=
+		return;=0A=
+	}=0A=
+	sp =3D dev->priv;=0A=
+	freeSharedMem(sp);=0A=
+	iounmap(sp->bar0);=0A=
+	iounmap(sp->bar1);=0A=
+	pci_disable_device(pdev);=0A=
+	pci_release_regions(pdev);=0A=
+	pci_set_drvdata(pdev, NULL);=0A=
+=0A=
+	unregister_netdev(dev);=0A=
+=0A=
+	free_netdev(dev);=0A=
+}=0A=
+=0A=
+int __init s2io_starter(void)=0A=
+{=0A=
+	return pci_module_init(&s2io_driver);=0A=
+}=0A=
+=0A=
+void s2io_closer(void)=0A=
+{=0A=
+	pci_unregister_driver(&s2io_driver);=0A=
+	DBG_PRINT(INIT_DBG, "cleanup done\n");=0A=
+}=0A=
+=0A=
+module_init(s2io_starter);=0A=
+module_exit(s2io_closer);=0A=
diff -urN vanilla-linux/drivers/net/s2io/s2io.h =
vanilla-linux-patch/drivers/net/s2io/s2io.h=0A=
--- vanilla-linux/drivers/net/s2io/s2io.h	1970-01-01 05:30:00.000000000 =
+0530=0A=
+++ vanilla-linux-patch/drivers/net/s2io/s2io.h	2004-03-19 =
11:22:44.000000000 +0530=0A=
@@ -0,0 +1,855 @@=0A=
+/***********************************************************************=
*=0A=
+ * s2io.h: A Linux PCI-X Ethernet driver for S2IO 10GbE Server NIC=0A=
+ * Copyright 2002 Raghavendra Koushik (raghavendra.koushik@s2io.com)=0A=
+=0A=
+ * This software may be used and distributed according to the terms of=0A=
+ * the GNU General Public License (GPL), incorporated herein by =
reference.=0A=
+ * Drivers based on or derived from this code fall under the GPL and =
must=0A=
+ * retain the authorship, copyright and license notice.  This file is =
not=0A=
+ * a complete program and may only be used when the entire operating=0A=
+ * system is licensed under the GPL.=0A=
+ * See the file COPYING in this distribution for more information.=0A=
+ =
************************************************************************/=0A=
+#ifndef _S2IO_H=0A=
+#define _S2IO_H=0A=
+=0A=
+#define TBD 0=0A=
+#define BIT(loc)        (((u64)0x8000000000000000ULL) >> loc)=0A=
+#define vBIT(val, loc, sz)  (((u64)val) << (64-loc-sz))=0A=
+=0A=
+#ifndef BOOL=0A=
+#define BOOL    int=0A=
+#endif=0A=
+=0A=
+#ifndef TRUE=0A=
+#define TRUE    1=0A=
+#define FALSE   0=0A=
+#endif=0A=
+=0A=
+#undef SUCCESS=0A=
+#define SUCCESS 0=0A=
+#define FAILURE -1=0A=
+=0A=
+/* Maximum outstanding splits to be configured into xena. */=0A=
+typedef enum xena_max_outstanding_splits {=0A=
+	XENA_ONE_SPLIT_TRANSACTION =3D 0,=0A=
+	XENA_TWO_SPLIT_TRANSACTION =3D 1,=0A=
+	XENA_THREE_SPLIT_TRANSACTION =3D 2,=0A=
+	XENA_FOUR_SPLIT_TRANSACTION =3D 3,=0A=
+	XENA_EIGHT_SPLIT_TRANSACTION =3D 4,=0A=
+	XENA_TWELVE_SPLIT_TRANSACTION =3D 5,=0A=
+	XENA_SIXTEEN_SPLIT_TRANSACTION =3D 6,=0A=
+	XENA_THIRTYTWO_SPLIT_TRANSACTION =3D 7=0A=
+} xena_max_outstanding_splits;=0A=
+#define XENA_MAX_OUTSTANDING_SPLITS(n) (n << 4)=0A=
+=0A=
+/*  OS concerned variables and constants */=0A=
+#define WATCH_DOG_TIMEOUT   	5*HZ=0A=
+#define EFILL       			0x1234=0A=
+#define ALIGN_SIZE  			127=0A=
+#define	PCIX_COMMAND_REGISTER	0x62=0A=
+=0A=
+/*=0A=
+ * Debug related variables.=0A=
+ */=0A=
+#define DEBUG_ON TRUE=0A=
+=0A=
+/* different debug levels. */=0A=
+#define	ERR_DBG		0=0A=
+#define	INIT_DBG	1=0A=
+#define	INFO_DBG	2=0A=
+#define	TX_DBG		3=0A=
+#define	INTR_DBG	4=0A=
+=0A=
+/* Global variable that defines the present debug level of the driver. =
*/=0A=
+int debug_level =3D ERR_DBG;	/* Default level. */=0A=
+=0A=
+/* DEBUG message print. */=0A=
+#define DBG_PRINT(dbg_level, args...)  if(!(debug_level<dbg_level)) =
printk(args)=0A=
+=0A=
+/* Protocol assist features of the NIC */=0A=
+#define L3_CKSUM_OK 0xFFFF=0A=
+#define L4_CKSUM_OK 0xFFFF=0A=
+#define S2IO_JUMBO_SIZE 9600=0A=
+=0A=
+/* The statistics block of Xena */=0A=
+typedef struct stat_block {=0A=
+#ifdef  __BIG_ENDIAN=0A=
+/* Tx MAC statistics counters. */=0A=
+	u32 tmac_frms;=0A=
+	u32 tmac_data_octets;=0A=
+	u64 tmac_drop_frms;=0A=
+	u32 tmac_mcst_frms;=0A=
+	u32 tmac_bcst_frms;=0A=
+	u64 tmac_pause_ctrl_frms;=0A=
+	u32 tmac_ttl_octets;=0A=
+	u32 tmac_ucst_frms;=0A=
+	u32 tmac_nucst_frms;=0A=
+	u32 tmac_any_err_frms;=0A=
+	u64 tmac_ttl_less_fb_octets;=0A=
+	u64 tmac_vld_ip_octets;=0A=
+	u32 tmac_vld_ip;=0A=
+	u32 tmac_drop_ip;=0A=
+	u32 tmac_icmp;=0A=
+	u32 tmac_rst_tcp;=0A=
+	u64 tmac_tcp;=0A=
+	u32 tmac_udp;=0A=
+	u32 reserved_0;=0A=
+=0A=
+/* Rx MAC Statistics counters. */=0A=
+	u32 rmac_vld_frms;=0A=
+	u32 rmac_data_octets;=0A=
+	u64 rmac_fcs_err_frms;=0A=
+	u64 rmac_drop_frms;=0A=
+	u32 rmac_vld_mcst_frms;=0A=
+	u32 rmac_vld_bcst_frms;=0A=
+	u32 rmac_in_rng_len_err_frms;=0A=
+	u32 rmac_out_rng_len_err_frms;=0A=
+	u64 rmac_long_frms;=0A=
+	u64 rmac_pause_ctrl_frms;=0A=
+	u64 rmac_unsup_ctrl_frms;=0A=
+	u32 rmac_ttl_octets;=0A=
+	u32 rmac_accepted_ucst_frms;=0A=
+	u32 rmac_accepted_nucst_frms;=0A=
+	u32 rmac_discarded_frms;=0A=
+	u32 rmac_drop_events;=0A=
+	u32 reserved_1;=0A=
+	u64 rmac_ttl_less_fb_octets;=0A=
+	u64 rmac_ttl_frms;=0A=
+	u64 reserved_2;=0A=
+	u32 reserved_3;=0A=
+	u32 rmac_usized_frms;=0A=
+	u32 rmac_osized_frms;=0A=
+	u32 rmac_frag_frms;=0A=
+	u32 rmac_jabber_frms;=0A=
+	u32 reserved_4;=0A=
+	u64 rmac_ttl_64_frms;=0A=
+	u64 rmac_ttl_65_127_frms;=0A=
+	u64 reserved_5;=0A=
+	u64 rmac_ttl_128_255_frms;=0A=
+	u64 rmac_ttl_256_511_frms;=0A=
+	u64 reserved_6;=0A=
+	u64 rmac_ttl_512_1023_frms;=0A=
+	u64 rmac_ttl_1024_1518_frms;=0A=
+	u32 reserved_7;=0A=
+	u32 rmac_ip;=0A=
+	u64 rmac_ip_octets;=0A=
+	u32 rmac_hdr_err_ip;=0A=
+	u32 rmac_drop_ip;=0A=
+	u32 rmac_icmp;=0A=
+	u32 reserved_8;=0A=
+	u64 rmac_tcp;=0A=
+	u32 rmac_udp;=0A=
+	u32 rmac_err_drp_udp;=0A=
+	u64 rmac_xgmii_err_sym;=0A=
+	u64 rmac_frms_q0;=0A=
+	u64 rmac_frms_q1;=0A=
+	u64 rmac_frms_q2;=0A=
+	u64 rmac_frms_q3;=0A=
+	u64 rmac_frms_q4;=0A=
+	u64 rmac_frms_q5;=0A=
+	u64 rmac_frms_q6;=0A=
+	u64 rmac_frms_q7;=0A=
+	u16 rmac_full_q0;=0A=
+	u16 rmac_full_q1;=0A=
+	u16 rmac_full_q2;=0A=
+	u16 rmac_full_q3;=0A=
+	u16 rmac_full_q4;=0A=
+	u16 rmac_full_q5;=0A=
+	u16 rmac_full_q6;=0A=
+	u16 rmac_full_q7;=0A=
+	u32 rmac_pause_cnt;=0A=
+	u32 reserved_9;=0A=
+	u64 rmac_xgmii_data_err_cnt;=0A=
+	u64 rmac_xgmii_ctrl_err_cnt;=0A=
+	u32 rmac_accepted_ip;=0A=
+	u32 rmac_err_tcp;=0A=
+=0A=
+/* PCI/PCI-X Read transaction statistics. */=0A=
+	u32 rd_req_cnt;=0A=
+	u32 new_rd_req_cnt;=0A=
+	u32 new_rd_req_rtry_cnt;=0A=
+	u32 rd_rtry_cnt;=0A=
+	u32 wr_rtry_rd_ack_cnt;=0A=
+=0A=
+/* PCI/PCI-X write transaction statistics. */=0A=
+	u32 wr_req_cnt;=0A=
+	u32 new_wr_req_cnt;=0A=
+	u32 new_wr_req_rtry_cnt;=0A=
+	u32 wr_rtry_cnt;=0A=
+	u32 wr_disc_cnt;=0A=
+	u32 rd_rtry_wr_ack_cnt;=0A=
+=0A=
+/*	DMA Transaction statistics. */=0A=
+	u32 txp_wr_cnt;=0A=
+	u32 txd_rd_cnt;=0A=
+	u32 txd_wr_cnt;=0A=
+	u32 rxd_rd_cnt;=0A=
+	u32 rxd_wr_cnt;=0A=
+	u32 txf_rd_cnt;=0A=
+	u32 rxf_wr_cnt;=0A=
+#else=0A=
+/* Tx MAC statistics counters. */=0A=
+	u32 tmac_data_octets;=0A=
+	u32 tmac_frms;=0A=
+	u64 tmac_drop_frms;=0A=
+	u32 tmac_bcst_frms;=0A=
+	u32 tmac_mcst_frms;=0A=
+	u64 tmac_pause_ctrl_frms;=0A=
+	u32 tmac_ucst_frms;=0A=
+	u32 tmac_ttl_octets;=0A=
+	u32 tmac_any_err_frms;=0A=
+	u32 tmac_nucst_frms;=0A=
+	u64 tmac_ttl_less_fb_octets;=0A=
+	u64 tmac_vld_ip_octets;=0A=
+	u32 tmac_drop_ip;=0A=
+	u32 tmac_vld_ip;=0A=
+	u32 tmac_rst_tcp;=0A=
+	u32 tmac_icmp;=0A=
+	u64 tmac_tcp;=0A=
+	u32 reserved_0;=0A=
+	u32 tmac_udp;=0A=
+=0A=
+/* Rx MAC Statistics counters. */=0A=
+	u32 rmac_data_octets;=0A=
+	u32 rmac_vld_frms;=0A=
+	u64 rmac_fcs_err_frms;=0A=
+	u64 rmac_drop_frms;=0A=
+	u32 rmac_vld_bcst_frms;=0A=
+	u32 rmac_vld_mcst_frms;=0A=
+	u32 rmac_out_rng_len_err_frms;=0A=
+	u32 rmac_in_rng_len_err_frms;=0A=
+	u64 rmac_long_frms;=0A=
+	u64 rmac_pause_ctrl_frms;=0A=
+	u64 rmac_unsup_ctrl_frms;=0A=
+	u32 rmac_accepted_ucst_frms;=0A=
+	u32 rmac_ttl_octets;=0A=
+	u32 rmac_discarded_frms;=0A=
+	u32 rmac_accepted_nucst_frms;=0A=
+	u32 reserved_1;=0A=
+	u32 rmac_drop_events;=0A=
+	u64 rmac_ttl_less_fb_octets;=0A=
+	u64 rmac_ttl_frms;=0A=
+	u64 reserved_2;=0A=
+	u32 rmac_usized_frms;=0A=
+	u32 reserved_3;=0A=
+	u32 rmac_frag_frms;=0A=
+	u32 rmac_osized_frms;=0A=
+	u32 reserved_4;=0A=
+	u32 rmac_jabber_frms;=0A=
+	u64 rmac_ttl_64_frms;=0A=
+	u64 rmac_ttl_65_127_frms;=0A=
+	u64 reserved_5;=0A=
+	u64 rmac_ttl_128_255_frms;=0A=
+	u64 rmac_ttl_256_511_frms;=0A=
+	u64 reserved_6;=0A=
+	u64 rmac_ttl_512_1023_frms;=0A=
+	u64 rmac_ttl_1024_1518_frms;=0A=
+	u32 rmac_ip;=0A=
+	u32 reserved_7;=0A=
+	u64 rmac_ip_octets;=0A=
+	u32 rmac_drop_ip;=0A=
+	u32 rmac_hdr_err_ip;=0A=
+	u32 reserved_8;=0A=
+	u32 rmac_icmp;=0A=
+	u64 rmac_tcp;=0A=
+	u32 rmac_err_drp_udp;=0A=
+	u32 rmac_udp;=0A=
+	u64 rmac_xgmii_err_sym;=0A=
+	u64 rmac_frms_q0;=0A=
+	u64 rmac_frms_q1;=0A=
+	u64 rmac_frms_q2;=0A=
+	u64 rmac_frms_q3;=0A=
+	u64 rmac_frms_q4;=0A=
+	u64 rmac_frms_q5;=0A=
+	u64 rmac_frms_q6;=0A=
+	u64 rmac_frms_q7;=0A=
+	u16 rmac_full_q3;=0A=
+	u16 rmac_full_q2;=0A=
+	u16 rmac_full_q1;=0A=
+	u16 rmac_full_q0;=0A=
+	u16 rmac_full_q7;=0A=
+	u16 rmac_full_q6;=0A=
+	u16 rmac_full_q5;=0A=
+	u16 rmac_full_q4;=0A=
+	u32 reserved_9;=0A=
+	u32 rmac_pause_cnt;=0A=
+	u64 rmac_xgmii_data_err_cnt;=0A=
+	u64 rmac_xgmii_ctrl_err_cnt;=0A=
+	u32 rmac_err_tcp;=0A=
+	u32 rmac_accepted_ip;=0A=
+=0A=
+/* PCI/PCI-X Read transaction statistics. */=0A=
+	u32 new_rd_req_cnt;=0A=
+	u32 rd_req_cnt;=0A=
+	u32 rd_rtry_cnt;=0A=
+	u32 new_rd_req_rtry_cnt;=0A=
+=0A=
+/* PCI/PCI-X Write/Read transaction statistics. */=0A=
+	u32 wr_req_cnt;=0A=
+	u32 wr_rtry_rd_ack_cnt;=0A=
+	u32 new_wr_req_rtry_cnt;=0A=
+	u32 new_wr_req_cnt;=0A=
+	u32 wr_disc_cnt;=0A=
+	u32 wr_rtry_cnt;=0A=
+=0A=
+/*	PCI/PCI-X Write / DMA Transaction statistics. */=0A=
+	u32 txp_wr_cnt;=0A=
+	u32 rd_rtry_wr_ack_cnt;=0A=
+	u32 txd_wr_cnt;=0A=
+	u32 txd_rd_cnt;=0A=
+	u32 rxd_wr_cnt;=0A=
+	u32 rxd_rd_cnt;=0A=
+	u32 rxf_wr_cnt;=0A=
+	u32 txf_rd_cnt;=0A=
+#endif=0A=
+} StatInfo_t;=0A=
+=0A=
+/* Structures representing different init time configuration=0A=
+ * parameters of the NIC.=0A=
+ */=0A=
+=0A=
+/* Maintains Per FIFO related information. */=0A=
+typedef struct tx_fifo_config {=0A=
+#define	MAX_AVAILABLE_TXDS	8192=0A=
+	u32 FifoLen;		/* specifies len of FIFO upto 8192, ie no of TxDLs */=0A=
+/* Priority definition */=0A=
+#define TX_FIFO_PRI_0               0	/*Highest */=0A=
+#define TX_FIFO_PRI_1               1=0A=
+#define TX_FIFO_PRI_2               2=0A=
+#define TX_FIFO_PRI_3               3=0A=
+#define TX_FIFO_PRI_4               4=0A=
+#define TX_FIFO_PRI_5               5=0A=
+#define TX_FIFO_PRI_6               6=0A=
+#define TX_FIFO_PRI_7               7	/*lowest */=0A=
+	u8 FifoPriority;	/* specifies pointer level for FIFO */=0A=
+	/* user should not set twos fifos with same pri */=0A=
+	u8 fNoSnoop;=0A=
+#define NO_SNOOP_TXD                0x01=0A=
+#define NO_SNOOP_TXD_BUFFER          0x02=0A=
+} tx_fifo_config_t;=0A=
+=0A=
+=0A=
+/* Maintains per Ring related information */=0A=
+typedef struct rx_ring_config {=0A=
+	u32 NumRxd;		/*No of RxDs per Rx Ring */=0A=
+#define RX_RING_PRI_0               0	/* highest */=0A=
+#define RX_RING_PRI_1               1=0A=
+#define RX_RING_PRI_2               2=0A=
+#define RX_RING_PRI_3               3=0A=
+#define RX_RING_PRI_4               4=0A=
+#define RX_RING_PRI_5               5=0A=
+#define RX_RING_PRI_6               6=0A=
+#define RX_RING_PRI_7               7	/* lowest */=0A=
+=0A=
+	u8 RingPriority;	/*Specifies service priority of ring */=0A=
+	/* OSM should not set any two rings with same priority */=0A=
+	u8 RingOrg;		/*Organization of ring */=0A=
+#define RING_ORG_BUFF1           0x01=0A=
+#define RX_RING_ORG_BUFF3           0x03=0A=
+#define RX_RING_ORG_BUFF5           0x05=0A=
+=0A=
+/* In case of 3 buffer recv. mode, size of three buffers is expected =
as.. */=0A=
+#define BUFF_SZ_1                   22	/* ethernet header */=0A=
+#define BUFF_SZ_2                   (64+64)	/* max. IP+TCP header size =
*/=0A=
+#define BUFF_SZ_3                   (1500-20-20)	/* TCP payload */=0A=
+#define BUFF_SZ_3_JUMBO             (9600-20-20)	/* Jumbo TCP payload */=0A=
+=0A=
+	u32 RxdThresh;		/*No of used Rxds NIC can store before transfer to =
host */=0A=
+#define DEFAULT_RXD_THRESHOLD       0x1	/* TODO */=0A=
+	u8 fNoSnoop;=0A=
+#define NO_SNOOP_RXD                0x01=0A=
+#define NO_SNOOP_RXD_BUFFER         0x02=0A=
+	u32 RxD_BackOff_Interval;=0A=
+#define RXD_BACKOFF_INTERVAL_DEF        0x0=0A=
+#define RXD_BACKOFF_INTERVAL_MIN        0x0=0A=
+#define RXD_BACKOFF_INTERVAL_MAX        0x0=0A=
+} rx_ring_config_t;=0A=
+=0A=
+/* This structure provides contains values of the tunable parameters =0A=
+ * of the H/W =0A=
+ */=0A=
+struct config_param {=0A=
+=0A=
+/* Tx Side */=0A=
+	u32 TxFIFONum;		/*Number of Tx FIFOs */=0A=
+#define MAX_TX_FIFOS 8=0A=
+=0A=
+	tx_fifo_config_t TxCfg[MAX_TX_FIFOS];	/*Per-Tx FIFO config */=0A=
+	u32 MaxTxDs;		/*Max no. of Tx buffer descriptor per TxDL */=0A=
+	BOOL TxVLANEnable;	/*TRUE: Insert VLAN ID, FALSE: Don't insert */=0A=
+#define TX_REQ_TIMEOUT_DEFAULT          0x0=0A=
+#define TX_REQ_TIMEOUT_MIN              0x0=0A=
+#define TX_REQ_TIMEOUT_MAX              0x0=0A=
+	u32 TxReqTimeOut;=0A=
+	BOOL TxFlow;		/*Tx flow control enable */=0A=
+	BOOL RxFlow;=0A=
+	BOOL OverrideTxServiceState;	/* TRUE: Overide, FALSE: Do not override =0A=
+					   Use the new priority information=0A=
+					   of service state. It is not recommended=0A=
+					   to change but OSM can opt to do so */=0A=
+#define MAX_SERVICE_STATES  36=0A=
+	u8 TxServiceState[MAX_SERVICE_STATES];=0A=
+	/* Array element represent 'priority' =0A=
+	 * and array index represents=0A=
+	 *  'Service state' e.g. =0A=
+	 *  TxServiceState[3]=3D7; it means =0A=
+	 *  Service state 3 is associated =0A=
+	 *  with priority 7 of a Tx FIFO */=0A=
+	u64 TxIntrType;		/* Specifies if Tx Intr is UTILZ or PER_LIST type. */=0A=
+=0A=
+/* Rx Side */=0A=
+	u32 RxRingNum;		/*Number of receive rings */=0A=
+#define MAX_RX_RINGS 8=0A=
+#define MAX_RX_BLOCKS_PER_RING  150=0A=
+=0A=
+	rx_ring_config_t RxCfg[MAX_RX_RINGS];	/*Per-Rx Ring config */=0A=
+	BOOL RxVLANEnable;	/*TRUE: Strip off VLAN tag from the frame,=0A=
+				   FALSE: Don't strip off VLAN tag */=0A=
+=0A=
+#define HEADER_ETHERNET_II_802_3_SIZE 14=0A=
+#define HEADER_802_2_SIZE              3=0A=
+#define HEADER_SNAP_SIZE               5=0A=
+#define HEADER_VLAN_SIZE               4=0A=
+#define HEADER_ALIGN_LAYER_3           2=0A=
+=0A=
+#define MIN_MTU                       46=0A=
+#define MAX_PYLD                    1500=0A=
+#define MAX_MTU                     (MAX_PYLD+18)=0A=
+#define MAX_MTU_VLAN                (MAX_PYLD+22)=0A=
+#define MAX_PYLD_JUMBO              9600=0A=
+#define MAX_MTU_JUMBO               (MAX_PYLD_JUMBO+18)=0A=
+#define MAX_MTU_JUMBO_VLAN          (MAX_PYLD_JUMBO+22)=0A=
+	u32 MTU;		/*Maximum Payload */=0A=
+	BOOL JumboEnable;	/*Enable Jumbo frames recv/send */=0A=
+	BOOL OverrideRxServiceState;	/* TRUE: Overide, FALSE: Do not override =0A=
+					   Use the new priority information=0A=
+					   of service state. It is not recommended=0A=
+					   to change but OSM can opt to do so */=0A=
+#define MAX_SERVICE_STATES  36=0A=
+	u8 RxServiceState[MAX_SERVICE_STATES];=0A=
+	/* Array element represent 'priority' =0A=
+	 * and array index represents =0A=
+	 * 'Service state'e.g. =0A=
+	 * RxServiceState[3]=3D7; it means =0A=
+	 * Service state 3 is associated =0A=
+	 * with priority 7 of a Rx FIFO */=0A=
+	BOOL StatAutoRefresh;	/* When true, StatRefreshTime have valid value */=0A=
+	u32 StatRefreshTime;	/*Time for refreshing statistics */=0A=
+#define     STAT_TRSF_PER_1_SECOND      0x208D5=0A=
+};=0A=
+=0A=
+/* Structure representing MAC Addrs */=0A=
+typedef struct mac_addr {=0A=
+	u8 mac_addr[ETH_ALEN];=0A=
+} macaddr_t;=0A=
+=0A=
+/* Structure that represent every FIFO element in the BAR1=0A=
+ * Address location. =0A=
+ */=0A=
+typedef struct _TxFIFO_element {=0A=
+	u64 TxDL_Pointer;=0A=
+=0A=
+	u64 List_Control;=0A=
+#define TX_FIFO_LAST_TXD_NUM( val)     vBIT(val,0,8)=0A=
+#define TX_FIFO_FIRST_LIST             BIT(14)=0A=
+#define TX_FIFO_LAST_LIST              BIT(15)=0A=
+#define TX_FIFO_FIRSTNLAST_LIST        vBIT(3,14,2)=0A=
+#define TX_FIFO_SPECIAL_FUNC           BIT(23)=0A=
+#define TX_FIFO_DS_NO_SNOOP            BIT(31)=0A=
+#define TX_FIFO_BUFF_NO_SNOOP          BIT(30)=0A=
+} TxFIFO_element_t;=0A=
+=0A=
+/* Tx descriptor structure */=0A=
+typedef struct _TxD {=0A=
+	u64 Control_1;=0A=
+/* bit mask */=0A=
+#define TXD_LIST_OWN_XENA       BIT(7)=0A=
+#define TXD_T_CODE              (BIT(12)|BIT(13)|BIT(14)|BIT(15))=0A=
+#define TXD_T_CODE_OK(val)      (|(val & TXD_T_CODE))=0A=
+#define GET_TXD_T_CODE(val)     ((val & TXD_T_CODE)<<12)=0A=
+#define TXD_GATHER_CODE         (BIT(22) | BIT(23))=0A=
+#define TXD_GATHER_CODE_FIRST   BIT(22)=0A=
+#define TXD_GATHER_CODE_LAST    BIT(23)=0A=
+#define TXD_TCP_LSO_EN          BIT(30)=0A=
+#define TXD_UDP_COF_EN          BIT(31)=0A=
+#define TXD_TCP_LSO_MSS(val)    vBIT(val,34,14)=0A=
+#define TXD_BUFFER0_SIZE(val)   vBIT(val,48,16)=0A=
+=0A=
+	u64 Control_2;=0A=
+#define TXD_TX_CKO_CONTROL      (BIT(5)|BIT(6)|BIT(7))=0A=
+#define TXD_TX_CKO_IPV4_EN      BIT(5)=0A=
+#define TXD_TX_CKO_TCP_EN       BIT(6)=0A=
+#define TXD_TX_CKO_UDP_EN       BIT(7)=0A=
+#define TXD_VLAN_ENABLE         BIT(15)=0A=
+#define TXD_VLAN_TAG(val)       vBIT(val,16,16)=0A=
+#define TXD_INT_NUMBER(val)     vBIT(val,34,6)=0A=
+#define TXD_INT_TYPE_PER_LIST   BIT(47)=0A=
+#define TXD_INT_TYPE_UTILZ      BIT(46)=0A=
+#define TXD_SET_MARKER         vBIT(0x6,0,4)=0A=
+=0A=
+	u64 Buffer_Pointer;=0A=
+	u64 Host_Control;	/* reserved for host */=0A=
+} TxD_t;=0A=
+=0A=
+/* Rx descriptor structure */=0A=
+typedef struct _RxD_t {=0A=
+	u64 Host_Control;	/* reserved for host */=0A=
+	u64 Control_1;=0A=
+#define RXD_OWN_XENA            BIT(7)=0A=
+#define RXD_T_CODE              (BIT(12)|BIT(13)|BIT(14)|BIT(15))=0A=
+#define RXD_FRAME_PROTO         vBIT(0xFFFF,24,8)=0A=
+#define RXD_FRAME_PROTO_IPV4    BIT(27)=0A=
+#define RXD_FRAME_PROTO_IPV6    BIT(28)=0A=
+#define RXD_FRAME_PROTO_TCP     BIT(30)=0A=
+#define RXD_FRAME_PROTO_UDP     BIT(31)=0A=
+#define TCP_OR_UDP_FRAME        (RXD_FRAME_PROTO_TCP | =
RXD_FRAME_PROTO_UDP)=0A=
+#define RXD_GET_L3_CKSUM(val)   ((u16)(val>> 16) & 0xFFFF)=0A=
+#define RXD_GET_L4_CKSUM(val)   ((u16)(val) & 0xFFFF)=0A=
+=0A=
+	u64 Control_2;=0A=
+#define MASK_BUFFER0_SIZE       vBIT(0xFFFF,0,16)=0A=
+#define SET_BUFFER0_SIZE(val)   vBIT(val,0,16)=0A=
+#define MASK_VLAN_TAG           vBIT(0xFFFF,48,16)=0A=
+#define SET_VLAN_TAG(val)       vBIT(val,48,16)=0A=
+#define SET_NUM_TAG(val)       vBIT(val,16,32)=0A=
+=0A=
+#define RXD_GET_BUFFER0_SIZE(Control_2) (u64)((Control_2 & =
vBIT(0xFFFF,0,16)))=0A=
+/*    =0A=
+#define TXD_GET_BUFFER1_SIZE(Control_2) (u16)((Control_2 & =
MASK_BUFFER1_SIZE) >> (63-31))  =0A=
+#define TXD_GET_BUFFER2_SIZE(Control_2) (u16)((Control_2 & =
MASK_BUFFER2_SIZE) >> (63-47))  =0A=
+*/=0A=
+	u64 Buffer0_ptr;=0A=
+} RxD_t;=0A=
+=0A=
+=0A=
+/* Structure that represents the Rx descriptor block which contains =0A=
+ * 128 Rx descriptors.=0A=
+ */=0A=
+typedef struct _RxD_block {=0A=
+#define MAX_RXDS_PER_BLOCK             127=0A=
+	RxD_t rxd[MAX_RXDS_PER_BLOCK];=0A=
+=0A=
+	u64 reserved_0;=0A=
+#define END_OF_BLOCK    0xFEFFFFFFFFFFFFFF=0A=
+	u64 reserved_1;		/* 0xFEFFFFFFFFFFFFFF to mark last Rxd in this blk */=0A=
+	u64 reserved_2_pNext_RxD_block;	/*@ Logical ptr to next */=0A=
+	u64 pNext_RxD_Blk_physical;	/* Buff0_ptr.=0A=
+					   In a 32 bit arch the upper 32 bits =0A=
+					   should be 0 */=0A=
+} RxD_block_t;=0A=
+=0A=
+/* Structure which stores all the MAC control parameters */=0A=
+=0A=
+/* This structure stores the offset of the RxD in the ring =0A=
+ * from which the Rx Interrupt processor can start picking =0A=
+ * up the RxDs for processing.=0A=
+ */=0A=
+typedef struct _rx_curr_get_info_t {=0A=
+	u32 block_index;=0A=
+	u32 offset;=0A=
+	u32 ring_len;=0A=
+} rx_curr_get_info_t;=0A=
+=0A=
+typedef rx_curr_get_info_t rx_curr_put_info_t;=0A=
+=0A=
+/* This structure stores the offset of the TxDl in the FIFO=0A=
+ * from which the Tx Interrupt processor can start picking =0A=
+ * up the TxDLs for send complete interrupt processing.=0A=
+ */=0A=
+typedef struct {=0A=
+	u32 offset;=0A=
+	u32 fifo_len;=0A=
+} tx_curr_get_info_t;=0A=
+=0A=
+typedef tx_curr_get_info_t tx_curr_put_info_t;=0A=
+=0A=
+/* Infomation related to the Tx and Rx FIFOs and Rings of Xena=0A=
+ * is maintained in this structure.=0A=
+ */=0A=
+typedef struct mac_info {=0A=
+/* rx side stuff */=0A=
+	u32 rxd_ring_mem_sz;=0A=
+	RxD_t *RxRing[MAX_RX_RINGS];	/* Logical Rx ring pointers */=0A=
+	dma_addr_t RxRing_Phy[MAX_RX_RINGS];=0A=
+=0A=
+	/* Put pointer info which indictes which RxD has to be replenished =0A=
+	 * with a new buffer.=0A=
+	 */=0A=
+	rx_curr_put_info_t rx_curr_put_info[MAX_RX_RINGS];=0A=
+=0A=
+	/* Get pointer info which indictes which is the last RxD that was =0A=
+	 * processed by the driver.=0A=
+	 */=0A=
+	rx_curr_get_info_t rx_curr_get_info[MAX_RX_RINGS];=0A=
+=0A=
+	u16 rmac_pause_time;=0A=
+=0A=
+	/* this will be used in receive function, this decides which ring would=0A=
+	   be processed first. eg: ring with priority value 0 (highest) should=0A=
+	   be processed first. =0A=
+	   first 3 LSB bits represent ring number which should be processed =0A=
+	   first, similarly next 3 bits represent next ring to be processed.=0A=
+	   eg: value of _rx_ring_pri_map =3D 0x0000 003A means =0A=
+	   ring #2 would be processed first and #7 would be processed next=0A=
+	 */=0A=
+	u32 _rx_ring_pri_map;=0A=
+=0A=
+/* tx side stuff */=0A=
+	void *txd_list_mem;	/* orignal pointer to allocated mem */=0A=
+	dma_addr_t txd_list_mem_phy;=0A=
+	u32 txd_list_mem_sz;=0A=
+=0A=
+	/* logical pointer of start of each Tx FIFO */=0A=
+	TxFIFO_element_t *tx_FIFO_start[MAX_TX_FIFOS];=0A=
+=0A=
+	/* logical pointer of start of TxDL which corresponds to each Tx FIFO =
*/=0A=
+	TxD_t *txdl_start[MAX_TX_FIFOS];=0A=
+=0A=
+	/* Same as txdl_start but phy addr */=0A=
+	dma_addr_t txdl_start_phy[MAX_TX_FIFOS];=0A=
+=0A=
+/* Current offset within tx_FIFO_start, where driver would write new Tx =
frame*/=0A=
+	tx_curr_put_info_t tx_curr_put_info[MAX_TX_FIFOS];=0A=
+	tx_curr_get_info_t tx_curr_get_info[MAX_TX_FIFOS];=0A=
+=0A=
+	u16 txdl_len;		/* length of a TxDL, same for all */=0A=
+=0A=
+	void *stats_mem;	/* orignal pointer to allocated mem */=0A=
+	dma_addr_t stats_mem_phy;	/* Physical address of the stat block */=0A=
+	u32 stats_mem_sz;=0A=
+	StatInfo_t *StatsInfo;	/* Logical address of the stat block */=0A=
+} mac_info_t;=0A=
+=0A=
+/* structure representing the user defined MAC addresses */=0A=
+typedef struct {=0A=
+	char addr[ETH_ALEN];=0A=
+	int usage_cnt;=0A=
+} usr_addr_t;=0A=
+=0A=
+/* Structure that holds the Phy and virt addresses of the Blocks */=0A=
+typedef struct rx_block_info {=0A=
+	RxD_t *block_virt_addr;=0A=
+	dma_addr_t block_dma_addr;=0A=
+} rx_block_info_t;=0A=
+=0A=
+/* Structure representing one instance of the NIC */=0A=
+typedef struct s2io_nic {=0A=
+#define MAX_MAC_SUPPORTED   16=0A=
+#define MAX_SUPPORTED_MULTICASTS MAX_MAC_SUPPORTED=0A=
+=0A=
+	macaddr_t defMacAddr[MAX_MAC_SUPPORTED];=0A=
+	macaddr_t preMacAddr[MAX_MAC_SUPPORTED];=0A=
+=0A=
+	struct net_device_stats stats;=0A=
+	caddr_t bar0;=0A=
+	caddr_t bar1;=0A=
+	struct config_param config;=0A=
+	mac_info_t mac_control;=0A=
+	int high_dma_flag;=0A=
+	int device_close_flag;=0A=
+	int device_enabled_once;=0A=
+=0A=
+	char name[32];=0A=
+	struct tasklet_struct task;=0A=
+	atomic_t tasklet_status;=0A=
+	struct timer_list timer;=0A=
+	struct net_device *dev;=0A=
+	struct pci_dev *pdev;=0A=
+=0A=
+	u16 vendor_id;=0A=
+	u16 device_id;=0A=
+	u16 ccmd;=0A=
+	u32 cbar0_1;=0A=
+	u32 cbar0_2;=0A=
+	u32 cbar1_1;=0A=
+	u32 cbar1_2;=0A=
+	u32 cirq;=0A=
+	u8 cache_line;=0A=
+	u32 rom_expansion;=0A=
+	u16 pcix_cmd;=0A=
+	u32 config_space[256 / sizeof(u32)];=0A=
+	u32 irq;=0A=
+	atomic_t rx_bufs_left[MAX_RX_RINGS];=0A=
+=0A=
+	spinlock_t isr_lock;=0A=
+	spinlock_t tx_lock;=0A=
+=0A=
+#define PROMISC     1=0A=
+#define ALL_MULTI   2=0A=
+=0A=
+#define MAX_ADDRS_SUPPORTED 64=0A=
+	u16 usr_addr_count;=0A=
+	u16 mc_addr_count;=0A=
+	usr_addr_t usr_addrs[MAX_ADDRS_SUPPORTED];=0A=
+=0A=
+	u16 m_cast_flg;=0A=
+	u16 all_multi_pos;=0A=
+	u16 promisc_flg;=0A=
+=0A=
+	u16 tx_pkt_count;=0A=
+	u16 rx_pkt_count;=0A=
+	u16 tx_err_count;=0A=
+	u16 rx_err_count;=0A=
+=0A=
+#if DEBUG_ON=0A=
+	u64 rxpkt_bytes;=0A=
+	u64 txpkt_bytes;=0A=
+	int int_cnt;=0A=
+	int rxint_cnt;=0A=
+	int txint_cnt;=0A=
+	u64 rxpkt_cnt;=0A=
+#endif=0A=
+=0A=
+	/*  Place holders for the virtual and physical addresses of =0A=
+	 *  all the Rx Blocks=0A=
+	 */=0A=
+	struct rx_block_info=0A=
+	 rx_blocks[MAX_RX_RINGS][MAX_RX_BLOCKS_PER_RING];=0A=
+	int block_count[MAX_RX_RINGS];=0A=
+	int pkt_cnt[MAX_RX_RINGS];=0A=
+=0A=
+	/*  Id timer, used to blink NIC to physically identify NIC. */=0A=
+	struct timer_list id_timer;=0A=
+=0A=
+	/*  Restart timer, used to restart NIC if the device is stuck and=0A=
+	 *  a schedule task that will set the correct Link state once the =0A=
+	 *  NIC's PHY has stabilized after a state change.=0A=
+	 */=0A=
+#ifdef INIT_TQUEUE=0A=
+	struct tq_struct rst_timer_task;=0A=
+	struct tq_struct set_link_task;=0A=
+#else=0A=
+	struct work_struct rst_timer_task;=0A=
+	struct work_struct set_link_task;=0A=
+#endif=0A=
+=0A=
+	/* Flag that can be used to turn on or turn off the Rx checksum =0A=
+	 * offload feature.=0A=
+	 */=0A=
+	int rx_csum;=0A=
+=0A=
+	/*  after blink, the adapter must be restored with original =0A=
+	 *  values.=0A=
+	 */=0A=
+	u64 adapt_ctrl_org;=0A=
+=0A=
+	/* Last known link state. */=0A=
+	u16 last_link_state;=0A=
+#define	LINK_DOWN	1=0A=
+#define	LINK_UP		2=0A=
+} nic_t __cacheline_aligned;=0A=
+=0A=
+#define RESET_ERROR 1;=0A=
+#define CMD_ERROR   2;=0A=
+=0A=
+/* Default Tunable parameters of the NIC. */=0A=
+#define DEFAULT_FIFO_LEN 4096=0A=
+#define SMALL_RXD_CNT	40 * (MAX_RXDS_PER_BLOCK+1)=0A=
+#define LARGE_RXD_CNT	100 * (MAX_RXDS_PER_BLOCK+1)=0A=
+=0A=
+/*  OS related system calls */=0A=
+#ifndef readq=0A=
+static inline u64 readq(void *addr)=0A=
+{=0A=
+	u64 ret =3D 0;=0A=
+	ret =3D readl(addr + 4);=0A=
+	(u64) ret <<=3D 32;=0A=
+	(u64) ret |=3D readl(addr);=0A=
+=0A=
+	return ret;=0A=
+}=0A=
+#endif=0A=
+=0A=
+#ifndef writeq=0A=
+static inline void writeq(u64 val, void *addr)=0A=
+{=0A=
+	writel((u32) (val), addr);=0A=
+	writel((u32) (val >> 32), (addr + 4));=0A=
+}=0A=
+#endif=0A=
+=0A=
+/*  Interrupt related values of Xena */=0A=
+=0A=
+#define ENABLE_INTRS    1=0A=
+#define DISABLE_INTRS   2=0A=
+=0A=
+/*  Highest level interrupt blocks */=0A=
+#define TX_PIC_INTR     (0x0001<<0)=0A=
+#define TX_DMA_INTR     (0x0001<<1)=0A=
+#define TX_MAC_INTR     (0x0001<<2)=0A=
+#define TX_XGXS_INTR    (0x0001<<3)=0A=
+#define TX_TRAFFIC_INTR (0x0001<<4)=0A=
+#define RX_PIC_INTR     (0x0001<<5)=0A=
+#define RX_DMA_INTR     (0x0001<<6)=0A=
+#define RX_MAC_INTR     (0x0001<<7)=0A=
+#define RX_XGXS_INTR    (0x0001<<8)=0A=
+#define RX_TRAFFIC_INTR (0x0001<<9)=0A=
+#define MC_INTR         (0x0001<<10)=0A=
+#define ENA_ALL_INTRS    (   TX_PIC_INTR     | \=0A=
+                            TX_DMA_INTR     | \=0A=
+                            TX_MAC_INTR     | \=0A=
+                            TX_XGXS_INTR    | \=0A=
+                            TX_TRAFFIC_INTR | \=0A=
+                            RX_PIC_INTR     | \=0A=
+                            RX_DMA_INTR     | \=0A=
+                            RX_MAC_INTR     | \=0A=
+                            RX_XGXS_INTR    | \=0A=
+                            RX_TRAFFIC_INTR | \=0A=
+                            MC_INTR )=0A=
+=0A=
+/*  Interrupt masks for the general interrupt mask register */=0A=
+#define DISABLE_ALL_INTRS   0xFFFFFFFFFFFFFFFFULL=0A=
+=0A=
+#define TXPIC_INT_M         BIT(0)=0A=
+#define TXDMA_INT_M         BIT(1)=0A=
+#define TXMAC_INT_M         BIT(2)=0A=
+#define TXXGXS_INT_M        BIT(3)=0A=
+#define TXTRAFFIC_INT_M     BIT(8)=0A=
+#define PIC_RX_INT_M        BIT(32)=0A=
+#define RXDMA_INT_M         BIT(33)=0A=
+#define RXMAC_INT_M         BIT(34)=0A=
+#define MC_INT_M            BIT(35)=0A=
+#define RXXGXS_INT_M        BIT(36)=0A=
+#define RXTRAFFIC_INT_M     BIT(40)=0A=
+=0A=
+/*  PIC level Interrupts TODO*/=0A=
+=0A=
+/*  DMA level Inressupts */=0A=
+#define TXDMA_PFC_INT_M     BIT(0)=0A=
+    /*  PFC block interrupts */=0A=
+#define PFC_MISC_ERR_1      BIT(0)	/* Interrupt to indicate FIFO full */=0A=
+=0A=
+/*=0A=
+ * Prototype declaration.=0A=
+ */=0A=
+static int __devinit s2io_init_nic(struct pci_dev *pdev,=0A=
+				   const struct pci_device_id *pre);=0A=
+static void __exit s2io_rem_nic(struct pci_dev *pdev);=0A=
+static int initSharedMem(struct s2io_nic *sp);=0A=
+static void freeSharedMem(struct s2io_nic *sp);=0A=
+static int initNic(struct s2io_nic *nic);=0A=
+#ifndef CONFIG_S2IO_NAPI=0A=
+static void rxIntrHandler(struct s2io_nic *sp);=0A=
+#endif=0A=
+static void txIntrHandler(struct s2io_nic *sp);=0A=
+static void alarmIntrHandler(struct s2io_nic *sp);=0A=
+=0A=
+static int s2io_starter(void);=0A=
+void s2io_closer(void);=0A=
+static void s2io_tx_watchdog(struct net_device *dev);=0A=
+static void s2io_tasklet(unsigned long dev_addr);=0A=
+static void s2io_set_multicast(struct net_device *dev);=0A=
+static int rxOsmHandler(nic_t * sp, u16 len, RxD_t * rxdp, int ring_no);=0A=
+void s2io_link(nic_t * sp, int link);=0A=
+void s2io_reset(nic_t * sp);=0A=
+#ifdef CONFIG_S2IO_NAPI=0A=
+static int s2io_poll(struct net_device *dev, int *budget);=0A=
+#endif=0A=
+static void s2io_init_pci(nic_t * sp);=0A=
+int s2io_set_mac_addr(struct net_device *dev, u8 * addr);=0A=
+static irqreturn_t s2io_isr(int irq, void *dev_id, struct pt_regs =
*regs);=0A=
+static int verify_xena_quiescence(u64 val64, int flag);=0A=
+static struct ethtool_ops netdev_ethtool_ops;=0A=
+=0A=
+#endif				/* _S2IO_H */=0A=
diff -urN vanilla-linux/drivers/net/tags =
vanilla-linux-patch/drivers/net/tags=0A=
--- vanilla-linux/drivers/net/tags	2004-03-16 16:20:29.000000000 +0530=0A=
+++ vanilla-linux-patch/drivers/net/tags	1970-01-01 05:30:00.000000000 =
+0530=0A=
@@ -1,1958 +0,0 @@=0A=
-!_TAG_FILE_FORMAT	2	/extended format; --format=3D1 will not append ;" =
to lines/=0A=
-!_TAG_FILE_SORTED	1	/0=3Dunsorted, 1=3Dsorted, 2=3Dfoldcase/=0A=
-!_TAG_PROGRAM_AUTHOR	Darren Hiebert	/dhiebert@users.sourceforge.net/=0A=
-!_TAG_PROGRAM_NAME	Exuberant Ctags	//=0A=
-!_TAG_PROGRAM_URL	http://ctags.sourceforge.net	/official site/=0A=
-!_TAG_PROGRAM_VERSION	5.4	//=0A=
-ACPI_LENOFF_LEN_MASK	tg3.h	351;"	d=0A=
-ACPI_LENOFF_LEN_SHIFT	tg3.h	352;"	d=0A=
-ACPI_LENOFF_OFF_MASK	tg3.h	353;"	d=0A=
-ACPI_LENOFF_OFF_SHIFT	tg3.h	354;"	d=0A=
-ADVERTISE_PAUSE_ASYM	tg3.h	1458;"	d=0A=
-ADVERTISE_PAUSE_CAP	tg3.h	1455;"	d=0A=
-ANEG_CFG_ACK	tg3.c	1504;"	d	file:=0A=
-ANEG_CFG_FD	tg3.c	1510;"	d	file:=0A=
-ANEG_CFG_HD	tg3.c	1509;"	d	file:=0A=
-ANEG_CFG_INVAL	tg3.c	1511;"	d	file:=0A=
-ANEG_CFG_NP	tg3.c	1503;"	d	file:=0A=
-ANEG_CFG_PS1	tg3.c	1508;"	d	file:=0A=
-ANEG_CFG_PS2	tg3.c	1507;"	d	file:=0A=
-ANEG_CFG_RF1	tg3.c	1506;"	d	file:=0A=
-ANEG_CFG_RF2	tg3.c	1505;"	d	file:=0A=
-ANEG_DONE	tg3.c	1515;"	d	file:=0A=
-ANEG_FAILED	tg3.c	1517;"	d	file:=0A=
-ANEG_OK	tg3.c	1514;"	d	file:=0A=
-ANEG_STATE_ABILITY_DETECT	tg3.c	1465;"	d	file:=0A=
-ANEG_STATE_ABILITY_DETECT_INIT	tg3.c	1464;"	d	file:=0A=
-ANEG_STATE_ACK_DETECT	tg3.c	1467;"	d	file:=0A=
-ANEG_STATE_ACK_DETECT_INIT	tg3.c	1466;"	d	file:=0A=
-ANEG_STATE_AN_ENABLE	tg3.c	1460;"	d	file:=0A=
-ANEG_STATE_COMPLETE_ACK	tg3.c	1469;"	d	file:=0A=
-ANEG_STATE_COMPLETE_ACK_INIT	tg3.c	1468;"	d	file:=0A=
-ANEG_STATE_DISABLE_LINK_OK	tg3.c	1463;"	d	file:=0A=
-ANEG_STATE_IDLE_DETECT	tg3.c	1471;"	d	file:=0A=
-ANEG_STATE_IDLE_DETECT_INIT	tg3.c	1470;"	d	file:=0A=
-ANEG_STATE_LINK_OK	tg3.c	1472;"	d	file:=0A=
-ANEG_STATE_NEXT_PAGE_WAIT	tg3.c	1474;"	d	file:=0A=
-ANEG_STATE_NEXT_PAGE_WAIT_INIT	tg3.c	1473;"	d	file:=0A=
-ANEG_STATE_RESTART	tg3.c	1462;"	d	file:=0A=
-ANEG_STATE_RESTART_INIT	tg3.c	1461;"	d	file:=0A=
-ANEG_STATE_SETTLE_TIME	tg3.c	1519;"	d	file:=0A=
-ANEG_STATE_UNKNOWN	tg3.c	1459;"	d	file:=0A=
-ANEG_TIMER_ENAB	tg3.c	1516;"	d	file:=0A=
-ASIC_REV_5700	tg3.h	122;"	d=0A=
-ASIC_REV_5701	tg3.h	123;"	d=0A=
-ASIC_REV_5703	tg3.h	124;"	d=0A=
-ASIC_REV_5704	tg3.h	125;"	d=0A=
-ASIC_REV_5705	tg3.h	126;"	d=0A=
-AUTONEG_INVALID	tg3.h	1793;"	d=0A=
-BDINFO_FLAGS_DISABLED	tg3.h	18;"	d=0A=
-BDINFO_FLAGS_MAXLEN_MASK	tg3.h	19;"	d=0A=
-BDINFO_FLAGS_MAXLEN_SHIFT	tg3.h	20;"	d=0A=
-BDINFO_FLAGS_USE_EXT_RECV	tg3.h	17;"	d=0A=
-BUFMGR_DMA_DESC_POOL_ADDR	tg3.h	911;"	d=0A=
-BUFMGR_DMA_DESC_POOL_SIZE	tg3.h	912;"	d=0A=
-BUFMGR_DMA_HIGH_WATER	tg3.h	915;"	d=0A=
-BUFMGR_DMA_LOW_WATER	tg3.h	913;"	d=0A=
-BUFMGR_HWDIAG_0	tg3.h	921;"	d=0A=
-BUFMGR_HWDIAG_1	tg3.h	922;"	d=0A=
-BUFMGR_HWDIAG_2	tg3.h	923;"	d=0A=
-BUFMGR_MB_ALLOC_BIT	tg3.h	907;"	d=0A=
-BUFMGR_MB_HIGH_WATER	tg3.h	902;"	d=0A=
-BUFMGR_MB_MACRX_LOW_WATER	tg3.h	898;"	d=0A=
-BUFMGR_MB_POOL_ADDR	tg3.h	892;"	d=0A=
-BUFMGR_MB_POOL_SIZE	tg3.h	893;"	d=0A=
-BUFMGR_MB_RDMA_LOW_WATER	tg3.h	894;"	d=0A=
-BUFMGR_MODE	tg3.h	883;"	d=0A=
-BUFMGR_MODE_ATTN_ENABLE	tg3.h	886;"	d=0A=
-BUFMGR_MODE_BM_TEST	tg3.h	887;"	d=0A=
-BUFMGR_MODE_ENABLE	tg3.h	885;"	d=0A=
-BUFMGR_MODE_MBLOW_ATTN_ENAB	tg3.h	888;"	d=0A=
-BUFMGR_MODE_RESET	tg3.h	884;"	d=0A=
-BUFMGR_RX_DMA_ALLOC_REQ	tg3.h	917;"	d=0A=
-BUFMGR_RX_DMA_ALLOC_RESP	tg3.h	918;"	d=0A=
-BUFMGR_RX_MB_ALLOC_REQ	tg3.h	906;"	d=0A=
-BUFMGR_RX_MB_ALLOC_RESP	tg3.h	908;"	d=0A=
-BUFMGR_STATUS	tg3.h	889;"	d=0A=
-BUFMGR_STATUS_ERROR	tg3.h	890;"	d=0A=
-BUFMGR_STATUS_MBLOW	tg3.h	891;"	d=0A=
-BUFMGR_TX_DMA_ALLOC_REQ	tg3.h	919;"	d=0A=
-BUFMGR_TX_DMA_ALLOC_RESP	tg3.h	920;"	d=0A=
-BUFMGR_TX_MB_ALLOC_REQ	tg3.h	909;"	d=0A=
-BUFMGR_TX_MB_ALLOC_RESP	tg3.h	910;"	d=0A=
-CHIPREV_5700_AX	tg3.h	128;"	d=0A=
-CHIPREV_5700_BX	tg3.h	129;"	d=0A=
-CHIPREV_5700_CX	tg3.h	130;"	d=0A=
-CHIPREV_5701_AX	tg3.h	131;"	d=0A=
-CHIPREV_ID_5700_A0	tg3.h	101;"	d=0A=
-CHIPREV_ID_5700_A1	tg3.h	102;"	d=0A=
-CHIPREV_ID_5700_ALTIMA	tg3.h	106;"	d=0A=
-CHIPREV_ID_5700_B0	tg3.h	103;"	d=0A=
-CHIPREV_ID_5700_B1	tg3.h	104;"	d=0A=
-CHIPREV_ID_5700_B3	tg3.h	105;"	d=0A=
-CHIPREV_ID_5700_C0	tg3.h	107;"	d=0A=
-CHIPREV_ID_5701_A0	tg3.h	108;"	d=0A=
-CHIPREV_ID_5701_B0	tg3.h	109;"	d=0A=
-CHIPREV_ID_5701_B2	tg3.h	110;"	d=0A=
-CHIPREV_ID_5701_B5	tg3.h	111;"	d=0A=
-CHIPREV_ID_5703_A0	tg3.h	112;"	d=0A=
-CHIPREV_ID_5703_A1	tg3.h	113;"	d=0A=
-CHIPREV_ID_5703_A2	tg3.h	114;"	d=0A=
-CHIPREV_ID_5703_A3	tg3.h	115;"	d=0A=
-CHIPREV_ID_5704_A0	tg3.h	116;"	d=0A=
-CHIPREV_ID_5704_A1	tg3.h	117;"	d=0A=
-CHIPREV_ID_5704_A2	tg3.h	118;"	d=0A=
-CHIPREV_ID_5705_A0	tg3.h	119;"	d=0A=
-CHIPREV_ID_5705_A1	tg3.h	120;"	d=0A=
-CLOCK_CTRL_44MHZ_CORE	tg3.h	186;"	d=0A=
-CLOCK_CTRL_625_CORE	tg3.h	187;"	d=0A=
-CLOCK_CTRL_ALTCLK	tg3.h	184;"	d=0A=
-CLOCK_CTRL_CLKRUN_OENABLE	tg3.h	189;"	d=0A=
-CLOCK_CTRL_CORECLK_DISABLE	tg3.h	181;"	d=0A=
-CLOCK_CTRL_DELAY_PCI_GRANT	tg3.h	190;"	d=0A=
-CLOCK_CTRL_FORCE_CLKRUN	tg3.h	188;"	d=0A=
-CLOCK_CTRL_PWRDOWN_PLL133	tg3.h	185;"	d=0A=
-CLOCK_CTRL_RXCLK_DISABLE	tg3.h	182;"	d=0A=
-CLOCK_CTRL_TXCLK_DISABLE	tg3.h	183;"	d=0A=
-COS_out_packets	tg3.h	/^	tg3_stat64_t			COS_out_packets[16];$/;"	m	=
struct:tg3_hw_stats=0A=
-COS_rx_filter_dropped	tg3.h	/^	tg3_stat64_t			=
COS_rx_filter_dropped;$/;"	m	struct:tg3_hw_stats=0A=
-COS_rx_packets	tg3.h	/^	tg3_stat64_t			COS_rx_packets[16];$/;"	m	=
struct:tg3_hw_stats=0A=
-CPU_EVTMASK	tg3.h	982;"	d=0A=
-CPU_HW_BP	tg3.h	990;"	d=0A=
-CPU_INSN	tg3.h	985;"	d=0A=
-CPU_LAST_BRANCH_ADDR	tg3.h	993;"	d=0A=
-CPU_MODE	tg3.h	978;"	d=0A=
-CPU_MODE_HALT	tg3.h	980;"	d=0A=
-CPU_MODE_RESET	tg3.h	979;"	d=0A=
-CPU_PC	tg3.h	984;"	d=0A=
-CPU_R0	tg3.h	996;"	d=0A=
-CPU_R1	tg3.h	997;"	d=0A=
-CPU_R10	tg3.h	1006;"	d=0A=
-CPU_R11	tg3.h	1007;"	d=0A=
-CPU_R12	tg3.h	1008;"	d=0A=
-CPU_R13	tg3.h	1009;"	d=0A=
-CPU_R14	tg3.h	1010;"	d=0A=
-CPU_R15	tg3.h	1011;"	d=0A=
-CPU_R16	tg3.h	1012;"	d=0A=
-CPU_R17	tg3.h	1013;"	d=0A=
-CPU_R18	tg3.h	1014;"	d=0A=
-CPU_R19	tg3.h	1015;"	d=0A=
-CPU_R2	tg3.h	998;"	d=0A=
-CPU_R20	tg3.h	1016;"	d=0A=
-CPU_R21	tg3.h	1017;"	d=0A=
-CPU_R22	tg3.h	1018;"	d=0A=
-CPU_R23	tg3.h	1019;"	d=0A=
-CPU_R24	tg3.h	1020;"	d=0A=
-CPU_R25	tg3.h	1021;"	d=0A=
-CPU_R26	tg3.h	1022;"	d=0A=
-CPU_R27	tg3.h	1023;"	d=0A=
-CPU_R28	tg3.h	1024;"	d=0A=
-CPU_R29	tg3.h	1025;"	d=0A=
-CPU_R3	tg3.h	999;"	d=0A=
-CPU_R30	tg3.h	1026;"	d=0A=
-CPU_R31	tg3.h	1027;"	d=0A=
-CPU_R4	tg3.h	1000;"	d=0A=
-CPU_R5	tg3.h	1001;"	d=0A=
-CPU_R6	tg3.h	1002;"	d=0A=
-CPU_R7	tg3.h	1003;"	d=0A=
-CPU_R8	tg3.h	1004;"	d=0A=
-CPU_R9	tg3.h	1005;"	d=0A=
-CPU_SPAD_UFLOW	tg3.h	986;"	d=0A=
-CPU_SPAD_UFLOW_SET	tg3.h	994;"	d=0A=
-CPU_STATE	tg3.h	981;"	d=0A=
-CPU_WDOG_CLEAR	tg3.h	987;"	d=0A=
-CPU_WDOG_PC	tg3.h	989;"	d=0A=
-CPU_WDOG_SAVED_STATE	tg3.h	992;"	d=0A=
-CPU_WDOG_VECTOR	tg3.h	988;"	d=0A=
-DEFAULT_DMA_HIGH_WATER	tg3.h	916;"	d=0A=
-DEFAULT_DMA_LOW_WATER	tg3.h	914;"	d=0A=
-DEFAULT_MB_HIGH_WATER	tg3.h	903;"	d=0A=
-DEFAULT_MB_HIGH_WATER_5705	tg3.h	904;"	d=0A=
-DEFAULT_MB_HIGH_WATER_JUMBO	tg3.h	905;"	d=0A=
-DEFAULT_MB_MACRX_LOW_WATER	tg3.h	899;"	d=0A=
-DEFAULT_MB_MACRX_LOW_WATER_5705	tg3.h	900;"	d=0A=
-DEFAULT_MB_MACRX_LOW_WATER_JUMBO	tg3.h	901;"	d=0A=
-DEFAULT_MB_RDMA_LOW_WATER	tg3.h	895;"	d=0A=
-DEFAULT_MB_RDMA_LOW_WATER_5705	tg3.h	896;"	d=0A=
-DEFAULT_MB_RDMA_LOW_WATER_JUMBO	tg3.h	897;"	d=0A=
-DEFAULT_RXCOAL_MAXF_INT	tg3.h	823;"	d=0A=
-DEFAULT_RXCOAL_TICK_INT	tg3.h	819;"	d=0A=
-DEFAULT_RXCOL_TICKS	tg3.h	804;"	d=0A=
-DEFAULT_RXMAX_FRAMES	tg3.h	812;"	d=0A=
-DEFAULT_STAT_COAL_TICKS	tg3.h	827;"	d=0A=
-DEFAULT_TXCOAL_MAXF_INT	tg3.h	825;"	d=0A=
-DEFAULT_TXCOAL_TICK_INT	tg3.h	821;"	d=0A=
-DEFAULT_TXCOL_TICKS	tg3.h	808;"	d=0A=
-DEFAULT_TXMAX_FRAMES	tg3.h	816;"	d=0A=
-DMAC_MODE	tg3.h	1186;"	d=0A=
-DMAC_MODE_ENABLE	tg3.h	1188;"	d=0A=
-DMAC_MODE_RESET	tg3.h	1187;"	d=0A=
-DMA_RWCTRL_ASSERT_ALL_BE	tg3.h	165;"	d=0A=
-DMA_RWCTRL_MIN_DMA	tg3.h	139;"	d=0A=
-DMA_RWCTRL_MIN_DMA_SHIFT	tg3.h	140;"	d=0A=
-DMA_RWCTRL_ONE_DMA	tg3.h	159;"	d=0A=
-DMA_RWCTRL_PCI_READ_CMD	tg3.h	166;"	d=0A=
-DMA_RWCTRL_PCI_READ_CMD_SHIFT	tg3.h	167;"	d=0A=
-DMA_RWCTRL_PCI_WRITE_CMD	tg3.h	168;"	d=0A=
-DMA_RWCTRL_PCI_WRITE_CMD_SHIFT	tg3.h	169;"	d=0A=
-DMA_RWCTRL_READ_BNDRY_1024	tg3.h	149;"	d=0A=
-DMA_RWCTRL_READ_BNDRY_128	tg3.h	146;"	d=0A=
-DMA_RWCTRL_READ_BNDRY_16	tg3.h	143;"	d=0A=
-DMA_RWCTRL_READ_BNDRY_256	tg3.h	147;"	d=0A=
-DMA_RWCTRL_READ_BNDRY_32	tg3.h	144;"	d=0A=
-DMA_RWCTRL_READ_BNDRY_512	tg3.h	148;"	d=0A=
-DMA_RWCTRL_READ_BNDRY_64	tg3.h	145;"	d=0A=
-DMA_RWCTRL_READ_BNDRY_DISAB	tg3.h	142;"	d=0A=
-DMA_RWCTRL_READ_BNDRY_MASK	tg3.h	141;"	d=0A=
-DMA_RWCTRL_READ_WATER	tg3.h	160;"	d=0A=
-DMA_RWCTRL_READ_WATER_SHIFT	tg3.h	161;"	d=0A=
-DMA_RWCTRL_USE_MEM_READ_MULT	tg3.h	164;"	d=0A=
-DMA_RWCTRL_WRITE_BNDRY_1024	tg3.h	158;"	d=0A=
-DMA_RWCTRL_WRITE_BNDRY_128	tg3.h	155;"	d=0A=
-DMA_RWCTRL_WRITE_BNDRY_16	tg3.h	152;"	d=0A=
-DMA_RWCTRL_WRITE_BNDRY_256	tg3.h	156;"	d=0A=
-DMA_RWCTRL_WRITE_BNDRY_32	tg3.h	153;"	d=0A=
-DMA_RWCTRL_WRITE_BNDRY_512	tg3.h	157;"	d=0A=
-DMA_RWCTRL_WRITE_BNDRY_64	tg3.h	154;"	d=0A=
-DMA_RWCTRL_WRITE_BNDRY_DISAB	tg3.h	151;"	d=0A=
-DMA_RWCTRL_WRITE_BNDRY_MASK	tg3.h	150;"	d=0A=
-DMA_RWCTRL_WRITE_WATER	tg3.h	162;"	d=0A=
-DMA_RWCTRL_WRITE_WATER_SHIFT	tg3.h	163;"	d=0A=
-DRV_MODULE_NAME	tg3.c	57;"	d	file:=0A=
-DRV_MODULE_RELDATE	tg3.c	60;"	d	file:=0A=
-DRV_MODULE_VERSION	tg3.c	59;"	d	file:=0A=
-DRV_STATE_START	tg3.h	1385;"	d=0A=
-DRV_STATE_SUSPEND	tg3.h	1388;"	d=0A=
-DRV_STATE_UNLOAD	tg3.h	1386;"	d=0A=
-DRV_STATE_WOL	tg3.h	1387;"	d=0A=
-DUPLEX_INVALID	tg3.h	1792;"	d=0A=
-EEPROM_ADDR_ADDR_MASK	tg3.h	1278;"	d=0A=
-EEPROM_ADDR_ADDR_SHIFT	tg3.h	1279;"	d=0A=
-EEPROM_ADDR_CLKPERD_SHIFT	tg3.h	1277;"	d=0A=
-EEPROM_ADDR_COMPLETE	tg3.h	1272;"	d=0A=
-EEPROM_ADDR_DEVID_MASK	tg3.h	1274;"	d=0A=
-EEPROM_ADDR_DEVID_SHIFT	tg3.h	1275;"	d=0A=
-EEPROM_ADDR_FSM_RESET	tg3.h	1273;"	d=0A=
-EEPROM_ADDR_READ	tg3.h	1271;"	d=0A=
-EEPROM_ADDR_START	tg3.h	1276;"	d=0A=
-EEPROM_ADDR_WRITE	tg3.h	1270;"	d=0A=
-EEPROM_CHIP_SIZE	tg3.h	1281;"	d=0A=
-EEPROM_DEFAULT_CLOCK_PERIOD	tg3.h	1280;"	d=0A=
-FTQ_DMA_COMP_DISC_CTL	tg3.h	1115;"	d=0A=
-FTQ_DMA_COMP_DISC_FIFO_ENQDEQ	tg3.h	1117;"	d=0A=
-FTQ_DMA_COMP_DISC_FULL_CNT	tg3.h	1116;"	d=0A=
-FTQ_DMA_COMP_DISC_WRITE_PEEK	tg3.h	1118;"	d=0A=
-FTQ_DMA_HIGH_READ_CTL	tg3.h	1111;"	d=0A=
-FTQ_DMA_HIGH_READ_FIFO_ENQDEQ	tg3.h	1113;"	d=0A=
-FTQ_DMA_HIGH_READ_FULL_CNT	tg3.h	1112;"	d=0A=
-FTQ_DMA_HIGH_READ_WRITE_PEEK	tg3.h	1114;"	d=0A=
-FTQ_DMA_HIGH_WRITE_CTL	tg3.h	1131;"	d=0A=
-FTQ_DMA_HIGH_WRITE_FIFO_ENQDEQ	tg3.h	1133;"	d=0A=
-FTQ_DMA_HIGH_WRITE_FULL_CNT	tg3.h	1132;"	d=0A=
-FTQ_DMA_HIGH_WRITE_WRITE_PEEK	tg3.h	1134;"	d=0A=
-FTQ_DMA_NORM_READ_CTL	tg3.h	1107;"	d=0A=
-FTQ_DMA_NORM_READ_FIFO_ENQDEQ	tg3.h	1109;"	d=0A=
-FTQ_DMA_NORM_READ_FULL_CNT	tg3.h	1108;"	d=0A=
-FTQ_DMA_NORM_READ_WRITE_PEEK	tg3.h	1110;"	d=0A=
-FTQ_DMA_NORM_WRITE_CTL	tg3.h	1127;"	d=0A=
-FTQ_DMA_NORM_WRITE_FIFO_ENQDEQ	tg3.h	1129;"	d=0A=
-FTQ_DMA_NORM_WRITE_FULL_CNT	tg3.h	1128;"	d=0A=
-FTQ_DMA_NORM_WRITE_WRITE_PEEK	tg3.h	1130;"	d=0A=
-FTQ_HOST_COAL_CTL	tg3.h	1143;"	d=0A=
-FTQ_HOST_COAL_FIFO_ENQDEQ	tg3.h	1145;"	d=0A=
-FTQ_HOST_COAL_FULL_CNT	tg3.h	1144;"	d=0A=
-FTQ_HOST_COAL_WRITE_PEEK	tg3.h	1146;"	d=0A=
-FTQ_MAC_TX_CTL	tg3.h	1147;"	d=0A=
-FTQ_MAC_TX_FIFO_ENQDEQ	tg3.h	1149;"	d=0A=
-FTQ_MAC_TX_FULL_CNT	tg3.h	1148;"	d=0A=
-FTQ_MAC_TX_WRITE_PEEK	tg3.h	1150;"	d=0A=
-FTQ_MB_FREE_CTL	tg3.h	1151;"	d=0A=
-FTQ_MB_FREE_FIFO_ENQDEQ	tg3.h	1153;"	d=0A=
-FTQ_MB_FREE_FULL_CNT	tg3.h	1152;"	d=0A=
-FTQ_MB_FREE_WRITE_PEEK	tg3.h	1154;"	d=0A=
-FTQ_RCVBD_COMP_CTL	tg3.h	1155;"	d=0A=
-FTQ_RCVBD_COMP_FIFO_ENQDEQ	tg3.h	1157;"	d=0A=
-FTQ_RCVBD_COMP_FULL_CNT	tg3.h	1156;"	d=0A=
-FTQ_RCVBD_COMP_WRITE_PEEK	tg3.h	1158;"	d=0A=
-FTQ_RCVDATA_COMP_CTL	tg3.h	1167;"	d=0A=
-FTQ_RCVDATA_COMP_FIFO_ENQDEQ	tg3.h	1169;"	d=0A=
-FTQ_RCVDATA_COMP_FULL_CNT	tg3.h	1168;"	d=0A=
-FTQ_RCVDATA_COMP_WRITE_PEEK	tg3.h	1170;"	d=0A=
-FTQ_RCVDATA_INI_CTL	tg3.h	1163;"	d=0A=
-FTQ_RCVDATA_INI_FIFO_ENQDEQ	tg3.h	1165;"	d=0A=
-FTQ_RCVDATA_INI_FULL_CNT	tg3.h	1164;"	d=0A=
-FTQ_RCVDATA_INI_WRITE_PEEK	tg3.h	1166;"	d=0A=
-FTQ_RCVLST_PLMT_CTL	tg3.h	1159;"	d=0A=
-FTQ_RCVLST_PLMT_FIFO_ENQDEQ	tg3.h	1161;"	d=0A=
-FTQ_RCVLST_PLMT_FULL_CNT	tg3.h	1160;"	d=0A=
-FTQ_RCVLST_PLMT_WRITE_PEEK	tg3.h	1162;"	d=0A=
-FTQ_RESET	tg3.h	1105;"	d=0A=
-FTQ_SEND_BD_COMP_CTL	tg3.h	1119;"	d=0A=
-FTQ_SEND_BD_COMP_FIFO_ENQDEQ	tg3.h	1121;"	d=0A=
-FTQ_SEND_BD_COMP_FULL_CNT	tg3.h	1120;"	d=0A=
-FTQ_SEND_BD_COMP_WRITE_PEEK	tg3.h	1122;"	d=0A=
-FTQ_SEND_DATA_COMP_CTL	tg3.h	1139;"	d=0A=
-FTQ_SEND_DATA_COMP_FIFO_ENQDEQ	tg3.h	1141;"	d=0A=
-FTQ_SEND_DATA_COMP_FULL_CNT	tg3.h	1140;"	d=0A=
-FTQ_SEND_DATA_COMP_WRITE_PEEK	tg3.h	1142;"	d=0A=
-FTQ_SEND_DATA_INIT_CTL	tg3.h	1123;"	d=0A=
-FTQ_SEND_DATA_INIT_FIFO_ENQDEQ	tg3.h	1125;"	d=0A=
-FTQ_SEND_DATA_INIT_FULL_CNT	tg3.h	1124;"	d=0A=
-FTQ_SEND_DATA_INIT_WRITE_PEEK	tg3.h	1126;"	d=0A=
-FTQ_SWTYPE1_CTL	tg3.h	1135;"	d=0A=
-FTQ_SWTYPE1_FIFO_ENQDEQ	tg3.h	1137;"	d=0A=
-FTQ_SWTYPE1_FULL_CNT	tg3.h	1136;"	d=0A=
-FTQ_SWTYPE1_WRITE_PEEK	tg3.h	1138;"	d=0A=
-FTQ_SWTYPE2_CTL	tg3.h	1171;"	d=0A=
-FTQ_SWTYPE2_FIFO_ENQDEQ	tg3.h	1173;"	d=0A=
-FTQ_SWTYPE2_FULL_CNT	tg3.h	1172;"	d=0A=
-FTQ_SWTYPE2_WRITE_PEEK	tg3.h	1174;"	d=0A=
-FWCMD_NICDRV_ALIVE	tg3.h	1375;"	d=0A=
-FWCMD_NICDRV_FIX_DMAR	tg3.h	1379;"	d=0A=
-FWCMD_NICDRV_FIX_DMAW	tg3.h	1380;"	d=0A=
-FWCMD_NICDRV_IPV4ADDR_CHG	tg3.h	1377;"	d=0A=
-FWCMD_NICDRV_IPV6ADDR_CHG	tg3.h	1378;"	d=0A=
-FWCMD_NICDRV_PAUSE_FW	tg3.h	1376;"	d=0A=
-GET_ASIC_REV	tg3.h	121;"	d=0A=
-GET_CHIP_REV	tg3.h	127;"	d=0A=
-GET_CHIP_REV_ID	tg3.h	98;"	d=0A=
-GET_METAL_REV	tg3.h	132;"	d=0A=
-GET_REG32_1	tg3.c	5850;"	d	file:=0A=
-GET_REG32_1	tg3.c	5889;"	d	file:=0A=
-GET_REG32_LOOP	tg3.c	5845;"	d	file:=0A=
-GET_REG32_LOOP	tg3.c	5888;"	d	file:=0A=
-GRCMBOX_GENERAL_0	tg3.h	1038;"	d=0A=
-GRCMBOX_GENERAL_1	tg3.h	1039;"	d=0A=
-GRCMBOX_GENERAL_2	tg3.h	1040;"	d=0A=
-GRCMBOX_GENERAL_3	tg3.h	1041;"	d=0A=
-GRCMBOX_GENERAL_4	tg3.h	1042;"	d=0A=
-GRCMBOX_GENERAL_5	tg3.h	1043;"	d=0A=
-GRCMBOX_GENERAL_6	tg3.h	1044;"	d=0A=
-GRCMBOX_GENERAL_7	tg3.h	1045;"	d=0A=
-GRCMBOX_HIGH_PRIO_EV_MASK	tg3.h	1099;"	d=0A=
-GRCMBOX_HIGH_PRIO_EV_VECTOR	tg3.h	1098;"	d=0A=
-GRCMBOX_INTERRUPT_0	tg3.h	1034;"	d=0A=
-GRCMBOX_INTERRUPT_1	tg3.h	1035;"	d=0A=
-GRCMBOX_INTERRUPT_2	tg3.h	1036;"	d=0A=
-GRCMBOX_INTERRUPT_3	tg3.h	1037;"	d=0A=
-GRCMBOX_LOW_PRIO_EV_MASK	tg3.h	1101;"	d=0A=
-GRCMBOX_LOW_PRIO_EV_VEC	tg3.h	1100;"	d=0A=
-GRCMBOX_RCVJUMBO_PROD_IDX	tg3.h	1048;"	d=0A=
-GRCMBOX_RCVMINI_PROD_IDX	tg3.h	1049;"	d=0A=
-GRCMBOX_RCVRET_CON_IDX_0	tg3.h	1050;"	d=0A=
-GRCMBOX_RCVRET_CON_IDX_1	tg3.h	1051;"	d=0A=
-GRCMBOX_RCVRET_CON_IDX_10	tg3.h	1060;"	d=0A=
-GRCMBOX_RCVRET_CON_IDX_11	tg3.h	1061;"	d=0A=
-GRCMBOX_RCVRET_CON_IDX_12	tg3.h	1062;"	d=0A=
-GRCMBOX_RCVRET_CON_IDX_13	tg3.h	1063;"	d=0A=
-GRCMBOX_RCVRET_CON_IDX_14	tg3.h	1064;"	d=0A=
-GRCMBOX_RCVRET_CON_IDX_15	tg3.h	1065;"	d=0A=
-GRCMBOX_RCVRET_CON_IDX_2	tg3.h	1052;"	d=0A=
-GRCMBOX_RCVRET_CON_IDX_3	tg3.h	1053;"	d=0A=
-GRCMBOX_RCVRET_CON_IDX_4	tg3.h	1054;"	d=0A=
-GRCMBOX_RCVRET_CON_IDX_5	tg3.h	1055;"	d=0A=
-GRCMBOX_RCVRET_CON_IDX_6	tg3.h	1056;"	d=0A=
-GRCMBOX_RCVRET_CON_IDX_7	tg3.h	1057;"	d=0A=
-GRCMBOX_RCVRET_CON_IDX_8	tg3.h	1058;"	d=0A=
-GRCMBOX_RCVRET_CON_IDX_9	tg3.h	1059;"	d=0A=
-GRCMBOX_RCVSTD_PROD_IDX	tg3.h	1047;"	d=0A=
-GRCMBOX_RELOAD_STAT	tg3.h	1046;"	d=0A=
-GRCMBOX_SNDHOST_PROD_IDX_0	tg3.h	1066;"	d=0A=
-GRCMBOX_SNDHOST_PROD_IDX_1	tg3.h	1067;"	d=0A=
-GRCMBOX_SNDHOST_PROD_IDX_10	tg3.h	1076;"	d=0A=
-GRCMBOX_SNDHOST_PROD_IDX_11	tg3.h	1077;"	d=0A=
-GRCMBOX_SNDHOST_PROD_IDX_12	tg3.h	1078;"	d=0A=
-GRCMBOX_SNDHOST_PROD_IDX_13	tg3.h	1079;"	d=0A=
-GRCMBOX_SNDHOST_PROD_IDX_14	tg3.h	1080;"	d=0A=
-GRCMBOX_SNDHOST_PROD_IDX_15	tg3.h	1081;"	d=0A=
-GRCMBOX_SNDHOST_PROD_IDX_2	tg3.h	1068;"	d=0A=
-GRCMBOX_SNDHOST_PROD_IDX_3	tg3.h	1069;"	d=0A=
-GRCMBOX_SNDHOST_PROD_IDX_4	tg3.h	1070;"	d=0A=
-GRCMBOX_SNDHOST_PROD_IDX_5	tg3.h	1071;"	d=0A=
-GRCMBOX_SNDHOST_PROD_IDX_6	tg3.h	1072;"	d=0A=
-GRCMBOX_SNDHOST_PROD_IDX_7	tg3.h	1073;"	d=0A=
-GRCMBOX_SNDHOST_PROD_IDX_8	tg3.h	1074;"	d=0A=
-GRCMBOX_SNDHOST_PROD_IDX_9	tg3.h	1075;"	d=0A=
-GRCMBOX_SNDNIC_PROD_IDX_0	tg3.h	1082;"	d=0A=
-GRCMBOX_SNDNIC_PROD_IDX_1	tg3.h	1083;"	d=0A=
-GRCMBOX_SNDNIC_PROD_IDX_10	tg3.h	1092;"	d=0A=
-GRCMBOX_SNDNIC_PROD_IDX_11	tg3.h	1093;"	d=0A=
-GRCMBOX_SNDNIC_PROD_IDX_12	tg3.h	1094;"	d=0A=
-GRCMBOX_SNDNIC_PROD_IDX_13	tg3.h	1095;"	d=0A=
-GRCMBOX_SNDNIC_PROD_IDX_14	tg3.h	1096;"	d=0A=
-GRCMBOX_SNDNIC_PROD_IDX_15	tg3.h	1097;"	d=0A=
-GRCMBOX_SNDNIC_PROD_IDX_2	tg3.h	1084;"	d=0A=
-GRCMBOX_SNDNIC_PROD_IDX_3	tg3.h	1085;"	d=0A=
-GRCMBOX_SNDNIC_PROD_IDX_4	tg3.h	1086;"	d=0A=
-GRCMBOX_SNDNIC_PROD_IDX_5	tg3.h	1087;"	d=0A=
-GRCMBOX_SNDNIC_PROD_IDX_6	tg3.h	1088;"	d=0A=
-GRCMBOX_SNDNIC_PROD_IDX_7	tg3.h	1089;"	d=0A=
-GRCMBOX_SNDNIC_PROD_IDX_8	tg3.h	1090;"	d=0A=
-GRCMBOX_SNDNIC_PROD_IDX_9	tg3.h	1091;"	d=0A=
-GRC_EEPROM_ADDR	tg3.h	1269;"	d=0A=
-GRC_EEPROM_CTRL	tg3.h	1283;"	d=0A=
-GRC_EEPROM_DATA	tg3.h	1282;"	d=0A=
-GRC_LCLCTRL_AUTO_SEEPROM	tg3.h	1258;"	d=0A=
-GRC_LCLCTRL_BANK_SELECT	tg3.h	1256;"	d=0A=
-GRC_LCLCTRL_CLEARINT	tg3.h	1235;"	d=0A=
-GRC_LCLCTRL_EXTMEM_ENABLE	tg3.h	1247;"	d=0A=
-GRC_LCLCTRL_GPIO_INPUT0	tg3.h	1238;"	d=0A=
-GRC_LCLCTRL_GPIO_INPUT1	tg3.h	1239;"	d=0A=
-GRC_LCLCTRL_GPIO_INPUT2	tg3.h	1240;"	d=0A=
-GRC_LCLCTRL_GPIO_OE0	tg3.h	1241;"	d=0A=
-GRC_LCLCTRL_GPIO_OE1	tg3.h	1242;"	d=0A=
-GRC_LCLCTRL_GPIO_OE2	tg3.h	1243;"	d=0A=
-GRC_LCLCTRL_GPIO_OUTPUT0	tg3.h	1244;"	d=0A=
-GRC_LCLCTRL_GPIO_OUTPUT1	tg3.h	1245;"	d=0A=
-GRC_LCLCTRL_GPIO_OUTPUT2	tg3.h	1246;"	d=0A=
-GRC_LCLCTRL_INT_ACTIVE	tg3.h	1234;"	d=0A=
-GRC_LCLCTRL_INT_ON_ATTN	tg3.h	1237;"	d=0A=
-GRC_LCLCTRL_MEMSZ_16M	tg3.h	1255;"	d=0A=
-GRC_LCLCTRL_MEMSZ_1M	tg3.h	1251;"	d=0A=
-GRC_LCLCTRL_MEMSZ_256K	tg3.h	1249;"	d=0A=
-GRC_LCLCTRL_MEMSZ_2M	tg3.h	1252;"	d=0A=
-GRC_LCLCTRL_MEMSZ_4M	tg3.h	1253;"	d=0A=
-GRC_LCLCTRL_MEMSZ_512K	tg3.h	1250;"	d=0A=
-GRC_LCLCTRL_MEMSZ_8M	tg3.h	1254;"	d=0A=
-GRC_LCLCTRL_MEMSZ_MASK	tg3.h	1248;"	d=0A=
-GRC_LCLCTRL_SETINT	tg3.h	1236;"	d=0A=
-GRC_LCLCTRL_SSRAM_TYPE	tg3.h	1257;"	d=0A=
-GRC_LOCAL_CTRL	tg3.h	1233;"	d=0A=
-GRC_MDI_CTRL	tg3.h	1284;"	d=0A=
-GRC_MEM_POWER_UP	tg3.h	1268;"	d=0A=
-GRC_MISC_CFG	tg3.h	1216;"	d=0A=
-GRC_MISC_CFG_BOARD_ID_5700	tg3.h	1221;"	d=0A=
-GRC_MISC_CFG_BOARD_ID_5701	tg3.h	1222;"	d=0A=
-GRC_MISC_CFG_BOARD_ID_5702FE	tg3.h	1223;"	d=0A=
-GRC_MISC_CFG_BOARD_ID_5703	tg3.h	1224;"	d=0A=
-GRC_MISC_CFG_BOARD_ID_5703S	tg3.h	1225;"	d=0A=
-GRC_MISC_CFG_BOARD_ID_5704	tg3.h	1226;"	d=0A=
-GRC_MISC_CFG_BOARD_ID_5704CIOBE	tg3.h	1227;"	d=0A=
-GRC_MISC_CFG_BOARD_ID_5704_A2	tg3.h	1228;"	d=0A=
-GRC_MISC_CFG_BOARD_ID_5788	tg3.h	1229;"	d=0A=
-GRC_MISC_CFG_BOARD_ID_5788M	tg3.h	1230;"	d=0A=
-GRC_MISC_CFG_BOARD_ID_AC91002A1	tg3.h	1231;"	d=0A=
-GRC_MISC_CFG_BOARD_ID_MASK	tg3.h	1220;"	d=0A=
-GRC_MISC_CFG_CORECLK_RESET	tg3.h	1217;"	d=0A=
-GRC_MISC_CFG_KEEP_GPHY_POWER	tg3.h	1232;"	d=0A=
-GRC_MISC_CFG_PRESCALAR_MASK	tg3.h	1218;"	d=0A=
-GRC_MISC_CFG_PRESCALAR_SHIFT	tg3.h	1219;"	d=0A=
-GRC_MODE	tg3.h	1192;"	d=0A=
-GRC_MODE_4X_NIC_SEND_RINGS	tg3.h	1214;"	d=0A=
-GRC_MODE_ALLOW_BAD_FRMS	tg3.h	1201;"	d=0A=
-GRC_MODE_BSWAP_DATA	tg3.h	1196;"	d=0A=
-GRC_MODE_BSWAP_NONFRM_DATA	tg3.h	1194;"	d=0A=
-GRC_MODE_FORCE_PCI32BIT	tg3.h	1204;"	d=0A=
-GRC_MODE_HOST_SENDBDS	tg3.h	1206;"	d=0A=
-GRC_MODE_HOST_STACKUP	tg3.h	1205;"	d=0A=
-GRC_MODE_INCL_CRC	tg3.h	1200;"	d=0A=
-GRC_MODE_IRQ_ON_DMA_ATTN	tg3.h	1212;"	d=0A=
-GRC_MODE_IRQ_ON_FLOW_ATTN	tg3.h	1213;"	d=0A=
-GRC_MODE_IRQ_ON_MAC_ATTN	tg3.h	1211;"	d=0A=
-GRC_MODE_IRQ_ON_RX_CPU_ATTN	tg3.h	1210;"	d=0A=
-GRC_MODE_IRQ_ON_TX_CPU_ATTN	tg3.h	1209;"	d=0A=
-GRC_MODE_MCAST_FRM_ENABLE	tg3.h	1215;"	d=0A=
-GRC_MODE_NOFRM_CRACKING	tg3.h	1199;"	d=0A=
-GRC_MODE_NOIRQ_ON_RCV	tg3.h	1203;"	d=0A=
-GRC_MODE_NOIRQ_ON_SENDS	tg3.h	1202;"	d=0A=
-GRC_MODE_NO_RX_PHDR_CSUM	tg3.h	1208;"	d=0A=
-GRC_MODE_NO_TX_PHDR_CSUM	tg3.h	1207;"	d=0A=
-GRC_MODE_SPLITHDR	tg3.h	1198;"	d=0A=
-GRC_MODE_UPD_ON_COAL	tg3.h	1193;"	d=0A=
-GRC_MODE_WSWAP_DATA	tg3.h	1197;"	d=0A=
-GRC_MODE_WSWAP_NONFRM_DATA	tg3.h	1195;"	d=0A=
-GRC_REMOTE_RX_CPU_ATTN	tg3.h	1263;"	d=0A=
-GRC_REMOTE_TX_CPU_ATTN	tg3.h	1267;"	d=0A=
-GRC_RX_CPU_EVENT	tg3.h	1260;"	d=0A=
-GRC_RX_CPU_SEM	tg3.h	1262;"	d=0A=
-GRC_RX_TIMER_REF	tg3.h	1261;"	d=0A=
-GRC_SEEPROM_DELAY	tg3.h	1285;"	d=0A=
-GRC_TIMER	tg3.h	1259;"	d=0A=
-GRC_TX_CPU_EVENT	tg3.h	1264;"	d=0A=
-GRC_TX_CPU_SEM	tg3.h	1266;"	d=0A=
-GRC_TX_TIMER_REF	tg3.h	1265;"	d=0A=
-HIGH_RXCOL_TICKS	tg3.h	805;"	d=0A=
-HIGH_RXMAX_FRAMES	tg3.h	813;"	d=0A=
-HIGH_TXCOL_TICKS	tg3.h	809;"	d=0A=
-HIGH_TXMAX_FRAMES	tg3.h	817;"	d=0A=
-HOSTCC_FLOW_ATTN	tg3.h	833;"	d=0A=
-HOSTCC_JUMBO_CON_IDX	tg3.h	835;"	d=0A=
-HOSTCC_MINI_CON_IDX	tg3.h	837;"	d=0A=
-HOSTCC_MODE	tg3.h	788;"	d=0A=
-HOSTCC_MODE_32BYTE	tg3.h	795;"	d=0A=
-HOSTCC_MODE_64BYTE	tg3.h	794;"	d=0A=
-HOSTCC_MODE_ATTN	tg3.h	791;"	d=0A=
-HOSTCC_MODE_CLRTICK_RXBD	tg3.h	796;"	d=0A=
-HOSTCC_MODE_CLRTICK_TXBD	tg3.h	797;"	d=0A=
-HOSTCC_MODE_ENABLE	tg3.h	790;"	d=0A=
-HOSTCC_MODE_FULL_STATUS	tg3.h	793;"	d=0A=
-HOSTCC_MODE_NOINT_ON_FORCE	tg3.h	799;"	d=0A=
-HOSTCC_MODE_NOINT_ON_NOW	tg3.h	798;"	d=0A=
-HOSTCC_MODE_NOW	tg3.h	792;"	d=0A=
-HOSTCC_MODE_RESET	tg3.h	789;"	d=0A=
-HOSTCC_RET_PROD_IDX_0	tg3.h	839;"	d=0A=
-HOSTCC_RET_PROD_IDX_1	tg3.h	840;"	d=0A=
-HOSTCC_RET_PROD_IDX_10	tg3.h	849;"	d=0A=
-HOSTCC_RET_PROD_IDX_11	tg3.h	850;"	d=0A=
-HOSTCC_RET_PROD_IDX_12	tg3.h	851;"	d=0A=
-HOSTCC_RET_PROD_IDX_13	tg3.h	852;"	d=0A=
-HOSTCC_RET_PROD_IDX_14	tg3.h	853;"	d=0A=
-HOSTCC_RET_PROD_IDX_15	tg3.h	854;"	d=0A=
-HOSTCC_RET_PROD_IDX_2	tg3.h	841;"	d=0A=
-HOSTCC_RET_PROD_IDX_3	tg3.h	842;"	d=0A=
-HOSTCC_RET_PROD_IDX_4	tg3.h	843;"	d=0A=
-HOSTCC_RET_PROD_IDX_5	tg3.h	844;"	d=0A=
-HOSTCC_RET_PROD_IDX_6	tg3.h	845;"	d=0A=
-HOSTCC_RET_PROD_IDX_7	tg3.h	846;"	d=0A=
-HOSTCC_RET_PROD_IDX_8	tg3.h	847;"	d=0A=
-HOSTCC_RET_PROD_IDX_9	tg3.h	848;"	d=0A=
-HOSTCC_RXCOAL_MAXF_INT	tg3.h	822;"	d=0A=
-HOSTCC_RXCOAL_TICK_INT	tg3.h	818;"	d=0A=
-HOSTCC_RXCOL_TICKS	tg3.h	802;"	d=0A=
-HOSTCC_RXMAX_FRAMES	tg3.h	810;"	d=0A=
-HOSTCC_SND_CON_IDX_0	tg3.h	855;"	d=0A=
-HOSTCC_SND_CON_IDX_1	tg3.h	856;"	d=0A=
-HOSTCC_SND_CON_IDX_10	tg3.h	865;"	d=0A=
-HOSTCC_SND_CON_IDX_11	tg3.h	866;"	d=0A=
-HOSTCC_SND_CON_IDX_12	tg3.h	867;"	d=0A=
-HOSTCC_SND_CON_IDX_13	tg3.h	868;"	d=0A=
-HOSTCC_SND_CON_IDX_14	tg3.h	869;"	d=0A=
-HOSTCC_SND_CON_IDX_15	tg3.h	870;"	d=0A=
-HOSTCC_SND_CON_IDX_2	tg3.h	857;"	d=0A=
-HOSTCC_SND_CON_IDX_3	tg3.h	858;"	d=0A=
-HOSTCC_SND_CON_IDX_4	tg3.h	859;"	d=0A=
-HOSTCC_SND_CON_IDX_5	tg3.h	860;"	d=0A=
-HOSTCC_SND_CON_IDX_6	tg3.h	861;"	d=0A=
-HOSTCC_SND_CON_IDX_7	tg3.h	862;"	d=0A=
-HOSTCC_SND_CON_IDX_8	tg3.h	863;"	d=0A=
-HOSTCC_SND_CON_IDX_9	tg3.h	864;"	d=0A=
-HOSTCC_STATS_BLK_HOST_ADDR	tg3.h	829;"	d=0A=
-HOSTCC_STATS_BLK_NIC_ADDR	tg3.h	831;"	d=0A=
-HOSTCC_STATUS	tg3.h	800;"	d=0A=
-HOSTCC_STATUS_BLK_HOST_ADDR	tg3.h	830;"	d=0A=
-HOSTCC_STATUS_BLK_NIC_ADDR	tg3.h	832;"	d=0A=
-HOSTCC_STATUS_ERROR_ATTN	tg3.h	801;"	d=0A=
-HOSTCC_STAT_COAL_TICKS	tg3.h	826;"	d=0A=
-HOSTCC_STD_CON_IDX	tg3.h	836;"	d=0A=
-HOSTCC_TXCOAL_MAXF_INT	tg3.h	824;"	d=0A=
-HOSTCC_TXCOAL_TICK_INT	tg3.h	820;"	d=0A=
-HOSTCC_TXCOL_TICKS	tg3.h	806;"	d=0A=
-HOSTCC_TXMAX_FRAMES	tg3.h	814;"	d=0A=
-KNOWN_PHY_ID	tg3.h	1987;"	d=0A=
-LED_CTRL_1000MBPS_ON	tg3.h	324;"	d=0A=
-LED_CTRL_1000MBPS_STATUS	tg3.h	330;"	d=0A=
-LED_CTRL_100MBPS_ON	tg3.h	325;"	d=0A=
-LED_CTRL_100MBPS_STATUS	tg3.h	331;"	d=0A=
-LED_CTRL_10MBPS_ON	tg3.h	326;"	d=0A=
-LED_CTRL_10MBPS_STATUS	tg3.h	332;"	d=0A=
-LED_CTRL_BLINK_PER_OVERRIDE	tg3.h	339;"	d=0A=
-LED_CTRL_BLINK_RATE_MASK	tg3.h	337;"	d=0A=
-LED_CTRL_BLINK_RATE_OVERRIDE	tg3.h	340;"	d=0A=
-LED_CTRL_BLINK_RATE_SHIFT	tg3.h	338;"	d=0A=
-LED_CTRL_LNKLED_OVERRIDE	tg3.h	323;"	d=0A=
-LED_CTRL_MAC_MODE	tg3.h	334;"	d=0A=
-LED_CTRL_PHY_MODE_1	tg3.h	335;"	d=0A=
-LED_CTRL_PHY_MODE_2	tg3.h	336;"	d=0A=
-LED_CTRL_TRAFFIC_BLINK	tg3.h	328;"	d=0A=
-LED_CTRL_TRAFFIC_LED	tg3.h	329;"	d=0A=
-LED_CTRL_TRAFFIC_OVERRIDE	tg3.h	327;"	d=0A=
-LED_CTRL_TRAFFIC_STATUS	tg3.h	333;"	d=0A=
-LOW_RXCOL_TICKS	tg3.h	803;"	d=0A=
-LOW_RXMAX_FRAMES	tg3.h	811;"	d=0A=
-LOW_TXCOL_TICKS	tg3.h	807;"	d=0A=
-LOW_TXMAX_FRAMES	tg3.h	815;"	d=0A=
-LPA_PAUSE_ASYM	tg3.h	1464;"	d=0A=
-LPA_PAUSE_CAP	tg3.h	1461;"	d=0A=
-MAC_ACPI_LEN_OFFSET	tg3.h	350;"	d=0A=
-MAC_ACPI_MBUF_PTR	tg3.h	349;"	d=0A=
-MAC_ADDR_0_HIGH	tg3.h	341;"	d=0A=
-MAC_ADDR_0_LOW	tg3.h	342;"	d=0A=
-MAC_ADDR_1_HIGH	tg3.h	343;"	d=0A=
-MAC_ADDR_1_LOW	tg3.h	344;"	d=0A=
-MAC_ADDR_2_HIGH	tg3.h	345;"	d=0A=
-MAC_ADDR_2_LOW	tg3.h	346;"	d=0A=
-MAC_ADDR_3_HIGH	tg3.h	347;"	d=0A=
-MAC_ADDR_3_LOW	tg3.h	348;"	d=0A=
-MAC_AUTO_POLL_ERROR	tg3.h	390;"	d=0A=
-MAC_AUTO_POLL_STATUS	tg3.h	389;"	d=0A=
-MAC_EVENT	tg3.h	313;"	d=0A=
-MAC_EVENT_AP_ERROR	tg3.h	318;"	d=0A=
-MAC_EVENT_LNKSTATE_CHANGED	tg3.h	315;"	d=0A=
-MAC_EVENT_MI_COMPLETION	tg3.h	316;"	d=0A=
-MAC_EVENT_MI_INTERRUPT	tg3.h	317;"	d=0A=
-MAC_EVENT_ODI_ERROR	tg3.h	319;"	d=0A=
-MAC_EVENT_PORT_DECODE_ERR	tg3.h	314;"	d=0A=
-MAC_EVENT_RXSTAT_OVERRUN	tg3.h	320;"	d=0A=
-MAC_EVENT_TXSTAT_OVERRUN	tg3.h	321;"	d=0A=
-MAC_EXTADDR_0_HIGH	tg3.h	472;"	d=0A=
-MAC_EXTADDR_0_LOW	tg3.h	473;"	d=0A=
-MAC_EXTADDR_10_HIGH	tg3.h	492;"	d=0A=
-MAC_EXTADDR_10_LOW	tg3.h	493;"	d=0A=
-MAC_EXTADDR_11_HIGH	tg3.h	494;"	d=0A=
-MAC_EXTADDR_11_LOW	tg3.h	495;"	d=0A=
-MAC_EXTADDR_1_HIGH	tg3.h	474;"	d=0A=
-MAC_EXTADDR_1_LOW	tg3.h	475;"	d=0A=
-MAC_EXTADDR_2_HIGH	tg3.h	476;"	d=0A=
-MAC_EXTADDR_2_LOW	tg3.h	477;"	d=0A=
-MAC_EXTADDR_3_HIGH	tg3.h	478;"	d=0A=
-MAC_EXTADDR_3_LOW	tg3.h	479;"	d=0A=
-MAC_EXTADDR_4_HIGH	tg3.h	480;"	d=0A=
-MAC_EXTADDR_4_LOW	tg3.h	481;"	d=0A=
-MAC_EXTADDR_5_HIGH	tg3.h	482;"	d=0A=
-MAC_EXTADDR_5_LOW	tg3.h	483;"	d=0A=
-MAC_EXTADDR_6_HIGH	tg3.h	484;"	d=0A=
-MAC_EXTADDR_6_LOW	tg3.h	485;"	d=0A=
-MAC_EXTADDR_7_HIGH	tg3.h	486;"	d=0A=
-MAC_EXTADDR_7_LOW	tg3.h	487;"	d=0A=
-MAC_EXTADDR_8_HIGH	tg3.h	488;"	d=0A=
-MAC_EXTADDR_8_LOW	tg3.h	489;"	d=0A=
-MAC_EXTADDR_9_HIGH	tg3.h	490;"	d=0A=
-MAC_EXTADDR_9_LOW	tg3.h	491;"	d=0A=
-MAC_HASHREGU_0	tg3.h	468;"	d=0A=
-MAC_HASHREGU_1	tg3.h	469;"	d=0A=
-MAC_HASHREGU_2	tg3.h	470;"	d=0A=
-MAC_HASHREGU_3	tg3.h	471;"	d=0A=
-MAC_HASH_REG_0	tg3.h	427;"	d=0A=
-MAC_HASH_REG_1	tg3.h	428;"	d=0A=
-MAC_HASH_REG_2	tg3.h	429;"	d=0A=
-MAC_HASH_REG_3	tg3.h	430;"	d=0A=
-MAC_LED_CTRL	tg3.h	322;"	d=0A=
-MAC_LOW_WMARK_MAX_RX_FRAME	tg3.h	466;"	d=0A=
-MAC_MI_COM	tg3.h	369;"	d=0A=
-MAC_MI_MODE	tg3.h	383;"	d=0A=
-MAC_MI_MODE_AUTO_POLL	tg3.h	386;"	d=0A=
-MAC_MI_MODE_BASE	tg3.h	388;"	d=0A=
-MAC_MI_MODE_CLK_10MHZ	tg3.h	384;"	d=0A=
-MAC_MI_MODE_CORE_CLK_62MHZ	tg3.h	387;"	d=0A=
-MAC_MI_MODE_SHORT_PREAMBLE	tg3.h	385;"	d=0A=
-MAC_MI_STAT	tg3.h	381;"	d=0A=
-MAC_MI_STAT_LNKSTAT_ATTN_ENAB	tg3.h	382;"	d=0A=
-MAC_MODE	tg3.h	273;"	d=0A=
-MAC_MODE_ACPI_ENABLE	tg3.h	294;"	d=0A=
-MAC_MODE_FHDE_ENABLE	tg3.h	298;"	d=0A=
-MAC_MODE_HALF_DUPLEX	tg3.h	275;"	d=0A=
-MAC_MODE_LINK_POLARITY	tg3.h	285;"	d=0A=
-MAC_MODE_MAGIC_PKT_ENABLE	tg3.h	293;"	d=0A=
-MAC_MODE_MAX_DEFER	tg3.h	284;"	d=0A=
-MAC_MODE_MIP_ENABLE	tg3.h	295;"	d=0A=
-MAC_MODE_PORT_INT_LPBACK	tg3.h	281;"	d=0A=
-MAC_MODE_PORT_MODE_GMII	tg3.h	278;"	d=0A=
-MAC_MODE_PORT_MODE_MASK	tg3.h	276;"	d=0A=
-MAC_MODE_PORT_MODE_MII	tg3.h	279;"	d=0A=
-MAC_MODE_PORT_MODE_NONE	tg3.h	280;"	d=0A=
-MAC_MODE_PORT_MODE_TBI	tg3.h	277;"	d=0A=
-MAC_MODE_RDE_ENABLE	tg3.h	297;"	d=0A=
-MAC_MODE_RESET	tg3.h	274;"	d=0A=
-MAC_MODE_RXSTAT_CLEAR	tg3.h	287;"	d=0A=
-MAC_MODE_RXSTAT_ENABLE	tg3.h	286;"	d=0A=
-MAC_MODE_RXSTAT_FLUSH	tg3.h	288;"	d=0A=
-MAC_MODE_SEND_CONFIGS	tg3.h	292;"	d=0A=
-MAC_MODE_TAGGED_MAC_CTRL	tg3.h	282;"	d=0A=
-MAC_MODE_TDE_ENABLE	tg3.h	296;"	d=0A=
-MAC_MODE_TXSTAT_CLEAR	tg3.h	290;"	d=0A=
-MAC_MODE_TXSTAT_ENABLE	tg3.h	289;"	d=0A=
-MAC_MODE_TXSTAT_FLUSH	tg3.h	291;"	d=0A=
-MAC_MODE_TX_BURSTING	tg3.h	283;"	d=0A=
-MAC_PCS_TEST	tg3.h	359;"	d=0A=
-MAC_RCV_RULE_0	tg3.h	431;"	d=0A=
-MAC_RCV_RULE_1	tg3.h	433;"	d=0A=
-MAC_RCV_RULE_10	tg3.h	451;"	d=0A=
-MAC_RCV_RULE_11	tg3.h	453;"	d=0A=
-MAC_RCV_RULE_12	tg3.h	455;"	d=0A=
-MAC_RCV_RULE_13	tg3.h	457;"	d=0A=
-MAC_RCV_RULE_14	tg3.h	459;"	d=0A=
-MAC_RCV_RULE_15	tg3.h	461;"	d=0A=
-MAC_RCV_RULE_2	tg3.h	435;"	d=0A=
-MAC_RCV_RULE_3	tg3.h	437;"	d=0A=
-MAC_RCV_RULE_4	tg3.h	439;"	d=0A=
-MAC_RCV_RULE_5	tg3.h	441;"	d=0A=
-MAC_RCV_RULE_6	tg3.h	443;"	d=0A=
-MAC_RCV_RULE_7	tg3.h	445;"	d=0A=
-MAC_RCV_RULE_8	tg3.h	447;"	d=0A=
-MAC_RCV_RULE_9	tg3.h	449;"	d=0A=
-MAC_RCV_RULE_CFG	tg3.h	464;"	d=0A=
-MAC_RCV_VALUE_0	tg3.h	432;"	d=0A=
-MAC_RCV_VALUE_1	tg3.h	434;"	d=0A=
-MAC_RCV_VALUE_10	tg3.h	452;"	d=0A=
-MAC_RCV_VALUE_11	tg3.h	454;"	d=0A=
-MAC_RCV_VALUE_12	tg3.h	456;"	d=0A=
-MAC_RCV_VALUE_13	tg3.h	458;"	d=0A=
-MAC_RCV_VALUE_14	tg3.h	460;"	d=0A=
-MAC_RCV_VALUE_15	tg3.h	462;"	d=0A=
-MAC_RCV_VALUE_2	tg3.h	436;"	d=0A=
-MAC_RCV_VALUE_3	tg3.h	438;"	d=0A=
-MAC_RCV_VALUE_4	tg3.h	440;"	d=0A=
-MAC_RCV_VALUE_5	tg3.h	442;"	d=0A=
-MAC_RCV_VALUE_6	tg3.h	444;"	d=0A=
-MAC_RCV_VALUE_7	tg3.h	446;"	d=0A=
-MAC_RCV_VALUE_8	tg3.h	448;"	d=0A=
-MAC_RCV_VALUE_9	tg3.h	450;"	d=0A=
-MAC_RX_AUTO_NEG	tg3.h	366;"	d=0A=
-MAC_RX_MAC_STATE_BASE	tg3.h	500;"	d=0A=
-MAC_RX_MODE	tg3.h	411;"	d=0A=
-MAC_RX_MTU_SIZE	tg3.h	357;"	d=0A=
-MAC_RX_STATS_ALIGN_ERRORS	tg3.h	541;"	d=0A=
-MAC_RX_STATS_BCAST	tg3.h	539;"	d=0A=
-MAC_RX_STATS_FCS_ERRORS	tg3.h	540;"	d=0A=
-MAC_RX_STATS_FRAGMENTS	tg3.h	536;"	d=0A=
-MAC_RX_STATS_FRAME_TOO_LONG	tg3.h	546;"	d=0A=
-MAC_RX_STATS_JABBERS	tg3.h	547;"	d=0A=
-MAC_RX_STATS_MAC_CTRL_RECVD	tg3.h	544;"	d=0A=
-MAC_RX_STATS_MCAST	tg3.h	538;"	d=0A=
-MAC_RX_STATS_OCTETS	tg3.h	534;"	d=0A=
-MAC_RX_STATS_RESV1	tg3.h	535;"	d=0A=
-MAC_RX_STATS_UCAST	tg3.h	537;"	d=0A=
-MAC_RX_STATS_UNDERSIZE	tg3.h	548;"	d=0A=
-MAC_RX_STATS_XOFF_ENTERED	tg3.h	545;"	d=0A=
-MAC_RX_STATS_XOFF_PAUSE_RECVD	tg3.h	543;"	d=0A=
-MAC_RX_STATS_XON_PAUSE_RECVD	tg3.h	542;"	d=0A=
-MAC_RX_STATUS	tg3.h	423;"	d=0A=
-MAC_SERDES_CFG	tg3.h	496;"	d=0A=
-MAC_SERDES_STAT	tg3.h	497;"	d=0A=
-MAC_STATUS	tg3.h	299;"	d=0A=
-MAC_STATUS_AP_ERROR	tg3.h	309;"	d=0A=
-MAC_STATUS_CFG_CHANGED	tg3.h	303;"	d=0A=
-MAC_STATUS_LNKSTATE_CHANGED	tg3.h	306;"	d=0A=
-MAC_STATUS_MI_COMPLETION	tg3.h	307;"	d=0A=
-MAC_STATUS_MI_INTERRUPT	tg3.h	308;"	d=0A=
-MAC_STATUS_ODI_ERROR	tg3.h	310;"	d=0A=
-MAC_STATUS_PCS_SYNCED	tg3.h	300;"	d=0A=
-MAC_STATUS_PORT_DEC_ERR	tg3.h	305;"	d=0A=
-MAC_STATUS_RCVD_CFG	tg3.h	302;"	d=0A=
-MAC_STATUS_RXSTAT_OVERRUN	tg3.h	311;"	d=0A=
-MAC_STATUS_SIGNAL_DET	tg3.h	301;"	d=0A=
-MAC_STATUS_SYNC_CHANGED	tg3.h	304;"	d=0A=
-MAC_STATUS_TXSTAT_OVERRUN	tg3.h	312;"	d=0A=
-MAC_TX_AUTO_NEG	tg3.h	363;"	d=0A=
-MAC_TX_BACKOFF_SEED	tg3.h	355;"	d=0A=
-MAC_TX_LENGTHS	tg3.h	404;"	d=0A=
-MAC_TX_MAC_STATE_BASE	tg3.h	499;"	d=0A=
-MAC_TX_MODE	tg3.h	391;"	d=0A=
-MAC_TX_STATS_BCAST	tg3.h	531;"	d=0A=
-MAC_TX_STATS_COLLISIONS	tg3.h	504;"	d=0A=
-MAC_TX_STATS_DEFERRED	tg3.h	511;"	d=0A=
-MAC_TX_STATS_EXCESSIVE_COL	tg3.h	513;"	d=0A=
-MAC_TX_STATS_LATE_COL	tg3.h	514;"	d=0A=
-MAC_TX_STATS_MAC_ERRORS	tg3.h	508;"	d=0A=
-MAC_TX_STATS_MCAST	tg3.h	530;"	d=0A=
-MAC_TX_STATS_MULT_COLLISIONS	tg3.h	510;"	d=0A=
-MAC_TX_STATS_OCTETS	tg3.h	502;"	d=0A=
-MAC_TX_STATS_RESV1	tg3.h	503;"	d=0A=
-MAC_TX_STATS_RESV2	tg3.h	507;"	d=0A=
-MAC_TX_STATS_RESV3	tg3.h	512;"	d=0A=
-MAC_TX_STATS_RESV4_1	tg3.h	515;"	d=0A=
-MAC_TX_STATS_RESV4_10	tg3.h	524;"	d=0A=
-MAC_TX_STATS_RESV4_11	tg3.h	525;"	d=0A=
-MAC_TX_STATS_RESV4_12	tg3.h	526;"	d=0A=
-MAC_TX_STATS_RESV4_13	tg3.h	527;"	d=0A=
-MAC_TX_STATS_RESV4_14	tg3.h	528;"	d=0A=
-MAC_TX_STATS_RESV4_2	tg3.h	516;"	d=0A=
-MAC_TX_STATS_RESV4_3	tg3.h	517;"	d=0A=
-MAC_TX_STATS_RESV4_4	tg3.h	518;"	d=0A=
-MAC_TX_STATS_RESV4_5	tg3.h	519;"	d=0A=
-MAC_TX_STATS_RESV4_6	tg3.h	520;"	d=0A=
-MAC_TX_STATS_RESV4_7	tg3.h	521;"	d=0A=
-MAC_TX_STATS_RESV4_8	tg3.h	522;"	d=0A=
-MAC_TX_STATS_RESV4_9	tg3.h	523;"	d=0A=
-MAC_TX_STATS_RESV5_1	tg3.h	532;"	d=0A=
-MAC_TX_STATS_RESV5_2	tg3.h	533;"	d=0A=
-MAC_TX_STATS_SINGLE_COLLISIONS	tg3.h	509;"	d=0A=
-MAC_TX_STATS_UCAST	tg3.h	529;"	d=0A=
-MAC_TX_STATS_XOFF_SENT	tg3.h	506;"	d=0A=
-MAC_TX_STATS_XON_SENT	tg3.h	505;"	d=0A=
-MAC_TX_STATUS	tg3.h	397;"	d=0A=
-MAILBOX_GENERAL_0	tg3.h	211;"	d=0A=
-MAILBOX_GENERAL_1	tg3.h	212;"	d=0A=
-MAILBOX_GENERAL_2	tg3.h	213;"	d=0A=
-MAILBOX_GENERAL_3	tg3.h	214;"	d=0A=
-MAILBOX_GENERAL_4	tg3.h	215;"	d=0A=
-MAILBOX_GENERAL_5	tg3.h	216;"	d=0A=
-MAILBOX_GENERAL_6	tg3.h	217;"	d=0A=
-MAILBOX_GENERAL_7	tg3.h	218;"	d=0A=
-MAILBOX_INTERRUPT_0	tg3.h	207;"	d=0A=
-MAILBOX_INTERRUPT_1	tg3.h	208;"	d=0A=
-MAILBOX_INTERRUPT_2	tg3.h	209;"	d=0A=
-MAILBOX_INTERRUPT_3	tg3.h	210;"	d=0A=
-MAILBOX_RCVRET_CON_IDX_0	tg3.h	223;"	d=0A=
-MAILBOX_RCVRET_CON_IDX_1	tg3.h	224;"	d=0A=
-MAILBOX_RCVRET_CON_IDX_10	tg3.h	233;"	d=0A=
-MAILBOX_RCVRET_CON_IDX_11	tg3.h	234;"	d=0A=
-MAILBOX_RCVRET_CON_IDX_12	tg3.h	235;"	d=0A=
-MAILBOX_RCVRET_CON_IDX_13	tg3.h	236;"	d=0A=
-MAILBOX_RCVRET_CON_IDX_14	tg3.h	237;"	d=0A=
-MAILBOX_RCVRET_CON_IDX_15	tg3.h	238;"	d=0A=
-MAILBOX_RCVRET_CON_IDX_2	tg3.h	225;"	d=0A=
-MAILBOX_RCVRET_CON_IDX_3	tg3.h	226;"	d=0A=
-MAILBOX_RCVRET_CON_IDX_4	tg3.h	227;"	d=0A=
-MAILBOX_RCVRET_CON_IDX_5	tg3.h	228;"	d=0A=
-MAILBOX_RCVRET_CON_IDX_6	tg3.h	229;"	d=0A=
-MAILBOX_RCVRET_CON_IDX_7	tg3.h	230;"	d=0A=
-MAILBOX_RCVRET_CON_IDX_8	tg3.h	231;"	d=0A=
-MAILBOX_RCVRET_CON_IDX_9	tg3.h	232;"	d=0A=
-MAILBOX_RCV_JUMBO_PROD_IDX	tg3.h	221;"	d=0A=
-MAILBOX_RCV_MINI_PROD_IDX	tg3.h	222;"	d=0A=
-MAILBOX_RCV_STD_PROD_IDX	tg3.h	220;"	d=0A=
-MAILBOX_RELOAD_STAT	tg3.h	219;"	d=0A=
-MAILBOX_SNDHOST_PROD_IDX_0	tg3.h	239;"	d=0A=
-MAILBOX_SNDHOST_PROD_IDX_1	tg3.h	240;"	d=0A=
-MAILBOX_SNDHOST_PROD_IDX_10	tg3.h	249;"	d=0A=
-MAILBOX_SNDHOST_PROD_IDX_11	tg3.h	250;"	d=0A=
-MAILBOX_SNDHOST_PROD_IDX_12	tg3.h	251;"	d=0A=
-MAILBOX_SNDHOST_PROD_IDX_13	tg3.h	252;"	d=0A=
-MAILBOX_SNDHOST_PROD_IDX_14	tg3.h	253;"	d=0A=
-MAILBOX_SNDHOST_PROD_IDX_15	tg3.h	254;"	d=0A=
-MAILBOX_SNDHOST_PROD_IDX_2	tg3.h	241;"	d=0A=
-MAILBOX_SNDHOST_PROD_IDX_3	tg3.h	242;"	d=0A=
-MAILBOX_SNDHOST_PROD_IDX_4	tg3.h	243;"	d=0A=
-MAILBOX_SNDHOST_PROD_IDX_5	tg3.h	244;"	d=0A=
-MAILBOX_SNDHOST_PROD_IDX_6	tg3.h	245;"	d=0A=
-MAILBOX_SNDHOST_PROD_IDX_7	tg3.h	246;"	d=0A=
-MAILBOX_SNDHOST_PROD_IDX_8	tg3.h	247;"	d=0A=
-MAILBOX_SNDHOST_PROD_IDX_9	tg3.h	248;"	d=0A=
-MAILBOX_SNDNIC_PROD_IDX_0	tg3.h	255;"	d=0A=
-MAILBOX_SNDNIC_PROD_IDX_1	tg3.h	256;"	d=0A=
-MAILBOX_SNDNIC_PROD_IDX_10	tg3.h	265;"	d=0A=
-MAILBOX_SNDNIC_PROD_IDX_11	tg3.h	266;"	d=0A=
-MAILBOX_SNDNIC_PROD_IDX_12	tg3.h	267;"	d=0A=
-MAILBOX_SNDNIC_PROD_IDX_13	tg3.h	268;"	d=0A=
-MAILBOX_SNDNIC_PROD_IDX_14	tg3.h	269;"	d=0A=
-MAILBOX_SNDNIC_PROD_IDX_15	tg3.h	270;"	d=0A=
-MAILBOX_SNDNIC_PROD_IDX_2	tg3.h	257;"	d=0A=
-MAILBOX_SNDNIC_PROD_IDX_3	tg3.h	258;"	d=0A=
-MAILBOX_SNDNIC_PROD_IDX_4	tg3.h	259;"	d=0A=
-MAILBOX_SNDNIC_PROD_IDX_5	tg3.h	260;"	d=0A=
-MAILBOX_SNDNIC_PROD_IDX_6	tg3.h	261;"	d=0A=
-MAILBOX_SNDNIC_PROD_IDX_7	tg3.h	262;"	d=0A=
-MAILBOX_SNDNIC_PROD_IDX_8	tg3.h	263;"	d=0A=
-MAILBOX_SNDNIC_PROD_IDX_9	tg3.h	264;"	d=0A=
-MAX_WAIT_CNT	tg3.c	3296;"	d	file:=0A=
-MBFREE_MODE	tg3.h	781;"	d=0A=
-MBFREE_MODE_ENABLE	tg3.h	783;"	d=0A=
-MBFREE_MODE_RESET	tg3.h	782;"	d=0A=
-MBFREE_STATUS	tg3.h	784;"	d=0A=
-MEMARB_MODE	tg3.h	874;"	d=0A=
-MEMARB_MODE_ENABLE	tg3.h	876;"	d=0A=
-MEMARB_MODE_RESET	tg3.h	875;"	d=0A=
-MEMARB_STATUS	tg3.h	877;"	d=0A=
-MEMARB_TRAP_ADDR_HIGH	tg3.h	879;"	d=0A=
-MEMARB_TRAP_ADDR_LOW	tg3.h	878;"	d=0A=
-METAL_REV_A0	tg3.h	133;"	d=0A=
-METAL_REV_A1	tg3.h	134;"	d=0A=
-METAL_REV_B0	tg3.h	135;"	d=0A=
-METAL_REV_B1	tg3.h	136;"	d=0A=
-METAL_REV_B2	tg3.h	137;"	d=0A=
-MII_TG3_AUX_CTRL	tg3.h	1431;"	d=0A=
-MII_TG3_AUX_STAT	tg3.h	1433;"	d=0A=
-MII_TG3_AUX_STAT_1000FULL	tg3.h	1442;"	d=0A=
-MII_TG3_AUX_STAT_1000HALF	tg3.h	1441;"	d=0A=
-MII_TG3_AUX_STAT_100FULL	tg3.h	1440;"	d=0A=
-MII_TG3_AUX_STAT_100HALF	tg3.h	1438;"	d=0A=
-MII_TG3_AUX_STAT_100_4	tg3.h	1439;"	d=0A=
-MII_TG3_AUX_STAT_10FULL	tg3.h	1437;"	d=0A=
-MII_TG3_AUX_STAT_10HALF	tg3.h	1436;"	d=0A=
-MII_TG3_AUX_STAT_LPASS	tg3.h	1434;"	d=0A=
-MII_TG3_AUX_STAT_SPDMASK	tg3.h	1435;"	d=0A=
-MII_TG3_CTRL	tg3.h	1414;"	d=0A=
-MII_TG3_CTRL_ADV_1000_FULL	tg3.h	1416;"	d=0A=
-MII_TG3_CTRL_ADV_1000_HALF	tg3.h	1415;"	d=0A=
-MII_TG3_CTRL_AS_MASTER	tg3.h	1417;"	d=0A=
-MII_TG3_CTRL_ENABLE_AS_MASTER	tg3.h	1418;"	d=0A=
-MII_TG3_DSP_ADDRESS	tg3.h	1429;"	d=0A=
-MII_TG3_DSP_RW_PORT	tg3.h	1427;"	d=0A=
-MII_TG3_EXT_CTRL	tg3.h	1420;"	d=0A=
-MII_TG3_EXT_CTRL_LNK3_LED_MODE	tg3.h	1421;"	d=0A=
-MII_TG3_EXT_CTRL_TBI	tg3.h	1422;"	d=0A=
-MII_TG3_EXT_STAT	tg3.h	1424;"	d=0A=
-MII_TG3_EXT_STAT_LPASS	tg3.h	1425;"	d=0A=
-MII_TG3_IMASK	tg3.h	1445;"	d=0A=
-MII_TG3_INT_ANEG_PAGE_RX	tg3.h	1451;"	d=0A=
-MII_TG3_INT_DUPLEXCHG	tg3.h	1450;"	d=0A=
-MII_TG3_INT_LINKCHG	tg3.h	1448;"	d=0A=
-MII_TG3_INT_SPEEDCHG	tg3.h	1449;"	d=0A=
-MII_TG3_ISTAT	tg3.h	1444;"	d=0A=
-MISC_HOST_CTRL_BYTE_SWAP	tg3.h	88;"	d=0A=
-MISC_HOST_CTRL_CHIPREV	tg3.h	96;"	d=0A=
-MISC_HOST_CTRL_CHIPREV_SHIFT	tg3.h	97;"	d=0A=
-MISC_HOST_CTRL_CLEAR_INT	tg3.h	86;"	d=0A=
-MISC_HOST_CTRL_CLKREG_RW	tg3.h	91;"	d=0A=
-MISC_HOST_CTRL_INDIR_ACCESS	tg3.h	93;"	d=0A=
-MISC_HOST_CTRL_IRQ_MASK_MODE	tg3.h	94;"	d=0A=
-MISC_HOST_CTRL_MASK_PCI_INT	tg3.h	87;"	d=0A=
-MISC_HOST_CTRL_PCISTATE_RW	tg3.h	90;"	d=0A=
-MISC_HOST_CTRL_REGWORD_SWAP	tg3.h	92;"	d=0A=
-MISC_HOST_CTRL_TAGGED_STATUS	tg3.h	95;"	d=0A=
-MISC_HOST_CTRL_WORD_SWAP	tg3.h	89;"	d=0A=
-MI_COM_BUSY	tg3.h	375;"	d=0A=
-MI_COM_CMD_MASK	tg3.h	370;"	d=0A=
-MI_COM_CMD_READ	tg3.h	372;"	d=0A=
-MI_COM_CMD_WRITE	tg3.h	371;"	d=0A=
-MI_COM_DATA_MASK	tg3.h	380;"	d=0A=
-MI_COM_PHY_ADDR_MASK	tg3.h	376;"	d=0A=
-MI_COM_PHY_ADDR_SHIFT	tg3.h	377;"	d=0A=
-MI_COM_READ_FAILED	tg3.h	373;"	d=0A=
-MI_COM_REG_ADDR_MASK	tg3.h	378;"	d=0A=
-MI_COM_REG_ADDR_SHIFT	tg3.h	379;"	d=0A=
-MI_COM_START	tg3.h	374;"	d=0A=
-MR_AN_COMPLETE	tg3.c	1479;"	d	file:=0A=
-MR_AN_ENABLE	tg3.c	1477;"	d	file:=0A=
-MR_LINK_OK	tg3.c	1493;"	d	file:=0A=
-MR_LP_ADV_ASYM_PAUSE	tg3.c	1486;"	d	file:=0A=
-MR_LP_ADV_FULL_DUPLEX	tg3.c	1483;"	d	file:=0A=
-MR_LP_ADV_HALF_DUPLEX	tg3.c	1484;"	d	file:=0A=
-MR_LP_ADV_NEXT_PAGE	tg3.c	1489;"	d	file:=0A=
-MR_LP_ADV_REMOTE_FAULT1	tg3.c	1487;"	d	file:=0A=
-MR_LP_ADV_REMOTE_FAULT2	tg3.c	1488;"	d	file:=0A=
-MR_LP_ADV_SYM_PAUSE	tg3.c	1485;"	d	file:=0A=
-MR_NP_LOADED	tg3.c	1481;"	d	file:=0A=
-MR_NP_RX	tg3.c	1491;"	d	file:=0A=
-MR_PAGE_RX	tg3.c	1480;"	d	file:=0A=
-MR_RESTART_AN	tg3.c	1478;"	d	file:=0A=
-MR_TOGGLE_RX	tg3.c	1490;"	d	file:=0A=
-MR_TOGGLE_TX	tg3.c	1482;"	d	file:=0A=
-MSGINT_FIFO	tg3.h	1182;"	d=0A=
-MSGINT_MODE	tg3.h	1178;"	d=0A=
-MSGINT_MODE_ENABLE	tg3.h	1180;"	d=0A=
-MSGINT_MODE_RESET	tg3.h	1179;"	d=0A=
-MSGINT_STATUS	tg3.h	1181;"	d=0A=
-NEXT_TX	tg3.c	121;"	d	file:=0A=
-NIC_SRAM_DATA_CFG	tg3.h	1353;"	d=0A=
-NIC_SRAM_DATA_CFG_ASF_ENABLE	tg3.h	1365;"	d=0A=
-NIC_SRAM_DATA_CFG_EEPROM_WP	tg3.h	1366;"	d=0A=
-NIC_SRAM_DATA_CFG_FIBER_WOL	tg3.h	1368;"	d=0A=
-NIC_SRAM_DATA_CFG_LED_LINK_SPD	tg3.h	1358;"	d=0A=
-NIC_SRAM_DATA_CFG_LED_MODE_MASK	tg3.h	1354;"	d=0A=
-NIC_SRAM_DATA_CFG_LED_MODE_UNKNOWN	tg3.h	1355;"	d=0A=
-NIC_SRAM_DATA_CFG_LED_OPEN_DRAIN	tg3.h	1357;"	d=0A=
-NIC_SRAM_DATA_CFG_LED_OUTPUT	tg3.h	1359;"	d=0A=
-NIC_SRAM_DATA_CFG_LED_TRIPLE_SPD	tg3.h	1356;"	d=0A=
-NIC_SRAM_DATA_CFG_MINI_PCI	tg3.h	1367;"	d=0A=
-NIC_SRAM_DATA_CFG_PHY_TYPE_COPPER	tg3.h	1362;"	d=0A=
-NIC_SRAM_DATA_CFG_PHY_TYPE_FIBER	tg3.h	1363;"	d=0A=
-NIC_SRAM_DATA_CFG_PHY_TYPE_MASK	tg3.h	1360;"	d=0A=
-NIC_SRAM_DATA_CFG_PHY_TYPE_UNKNOWN	tg3.h	1361;"	d=0A=
-NIC_SRAM_DATA_CFG_WOL_ENABLE	tg3.h	1364;"	d=0A=
-NIC_SRAM_DATA_PHY_ID	tg3.h	1370;"	d=0A=
-NIC_SRAM_DATA_PHY_ID1_MASK	tg3.h	1371;"	d=0A=
-NIC_SRAM_DATA_PHY_ID2_MASK	tg3.h	1372;"	d=0A=
-NIC_SRAM_DATA_SIG	tg3.h	1350;"	d=0A=
-NIC_SRAM_DATA_SIG_MAGIC	tg3.h	1351;"	d=0A=
-NIC_SRAM_DMA_DESC_POOL_BASE	tg3.h	1397;"	d=0A=
-NIC_SRAM_DMA_DESC_POOL_SIZE	tg3.h	1398;"	d=0A=
-NIC_SRAM_FIRMWARE_MBOX	tg3.h	1346;"	d=0A=
-NIC_SRAM_FIRMWARE_MBOX_MAGIC1	tg3.h	1347;"	d=0A=
-NIC_SRAM_FIRMWARE_MBOX_MAGIC2	tg3.h	1348;"	d=0A=
-NIC_SRAM_FW_ASF_STATUS_MBOX	tg3.h	1383;"	d=0A=
-NIC_SRAM_FW_CMD_DATA_MBOX	tg3.h	1382;"	d=0A=
-NIC_SRAM_FW_CMD_LEN_MBOX	tg3.h	1381;"	d=0A=
-NIC_SRAM_FW_CMD_MBOX	tg3.h	1374;"	d=0A=
-NIC_SRAM_FW_DRV_STATE_MBOX	tg3.h	1384;"	d=0A=
-NIC_SRAM_FW_RESET_TYPE_MBOX	tg3.h	1390;"	d=0A=
-NIC_SRAM_MAC_ADDR_HIGH_MBOX	tg3.h	1392;"	d=0A=
-NIC_SRAM_MAC_ADDR_LOW_MBOX	tg3.h	1393;"	d=0A=
-NIC_SRAM_MBUF_POOL_BASE	tg3.h	1402;"	d=0A=
-NIC_SRAM_MBUF_POOL_BASE5705	tg3.h	1405;"	d=0A=
-NIC_SRAM_MBUF_POOL_SIZE5705	tg3.h	1406;"	d=0A=
-NIC_SRAM_MBUF_POOL_SIZE64	tg3.h	1404;"	d=0A=
-NIC_SRAM_MBUF_POOL_SIZE96	tg3.h	1403;"	d=0A=
-NIC_SRAM_PAGE_ZERO	tg3.h	1340;"	d=0A=
-NIC_SRAM_RCV_RET_RCB	tg3.h	1342;"	d=0A=
-NIC_SRAM_RX_BUFFER_DESC	tg3.h	1400;"	d=0A=
-NIC_SRAM_RX_JUMBO_BUFFER_DESC	tg3.h	1401;"	d=0A=
-NIC_SRAM_RX_MINI_BUFFER_DESC	tg3.h	1395;"	d=0A=
-NIC_SRAM_SEND_RCB	tg3.h	1341;"	d=0A=
-NIC_SRAM_STATS_BLK	tg3.h	1343;"	d=0A=
-NIC_SRAM_STATUS_BLK	tg3.h	1344;"	d=0A=
-NIC_SRAM_TX_BUFFER_DESC	tg3.h	1399;"	d=0A=
-NIC_SRAM_WIN_BASE	tg3.h	1337;"	d=0A=
-NVRAM_ADDR	tg3.h	1302;"	d=0A=
-NVRAM_ADDR_MSK	tg3.h	1303;"	d=0A=
-NVRAM_BUFFERED_PAGE_POS	tg3.h	1331;"	d=0A=
-NVRAM_BUFFERED_PAGE_SIZE	tg3.h	1330;"	d=0A=
-NVRAM_CFG1	tg3.h	1305;"	d=0A=
-NVRAM_CFG1_BIT_BANG	tg3.h	1309;"	d=0A=
-NVRAM_CFG1_BUFFERED_MODE	tg3.h	1307;"	d=0A=
-NVRAM_CFG1_COMPAT_BYPASS	tg3.h	1310;"	d=0A=
-NVRAM_CFG1_FLASHIF_ENAB	tg3.h	1306;"	d=0A=
-NVRAM_CFG1_PASS_THRU	tg3.h	1308;"	d=0A=
-NVRAM_CFG2	tg3.h	1311;"	d=0A=
-NVRAM_CFG3	tg3.h	1312;"	d=0A=
-NVRAM_CMD	tg3.h	1291;"	d=0A=
-NVRAM_CMD_DONE	tg3.h	1293;"	d=0A=
-NVRAM_CMD_ERASE	tg3.h	1297;"	d=0A=
-NVRAM_CMD_FIRST	tg3.h	1298;"	d=0A=
-NVRAM_CMD_GO	tg3.h	1294;"	d=0A=
-NVRAM_CMD_LAST	tg3.h	1299;"	d=0A=
-NVRAM_CMD_RD	tg3.h	1296;"	d=0A=
-NVRAM_CMD_RESET	tg3.h	1292;"	d=0A=
-NVRAM_CMD_WR	tg3.h	1295;"	d=0A=
-NVRAM_RDDATA	tg3.h	1304;"	d=0A=
-NVRAM_STAT	tg3.h	1300;"	d=0A=
-NVRAM_SWARB	tg3.h	1313;"	d=0A=
-NVRAM_WRDATA	tg3.h	1301;"	d=0A=
-PCISTATE_BUS_32BIT	tg3.h	175;"	d=0A=
-PCISTATE_BUS_SPEED_HIGH	tg3.h	174;"	d=0A=
-PCISTATE_CONV_PCI_MODE	tg3.h	173;"	d=0A=
-PCISTATE_FLAT_VIEW	tg3.h	178;"	d=0A=
-PCISTATE_FORCE_RESET	tg3.h	171;"	d=0A=
-PCISTATE_INT_NOT_ACTIVE	tg3.h	172;"	d=0A=
-PCISTATE_RETRY_SAME_DMA	tg3.h	179;"	d=0A=
-PCISTATE_ROM_ENABLE	tg3.h	176;"	d=0A=
-PCISTATE_ROM_RETRY_ENABLE	tg3.h	177;"	d=0A=
-PCIX_CAPS_BURST_MASK	tg3.h	61;"	d=0A=
-PCIX_CAPS_BURST_SHIFT	tg3.h	62;"	d=0A=
-PCIX_CAPS_MAX_BURST_CPIOB	tg3.h	63;"	d=0A=
-PCIX_CAPS_RELAXED_ORDERING	tg3.h	58;"	d=0A=
-PCIX_CAPS_SPLIT_MASK	tg3.h	59;"	d=0A=
-PCIX_CAPS_SPLIT_SHIFT	tg3.h	60;"	d=0A=
-PCS_TEST_ENABLE	tg3.h	362;"	d=0A=
-PCS_TEST_PATTERN_MASK	tg3.h	360;"	d=0A=
-PCS_TEST_PATTERN_SHIFT	tg3.h	361;"	d=0A=
-PFX	tg3.c	58;"	d	file:=0A=
-PHY_ADDR	tg3.h	1409;"	d=0A=
-PHY_BUSY_LOOPS	tg3.c	315;"	d	file:=0A=
-PHY_ID_BCM5400	tg3.h	1961;"	d=0A=
-PHY_ID_BCM5401	tg3.h	1962;"	d=0A=
-PHY_ID_BCM5411	tg3.h	1963;"	d=0A=
-PHY_ID_BCM5701	tg3.h	1964;"	d=0A=
-PHY_ID_BCM5703	tg3.h	1965;"	d=0A=
-PHY_ID_BCM5704	tg3.h	1966;"	d=0A=
-PHY_ID_BCM5705	tg3.h	1967;"	d=0A=
-PHY_ID_BCM8002	tg3.h	1968;"	d=0A=
-PHY_ID_INVALID	tg3.h	1970;"	d=0A=
-PHY_ID_MASK	tg3.h	1960;"	d=0A=
-PHY_ID_REV_MASK	tg3.h	1971;"	d=0A=
-PHY_ID_SERDES	tg3.h	1969;"	d=0A=
-PHY_REV_BCM5401_B0	tg3.h	1972;"	d=0A=
-PHY_REV_BCM5401_B2	tg3.h	1973;"	d=0A=
-PHY_REV_BCM5401_C0	tg3.h	1974;"	d=0A=
-PHY_REV_BCM5411_X0	tg3.h	1975;"	d=0A=
-RCVBDI_JUMBO_PROD_IDX	tg3.h	751;"	d=0A=
-RCVBDI_JUMBO_THRESH	tg3.h	756;"	d=0A=
-RCVBDI_MINI_PROD_IDX	tg3.h	753;"	d=0A=
-RCVBDI_MINI_THRESH	tg3.h	754;"	d=0A=
-RCVBDI_MODE	tg3.h	745;"	d=0A=
-RCVBDI_MODE_ENABLE	tg3.h	747;"	d=0A=
-RCVBDI_MODE_RCB_ATTN_ENAB	tg3.h	748;"	d=0A=
-RCVBDI_MODE_RESET	tg3.h	746;"	d=0A=
-RCVBDI_STATUS	tg3.h	749;"	d=0A=
-RCVBDI_STATUS_RCB_ATTN	tg3.h	750;"	d=0A=
-RCVBDI_STD_PROD_IDX	tg3.h	752;"	d=0A=
-RCVBDI_STD_THRESH	tg3.h	755;"	d=0A=
-RCVCC_JUMP_PROD_IDX	tg3.h	766;"	d=0A=
-RCVCC_MINI_PROD_IDX	tg3.h	768;"	d=0A=
-RCVCC_MODE	tg3.h	760;"	d=0A=
-RCVCC_MODE_ATTN_ENABLE	tg3.h	763;"	d=0A=
-RCVCC_MODE_ENABLE	tg3.h	762;"	d=0A=
-RCVCC_MODE_RESET	tg3.h	761;"	d=0A=
-RCVCC_STATUS	tg3.h	764;"	d=0A=
-RCVCC_STATUS_ERROR_ATTN	tg3.h	765;"	d=0A=
-RCVCC_STD_PROD_IDX	tg3.h	767;"	d=0A=
-RCVDBDI_BD_PROD_IDX_0	tg3.h	718;"	d=0A=
-RCVDBDI_BD_PROD_IDX_1	tg3.h	719;"	d=0A=
-RCVDBDI_BD_PROD_IDX_10	tg3.h	728;"	d=0A=
-RCVDBDI_BD_PROD_IDX_11	tg3.h	729;"	d=0A=
-RCVDBDI_BD_PROD_IDX_12	tg3.h	730;"	d=0A=
-RCVDBDI_BD_PROD_IDX_13	tg3.h	731;"	d=0A=
-RCVDBDI_BD_PROD_IDX_14	tg3.h	732;"	d=0A=
-RCVDBDI_BD_PROD_IDX_15	tg3.h	733;"	d=0A=
-RCVDBDI_BD_PROD_IDX_2	tg3.h	720;"	d=0A=
-RCVDBDI_BD_PROD_IDX_3	tg3.h	721;"	d=0A=
-RCVDBDI_BD_PROD_IDX_4	tg3.h	722;"	d=0A=
-RCVDBDI_BD_PROD_IDX_5	tg3.h	723;"	d=0A=
-RCVDBDI_BD_PROD_IDX_6	tg3.h	724;"	d=0A=
-RCVDBDI_BD_PROD_IDX_7	tg3.h	725;"	d=0A=
-RCVDBDI_BD_PROD_IDX_8	tg3.h	726;"	d=0A=
-RCVDBDI_BD_PROD_IDX_9	tg3.h	727;"	d=0A=
-RCVDBDI_HWDIAG	tg3.h	734;"	d=0A=
-RCVDBDI_JUMBO_BD	tg3.h	711;"	d=0A=
-RCVDBDI_JUMBO_CON_IDX	tg3.h	714;"	d=0A=
-RCVDBDI_MINI_BD	tg3.h	713;"	d=0A=
-RCVDBDI_MINI_CON_IDX	tg3.h	716;"	d=0A=
-RCVDBDI_MODE	tg3.h	699;"	d=0A=
-RCVDBDI_MODE_ENABLE	tg3.h	701;"	d=0A=
-RCVDBDI_MODE_FRM_TOO_BIG	tg3.h	703;"	d=0A=
-RCVDBDI_MODE_INV_RING_SZ	tg3.h	704;"	d=0A=
-RCVDBDI_MODE_JUMBOBD_NEEDED	tg3.h	702;"	d=0A=
-RCVDBDI_MODE_RESET	tg3.h	700;"	d=0A=
-RCVDBDI_SPLIT_FRAME_MINSZ	tg3.h	709;"	d=0A=
-RCVDBDI_STATUS	tg3.h	705;"	d=0A=
-RCVDBDI_STATUS_FRM_TOO_BIG	tg3.h	707;"	d=0A=
-RCVDBDI_STATUS_INV_RING_SZ	tg3.h	708;"	d=0A=
-RCVDBDI_STATUS_JUMBOBD_NEEDED	tg3.h	706;"	d=0A=
-RCVDBDI_STD_BD	tg3.h	712;"	d=0A=
-RCVDBDI_STD_CON_IDX	tg3.h	715;"	d=0A=
-RCVDCC_MODE	tg3.h	738;"	d=0A=
-RCVDCC_MODE_ATTN_ENABLE	tg3.h	741;"	d=0A=
-RCVDCC_MODE_ENABLE	tg3.h	740;"	d=0A=
-RCVDCC_MODE_RESET	tg3.h	739;"	d=0A=
-RCVLPC_CONFIG	tg3.h	676;"	d=0A=
-RCVLPC_COS_CNTL_BASE	tg3.h	688;"	d=0A=
-RCVLPC_DMA_HIPRIO_WQ_FULL_CNT	tg3.h	691;"	d=0A=
-RCVLPC_DMA_WQ_FULL_CNT	tg3.h	690;"	d=0A=
-RCVLPC_DROP_FILTER_CNT	tg3.h	689;"	d=0A=
-RCVLPC_IN_DISCARDS_CNT	tg3.h	693;"	d=0A=
-RCVLPC_IN_ERRORS_CNT	tg3.h	694;"	d=0A=
-RCVLPC_LOCK	tg3.h	669;"	d=0A=
-RCVLPC_LOCK_GRANT_MASK	tg3.h	672;"	d=0A=
-RCVLPC_LOCK_GRANT_SHIFT	tg3.h	673;"	d=0A=
-RCVLPC_LOCK_REQ_MASK	tg3.h	670;"	d=0A=
-RCVLPC_LOCK_REQ_SHIFT	tg3.h	671;"	d=0A=
-RCVLPC_MODE	tg3.h	659;"	d=0A=
-RCVLPC_MODE_CLASS0_ATTN_ENAB	tg3.h	662;"	d=0A=
-RCVLPC_MODE_ENABLE	tg3.h	661;"	d=0A=
-RCVLPC_MODE_MAPOOR_AATTN_ENAB	tg3.h	663;"	d=0A=
-RCVLPC_MODE_RESET	tg3.h	660;"	d=0A=
-RCVLPC_MODE_STAT_OFLOW_ENAB	tg3.h	664;"	d=0A=
-RCVLPC_NON_EMPTY_BITS	tg3.h	674;"	d=0A=
-RCVLPC_NON_EMPTY_BITS_MASK	tg3.h	675;"	d=0A=
-RCVLPC_NO_RCV_BD_CNT	tg3.h	692;"	d=0A=
-RCVLPC_RCV_THRESH_HIT_CNT	tg3.h	695;"	d=0A=
-RCVLPC_SELLST_BASE	tg3.h	684;"	d=0A=
-RCVLPC_STATSCTRL	tg3.h	677;"	d=0A=
-RCVLPC_STATSCTRL_ENABLE	tg3.h	678;"	d=0A=
-RCVLPC_STATSCTRL_FASTUPD	tg3.h	679;"	d=0A=
-RCVLPC_STATSENAB_LNGBRST_RFIX	tg3.h	681;"	d=0A=
-RCVLPC_STATS_ENABLE	tg3.h	680;"	d=0A=
-RCVLPC_STATS_INCMASK	tg3.h	682;"	d=0A=
-RCVLPC_STATUS	tg3.h	665;"	d=0A=
-RCVLPC_STATUS_CLASS0	tg3.h	666;"	d=0A=
-RCVLPC_STATUS_MAPOOR	tg3.h	667;"	d=0A=
-RCVLPC_STATUS_STAT_OFLOW	tg3.h	668;"	d=0A=
-RCVLSC_MODE	tg3.h	772;"	d=0A=
-RCVLSC_MODE_ATTN_ENABLE	tg3.h	775;"	d=0A=
-RCVLSC_MODE_ENABLE	tg3.h	774;"	d=0A=
-RCVLSC_MODE_RESET	tg3.h	773;"	d=0A=
-RCVLSC_STATUS	tg3.h	776;"	d=0A=
-RCVLSC_STATUS_ERROR_ATTN	tg3.h	777;"	d=0A=
-RCV_RULE_CFG_DEFAULT_CLASS	tg3.h	465;"	d=0A=
-RCV_RULE_DISABLE_MASK	tg3.h	463;"	d=0A=
-RDMAC_MODE	tg3.h	927;"	d=0A=
-RDMAC_MODE_ADDROFLOW_ENAB	tg3.h	933;"	d=0A=
-RDMAC_MODE_ENABLE	tg3.h	929;"	d=0A=
-RDMAC_MODE_FIFOOFLOW_ENAB	tg3.h	934;"	d=0A=
-RDMAC_MODE_FIFOOREAD_ENAB	tg3.h	936;"	d=0A=
-RDMAC_MODE_FIFOURUN_ENAB	tg3.h	935;"	d=0A=
-RDMAC_MODE_FIFO_LONG_BURST	tg3.h	941;"	d=0A=
-RDMAC_MODE_FIFO_SIZE_128	tg3.h	940;"	d=0A=
-RDMAC_MODE_LNGREAD_ENAB	tg3.h	937;"	d=0A=
-RDMAC_MODE_MSTABORT_ENAB	tg3.h	931;"	d=0A=
-RDMAC_MODE_PARITYERR_ENAB	tg3.h	932;"	d=0A=
-RDMAC_MODE_RESET	tg3.h	928;"	d=0A=
-RDMAC_MODE_SPLIT_ENABLE	tg3.h	938;"	d=0A=
-RDMAC_MODE_SPLIT_RESET	tg3.h	939;"	d=0A=
-RDMAC_MODE_TGTABORT_ENAB	tg3.h	930;"	d=0A=
-RDMAC_STATUS	tg3.h	942;"	d=0A=
-RDMAC_STATUS_ADDROFLOW	tg3.h	946;"	d=0A=
-RDMAC_STATUS_FIFOOFLOW	tg3.h	947;"	d=0A=
-RDMAC_STATUS_FIFOOREAD	tg3.h	949;"	d=0A=
-RDMAC_STATUS_FIFOURUN	tg3.h	948;"	d=0A=
-RDMAC_STATUS_LNGREAD	tg3.h	950;"	d=0A=
-RDMAC_STATUS_MSTABORT	tg3.h	944;"	d=0A=
-RDMAC_STATUS_PARITYERR	tg3.h	945;"	d=0A=
-RDMAC_STATUS_TGTABORT	tg3.h	943;"	d=0A=
-RXD_ERR_BAD_CRC	tg3.h	1565;"	d=0A=
-RXD_ERR_COLLISION	tg3.h	1566;"	d=0A=
-RXD_ERR_HUGE_FRAME	tg3.h	1573;"	d=0A=
-RXD_ERR_LINK_LOST	tg3.h	1567;"	d=0A=
-RXD_ERR_MAC_ABRT	tg3.h	1570;"	d=0A=
-RXD_ERR_MASK	tg3.h	1574;"	d=0A=
-RXD_ERR_NO_RESOURCES	tg3.h	1572;"	d=0A=
-RXD_ERR_ODD_NIBBLE_RCVD_MII	tg3.h	1569;"	d=0A=
-RXD_ERR_PHY_DECODE	tg3.h	1568;"	d=0A=
-RXD_ERR_TOO_SMALL	tg3.h	1571;"	d=0A=
-RXD_FLAGS_SHIFT	tg3.h	1544;"	d=0A=
-RXD_FLAG_END	tg3.h	1546;"	d=0A=
-RXD_FLAG_ERROR	tg3.h	1550;"	d=0A=
-RXD_FLAG_IP_CSUM	tg3.h	1551;"	d=0A=
-RXD_FLAG_IS_TCP	tg3.h	1553;"	d=0A=
-RXD_FLAG_JUMBO	tg3.h	1548;"	d=0A=
-RXD_FLAG_MINI	tg3.h	1547;"	d=0A=
-RXD_FLAG_TCPUDP_CSUM	tg3.h	1552;"	d=0A=
-RXD_FLAG_VLAN	tg3.h	1549;"	d=0A=
-RXD_IDX_MASK	tg3.h	1537;"	d=0A=
-RXD_IDX_SHIFT	tg3.h	1538;"	d=0A=
-RXD_IPCSUM_MASK	tg3.h	1556;"	d=0A=
-RXD_IPCSUM_SHIFT	tg3.h	1557;"	d=0A=
-RXD_LEN_MASK	tg3.h	1539;"	d=0A=
-RXD_LEN_SHIFT	tg3.h	1540;"	d=0A=
-RXD_OPAQUE_INDEX_MASK	tg3.h	1578;"	d=0A=
-RXD_OPAQUE_INDEX_SHIFT	tg3.h	1579;"	d=0A=
-RXD_OPAQUE_RING_JUMBO	tg3.h	1581;"	d=0A=
-RXD_OPAQUE_RING_MASK	tg3.h	1583;"	d=0A=
-RXD_OPAQUE_RING_MINI	tg3.h	1582;"	d=0A=
-RXD_OPAQUE_RING_STD	tg3.h	1580;"	d=0A=
-RXD_TCPCSUM_MASK	tg3.h	1558;"	d=0A=
-RXD_TCPCSUM_SHIFT	tg3.h	1559;"	d=0A=
-RXD_TYPE_SHIFT	tg3.h	1543;"	d=0A=
-RXD_VLAN_MASK	tg3.h	1563;"	d=0A=
-RX_AUTO_NEG_MASK	tg3.h	367;"	d=0A=
-RX_AUTO_NEG_SHIFT	tg3.h	368;"	d=0A=
-RX_COPY_THRESHOLD	tg3.h	24;"	d=0A=
-RX_CPU_BASE	tg3.h	1030;"	d=0A=
-RX_CPU_SCRATCH_BASE	tg3.c	3681;"	d	file:=0A=
-RX_CPU_SCRATCH_SIZE	tg3.c	3682;"	d	file:=0A=
-RX_JUMBO_MAX_SIZE	tg3.h	28;"	d=0A=
-RX_JUMBO_PKT_BUF_SZ	tg3.c	124;"	d	file:=0A=
-RX_MODE_ACCEPT_OVERSIZED	tg3.h	417;"	d=0A=
-RX_MODE_ACCEPT_RUNTS	tg3.h	418;"	d=0A=
-RX_MODE_ENABLE	tg3.h	413;"	d=0A=
-RX_MODE_FLOW_CTRL_ENABLE	tg3.h	414;"	d=0A=
-RX_MODE_KEEP_MAC_CTRL	tg3.h	415;"	d=0A=
-RX_MODE_KEEP_PAUSE	tg3.h	416;"	d=0A=
-RX_MODE_KEEP_VLAN_TAG	tg3.h	422;"	d=0A=
-RX_MODE_LEN_CHECK	tg3.h	419;"	d=0A=
-RX_MODE_NO_CRC_CHECK	tg3.h	421;"	d=0A=
-RX_MODE_PROMISC	tg3.h	420;"	d=0A=
-RX_MODE_RESET	tg3.h	412;"	d=0A=
-RX_MTU_SIZE_MASK	tg3.h	358;"	d=0A=
-RX_PKT_BUF_SZ	tg3.c	123;"	d	file:=0A=
-RX_STATUS_REMOTE_TX_XOFFED	tg3.h	424;"	d=0A=
-RX_STATUS_XOFF_RCVD	tg3.h	425;"	d=0A=
-RX_STATUS_XON_RCVD	tg3.h	426;"	d=0A=
-RX_STD_MAX_SIZE	tg3.h	26;"	d=0A=
-RX_STD_MAX_SIZE_5705	tg3.h	27;"	d=0A=
-SD_STATUS_ERROR	tg3.h	1623;"	d=0A=
-SD_STATUS_LINK_CHG	tg3.h	1622;"	d=0A=
-SD_STATUS_UPDATED	tg3.h	1621;"	d=0A=
-SELLST_CONT	tg3.h	686;"	d=0A=
-SELLST_TAIL	tg3.h	685;"	d=0A=
-SELLST_UNUSED	tg3.h	687;"	d=0A=
-SNDBDC_MODE	tg3.h	652;"	d=0A=
-SNDBDC_MODE_ATTN_ENABLE	tg3.h	655;"	d=0A=
-SNDBDC_MODE_ENABLE	tg3.h	654;"	d=0A=
-SNDBDC_MODE_RESET	tg3.h	653;"	d=0A=
-SNDBDI_IN_PROD_IDX_0	tg3.h	633;"	d=0A=
-SNDBDI_IN_PROD_IDX_1	tg3.h	634;"	d=0A=
-SNDBDI_IN_PROD_IDX_10	tg3.h	643;"	d=0A=
-SNDBDI_IN_PROD_IDX_11	tg3.h	644;"	d=0A=
-SNDBDI_IN_PROD_IDX_12	tg3.h	645;"	d=0A=
-SNDBDI_IN_PROD_IDX_13	tg3.h	646;"	d=0A=
-SNDBDI_IN_PROD_IDX_14	tg3.h	647;"	d=0A=
-SNDBDI_IN_PROD_IDX_15	tg3.h	648;"	d=0A=
-SNDBDI_IN_PROD_IDX_2	tg3.h	635;"	d=0A=
-SNDBDI_IN_PROD_IDX_3	tg3.h	636;"	d=0A=
-SNDBDI_IN_PROD_IDX_4	tg3.h	637;"	d=0A=
-SNDBDI_IN_PROD_IDX_5	tg3.h	638;"	d=0A=
-SNDBDI_IN_PROD_IDX_6	tg3.h	639;"	d=0A=
-SNDBDI_IN_PROD_IDX_7	tg3.h	640;"	d=0A=
-SNDBDI_IN_PROD_IDX_8	tg3.h	641;"	d=0A=
-SNDBDI_IN_PROD_IDX_9	tg3.h	642;"	d=0A=
-SNDBDI_MODE	tg3.h	627;"	d=0A=
-SNDBDI_MODE_ATTN_ENABLE	tg3.h	630;"	d=0A=
-SNDBDI_MODE_ENABLE	tg3.h	629;"	d=0A=
-SNDBDI_MODE_RESET	tg3.h	628;"	d=0A=
-SNDBDI_STATUS	tg3.h	631;"	d=0A=
-SNDBDI_STATUS_ERROR_ATTN	tg3.h	632;"	d=0A=
-SNDBDS_HWDIAG	tg3.h	606;"	d=0A=
-SNDBDS_MODE	tg3.h	600;"	d=0A=
-SNDBDS_MODE_ATTN_ENABLE	tg3.h	603;"	d=0A=
-SNDBDS_MODE_ENABLE	tg3.h	602;"	d=0A=
-SNDBDS_MODE_RESET	tg3.h	601;"	d=0A=
-SNDBDS_SEL_CON_IDX_0	tg3.h	608;"	d=0A=
-SNDBDS_SEL_CON_IDX_1	tg3.h	609;"	d=0A=
-SNDBDS_SEL_CON_IDX_10	tg3.h	618;"	d=0A=
-SNDBDS_SEL_CON_IDX_11	tg3.h	619;"	d=0A=
-SNDBDS_SEL_CON_IDX_12	tg3.h	620;"	d=0A=
-SNDBDS_SEL_CON_IDX_13	tg3.h	621;"	d=0A=
-SNDBDS_SEL_CON_IDX_14	tg3.h	622;"	d=0A=
-SNDBDS_SEL_CON_IDX_15	tg3.h	623;"	d=0A=
-SNDBDS_SEL_CON_IDX_2	tg3.h	610;"	d=0A=
-SNDBDS_SEL_CON_IDX_3	tg3.h	611;"	d=0A=
-SNDBDS_SEL_CON_IDX_4	tg3.h	612;"	d=0A=
-SNDBDS_SEL_CON_IDX_5	tg3.h	613;"	d=0A=
-SNDBDS_SEL_CON_IDX_6	tg3.h	614;"	d=0A=
-SNDBDS_SEL_CON_IDX_7	tg3.h	615;"	d=0A=
-SNDBDS_SEL_CON_IDX_8	tg3.h	616;"	d=0A=
-SNDBDS_SEL_CON_IDX_9	tg3.h	617;"	d=0A=
-SNDBDS_STATUS	tg3.h	604;"	d=0A=
-SNDBDS_STATUS_ERROR_ATTN	tg3.h	605;"	d=0A=
-SNDDATAC_MODE	tg3.h	594;"	d=0A=
-SNDDATAC_MODE_ENABLE	tg3.h	596;"	d=0A=
-SNDDATAC_MODE_RESET	tg3.h	595;"	d=0A=
-SNDDATAI_AVOID_INTERRUPTS_CNT	tg3.h	589;"	d=0A=
-SNDDATAI_COS_CNT_0	tg3.h	567;"	d=0A=
-SNDDATAI_COS_CNT_1	tg3.h	568;"	d=0A=
-SNDDATAI_COS_CNT_10	tg3.h	577;"	d=0A=
-SNDDATAI_COS_CNT_11	tg3.h	578;"	d=0A=
-SNDDATAI_COS_CNT_12	tg3.h	579;"	d=0A=
-SNDDATAI_COS_CNT_13	tg3.h	580;"	d=0A=
-SNDDATAI_COS_CNT_14	tg3.h	581;"	d=0A=
-SNDDATAI_COS_CNT_15	tg3.h	582;"	d=0A=
-SNDDATAI_COS_CNT_2	tg3.h	569;"	d=0A=
-SNDDATAI_COS_CNT_3	tg3.h	570;"	d=0A=
-SNDDATAI_COS_CNT_4	tg3.h	571;"	d=0A=
-SNDDATAI_COS_CNT_5	tg3.h	572;"	d=0A=
-SNDDATAI_COS_CNT_6	tg3.h	573;"	d=0A=
-SNDDATAI_COS_CNT_7	tg3.h	574;"	d=0A=
-SNDDATAI_COS_CNT_8	tg3.h	575;"	d=0A=
-SNDDATAI_COS_CNT_9	tg3.h	576;"	d=0A=
-SNDDATAI_DMA_PRIO_RDQ_FULL_CNT	tg3.h	584;"	d=0A=
-SNDDATAI_DMA_RDQ_FULL_CNT	tg3.h	583;"	d=0A=
-SNDDATAI_INTERRUPTS_CNT	tg3.h	588;"	d=0A=
-SNDDATAI_MODE	tg3.h	552;"	d=0A=
-SNDDATAI_MODE_ENABLE	tg3.h	554;"	d=0A=
-SNDDATAI_MODE_RESET	tg3.h	553;"	d=0A=
-SNDDATAI_MODE_STAT_OFLOW_ENAB	tg3.h	555;"	d=0A=
-SNDDATAI_NICRNG_SSND_PIDX_CNT	tg3.h	586;"	d=0A=
-SNDDATAI_SCTRL_CLEAR	tg3.h	561;"	d=0A=
-SNDDATAI_SCTRL_ENABLE	tg3.h	559;"	d=0A=
-SNDDATAI_SCTRL_FASTUPD	tg3.h	560;"	d=0A=
-SNDDATAI_SCTRL_FLUSH	tg3.h	562;"	d=0A=
-SNDDATAI_SCTRL_FORCE_ZERO	tg3.h	563;"	d=0A=
-SNDDATAI_SDCQ_FULL_CNT	tg3.h	585;"	d=0A=
-SNDDATAI_SND_THRESH_HIT_CNT	tg3.h	590;"	d=0A=
-SNDDATAI_STATSCTRL	tg3.h	558;"	d=0A=
-SNDDATAI_STATSENAB	tg3.h	564;"	d=0A=
-SNDDATAI_STATSINCMASK	tg3.h	565;"	d=0A=
-SNDDATAI_STATS_UPDATED_CNT	tg3.h	587;"	d=0A=
-SNDDATAI_STATUS	tg3.h	556;"	d=0A=
-SNDDATAI_STATUS_STAT_OFLOW	tg3.h	557;"	d=0A=
-SPEED_INVALID	tg3.h	1791;"	d=0A=
-SPLIT_MODE_5704_MAX_REQ	tg3.h	1925;"	d=0A=
-SWARB_GNT0	tg3.h	1322;"	d=0A=
-SWARB_GNT1	tg3.h	1323;"	d=0A=
-SWARB_GNT2	tg3.h	1324;"	d=0A=
-SWARB_GNT3	tg3.h	1325;"	d=0A=
-SWARB_REQ0	tg3.h	1326;"	d=0A=
-SWARB_REQ1	tg3.h	1327;"	d=0A=
-SWARB_REQ2	tg3.h	1328;"	d=0A=
-SWARB_REQ3	tg3.h	1329;"	d=0A=
-SWARB_REQ_CLR0	tg3.h	1318;"	d=0A=
-SWARB_REQ_CLR1	tg3.h	1319;"	d=0A=
-SWARB_REQ_CLR2	tg3.h	1320;"	d=0A=
-SWARB_REQ_CLR3	tg3.h	1321;"	d=0A=
-SWARB_REQ_SET0	tg3.h	1314;"	d=0A=
-SWARB_REQ_SET1	tg3.h	1315;"	d=0A=
-SWARB_REQ_SET2	tg3.h	1316;"	d=0A=
-SWARB_REQ_SET3	tg3.h	1317;"	d=0A=
-TEST_BUFFER_SIZE	tg3.c	7219;"	d	file:=0A=
-TG3PCI_BASE0_HIGH	tg3.h	46;"	d=0A=
-TG3PCI_BASE0_LOW	tg3.h	45;"	d=0A=
-TG3PCI_BIST	tg3.h	44;"	d=0A=
-TG3PCI_BR_SUPP_EXT	tg3.h	71;"	d=0A=
-TG3PCI_CACHELINESZ	tg3.h	41;"	d=0A=
-TG3PCI_CAPLIST	tg3.h	51;"	d=0A=
-TG3PCI_CCREVID	tg3.h	40;"	d=0A=
-TG3PCI_CLOCK_CTRL	tg3.h	180;"	d=0A=
-TG3PCI_COMMAND	tg3.h	38;"	d=0A=
-TG3PCI_DEVICE	tg3.h	33;"	d=0A=
-TG3PCI_DEVICE_TIGON3_1	tg3.h	34;"	d=0A=
-TG3PCI_DEVICE_TIGON3_2	tg3.h	35;"	d=0A=
-TG3PCI_DEVICE_TIGON3_3	tg3.h	36;"	d=0A=
-TG3PCI_DEVICE_TIGON3_4	tg3.h	37;"	d=0A=
-TG3PCI_DMA_RW_CTRL	tg3.h	138;"	d=0A=
-TG3PCI_HEADERTYPE	tg3.h	43;"	d=0A=
-TG3PCI_IRQ_LINE	tg3.h	53;"	d=0A=
-TG3PCI_IRQ_PIN	tg3.h	54;"	d=0A=
-TG3PCI_LATTIMER	tg3.h	42;"	d=0A=
-TG3PCI_MAX_LAT	tg3.h	56;"	d=0A=
-TG3PCI_MEM_WIN_BASE_ADDR	tg3.h	192;"	d=0A=
-TG3PCI_MEM_WIN_DATA	tg3.h	194;"	d=0A=
-TG3PCI_MIN_GNT	tg3.h	55;"	d=0A=
-TG3PCI_MISC_CFG	tg3.h	196;"	d=0A=
-TG3PCI_MISC_HOST_CTRL	tg3.h	85;"	d=0A=
-TG3PCI_MISC_LOCAL_CTRL	tg3.h	197;"	d=0A=
-TG3PCI_MODE_CTRL	tg3.h	195;"	d=0A=
-TG3PCI_MSI_ADDR_HIGH	tg3.h	82;"	d=0A=
-TG3PCI_MSI_ADDR_LOW	tg3.h	81;"	d=0A=
-TG3PCI_MSI_CAP_ID	tg3.h	78;"	d=0A=
-TG3PCI_MSI_CAP_PTR	tg3.h	74;"	d=0A=
-TG3PCI_MSI_CTRL	tg3.h	80;"	d=0A=
-TG3PCI_MSI_DATA	tg3.h	83;"	d=0A=
-TG3PCI_NXT_CAP_PTR	tg3.h	79;"	d=0A=
-TG3PCI_PCISTATE	tg3.h	170;"	d=0A=
-TG3PCI_PM_CAPS	tg3.h	69;"	d=0A=
-TG3PCI_PM_CAP_ID	tg3.h	67;"	d=0A=
-TG3PCI_PM_CAP_PTR	tg3.h	64;"	d=0A=
-TG3PCI_PM_CTRL_STAT	tg3.h	70;"	d=0A=
-TG3PCI_PM_DATA	tg3.h	72;"	d=0A=
-TG3PCI_RCV_RET_RING_CON_IDX	tg3.h	200;"	d=0A=
-TG3PCI_REG_BASE_ADDR	tg3.h	191;"	d=0A=
-TG3PCI_REG_DATA	tg3.h	193;"	d=0A=
-TG3PCI_ROMADDR	tg3.h	50;"	d=0A=
-TG3PCI_SND_PROD_IDX	tg3.h	201;"	d=0A=
-TG3PCI_STATUS	tg3.h	39;"	d=0A=
-TG3PCI_STD_RING_PROD_IDX	tg3.h	199;"	d=0A=
-TG3PCI_SUBSYSID	tg3.h	49;"	d=0A=
-TG3PCI_SUBSYSVENID	tg3.h	48;"	d=0A=
-TG3PCI_VENDOR	tg3.h	31;"	d=0A=
-TG3PCI_VENDOR_BROADCOM	tg3.h	32;"	d=0A=
-TG3PCI_VPD_ADDR_FLAG	tg3.h	75;"	d=0A=
-TG3PCI_VPD_CAP_ID	tg3.h	73;"	d=0A=
-TG3PCI_VPD_CAP_PTR	tg3.h	68;"	d=0A=
-TG3PCI_VPD_DATA	tg3.h	77;"	d=0A=
-TG3PCI_X_CAPS	tg3.h	57;"	d=0A=
-TG3PCI_X_COMMAND	tg3.h	65;"	d=0A=
-TG3PCI_X_STATUS	tg3.h	66;"	d=0A=
-TG3_64BIT_REG_HIGH	tg3.h	11;"	d=0A=
-TG3_64BIT_REG_LOW	tg3.h	12;"	d=0A=
-TG3_BDINFO_HOST_ADDR	tg3.h	15;"	d=0A=
-TG3_BDINFO_MAXLEN_FLAGS	tg3.h	16;"	d=0A=
-TG3_BDINFO_NIC_ADDR	tg3.h	21;"	d=0A=
-TG3_BDINFO_SIZE	tg3.h	22;"	d=0A=
-TG3_BMCR_SPEED1000	tg3.h	1412;"	d=0A=
-TG3_DEF_MAC_MODE	tg3.c	62;"	d	file:=0A=
-TG3_DEF_MSG_ENABLE	tg3.c	65;"	d	file:=0A=
-TG3_DEF_RX_JUMBO_RING_PENDING	tg3.c	92;"	d	file:=0A=
-TG3_DEF_RX_MODE	tg3.c	63;"	d	file:=0A=
-TG3_DEF_RX_RING_PENDING	tg3.c	90;"	d	file:=0A=
-TG3_DEF_TX_MODE	tg3.c	64;"	d	file:=0A=
-TG3_DEF_TX_RING_PENDING	tg3.c	105;"	d	file:=0A=
-TG3_FLAG_10_100_ONLY	tg3.h	1908;"	d=0A=
-TG3_FLAG_5701_REG_WRITE_BUG	tg3.h	1890;"	d=0A=
-TG3_FLAG_BROKEN_CHECKSUMS	tg3.h	1912;"	d=0A=
-TG3_FLAG_EEPROM_WRITE_PROT	tg3.h	1896;"	d=0A=
-TG3_FLAG_ENABLE_ASF	tg3.h	1889;"	d=0A=
-TG3_FLAG_GOT_SERDES_FLOWCTL	tg3.h	1913;"	d=0A=
-TG3_FLAG_HOST_TXDS	tg3.h	1884;"	d=0A=
-TG3_FLAG_INIT_COMPLETE	tg3.h	1915;"	d=0A=
-TG3_FLAG_JUMBO_ENABLE	tg3.h	1907;"	d=0A=
-TG3_FLAG_MBOX_WRITE_REORDER	tg3.h	1892;"	d=0A=
-TG3_FLAG_NO_RX_PSEUDO_CSUM	tg3.h	1905;"	d=0A=
-TG3_FLAG_NO_TX_PSEUDO_CSUM	tg3.h	1904;"	d=0A=
-TG3_FLAG_NVRAM	tg3.h	1897;"	d=0A=
-TG3_FLAG_NVRAM_BUFFERED	tg3.h	1898;"	d=0A=
-TG3_FLAG_PAUSE_AUTONEG	tg3.h	1909;"	d=0A=
-TG3_FLAG_PAUSE_RX	tg3.h	1910;"	d=0A=
-TG3_FLAG_PAUSE_TX	tg3.h	1911;"	d=0A=
-TG3_FLAG_PCIX_MODE	tg3.h	1901;"	d=0A=
-TG3_FLAG_PCIX_TARGET_HWBUG	tg3.h	1893;"	d=0A=
-TG3_FLAG_PCI_32BIT	tg3.h	1903;"	d=0A=
-TG3_FLAG_PCI_HIGH_SPEED	tg3.h	1902;"	d=0A=
-TG3_FLAG_POLL_SERDES	tg3.h	1891;"	d=0A=
-TG3_FLAG_RX_CHECKSUMS	tg3.h	1886;"	d=0A=
-TG3_FLAG_RX_PAUSE	tg3.h	1899;"	d=0A=
-TG3_FLAG_SERDES_WOL_CAP	tg3.h	1906;"	d=0A=
-TG3_FLAG_SPLIT_MODE	tg3.h	1914;"	d=0A=
-TG3_FLAG_TXD_MBOX_HWBUG	tg3.h	1885;"	d=0A=
-TG3_FLAG_TX_PAUSE	tg3.h	1900;"	d=0A=
-TG3_FLAG_USE_LINKCHG_REG	tg3.h	1887;"	d=0A=
-TG3_FLAG_USE_MI_INTERRUPT	tg3.h	1888;"	d=0A=
-TG3_FLAG_WOL_ENABLE	tg3.h	1895;"	d=0A=
-TG3_FLAG_WOL_SPEED_100MB	tg3.h	1894;"	d=0A=
-TG3_FLG2_IS_5788	tg3.h	1920;"	d=0A=
-TG3_FLG2_MAX_RXPEND_64	tg3.h	1921;"	d=0A=
-TG3_FLG2_NO_ETH_WIRE_SPEED	tg3.h	1919;"	d=0A=
-TG3_FLG2_RESTART_TIMER	tg3.h	1917;"	d=0A=
-TG3_FLG2_SUN_5704	tg3.h	1918;"	d=0A=
-TG3_FLG2_TSO_CAPABLE	tg3.h	1922;"	d=0A=
-TG3_FW_BSS_ADDR	tg3.c	3569;"	d	file:=0A=
-TG3_FW_BSS_LEN	tg3.c	3570;"	d	file:=0A=
-TG3_FW_DATA_ADDR	tg3.c	3565;"	d	file:=0A=
-TG3_FW_DATA_LEN	tg3.c	3566;"	d	file:=0A=
-TG3_FW_RELASE_MINOR	tg3.c	3558;"	d	file:=0A=
-TG3_FW_RELEASE_FIX	tg3.c	3559;"	d	file:=0A=
-TG3_FW_RELEASE_MAJOR	tg3.c	3557;"	d	file:=0A=
-TG3_FW_RODATA_ADDR	tg3.c	3563;"	d	file:=0A=
-TG3_FW_RODATA_LEN	tg3.c	3564;"	d	file:=0A=
-TG3_FW_SBSS_ADDR	tg3.c	3567;"	d	file:=0A=
-TG3_FW_SBSS_LEN	tg3.c	3568;"	d	file:=0A=
-TG3_FW_START_ADDR	tg3.c	3560;"	d	file:=0A=
-TG3_FW_TEXT_ADDR	tg3.c	3561;"	d	file:=0A=
-TG3_FW_TEXT_LEN	tg3.c	3562;"	d	file:=0A=
-TG3_HW_STATUS_SIZE	tg3.h	1618;"	d=0A=
-TG3_MAX_MTU	tg3.c	82;"	d	file:=0A=
-TG3_MIN_MTU	tg3.c	81;"	d	file:=0A=
-TG3_REGDUMP_LEN	tg3.c	5824;"	d	file:=0A=
-TG3_RX_JUMBO_RING_BYTES	tg3.c	109;"	d	file:=0A=
-TG3_RX_JUMBO_RING_SIZE	tg3.c	91;"	d	file:=0A=
-TG3_RX_RCB_RING_BYTES	tg3.c	111;"	d	file:=0A=
-TG3_RX_RCB_RING_SIZE	tg3.c	100;"	d	file:=0A=
-TG3_RX_RING_BYTES	tg3.c	107;"	d	file:=0A=
-TG3_RX_RING_SIZE	tg3.c	89;"	d	file:=0A=
-TG3_STAT_ADD32	tg3.c	5149;"	d	file:=0A=
-TG3_TSO5_FW_BSS_ADDR	tg3.c	4194;"	d	file:=0A=
-TG3_TSO5_FW_BSS_LEN	tg3.c	4195;"	d	file:=0A=
-TG3_TSO5_FW_DATA_ADDR	tg3.c	4190;"	d	file:=0A=
-TG3_TSO5_FW_DATA_LEN	tg3.c	4191;"	d	file:=0A=
-TG3_TSO5_FW_RELASE_MINOR	tg3.c	4183;"	d	file:=0A=
-TG3_TSO5_FW_RELEASE_FIX	tg3.c	4184;"	d	file:=0A=
-TG3_TSO5_FW_RELEASE_MAJOR	tg3.c	4182;"	d	file:=0A=
-TG3_TSO5_FW_RODATA_ADDR	tg3.c	4188;"	d	file:=0A=
-TG3_TSO5_FW_RODATA_LEN	tg3.c	4189;"	d	file:=0A=
-TG3_TSO5_FW_SBSS_ADDR	tg3.c	4192;"	d	file:=0A=
-TG3_TSO5_FW_SBSS_LEN	tg3.c	4193;"	d	file:=0A=
-TG3_TSO5_FW_START_ADDR	tg3.c	4185;"	d	file:=0A=
-TG3_TSO5_FW_TEXT_ADDR	tg3.c	4186;"	d	file:=0A=
-TG3_TSO5_FW_TEXT_LEN	tg3.c	4187;"	d	file:=0A=
-TG3_TSO_FW_BSS_ADDR	tg3.c	3874;"	d	file:=0A=
-TG3_TSO_FW_BSS_LEN	tg3.c	3875;"	d	file:=0A=
-TG3_TSO_FW_DATA_ADDR	tg3.c	3870;"	d	file:=0A=
-TG3_TSO_FW_DATA_LEN	tg3.c	3871;"	d	file:=0A=
-TG3_TSO_FW_RELASE_MINOR	tg3.c	3863;"	d	file:=0A=
-TG3_TSO_FW_RELEASE_FIX	tg3.c	3864;"	d	file:=0A=
-TG3_TSO_FW_RELEASE_MAJOR	tg3.c	3862;"	d	file:=0A=
-TG3_TSO_FW_RODATA_ADDR	tg3.c	3868;"	d	file:=0A=
-TG3_TSO_FW_RODATA_LEN	tg3.c	3869;"	d	file:=0A=
-TG3_TSO_FW_SBSS_ADDR	tg3.c	3872;"	d	file:=0A=
-TG3_TSO_FW_SBSS_LEN	tg3.c	3873;"	d	file:=0A=
-TG3_TSO_FW_START_ADDR	tg3.c	3865;"	d	file:=0A=
-TG3_TSO_FW_TEXT_ADDR	tg3.c	3866;"	d	file:=0A=
-TG3_TSO_FW_TEXT_LEN	tg3.c	3867;"	d	file:=0A=
-TG3_TSO_SUPPORT	tg3.c	50;"	d	file:=0A=
-TG3_TSO_SUPPORT	tg3.c	52;"	d	file:=0A=
-TG3_TX_RING_BYTES	tg3.c	113;"	d	file:=0A=
-TG3_TX_RING_SIZE	tg3.c	104;"	d	file:=0A=
-TG3_TX_TIMEOUT	tg3.c	78;"	d	file:=0A=
-TG3_TX_WAKEUP_THRESH	tg3.c	127;"	d	file:=0A=
-TG3_VLAN_TAG_USED	tg3.c	44;"	d	file:=0A=
-TG3_VLAN_TAG_USED	tg3.c	46;"	d	file:=0A=
-TXD_ADDR	tg3.h	1527;"	d=0A=
-TXD_FLAG_ADD_SRC_ADDR	tg3.h	1517;"	d=0A=
-TXD_FLAG_CHOOSE_SRC_ADDR	tg3.h	1518;"	d=0A=
-TXD_FLAG_COAL_NOW	tg3.h	1514;"	d=0A=
-TXD_FLAG_CPU_POST_DMA	tg3.h	1516;"	d=0A=
-TXD_FLAG_CPU_PRE_DMA	tg3.h	1515;"	d=0A=
-TXD_FLAG_END	tg3.h	1510;"	d=0A=
-TXD_FLAG_IP_CSUM	tg3.h	1509;"	d=0A=
-TXD_FLAG_IP_FRAG	tg3.h	1511;"	d=0A=
-TXD_FLAG_IP_FRAG_END	tg3.h	1512;"	d=0A=
-TXD_FLAG_NO_CRC	tg3.h	1519;"	d=0A=
-TXD_FLAG_TCPUDP_CSUM	tg3.h	1508;"	d=0A=
-TXD_FLAG_VLAN	tg3.h	1513;"	d=0A=
-TXD_LEN_FLAGS	tg3.h	1528;"	d=0A=
-TXD_LEN_SHIFT	tg3.h	1520;"	d=0A=
-TXD_MSS_SHIFT	tg3.h	1524;"	d=0A=
-TXD_SIZE	tg3.h	1530;"	d=0A=
-TXD_VLAN_TAG	tg3.h	1529;"	d=0A=
-TXD_VLAN_TAG_SHIFT	tg3.h	1523;"	d=0A=
-TX_AUTO_NEG_MASK	tg3.h	364;"	d=0A=
-TX_AUTO_NEG_SHIFT	tg3.h	365;"	d=0A=
-TX_BACKOFF_SEED_MASK	tg3.h	356;"	d=0A=
-TX_BUFFS_AVAIL	tg3.c	117;"	d	file:=0A=
-TX_CPU_BASE	tg3.h	1031;"	d=0A=
-TX_CPU_SCRATCH_BASE	tg3.c	3683;"	d	file:=0A=
-TX_CPU_SCRATCH_SIZE	tg3.c	3684;"	d	file:=0A=
-TX_LENGTHS_IPG_CRS_MASK	tg3.h	409;"	d=0A=
-TX_LENGTHS_IPG_CRS_SHIFT	tg3.h	410;"	d=0A=
-TX_LENGTHS_IPG_MASK	tg3.h	407;"	d=0A=
-TX_LENGTHS_IPG_SHIFT	tg3.h	408;"	d=0A=
-TX_LENGTHS_SLOT_TIME_MASK	tg3.h	405;"	d=0A=
-TX_LENGTHS_SLOT_TIME_SHIFT	tg3.h	406;"	d=0A=
-TX_MODE_BIG_BCKOFF_ENABLE	tg3.h	395;"	d=0A=
-TX_MODE_ENABLE	tg3.h	393;"	d=0A=
-TX_MODE_FLOW_CTRL_ENABLE	tg3.h	394;"	d=0A=
-TX_MODE_LONG_PAUSE_ENABLE	tg3.h	396;"	d=0A=
-TX_MODE_RESET	tg3.h	392;"	d=0A=
-TX_RING_GAP	tg3.c	115;"	d	file:=0A=
-TX_STATUS_LINK_UP	tg3.h	401;"	d=0A=
-TX_STATUS_ODI_OVERRUN	tg3.h	403;"	d=0A=
-TX_STATUS_ODI_UNDERRUN	tg3.h	402;"	d=0A=
-TX_STATUS_SENT_XOFF	tg3.h	399;"	d=0A=
-TX_STATUS_SENT_XON	tg3.h	400;"	d=0A=
-TX_STATUS_XOFFED	tg3.h	398;"	d=0A=
-VPD_ADDR_FLAG_WRITE	tg3.h	76;"	d=0A=
-WDMAC_MODE	tg3.h	954;"	d=0A=
-WDMAC_MODE_ADDROFLOW_ENAB	tg3.h	960;"	d=0A=
-WDMAC_MODE_ENABLE	tg3.h	956;"	d=0A=
-WDMAC_MODE_FIFOOFLOW_ENAB	tg3.h	961;"	d=0A=
-WDMAC_MODE_FIFOOREAD_ENAB	tg3.h	963;"	d=0A=
-WDMAC_MODE_FIFOURUN_ENAB	tg3.h	962;"	d=0A=
-WDMAC_MODE_LNGREAD_ENAB	tg3.h	964;"	d=0A=
-WDMAC_MODE_MSTABORT_ENAB	tg3.h	958;"	d=0A=
-WDMAC_MODE_PARITYERR_ENAB	tg3.h	959;"	d=0A=
-WDMAC_MODE_RESET	tg3.h	955;"	d=0A=
-WDMAC_MODE_RX_ACCEL	tg3.h	965;"	d=0A=
-WDMAC_MODE_TGTABORT_ENAB	tg3.h	957;"	d=0A=
-WDMAC_STATUS	tg3.h	966;"	d=0A=
-WDMAC_STATUS_ADDROFLOW	tg3.h	970;"	d=0A=
-WDMAC_STATUS_FIFOOFLOW	tg3.h	971;"	d=0A=
-WDMAC_STATUS_FIFOOREAD	tg3.h	973;"	d=0A=
-WDMAC_STATUS_FIFOURUN	tg3.h	972;"	d=0A=
-WDMAC_STATUS_LNGREAD	tg3.h	974;"	d=0A=
-WDMAC_STATUS_MSTABORT	tg3.h	968;"	d=0A=
-WDMAC_STATUS_PARITYERR	tg3.h	969;"	d=0A=
-WDMAC_STATUS_TGTABORT	tg3.h	967;"	d=0A=
-_T3_H	tg3.h	9;"	d=0A=
-__GET_REG32	tg3.c	5844;"	d	file:=0A=
-__GET_REG32	tg3.c	5887;"	d	file:=0A=
-__cookie1	tg3.h	/^	u32				__cookie1;$/;"	m	=
struct:tg3_internal_buffer_desc=0A=
-__cookie2	tg3.h	/^	u32				__cookie2;$/;"	m	=
struct:tg3_internal_buffer_desc=0A=
-__cookie3	tg3.h	/^	u32				__cookie3;$/;"	m	=
struct:tg3_internal_buffer_desc=0A=
-__devinitdata	tg3.c	/^static char version[] __devinitdata =3D$/;"	v	=
file:=0A=
-__reserved0	tg3.h	/^	u8				__reserved0[0x400-0x300];$/;"	m	=
struct:tg3_hw_stats=0A=
-__reserved1	tg3.h	/^	u64				__reserved1;$/;"	m	struct:tg3_hw_stats=0A=
-__reserved2	tg3.h	/^	u64				__reserved2;$/;"	m	struct:tg3_hw_stats=0A=
-__reserved3	tg3.h	/^	u64				__reserved3;$/;"	m	struct:tg3_hw_stats=0A=
-__reserved4	tg3.h	/^	u8				__reserved4[0xb00-0x9c0];$/;"	m	=
struct:tg3_hw_stats=0A=
-__tg3_set_mac_addr	tg3.c	/^static void __tg3_set_mac_addr(struct tg3 =
*tp)$/;"	f	file:=0A=
-__tg3_set_rx_mode	tg3.c	/^static void __tg3_set_rx_mode(struct =
net_device *dev)$/;"	f	file:=0A=
-__unused0	tg3.h	/^	u64				__unused0[37];$/;"	m	struct:tg3_hw_stats=0A=
-__unused1	tg3.h	/^	u64				__unused1[31];$/;"	m	struct:tg3_hw_stats=0A=
-__unused2	tg3.h	/^	u64				__unused2[9];$/;"	m	struct:tg3_hw_stats=0A=
-ability_match	tg3.c	/^	char ability_match, idle_match, ack_match;$/;"	m	=
struct:tg3_fiber_aneginfo	file:=0A=
-ability_match_cfg	tg3.c	/^	u32 ability_match_cfg;$/;"	m	=
struct:tg3_fiber_aneginfo	file:=0A=
-ability_match_count	tg3.c	/^	int ability_match_count;$/;"	m	=
struct:tg3_fiber_aneginfo	file:=0A=
-ack_match	tg3.c	/^	char ability_match, idle_match, ack_match;$/;"	m	=
struct:tg3_fiber_aneginfo	file:=0A=
-active_duplex	tg3.h	/^	u8				active_duplex;$/;"	m	struct:tg3_link_config=0A=
-active_speed	tg3.h	/^	u16				active_speed;$/;"	m	struct:tg3_link_config=0A=
-addr_hi	tg3.h	/^		u32			addr_hi;$/;"	m	=
struct:tg3_ext_rx_buffer_desc::<anonymous>=0A=
-addr_hi	tg3.h	/^	u32				addr_hi;$/;"	m	struct:tg3_internal_buffer_desc=0A=
-addr_hi	tg3.h	/^	u32				addr_hi;$/;"	m	struct:tg3_rx_buffer_desc=0A=
-addr_hi	tg3.h	/^	u32				addr_hi;$/;"	m	struct:tg3_tx_buffer_desc=0A=
-addr_lo	tg3.h	/^		u32			addr_lo;$/;"	m	=
struct:tg3_ext_rx_buffer_desc::<anonymous>=0A=
-addr_lo	tg3.h	/^	u32				addr_lo;$/;"	m	struct:tg3_internal_buffer_desc=0A=
-addr_lo	tg3.h	/^	u32				addr_lo;$/;"	m	struct:tg3_rx_buffer_desc=0A=
-addr_lo	tg3.h	/^	u32				addr_lo;$/;"	m	struct:tg3_tx_buffer_desc=0A=
-addrlist	tg3.h	/^	}				addrlist[3];$/;"	m	struct:tg3_ext_rx_buffer_desc=0A=
-advertising	tg3.h	/^	u32				advertising;$/;"	m	struct:tg3_link_config=0A=
-asf_counter	tg3.h	/^	u16				asf_counter;$/;"	m	struct:tg3=0A=
-asf_multiplier	tg3.h	/^	u16				asf_multiplier;$/;"	m	struct:tg3=0A=
-autoneg	tg3.h	/^	u8				autoneg;$/;"	m	struct:tg3_link_config=0A=
-board_part_number	tg3.h	/^	char				board_part_number[24];$/;"	m	=
struct:tg3=0A=
-bufmgr_config	tg3.h	/^	struct tg3_bufmgr_config	bufmgr_config;$/;"	m	=
struct:tg3=0A=
-calc_crc	tg3.c	/^static inline u32 calc_crc(unsigned char *buf, int =
len)$/;"	f	file:=0A=
-calc_crc_errors	tg3.c	/^static unsigned long calc_crc_errors(struct tg3 =
*tp)$/;"	f	file:=0A=
-coalesce_mode	tg3.h	/^	u32				coalesce_mode;$/;"	m	struct:tg3=0A=
-cqid_sqid	tg3.h	/^	u16				cqid_sqid;$/;"	m	=
struct:tg3_internal_buffer_desc=0A=
-cur_time	tg3.c	/^	unsigned long link_time, cur_time;$/;"	m	=
struct:tg3_fiber_aneginfo	file:=0A=
-data_base	tg3.c	/^	unsigned int data_base;$/;"	m	struct:fw_info	file:=0A=
-data_data	tg3.c	/^	u32 *data_data;$/;"	m	struct:fw_info	file:=0A=
-data_len	tg3.c	/^	unsigned int data_len;$/;"	m	struct:fw_info	file:=0A=
-dev	tg3.h	/^	struct net_device		*dev;$/;"	m	struct:tg3=0A=
-dma_high_water	tg3.h	/^	u32		dma_high_water;$/;"	m	=
struct:tg3_bufmgr_config=0A=
-dma_low_water	tg3.h	/^	u32		dma_low_water;$/;"	m	=
struct:tg3_bufmgr_config=0A=
-dma_read_prioq_full	tg3.h	/^	tg3_stat64_t			dma_read_prioq_full;$/;"	m	=
struct:tg3_hw_stats=0A=
-dma_readq_full	tg3.h	/^	tg3_stat64_t			dma_readq_full;$/;"	m	=
struct:tg3_hw_stats=0A=
-dma_rwctrl	tg3.h	/^	u32				dma_rwctrl;$/;"	m	struct:tg3=0A=
-dma_write_prioq_full	tg3.h	/^	tg3_stat64_t			dma_write_prioq_full;$/;"	=
m	struct:tg3_hw_stats=0A=
-dma_writeq_full	tg3.h	/^	tg3_stat64_t			dma_writeq_full;$/;"	m	=
struct:tg3_hw_stats=0A=
-duplex	tg3.h	/^	u8				duplex;$/;"	m	struct:tg3_link_config=0A=
-err_vlan	tg3.h	/^	u32				err_vlan;$/;"	m	struct:tg3_rx_buffer_desc=0A=
-flags	tg3.c	/^	u32 flags;$/;"	m	struct:tg3_fiber_aneginfo	file:=0A=
-flags	tg3.h	/^	u32				flags;$/;"	m	struct:tg3_config_info=0A=
-flags	tg3.h	/^	u32				flags;$/;"	m	struct:tg3_internal_buffer_desc=0A=
-fw_info	tg3.c	/^struct fw_info {$/;"	s	file:=0A=
-get_stat64	tg3.c	/^static inline unsigned long get_stat64(tg3_stat64_t =
*val)$/;"	f	file:=0A=
-grc_local_ctrl	tg3.h	/^	u32				grc_local_ctrl;$/;"	m	struct:tg3=0A=
-grc_mode	tg3.h	/^	u32				grc_mode;$/;"	m	struct:tg3=0A=
-high	tg3.h	/^	u32 high, low;$/;"	m	struct:=0A=
-hw_stats	tg3.h	/^	struct tg3_hw_stats		*hw_stats;$/;"	m	struct:tg3=0A=
-hw_status	tg3.h	/^	struct tg3_hw_status		*hw_status;$/;"	m	struct:tg3=0A=
-idle_match	tg3.c	/^	char ability_match, idle_match, ack_match;$/;"	m	=
struct:tg3_fiber_aneginfo	file:=0A=
-idx	tg3.h	/^	}				idx[16];$/;"	m	struct:tg3_hw_status=0A=
-idx_len	tg3.h	/^	u32				idx_len;$/;"	m	struct:tg3_rx_buffer_desc=0A=
-indirect_lock	tg3.h	/^	spinlock_t			indirect_lock;$/;"	m	struct:tg3=0A=
-ip_tcp_csum	tg3.h	/^	u32				ip_tcp_csum;$/;"	m	struct:tg3_rx_buffer_desc=0A=
-led_mode	tg3.h	/^	enum phy_led_mode		led_mode;$/;"	m	struct:tg3=0A=
-led_mode_auto	tg3.h	/^	led_mode_auto,$/;"	e	enum:phy_led_mode=0A=
-led_mode_link10	tg3.h	/^	led_mode_link10$/;"	e	enum:phy_led_mode=0A=
-led_mode_three_link	tg3.h	/^	led_mode_three_link,$/;"	e	=
enum:phy_led_mode=0A=
-len	tg3.h	/^	u16				len;$/;"	m	struct:tg3_internal_buffer_desc=0A=
-len2_len1	tg3.h	/^	u32				len2_len1;$/;"	m	struct:tg3_ext_rx_buffer_desc=0A=
-len_flags	tg3.h	/^	u32				len_flags;$/;"	m	struct:tg3_tx_buffer_desc=0A=
-link_config	tg3.h	/^	struct tg3_link_config		link_config;$/;"	m	=
struct:tg3=0A=
-link_time	tg3.c	/^	unsigned long link_time, cur_time;$/;"	m	=
struct:tg3_fiber_aneginfo	file:=0A=
-lock	tg3.h	/^	spinlock_t			lock;$/;"	m	struct:tg3=0A=
-low	tg3.h	/^	u32 high, low;$/;"	m	struct:=0A=
-mac_mode	tg3.h	/^	u32				mac_mode;$/;"	m	struct:tg3=0A=
-mbuf_high_water	tg3.h	/^	u32		mbuf_high_water;$/;"	m	=
struct:tg3_bufmgr_config=0A=
-mbuf_high_water_jumbo	tg3.h	/^	u32		mbuf_high_water_jumbo;$/;"	m	=
struct:tg3_bufmgr_config=0A=
-mbuf_mac_rx_low_water	tg3.h	/^	u32		mbuf_mac_rx_low_water;$/;"	m	=
struct:tg3_bufmgr_config=0A=
-mbuf_mac_rx_low_water_jumbo	tg3.h	/^	u32		=
mbuf_mac_rx_low_water_jumbo;$/;"	m	struct:tg3_bufmgr_config=0A=
-mbuf_read_dma_low_water	tg3.h	/^	u32		mbuf_read_dma_low_water;$/;"	m	=
struct:tg3_bufmgr_config=0A=
-mbuf_read_dma_low_water_jumbo	tg3.h	/^	u32		=
mbuf_read_dma_low_water_jumbo;$/;"	m	struct:tg3_bufmgr_config=0A=
-mi_mode	tg3.h	/^	u32				mi_mode;$/;"	m	struct:tg3=0A=
-misc_host_ctrl	tg3.h	/^	u32				misc_host_ctrl;$/;"	m	struct:tg3=0A=
-msg_enable	tg3.h	/^	u32				msg_enable;$/;"	m	struct:tg3=0A=
-net_stats	tg3.h	/^	struct net_device_stats		net_stats;$/;"	m	struct:tg3=0A=
-net_stats_prev	tg3.h	/^	struct net_device_stats		net_stats_prev;$/;"	m	=
struct:tg3=0A=
-nic_avoided_irqs	tg3.h	/^	tg3_stat64_t			nic_avoided_irqs;$/;"	m	=
struct:tg3_hw_stats=0A=
-nic_irqs	tg3.h	/^	tg3_stat64_t			nic_irqs;$/;"	m	struct:tg3_hw_stats=0A=
-nic_mbuf	tg3.h	/^	u32				nic_mbuf;$/;"	m	struct:tg3_internal_buffer_desc=0A=
-nic_sram_data_cfg	tg3.h	/^	u32				nic_sram_data_cfg;$/;"	m	struct:tg3=0A=
-nic_tx_threshold_hit	tg3.h	/^	tg3_stat64_t			nic_tx_threshold_hit;$/;"	=
m	struct:tg3_hw_stats=0A=
-opaque	tg3.h	/^	u32				opaque;$/;"	m	struct:tg3_rx_buffer_desc=0A=
-orig_autoneg	tg3.h	/^	u8				orig_autoneg;$/;"	m	struct:tg3_link_config=0A=
-orig_duplex	tg3.h	/^	u8				orig_duplex;$/;"	m	struct:tg3_link_config=0A=
-orig_speed	tg3.h	/^	u16				orig_speed;$/;"	m	struct:tg3_link_config=0A=
-pci_bist	tg3.h	/^	u8				pci_bist;$/;"	m	struct:tg3=0A=
-pci_cacheline_sz	tg3.h	/^	u8				pci_cacheline_sz;$/;"	m	struct:tg3=0A=
-pci_cfg_state	tg3.h	/^	u32				pci_cfg_state[64 \/ sizeof(u32)];$/;"	m	=
struct:tg3=0A=
-pci_chip_rev_id	tg3.h	/^	u16				pci_chip_rev_id;$/;"	m	struct:tg3=0A=
-pci_clock_ctrl	tg3.h	/^	u32				pci_clock_ctrl;$/;"	m	struct:tg3=0A=
-pci_hdr_type	tg3.h	/^	u8				pci_hdr_type;$/;"	m	struct:tg3=0A=
-pci_lat_timer	tg3.h	/^	u8				pci_lat_timer;$/;"	m	struct:tg3=0A=
-pdev	tg3.h	/^	struct pci_dev			*pdev;$/;"	m	struct:tg3=0A=
-pdev_peer	tg3.h	/^	struct pci_dev			*pdev_peer;$/;"	m	struct:tg3=0A=
-phy_crc_errors	tg3.h	/^	unsigned long			phy_crc_errors;$/;"	m	struct:tg3=0A=
-phy_id	tg3.c	/^	u32 phy_id;$/;"	m	struct:subsys_tbl_ent	file:=0A=
-phy_id	tg3.h	/^	u32				phy_id;$/;"	m	struct:tg3=0A=
-phy_is_low_power	tg3.h	/^	int				phy_is_low_power;$/;"	m	=
struct:tg3_link_config=0A=
-phy_led_mode	tg3.h	/^enum phy_led_mode {$/;"	g=0A=
-pm_cap	tg3.h	/^	int				pm_cap;$/;"	m	struct:tg3=0A=
-regs	tg3.h	/^	unsigned long			regs;$/;"	m	struct:tg3=0A=
-reserved	tg3.h	/^	u16				reserved;$/;"	m	struct:tg3_hw_status=0A=
-reserved	tg3.h	/^	u32				reserved;$/;"	m	struct:tg3_rx_buffer_desc=0A=
-reset_task	tg3.h	/^	struct work_struct		reset_task;$/;"	m	struct:tg3=0A=
-resv_len3	tg3.h	/^	u32				resv_len3;$/;"	m	struct:tg3_ext_rx_buffer_desc=0A=
-ring_info	tg3.h	/^struct ring_info {$/;"	s=0A=
-ring_set_send_prod_index	tg3.h	/^	tg3_stat64_t			=
ring_set_send_prod_index;$/;"	m	struct:tg3_hw_stats=0A=
-ring_status_update	tg3.h	/^	tg3_stat64_t			ring_status_update;$/;"	m	=
struct:tg3_hw_stats=0A=
-rodata_base	tg3.c	/^	unsigned int rodata_base;$/;"	m	struct:fw_info	=
file:=0A=
-rodata_data	tg3.c	/^	u32 *rodata_data;$/;"	m	struct:fw_info	file:=0A=
-rodata_len	tg3.c	/^	unsigned int rodata_len;$/;"	m	struct:fw_info	file:=0A=
-rx_1024_to_1522_octet_packets	tg3.h	/^	tg3_stat64_t			=
rx_1024_to_1522_octet_packets;$/;"	m	struct:tg3_hw_stats=0A=
-rx_128_to_255_octet_packets	tg3.h	/^	tg3_stat64_t			=
rx_128_to_255_octet_packets;$/;"	m	struct:tg3_hw_stats=0A=
-rx_1523_to_2047_octet_packets	tg3.h	/^	tg3_stat64_t			=
rx_1523_to_2047_octet_packets;$/;"	m	struct:tg3_hw_stats=0A=
-rx_2048_to_4095_octet_packets	tg3.h	/^	tg3_stat64_t			=
rx_2048_to_4095_octet_packets;$/;"	m	struct:tg3_hw_stats=0A=
-rx_256_to_511_octet_packets	tg3.h	/^	tg3_stat64_t			=
rx_256_to_511_octet_packets;$/;"	m	struct:tg3_hw_stats=0A=
-rx_4096_to_8191_octet_packets	tg3.h	/^	tg3_stat64_t			=
rx_4096_to_8191_octet_packets;$/;"	m	struct:tg3_hw_stats=0A=
-rx_512_to_1023_octet_packets	tg3.h	/^	tg3_stat64_t			=
rx_512_to_1023_octet_packets;$/;"	m	struct:tg3_hw_stats=0A=
-rx_64_or_less_octet_packets	tg3.h	/^	tg3_stat64_t			=
rx_64_or_less_octet_packets;$/;"	m	struct:tg3_hw_stats=0A=
-rx_65_to_127_octet_packets	tg3.h	/^	tg3_stat64_t			=
rx_65_to_127_octet_packets;$/;"	m	struct:tg3_hw_stats=0A=
-rx_8192_to_9022_octet_packets	tg3.h	/^	tg3_stat64_t			=
rx_8192_to_9022_octet_packets;$/;"	m	struct:tg3_hw_stats=0A=
-rx_align_errors	tg3.h	/^	tg3_stat64_t			rx_align_errors;$/;"	m	=
struct:tg3_hw_stats=0A=
-rx_bcast_packets	tg3.h	/^	tg3_stat64_t			rx_bcast_packets;$/;"	m	=
struct:tg3_hw_stats=0A=
-rx_consumer	tg3.h	/^	u16				rx_consumer;$/;"	m	struct:tg3_hw_status=0A=
-rx_discards	tg3.h	/^	tg3_stat64_t			rx_discards;$/;"	m	=
struct:tg3_hw_stats=0A=
-rx_errors	tg3.h	/^	tg3_stat64_t			rx_errors;$/;"	m	struct:tg3_hw_stats=0A=
-rx_fcs_errors	tg3.h	/^	tg3_stat64_t			rx_fcs_errors;$/;"	m	=
struct:tg3_hw_stats=0A=
-rx_fragments	tg3.h	/^	tg3_stat64_t			rx_fragments;$/;"	m	=
struct:tg3_hw_stats=0A=
-rx_frame_too_long_errors	tg3.h	/^	tg3_stat64_t			=
rx_frame_too_long_errors;$/;"	m	struct:tg3_hw_stats=0A=
-rx_in_length_errors	tg3.h	/^	tg3_stat64_t			rx_in_length_errors;$/;"	m	=
struct:tg3_hw_stats=0A=
-rx_jabbers	tg3.h	/^	tg3_stat64_t			rx_jabbers;$/;"	m	struct:tg3_hw_stats=0A=
-rx_jumbo	tg3.h	/^	struct tg3_rx_buffer_desc	*rx_jumbo;$/;"	m	struct:tg3=0A=
-rx_jumbo_buffers	tg3.h	/^	struct ring_info		*rx_jumbo_buffers;$/;"	m	=
struct:tg3=0A=
-rx_jumbo_consumer	tg3.h	/^	u16				rx_jumbo_consumer;$/;"	m	=
struct:tg3_hw_status=0A=
-rx_jumbo_mapping	tg3.h	/^	dma_addr_t			rx_jumbo_mapping;$/;"	m	=
struct:tg3=0A=
-rx_jumbo_pending	tg3.h	/^	u32				rx_jumbo_pending;$/;"	m	struct:tg3=0A=
-rx_jumbo_ptr	tg3.h	/^	u32				rx_jumbo_ptr;$/;"	m	struct:tg3=0A=
-rx_mac_ctrl_rcvd	tg3.h	/^	tg3_stat64_t			rx_mac_ctrl_rcvd;$/;"	m	=
struct:tg3_hw_stats=0A=
-rx_mcast_packets	tg3.h	/^	tg3_stat64_t			rx_mcast_packets;$/;"	m	=
struct:tg3_hw_stats=0A=
-rx_mini_consumer	tg3.h	/^	u16				rx_mini_consumer;$/;"	m	=
struct:tg3_hw_status=0A=
-rx_mode	tg3.h	/^	u32				rx_mode;$/;"	m	struct:tg3=0A=
-rx_octets	tg3.h	/^	tg3_stat64_t			rx_octets;$/;"	m	struct:tg3_hw_stats=0A=
-rx_offset	tg3.h	/^	u32				rx_offset;$/;"	m	struct:tg3=0A=
-rx_out_length_errors	tg3.h	/^	tg3_stat64_t			rx_out_length_errors;$/;"	=
m	struct:tg3_hw_stats=0A=
-rx_pending	tg3.h	/^	u32				rx_pending;$/;"	m	struct:tg3=0A=
-rx_producer	tg3.h	/^		u16			rx_producer;$/;"	m	=
struct:tg3_hw_status::<anonymous>=0A=
-rx_rcb	tg3.h	/^	struct tg3_rx_buffer_desc	*rx_rcb;$/;"	m	struct:tg3=0A=
-rx_rcb_mapping	tg3.h	/^	dma_addr_t			rx_rcb_mapping;$/;"	m	struct:tg3=0A=
-rx_rcb_ptr	tg3.h	/^	u32				rx_rcb_ptr;$/;"	m	struct:tg3=0A=
-rx_std	tg3.h	/^	struct tg3_rx_buffer_desc	*rx_std;$/;"	m	struct:tg3=0A=
-rx_std_buffers	tg3.h	/^	struct ring_info		*rx_std_buffers;$/;"	m	=
struct:tg3=0A=
-rx_std_mapping	tg3.h	/^	dma_addr_t			rx_std_mapping;$/;"	m	struct:tg3=0A=
-rx_std_ptr	tg3.h	/^	u32				rx_std_ptr;$/;"	m	struct:tg3=0A=
-rx_threshold_hit	tg3.h	/^	tg3_stat64_t			rx_threshold_hit;$/;"	m	=
struct:tg3_hw_stats=0A=
-rx_ucast_packets	tg3.h	/^	tg3_stat64_t			rx_ucast_packets;$/;"	m	=
struct:tg3_hw_stats=0A=
-rx_undersize_packets	tg3.h	/^	tg3_stat64_t			rx_undersize_packets;$/;"	=
m	struct:tg3_hw_stats=0A=
-rx_xoff_entered	tg3.h	/^	tg3_stat64_t			rx_xoff_entered;$/;"	m	=
struct:tg3_hw_stats=0A=
-rx_xoff_pause_rcvd	tg3.h	/^	tg3_stat64_t			rx_xoff_pause_rcvd;$/;"	m	=
struct:tg3_hw_stats=0A=
-rx_xon_pause_rcvd	tg3.h	/^	tg3_stat64_t			rx_xon_pause_rcvd;$/;"	m	=
struct:tg3_hw_stats=0A=
-rxbds_empty	tg3.h	/^	tg3_stat64_t			rxbds_empty;$/;"	m	=
struct:tg3_hw_stats=0A=
-rxconfig	tg3.c	/^	u32 txconfig, rxconfig;$/;"	m	=
struct:tg3_fiber_aneginfo	file:=0A=
-skb	tg3.h	/^	struct sk_buff			*skb;$/;"	m	struct:ring_info=0A=
-skb	tg3.h	/^	struct sk_buff			*skb;$/;"	m	struct:tx_ring_info=0A=
-speed	tg3.h	/^	u16				speed;$/;"	m	struct:tg3_link_config=0A=
-split_mode_max_reqs	tg3.h	/^	u32				split_mode_max_reqs;$/;"	m	=
struct:tg3=0A=
-state	tg3.c	/^	int state;$/;"	m	struct:tg3_fiber_aneginfo	file:=0A=
-stats_mapping	tg3.h	/^	dma_addr_t			stats_mapping;$/;"	m	struct:tg3=0A=
-status	tg3.h	/^	u32				status;$/;"	m	struct:tg3_hw_status=0A=
-status_mapping	tg3.h	/^	dma_addr_t			status_mapping;$/;"	m	struct:tg3=0A=
-status_tag	tg3.h	/^	u32				status_tag;$/;"	m	struct:tg3_hw_status=0A=
-std	tg3.h	/^	struct tg3_rx_buffer_desc	std;$/;"	m	=
struct:tg3_ext_rx_buffer_desc=0A=
-subsys_devid	tg3.c	/^	u16 subsys_vendor, subsys_devid;$/;"	m	=
struct:subsys_tbl_ent	file:=0A=
-subsys_id_to_phy_id	tg3.c	/^static struct subsys_tbl_ent =
subsys_id_to_phy_id[] =3D {$/;"	v	file:=0A=
-subsys_tbl_ent	tg3.c	/^struct subsys_tbl_ent {$/;"	s	file:=0A=
-subsys_vendor	tg3.c	/^	u16 subsys_vendor, subsys_devid;$/;"	m	=
struct:subsys_tbl_ent	file:=0A=
-text_base	tg3.c	/^	unsigned int text_base;$/;"	m	struct:fw_info	file:=0A=
-text_data	tg3.c	/^	u32 *text_data;$/;"	m	struct:fw_info	file:=0A=
-text_len	tg3.c	/^	unsigned int text_len;$/;"	m	struct:fw_info	file:=0A=
-tg3	tg3.h	/^struct tg3 {$/;"	s=0A=
-tg3FwRodata	tg3.c	/^static u32 tg3FwRodata[(TG3_FW_RODATA_LEN \/ =
sizeof(u32)) + 1] =3D {$/;"	v	file:=0A=
-tg3FwText	tg3.c	/^static u32 tg3FwText[(TG3_FW_TEXT_LEN \/ sizeof(u32)) =
+ 1] =3D {$/;"	v	file:=0A=
-tg3Tso5FwData	tg3.c	/^u32 tg3Tso5FwData[] =3D {$/;"	v=0A=
-tg3Tso5FwRodata	tg3.c	/^u32 tg3Tso5FwRodata[] =3D {$/;"	v=0A=
-tg3Tso5FwText	tg3.c	/^static u32 tg3Tso5FwText[] =3D {$/;"	v	file:=0A=
-tg3TsoFwRodata	tg3.c	/^u32 tg3TsoFwRodata[] =3D {$/;"	v=0A=
-tg3TsoFwText	tg3.c	/^static u32 tg3TsoFwText[] =3D {$/;"	v	file:=0A=
-tg3_4g_overflow_test	tg3.c	/^static inline int =
tg3_4g_overflow_test(dma_addr_t mapping, int len)$/;"	f	file:=0A=
-tg3_abort_hw	tg3.c	/^static int tg3_abort_hw(struct tg3 *tp)$/;"	f	file:=0A=
-tg3_alloc_consistent	tg3.c	/^static int tg3_alloc_consistent(struct tg3 =
*tp)$/;"	f	file:=0A=
-tg3_alloc_rx_skb	tg3.c	/^static int tg3_alloc_rx_skb(struct tg3 *tp, =
u32 opaque_key,$/;"	f	file:=0A=
-tg3_aux_stat_to_speed_duplex	tg3.c	/^static void =
tg3_aux_stat_to_speed_duplex(struct tg3 *tp, u32 val, u16 *speed, u8 =
*duplex)$/;"	f	file:=0A=
-tg3_bmcr_reset	tg3.c	/^static int tg3_bmcr_reset(struct tg3 *tp)$/;"	f	=
file:=0A=
-tg3_bufmgr_config	tg3.h	/^struct tg3_bufmgr_config {$/;"	s=0A=
-tg3_change_mtu	tg3.c	/^static int tg3_change_mtu(struct net_device =
*dev, int new_mtu)$/;"	f	file:=0A=
-tg3_chip_reset	tg3.c	/^static void tg3_chip_reset(struct tg3 *tp)$/;"	f	=
file:=0A=
-tg3_cleanup	tg3.c	/^module_exit(tg3_cleanup);$/;"	v=0A=
-tg3_cleanup	tg3.c	/^static void __exit tg3_cleanup(void)$/;"	f	file:=0A=
-tg3_close	tg3.c	/^static int tg3_close(struct net_device *dev)$/;"	f	=
file:=0A=
-tg3_cond_int	tg3.c	/^static inline void tg3_cond_int(struct tg3 =
*tp)$/;"	f	file:=0A=
-tg3_config_info	tg3.h	/^struct tg3_config_info {$/;"	s=0A=
-tg3_debug	tg3.c	/^static int tg3_debug =3D -1;	\/* -1 =3D=3D use =
TG3_DEF_MSG_ENABLE as value *\/$/;"	v	file:=0A=
-tg3_disable_ints	tg3.c	/^static void tg3_disable_ints(struct tg3 =
*tp)$/;"	f	file:=0A=
-tg3_do_test_dma	tg3.c	/^static int __devinit tg3_do_test_dma(struct tg3 =
*tp, u32 *buf, dma_addr_t buf_dma, int size, int to_device)$/;"	f	file:=0A=
-tg3_driver	tg3.c	/^static struct pci_driver tg3_driver =3D {$/;"	v	file:=0A=
-tg3_enable_ints	tg3.c	/^static void tg3_enable_ints(struct tg3 *tp)$/;"	=
f	file:=0A=
-tg3_ethtool_ops	tg3.c	/^static struct ethtool_ops tg3_ethtool_ops =3D =
{$/;"	v	file:=0A=
-tg3_ext_rx_buffer_desc	tg3.h	/^struct tg3_ext_rx_buffer_desc {$/;"	s=0A=
-tg3_fiber_aneg_smachine	tg3.c	/^static int =
tg3_fiber_aneg_smachine(struct tg3 *tp,$/;"	f	file:=0A=
-tg3_fiber_aneginfo	tg3.c	/^struct tg3_fiber_aneginfo {$/;"	s	file:=0A=
-tg3_find_5704_peer	tg3.c	/^static struct pci_dev * __devinit =
tg3_find_5704_peer(struct tg3 *tp)$/;"	f	file:=0A=
-tg3_flags	tg3.h	/^	u32				tg3_flags;$/;"	m	struct:tg3=0A=
-tg3_flags2	tg3.h	/^	u32				tg3_flags2;$/;"	m	struct:tg3=0A=
-tg3_free_consistent	tg3.c	/^static void tg3_free_consistent(struct tg3 =
*tp)$/;"	f	file:=0A=
-tg3_free_rings	tg3.c	/^static void tg3_free_rings(struct tg3 *tp)$/;"	f	=
file:=0A=
-tg3_frob_aux_power	tg3.c	/^static void tg3_frob_aux_power(struct tg3 =
*tp)$/;"	f	file:=0A=
-tg3_get_default_macaddr_sparc	tg3.c	/^static int __devinit =
tg3_get_default_macaddr_sparc(struct tg3 *tp)$/;"	f	file:=0A=
-tg3_get_device_address	tg3.c	/^static int __devinit =
tg3_get_device_address(struct tg3 *tp)$/;"	f	file:=0A=
-tg3_get_drvinfo	tg3.c	/^static void tg3_get_drvinfo(struct net_device =
*dev, struct ethtool_drvinfo *info)$/;"	f	file:=0A=
-tg3_get_invariants	tg3.c	/^static int __devinit =
tg3_get_invariants(struct tg3 *tp)$/;"	f	file:=0A=
-tg3_get_macaddr_sparc	tg3.c	/^static int __devinit =
tg3_get_macaddr_sparc(struct tg3 *tp)$/;"	f	file:=0A=
-tg3_get_msglevel	tg3.c	/^static u32 tg3_get_msglevel(struct net_device =
*dev)$/;"	f	file:=0A=
-tg3_get_pauseparam	tg3.c	/^static void tg3_get_pauseparam(struct =
net_device *dev, struct ethtool_pauseparam *epause)$/;"	f	file:=0A=
-tg3_get_regs	tg3.c	/^static void tg3_get_regs(struct net_device *dev, =
struct ethtool_regs *regs, void *p)$/;"	f	file:=0A=
-tg3_get_regs_len	tg3.c	/^static int tg3_get_regs_len(struct net_device =
*dev)$/;"	f	file:=0A=
-tg3_get_ringparam	tg3.c	/^static void tg3_get_ringparam(struct =
net_device *dev, struct ethtool_ringparam *ering)$/;"	f	file:=0A=
-tg3_get_rx_csum	tg3.c	/^static u32 tg3_get_rx_csum(struct net_device =
*dev)$/;"	f	file:=0A=
-tg3_get_settings	tg3.c	/^static int tg3_get_settings(struct net_device =
*dev, struct ethtool_cmd *cmd)$/;"	f	file:=0A=
-tg3_get_stats	tg3.c	/^static struct net_device_stats =
*tg3_get_stats(struct net_device *dev)$/;"	f	file:=0A=
-tg3_get_wol	tg3.c	/^static void tg3_get_wol(struct net_device *dev, =
struct ethtool_wolinfo *wol)$/;"	f	file:=0A=
-tg3_halt	tg3.c	/^static int tg3_halt(struct tg3 *tp)$/;"	f	file:=0A=
-tg3_halt_cpu	tg3.c	/^static int tg3_halt_cpu(struct tg3 *tp, u32 =
offset)$/;"	f	file:=0A=
-tg3_has_work	tg3.c	/^static inline unsigned int tg3_has_work(struct =
net_device *dev, struct tg3 *tp)$/;"	f	file:=0A=
-tg3_hw_stats	tg3.h	/^struct tg3_hw_stats {$/;"	s=0A=
-tg3_hw_status	tg3.h	/^struct tg3_hw_status {$/;"	s=0A=
-tg3_init	tg3.c	/^module_init(tg3_init);$/;"	v=0A=
-tg3_init	tg3.c	/^static int __init tg3_init(void)$/;"	f	file:=0A=
-tg3_init_5401phy_dsp	tg3.c	/^static int tg3_init_5401phy_dsp(struct tg3 =
*tp)$/;"	f	file:=0A=
-tg3_init_bufmgr_config	tg3.c	/^static void __devinit =
tg3_init_bufmgr_config(struct tg3 *tp)$/;"	f	file:=0A=
-tg3_init_hw	tg3.c	/^static int tg3_init_hw(struct tg3 *tp)$/;"	f	file:=0A=
-tg3_init_link_config	tg3.c	/^static void __devinit =
tg3_init_link_config(struct tg3 *tp)$/;"	f	file:=0A=
-tg3_init_one	tg3.c	/^static int __devinit tg3_init_one(struct pci_dev =
*pdev,$/;"	f	file:=0A=
-tg3_init_rings	tg3.c	/^static void tg3_init_rings(struct tg3 *tp)$/;"	f	=
file:=0A=
-tg3_internal_buffer_desc	tg3.h	/^struct tg3_internal_buffer_desc {$/;"	s=0A=
-tg3_interrupt	tg3.c	/^static irqreturn_t tg3_interrupt(int irq, void =
*dev_id, struct pt_regs *regs)$/;"	f	file:=0A=
-tg3_ioctl	tg3.c	/^static int tg3_ioctl(struct net_device *dev, struct =
ifreq *ifr, int cmd)$/;"	f	file:=0A=
-tg3_is_sun_5704	tg3.c	/^static int __devinit tg3_is_sun_5704(struct tg3 =
*tp)$/;"	f	file:=0A=
-tg3_link_config	tg3.h	/^struct tg3_link_config {$/;"	s=0A=
-tg3_link_report	tg3.c	/^static void tg3_link_report(struct tg3 *tp)$/;"	=
f	file:=0A=
-tg3_load_5701_a0_firmware_fix	tg3.c	/^static int =
tg3_load_5701_a0_firmware_fix(struct tg3 *tp)$/;"	f	file:=0A=
-tg3_load_firmware_cpu	tg3.c	/^static int tg3_load_firmware_cpu(struct =
tg3 *tp, u32 cpu_base, u32 cpu_scratch_base,$/;"	f	file:=0A=
-tg3_load_tso_firmware	tg3.c	/^static int tg3_load_tso_firmware(struct =
tg3 *tp)$/;"	f	file:=0A=
-tg3_netif_start	tg3.c	/^static inline void tg3_netif_start(struct tg3 =
*tp)$/;"	f	file:=0A=
-tg3_netif_stop	tg3.c	/^static inline void tg3_netif_stop(struct tg3 =
*tp)$/;"	f	file:=0A=
-tg3_nvram_init	tg3.c	/^static void __devinit tg3_nvram_init(struct tg3 =
*tp)$/;"	f	file:=0A=
-tg3_nvram_read	tg3.c	/^static int __devinit tg3_nvram_read(struct tg3 =
*tp,$/;"	f	file:=0A=
-tg3_nvram_read_using_eeprom	tg3.c	/^static int __devinit =
tg3_nvram_read_using_eeprom(struct tg3 *tp,$/;"	f	file:=0A=
-tg3_nway_reset	tg3.c	/^static int tg3_nway_reset(struct net_device =
*dev)$/;"	f	file:=0A=
-tg3_open	tg3.c	/^static int tg3_open(struct net_device *dev)$/;"	f	file:=0A=
-tg3_pci_tbl	tg3.c	/^static struct pci_device_id tg3_pci_tbl[] =3D {$/;"	=
v	file:=0A=
-tg3_periodic_fetch_stats	tg3.c	/^static void =
tg3_periodic_fetch_stats(struct tg3 *tp)$/;"	f	file:=0A=
-tg3_phy_copper_begin	tg3.c	/^static int tg3_phy_copper_begin(struct tg3 =
*tp, int wait_for_link)$/;"	f	file:=0A=
-tg3_phy_probe	tg3.c	/^static int __devinit tg3_phy_probe(struct tg3 =
*tp)$/;"	f	file:=0A=
-tg3_phy_reset	tg3.c	/^static int tg3_phy_reset(struct tg3 *tp, int =
force)$/;"	f	file:=0A=
-tg3_phy_reset_5703_4_5	tg3.c	/^static int tg3_phy_reset_5703_4_5(struct =
tg3 *tp)$/;"	f	file:=0A=
-tg3_phy_reset_chanpat	tg3.c	/^static int tg3_phy_reset_chanpat(struct =
tg3 *tp)$/;"	f	file:=0A=
-tg3_phy_set_wirespeed	tg3.c	/^static void tg3_phy_set_wirespeed(struct =
tg3 *tp)$/;"	f	file:=0A=
-tg3_phy_string	tg3.c	/^static char * __devinit tg3_phy_string(struct =
tg3 *tp)$/;"	f	file:=0A=
-tg3_phy_write_and_check_testpat	tg3.c	/^static int =
tg3_phy_write_and_check_testpat(struct tg3 *tp, int *resetp)$/;"	f	file:=0A=
-tg3_poll	tg3.c	/^static int tg3_poll(struct net_device *netdev, int =
*budget)$/;"	f	file:=0A=
-tg3_read_mem	tg3.c	/^static void tg3_read_mem(struct tg3 *tp, u32 off, =
u32 *val)$/;"	f	file:=0A=
-tg3_read_partno	tg3.c	/^static void __devinit tg3_read_partno(struct =
tg3 *tp)$/;"	f	file:=0A=
-tg3_readphy	tg3.c	/^static int tg3_readphy(struct tg3 *tp, int reg, u32 =
*val)$/;"	f	file:=0A=
-tg3_recycle_rx	tg3.c	/^static void tg3_recycle_rx(struct tg3 *tp, u32 =
opaque_key,$/;"	f	file:=0A=
-tg3_remove_one	tg3.c	/^static void __devexit tg3_remove_one(struct =
pci_dev *pdev)$/;"	f	file:=0A=
-tg3_reset_hw	tg3.c	/^static int tg3_reset_hw(struct tg3 *tp)$/;"	f	file:=0A=
-tg3_reset_task	tg3.c	/^static void tg3_reset_task(void *_data)$/;"	f	=
file:=0A=
-tg3_resume	tg3.c	/^static int tg3_resume(struct pci_dev *pdev)$/;"	f	=
file:=0A=
-tg3_rx	tg3.c	/^static int tg3_rx(struct tg3 *tp, int budget)$/;"	f	file:=0A=
-tg3_rx_buffer_desc	tg3.h	/^struct tg3_rx_buffer_desc {$/;"	s=0A=
-tg3_set_bdinfo	tg3.c	/^static void tg3_set_bdinfo(struct tg3 *tp, u32 =
bdinfo_addr,$/;"	f	file:=0A=
-tg3_set_mac_addr	tg3.c	/^static int tg3_set_mac_addr(struct net_device =
*dev, void *p)$/;"	f	file:=0A=
-tg3_set_msglevel	tg3.c	/^static void tg3_set_msglevel(struct net_device =
*dev, u32 value)$/;"	f	file:=0A=
-tg3_set_mtu	tg3.c	/^static inline void tg3_set_mtu(struct net_device =
*dev, struct tg3 *tp,$/;"	f	file:=0A=
-tg3_set_multi	tg3.c	/^static void tg3_set_multi(struct tg3 *tp, =
unsigned int accept_all)$/;"	f	file:=0A=
-tg3_set_pauseparam	tg3.c	/^static int tg3_set_pauseparam(struct =
net_device *dev, struct ethtool_pauseparam *epause)$/;"	f	file:=0A=
-tg3_set_power_state	tg3.c	/^static int tg3_set_power_state(struct tg3 =
*tp, int state)$/;"	f	file:=0A=
-tg3_set_ringparam	tg3.c	/^static int tg3_set_ringparam(struct =
net_device *dev, struct ethtool_ringparam *ering)$/;"	f	file:=0A=
-tg3_set_rx_csum	tg3.c	/^static int tg3_set_rx_csum(struct net_device =
*dev, u32 data)$/;"	f	file:=0A=
-tg3_set_rx_mode	tg3.c	/^static void tg3_set_rx_mode(struct net_device =
*dev)$/;"	f	file:=0A=
-tg3_set_settings	tg3.c	/^static int tg3_set_settings(struct net_device =
*dev, struct ethtool_cmd *cmd)$/;"	f	file:=0A=
-tg3_set_tso	tg3.c	/^static int tg3_set_tso(struct net_device *dev, u32 =
value)$/;"	f	file:=0A=
-tg3_set_tx_csum	tg3.c	/^static int tg3_set_tx_csum(struct net_device =
*dev, u32 data)$/;"	f	file:=0A=
-tg3_set_txd	tg3.c	/^static void tg3_set_txd(struct tg3 *tp, int =
entry,$/;"	f	file:=0A=
-tg3_set_wol	tg3.c	/^static int tg3_set_wol(struct net_device *dev, =
struct ethtool_wolinfo *wol)$/;"	f	file:=0A=
-tg3_setup_copper_phy	tg3.c	/^static int tg3_setup_copper_phy(struct tg3 =
*tp)$/;"	f	file:=0A=
-tg3_setup_fiber_phy	tg3.c	/^static int tg3_setup_fiber_phy(struct tg3 =
*tp)$/;"	f	file:=0A=
-tg3_setup_flow_control	tg3.c	/^static void =
tg3_setup_flow_control(struct tg3 *tp, u32 local_adv, u32 =
remote_adv)$/;"	f	file:=0A=
-tg3_setup_phy	tg3.c	/^static int tg3_setup_phy(struct tg3 *tp)$/;"	f	=
file:=0A=
-tg3_start_xmit	tg3.c	/^static int tg3_start_xmit(struct sk_buff *skb, =
struct net_device *dev)$/;"	f	file:=0A=
-tg3_start_xmit_4gbug	tg3.c	/^static int tg3_start_xmit_4gbug(struct =
sk_buff *skb, struct net_device *dev)$/;"	f	file:=0A=
-tg3_stat64_t	tg3.h	/^} tg3_stat64_t;$/;"	t=0A=
-tg3_stop_block	tg3.c	/^static int tg3_stop_block(struct tg3 *tp, =
unsigned long ofs, u32 enable_bit)$/;"	f	file:=0A=
-tg3_stop_fw	tg3.c	/^static void tg3_stop_fw(struct tg3 *tp)$/;"	f	file:=0A=
-tg3_suspend	tg3.c	/^static int tg3_suspend(struct pci_dev *pdev, u32 =
state)$/;"	f	file:=0A=
-tg3_switch_clocks	tg3.c	/^static void tg3_switch_clocks(struct tg3 =
*tp)$/;"	f	file:=0A=
-tg3_test_dma	tg3.c	/^static int __devinit tg3_test_dma(struct tg3 =
*tp)$/;"	f	file:=0A=
-tg3_timer	tg3.c	/^static void tg3_timer(unsigned long __opaque)$/;"	f	=
file:=0A=
-tg3_tx	tg3.c	/^static void tg3_tx(struct tg3 *tp)$/;"	f	file:=0A=
-tg3_tx_buffer_desc	tg3.h	/^struct tg3_tx_buffer_desc {$/;"	s=0A=
-tg3_tx_timeout	tg3.c	/^static void tg3_tx_timeout(struct net_device =
*dev)$/;"	f	file:=0A=
-tg3_vlan_rx	tg3.c	/^static int tg3_vlan_rx(struct tg3 *tp, struct =
sk_buff *skb, u16 vlan_tag)$/;"	f	file:=0A=
-tg3_vlan_rx_kill_vid	tg3.c	/^static void tg3_vlan_rx_kill_vid(struct =
net_device *dev, unsigned short vid)$/;"	f	file:=0A=
-tg3_vlan_rx_register	tg3.c	/^static void tg3_vlan_rx_register(struct =
net_device *dev, struct vlan_group *grp)$/;"	f	file:=0A=
-tg3_wait_macro_done	tg3.c	/^static int tg3_wait_macro_done(struct tg3 =
*tp)$/;"	f	file:=0A=
-tg3_write_indirect_reg32	tg3.c	/^static void =
tg3_write_indirect_reg32(struct tg3 *tp, u32 off, u32 val)$/;"	f	file:=0A=
-tg3_write_mem	tg3.c	/^static void tg3_write_mem(struct tg3 *tp, u32 =
off, u32 val)$/;"	f	file:=0A=
-tg3_writephy	tg3.c	/^static int tg3_writephy(struct tg3 *tp, int reg, =
u32 val)$/;"	f	file:=0A=
-tigon3_4gb_hwbug_workaround	tg3.c	/^static int =
tigon3_4gb_hwbug_workaround(struct tg3 *tp, struct sk_buff *skb,$/;"	f	=
file:=0A=
-timer	tg3.h	/^	struct timer_list		timer;$/;"	m	struct:tg3=0A=
-timer_counter	tg3.h	/^	u16				timer_counter;$/;"	m	struct:tg3=0A=
-timer_multiplier	tg3.h	/^	u16				timer_multiplier;$/;"	m	struct:tg3=0A=
-timer_offset	tg3.h	/^	u32				timer_offset;$/;"	m	struct:tg3=0A=
-tr16	tg3.c	217;"	d	file:=0A=
-tr32	tg3.c	216;"	d	file:=0A=
-tr8	tg3.c	218;"	d	file:=0A=
-tw16	tg3.c	214;"	d	file:=0A=
-tw32	tg3.c	212;"	d	file:=0A=
-tw32_mailbox	tg3.c	213;"	d	file:=0A=
-tw8	tg3.c	215;"	d	file:=0A=
-tx_bcast_packets	tg3.h	/^	tg3_stat64_t			tx_bcast_packets;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_buffers	tg3.h	/^	struct tx_ring_info		*tx_buffers;$/;"	m	struct:tg3=0A=
-tx_carrier_sense_errors	tg3.h	/^	tg3_stat64_t			=
tx_carrier_sense_errors;$/;"	m	struct:tg3_hw_stats=0A=
-tx_collide_10times	tg3.h	/^	tg3_stat64_t			tx_collide_10times;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_collide_11times	tg3.h	/^	tg3_stat64_t			tx_collide_11times;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_collide_12times	tg3.h	/^	tg3_stat64_t			tx_collide_12times;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_collide_13times	tg3.h	/^	tg3_stat64_t			tx_collide_13times;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_collide_14times	tg3.h	/^	tg3_stat64_t			tx_collide_14times;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_collide_15times	tg3.h	/^	tg3_stat64_t			tx_collide_15times;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_collide_2times	tg3.h	/^	tg3_stat64_t			tx_collide_2times;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_collide_3times	tg3.h	/^	tg3_stat64_t			tx_collide_3times;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_collide_4times	tg3.h	/^	tg3_stat64_t			tx_collide_4times;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_collide_5times	tg3.h	/^	tg3_stat64_t			tx_collide_5times;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_collide_6times	tg3.h	/^	tg3_stat64_t			tx_collide_6times;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_collide_7times	tg3.h	/^	tg3_stat64_t			tx_collide_7times;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_collide_8times	tg3.h	/^	tg3_stat64_t			tx_collide_8times;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_collide_9times	tg3.h	/^	tg3_stat64_t			tx_collide_9times;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_collisions	tg3.h	/^	tg3_stat64_t			tx_collisions;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_comp_queue_full	tg3.h	/^	tg3_stat64_t			tx_comp_queue_full;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_cons	tg3.h	/^	u32				tx_cons;$/;"	m	struct:tg3=0A=
-tx_consumer	tg3.h	/^		u16			tx_consumer;$/;"	m	=
struct:tg3_hw_status::<anonymous>=0A=
-tx_deferred	tg3.h	/^	tg3_stat64_t			tx_deferred;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_desc_mapping	tg3.h	/^	dma_addr_t			tx_desc_mapping;$/;"	m	struct:tg3=0A=
-tx_discards	tg3.h	/^	tg3_stat64_t			tx_discards;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_errors	tg3.h	/^	tg3_stat64_t			tx_errors;$/;"	m	struct:tg3_hw_stats=0A=
-tx_excessive_collisions	tg3.h	/^	tg3_stat64_t			=
tx_excessive_collisions;$/;"	m	struct:tg3_hw_stats=0A=
-tx_flow_control	tg3.h	/^	tg3_stat64_t			tx_flow_control;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_late_collisions	tg3.h	/^	tg3_stat64_t			tx_late_collisions;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_lock	tg3.h	/^	spinlock_t			tx_lock;$/;"	m	struct:tg3=0A=
-tx_mac_errors	tg3.h	/^	tg3_stat64_t			tx_mac_errors;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_mcast_packets	tg3.h	/^	tg3_stat64_t			tx_mcast_packets;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_mode	tg3.h	/^	u32				tx_mode;$/;"	m	struct:tg3=0A=
-tx_mult_collisions	tg3.h	/^	tg3_stat64_t			tx_mult_collisions;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_octets	tg3.h	/^	tg3_stat64_t			tx_octets;$/;"	m	struct:tg3_hw_stats=0A=
-tx_pending	tg3.h	/^	u32				tx_pending;$/;"	m	struct:tg3=0A=
-tx_prod	tg3.h	/^	u32				tx_prod;$/;"	m	struct:tg3=0A=
-tx_ring	tg3.h	/^	struct tg3_tx_buffer_desc	*tx_ring;$/;"	m	struct:tg3=0A=
-tx_ring_info	tg3.h	/^struct tx_ring_info {$/;"	s=0A=
-tx_single_collisions	tg3.h	/^	tg3_stat64_t			tx_single_collisions;$/;"	=
m	struct:tg3_hw_stats=0A=
-tx_ucast_packets	tg3.h	/^	tg3_stat64_t			tx_ucast_packets;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_xoff_sent	tg3.h	/^	tg3_stat64_t			tx_xoff_sent;$/;"	m	=
struct:tg3_hw_stats=0A=
-tx_xon_sent	tg3.h	/^	tg3_stat64_t			tx_xon_sent;$/;"	m	=
struct:tg3_hw_stats=0A=
-txconfig	tg3.c	/^	u32 txconfig, rxconfig;$/;"	m	=
struct:tg3_fiber_aneginfo	file:=0A=
-type_flags	tg3.h	/^	u32				type_flags;$/;"	m	struct:tg3_rx_buffer_desc=0A=
-vlan_tag	tg3.h	/^	u32				vlan_tag;$/;"	m	struct:tg3_tx_buffer_desc=0A=
-vlgrp	tg3.h	/^	struct vlan_group		*vlgrp;$/;"	m	struct:tg3=0A=
diff -urN vanilla-linux/include/linux/pci_ids.h =
vanilla-linux-patch/include/linux/pci_ids.h=0A=
--- vanilla-linux/include/linux/pci_ids.h	2003-10-26 00:13:29.000000000 =
+0530=0A=
+++ vanilla-linux-patch/include/linux/pci_ids.h	2004-03-15 =
11:23:43.000000000 +0530=0A=
@@ -1817,6 +1817,10 @@=0A=
 #define PCI_DEVICE_ID_ALTIMA_AC9100	0x03ea=0A=
 #define PCI_DEVICE_ID_ALTIMA_AC1003	0x03eb=0A=
 =0A=
+#define PCI_VENDOR_ID_S2IO		0x17d5=0A=
+#define	PCI_DEVICE_ID_S2IO_WIN		0x5731=0A=
+#define	PCI_DEVICE_ID_S2IO_UNI		0x5831=0A=
+=0A=
 #define PCI_VENDOR_ID_SYMPHONY		0x1c1c=0A=
 #define PCI_DEVICE_ID_SYMPHONY_101	0x0001=0A=
 =0A=

------=_NextPart_000_0011_01C40DF1.C4A084B0--
