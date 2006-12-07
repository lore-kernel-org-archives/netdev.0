From: Ralf Baechle <ralf@linux-mips.org>
Subject: [AX.25] Fix default address and broadcast address initialization
Date: Thu, 7 Dec 2006 23:45:59 +0000
Message-ID: <20061207234559.GA15282@linux-mips.org>
References: <20061207234057.GA15220@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:38499 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1164013AbWLGXqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 18:46:05 -0500
Received: from localhost.localdomain ([127.0.0.1]:17568 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20037862AbWLGXqE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 23:46:04 +0000
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20061207234057.GA15220@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only the callsign but not the SSID part of an AX.25 address is ASCII
based but Linux by initializes the SSID which should be just a 4-bit
number from ASCII anyway.

Fix that and convert the code to use a shared constant for both default
addresses.  While at it, use the same style for null_ax25_address also.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 drivers/net/hamradio/6pack.c      |    9 ++-------
 drivers/net/hamradio/baycom_epp.c |   10 ++--------
 drivers/net/hamradio/bpqether.c   |    9 ++-------
 drivers/net/hamradio/dmascc.c     |   10 ++--------
 drivers/net/hamradio/hdlcdrv.c    |   16 ++--------------
 drivers/net/hamradio/mkiss.c      |    9 ++-------
 drivers/net/hamradio/scc.c        |    9 ++-------
 drivers/net/hamradio/yam.c        |    9 ++-------
 include/net/ax25.h                |    6 +++---
 net/ax25/ax25_addr.c              |   15 ++++++++++++---
 10 files changed, 31 insertions(+), 71 deletions(-)

Index: linux-net/drivers/net/hamradio/6pack.c
===================================================================
--- linux-net.orig/drivers/net/hamradio/6pack.c
+++ linux-net/drivers/net/hamradio/6pack.c
@@ -325,11 +325,6 @@ static int sp_rebuild_header(struct sk_b
 
 static void sp_setup(struct net_device *dev)
 {
-	static char ax25_bcast[AX25_ADDR_LEN] =
-		{'Q'<<1,'S'<<1,'T'<<1,' '<<1,' '<<1,' '<<1,'0'<<1};
-	static char ax25_test[AX25_ADDR_LEN] =
-		{'L'<<1,'I'<<1,'N'<<1,'U'<<1,'X'<<1,' '<<1,'1'<<1};
-
 	/* Finish setting up the DEVICE info. */
 	dev->mtu		= SIXP_MTU;
 	dev->hard_start_xmit	= sp_xmit;
@@ -347,8 +342,8 @@ static void sp_setup(struct net_device *
 	dev->tx_timeout		= NULL;
 
 	/* Only activated in AX.25 mode */
-	memcpy(dev->broadcast, ax25_bcast, AX25_ADDR_LEN);
-	memcpy(dev->dev_addr, ax25_test, AX25_ADDR_LEN);
+	memcpy(dev->broadcast, &ax25_bcast, AX25_ADDR_LEN);
+	memcpy(dev->dev_addr, &ax25_defaddr, AX25_ADDR_LEN);
 
 	SET_MODULE_OWNER(dev);
 
Index: linux-net/drivers/net/hamradio/baycom_epp.c
===================================================================
--- linux-net.orig/drivers/net/hamradio/baycom_epp.c
+++ linux-net/drivers/net/hamradio/baycom_epp.c
@@ -1141,12 +1141,6 @@ static int baycom_ioctl(struct net_devic
  */
 static void baycom_probe(struct net_device *dev)
 {
-	static char ax25_bcast[AX25_ADDR_LEN] = {
-		'Q' << 1, 'S' << 1, 'T' << 1, ' ' << 1, ' ' << 1, ' ' << 1, '0' << 1
-	};
-	static char ax25_nocall[AX25_ADDR_LEN] = {
-		'L' << 1, 'I' << 1, 'N' << 1, 'U' << 1, 'X' << 1, ' ' << 1, '1' << 1
-	};
 	const struct hdlcdrv_channel_params dflt_ch_params = { 
 		20, 2, 10, 40, 0 
 	};
@@ -1182,8 +1176,8 @@ static void baycom_probe(struct net_devi
 	dev->hard_header_len = AX25_MAX_HEADER_LEN + AX25_BPQ_HEADER_LEN;
 	dev->mtu = AX25_DEF_PACLEN;        /* eth_mtu is the default */
 	dev->addr_len = AX25_ADDR_LEN;     /* sizeof an ax.25 address */
-	memcpy(dev->broadcast, ax25_bcast, AX25_ADDR_LEN);
-	memcpy(dev->dev_addr, ax25_nocall, AX25_ADDR_LEN);
+	memcpy(dev->broadcast, &ax25_bcast, AX25_ADDR_LEN);
+	memcpy(dev->dev_addr, &ax25_nocall, AX25_ADDR_LEN);
 	dev->tx_queue_len = 16;
 
 	/* New style flags */
Index: linux-net/drivers/net/hamradio/bpqether.c
===================================================================
--- linux-net.orig/drivers/net/hamradio/bpqether.c
+++ linux-net/drivers/net/hamradio/bpqether.c
@@ -88,11 +88,6 @@
 
 static char banner[] __initdata = KERN_INFO "AX.25: bpqether driver version 004\n";
 
-static unsigned char ax25_bcast[AX25_ADDR_LEN] =
-	{'Q' << 1, 'S' << 1, 'T' << 1, ' ' << 1, ' ' << 1, ' ' << 1, '0' << 1};
-static unsigned char ax25_defaddr[AX25_ADDR_LEN] =
-	{'L' << 1, 'I' << 1, 'N' << 1, 'U' << 1, 'X' << 1, ' ' << 1, '1' << 1};
-
 static char bcast_addr[6]={0xFF,0xFF,0xFF,0xFF,0xFF,0xFF};
 
 static char bpq_eth_addr[6];
@@ -487,8 +482,8 @@ static void bpq_setup(struct net_device 
 	dev->do_ioctl	     = bpq_ioctl;
 	dev->destructor	     = free_netdev;
 
-	memcpy(dev->broadcast, ax25_bcast, AX25_ADDR_LEN);
-	memcpy(dev->dev_addr,  ax25_defaddr, AX25_ADDR_LEN);
+	memcpy(dev->broadcast, &ax25_bcast, AX25_ADDR_LEN);
+	memcpy(dev->dev_addr,  &ax25_defaddr, AX25_ADDR_LEN);
 
 	dev->flags      = 0;
 
Index: linux-net/drivers/net/hamradio/dmascc.c
===================================================================
--- linux-net.orig/drivers/net/hamradio/dmascc.c
+++ linux-net/drivers/net/hamradio/dmascc.c
@@ -264,12 +264,6 @@ static int io[MAX_NUM_DEVS] __initdata =
 
 /* Beware! hw[] is also used in cleanup_module(). */
 static struct scc_hardware hw[NUM_TYPES] __initdata_or_module = HARDWARE;
-static char ax25_broadcast[7] __initdata =
-    { 'Q' << 1, 'S' << 1, 'T' << 1, ' ' << 1, ' ' << 1, ' ' << 1,
-'0' << 1 };
-static char ax25_test[7] __initdata =
-    { 'L' << 1, 'I' << 1, 'N' << 1, 'U' << 1, 'X' << 1, ' ' << 1,
-'1' << 1 };
 
 
 /* Global variables */
@@ -443,8 +437,8 @@ static void __init dev_setup(struct net_
 	dev->mtu = 1500;
 	dev->addr_len = AX25_ADDR_LEN;
 	dev->tx_queue_len = 64;
-	memcpy(dev->broadcast, ax25_broadcast, AX25_ADDR_LEN);
-	memcpy(dev->dev_addr, ax25_test, AX25_ADDR_LEN);
+	memcpy(dev->broadcast, &ax25_bcast, AX25_ADDR_LEN);
+	memcpy(dev->dev_addr, &ax25_defaddr, AX25_ADDR_LEN);
 }
 
 static int __init setup_adapter(int card_base, int type, int n)
Index: linux-net/drivers/net/hamradio/hdlcdrv.c
===================================================================
--- linux-net.orig/drivers/net/hamradio/hdlcdrv.c
+++ linux-net/drivers/net/hamradio/hdlcdrv.c
@@ -63,18 +63,6 @@
 
 /* --------------------------------------------------------------------- */
 
-/*
- * The name of the card. Is used for messages and in the requests for
- * io regions, irqs and dma channels
- */
-
-static char ax25_bcast[AX25_ADDR_LEN] =
-{'Q' << 1, 'S' << 1, 'T' << 1, ' ' << 1, ' ' << 1, ' ' << 1, '0' << 1};
-static char ax25_nocall[AX25_ADDR_LEN] =
-{'L' << 1, 'I' << 1, 'N' << 1, 'U' << 1, 'X' << 1, ' ' << 1, '1' << 1};
-
-/* --------------------------------------------------------------------- */
-
 #define KISS_VERBOSE
 
 /* --------------------------------------------------------------------- */
@@ -709,8 +697,8 @@ static void hdlcdrv_setup(struct net_dev
 	dev->hard_header_len = AX25_MAX_HEADER_LEN + AX25_BPQ_HEADER_LEN;
 	dev->mtu = AX25_DEF_PACLEN;        /* eth_mtu is the default */
 	dev->addr_len = AX25_ADDR_LEN;     /* sizeof an ax.25 address */
-	memcpy(dev->broadcast, ax25_bcast, AX25_ADDR_LEN);
-	memcpy(dev->dev_addr, ax25_nocall, AX25_ADDR_LEN);
+	memcpy(dev->broadcast, &ax25_bcast, AX25_ADDR_LEN);
+	memcpy(dev->dev_addr, &ax25_defaddr, AX25_ADDR_LEN);
 	dev->tx_queue_len = 16;
 }
 
Index: linux-net/drivers/net/hamradio/mkiss.c
===================================================================
--- linux-net.orig/drivers/net/hamradio/mkiss.c
+++ linux-net/drivers/net/hamradio/mkiss.c
@@ -672,11 +672,6 @@ static struct net_device_stats *ax_get_s
 
 static void ax_setup(struct net_device *dev)
 {
-	static char ax25_bcast[AX25_ADDR_LEN] =
-		{'Q'<<1,'S'<<1,'T'<<1,' '<<1,' '<<1,' '<<1,'0'<<1};
-	static char ax25_test[AX25_ADDR_LEN] =
-		{'L'<<1,'I'<<1,'N'<<1,'U'<<1,'X'<<1,' '<<1,'1'<<1};
-
 	/* Finish setting up the DEVICE info. */
 	dev->mtu             = AX_MTU;
 	dev->hard_start_xmit = ax_xmit;
@@ -691,8 +686,8 @@ static void ax_setup(struct net_device *
 	dev->hard_header     = ax_header;
 	dev->rebuild_header  = ax_rebuild_header;
 
-	memcpy(dev->broadcast, ax25_bcast, AX25_ADDR_LEN);
-	memcpy(dev->dev_addr,  ax25_test,  AX25_ADDR_LEN);
+	memcpy(dev->broadcast, &ax25_bcast, AX25_ADDR_LEN);
+	memcpy(dev->dev_addr,  &ax25_defaddr,  AX25_ADDR_LEN);
 
 	dev->flags      = IFF_BROADCAST | IFF_MULTICAST;
 }
Index: linux-net/drivers/net/hamradio/scc.c
===================================================================
--- linux-net.orig/drivers/net/hamradio/scc.c
+++ linux-net/drivers/net/hamradio/scc.c
@@ -1540,11 +1540,6 @@ static int scc_net_alloc(const char *nam
 /* *			    Network driver methods		      * */
 /* ******************************************************************** */
 
-static unsigned char ax25_bcast[AX25_ADDR_LEN] =
-{'Q' << 1, 'S' << 1, 'T' << 1, ' ' << 1, ' ' << 1, ' ' << 1, '0' << 1};
-static unsigned char ax25_nocall[AX25_ADDR_LEN] =
-{'L' << 1, 'I' << 1, 'N' << 1, 'U' << 1, 'X' << 1, ' ' << 1, '1' << 1};
-
 /* ----> Initialize device <----- */
 
 static void scc_net_setup(struct net_device *dev)
@@ -1562,8 +1557,8 @@ static void scc_net_setup(struct net_dev
 	dev->do_ioctl        = scc_net_ioctl;
 	dev->tx_timeout      = NULL;
 
-	memcpy(dev->broadcast, ax25_bcast,  AX25_ADDR_LEN);
-	memcpy(dev->dev_addr,  ax25_nocall, AX25_ADDR_LEN);
+	memcpy(dev->broadcast, &ax25_bcast,  AX25_ADDR_LEN);
+	memcpy(dev->dev_addr,  &ax25_defaddr, AX25_ADDR_LEN);
  
 	dev->flags      = 0;
 
Index: linux-net/drivers/net/hamradio/yam.c
===================================================================
--- linux-net.orig/drivers/net/hamradio/yam.c
+++ linux-net/drivers/net/hamradio/yam.c
@@ -156,11 +156,6 @@ static struct net_device *yam_devs[NR_PO
 
 static struct yam_mcs *yam_data;
 
-static char ax25_bcast[7] =
-{'Q' << 1, 'S' << 1, 'T' << 1, ' ' << 1, ' ' << 1, ' ' << 1, '0' << 1};
-static char ax25_test[7] =
-{'L' << 1, 'I' << 1, 'N' << 1, 'U' << 1, 'X' << 1, ' ' << 1, '1' << 1};
-
 static DEFINE_TIMER(yam_timer, NULL, 0, 0);
 
 /* --------------------------------------------------------------------- */
@@ -1115,8 +1110,8 @@ static void yam_setup(struct net_device 
 	dev->hard_header_len = AX25_MAX_HEADER_LEN;
 	dev->mtu = AX25_MTU;
 	dev->addr_len = AX25_ADDR_LEN;
-	memcpy(dev->broadcast, ax25_bcast, AX25_ADDR_LEN);
-	memcpy(dev->dev_addr, ax25_test, AX25_ADDR_LEN);
+	memcpy(dev->broadcast, &ax25_bcast, AX25_ADDR_LEN);
+	memcpy(dev->dev_addr, &ax25_defaddr, AX25_ADDR_LEN);
 }
 
 static int __init yam_init_driver(void)
Index: linux-net/net/ax25/ax25_addr.c
===================================================================
--- linux-net.orig/net/ax25/ax25_addr.c
+++ linux-net/net/ax25/ax25_addr.c
@@ -29,11 +29,20 @@
 #include <linux/interrupt.h>
 
 /*
- *	The null address is defined as a callsign of all spaces with an
- *	SSID of zero.
+ * The default broadcast address of an interface is QST-0; the default address
+ * is LINUX-1.  The null address is defined as a callsign of all spaces with
+ * an SSID of zero.
  */
-ax25_address null_ax25_address = {{0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x00}};
 
+const ax25_address ax25_bcast =
+	{{'Q' << 1, 'S' << 1, 'T' << 1, ' ' << 1, ' ' << 1, ' ' << 1, 0 << 1}};
+const ax25_address ax25_defaddr =
+	{{'L' << 1, 'I' << 1, 'N' << 1, 'U' << 1, 'X' << 1, ' ' << 1, 1 << 1}};
+const ax25_address null_ax25_address =
+	{{' ' << 1, ' ' << 1, ' ' << 1, ' ' << 1, ' ' << 1, ' ' << 1, 0 << 1}};
+
+EXPORT_SYMBOL_GPL(ax25_bcast);
+EXPORT_SYMBOL_GPL(ax25_defaddr);
 EXPORT_SYMBOL(null_ax25_address);
 
 /*
Index: linux-net/include/net/ax25.h
===================================================================
--- linux-net.orig/include/net/ax25.h
+++ linux-net/include/net/ax25.h
@@ -282,9 +282,9 @@ extern void ax25_fillin_cb(ax25_cb *, ax
 extern struct sock *ax25_make_new(struct sock *, struct ax25_dev *);
 
 /* ax25_addr.c */
-extern ax25_address null_ax25_address;
-extern char *ax2asc(char *buf, const ax25_address *);
-extern void asc2ax(ax25_address *addr, const char *callsign);
+extern const ax25_address ax25_bcast;
+extern const ax25_address ax25_defaddr;
+extern const ax25_address null_ax25_address;
 extern int ax25cmp(const ax25_address *, const ax25_address *);
 extern int ax25digicmp(const ax25_digi *, const ax25_digi *);
 extern const unsigned char *ax25_addr_parse(const unsigned char *, int,
