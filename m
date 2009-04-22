From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH] smsc911x: add fifo byteswap support
Date: Wed, 22 Apr 2009 23:55:53 +0900
Message-ID: <20090422145553.25073.99410.sendpatchset@rx1.opensource.se>
Cc: steve.glendinning@smsc.com, Magnus Damm <magnus.damm@gmail.com>,
	lethal@linux-sh.org, davem@davemloft.net, iwamatsu@nigauri.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:33336 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739AbZDVO6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 10:58:39 -0400
Received: by wa-out-1112.google.com with SMTP id j5so2395wah.21
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2009 07:58:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Damm <damm@igel.co.jp>

This patch adds fifo byteswap support to the smsc911x driver.

The smsc911x hardware supports both big and little and endian
hardware configurations, and the linux smsc911x driver currently
detects word order.

For correct operation on big endian platforms lacking swapped
byte lanes the following patch is needed. Only fifo data is
swapped, register data does not require any swapping. 

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 Platform data for the rsk7203 board will be posted separately
 to the linux-sh in the near future.

 drivers/net/smsc911x.c   |   13 +++++++++++++
 include/linux/smsc911x.h |    1 +
 2 files changed, 14 insertions(+)

--- 0001/drivers/net/smsc911x.c
+++ work/drivers/net/smsc911x.c	2009-04-21 20:06:35.000000000 +0900
@@ -47,6 +47,7 @@
 #include <linux/bitops.h>
 #include <linux/irq.h>
 #include <linux/io.h>
+#include <linux/swab.h>
 #include <linux/phy.h>
 #include <linux/smsc911x.h>
 #include "smsc911x.h"
@@ -175,6 +176,12 @@ static inline void
 smsc911x_tx_writefifo(struct smsc911x_data *pdata, unsigned int *buf,
 		      unsigned int wordcount)
 {
+	if (pdata->config.flags & SMSC911X_SWAP_FIFO) {
+		while (wordcount--)
+			smsc911x_reg_write(pdata, TX_DATA_FIFO, swab32(*buf++));
+		return;
+	}
+
 	if (pdata->config.flags & SMSC911X_USE_32BIT) {
 		writesl(pdata->ioaddr + TX_DATA_FIFO, buf, wordcount);
 		return;
@@ -194,6 +201,12 @@ static inline void
 smsc911x_rx_readfifo(struct smsc911x_data *pdata, unsigned int *buf,
 		     unsigned int wordcount)
 {
+	if (pdata->config.flags & SMSC911X_SWAP_FIFO) {
+		while (wordcount--)
+			*buf++ = swab32(smsc911x_reg_read(pdata, RX_DATA_FIFO));
+		return;
+	}
+
 	if (pdata->config.flags & SMSC911X_USE_32BIT) {
 		readsl(pdata->ioaddr + RX_DATA_FIFO, buf, wordcount);
 		return;
--- 0001/include/linux/smsc911x.h
+++ work/include/linux/smsc911x.h	2009-04-21 20:07:57.000000000 +0900
@@ -46,5 +46,6 @@ struct smsc911x_platform_config {
 #define SMSC911X_FORCE_INTERNAL_PHY		(BIT(2))
 #define SMSC911X_FORCE_EXTERNAL_PHY 		(BIT(3))
 #define SMSC911X_SAVE_MAC_ADDRESS		(BIT(4))
+#define SMSC911X_SWAP_FIFO			(BIT(5))
 
 #endif /* __LINUX_SMSC911X_H__ */
