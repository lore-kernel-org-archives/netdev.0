From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: Submission #3  for S2io 10GbE driver
Date: Sat, 28 Feb 2004 07:08:11 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <000001c3fe0c$af99c9e0$0300a8c0@S2IOtech.com>
References: <20040217001111.A23086@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_0001_01C3FDC9.A17689E0"
Cc: "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Stephen Hemminger'" <shemminger@osdl.org>,
        "'Christoph Hellwig'" <hch@infradead.org>,
        "'ravinandan arakali'" <ravinandan.arakali@s2io.com>,
        <raghavendra.koushik@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
In-Reply-To: <20040217001111.A23086@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_0001_01C3FDC9.A17689E0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi all,
Attached is a patch file for the driver that addresses (hopefully :-))
all the comments we received for the submission #2. 
As always, thanks for everybody who took the time and effort to suggest
improvements to our code.

This consists of a S2io folder in the ~/drivers/net folder and an
enhanced 
Kconfig file also in the same folder. The Kconfig file now reflects the
S2IO and S2IO_NAPI config 
and help details. Also the s2io source files in the s2io folder no
longer contain the CVS messages 
that get inserted during CVS commits. 

As a side note, we've done more performance testing on the 2.6 kernel
and I'd like to retract my earlier comment about marginal benefits of
Linux TSO support. 
At least with the latest kernel, we are getting extra ~8% transmit
performance with large send offload; this is very much in line with
results on other operating systems.

Regards, Leonid

------=_NextPart_000_0001_01C3FDC9.A17689E0
Content-Type: application/octet-stream;
	name="s2ioDriver.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="s2ioDriver.patch"

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
+++ vanilla-linux-patch/drivers/net/s2io/Makefile	2004-02-27 =
20:26:50.000000000 +0530=0A=
@@ -0,0 +1,91 @@=0A=
+#!/usr/bin/make=0A=
+# Makefile for building Linux S2io 10Gigabit ethernet driver as a =
module.=0A=
+=0A=
+# PREFIX may be set by the RPM build to set the effective root.=0A=
+PREFIX=3D=0A=
+ifeq ($(shell ls /lib/modules/`uname -r`/build > /dev/null 2>&1 && echo =
build),)=0A=
+  ifeq ($(shell ls /usr/src/linux > /dev/null 2>&1 && echo linux),)=0A=
+    LINUX=3D=0A=
+  else=0A=
+    LINUX=3D/usr/src/linux=0A=
+  endif=0A=
+else=0A=
+  LINUX=3D/lib/modules/`uname -r`/build=0A=
+endif=0A=
+=0A=
+ifeq ($(LINUX),)=0A=
+  $(error Linux kernel source tree not found)=0A=
+endif=0A=
+=0A=
+CC =3D gcc=0A=
+LD =3D ld=0A=
+=0A=
+=0A=
+INCLUDEDIR:=3D$(shell uname -r | sed 's/\([0-9]*\.[0-9]*\)\..*/\1/')=0A=
+=0A=
+ARCH:=3D$(shell uname -m)=0A=
+=0A=
+ifeq ($(INCLUDEDIR),2.6)=0A=
+=0A=
+ifneq ($(KERNELRELEASE), )=0A=
+obj-m :=3D s2io.o=0A=
+=0A=
+else=0A=
+KDIR :=3D /lib/modules/$(shell uname -r)/build=0A=
+PWD :=3D $(shell pwd)=0A=
+default:=0A=
+	@echo Build on Linux-$(INCLUDEDIR);=0A=
+	$(MAKE) -C $(KDIR) SUBDIRS=3D$(PWD) modules=0A=
+endif=0A=
+endif=0A=
+=0A=
+ifeq ($(INCLUDEDIR),2.4)=0A=
+# Default flags for ia64, alpha, x86_64, i686 & ppc64=0A=
+CFLAGS=3D -DMODULE -D__KERNEL__ -I/usr/src/linux-$(INCLUDEDIR)/include =
-Wall\=0A=
+ -Wstrict-prototypes -O2=0A=
+=0A=
+ifeq ($(ARCH),alpha)=0A=
+CFLAGS+=3D-ffixed-8 -mno-fp-regs -pipe -O2=0A=
+endif=0A=
+=0A=
+ifeq ($(ARCH),ppc64)=0A=
+CC =3D /opt/cross/bin/powerpc64-linux-gcc=0A=
+LD =3D /opt/cross/bin/powerpc64-linux-ld=0A=
+endif=0A=
+=0A=
+ifeq ($(ARCH),ia64)=0A=
+endif=0A=
+=0A=
+ifeq ($(ARCH),x86_64)=0A=
+CFLAGS+=3D -mcmodel=3Dkernel=0A=
+endif=0A=
+=0A=
+#ifeq ($(ARCH),i686)=0A=
+#endif=0A=
+=0A=
+all: s2io.o=0A=
+	@echo Build on Linux-$(INCLUDEDIR);=0A=
+	=0A=
+s2io.o: s2io.h=0A=
+=0A=
+install: s2io.o=0A=
+	@echo Install on Linux-$(INCLUDEDIR);=0A=
+	@if [ -d $(PREFIX)/lib/modules/`uname -r`/kernel/drivers/net/s2io ];\=0A=
+	then install -m 444 s2io.o $(PREFIX)/lib/modules/`uname =
-r`/kernel/drivers/net/s2io;\=0A=
+	elif [ -d $(PREFIX)/lib/modules/`uname -r`/kernel/drivers/net ];\=0A=
+	then install -m 444 s2io.o $(PREFIX)/lib/modules/`uname =
-r`/kernel/drivers/net;\=0A=
+	fi=0A=
+	@if [ "$(PREFIX)" =3D "" ]; then /sbin/depmod -a ;\=0A=
+	else echo " *** Run '/sbin/depmod -a' to update the module database.";\=0A=
+	fi=0A=
+=0A=
+.PHONEY: all clean install=0A=
+=0A=
+endif=0A=
+=0A=
+clean:=0A=
+	@echo Clean on Linux-$(INCLUDEDIR);=0A=
+	@if [ "$(INCLUDEDIR)" =3D "2.4" ]; then /bin/rm -f s2io.o;\=0A=
+	elif [ "$(INCLUDEDIR)" =3D "2.6" ]; then /bin/rm -f s2io.o s2io.mod.c =
s2io.mod.o s2io.ko;\=0A=
+	fi=0A=
+ =0A=
diff -urN vanilla-linux/drivers/net/s2io/README.txt =
vanilla-linux-patch/drivers/net/s2io/README.txt=0A=
--- vanilla-linux/drivers/net/s2io/README.txt	1970-01-01 =
05:30:00.000000000 +0530=0A=
+++ vanilla-linux-patch/drivers/net/s2io/README.txt	2004-02-27 =
20:26:50.000000000 +0530=0A=
@@ -0,0 +1,55 @@=0A=
+1. If jumbo frames are being used, with MTU sizes in excess of 1500 =
bytes the=20
+Tx/Rx side coalescing has to be varied.=20
+For an MTU size of 9600 the coalescing parametes which can be used are,
+
+For Tx interrupts.
+
+	% Bandwidth used	No of Packets per interrupt.
+------------------------------------------------------------
+i.	0 - 10				1
+ii.	10 - 15				2
+iii.	15 - 40				2
+iv.	40 - 100			4
+
+For Rx side,
+
+	% Bandwidth used	No of Packets per interrupt.
+------------------------------------------------------------
+i. 	0 - 10				1
+ii. 	10 - 15				2
+iii. 	15 - 40				4
+iv. 	40 - 100			8
+
+2. The Util is a utility that can be used to look into the Register =
space of the NIC and also to dump some data from the driver. The util.c =
basically makes=20
+IOCTL calls to the device to extract this info, so the device name =
variable in=20
+the code has to be changed appropriately and recompiled (using bd =
script)=20
+before using this tool.
+
+3. When loaded as a module, the driver provides a host of Module =
loadable
+parameters, so the device can be tuned as per the users needs.
+A list of the Module params is given below.
+	(i)		ring_num: This can be used to program the number of receive=20
+			rings used in the driver.
+	(ii)	ring_len: This defines the number of descriptors each ring can =
have.
+			There can be a maximum of 8 rings.
+	(iii)	frame_len: This is an array of size 8. Using this we can set the =

+			maximum size of the received frame that can be steered=20
+ 			into the corrsponding receive ring.=09
+  	(iv)	fifo_num: This defines the number of Tx FIFOs thats used in the =

+			driver.=20
+ 	(v)		fifo_len: Each element defines the number of=20
+ 			Tx descriptors that can be associated with each corresponding FIFO.
+			There are a maximum of 8 FIFOs.
+	(vi)	tx_prio: This is a bool, if module is loaded with a non-zero
+			value for tx_prio multi FIFO scheme is activated.
+	(vii)	rx_prio: This is a bool, if module is loaded with a non-zero
+			value for tx_prio multi RING scheme is activated.
+	(viii)	latency_timer: The value given against this param will be =
loaded
+			into the latency timer register in PCI Config space, else
+			the register is left with its reset value.
+
+BUILD INSTRUCTIONS.
+A make file is provided.  It will detect IA32,IA64,Opteron,POWERPC-64=20
+platforms. It can also detect 2.4/2.6 kernel versions. Please note, for =
2.4
+kernel, you need to load "s2io.o" and for 2.6 platforms you need to =
load
+"s2io.ko".=20
diff -urN vanilla-linux/drivers/net/s2io/regs.h =
vanilla-linux-patch/drivers/net/s2io/regs.h=0A=
--- vanilla-linux/drivers/net/s2io/regs.h	1970-01-01 05:30:00.000000000 =
+0530=0A=
+++ vanilla-linux-patch/drivers/net/s2io/regs.h	2004-02-27 =
20:48:16.000000000 +0530=0A=
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
+++ vanilla-linux-patch/drivers/net/s2io/s2io.c	2004-02-27 =
20:47:52.000000000 +0530=0A=
@@ -0,0 +1,4436 @@=0A=
+/***********************************************************************=
*=0A=
+ * s2io.c: A Linux PCI-X Ethernet driver for S2IO 10GbE Server NIC=0A=
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
+ *=0A=
+ *=0A=
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
+=0A=
+/* local include */=0A=
+#include "s2io.h"=0A=
+#include "regs.h"=0A=
+=0A=
+/* VENDOR and DEVICE ID of XENA. */=0A=
+#ifndef PCI_VENDOR_ID_S2IO=0A=
+#define PCI_VENDOR_ID_S2IO      0x17D5=0A=
+#define PCI_DEVICE_ID_S2IO_WIN  0x5731=0A=
+#define PCI_DEVICE_ID_S2IO_UNI  0x5831=0A=
+#endif=0A=
+=0A=
+/* S2io Driver name & version. */=0A=
+static char s2io_driver_name[] =3D "S2IO 10Gig driver";=0A=
+static char s2io_driver_version[] =3D "Version 1.0";=0A=
+=0A=
+/* Macros to ensure the code is backward compatible with 2.4.x kernels. =
*/=0A=
+#ifndef SET_NETDEV_DEV=0A=
+#define SET_NETDEV_DEV(a, b)	do {} while(0)=0A=
+#endif=0A=
+=0A=
+#ifndef HAVE_FREE_NETDEV=0A=
+#define free_netdev(x) kfree(x)=0A=
+#endif=0A=
+=0A=
+#ifndef IRQ_NONE=0A=
+typedef void irqreturn_t;=0A=
+#define	IRQ_NONE=0A=
+#define	IRQ_HANDLED=0A=
+#define	IRQ_RETVAL(x)=0A=
+#endif=0A=
+=0A=
+/*Prototype declaration of the used functions */=0A=
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
+/*Grisha */=0A=
+static void s2io_init_pci(nic_t * sp);=0A=
+int s2io_set_mac_addr(struct net_device *dev, u8 * addr);=0A=
+static irqreturn_t s2io_isr(int irq, void *dev_id, struct pt_regs =
*regs);=0A=
+static int verify_xena_quiescence(u64 val64, int flag);=0A=
+=0A=
+#ifdef SET_ETHTOOL_OPS=0A=
+static struct ethtool_ops netdev_ethtool_ops;=0A=
+#endif=0A=
+=0A=
+#define TASKLET_IN_USE test_and_set_bit(0, (unsigned long =
*)(&sp->tasklet_status))=0A=
+#define RST_TIMER_SCHEDULED test_and_set_bit(0, (unsigned long =
*)(&sp->rst_status))=0A=
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
+	    0xC0010100008000E4ULL,=0A=
+	/* Remove Reset from PMA PLL */=0A=
+	0xC001010000000000ULL, 0xC0010100000000E0ULL,=0A=
+	    0xC0010100000000E4ULL,=0A=
+	END_SIGN=0A=
+};=0A=
+=0A=
+static u64 default_dtx_cfg[] =3D {=0A=
+	0x8000051500000000ULL, 0x80000515000000E0ULL,=0A=
+	    0x80000515D93500E4ULL,=0A=
+	0x8001051500000000ULL, 0x80010515000000E0ULL,=0A=
+	    0x80010515001E00E4ULL,=0A=
+	0x8002051500000000ULL, 0x80020515000000E0ULL,=0A=
+	    0x80020515F21000E4ULL,=0A=
+	/* Set PADLOOPBACKN */=0A=
+	0x8002051500000000ULL, 0x80020515000000E0ULL,=0A=
+	    0x80020515B20000E4ULL,=0A=
+	0x8003051500000000ULL, 0x80030515000000E0ULL,=0A=
+	    0x80030515B20000E4ULL,=0A=
+	0x8004051500000000ULL, 0x80040515000000E0ULL,=0A=
+	    0x80040515B20000E4ULL,=0A=
+	0x8005051500000000ULL, 0x80050515000000E0ULL,=0A=
+	    0x80050515B20000E4ULL,=0A=
+	SWITCH_SIGN,=0A=
+	/* Remove PADLOOPBACKN */=0A=
+	0x8002051500000000ULL, 0x80020515000000E0ULL,=0A=
+	    0x80020515F20000E4ULL,=0A=
+	0x8003051500000000ULL, 0x80030515000000E0ULL,=0A=
+	    0x80030515F20000E4ULL,=0A=
+	0x8004051500000000ULL, 0x80040515000000E0ULL,=0A=
+	    0x80040515F20000E4ULL,=0A=
+	0x8005051500000000ULL, 0x80050515000000E0ULL,=0A=
+	    0x80050515F20000E4ULL,=0A=
+	END_SIGN=0A=
+};=0A=
+=0A=
+=0A=
+static u64 oldphy_mdio_cfg[] =3D {=0A=
+	0x0018040000000000ULL, 0x00180400000000E0ULL,=0A=
+	    0x00180400000000ECULL,=0A=
+	SWITCH_SIGN,=0A=
+	0x0018040000000000ULL, 0x00180400000000E0ULL,=0A=
+	    0x00180400000000ECULL,=0A=
+	END_SIGN=0A=
+};=0A=
+=0A=
+static u64 oldphy_dtx_cfg[] =3D {=0A=
+	0x8000051500000000ULL, 0x80000515000000E0ULL,=0A=
+	    0x80000515D93500E4ULL,=0A=
+	0x8001051500000000ULL, 0x80010515000000E0ULL,=0A=
+	    0x80010515001E00E4ULL,=0A=
+	0x8002051500000000ULL, 0x80020515000000E0ULL,=0A=
+	    0x80020515F21000E4ULL,=0A=
+	0x8000051500000000ULL, 0x80000515000000E0ULL,=0A=
+	    0x80000515D93500ECULL,=0A=
+	0x8001051500000000ULL, 0x80010515000000E0ULL,=0A=
+	    0x80010515000000ECULL,=0A=
+	0x8002051500000000ULL, 0x80020515000000E0ULL,=0A=
+	    0x80020515000000ECULL,=0A=
+	SWITCH_SIGN,=0A=
+	0x0000051500000000ULL, 0x00000515604000E0ULL,=0A=
+	    0x00000515604000E4ULL,=0A=
+	0x00000515204000E4ULL, 0x00000515204000ECULL,=0A=
+	END_SIGN=0A=
+};=0A=
+=0A=
+/* Module Loadable parameters. */=0A=
+static u32 ring_num;=0A=
+static u32 frame_len[MAX_RX_RINGS];=0A=
+static u32 ring_len[MAX_RX_RINGS];=0A=
+static u32 fifo_num;=0A=
+static u32 fifo_len[MAX_TX_FIFOS];=0A=
+static u32 rx_prio;=0A=
+static u32 tx_prio;=0A=
+static u8 latency_timer =3D 0xff;=0A=
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
+/* Allocation and initialization of TXDLs in FIOFs */=0A=
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
+		  (unsigned long long)tmp_p_addr);=0A=
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
+/* Allocation and initialization of RXDs in Rings */=0A=
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
+				/* In case of failure, freeSharedMem() is called, which should=0A=
+				 * free any memory that was alloced till the failure happened.=0A=
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
+/* Allocation and initialization of Statistics block */=0A=
+	size =3D sizeof(StatInfo_t);=0A=
+	mac_control->stats_mem =3D pci_alloc_consistent=0A=
+	    (nic->pdev, size, &mac_control->stats_mem_phy);=0A=
+=0A=
+	if (!mac_control->stats_mem) {=0A=
+		/* In case of failure, freeSharedMem() is called, which should=0A=
+		 * free any memory that was alloced till the failure happened.=0A=
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
+		  (unsigned long long)tmp_p_addr);=0A=
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
+	u32 time, mem_share;=0A=
+	int i, j;=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+	int mdio_cnt =3D 0, dtx_cnt =3D 0;=0A=
+	unsigned long long print_var;=0A=
+=0A=
+	mac_control =3D &nic->mac_control;=0A=
+	config =3D &nic->config;=0A=
+=0A=
+/*  Set proper endian settings and verify the same by reading the PIF =0A=
+Feed-back register */=0A=
+#ifdef  __BIG_ENDIAN=0A=
+/* The device by default set to a big endian format, so a big endian=0A=
+ * driver need not set anything.=0A=
+ */=0A=
+	write64(&bar0->swapper_ctrl, 0xffffffffffffffffULL);=0A=
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
+	write64(&bar0->swapper_ctrl, val64);=0A=
+#else=0A=
+/* Initially we enable all bits to make it accessible by the driver,=0A=
+ * then we selectively enable only those bits that we want to set.=0A=
+ */=0A=
+	write64(&bar0->swapper_ctrl, 0xffffffffffffffffULL);=0A=
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
+	write64(&bar0->swapper_ctrl, val64);=0A=
+#endif=0A=
+=0A=
+/*  Verifying if endian settings are accurate by reading a feedback=0A=
+ *  register.=0A=
+ */=0A=
+	val64 =3D read64(&bar0->pif_rd_swapper_fb);=0A=
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
+/* Remove XGXS from reset state*/=0A=
+	val64 =3D 0;=0A=
+	write64(&bar0->sw_reset, val64);=0A=
+	set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+	schedule_timeout(HZ / 2);=0A=
+=0A=
+/* Need to set correct values in the following PIC Control registers =0A=
+ * 1. PIC Control=0A=
+ * 2. Tx request timeout=0A=
+ * 3. Stats request timeout=0A=
+ * 4. Read retry delay=0A=
+ * 5. Read retry acclereration=0A=
+ * 6. Write retry delay=0A=
+ * 7. Write retry acclereration=0A=
+ */=0A=
+=0A=
+/*  Enable Receiving broadcasts */=0A=
+	val64 =3D read64(&bar0->mac_cfg);=0A=
+	val64 |=3D MAC_RMAC_BCAST_ENABLE;=0A=
+	write64(&bar0->rmac_cfg_key, RMAC_CFG_KEY(0x4C0D));=0A=
+	write64(&bar0->mac_cfg, val64);=0A=
+=0A=
+/* Read registers in all blocks */=0A=
+	val64 =3D read64(&bar0->mac_int_mask);=0A=
+	val64 =3D read64(&bar0->mc_int_mask);=0A=
+	val64 =3D read64(&bar0->xgxs_int_mask);=0A=
+=0A=
+/*  Set MTU */=0A=
+	val64 =3D dev->mtu;=0A=
+	write64(&bar0->rmac_max_pyld_len, vBIT(val64, 2, 14));=0A=
+=0A=
+/* Configuring the XAUI Interface of Xena. =0A=
+ *****************************************=0A=
+ * To Configure the Xena's XAUI, one has to write a series of 64 bit =0A=
+ * values into two registers in a particular sequence.=0A=
+ * Hence a macro 'SWITCH_SIGN' has been defined which will be defined in=0A=
+ * the array of configuration values (default_dtx_cfg & =
default_mdio_cfg)=0A=
+ * at appropriate places to switch writing from one regsiter to another.=0A=
+ * We continue writing these values until we encounter the 'END_SIGN' =
macro.=0A=
+ * For example, After making a series of 21 writes into dtx_control =
register=0A=
+ * the 'SWITCH_SIGN' appears and hence we start writing into =
mdio_control =0A=
+ * until we encounter END_SIGN.=0A=
+ */=0A=
+	while (1) {=0A=
+	      dtx_cfg:=0A=
+		while (default_dtx_cfg[dtx_cnt] !=3D END_SIGN) {=0A=
+			if (default_dtx_cfg[dtx_cnt] =3D=3D SWITCH_SIGN) {=0A=
+				dtx_cnt++;=0A=
+				goto mdio_cfg;=0A=
+			}=0A=
+			write64(&bar0->dtx_control,=0A=
+				default_dtx_cfg[dtx_cnt]);=0A=
+			val64 =3D read64(&bar0->dtx_control);=0A=
+			dtx_cnt++;=0A=
+		}=0A=
+	      mdio_cfg:=0A=
+		while (default_mdio_cfg[mdio_cnt] !=3D END_SIGN) {=0A=
+			if (default_mdio_cfg[mdio_cnt] =3D=3D SWITCH_SIGN) {=0A=
+				mdio_cnt++;=0A=
+				goto dtx_cfg;=0A=
+			}=0A=
+			write64(&bar0->mdio_control,=0A=
+				default_mdio_cfg[mdio_cnt]);=0A=
+			val64 =3D read64(&bar0->mdio_control);=0A=
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
+/*  Tx DMA Initialization */=0A=
+	val64 =3D 0;=0A=
+	write64(&bar0->tx_fifo_partition_0, val64);=0A=
+	write64(&bar0->tx_fifo_partition_1, val64);=0A=
+	write64(&bar0->tx_fifo_partition_2, val64);=0A=
+	write64(&bar0->tx_fifo_partition_3, val64);=0A=
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
+			write64(&bar0->tx_fifo_partition_0, val64);=0A=
+			val64 =3D 0;=0A=
+			break;=0A=
+		case 3:=0A=
+			write64(&bar0->tx_fifo_partition_1, val64);=0A=
+			val64 =3D 0;=0A=
+			break;=0A=
+		case 5:=0A=
+			write64(&bar0->tx_fifo_partition_2, val64);=0A=
+			val64 =3D 0;=0A=
+			break;=0A=
+		case 7:=0A=
+			write64(&bar0->tx_fifo_partition_3, val64);=0A=
+			break;=0A=
+		}=0A=
+	}=0A=
+=0A=
+/* Enable Tx FIFO partition 0. */=0A=
+	val64 =3D read64(&bar0->tx_fifo_partition_0);=0A=
+	val64 |=3D BIT(0);	/* To enable the FIFO partition. */=0A=
+	write64(&bar0->tx_fifo_partition_0, val64);=0A=
+=0A=
+	val64 =3D read64(&bar0->tx_fifo_partition_0);=0A=
+	DBG_PRINT(INIT_DBG, "Fifo partition at: 0x%p is: 0x%llx\n",=0A=
+		  &bar0->tx_fifo_partition_0, (unsigned long long)val64);=0A=
+=0A=
+/* Initialization of Tx_PA_CONFIG register to ignore packet integrity =0A=
+ * checking.=0A=
+ */=0A=
+	val64 =3D read64(&bar0->tx_pa_cfg);=0A=
+	val64 |=3D TX_PA_CFG_IGNORE_FRM_ERR | TX_PA_CFG_IGNORE_SNAP_OUI |=0A=
+	    TX_PA_CFG_IGNORE_LLC_CTRL | TX_PA_CFG_IGNORE_L2_ERR;=0A=
+	write64(&bar0->tx_pa_cfg, val64);=0A=
+=0A=
+/* Rx DMA intialization. */=0A=
+	val64 =3D 0;=0A=
+	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
+		val64 |=3D=0A=
+		    vBIT(config->RxCfg[i].RingPriority, (5 + (i * 8)), 3);=0A=
+	}=0A=
+	write64(&bar0->rx_queue_priority, val64);=0A=
+=0A=
+/* Allocating equal share of memory to all the configured Rings. */=0A=
+#if 1=0A=
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
+	val64 =3D RX_QUEUE_CFG_Q0_SZ(64);=0A=
+	write64(&bar0->rx_queue_cfg, val64);=0A=
+#else=0A=
+	val64 =3D RX_QUEUE_CFG_Q0_SZ(64);=0A=
+	write64(&bar0->rx_queue_cfg, val64);	/* Setting Q0 with all RLDRAM =0A=
+						 * space.=0A=
+						 */=0A=
+#endif=0A=
+=0A=
+/* Initializing the Tx round robin registers to 0.=0A=
+ * Filling Tx and Rx round robin registers as per the number of FIFOs =
and=0A=
+ * Rings is still TODO.=0A=
+ */=0A=
+	write64(&bar0->tx_w_round_robin_0, 0);=0A=
+	write64(&bar0->tx_w_round_robin_1, 0);=0A=
+	write64(&bar0->tx_w_round_robin_2, 0);=0A=
+	write64(&bar0->tx_w_round_robin_3, 0);=0A=
+	write64(&bar0->tx_w_round_robin_4, 0);=0A=
+=0A=
+/* Disable Rx steering. Hard coding all packets be steered to=0A=
+ * Queue 0 for now. =0A=
+ * TODO*/=0A=
+	if (rx_prio) {=0A=
+		u64 def =3D 0x8000000000000000ULL, tmp;=0A=
+		for (i =3D 0; i < MAX_RX_RINGS; i++) {=0A=
+			tmp =3D (u64) (def >> (i % config->RxRingNum));=0A=
+			val64 |=3D (u64) (tmp >> (i * 8));=0A=
+		}=0A=
+		write64(&bar0->rts_qos_steering, val64);=0A=
+	} else {=0A=
+		val64 =3D 0x8080808080808080ULL;=0A=
+		write64(&bar0->rts_qos_steering, val64);=0A=
+	}=0A=
+=0A=
+/* Disable the device from passing packets with L/T mismatch to the =
host.*/=0A=
+	val64 =3D read64(&bar0->rmac_err_cfg);=0A=
+	val64 &=3D ~RMAC_ERR_LEN_MISMATCH;=0A=
+	write64(&bar0->rmac_err_cfg, val64);=0A=
+=0A=
+/* UDP Fix */=0A=
+	val64 =3D 0;=0A=
+	for (i =3D 1; i < 8; i++)=0A=
+		write64(&bar0->rts_frm_len_n[i], val64);=0A=
+=0A=
+/* Set rts_frm_len register for fifo 0 */=0A=
+	write64(&bar0->rts_frm_len_n[0],=0A=
+		MAC_RTS_FRM_LEN_SET((dev->mtu) + 22));=0A=
+=0A=
+=0A=
+=0A=
+/* Enable statistics */=0A=
+	write64(&bar0->stat_addr, (u64) mac_control->stats_mem_phy);=0A=
+	val64 =3D SET_UPDT_PERIOD(8) | STAT_CFG_STAT_RO | STAT_CFG_STAT_EN;=0A=
+	write64(&bar0->stat_cfg, val64);=0A=
+=0A=
+/* Initializing the sampling rate for the device to calculate the=0A=
+ * bandwidth utilization.=0A=
+ */=0A=
+	val64 =3D MAC_TX_LINK_UTIL_VAL(0x5) | MAC_RX_LINK_UTIL_VAL(0x5);=0A=
+	write64(&bar0->mac_link_util, val64);=0A=
+=0A=
+/* Initializing the Transmit and Receive Traffic Interrupt Scheme */=0A=
+=0A=
+/* TTI Initialization */=0A=
+	val64 =3D TTI_DATA1_MEM_TX_TIMER_VAL(0xFFF) |=0A=
+	    TTI_DATA1_MEM_TX_URNG_A(0xA) | TTI_DATA1_MEM_TX_URNG_B(0x10) |=0A=
+	    TTI_DATA1_MEM_TX_URNG_C(0x30) | TTI_DATA1_MEM_TX_TIMER_AC_EN;=0A=
+	write64(&bar0->tti_data1_mem, val64);=0A=
+=0A=
+	val64 =3D=0A=
+	    TTI_DATA2_MEM_TX_UFC_A(0x10) | TTI_DATA2_MEM_TX_UFC_B(0x20) |=0A=
+	    TTI_DATA2_MEM_TX_UFC_C(0x40) | TTI_DATA2_MEM_TX_UFC_D(0x80);=0A=
+	write64(&bar0->tti_data2_mem, val64);=0A=
+=0A=
+	val64 =3D TTI_CMD_MEM_WE | TTI_CMD_MEM_STROBE_NEW_CMD;=0A=
+	write64(&bar0->tti_command_mem, val64);=0A=
+/*  Wait for the operation to complete */=0A=
+	time =3D 0;=0A=
+	while (TRUE) {=0A=
+		val64 =3D read64(&bar0->tti_command_mem);=0A=
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
+/* RTI Initialization */=0A=
+	val64 =3D RTI_DATA1_MEM_RX_TIMER_VAL(0xFFF) |=0A=
+	    RTI_DATA1_MEM_RX_URNG_A(0xA) | RTI_DATA1_MEM_RX_URNG_B(0x10) |=0A=
+	    RTI_DATA1_MEM_RX_URNG_C(0x30) | RTI_DATA1_MEM_RX_TIMER_AC_EN;=0A=
+	write64(&bar0->rti_data1_mem, val64);=0A=
+=0A=
+	val64 =3D RTI_DATA2_MEM_RX_UFC_A(0x1) | RTI_DATA2_MEM_RX_UFC_B(0x2) |=0A=
+	    RTI_DATA2_MEM_RX_UFC_C(0x40) | RTI_DATA2_MEM_RX_UFC_D(0x80);=0A=
+	write64(&bar0->rti_data2_mem, val64);=0A=
+=0A=
+	val64 =3D RTI_CMD_MEM_WE | RTI_CMD_MEM_STROBE_NEW_CMD;=0A=
+	write64(&bar0->rti_command_mem, val64);=0A=
+=0A=
+/*  Wait for the operation to complete */=0A=
+	time =3D 0;=0A=
+	while (TRUE) {=0A=
+		val64 =3D read64(&bar0->rti_command_mem);=0A=
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
+/*  Initializing proper values as Pause threshold into all the 8 Queues =0A=
+ *  on Rx side.=0A=
+ */=0A=
+	write64(&bar0->mc_pause_thresh_q0q3, 0xffbbffbbffbbffbbULL);=0A=
+	write64(&bar0->mc_pause_thresh_q4q7, 0xffbbffbbffbbffbbULL);=0A=
+=0A=
+/* Disable RMAC PAD STRIPPING */=0A=
+	add =3D (void *) &bar0->mac_cfg;=0A=
+	val64 =3D read64(&bar0->mac_cfg);=0A=
+	val64 &=3D ~(MAC_CFG_RMAC_STRIP_PAD);=0A=
+	write64(&bar0->rmac_cfg_key, RMAC_CFG_KEY(0x4C0D));=0A=
+	writel((u32) (val64), add);=0A=
+	write64(&bar0->rmac_cfg_key, RMAC_CFG_KEY(0x4C0D));=0A=
+	writel((u32) (val64 >> 32), (add + 4));=0A=
+	val64 =3D read64(&bar0->mac_cfg);=0A=
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
+/*  Top level interrupt classification */=0A=
+/*  PIC Interrupts */=0A=
+	if ((mask & (TX_PIC_INTR | RX_PIC_INTR))) {=0A=
+		/*  Enable PIC Intrs in the general intr mask register */=0A=
+		val64 =3D TXPIC_INT_M | PIC_RX_INT_M;=0A=
+		if (flag =3D=3D ENABLE_INTRS) {=0A=
+			temp64 =3D read64(&bar0->general_int_mask);=0A=
+			temp64 &=3D ~((u64) val64);=0A=
+			write64(&bar0->general_int_mask, temp64);=0A=
+			/*  Disabled all PCIX, Flash, MDIO, IIC and GPIO=0A=
+			 *  interrupts for now. =0A=
+			 * TODO */=0A=
+			write64(&bar0->pic_int_mask, DISABLE_ALL_INTRS);=0A=
+			/*  No MSI Support is available presently, so TTI and=0A=
+			 * RTI interrupts are also disabled.=0A=
+			 */=0A=
+		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
+			/*  Disable PIC Intrs in the general intr mask register =0A=
+			 */=0A=
+			write64(&bar0->pic_int_mask, DISABLE_ALL_INTRS);=0A=
+			temp64 =3D read64(&bar0->general_int_mask);=0A=
+			val64 |=3D temp64;=0A=
+			write64(&bar0->general_int_mask, val64);=0A=
+		}=0A=
+	}=0A=
+=0A=
+/*  DMA Interrupts */=0A=
+/*  Enabling/Disabling Tx DMA interrupts */=0A=
+	if (mask & TX_DMA_INTR) {=0A=
+		/*  Enable TxDMA Intrs in the general intr mask register */=0A=
+		val64 =3D TXDMA_INT_M;=0A=
+		if (flag =3D=3D ENABLE_INTRS) {=0A=
+			temp64 =3D read64(&bar0->general_int_mask);=0A=
+			temp64 &=3D ~((u64) val64);=0A=
+			write64(&bar0->general_int_mask, temp64);=0A=
+			/* Disable all interrupts other than PFC interrupt in =0A=
+			 * DMA level.=0A=
+			 */=0A=
+			val64 =3D DISABLE_ALL_INTRS & (~TXDMA_PFC_INT_M);=0A=
+			write64(&bar0->txdma_int_mask, val64);=0A=
+			/* Enable only the MISC error 1 interrupt in PFC block =0A=
+			 */=0A=
+			val64 =3D DISABLE_ALL_INTRS & (~PFC_MISC_ERR_1);=0A=
+			write64(&bar0->pfc_err_mask, val64);=0A=
+		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
+			/*  Disable TxDMA Intrs in the general intr mask =0A=
+			 *  register */=0A=
+			write64(&bar0->txdma_int_mask, DISABLE_ALL_INTRS);=0A=
+			write64(&bar0->pfc_err_mask, DISABLE_ALL_INTRS);=0A=
+			temp64 =3D read64(&bar0->general_int_mask);=0A=
+			val64 |=3D temp64;=0A=
+			write64(&bar0->general_int_mask, val64);=0A=
+		}=0A=
+	}=0A=
+=0A=
+/*  Enabling/Disabling Rx DMA interrupts */=0A=
+	if (mask & RX_DMA_INTR) {=0A=
+		/*  Enable RxDMA Intrs in the general intr mask register */=0A=
+		val64 =3D RXDMA_INT_M;=0A=
+		if (flag =3D=3D ENABLE_INTRS) {=0A=
+			temp64 =3D read64(&bar0->general_int_mask);=0A=
+			temp64 &=3D ~((u64) val64);=0A=
+			write64(&bar0->general_int_mask, temp64);=0A=
+			/* All RxDMA block interrupts are disabled for now =0A=
+			 * TODO */=0A=
+			write64(&bar0->rxdma_int_mask, DISABLE_ALL_INTRS);=0A=
+		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
+			/*  Disable RxDMA Intrs in the general intr mask =0A=
+			 *  register */=0A=
+			write64(&bar0->rxdma_int_mask, DISABLE_ALL_INTRS);=0A=
+			temp64 =3D read64(&bar0->general_int_mask);=0A=
+			val64 |=3D temp64;=0A=
+			write64(&bar0->general_int_mask, val64);=0A=
+		}=0A=
+	}=0A=
+=0A=
+/*  MAC Interrupts */=0A=
+/*  Enabling/Disabling MAC interrupts */=0A=
+	if (mask & (TX_MAC_INTR | RX_MAC_INTR)) {=0A=
+		val64 =3D TXMAC_INT_M | RXMAC_INT_M;=0A=
+		if (flag =3D=3D ENABLE_INTRS) {=0A=
+			temp64 =3D read64(&bar0->general_int_mask);=0A=
+			temp64 &=3D ~((u64) val64);=0A=
+			write64(&bar0->general_int_mask, temp64);=0A=
+			/* All MAC block error interrupts are disabled for now =0A=
+			 * except the link status change interrupt.=0A=
+			 * TODO*/=0A=
+			val64 =3D MAC_INT_STATUS_RMAC_INT;=0A=
+			temp64 =3D read64(&bar0->mac_int_mask);=0A=
+			temp64 &=3D ~((u64) val64);=0A=
+			write64(&bar0->mac_int_mask, temp64);=0A=
+=0A=
+			val64 =3D read64(&bar0->mac_rmac_err_mask);=0A=
+			val64 &=3D ~((u64) RMAC_LINK_STATE_CHANGE_INT);=0A=
+			write64(&bar0->mac_rmac_err_mask, val64);=0A=
+		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
+			/*  Disable MAC Intrs in the general intr mask register =0A=
+			 */=0A=
+			write64(&bar0->mac_int_mask, DISABLE_ALL_INTRS);=0A=
+			write64(&bar0->mac_rmac_err_mask,=0A=
+				DISABLE_ALL_INTRS);=0A=
+			temp64 =3D read64(&bar0->general_int_mask);=0A=
+			val64 |=3D temp64;=0A=
+			write64(&bar0->general_int_mask, val64);=0A=
+		}=0A=
+	}=0A=
+=0A=
+/*  XGXS Interrupts */=0A=
+	if (mask & (TX_XGXS_INTR | RX_XGXS_INTR)) {=0A=
+		val64 =3D TXXGXS_INT_M | RXXGXS_INT_M;=0A=
+		if (flag =3D=3D ENABLE_INTRS) {=0A=
+			temp64 =3D read64(&bar0->general_int_mask);=0A=
+			temp64 &=3D ~((u64) val64);=0A=
+			write64(&bar0->general_int_mask, temp64);=0A=
+			/* All XGXS block error interrupts are disabled for now=0A=
+			 *  TODO */=0A=
+			write64(&bar0->xgxs_int_mask, DISABLE_ALL_INTRS);=0A=
+		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
+			/*  Disable MC Intrs in the general intr mask register =0A=
+			 */=0A=
+			write64(&bar0->xgxs_int_mask, DISABLE_ALL_INTRS);=0A=
+			temp64 =3D read64(&bar0->general_int_mask);=0A=
+			val64 |=3D temp64;=0A=
+			write64(&bar0->general_int_mask, val64);=0A=
+		}=0A=
+	}=0A=
+=0A=
+/*  Memory Controller(MC) interrupts */=0A=
+	if (mask & MC_INTR) {=0A=
+		val64 =3D MC_INT_M;=0A=
+		if (flag =3D=3D ENABLE_INTRS) {=0A=
+			temp64 =3D read64(&bar0->general_int_mask);=0A=
+			temp64 &=3D ~((u64) val64);=0A=
+			write64(&bar0->general_int_mask, temp64);=0A=
+			/* All MC block error interrupts are disabled for now=0A=
+			 * TODO */=0A=
+			write64(&bar0->mc_int_mask, DISABLE_ALL_INTRS);=0A=
+		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
+			/*  Disable MC Intrs in the general intr mask register=0A=
+			 */=0A=
+			write64(&bar0->mc_int_mask, DISABLE_ALL_INTRS);=0A=
+			temp64 =3D read64(&bar0->general_int_mask);=0A=
+			val64 |=3D temp64;=0A=
+			write64(&bar0->general_int_mask, val64);=0A=
+		}=0A=
+	}=0A=
+=0A=
+=0A=
+/*  Tx traffic interrupts */=0A=
+	if (mask & TX_TRAFFIC_INTR) {=0A=
+		val64 =3D TXTRAFFIC_INT_M;=0A=
+		if (flag =3D=3D ENABLE_INTRS) {=0A=
+			temp64 =3D read64(&bar0->general_int_mask);=0A=
+			temp64 &=3D ~((u64) val64);=0A=
+			write64(&bar0->general_int_mask, temp64);=0A=
+			/* Enable all the Tx side interrupts */=0A=
+			write64(&bar0->tx_traffic_mask, 0x0);	/* '0' Enables =0A=
+								 * all 64 TX =0A=
+								 * interrupt =0A=
+								 * levels.=0A=
+								 */=0A=
+		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
+			/*  Disable Tx Traffic Intrs in the general intr mask =0A=
+			 *  register.=0A=
+			 */=0A=
+			write64(&bar0->tx_traffic_mask, DISABLE_ALL_INTRS);=0A=
+			temp64 =3D read64(&bar0->general_int_mask);=0A=
+			val64 |=3D temp64;=0A=
+			write64(&bar0->general_int_mask, val64);=0A=
+		}=0A=
+	}=0A=
+=0A=
+/*  Rx traffic interrupts */=0A=
+	if (mask & RX_TRAFFIC_INTR) {=0A=
+		val64 =3D RXTRAFFIC_INT_M;=0A=
+		if (flag =3D=3D ENABLE_INTRS) {=0A=
+			temp64 =3D read64(&bar0->general_int_mask);=0A=
+			temp64 &=3D ~((u64) val64);=0A=
+			write64(&bar0->general_int_mask, temp64);=0A=
+			write64(&bar0->rx_traffic_mask, 0x0);	/* '0' Enables =0A=
+								 * all 8 RX =0A=
+								 * interrupt =0A=
+								 * levels.=0A=
+								 */=0A=
+		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
+			/*  Disable Rx Traffic Intrs in the general intr mask =0A=
+			 *  register.=0A=
+			 */=0A=
+			write64(&bar0->rx_traffic_mask, DISABLE_ALL_INTRS);=0A=
+			temp64 =3D read64(&bar0->general_int_mask);=0A=
+			val64 |=3D temp64;=0A=
+			write64(&bar0->general_int_mask, val64);=0A=
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
+	int ret =3D FALSE;=0A=
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
+				ret =3D TRUE;=0A=
+=0A=
+			}=0A=
+		} else {=0A=
+			if (((val64 & ADAPTER_STATUS_RMAC_PCC_IDLE) =3D=3D=0A=
+			     ADAPTER_STATUS_RMAC_PCC_IDLE) &&=0A=
+			    (!(val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) ||=0A=
+			     ((val64 & ADAPTER_STATUS_RC_PRC_QUIESCENT) =3D=3D=0A=
+			      ADAPTER_STATUS_RC_PRC_QUIESCENT))) {=0A=
+=0A=
+				ret =3D TRUE;=0A=
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
+	int i;=0A=
+=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+=0A=
+	write64(&bar0->gpio_control, 0x0060000000000000ULL);=0A=
+	udelay(10);=0A=
+	write64(&bar0->gpio_control, 0x0060600000000000ULL);=0A=
+	udelay(10);=0A=
+=0A=
+/* Create start condition */=0A=
+	write64(&bar0->gpio_control, 0x0040600000000000ULL);=0A=
+	udelay(10);=0A=
+	write64(&bar0->gpio_control, 0x0000600000000000ULL);=0A=
+	udelay(10);=0A=
+	write64(&bar0->gpio_control, 0x0020600000000000ULL);=0A=
+	udelay(10);=0A=
+	write64(&bar0->gpio_control, 0x0060600000000000ULL);=0A=
+	udelay(10);=0A=
+=0A=
+/* Scan 9 consecutives ones */=0A=
+	for (i =3D 0; i < 9; i++) {=0A=
+		write64(&bar0->gpio_control, 0x0020600000000000ULL);=0A=
+		udelay(10);=0A=
+		write64(&bar0->gpio_control, 0x0060600000000000ULL);=0A=
+		udelay(10);=0A=
+	}=0A=
+=0A=
+/* Create stop condition */=0A=
+	write64(&bar0->gpio_control, 0x0020600000000000ULL);=0A=
+	udelay(10);=0A=
+	write64(&bar0->gpio_control, 0x0000600000000000ULL);=0A=
+	udelay(10);=0A=
+	write64(&bar0->gpio_control, 0x0040600000000000ULL);=0A=
+	udelay(10);=0A=
+	write64(&bar0->gpio_control, 0x0060600000000000ULL);=0A=
+	udelay(10);=0A=
+=0A=
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
+/*  PRC Initialization and configuration */=0A=
+	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
+		write64(&bar0->prc_rxd0_n[i],=0A=
+			(u64) nic->rx_blocks[i][0].block_dma_addr);=0A=
+		val64 =3D read64(&bar0->prc_ctrl_n[i]);=0A=
+		val64 |=3D PRC_CTRL_RC_ENABLED;=0A=
+		write64(&bar0->prc_ctrl_n[i], val64);=0A=
+	}=0A=
+=0A=
+/* Enabling MC-RLDRAM */=0A=
+	val64 =3D read64(&bar0->mc_rldram_mrs);=0A=
+	val64 |=3D MC_RLDRAM_QUEUE_SIZE_ENABLE | MC_RLDRAM_MRS_ENABLE;=0A=
+	write64(&bar0->mc_rldram_mrs, val64);=0A=
+	set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+	schedule_timeout(HZ / 10);=0A=
+=0A=
+/* Enabling ECC Protection. */=0A=
+	val64 =3D read64(&bar0->adapter_control);=0A=
+	val64 &=3D ~ADAPTER_ECC_EN;=0A=
+	write64(&bar0->adapter_control, val64);=0A=
+=0A=
+/* Clearing any possible Link state change interrupts that could have=0A=
+ * popped up just before Enabling the card.=0A=
+ */=0A=
+	val64 =3D read64(&bar0->mac_rmac_err_reg);=0A=
+	if (val64)=0A=
+		write64(&bar0->mac_rmac_err_reg, val64);=0A=
+=0A=
+/* Verify if the device is ready to be enabled, if so enable it. */=0A=
+	val64 =3D read64(&bar0->adapter_status);=0A=
+	if (verify_xena_quiescence(val64, nic->device_enabled_once) =3D=3D=0A=
+	    FALSE) {=0A=
+		DBG_PRINT(ERR_DBG, "%s: device is not ready, ", dev->name);=0A=
+		DBG_PRINT(ERR_DBG, "Adapter status reads: 0x%llx\n",=0A=
+			  (unsigned long long)val64);=0A=
+		return FAILURE;=0A=
+	}=0A=
+=0A=
+/*  Enable select interrupts */=0A=
+	interruptible =3D TX_TRAFFIC_INTR | RX_TRAFFIC_INTR | TX_MAC_INTR |=0A=
+	    RX_MAC_INTR;=0A=
+	en_dis_able_NicIntrs(nic, interruptible, ENABLE_INTRS);=0A=
+=0A=
+/* With some switches, link might be already up at this point.=0A=
+ * Because of this weird behavior, when we enable laser, =0A=
+ * we may not get link. We need to handle this. We cannot =0A=
+ * figure out which switch is misbehaving. So we are forced to =0A=
+ * make a global change. =0A=
+ */=0A=
+=0A=
+/* Enabling Laser. */=0A=
+	val64 =3D read64(&bar0->adapter_control);=0A=
+	val64 |=3D ADAPTER_EOI_TX_ON;=0A=
+	write64(&bar0->adapter_control, val64);=0A=
+=0A=
+	/* SXE-002: Initialize link and activity LED */=0A=
+	subid =3D nic->pdev->subsystem_device;=0A=
+	if ((subid & 0xFF) >=3D 0x07) {=0A=
+		val64 =3D read64(&bar0->gpio_control);=0A=
+		val64 |=3D 0x0000800000000000ULL;=0A=
+		write64(&bar0->gpio_control, val64);=0A=
+		val64 =3D 0x0411040400000000ULL;=0A=
+		write64((u64 *) ((u8 *) bar0 + 0x2700), val64);=0A=
+	}=0A=
+=0A=
+/* =0A=
+ * Here we are performing soft reset on XGXS to =0A=
+ * force link down. Since link is already up, we will get=0A=
+ * link state change interrupt after this reset=0A=
+ */=0A=
+=0A=
+	write64(&bar0->dtx_control, 0x8007051500000000ULL);=0A=
+	udelay(50);=0A=
+	write64(&bar0->dtx_control, 0x80070515000000E0ULL);=0A=
+	udelay(50);=0A=
+	write64(&bar0->dtx_control, 0x80070515001F00E4ULL);=0A=
+	udelay(50);=0A=
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
+		val64 =3D read64(&bar0->prc_ctrl_n[i]);=0A=
+		val64 &=3D ~((u64) PRC_CTRL_RC_ENABLED);=0A=
+		write64(&bar0->prc_ctrl_n[i], val64);=0A=
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
+	nic_t *nic =3D (nic_t *) dev->priv;=0A=
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
+	val64 =3D read64(&bar0->rx_traffic_int);=0A=
+	write64(&bar0->rx_traffic_int, val64);=0A=
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
+	val64 =3D read64(&bar0->rx_traffic_int);=0A=
+	write64(&bar0->rx_traffic_int, val64);=0A=
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
+	unsigned long flags =3D 0;=0A=
+#if DEBUG_ON=0A=
+	int cnt =3D 0;=0A=
+	nic->txint_cnt++;=0A=
+#endif=0A=
+=0A=
+	mac_control =3D &nic->mac_control;=0A=
+	config =3D &nic->config;=0A=
+=0A=
+/* tx_traffic_int reg is an R1 register, hence we read and write back =0A=
+* the samevalue in the register to clear it.=0A=
+*/=0A=
+	val64 =3D read64(&bar0->tx_traffic_int);=0A=
+	write64(&bar0->tx_traffic_int, val64);=0A=
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
+			if (!frg_cnt) {=0A=
+				pci_unmap_single(nic->pdev, (dma_addr_t)=0A=
+						 txdlp->Buffer_Pointer,=0A=
+						 skb->len,=0A=
+						 PCI_DMA_TODEVICE);=0A=
+			} else {=0A=
+				TxD_t *txdp =3D txdlp;=0A=
+=0A=
+				pci_unmap_single(nic->pdev, (dma_addr_t)=0A=
+						 txdlp->Buffer_Pointer,=0A=
+						 skb->len - skb->data_len,=0A=
+						 PCI_DMA_TODEVICE);=0A=
+=0A=
+				for (j =3D 0; j < frg_cnt; j++) {=0A=
+					skb_frag_t *frag =3D=0A=
+					    &skb_shinfo(skb)->frags[j];=0A=
+=0A=
+					txdp++;=0A=
+					pci_unmap_single(nic->pdev,=0A=
+							 (dma_addr_t)=0A=
+							 txdp->=0A=
+							 Buffer_Pointer,=0A=
+							 frag->size,=0A=
+							 PCI_DMA_TODEVICE);=0A=
+				}=0A=
+=0A=
+			}=0A=
+=0A=
+			dev_kfree_skb_irq(skb);=0A=
+			memset(txdlp, 0,=0A=
+			       (sizeof(TxD_t) * config->MaxTxDs));=0A=
+			/* Updating the statistics block */=0A=
+			nic->stats.tx_packets++;=0A=
+			nic->stats.tx_bytes +=3D skb->len;=0A=
+#if DEBUG_ON=0A=
+			nic->txpkt_bytes +=3D skb->len;=0A=
+			cnt++;=0A=
+#endif=0A=
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
+	spin_lock_irqsave(&nic->tx_lock, flags);=0A=
+	if (netif_queue_stopped(dev))=0A=
+		netif_wake_queue(dev);=0A=
+	spin_unlock_irqrestore(&nic->tx_lock, flags);=0A=
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
+	int quiescence_flag =3D FALSE, cnt =3D 0;=0A=
+	register u64 val64 =3D 0;=0A=
+=0A=
+/* Handling link status change error Intr */=0A=
+	val64 =3D read64(&bar0->mac_rmac_err_reg);=0A=
+	if (val64 & RMAC_LINK_STATE_CHANGE_INT) {=0A=
+		val64 =3D read64(&bar0->adapter_status);=0A=
+		if (verify_xena_quiescence(val64, nic->device_enabled_once)=0A=
+		    =3D=3D TRUE) {=0A=
+			do {=0A=
+				val64 =3D read64(&bar0->adapter_status);=0A=
+				if (!=0A=
+				    (val64 &=0A=
+				     (ADAPTER_STATUS_RMAC_REMOTE_FAULT |=0A=
+				      ADAPTER_STATUS_RMAC_LOCAL_FAULT))) {=0A=
+					val64 =3D=0A=
+					    read64(&bar0->adapter_control);=0A=
+					val64 |=3D ADAPTER_CNTL_EN;=0A=
+					write64(&bar0->adapter_control,=0A=
+						val64);=0A=
+					val64 |=3D ADAPTER_LED_ON;=0A=
+					write64(&bar0->adapter_control,=0A=
+						val64);=0A=
+					val64 =3D=0A=
+					    read64(&bar0->adapter_status);=0A=
+					if ((val64 &=0A=
+					     (ADAPTER_STATUS_RMAC_REMOTE_FAULT=0A=
+					      |=0A=
+					      ADAPTER_STATUS_RMAC_LOCAL_FAULT)))=0A=
+					{=0A=
+						DBG_PRINT(ERR_DBG, "%s:",=0A=
+							  dev->name);=0A=
+						DBG_PRINT(ERR_DBG,=0A=
+							  " Link down");=0A=
+						DBG_PRINT(ERR_DBG,=0A=
+							  "after ");=0A=
+						DBG_PRINT(ERR_DBG,=0A=
+							  "enabling ");=0A=
+						DBG_PRINT(ERR_DBG,=0A=
+							  "device \n");=0A=
+						cnt++;=0A=
+						continue;=0A=
+					}=0A=
+					if (nic->device_enabled_once =3D=3D=0A=
+					    FALSE) {=0A=
+						nic->device_enabled_once =3D=0A=
+						    TRUE;=0A=
+					}=0A=
+					s2io_link(nic, 1);=0A=
+					break;=0A=
+				}=0A=
+				cnt++;=0A=
+				if (cnt > 10) {=0A=
+					s2io_link(nic, 0);=0A=
+					break;=0A=
+				}=0A=
+				set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+				schedule_timeout(HZ/20);	=0A=
+			} while (TRUE);=0A=
+			quiescence_flag =3D TRUE;=0A=
+		}=0A=
+	}=0A=
+	/* Acknowledge interrupt and clear the R1 register */=0A=
+	val64 =3D read64(&bar0->mac_rmac_err_reg);=0A=
+	write64(&bar0->mac_rmac_err_reg, val64);=0A=
+=0A=
+	if (quiescence_flag =3D=3D FALSE) {=0A=
+		/*=0A=
+		 * The Device could not reach quiescence state. Stopping device=0A=
+		 * Xmit queue. This inturn will force a H/W reset in the =0A=
+		 * Tx_Timeou function.=0A=
+		 */=0A=
+		DBG_PRINT(ERR_DBG, "%s: from Link Intr, ", dev->name);=0A=
+		DBG_PRINT(ERR_DBG, "device is not Quiescent\n");=0A=
+		netif_stop_queue(dev);=0A=
+	}=0A=
+=0A=
+	/* Handling SERR errors by stopping device Xmit queue and forcing =0A=
+	 * a H/W reset.=0A=
+	 */=0A=
+	val64 =3D read64(&bar0->serr_source);=0A=
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
+		write64(&bar0->rmac_addr_cmd_mem, val64);=0A=
+		val64 =3D read64(&bar0->rmac_addr_cmd_mem);=0A=
+		if (!val64) {=0A=
+			ret =3D SUCCESS;=0A=
+			break;=0A=
+		}=0A=
+		set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+		schedule_timeout(5);=0A=
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
+	write64(&bar0->sw_reset, val64);=0A=
+	set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+	schedule_timeout(30);=0A=
+=0A=
+/* Restore the PCI state saved during initializarion. */=0A=
+	pci_restore_state(sp->pdev, sp->config_space);=0A=
+	/*Grisha */=0A=
+	s2io_init_pci(sp);=0A=
+=0A=
+	set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+	schedule_timeout(30);=0A=
+=0A=
+	val64 =3D read64(&bar0->xmsi_address);=0A=
+=0A=
+	/* SXE-002: Configure link and activity LED to turn it off */=0A=
+	subid =3D sp->pdev->subsystem_device;=0A=
+	if ((subid & 0xFF) >=3D 0x07) {=0A=
+		val64 =3D read64(&bar0->gpio_control);=0A=
+		val64 |=3D 0x0000800000000000ULL;=0A=
+		write64(&bar0->gpio_control, val64);=0A=
+		val64 =3D 0x0411040400000000ULL;=0A=
+		write64((u64 *) ((u8 *) bar0 + 0x2700), val64);=0A=
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
+	write64(&bar0->swapper_ctrl, 0xffffffffffffffffULL);=0A=
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
+	write64(&bar0->swapper_ctrl, val64);=0A=
+#else=0A=
+/* Initially we enable all bits to make it accessible by the driver,=0A=
+ * then we selectively enable only those bits that we want to set.=0A=
+ */=0A=
+	write64(&bar0->swapper_ctrl, 0xffffffffffffffffULL);=0A=
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
+	write64(&bar0->swapper_ctrl, val64);=0A=
+#endif=0A=
+=0A=
+/*  Verifying if endian settings are accurate by reading a feedback=0A=
+ *  register.=0A=
+ */=0A=
+	val64 =3D read64(&bar0->pif_rd_swapper_fb);=0A=
+	if (val64 !=3D 0x0123456789ABCDEFULL) {=0A=
+		/* Endian settings are incorrect, calls for another dekko. */=0A=
+		DBG_PRINT(ERR_DBG, "%s: Endian settings are wrong, ",=0A=
+			  dev->name);=0A=
+		DBG_PRINT(ERR_DBG, "feedback read %llx\n", =0A=
+				(unsigned long long)val64);=0A=
+		return FAILURE;=0A=
+	}=0A=
+=0A=
+	return SUCCESS;=0A=
+}=0A=
+=0A=
+/* ********************************************************* */=0A=
+/* Functions defined below concern the OS part of the driver */=0A=
+/* ********************************************************* */=0A=
+/*=0A=
+ *  Input Argument: =0A=
+ *  dev - pointer to the device structure.=0A=
+ *  Return value:=0A=
+ *  SUCCESS on success and an appropriate (-)ve integer as defined in =
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
+	nic_t *sp =3D (nic_t *) dev->priv;=0A=
+	int i, ret =3D 0;=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+=0A=
+=0A=
+/* Make sure you have link off by default every time Nic is =
initialized*/=0A=
+	netif_carrier_off(dev);=0A=
+=0A=
+/*  Initialize the H/W I/O registers */=0A=
+	if (initNic(sp) !=3D 0) {=0A=
+		DBG_PRINT(ERR_DBG, "%s: H/W initialization failed\n",=0A=
+			  dev->name);=0A=
+		return FAILURE;=0A=
+	}=0A=
+=0A=
+/*  After proper initialization of H/W, register ISR */=0A=
+	if (request_irq((int) sp->irq, s2io_isr, SA_SHIRQ, sp->name, dev)) {=0A=
+		s2io_reset(sp);=0A=
+		DBG_PRINT(ERR_DBG, "%s: ISR registration failed\n",=0A=
+			  dev->name);=0A=
+		return FAILURE;=0A=
+	}=0A=
+	if(s2io_set_mac_addr(dev, dev->dev_addr) =3D=3D FAILURE){=0A=
+		DBG_PRINT(ERR_DBG, "Set Mac Address Failed\n");=0A=
+		s2io_reset(sp);=0A=
+		return FAILURE;=0A=
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
+		return FAILURE;=0A=
+	}=0A=
+=0A=
+	sp->device_close_flag =3D FALSE;	/* Device is up and running. */=0A=
+	netif_start_queue(dev);=0A=
+=0A=
+	return SUCCESS;=0A=
+}=0A=
+=0A=
+/*=0A=
+ *  Input Argument/s: =0A=
+ *  dev - device pointer.=0A=
+ *  Return value:=0A=
+ *  SUCCESS on success and an appropriate (-)ve integer as defined in =
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
+	nic_t *sp =3D (nic_t *) dev->priv;=0A=
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
+		schedule_timeout(10);=0A=
+	}=0A=
+	tasklet_kill(&sp->task);=0A=
+=0A=
+/* Check if the device is Quiescent and then Reset the NIC */=0A=
+	do {=0A=
+		val64 =3D read64(&bar0->adapter_status);=0A=
+		if (verify_xena_quiescence(val64, sp->device_enabled_once)=0A=
+		    =3D=3D TRUE) {=0A=
+			break;=0A=
+		}=0A=
+=0A=
+		set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+		schedule_timeout(5);=0A=
+		cnt++;=0A=
+		if (cnt =3D=3D 10) {=0A=
+			DBG_PRINT(ERR_DBG,=0A=
+				  "s2io_close:Device not Quiescent ");=0A=
+			DBG_PRINT(ERR_DBG, "adaper status reads 0x%llx\n",=0A=
+				  (unsigned long long)val64);=0A=
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
+	return SUCCESS;=0A=
+}=0A=
+=0A=
+/*=0A=
+ *  Input Argument/s: =0A=
+ *  skb - the socket buffer containing the Tx data.=0A=
+ *  dev - device pointer.=0A=
+ *  Return value:=0A=
+ *  always SUCCESS. =0A=
+ *  NOTE: when device cant queue the pkt, just the trans_start variable =
will=0A=
+ *  not be upadted.=0A=
+ *  Description:=0A=
+ *  This function is the Tx entry point of the driver. S2IO NIC supports=0A=
+ *  certain protocol assist features on Tx side, namely  CSO, S/G, LSO.=0A=
+ */=0A=
+int s2io_xmit(struct sk_buff *skb, struct net_device *dev)=0A=
+{=0A=
+	nic_t *sp =3D (nic_t *) dev->priv;=0A=
+	u16 off, txd_len, frg_cnt, frg_len, i, queue, off1;=0A=
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
+=0A=
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
+	/* Avoid "put" pointer going beyond "get" pointer */=0A=
+	if ((txdp->Host_Control) ||=0A=
+	    (((off +=0A=
+	       1) % (mac_control->tx_curr_put_info[queue].fifo_len + 1))=0A=
+	     =3D=3D off1)) {=0A=
+		DBG_PRINT(ERR_DBG,=0A=
+			  "No free TXDs for now, put: 0x%x, get:0x%x\n",=0A=
+			  off, off1);=0A=
+		goto no_txd;=0A=
+	}=0A=
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
+/*  The NIC is made the owner of the TxDL */=0A=
+	txdp->Control_1 |=3D (TXD_BUFFER0_SIZE(frg_len) |=0A=
+			    TXD_GATHER_CODE_FIRST);=0A=
+	txdp->Control_1 |=3D TXD_LIST_OWN_XENA;=0A=
+=0A=
+/* If the SKB is fragmented, each fragment is put into a new Tx buffer. =
*/=0A=
+	for (i =3D 0; i < frg_cnt; i++) {=0A=
+		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];=0A=
+		txdp++;=0A=
+		txdp->Buffer_Pointer =3D (u64) pci_map_single=0A=
+		    (sp->pdev,=0A=
+		     page_address(frag->page) + frag->page_offset,=0A=
+		     frag->size, PCI_DMA_TODEVICE);=0A=
+		txdp->Control_1 |=3D TXD_BUFFER0_SIZE(frag->size);=0A=
+	}=0A=
+	txdp->Control_1 |=3D TXD_GATHER_CODE_LAST;=0A=
+=0A=
+/* To Update the TxDL pointer into the XENA nic. */=0A=
+	tx_fifo =3D mac_control->tx_FIFO_start[queue];=0A=
+	val64 =3D (mac_control->txdl_start_phy[queue] +=0A=
+		 (sizeof(TxD_t) * txd_len * off));=0A=
+	write64(&tx_fifo->TxDL_Pointer, val64);=0A=
+=0A=
+	val64 =3D (TX_FIFO_LAST_TXD_NUM(frg_cnt) | TX_FIFO_FIRST_LIST |=0A=
+		 TX_FIFO_LAST_LIST);=0A=
+#ifdef NETIF_F_TSO=0A=
+	if (mss)=0A=
+		val64 |=3D TX_FIFO_SPECIAL_FUNC;=0A=
+#endif=0A=
+	write64(&tx_fifo->List_Control, val64);=0A=
+=0A=
+/*Incrementing offset */=0A=
+	off++;=0A=
+	off %=3D mac_control->tx_curr_put_info[queue].fifo_len + 1;=0A=
+	mac_control->tx_curr_put_info[queue].offset =3D off;=0A=
+=0A=
+/* Update the time when the last Tx happened */=0A=
+	dev->trans_start =3D jiffies;=0A=
+	spin_unlock_irqrestore(&sp->tx_lock, flags);=0A=
+=0A=
+	return SUCCESS;=0A=
+=0A=
+      no_txd:=0A=
+	netif_stop_queue(dev);=0A=
+	spin_unlock_irqrestore(&sp->tx_lock, flags);=0A=
+	return 1;=0A=
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
+	nic_t *sp =3D (nic_t *) dev->priv;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+#ifndef CONFIG_S2IO_NAPI=0A=
+	int i, ret;=0A=
+#endif=0A=
+	u64 reason =3D 0, general_mask =3D 0;=0A=
+	unsigned long flags;=0A=
+	mac_info_t *mac_control;=0A=
+	struct config_param *config;=0A=
+=0A=
+	mac_control =3D &sp->mac_control;=0A=
+	config =3D &sp->config;=0A=
+=0A=
+	spin_lock_irqsave(&sp->isr_lock, flags);=0A=
+=0A=
+/* Identify the cause for interrupt and call the appropriate=0A=
+ * interrupt handler. Causes for the interrupt could be;=0A=
+ * 1. Rx of packet.=0A=
+ * 2. Tx complete.=0A=
+ * 3. Link down.=0A=
+ * 4. Error in any functional blocks of the NIC. =0A=
+ */=0A=
+	reason =3D read64(&bar0->general_int_status);=0A=
+=0A=
+	if (!reason) {=0A=
+		/* The interrupt was not raised by Xena. */=0A=
+		spin_unlock_irqrestore(&sp->isr_lock, flags);=0A=
+		return IRQ_NONE;=0A=
+	}=0A=
+	/* Mask the interrupts on the NIC */=0A=
+	general_mask =3D read64(&bar0->general_int_mask);=0A=
+	write64(&bar0->general_int_mask, 0xFFFFFFFFFFFFFFFFULL);=0A=
+=0A=
+#if DEBUG_ON=0A=
+	sp->int_cnt++;=0A=
+#endif=0A=
+=0A=
+/* If Intr is because of Tx Traffic */=0A=
+	if (reason & GEN_INTR_TXTRAFFIC)=0A=
+		txIntrHandler(sp);=0A=
+=0A=
+/* If Intr is because of Link status change or error */=0A=
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
+			general_mask =3D read64(&bar0->general_int_mask);=0A=
+			__netif_rx_schedule(dev);=0A=
+		}=0A=
+	}=0A=
+#else=0A=
+	/* If Intr is because of Rx Traffic */=0A=
+	if (reason & GEN_INTR_RXTRAFFIC)=0A=
+		rxIntrHandler(sp);=0A=
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
+				write64(&bar0->general_int_mask,=0A=
+					general_mask);=0A=
+				spin_unlock_irqrestore(&sp->isr_lock,=0A=
+						       flags);=0A=
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
+/* Unmask all the previously enabled interrupts on the NIC */=0A=
+	write64(&bar0->general_int_mask, general_mask);=0A=
+=0A=
+	spin_unlock_irqrestore(&sp->isr_lock, flags);=0A=
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
+	nic_t *sp =3D (nic_t *) dev->priv;=0A=
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
+	nic_t *sp =3D (nic_t *) dev->priv;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+	u64 val64 =3D 0, multi_mac =3D 0x010203040506ULL, mask =3D=0A=
+	    0xfeffffffffffULL;=0A=
+	u64 dis_addr =3D 0xffffffffffffULL, mac_addr =3D 0;=0A=
+	void *add;=0A=
+=0A=
+	if ((dev->flags & IFF_ALLMULTI) && (!sp->m_cast_flg)) {=0A=
+		/*  Enable all Multicast addresses */=0A=
+		write64(&bar0->rmac_addr_data0_mem,=0A=
+			RMAC_ADDR_DATA0_MEM_ADDR(multi_mac));=0A=
+		write64(&bar0->rmac_addr_data1_mem,=0A=
+			RMAC_ADDR_DATA1_MEM_MASK(mask));=0A=
+=0A=
+		val64 =3D RMAC_ADDR_CMD_MEM_WE |=0A=
+		    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |=0A=
+		    RMAC_ADDR_CMD_MEM_OFFSET(MAC_MC_ALL_MC_ADDR_OFFSET);=0A=
+		write64(&bar0->rmac_addr_cmd_mem, val64);=0A=
+		/* Wait till command completes */=0A=
+		waitForCmdComplete(sp);=0A=
+=0A=
+		sp->m_cast_flg =3D 1;=0A=
+		sp->all_multi_pos =3D MAC_MC_ALL_MC_ADDR_OFFSET;=0A=
+	} else if ((dev->flags & IFF_ALLMULTI) && (sp->m_cast_flg)) {=0A=
+		/*  Disable all Multicast addresses */=0A=
+		write64(&bar0->rmac_addr_data0_mem,=0A=
+			RMAC_ADDR_DATA0_MEM_ADDR(dis_addr));=0A=
+=0A=
+		val64 =3D RMAC_ADDR_CMD_MEM_WE |=0A=
+		    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |=0A=
+		    RMAC_ADDR_CMD_MEM_OFFSET(sp->all_multi_pos);=0A=
+		write64(&bar0->rmac_addr_cmd_mem, val64);=0A=
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
+		val64 =3D read64(&bar0->mac_cfg);=0A=
+		val64 |=3D MAC_CFG_RMAC_PROM_ENABLE;=0A=
+=0A=
+		write64(&bar0->rmac_cfg_key, RMAC_CFG_KEY(0x4C0D));=0A=
+		writel((u32) val64, add);=0A=
+		write64(&bar0->rmac_cfg_key, RMAC_CFG_KEY(0x4C0D));=0A=
+		writel((u32) (val64 >> 32), (add + 4));=0A=
+=0A=
+		val64 =3D read64(&bar0->mac_cfg);=0A=
+		sp->promisc_flg =3D 1;=0A=
+		DBG_PRINT(ERR_DBG, "%s: entered promiscuous mode\n",=0A=
+			  dev->name);=0A=
+	} else if (!(dev->flags & IFF_PROMISC) && (sp->promisc_flg)) {=0A=
+		/*  Remove the NIC from promiscuous mode */=0A=
+		add =3D (void *) &bar0->mac_cfg;=0A=
+		val64 =3D read64(&bar0->mac_cfg);=0A=
+		val64 &=3D ~MAC_CFG_RMAC_PROM_ENABLE;=0A=
+=0A=
+		write64(&bar0->rmac_cfg_key, RMAC_CFG_KEY(0x4C0D));=0A=
+		writel((u32) val64, add);=0A=
+		write64(&bar0->rmac_cfg_key, RMAC_CFG_KEY(0x4C0D));=0A=
+		writel((u32) (val64 >> 32), (add + 4));=0A=
+=0A=
+		val64 =3D read64(&bar0->mac_cfg);=0A=
+		sp->promisc_flg =3D 0;=0A=
+		DBG_PRINT(ERR_DBG, "%s: left promiscuous mode\n",=0A=
+			  dev->name);=0A=
+	}=0A=
+=0A=
+/*  Update individual M_CAST address list*/=0A=
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
+			write64(&bar0->rmac_addr_data0_mem,=0A=
+				RMAC_ADDR_DATA0_MEM_ADDR(dis_addr));=0A=
+			val64 =3D RMAC_ADDR_CMD_MEM_WE |=0A=
+			    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |=0A=
+			    RMAC_ADDR_CMD_MEM_OFFSET=0A=
+			    (MAC_MC_ADDR_START_OFFSET + i);=0A=
+			write64(&bar0->rmac_addr_cmd_mem, val64);=0A=
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
+			write64(&bar0->rmac_addr_data0_mem,=0A=
+				RMAC_ADDR_DATA0_MEM_ADDR(mac_addr));=0A=
+			val64 =3D RMAC_ADDR_CMD_MEM_WE |=0A=
+			    RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |=0A=
+			    RMAC_ADDR_CMD_MEM_OFFSET(i +=0A=
+						     MAC_MC_ADDR_START_OFFSET);=0A=
+			write64(&bar0->rmac_addr_cmd_mem, val64);=0A=
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
+	nic_t *sp =3D (nic_t *) dev->priv;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+	register u64 val64, mac_addr =3D 0;=0A=
+	int i;=0A=
+=0A=
+/* =0A=
+* Set the new MAC address as the new unicast filter and reflect this=0A=
+* change on the device address registered with the OS. It will be=0A=
+* at offset 0. =0A=
+*/=0A=
+	for (i =3D 0; i < ETH_ALEN; i++) {=0A=
+		mac_addr <<=3D 8;=0A=
+		mac_addr |=3D addr[i];=0A=
+	}=0A=
+=0A=
+	write64(&bar0->rmac_addr_data0_mem,=0A=
+		RMAC_ADDR_DATA0_MEM_ADDR(mac_addr));=0A=
+	val64 =3D=0A=
+	    RMAC_ADDR_CMD_MEM_WE | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |=0A=
+	    RMAC_ADDR_CMD_MEM_OFFSET(0);=0A=
+	write64(&bar0->rmac_addr_cmd_mem, val64);=0A=
+/* Wait till command completes */=0A=
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
+#define SPEED_10000 10000=0A=
+static int s2io_ethtool_sset(struct net_device * dev, struct =
ethtool_cmd *info)=0A=
+{=0A=
+nic_t * sp =3D (nic_t *)dev->priv;=0A=
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
+int s2io_ethtool_gset(struct net_device *dev,struct ethtool_cmd *info)=0A=
+{=0A=
+nic_t * sp =3D (nic_t *)dev->priv;=0A=
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
+	return SUCCESS;=0A=
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
+static void s2io_ethtool_gdrvinfo(struct net_device *dev, struct =
ethtool_drvinfo *info)=0A=
+{=0A=
+nic_t * sp =3D (nic_t *)dev->priv;=0A=
+=0A=
+	strncpy(info->driver, s2io_driver_name, =0A=
+			sizeof(s2io_driver_name));=0A=
+	strncpy(info->version, s2io_driver_version, =0A=
+			sizeof(s2io_driver_version));=0A=
+	strncpy(info->fw_version, "", 32);=0A=
+	strncpy(info->bus_info, sp->pdev->slot_name, 32);=0A=
+#if defined(ETHTOOL_GREGS)=0A=
+	info->regdump_len =3D XENA_REG_SPACE;=0A=
+#endif=0A=
+	info->eedump_len =3D XENA_EEPROM_SPACE;=0A=
+	info->testinfo_len =3D S2IO_TEST_LEN;=0A=
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
+static void s2io_ethtool_gregs(struct net_device *dev,struct =
ethtool_regs *regs,=0A=
+			       void *space)=0A=
+{=0A=
+	int i;=0A=
+	u64 reg;=0A=
+	u8 *reg_space =3D (u8 *)space;=0A=
+	nic_t *sp =3D (nic_t *) dev->priv;=0A=
+=0A=
+	regs->len =3D XENA_REG_SPACE;=0A=
+	regs->version =3D sp->pdev->subsystem_device;=0A=
+=0A=
+	for (i =3D 0; i < regs->len; i +=3D 8) {=0A=
+		reg =3D read64((void *) (sp->bar0 + i));=0A=
+		memcpy((reg_space + i), &reg, 8);=0A=
+	}=0A=
+}=0A=
+=0A=
+#ifdef ETHTOOL_PHYS_ID=0A=
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
+ *  The timeris set for 1/2 a second, hence tha NIC blinks once every =
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
+		val64 =3D read64(&bar0->gpio_control);=0A=
+		val64 ^=3D GPIO_CTRL_GPIO_0;=0A=
+		write64(&bar0->gpio_control, val64);=0A=
+	} else {=0A=
+		val64 =3D read64(&bar0->adapter_control);=0A=
+		val64 ^=3D ADAPTER_LED_ON;=0A=
+		write64(&bar0->adapter_control, val64);=0A=
+	}=0A=
+=0A=
+	mod_timer(&sp->id_timer, jiffies + HZ / 2);	/* blink once in 1 sec */=0A=
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
+ *  void=0A=
+ * Description:=0A=
+ *  Used to physically identify the NIC on the system. The Link LED =
will blink=0A=
+ *  for a time specified by the user for identification.=0A=
+ *  NOTE: The Link has to be Up to be able to blink the LED. Hence =0A=
+ *  identification is possible only if it's link is up.=0A=
+ */=0A=
+static int s2io_ethtool_idnic(struct net_device *dev,u32 data)=0A=
+{=0A=
+	u64 val64 =3D 0;=0A=
+	nic_t *sp =3D (nic_t *) dev->priv;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+	u16 subid;=0A=
+=0A=
+	subid =3D sp->pdev->subsystem_device;=0A=
+	if ((subid & 0xFF) < 0x07) {=0A=
+		val64 =3D read64(&bar0->adapter_control);=0A=
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
+	return SUCCESS;=0A=
+}=0A=
+#endif=0A=
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
+	nic_t *sp =3D (nic_t *)dev->priv;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+=0A=
+	val64 =3D read64(&bar0->rmac_pause_cfg);=0A=
+	if (val64 & RMAC_PAUSE_GEN_ENABLE)=0A=
+		ep->tx_pause =3D TRUE;=0A=
+	if (val64 & RMAC_PAUSE_RX_ENABLE)=0A=
+		ep->rx_pause =3D TRUE;=0A=
+	ep->autoneg =3D FALSE;=0A=
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
+ *  It can be used to set or reset Pause frame generation or reception =
support =0A=
+ *  of the NIC.=0A=
+ */=0A=
+int  s2io_ethtool_setpause_data(struct net_device *dev,=0A=
+				       struct ethtool_pauseparam *ep)=0A=
+{=0A=
+	u64 val64;=0A=
+	nic_t * sp =3D (nic_t *)dev->priv;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+=0A=
+	val64 =3D read64(&bar0->rmac_pause_cfg);=0A=
+	if (ep->tx_pause)=0A=
+		val64 |=3D RMAC_PAUSE_GEN_ENABLE;=0A=
+	else=0A=
+		val64 &=3D ~RMAC_PAUSE_GEN_ENABLE;=0A=
+	if (ep->rx_pause)=0A=
+		val64 |=3D RMAC_PAUSE_RX_ENABLE;=0A=
+	else=0A=
+		val64 &=3D ~RMAC_PAUSE_RX_ENABLE;=0A=
+	write64(&bar0->rmac_pause_cfg, val64);=0A=
+	return SUCCESS;=0A=
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
+	write64(&bar0->i2c_control, val64);=0A=
+=0A=
+	while (exit_cnt < 5) {=0A=
+		val64 =3D read64(&bar0->i2c_control);=0A=
+		if (I2C_CONTROL_CNTL_END(val64)) {=0A=
+			data =3D I2C_CONTROL_GET_DATA(val64);=0A=
+			break;=0A=
+		}=0A=
+		set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+		schedule_timeout(HZ/20);	=0A=
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
+	write64(&bar0->i2c_control, val64);=0A=
+=0A=
+	while (exit_cnt < 5) {=0A=
+		val64 =3D read64(&bar0->i2c_control);=0A=
+		if (I2C_CONTROL_CNTL_END(val64)) {=0A=
+			if (!(val64 & I2C_CONTROL_NACK))=0A=
+				ret =3D 0;=0A=
+			break;=0A=
+		}=0A=
+		set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+		schedule_timeout(HZ/20);	=0A=
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
+ *  void=0A=
+ * Description:=0A=
+ *  Reads the values stored in the Eeprom at given offset for a given =
length.=0A=
+ *  Stores these values int the input argument data buffer 'data_buf' =
and=0A=
+ *  returns these to the caller (ethtool.)=0A=
+ */=0A=
+int s2io_ethtool_geeprom(struct net_device *dev, =0A=
+				struct ethtool_eeprom *eeprom,=0A=
+				 u8 *data_buf)=0A=
+{=0A=
+	u32 data, i, valid;=0A=
+	nic_t *sp =3D (nic_t *) dev->priv;=0A=
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
+	return SUCCESS;=0A=
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
+static int s2io_ethtool_seeprom(struct net_device *dev, =0A=
+				struct ethtool_eeprom *eeprom,=0A=
+				u8 *data_buf)=0A=
+{=0A=
+	int len =3D eeprom->len, cnt =3D 0;=0A=
+	u32 valid =3D 0, data;=0A=
+	nic_t *sp =3D (nic_t *) dev->priv;=0A=
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
+	val64 =3D read64(&bar0->pcc_enable);=0A=
+	if (val64 !=3D 0xff00000000000000ULL) {=0A=
+		fail =3D 1;=0A=
+		DBG_PRINT(INFO_DBG, "Read Test level 1 fails\n");=0A=
+	}=0A=
+=0A=
+	val64 =3D read64(&bar0->rmac_pause_cfg);=0A=
+	if (val64 !=3D 0xc000ffff00000000ULL) {=0A=
+		fail =3D 1;=0A=
+		DBG_PRINT(INFO_DBG, "Read Test level 2 fails\n");=0A=
+	}=0A=
+=0A=
+	val64 =3D read64(&bar0->rx_queue_cfg);=0A=
+	if (val64 !=3D 0x0808080808080808ULL) {=0A=
+		fail =3D 1;=0A=
+		DBG_PRINT(INFO_DBG, "Read Test level 3 fails\n");=0A=
+	}=0A=
+=0A=
+	val64 =3D read64(&bar0->xgxs_efifo_cfg);=0A=
+	if (val64 !=3D 0x000000001923141EULL) {=0A=
+		fail =3D 1;=0A=
+		DBG_PRINT(INFO_DBG, "Read Test level 4 fails\n");=0A=
+	}=0A=
+=0A=
+	val64 =3D 0x5A5A5A5A5A5A5A5AULL;=0A=
+	write64(&bar0->xmsi_data, val64);=0A=
+	val64 =3D read64(&bar0->xmsi_data);=0A=
+	if (val64 !=3D 0x5A5A5A5A5A5A5A5AULL) {=0A=
+		fail =3D 1;=0A=
+		DBG_PRINT(ERR_DBG, "Write Test level 1 fails\n");=0A=
+	}=0A=
+=0A=
+	val64 =3D 0xA5A5A5A5A5A5A5A5ULL;=0A=
+	write64(&bar0->xmsi_data, val64);=0A=
+	val64 =3D read64(&bar0->xmsi_data);=0A=
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
+		schedule_timeout(HZ/10);	=0A=
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
+	val64 =3D read64(&bar0->adapter_status);=0A=
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
+	val64 =3D read64(&bar0->adapter_control);=0A=
+	val64 &=3D ~ADAPTER_ECC_EN;=0A=
+	write64(&bar0->adapter_control, val64);=0A=
+=0A=
+	val64 =3D read64(&bar0->mc_rldram_test_ctrl);=0A=
+	val64 |=3D MC_RLDRAM_TEST_MODE;=0A=
+	write64(&bar0->mc_rldram_test_ctrl, val64);=0A=
+=0A=
+	val64 =3D read64(&bar0->mc_rldram_mrs);=0A=
+	val64 |=3D MC_RLDRAM_QUEUE_SIZE_ENABLE;=0A=
+	write64(&bar0->mc_rldram_mrs, val64);=0A=
+=0A=
+	val64 |=3D MC_RLDRAM_MRS_ENABLE;=0A=
+	write64(&bar0->mc_rldram_mrs, val64);=0A=
+=0A=
+	while (iteration < 2) {=0A=
+		val64 =3D 0x55555555aaaa0000ULL;=0A=
+		if (iteration =3D=3D 1) {=0A=
+			val64 ^=3D 0xFFFFFFFFFFFF0000ULL;=0A=
+		}=0A=
+		write64(&bar0->mc_rldram_test_d0, val64);=0A=
+=0A=
+		val64 =3D 0xaaaa5a5555550000ULL;=0A=
+		if (iteration =3D=3D 1) {=0A=
+			val64 ^=3D 0xFFFFFFFFFFFF0000ULL;=0A=
+		}=0A=
+		write64(&bar0->mc_rldram_test_d1, val64);=0A=
+=0A=
+		val64 =3D 0x55aaaaaaaa5a0000ULL;=0A=
+		if (iteration =3D=3D 1) {=0A=
+			val64 ^=3D 0xFFFFFFFFFFFF0000ULL;=0A=
+		}=0A=
+		write64(&bar0->mc_rldram_test_d2, val64);=0A=
+=0A=
+		val64 =3D (u64) (0x0000003fffff0000ULL);=0A=
+		write64(&bar0->mc_rldram_test_add, val64);=0A=
+=0A=
+=0A=
+		val64 =3D MC_RLDRAM_TEST_MODE;=0A=
+		write64(&bar0->mc_rldram_test_ctrl, val64);=0A=
+=0A=
+		val64 |=3D=0A=
+		    MC_RLDRAM_TEST_MODE | MC_RLDRAM_TEST_WRITE |=0A=
+		    MC_RLDRAM_TEST_GO;=0A=
+		write64(&bar0->mc_rldram_test_ctrl, val64);=0A=
+=0A=
+		for (cnt =3D 0; cnt < 5; cnt++) {=0A=
+			val64 =3D read64(&bar0->mc_rldram_test_ctrl);=0A=
+			if (val64 & MC_RLDRAM_TEST_DONE)=0A=
+				break;=0A=
+			set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+			schedule_timeout(HZ/5);	=0A=
+		}=0A=
+=0A=
+		if (cnt =3D=3D 5)=0A=
+			break;=0A=
+=0A=
+		val64 =3D MC_RLDRAM_TEST_MODE;=0A=
+		write64(&bar0->mc_rldram_test_ctrl, val64);=0A=
+=0A=
+		val64 |=3D MC_RLDRAM_TEST_MODE | MC_RLDRAM_TEST_GO;=0A=
+		write64(&bar0->mc_rldram_test_ctrl, val64);=0A=
+=0A=
+		set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+		schedule_timeout(HZ/2);	=0A=
+		for (cnt =3D 0; cnt < 5; cnt++) {=0A=
+			val64 =3D read64(&bar0->mc_rldram_test_ctrl);=0A=
+			if (val64 & MC_RLDRAM_TEST_DONE)=0A=
+				break;=0A=
+			set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+			schedule_timeout(HZ/2);	=0A=
+		}=0A=
+=0A=
+		if (cnt =3D=3D 5)=0A=
+			break;=0A=
+=0A=
+		val64 =3D read64(&bar0->mc_rldram_test_ctrl);=0A=
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
+				struct ethtool_test *ethtest,=0A=
+			     	uint64_t * data)=0A=
+{=0A=
+	nic_t *sp =3D (nic_t *)dev->priv;=0A=
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
+			DBG_PRINT(ERR_DBG, "%s: is not up, cannot run test\n",=0A=
+						dev->name);=0A=
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
+=0A=
+int s2io_ethtool_get_regs_len(struct net_device *dev)=0A=
+{=0A=
+	return (XENA_REG_SPACE);=0A=
+}=0A=
+=0A=
+int s2io_ethtool_nway_reset(struct net_device *dev)=0A=
+{=0A=
+	nic_t *sp =3D (nic_t *) dev->priv;=0A=
+	DBG_PRINT(INFO_DBG, "Card reset through EthTool\n");=0A=
+	if (netif_running(dev)) {=0A=
+		s2io_close(dev);=0A=
+		s2io_open(dev);=0A=
+	} else {=0A=
+		s2io_reset(sp);=0A=
+		s2io_set_swapper(sp);=0A=
+	}=0A=
+	return SUCCESS;=0A=
+}=0A=
+=0A=
+u32 s2io_ethtool_get_link(struct net_device *dev)=0A=
+{=0A=
+	return(netif_carrier_ok(dev));=0A=
+}=0A=
+=0A=
+u32 s2io_ethtool_get_rx_csum(struct net_device *dev)=0A=
+{=0A=
+	return ((dev->features & NETIF_F_HW_CSUM));=0A=
+}=0A=
+=0A=
+int s2io_ethtool_set_rx_csum(struct net_device *dev,u32 data)=0A=
+{=0A=
+	if(data)=0A=
+		dev->features |=3D NETIF_F_HW_CSUM;=0A=
+	else=0A=
+		dev->features &=3D ~NETIF_F_HW_CSUM;=0A=
+	return SUCCESS;=0A=
+}=0A=
+u32 s2io_ethtool_get_tx_csum(struct net_device *dev)=0A=
+{=0A=
+	return ((dev->features & NETIF_F_HW_CSUM));=0A=
+}=0A=
+int s2io_ethtool_set_tx_csum(struct net_device *dev,u32 data)=0A=
+{=0A=
+        if(data)=0A=
+                dev->features |=3D NETIF_F_HW_CSUM;=0A=
+        else=0A=
+                dev->features &=3D ~NETIF_F_HW_CSUM;=0A=
+        return SUCCESS;=0A=
+}=0A=
+=0A=
+int s2io_get_eeprom_len(struct net_device *dev)=0A=
+{=0A=
+	return(XENA_EEPROM_SPACE);=0A=
+}=0A=
+=0A=
+u32 s2io_ethtool_get_sg(struct net_device *dev)=0A=
+{=0A=
+	return ((dev->features & NETIF_F_SG));=0A=
+}=0A=
+int s2io_ethtool_set_sg(struct net_device *dev, u32 data)=0A=
+{=0A=
+	if (data)=0A=
+		dev->features |=3D NETIF_F_SG;=0A=
+	else=0A=
+		dev->features &=3D ~NETIF_F_SG;=0A=
+	return SUCCESS;=0A=
+}=0A=
+#ifdef NETIF_F_TSO=0A=
+u32 s2io_ethtool_get_tso(struct net_device *dev)=0A=
+{=0A=
+	return ((dev->features & NETIF_F_TSO));=0A=
+}=0A=
+int s2io_ethtool_set_tso(struct net_device *dev,u32 data)=0A=
+{=0A=
+	if(data)=0A=
+		dev->features |=3D NETIF_F_TSO;=0A=
+	else=0A=
+		dev->features &=3D ~NETIF_F_TSO;=0A=
+	return SUCCESS;=0A=
+}=0A=
+#endif=0A=
+void s2io_ethtool_self_test_count(struct net_device *dev)=0A=
+{=0A=
+	return (S2IO_TEST_LEN);=0A=
+}=0A=
+void    s2io_ethtool_get_strings(struct net_device *dev, =0A=
+				u32 stringset, u8 *data)=0A=
+{=0A=
+	switch (stringset) {=0A=
+		case ETH_SS_TEST:=0A=
+			memcpy(data, s2io_gstrings,=0A=
+				S2IO_STRINGS_LEN);=0A=
+	}=0A=
+}=0A=
+static struct ethtool_ops netdev_ethtool_ops =3D {=0A=
+        .get_settings   =3D s2io_ethtool_gset, =0A=
+        .set_settings   =3D s2io_ethtool_sset,=0A=
+        .get_drvinfo    =3D s2io_ethtool_gdrvinfo, =0A=
+        .get_regs_len   =3D s2io_ethtool_get_regs_len,=0A=
+        .get_regs       =3D s2io_ethtool_gregs, =0A=
+        .get_wol        =3D NULL,=0A=
+        .set_wol        =3D NULL,=0A=
+        .get_msglevel   =3D NULL,=0A=
+        .set_msglevel   =3D NULL,=0A=
+        .nway_reset     =3D s2io_ethtool_nway_reset,=0A=
+        .get_link       =3D s2io_ethtool_get_link, =0A=
+        .get_eeprom_len =3D s2io_get_eeprom_len, =0A=
+        .get_eeprom     =3D s2io_ethtool_geeprom, =0A=
+        .set_eeprom     =3D s2io_ethtool_seeprom, =0A=
+        .get_coalesce   =3D NULL,=0A=
+        .set_coalesce   =3D NULL,=0A=
+        .get_ringparam  =3D NULL,=0A=
+        .set_ringparam  =3D NULL,=0A=
+        .get_pauseparam =3D s2io_ethtool_getpause_data, =0A=
+        .set_pauseparam =3D s2io_ethtool_setpause_data, =0A=
+        .get_rx_csum    =3D s2io_ethtool_get_rx_csum, =0A=
+        .set_rx_csum    =3D s2io_ethtool_set_rx_csum, =0A=
+        .get_tx_csum    =3D s2io_ethtool_get_tx_csum,=0A=
+        .set_tx_csum    =3D s2io_ethtool_set_tx_csum,=0A=
+        .get_sg         =3D s2io_ethtool_get_sg, =0A=
+        .set_sg         =3D s2io_ethtool_set_sg, =0A=
+#ifdef NETIF_F_TSO=0A=
+        .get_tso        =3D s2io_ethtool_get_tso,=0A=
+        .set_tso        =3D s2io_ethtool_set_tso,=0A=
+#else=0A=
+        .get_tso        =3D NULL,=0A=
+        .set_tso        =3D NULL,=0A=
+#endif=0A=
+        .self_test_count=3D s2io_ethtool_self_test_count, =0A=
+        .self_test      =3D s2io_ethtool_test, =0A=
+        .get_strings    =3D s2io_ethtool_get_strings,=0A=
+        .phys_id 	    =3D s2io_ethtool_idnic,=0A=
+        .get_stats_count =3D  NULL,=0A=
+        .get_ethtool_stats =3D NULL=0A=
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
+ *  SUCCESS on success and an appropriate (-)ve integer as defined in =
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
+=0A=
+}=0A=
+=0A=
+/*=0A=
+ *  Input Argument/s: =0A=
+ *   dev - device pointer.=0A=
+ *   new_mtu - the new MTU size for the device.=0A=
+ *  Return value:=0A=
+ *   SUCCESS on success and an appropriate (-)ve integer as defined in =
errno.h=0A=
+ *   file on failure.=0A=
+ *  Description:=0A=
+ *   A driver entry point to change MTU size for the device. Before =
changing=0A=
+ *   the MTU the device must be stopped.=0A=
+ */=0A=
+int s2io_change_mtu(struct net_device *dev, int new_mtu)=0A=
+{=0A=
+	nic_t *sp =3D (nic_t *) dev->priv;=0A=
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
+	write64(&bar0->rmac_max_pyld_len, vBIT(val64, 2, 14));=0A=
+=0A=
+	dev->mtu =3D new_mtu;=0A=
+=0A=
+	return SUCCESS;=0A=
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
+	nic_t *sp =3D (nic_t *) dev->priv;=0A=
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
+/*=0A=
+ * Description:=0A=
+ * This function is scheduled to be run by the s2io_tx_watchdog=0A=
+ * function after 0.5 secs to reset the NIC. The idea is to reduce =0A=
+ * the run time of the watch dog routine which is run holding a=0A=
+ * spin lock.=0A=
+ */=0A=
+static void s2io_restart_nic(unsigned long data)=0A=
+{=0A=
+	struct net_device *dev =3D (struct net_device *)data;=0A=
+	nic_t *sp =3D (nic_t *)dev->priv;=0A=
+=0A=
+	s2io_close(dev);=0A=
+	sp->device_close_flag =3D TRUE;=0A=
+	s2io_open(dev);=0A=
+	DBG_PRINT(INFO_DBG,=0A=
+		  "%s: was reset by Tx watchdog timer.\n", dev->name);=0A=
+	clear_bit(0, (unsigned long *) (&sp->rst_status));=0A=
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
+	nic_t *sp =3D (nic_t *) dev->priv;=0A=
+=0A=
+	if ((!RST_TIMER_SCHEDULED) && (netif_carrier_ok(dev))) {=0A=
+		if (sp->rst_timer.function =3D=3D NULL) {=0A=
+			init_timer(&sp->rst_timer);=0A=
+			sp->rst_timer.function =3D s2io_restart_nic;=0A=
+			sp->rst_timer.data =3D (unsigned long) sp;=0A=
+		}=0A=
+		mod_timer(&sp->rst_timer, (jiffies + HZ/2));=0A=
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
+	if (rxdp->Control_1 & TCP_OR_UDP_FRAME) {=0A=
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
+	if (link =3D=3D 0) {=0A=
+		DBG_PRINT(ERR_DBG, "%s: Link down\n", dev->name);=0A=
+		netif_carrier_off(dev);=0A=
+		netif_stop_queue(dev);=0A=
+	} else {=0A=
+		DBG_PRINT(ERR_DBG, "%s: Link Up\n", dev->name);=0A=
+		netif_carrier_on(dev);=0A=
+		netif_wake_queue(dev);=0A=
+	}=0A=
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
+		pci_write_config_byte(sp->pdev, PCI_LATENCY_TIMER,=0A=
+				      latency_timer);=0A=
+	}=0A=
+=0A=
+/* Set MMRB count to 4096 in PCI-X Command register. */=0A=
+	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,=0A=
+			      (sp->pcix_cmd | 0x0C));=0A=
+	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,=0A=
+			     &(sp->pcix_cmd));=0A=
+=0A=
+/* Setting Maximum outstanding splits to two for now. */=0A=
+	/*Grisha : first clear out the OST field */=0A=
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
+*   returns '0'(SUCCESS) on success and negative on failure.=0A=
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
+=0A=
+#if LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,6,00)=0A=
+		if (pci_set_consistent_dma_mask=0A=
+		    (pdev, 0xffffffffffffffffULL)) {=0A=
+			DBG_PRINT(ERR_DBG,=0A=
+				  "Unable to obtain 64bit DMA for \=0A=
+					consistent allocations\n");=0A=
+			pci_disable_device(pdev);=0A=
+			return -ENOMEM;=0A=
+		}=0A=
+#endif=0A=
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
+/*  Private member variable initialized to s2io NIC structure */=0A=
+	sp =3D (nic_t *) dev->priv;=0A=
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
+/* Initialize some PCI/PCI-X fields of the NIC. */=0A=
+	s2io_init_pci(sp);=0A=
+=0A=
+/*  Setting the device configuration parameters.=0A=
+ *  Most of these parameters can be specified by the user during module =0A=
+ *  insertion as they are module loadable parameters. If these =0A=
+ *  parameters are not not specified during load time, they are =
initalized=0A=
+ *  with default values.=0A=
+ */=0A=
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
+		if (config->TxCfg[i].FifoLen < 64) {=0A=
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
+/* Miscellaneous parameters.*/=0A=
+	config->RxVLANEnable =3D TRUE;=0A=
+	config->MTU =3D MAX_MTU_VLAN;=0A=
+	config->JumboEnable =3D FALSE;=0A=
+=0A=
+/*  Setting Mac Control parameters */=0A=
+	mac_control->txdl_len =3D MAX_SKB_FRAGS;=0A=
+	mac_control->rmac_pause_time =3D 0;=0A=
+=0A=
+/* Initialize Ring buffer parameters. */=0A=
+	for (i =3D 0; i < config->RxRingNum; i++)=0A=
+		atomic_set(&sp->rx_bufs_left[i], 0);=0A=
+=0A=
+/*  initialize the shared memory used by the NIC and the host */=0A=
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
+	sp =3D (nic_t *) dev->priv;=0A=
+=0A=
+/* Initializing the BAR1 address as the start of the FIFO pointer. */=0A=
+	for (j =3D 0; j < MAX_TX_FIFOS; j++) {=0A=
+		mac_control->tx_FIFO_start[j] =3D (TxFIFO_element_t *)=0A=
+		    (sp->bar1 + (j * 0x00020000));=0A=
+	}=0A=
+=0A=
+/*  Driver entry points */=0A=
+	dev->open =3D &s2io_open;=0A=
+	dev->stop =3D &s2io_close;=0A=
+	dev->hard_start_xmit =3D &s2io_xmit;=0A=
+	dev->get_stats =3D &s2io_get_stats;=0A=
+	dev->set_multicast_list =3D &s2io_set_multicast;=0A=
+	dev->do_ioctl =3D &s2io_ioctl;=0A=
+	dev->change_mtu =3D &s2io_change_mtu;=0A=
+#ifdef SET_ETHTOOL_OPS=0A=
+	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);=0A=
+#endif=0A=
+	/*=0A=
+	 * will use eth_mac_addr() for  dev->set_mac_address=0A=
+	 * mac address will be set every time dev->open() is called=0A=
+	 */=0A=
+#ifdef CONFIG_S2IO_NAPI=0A=
+	dev->poll =3D s2io_poll;=0A=
+	dev->weight =3D 128;	/* For now. */=0A=
+#endif=0A=
+=0A=
+	dev->features |=3D NETIF_F_SG | NETIF_F_HW_CSUM;=0A=
+	if (sp->high_dma_flag =3D=3D TRUE)=0A=
+		dev->features |=3D NETIF_F_HIGHDMA;=0A=
+#ifdef NETIF_F_TSO=0A=
+	dev->features |=3D NETIF_F_TSO;=0A=
+#endif=0A=
+=0A=
+	dev->tx_timeout =3D &s2io_tx_watchdog;=0A=
+	dev->watchdog_timeo =3D WATCH_DOG_TIMEOUT;=0A=
+=0A=
+	if (register_netdev(dev)) {=0A=
+		DBG_PRINT(ERR_DBG, "Device registration failed\n");=0A=
+		goto register_failed;=0A=
+	}=0A=
+=0A=
+	pci_save_state(sp->pdev, sp->config_space);=0A=
+=0A=
+/* Setting swapper control on the NIC, for proper reset operation */=0A=
+	if (s2io_set_swapper(sp)) {=0A=
+		DBG_PRINT(ERR_DBG, "%s:swapper settings are wrong\n",=0A=
+			  dev->name);=0A=
+		goto set_swap_failed;=0A=
+	}=0A=
+=0A=
+/* Fix for all "FFs" MAC address problems observed on Alpha platforms */=0A=
+	FixMacAddress(sp);=0A=
+	s2io_reset(sp);=0A=
+=0A=
+/* Setting swapper control on the NIC, so the MAC address can be read. =
*/=0A=
+	if (s2io_set_swapper(sp)) {=0A=
+		DBG_PRINT(ERR_DBG,=0A=
+			  "%s: S2IO: swapper settings are wrong\n",=0A=
+			  dev->name);=0A=
+		goto set_swap_failed;=0A=
+	}=0A=
+=0A=
+/*  MAC address initialization.=0A=
+ *  For now only one mac address will be read and used. */=0A=
+	bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
+	val64 =3D RMAC_ADDR_CMD_MEM_RD | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |=0A=
+	    RMAC_ADDR_CMD_MEM_OFFSET(0 + MAC_MAC_ADDR_START_OFFSET);=0A=
+	write64(&bar0->rmac_addr_cmd_mem, val64);=0A=
+	set_current_state(TASK_UNINTERRUPTIBLE);=0A=
+	schedule_timeout(HZ/2);	=0A=
+	tmp64 =3D read64(&bar0->rmac_addr_data0_mem);=0A=
+=0A=
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
+/*  Set the factory defined MAC address initially   */=0A=
+	dev->addr_len =3D ETH_ALEN;=0A=
+	memcpy(dev->dev_addr, sp->defMacAddr, ETH_ALEN);=0A=
+=0A=
+/*  Initialize the tasklet status flag and rst_timer flag*/=0A=
+	atomic_set(&(sp->tasklet_status), 0);=0A=
+	atomic_set(&(sp->rst_status), 0);=0A=
+=0A=
+=0A=
+/* Initialize spinlocks */=0A=
+	spin_lock_init(&sp->isr_lock);=0A=
+	spin_lock_init(&sp->tx_lock);=0A=
+=0A=
+	/* SXE-002: Configure link and activity LED to init state =0A=
+	 * on driver load. =0A=
+	 */=0A=
+	subid =3D sp->pdev->subsystem_device;=0A=
+	if ((subid & 0xFF) >=3D 0x07) {=0A=
+		val64 =3D read64(&bar0->gpio_control);=0A=
+		val64 |=3D 0x0000800000000000ULL;=0A=
+		write64(&bar0->gpio_control, val64);=0A=
+		val64 =3D 0x0411040400000000ULL;=0A=
+		write64((u64 *) ((u8 *) bar0 + 0x2700), val64);=0A=
+	}=0A=
+=0A=
+/* Make Link state as off at this point, when the Link change interrupt =
comes=0A=
+ * the state will be automatically changed to the right state.=0A=
+ */=0A=
+	netif_carrier_off(dev);=0A=
+=0A=
+	return SUCCESS;=0A=
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
+	sp =3D (nic_t *) dev->priv;=0A=
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
+int s2io_starter(void)=0A=
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
+=0A=
+/*  To build the driver, =0A=
+gcc -D__KERNEL__ -DMODULE -I/usr/src/linux-2.4/include -Wall =
-Wstrict-prototypes -O2 -c s2io.c=0A=
+*/=0A=
diff -urN vanilla-linux/drivers/net/s2io/s2io.h =
vanilla-linux-patch/drivers/net/s2io/s2io.h=0A=
--- vanilla-linux/drivers/net/s2io/s2io.h	1970-01-01 05:30:00.000000000 =
+0530=0A=
+++ vanilla-linux-patch/drivers/net/s2io/s2io.h	2004-02-27 =
20:48:05.000000000 +0530=0A=
@@ -0,0 +1,832 @@=0A=
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
+#ifndef ETH_ALEN=0A=
+#define ETH_ALEN    6=0A=
+#endif=0A=
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
+#ifndef SUPPORTED_10000baseT_Full=0A=
+#define SUPPORTED_10000baseT_Full (1 << 12)=0A=
+#endif=0A=
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
+	u32 rmac_ttl_128_255_frms_oflow;=0A=
+	u32 rmac_ttl_65_127_frms_oflow;=0A=
+	u64 rmac_ttl_128_255_frms;=0A=
+	u64 rmac_ttl_256_511_frms;=0A=
+	u64 reserved_6;=0A=
+	u32 rmac_ttl_512_1023_frms_oflow;=0A=
+	u32 rmac_ttl_256_511_frms_oflow;=0A=
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
+/*  Place holders for the virtual and physical addresses of all the=0A=
+ *  Rx Blocks */=0A=
+	struct rx_block_info=0A=
+	 rx_blocks[MAX_RX_RINGS][MAX_RX_BLOCKS_PER_RING];=0A=
+	int block_count[MAX_RX_RINGS];=0A=
+	int pkt_cnt[MAX_RX_RINGS];=0A=
+=0A=
+/* 	Id timer, used to blink NIC to physically identify NIC. */=0A=
+	struct timer_list id_timer;=0A=
+=0A=
+/* 	Restart timer, used to restart NIC if the device is stuck. */=0A=
+	struct timer_list rst_timer;=0A=
+=0A=
+/*	Atomic variable which tracks if the rst_timer has been scheduled=0A=
+ 	to run or not. */=0A=
+	atomic_t rst_status;=0A=
+=0A=
+/*	after blink, the adapter must be restored with original values. */=0A=
+	u64 adapt_ctrl_org;=0A=
+} nic_t;			// __cacheline_aligned;=0A=
+=0A=
+#define RESET_ERROR 1;=0A=
+#define CMD_ERROR   2;=0A=
+=0A=
+/* Default Tunable parameters of the NIC. */=0A=
+#define DEFAULT_FIFO_LEN 4096=0A=
+#define SMALL_RXD_CNT	10 * (MAX_RXDS_PER_BLOCK+1)=0A=
+#define LARGE_RXD_CNT	100 * (MAX_RXDS_PER_BLOCK+1)=0A=
+=0A=
+/*  OS related system calls */=0A=
+=0A=
+#ifndef readq=0A=
+static inline u64 read64(void *addr)=0A=
+{=0A=
+	u64 ret =3D 0;=0A=
+	ret =3D readl(addr + 4);=0A=
+	(u64) ret <<=3D 32;=0A=
+	(u64) ret |=3D readl(addr);=0A=
+=0A=
+	return ret;=0A=
+}=0A=
+#else=0A=
+static inline u64 read64(void *addr)=0A=
+{=0A=
+	u64 ret =3D readq(addr);=0A=
+	return ret;=0A=
+}=0A=
+#endif=0A=
+#define read32(addr, ret)  ret =3D  readl(addr);=0A=
+#define read16(addr, ret)  ret =3D  readw(addr);=0A=
+#define read8(addr, ret)   ret =3D  readb(addr);=0A=
+=0A=
+#ifndef writeq=0A=
+static inline void write64(void *addr, u64 val)=0A=
+{=0A=
+	writel((u32) (val), addr);=0A=
+	writel((u32) (val >> 32), (addr + 4));=0A=
+}=0A=
+#else=0A=
+#define write64(addr, ret) writeq(ret,(void *)addr)=0A=
+#endif=0A=
+#define write32(addr, ret) writel(ret,(void *)addr);=0A=
+#define write16(addr, ret) writew(ret,(void *)addr);=0A=
+#define write8(addr, ret)  writeb(ret,(void *)addr);=0A=
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
+#endif				/* _S2IO_H */=0A=
diff -urN vanilla-linux/drivers/net/s2io/sysctl_xframe.conf =
vanilla-linux-patch/drivers/net/s2io/sysctl_xframe.conf=0A=
--- vanilla-linux/drivers/net/s2io/sysctl_xframe.conf	1970-01-01 =
05:30:00.000000000 +0530=0A=
+++ vanilla-linux-patch/drivers/net/s2io/sysctl_xframe.conf	2004-02-27 =
20:28:11.000000000 +0530=0A=
@@ -0,0 +1,21 @@=0A=
+# some of the defaults may be different for your kernel=0A=
+# call this file with sysctl -p <this file>=0A=
+# these are just suggested values that worked well to increase =
throughput in=0A=
+# several network benchmark tests, your mileage may vary=0A=
+                                                                        =
        =0A=
+### IPV4 specific settings=0A=
+net.ipv4.tcp_timestamps =3D 0 # turns TCP timestamp support off, =
default 1, reduces CPU use=0A=
+net.ipv4.tcp_sack =3D 0 # turn SACK support off, default on=0A=
+# on systems with a VERY fast bus -> memory interface this is the big =
gainer=0A=
+net.ipv4.tcp_rmem =3D 10000000 10000000 10000000 # sets min/default/max =
TCP read buffer, default 4096 87380 174760=0A=
+net.ipv4.tcp_wmem =3D 10000000 10000000 10000000 # sets =
min/pressure/max TCP write buffer, default 4096 16384 131072=0A=
+net.ipv4.tcp_mem =3D 10000000 10000000 10000000 # sets min/pressure/max =
TCP buffer space, default 31744 32256 32768=0A=
+                                                                        =
        =0A=
+### CORE settings (mostly for socket and UDP effect)=0A=
+net.core.rmem_max =3D 524287 # maximum receive socket buffer size, =
default 131071=0A=
+net.core.wmem_max =3D 524287 # maximum send socket buffer size, default =
131071=0A=
+net.core.rmem_default =3D 524287 # default receive socket buffer size, =
default 65535=0A=
+net.core.wmem_default =3D 524287 # default send socket buffer size, =
default 65535=0A=
+net.core.optmem_max =3D 524287 # maximum amount of option memory =
buffers, default 10240=0A=
+net.core.netdev_max_backlog =3D 300000 # number of unprocessed input =
packets before kernel starts dropping them, default 300=0A=
+=0A=

------=_NextPart_000_0001_01C3FDC9.A17689E0--
