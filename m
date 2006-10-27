From: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>
Subject: [PATCH 7/9] NetEffect 10Gb RNIC Driver: utility routines c file
Date: Thu, 26 Oct 2006 19:25:46 -0500
Message-ID: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EC1@venom2>
Reply-To: <glenng@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.neteffect.com ([204.57.75.68]:52959 "EHLO
	mail2.neteffect.com") by vger.kernel.org with ESMTP
	id S1946057AbWJ0AZs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 20:25:48 -0400
Content-class: urn:content-classes:message
To: <openib-general@openib.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kernel driver patch 7 of 9.

Signed-off-by: Glenn Grundstrom <glenng@neteffect.com>

======================================================

diff -ruNp old/drivers/infiniband/hw/nes/nes_utils.c
new/drivers/infiniband/hw/nes/nes_utils.c
--- old/drivers/infiniband/hw/nes/nes_utils.c	1969-12-31
18:00:00.000000000 -0600
+++ new/drivers/infiniband/hw/nes/nes_utils.c	2006-10-25
10:15:51.000000000 -0500
@@ -0,0 +1,488 @@
+/*
+ * Copyright (c) 2006 NetEffect, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/if_vlan.h>
+#include <linux/crc32.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/init.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/byteorder.h>
+
+#include <rdma/ib_smi.h>
+#include <rdma/ib_verbs.h>
+#include <rdma/ib_pack.h>
+#include <rdma/iw_cm.h>
+#include "nes.h"
+#include "nes_verbs.h"
+
+#define BITMASK(X)     (1L << (X))
+#define NES_CRC_WID     32
+
+static u32 nesCRCTable[256];
+static u32 nesCRCInitialized = 0;
+
+static u32 nesCRCWidMask(u32);
+static u32 nes_crc_table_gen(u32 *, u32, u32, u32);
+static u32 reflect(u32, u32);
+static u32 byte_swap(u32, u32);
+
+
+/**
+ * nes_read_eeprom_values -
+ * 
+ * @param nesdev
+ * 
+ * @return int
+ */
+int nes_read_eeprom_values(struct nes_dev *nesdev)
+{
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	u32 mac_addr_low;
+	u16 mac_addr_high;
+	u16 eeprom_data;
+	u16 eeprom_offset;
+
+	if (0 == nesadapter->firmware_eeprom_offset) {
+		/* Read the EEPROM Parameters */
+		eeprom_data = nes_read16_eeprom(nesdev->regs, 0);
+		dprintk("EEPROM Offset 0  = 0x%04X\n", eeprom_data);
+		eeprom_offset = 2 + (((eeprom_data &
0x007f)<<3)<<((eeprom_data & 0x0080)>>7));
+		dprintk("Firmware Offset = 0x%04X\n", eeprom_offset);
+		nesadapter->firmware_eeprom_offset = eeprom_offset;
+		eeprom_data = nes_read16_eeprom(nesdev->regs,
eeprom_offset+4);
+		if (eeprom_data != 0x5746) {
+			dprintk("Not a valid Firmware Image = 0x%04X\n",
eeprom_data);
+			return -1;
+		}
+
+		eeprom_data = nes_read16_eeprom(nesdev->regs,
eeprom_offset+2);
+		dprintk("EEPROM Offset %u  = 0x%04X\n", eeprom_offset+2,
eeprom_data);
+		eeprom_offset += ((eeprom_data &
0x00ff)<<3)<<((eeprom_data & 0x0100)>>8);
+		dprintk("Software Offset = 0x%04X\n", eeprom_offset);
+		nesadapter->software_eeprom_offset = eeprom_offset;
+		eeprom_data = nes_read16_eeprom(nesdev->regs,
eeprom_offset);
+		dprintk("EEPROM Offset %u  = 0x%04X\n", eeprom_offset,
eeprom_data);
+		eeprom_data = nes_read16_eeprom(nesdev->regs,
eeprom_offset+4);
+		if (eeprom_data != 0x5753) {
+			dprintk("Not a valid Software Image = 0x%04X\n",
eeprom_data);
+			return -1;
+		}
+
+		eeprom_offset = nesadapter->software_eeprom_offset;
+		eeprom_offset += 10;
+		mac_addr_high = nes_read16_eeprom(nesdev->regs,
eeprom_offset);
+		eeprom_offset += 2;
+		mac_addr_low = (u32)nes_read16_eeprom(nesdev->regs,
eeprom_offset);
+		eeprom_offset += 2;
+		mac_addr_low <<= 16;
+		mac_addr_low += (u32)nes_read16_eeprom(nesdev->regs,
eeprom_offset);
+		dprintk("MAC Address = 0x%04X%08X\n", mac_addr_high,
mac_addr_low);
+
+		nesadapter->mac_addr_low = mac_addr_low;
+		nesadapter->mac_addr_high = mac_addr_high;
+   }
+
+	/* TODO: Get this from EEPROM */
+	nesdev->nesadapter->phy_index[0] = 6;
+
+	/* TODO: get this from EEPROM and stop setting in init loop */
+	nesdev->base_doorbell_index = 1;
+
+	return 0;   
+}
+
+
+
+
+/**
+ * nes_write_10G_phy_reg
+ * 
+ * @param addr
+ * @param phy_reg
+ * @param phy_addr
+ * @param data
+ */
+void nes_write_10G_phy_reg(void __iomem *addr, u16 phy_reg, u8
phy_addr, u16 data)
+{
+	u32 dev_addr;
+	u32 port_addr;
+	u32 u32temp;
+	u32 counter;
+
+	dev_addr = 5;
+	port_addr = 0;
+
+	// set address
+	nes_write_indexed(addr, NES_IDX_MAC_MDIO_CONTROL, 0x00020000 |
phy_reg | (dev_addr<<18) | (port_addr<<23));
+	for (counter=0; counter<100 ; counter++ ) {
+		udelay(30);
+		u32temp = nes_read_indexed(addr,
NES_IDX_MAC_INT_STATUS);
+		if (u32temp & 1) {
+//		 dprintk("Address phase; Phy interrupt status =
0x%X.\n", u32temp);
+			nes_write_indexed(addr, NES_IDX_MAC_INT_STATUS,
1);
+			break;
+		}
+	}
+	if (!(u32temp & 1))	dprintk("Phy is not responding.
interrupt status = 0x%X.\n", u32temp);
+
+	// set data
+	nes_write_indexed(addr, NES_IDX_MAC_MDIO_CONTROL, 0x10020000 |
data | (dev_addr<<18) | (port_addr<<23) );
+	for (counter=0; counter<100 ; counter++ ) {
+		udelay(30);
+		u32temp = nes_read_indexed(addr,
NES_IDX_MAC_INT_STATUS);
+		if (u32temp & 1) {
+//         dprintk("Write phase; Phy interrupt status = 0x%X.\n",
u32temp);
+			nes_write_indexed(addr, NES_IDX_MAC_INT_STATUS,
1);
+			break;
+		}
+	}
+	if (!(u32temp & 1))
+		dprintk("Phy is not responding. interrupt status =
0x%X.\n", u32temp);
+}
+
+
+/**
+ * nes_read_1G_phy_reg
+ * This routine only issues the read, the data must be read
+ * separately.
+ * 
+ * @param addr
+ * @param phy_reg
+ * @param phy_addr
+ */
+void nes_read_10G_phy_reg(void __iomem *addr, u16 phy_reg, u8 phy_addr)
+{
+	u32 dev_addr;
+	u32 port_addr;
+	u32 u32temp;
+	u32 counter;
+
+	dev_addr = 5;
+	port_addr = 0;
+
+	// set address
+	nes_write_indexed(addr, NES_IDX_MAC_MDIO_CONTROL, 0x00020000 |
phy_reg | (dev_addr<<18) | (port_addr<<23));
+	for (counter=0; counter<100 ; counter++ ) {
+		udelay(30);
+		u32temp = nes_read_indexed(addr,
NES_IDX_MAC_INT_STATUS);
+		if (u32temp & 1) {
+//		 dprintk("Address phase; Phy interrupt status =
0x%X.\n", u32temp);
+			nes_write_indexed(addr, NES_IDX_MAC_INT_STATUS,
1);
+			break;
+		}
+	}
+	if (!(u32temp & 1))	dprintk("Phy is not responding.
interrupt status = 0x%X.\n", u32temp);
+
+	// issue read
+	nes_write_indexed(addr, NES_IDX_MAC_MDIO_CONTROL, 0x30020000 |
(dev_addr<<18) | (port_addr<<23));
+	for (counter=0; counter<100 ; counter++ ) {
+		udelay(30);
+		u32temp = nes_read_indexed(addr,
NES_IDX_MAC_INT_STATUS);
+		if (u32temp & 1) {
+//         dprintk("Read phase; Phy interrupt status = 0x%X.\n",
u32temp);
+			nes_write_indexed(addr, NES_IDX_MAC_INT_STATUS,
1);
+			break;
+		}
+	}
+	if (!(u32temp & 1))
+		dprintk("Phy is not responding. interrupt status =
0x%X.\n", u32temp);
+}
+
+
+/**
+ * nes_arp_table_update
+ * 
+ * @param nesdev
+ * @param ip_address
+ * @param action
+ * 
+ * @return u16
+ */
+u16 nes_arp_table_update(struct nes_dev *nesdev, u32 ip_address, u32
action)
+{
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+	u32 arp_index = 0;
+	int err=0;
+
+	// dprintk("%s: ip_address=%08X, action=%d\n", __FUNCTION__,
ip_address, action);
+
+	if (action == NES_ARP_INDEX_ADD) {
+		err = nes_alloc_resource(nesadapter,
nesadapter->allocated_arps, nesadapter->arp_table_size, &arp_index,
+
&nesadapter->arp_index);
+		if (err) {
+			dprintk("%s: nes_alloc_resource returned error =
%u\n", __FUNCTION__, err);
+			return ((u16)((u32)ERR_PTR(err)));
+		}
+		dprintk("nes_arp_table_update: ADD, ip_address=%08X,
arp_index=%d\n", ip_address, arp_index);
+
+		nesadapter->arp_table[arp_index].ip_address =
ip_address;
+		return ((u16)arp_index);
+	}
+
+	// DELETE or RESOLVE
+	for (arp_index = 0; arp_index < nesadapter->arp_table_size;
arp_index++) {
+		if (nesadapter->arp_table[arp_index].ip_address ==
ip_address)
+			break;
+	}
+
+	if (arp_index == nesadapter->arp_table_size)
+		return (nesadapter->arp_table_size); 		// did
not find ip address; return something else?
+
+	if (action == NES_ARP_INDEX_DELETE) {
+		dprintk("nes_arp_table_update: DELETE, ip_address=%08X,
arp_index=%d\n", ip_address, arp_index);
+		nesadapter->arp_table[arp_index].ip_address = 0;
+		nes_free_resource(nesadapter,
nesadapter->allocated_arps, arp_index);
+		return (0);
+	}
+
+	if (action == NES_ARP_INDEX_RESOLVE) {
+		dprintk("nes_arp_table_update: RESOLVE, ip_address=%08X,
arp_index=%d\n", ip_address, arp_index);
+		return ((u16)arp_index);
+	}
+
+	return (err); 
+}
+
+
+/*
+"Everything you wanted to know about CRC algorithms, but were afraid to
ask
+ for fear that errors in your understanding might be detected." Version
: 3.
+Date  : 19 August 1993.  
+Author  : Ross N. Williams.  
+Net  : ross@guest.adelaide.edu.au.  
+FTP  : ftp.adelaide.edu.au/pub/rocksoft/crc_v3.txt  
+Company  : Rocksoft(tm) Pty Ltd.  
+Snail  : 16 Lerwick Avenue, Hazelwood Park 5066, Australia.  
+Fax  : +61 8 373-4911 (c/- Internode Systems Pty Ltd).  
+Phone  : +61 8 379-9217 (10am to 10pm Adelaide Australia time).  
+Note  : "Rocksoft" is a trademark of Rocksoft Pty Ltd, Australia.  
+Status  : Copyright (C) Ross Williams, 1993. However, permission is
granted to
+ make and distribute verbatim copies of this document provided that
this information
+ block and copyright notice is included. Also, the C code modules
included in this
+ document are fully public domain.  
+ 
+Thanks  : Thanks to Jean-loup Gailly (jloup@chorus.fr) and Mark Adler
+ (me@quest.jpl.nasa.gov) who both proof read this document and picked
+ out lots of nits as well as some big fat bugs.  
+
+The current web page for this seems to be
http://www.ross.net/crc/crcpaper.html.
+
+*/
+
+/**********************************************************************
******/
+/*                            Generate width mask
*/
+/**********************************************************************
******/
+/*
*/
+/* Returns a longword whose value is (2^p_cm->cm_width)-1.
*/
+/* The trick is to do this portably (e.g. without doing <<32).
*/
+/*
*/
+/* Author:  Tristan Gross
*/
+/* Source:  "A PAINLESS GUIDE TO CRC ERROR DETECTION ALGORITHMS"
*/
+/*          Ross N. Williams
*/
+/*          http://www.rocksoft.com
*/
+/*
*/
+/**********************************************************************
******/
+
+static u32 nesCRCWidMask (u32 width)
+{
+	return (((1L<<(((u32)width)-1))-1L)<<1)|1L;
+}
+
+
+/**********************************************************************
******/
+/*                             Generate CRC table
*/
+/**********************************************************************
******/
+/*
*/
+/* Source:  "A PAINLESS GUIDE TO CRC ERROR DETECTION ALGORITHMS"
*/
+/*          Ross N. Williams
*/
+/*          http://www.rocksoft.com
*/
+/*
*/
+/**********************************************************************
******/
+static u32 nes_crc_table_gen ( u32 *pCRCTable,
+                        u32  poly,
+                        u32  order,
+                        u32  reflectIn)
+{
+	u32 i;
+	u32 reg;
+	u32 byte;
+	u32 topbit = BITMASK(NES_CRC_WID-1);
+	u32 tmp;
+
+	for (byte=0;byte<256;byte++) { 
+
+		// If we need to creat a reflected table we must reflect
the index (byte) and 
+		// reflect the final reg
+		tmp = (reflectIn) ? reflect(byte,8): byte;
+
+		reg = tmp << (NES_CRC_WID-8);
+
+		for (i=0; i<8; i++) {
+			if (reg & topbit) {
+				reg = (reg << 1) ^ poly;
+			}
+			else {
+				reg <<= 1;
+			}
+		}
+
+		reg = (reflectIn) ?  reflect(reg,order): reg;
+		pCRCTable[byte] = reg & nesCRCWidMask(NES_CRC_WID);
+	}
+
+  return(0);
+}
+
+
+/**********************************************************************
******/
+/*                    Perform 32 bit based CRC calculation
*/
+/**********************************************************************
******/
+/*
*/
+/* Source:  "A PAINLESS GUIDE TO CRC ERROR DETECTION ALGORITHMS"
*/
+/*          Ross N. Williams
*/
+/*          http://www.rocksoft.com
*/
+/*
*/
+/* This performs a standard 32 bit crc on an array of arbitrary length
*/
+/* with an arbitrary initial value and passed generator polynomial
*/
+/* in the form of a crc table.
*/
+/*
*/
+/**********************************************************************
******/
+static u32 reflect (u32 data, u32 num)
+{
+	// Reflects the lower num bits in 'data' around their center
point.
+	u32 i;
+	u32 j      = 1;
+	u32 result = 0;
+
+	for (i=(u32)1<<(num-1); i; i>>=1) {
+		if (data & i) result|=j;
+		j <<= 1;
+	}
+	return (result);
+}
+
+
+/**
+ * byte_swap
+ * 
+ * @param data
+ * @param num
+ * 
+ * @return u32
+ */
+static u32 byte_swap (u32 data, u32 num)
+{ 
+    u32 i;
+    u32 result = 0;
+
+    if (num%16) {
+        dprintk("\nbyte_swap: ERROR: num is not an even number of
bytes\n");
+//        ASSERT(0);
+    }
+
+    for(i=0;i<num;i+=8) {
+        result |= (0xFF & (data >> i)) << (num-8-i);
+    }
+
+    return (result);
+}
+
+
+/**
+ * nes_crc32 - 
+ * This is a reflected table algorithm. ReflectIn basically means to
reflect each incomming byte of
+ * the data. But to make things more complicated,  we can instead
reflect the initial value, 
+ * the final crc, and shift data to the right using a reflected
pCRCTable. CRC is FUN!!
+ *
+ * @param reverse
+ * @param initialValue
+ * @param finalXOR
+ * @param messageLength
+ * @param pMessage
+ * @param order
+ * @param reflectIn
+ * @param reflectOut
+ * 
+ * @return u32
+ */
+u32 nes_crc32 (   u32  reverse,
+                  u32  initialValue,
+                  u32  finalXOR,
+                  u32  messageLength,
+                  u8  *pMessage,
+                  u32  order,
+                  u32  reflectIn,
+                  u32  reflectOut)
+
+{
+	u8     *pBlockAddr = pMessage;
+	u32     mlen       = messageLength;
+	u32     crc;
+
+	if (0 == nesCRCInitialized) {
+		nes_crc_table_gen( &nesCRCTable[0], CRC32C_POLY, ORDER,
REFIN );
+		nesCRCInitialized = 1;
+	}
+
+	crc = (reflectIn) ? reflect(initialValue,order): initialValue;
+
+	while (mlen--) {
+		//printf("byte = %x, index = %u, crctable[index] =
%x\n", *pBlockAddr, (crc & 0xffL) ^ *pBlockAddr, nesCRCTable[(crc &
0xffL) ^ *pBlockAddr]);
+		if (reflectIn) {
+			crc = nesCRCTable[(crc & 0xffL ) ^
*pBlockAddr++] ^ (crc >> 8);
+		}
+		else { 
+			crc = nesCRCTable[((crc>>24) ^ *pBlockAddr++) &
0xFFL] ^ (crc << 8);
+		}
+	}
+ 
+	// if reflectOut and reflectIn are both set, we don't
+	// do anything since reflecting twice effectively does nothing.
+	crc = ((reflectIn)^(reflectOut)) ? reflect(crc,order): crc;
+ 
+	crc = crc^finalXOR;
+ 
+	// We don't really use this, but it is here for completeness
+	crc = (reverse) ? byte_swap(crc,32): crc;
+
+	return crc;
+}
+


