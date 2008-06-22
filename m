From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [RFC/PATCH] ipg: add jumbo frame support kconfig option
Date: Sun, 22 Jun 2008 12:23:21 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806221220540.27261@sbz-30.cs.Helsinki.FI>
References: <200806201037.46687.Bircoph@list.ru>
 <84144f020806200412s5e0225eblbb2001ca139e7fdc@mail.gmail.com>
 <20080620084131.3313abe8@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Savchenko <Bircoph@list.ru>, linux-kernel@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	shemminger@vyatta.com, Jeff Garzik <jeff@garzik.org>,
	sorbica@icplus.com.tw, Jesse Huang <jesse@icplus.com.tw>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44203 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144AbYFVJXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2008 05:23:23 -0400
In-Reply-To: <20080620084131.3313abe8@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Jun 2008, Stephen Hemminger wrote:
> The code should enable/disable anything it needs based on the MTU size
> in the change_mtu call. If the driver needs to reallocate buffers, change receiver
> settings, make sacrifices to deities, or phone home that is the place to do it.
> In other words no compile or config option fro MTU settings please.

Right, so how about something like this instead? Andrew, can you test the 
following patch? You need all the other patches from the previous series 
modulo the last patch. Thanks!

		Pekka

Subject: [PATCH] ipg: run-time configurable jumbo frame support
From: Pekka Enberg <penberg@cs.helsinki.fi>

Make jumbo frame support configurable via ifconfig mtu option as suggested by
Stephen Hemminger.

Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 drivers/net/ipg.c |   42 ++++++++++++++++++++------
 drivers/net/ipg.h |   85 ------------------------------------------------------
 2 files changed, 32 insertions(+), 95 deletions(-)

Index: linux-2.6/drivers/net/ipg.c
===================================================================
--- linux-2.6.orig/drivers/net/ipg.c	2008-06-22 11:55:53.000000000 +0300
+++ linux-2.6/drivers/net/ipg.c	2008-06-22 12:15:45.000000000 +0300
@@ -42,7 +42,6 @@
 #define ipg_r16(reg)		ioread16(ioaddr + (reg))
 #define ipg_r8(reg)		ioread8(ioaddr + (reg))
 
-#define JUMBO_FRAME_4k_ONLY
 enum {
 	netdev_io_size = 128
 };
@@ -55,6 +54,14 @@
 MODULE_LICENSE("GPL");
 
 /*
+ * Defaults
+ */
+#define IPG_MAX_RXFRAME_SIZE	0x0600
+#define IPG_RXFRAG_SIZE		0x0600
+#define IPG_RXSUPPORT_SIZE	0x0600
+#define IPG_IS_JUMBO		false
+
+/*
  * Variable record -- index by leading revision/length
  * Revision/Length(=N*4), Address1, Data1, Address2, Data2,...,AddressN,DataN
  */
@@ -1805,9 +1812,6 @@
 	sp->jumbo.current_size = 0;
 	sp->jumbo.skb = NULL;
 
-	if (IPG_TXFRAG_SIZE)
-		dev->mtu = IPG_TXFRAG_SIZE;
-
 	/* Enable transmit and receive operation of the IPG. */
 	ipg_w32((ipg_r32(MAC_CTRL) | IPG_MC_RX_ENABLE | IPG_MC_TX_ENABLE) &
 		 IPG_MC_RSVD_MASK, MAC_CTRL);
@@ -2116,6 +2120,7 @@
 static int ipg_nic_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
+	int err;
 
 	/* Function to accomodate changes to Maximum Transfer Unit
 	 * (or MTU) of IPG NIC. Cannot use default function since
@@ -2124,16 +2129,33 @@
 
 	IPG_DEBUG_MSG("_nic_change_mtu\n");
 
-	/* Check that the new MTU value is between 68 (14 byte header, 46
-	 * byte payload, 4 byte FCS) and IPG_MAX_RXFRAME_SIZE, which
-	 * corresponds to the MAXFRAMESIZE register in the IPG.
+	/*
+	 * Check that the new MTU value is between 68 (14 byte header, 46 byte
+	 * payload, 4 byte FCS) and 10 KB, which is the largest supported MTU.
 	 */
-	if ((new_mtu < 68) || (new_mtu > sp->max_rxframe_size))
+	if (new_mtu < 68 || new_mtu > 10240)
 		return -EINVAL;
 
+	err = ipg_nic_stop(dev);
+	if (err)
+		return err;
+
 	dev->mtu = new_mtu;
 
-	return 0;
+	sp->max_rxframe_size = new_mtu;
+
+	sp->rxfrag_size = new_mtu;
+	if (sp->rxfrag_size > 4088)
+		sp->rxfrag_size = 4088;
+
+	sp->rxsupport_size = sp->max_rxframe_size;
+
+	if (new_mtu > 0x0600)
+		sp->is_jumbo = true;
+	else
+		sp->is_jumbo = false;
+
+	return ipg_nic_open(dev);
 }
 
 static int ipg_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -2238,7 +2260,7 @@
 	spin_lock_init(&sp->lock);
 	mutex_init(&sp->mii_mutex);
 
-	sp->is_jumbo = IPG_JUMBO;
+	sp->is_jumbo = IPG_IS_JUMBO;
 	sp->rxfrag_size = IPG_RXFRAG_SIZE;
 	sp->rxsupport_size = IPG_RXSUPPORT_SIZE;
 	sp->max_rxframe_size = IPG_MAX_RXFRAME_SIZE;
Index: linux-2.6/drivers/net/ipg.h
===================================================================
--- linux-2.6.orig/drivers/net/ipg.h	2008-06-22 11:55:53.000000000 +0300
+++ linux-2.6/drivers/net/ipg.h	2008-06-22 11:55:54.000000000 +0300
@@ -536,91 +536,6 @@
  */
 #define		IPG_FRAMESBETWEENTXDMACOMPLETES 0x1
 
-#ifdef JUMBO_FRAME
-# define IPG_JUMBO true
-#else
-# define IPG_JUMBO false
-#endif
-
-#ifdef JUMBO_FRAME
-
-# ifdef JUMBO_FRAME_SIZE_2K
-# define JUMBO_FRAME_SIZE 2048
-# define __IPG_RXFRAG_SIZE 2048
-# else
-#  ifdef JUMBO_FRAME_SIZE_3K
-#  define JUMBO_FRAME_SIZE 3072
-#  define __IPG_RXFRAG_SIZE 3072
-#  else
-#   ifdef JUMBO_FRAME_SIZE_4K
-#   define JUMBO_FRAME_SIZE 4096
-#   define __IPG_RXFRAG_SIZE 4088
-#   else
-#    ifdef JUMBO_FRAME_SIZE_5K
-#    define JUMBO_FRAME_SIZE 5120
-#    define __IPG_RXFRAG_SIZE 4088
-#    else
-#     ifdef JUMBO_FRAME_SIZE_6K
-#     define JUMBO_FRAME_SIZE 6144
-#     define __IPG_RXFRAG_SIZE 4088
-#     else
-#      ifdef JUMBO_FRAME_SIZE_7K
-#      define JUMBO_FRAME_SIZE 7168
-#      define __IPG_RXFRAG_SIZE 4088
-#      else
-#       ifdef JUMBO_FRAME_SIZE_8K
-#       define JUMBO_FRAME_SIZE 8192
-#       define __IPG_RXFRAG_SIZE 4088
-#       else
-#        ifdef JUMBO_FRAME_SIZE_9K
-#        define JUMBO_FRAME_SIZE 9216
-#        define __IPG_RXFRAG_SIZE 4088
-#        else
-#         ifdef JUMBO_FRAME_SIZE_10K
-#         define JUMBO_FRAME_SIZE 10240
-#         define __IPG_RXFRAG_SIZE 4088
-#         else
-#         define JUMBO_FRAME_SIZE 4096
-#         endif
-#        endif
-#       endif
-#      endif
-#     endif
-#    endif
-#   endif
-#  endif
-# endif
-#endif
-
-/* Size of allocated received buffers. Nominally 0x0600.
- * Define larger if expecting jumbo frames.
- */
-#ifdef JUMBO_FRAME
-/* IPG_TXFRAG_SIZE must <= 0x2b00, or TX will crash */
-#define		IPG_TXFRAG_SIZE		JUMBO_FRAME_SIZE
-#else
-#define		IPG_TXFRAG_SIZE		0 /* use default MTU */
-#endif
-
-/* Size of allocated received buffers. Nominally 0x0600.
- * Define larger if expecting jumbo frames.
- */
-#ifdef JUMBO_FRAME
-/* 4088 = 4096 - 8 */
-#define		IPG_RXFRAG_SIZE		__IPG_RXFRAG_SIZE
-#define     IPG_RXSUPPORT_SIZE   IPG_MAX_RXFRAME_SIZE
-#else
-#define		IPG_RXFRAG_SIZE		0x0600
-#define     IPG_RXSUPPORT_SIZE   IPG_RXFRAG_SIZE
-#endif
-
-/* IPG_MAX_RXFRAME_SIZE <= IPG_RXFRAG_SIZE */
-#ifdef JUMBO_FRAME
-#define		IPG_MAX_RXFRAME_SIZE		JUMBO_FRAME_SIZE
-#else
-#define		IPG_MAX_RXFRAME_SIZE		0x0600
-#endif
-
 #define		IPG_RFDLIST_LENGTH		0x100
 
 /* Maximum number of RFDs to process per interrupt.
