From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (8/8) pc300_tty cleanup.
Date: Tue, 2 Dec 2003 14:00:43 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202140043.4da79ac3.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krzysztof Halas <khc@pm.waw.pl>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1500  -> 1.1501 
#	drivers/net/wan/pc300_tty.c	1.14    -> 1.15   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/12/01	shemminger@osdl.org	1.1501
# * make local variables static
# * initialize tty_driver struct at compile time
# * don't expect net_device to be first in pc300 struct
# * don't depend on name being hdlcX
# --------------------------------------------
#
diff -Nru a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
--- a/drivers/net/wan/pc300_tty.c	Tue Dec  2 13:55:55 2003
+++ b/drivers/net/wan/pc300_tty.c	Tue Dec  2 13:55:55 2003
@@ -102,20 +102,17 @@
 	volatile struct st_cpc_rx_list buf_rx;	/* ptr. to reception buffer */
 	unsigned char*	buf_tx;		/* ptr. to transmission buffer */
 	pc300dev_t*	pc300dev;	/* ptr. to info struct in PC300 driver */
-	unsigned char	name[20];	/* interf. name + "-tty" */
+	unsigned char	name[IFNAMSIZ+6]; /* interf. name + "-tty" */
 	struct tty_struct *tty;		
 	struct work_struct tty_tx_work; /* tx work - tx interrupt */
 	struct work_struct tty_rx_work; /* rx work - rx interrupt */
 	} st_cpc_tty_area;
 
-/* TTY data structures */
-static struct tty_driver serial_drv;
-
 /* local variables */
-st_cpc_tty_area	cpc_tty_area[CPC_TTY_NPORTS];
+static st_cpc_tty_area	cpc_tty_area[CPC_TTY_NPORTS];
 
-int cpc_tty_cnt=0;	/* number of intrfaces configured with MLPPP */
-int cpc_tty_unreg_flag = 0;
+static int cpc_tty_cnt=0;	/* number of intrfaces configured with MLPPP */
+static int cpc_tty_unreg_flag = 0;
 
 /* TTY functions prototype */
 static int cpc_tty_open(struct tty_struct *tty, struct file *flip);
@@ -152,8 +149,8 @@
 	int ch = pc300chan->channel; 
 	unsigned long flags; 
 
-	CPC_TTY_DBG("%s-tty: Clear signal DTR\n",
-		((struct net_device*)(pc300dev->hdlc))->name);
+	CPC_TTY_DBG("%s-tty: Clear signal DTR\n", 
+		    pc300dev->hdlc->netdev->name);
 	CPC_TTY_LOCK(card, flags); 
 	cpc_writeb(card->hw.scabase + M_REG(CTL,ch), 
 		cpc_readb(card->hw.scabase+M_REG(CTL,ch))& CTL_DTR); 
@@ -171,13 +168,34 @@
 	unsigned long flags; 
 
 	CPC_TTY_DBG("%s-tty: Set signal DTR\n",
-		((struct net_device*)(pc300dev->hdlc))->name);
+		    pc300dev->hdlc->netdev->name);
 	CPC_TTY_LOCK(card, flags); 
 	cpc_writeb(card->hw.scabase + M_REG(CTL,ch), 
 		cpc_readb(card->hw.scabase+M_REG(CTL,ch))& ~CTL_DTR); 
 	CPC_TTY_UNLOCK(card,flags); 
 }
 
+static struct tty_driver serial_drv = {
+	.magic = TTY_DRIVER_MAGIC,
+	.owner = THIS_MODULE,
+	.driver_name = "pc300_tty",
+	.name = "ttyCP",
+	.major = CPC_TTY_MAJOR,
+	.minor_start = CPC_TTY_MINOR_START,
+	.num = CPC_TTY_NPORTS,
+	.type = TTY_DRIVER_TYPE_SERIAL,
+	.subtype = SERIAL_TYPE_NORMAL,
+	.flags = TTY_DRIVER_REAL_RAW,
+	.open = cpc_tty_open,
+	.close = cpc_tty_close,
+	.write = cpc_tty_write, 
+	.write_room = cpc_tty_write_room, 
+	.chars_in_buffer = cpc_tty_chars_in_buffer, 
+	.ioctl = cpc_tty_ioctl, 
+	.flush_buffer = cpc_tty_flush_buffer, 
+	.hangup = cpc_tty_hangup,
+};
+
 /*
  * PC300 TTY initialization routine
  *
@@ -190,48 +208,26 @@
  */
 void cpc_tty_init(pc300dev_t *pc300dev)
 {
-	int port, aux;
+	struct net_device *dev = pc300dev->hdlc->netdev;
+	unsigned port;
 	st_cpc_tty_area * cpc_tty;
 
 	/* hdlcX - X=interface number */
-	port = ((struct net_device*)(pc300dev->hdlc))->name[4] - '0';
-	if (port >= CPC_TTY_NPORTS) {
+	if (sscanf(dev->name, "hdlc%u", &port) != 1
+	    || port >= CPC_TTY_NPORTS) {
 		printk("%s-tty: invalid interface selected (0-%i): %i", 
-			((struct net_device*)(pc300dev->hdlc))->name,
-			CPC_TTY_NPORTS-1,port);
+		       dev->name, CPC_TTY_NPORTS-1,port);
 		return;
 	}
 
 	if (cpc_tty_cnt == 0) { /* first TTY connection -> register driver */
 		CPC_TTY_DBG("%s-tty: driver init, major:%i, minor range:%i=%i\n",
-			((struct net_device*)(pc300dev->hdlc))->name,
-			CPC_TTY_MAJOR, CPC_TTY_MINOR_START,
-			CPC_TTY_MINOR_START+CPC_TTY_NPORTS);
-		/* initialize tty driver struct */
-		memset(&serial_drv,0,sizeof(struct tty_driver));
-		serial_drv.magic = TTY_DRIVER_MAGIC;
-		serial_drv.owner = THIS_MODULE;
-		serial_drv.driver_name = "pc300_tty";
-		serial_drv.name = "ttyCP";
-		serial_drv.major = CPC_TTY_MAJOR;
-		serial_drv.minor_start = CPC_TTY_MINOR_START;
-		serial_drv.num = CPC_TTY_NPORTS;
-		serial_drv.type = TTY_DRIVER_TYPE_SERIAL;
-		serial_drv.subtype = SERIAL_TYPE_NORMAL;
+			    dev->name,
+			    CPC_TTY_MAJOR, CPC_TTY_MINOR_START,
+			    CPC_TTY_MINOR_START+CPC_TTY_NPORTS);
 
 		serial_drv.init_termios = tty_std_termios;
 		serial_drv.init_termios.c_cflag = B9600|CS8|CREAD|HUPCL|CLOCAL;
-		serial_drv.flags = TTY_DRIVER_REAL_RAW;
-
-		/* interface routines from the upper tty layer to the tty driver */
-		serial_drv.open = cpc_tty_open;
-		serial_drv.close = cpc_tty_close;
-		serial_drv.write = cpc_tty_write; 
-		serial_drv.write_room = cpc_tty_write_room; 
-		serial_drv.chars_in_buffer = cpc_tty_chars_in_buffer; 
-		serial_drv.ioctl = cpc_tty_ioctl; 
-		serial_drv.flush_buffer = cpc_tty_flush_buffer; 
-		serial_drv.hangup = cpc_tty_hangup;
 
 		/* register the TTY driver */
 		if (tty_register_driver(&serial_drv)) { 
@@ -241,7 +237,7 @@
 		} 
 
 		memset((void *)cpc_tty_area, 0,
-								sizeof(st_cpc_tty_area) * CPC_TTY_NPORTS);
+		       sizeof(st_cpc_tty_area) * CPC_TTY_NPORTS);
 	}
 
 	cpc_tty = &cpc_tty_area[port];
@@ -265,11 +261,8 @@
 
 	pc300dev->cpc_tty = (void *)cpc_tty; 
 	
-	aux = strlen(((struct net_device*)(pc300dev->hdlc))->name);
-	memcpy(cpc_tty->name,((struct net_device*)(pc300dev->hdlc))->name,aux);
-	memcpy(&cpc_tty->name[aux], "-tty", 5);
-	
-	cpc_open((struct net_device *)pc300dev->hdlc);
+	snprintf(cpc_tty->name, sizeof(cpc_tty->name)-1, "%s-tty", dev->name);
+	cpc_open(pc300dev->hdlc->netdev);
 	cpc_tty_dtr_off(pc300dev);
 
 	CPC_TTY_DBG("%s: Initializing TTY Sync Driver, tty major#%d minor#%i\n",
@@ -997,22 +990,23 @@
 static void cpc_tty_trace(pc300dev_t *dev, char* buf, int len, char rxtx)
 {
 	struct sk_buff *skb; 
+	struct net_device *netdev = dev->hdlc->netdev;
 
 	if ((skb = dev_alloc_skb(10 + len)) == NULL) { 
 		/* out of memory */ 
 		CPC_TTY_DBG("%s: tty_trace - out of memory\n",
-			((struct net_device *)(dev->hdlc))->name);
+			    netdev->name);
 		return; 
 	}
 
 	skb_put (skb, 10 + len); 
-	skb->dev = (struct net_device *) dev->hdlc; 
+	skb->dev = netdev;
 	skb->protocol = htons(ETH_P_CUST); 
 	skb->mac.raw = skb->data; 
 	skb->pkt_type = PACKET_HOST; 
 	skb->len = 10 + len; 
 
-	memcpy(skb->data,((struct net_device *)(dev->hdlc))->name,5);
+	memcpy(skb->data,netdev->name,5);
 	skb->data[5] = '['; 
 	skb->data[6] = rxtx; 
 	skb->data[7] = ']'; 
@@ -1035,14 +1029,14 @@
 
 	if ((cpc_tty= (st_cpc_tty_area *) pc300dev->cpc_tty) == 0) { 
 		CPC_TTY_DBG("%s: interface is not TTY\n",
-			((struct net_device *)(pc300dev->hdlc))->name);
+			pc300dev->hdlc->netdev->name);
 		return; 
 	}
 	CPC_TTY_DBG("%s: cpc_tty_unregister_service", cpc_tty->name);
 
 	if (cpc_tty->pc300dev != pc300dev) { 
 		CPC_TTY_DBG("%s: invalid tty ptr=%s\n", 
-		((struct net_device *)(pc300dev->hdlc))->name, cpc_tty->name);
+			    pc300dev->hdlc->netdev->name, cpc_tty->name);
 		return; 
 	}
 
@@ -1091,8 +1085,7 @@
 	int i ; 
 
 	CPC_TTY_DBG("hdlcX-tty: reset variables\n");
-	/* reset  the tty_driver structure - serial_drv */ 
-	memset(&serial_drv, 0, sizeof(struct tty_driver));
+
 	for (i=0; i < CPC_TTY_NPORTS; i++){
 		memset(&cpc_tty_area[i],0, sizeof(st_cpc_tty_area)); 
 	}
