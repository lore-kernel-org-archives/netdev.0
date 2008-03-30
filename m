From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: [PATCH] sb1000.c: stop inlining largish static functions
Date: Mon, 31 Mar 2008 01:02:43 +0200
Message-ID: <200803310102.43277.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_TwB8HLzBgrvpwo5"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755458AbYC3XEl@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_TwB8HLzBgrvpwo5
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi Jeff,

Can you take this patch into your net driver fixes tree?

drivers/net/sb1000.c has lots of inlined static functions.

Mst of them are used at initialization, wait for some
hardware register to change (wait using yield, sleep etc),
or do slow port-based I/O. Inlining thse "for speed" makes no sense.

This patch removes "inline" from biggest static function
(regardless of number of callsites - gcc nowadays auto-inlines
statics with one callsite).

Size difference for 32bit x86:

   text    data     bss     dec     hex filename
   6299     129       0    6428    191c linux-2.6-ALLYES/drivers/net/sb1000.o
   5418     129       0    5547    15ab linux-2.6.inline-ALLYES/drivers/net/sb1000.o

(I also see some other optimization opportunities,
will test and send a patch separately).

Signed-off-by: Denys Vlasenko <vda.linux@googlemail.com>
--
vda

--Boundary-00=_TwB8HLzBgrvpwo5
Content-Type: text/x-diff;
  charset="us-ascii";
  name="deinline_sb1000.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="deinline_sb1000.diff"

diff -urp -U 10 linux-2.6/drivers/net/sb1000.c linux-2.6.inline/drivers/net/sb1000.c
--- linux-2.6/drivers/net/sb1000.c	2008-03-30 03:27:45.000000000 +0200
+++ linux-2.6.inline/drivers/net/sb1000.c	2008-03-31 00:46:20.000000000 +0200
@@ -81,59 +81,59 @@ struct sb1000_private {
 /* prototypes for Linux interface */
 extern int sb1000_probe(struct net_device *dev);
 static int sb1000_open(struct net_device *dev);
 static int sb1000_dev_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd);
 static int sb1000_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t sb1000_interrupt(int irq, void *dev_id);
 static int sb1000_close(struct net_device *dev);
 
 
 /* SB1000 hardware routines to be used during open/configuration phases */
-static inline int card_wait_for_busy_clear(const int ioaddr[],
+static int card_wait_for_busy_clear(const int ioaddr[],
 	const char* name);
-static inline int card_wait_for_ready(const int ioaddr[], const char* name,
+static int card_wait_for_ready(const int ioaddr[], const char* name,
 	unsigned char in[]);
 static int card_send_command(const int ioaddr[], const char* name,
 	const unsigned char out[], unsigned char in[]);
 
 /* SB1000 hardware routines to be used during frame rx interrupt */
-static inline int sb1000_wait_for_ready(const int ioaddr[], const char* name);
-static inline int sb1000_wait_for_ready_clear(const int ioaddr[],
+static int sb1000_wait_for_ready(const int ioaddr[], const char* name);
+static int sb1000_wait_for_ready_clear(const int ioaddr[],
 	const char* name);
-static inline void sb1000_send_command(const int ioaddr[], const char* name,
+static void sb1000_send_command(const int ioaddr[], const char* name,
 	const unsigned char out[]);
-static inline void sb1000_read_status(const int ioaddr[], unsigned char in[]);
-static inline void sb1000_issue_read_command(const int ioaddr[],
+static void sb1000_read_status(const int ioaddr[], unsigned char in[]);
+static void sb1000_issue_read_command(const int ioaddr[],
 	const char* name);
 
 /* SB1000 commands for open/configuration */
-static inline int sb1000_reset(const int ioaddr[], const char* name);
-static inline int sb1000_check_CRC(const int ioaddr[], const char* name);
+static int sb1000_reset(const int ioaddr[], const char* name);
+static int sb1000_check_CRC(const int ioaddr[], const char* name);
 static inline int sb1000_start_get_set_command(const int ioaddr[],
 	const char* name);
-static inline int sb1000_end_get_set_command(const int ioaddr[],
+static int sb1000_end_get_set_command(const int ioaddr[],
 	const char* name);
-static inline int sb1000_activate(const int ioaddr[], const char* name);
+static int sb1000_activate(const int ioaddr[], const char* name);
 static int sb1000_get_firmware_version(const int ioaddr[],
 	const char* name, unsigned char version[], int do_end);
 static int sb1000_get_frequency(const int ioaddr[], const char* name,
 	int* frequency);
 static int sb1000_set_frequency(const int ioaddr[], const char* name,
 	int frequency);
 static int sb1000_get_PIDs(const int ioaddr[], const char* name,
 	short PID[]);
 static int sb1000_set_PIDs(const int ioaddr[], const char* name,
 	const short PID[]);
 
 /* SB1000 commands for frame rx interrupt */
-static inline int sb1000_rx(struct net_device *dev);
-static inline void sb1000_error_dpc(struct net_device *dev);
+static int sb1000_rx(struct net_device *dev);
+static void sb1000_error_dpc(struct net_device *dev);
 
 static const struct pnp_device_id sb1000_pnp_ids[] = {
 	{ "GIC1000", 0 },
 	{ "", 0 }
 };
 MODULE_DEVICE_TABLE(pnp, sb1000_pnp_ids);
 
 static int
 sb1000_probe_one(struct pnp_dev *pdev, const struct pnp_device_id *id)
 {
@@ -243,21 +243,21 @@ static struct pnp_driver sb1000_driver =
 };
 
 
 /*
  * SB1000 hardware routines to be used during open/configuration phases
  */
 
 static const int TimeOutJiffies = (875 * HZ) / 100;
 
 /* Card Wait For Busy Clear (cannot be used during an interrupt) */
-static inline int
+static int
 card_wait_for_busy_clear(const int ioaddr[], const char* name)
 {
 	unsigned char a;
 	unsigned long timeout;
 
 	a = inb(ioaddr[0] + 7);
 	timeout = jiffies + TimeOutJiffies;
 	while (a & 0x80 || a & 0x40) {
 		/* a little sleep */
 		yield();
@@ -267,21 +267,21 @@ card_wait_for_busy_clear(const int ioadd
 			printk(KERN_WARNING "%s: card_wait_for_busy_clear timeout\n",
 				name);
 			return -ETIME;
 		}
 	}
 
 	return 0;
 }
 
 /* Card Wait For Ready (cannot be used during an interrupt) */
-static inline int
+static int
 card_wait_for_ready(const int ioaddr[], const char* name, unsigned char in[])
 {
 	unsigned char a;
 	unsigned long timeout;
 
 	a = inb(ioaddr[1] + 6);
 	timeout = jiffies + TimeOutJiffies;
 	while (a & 0x80 || !(a & 0x40)) {
 		/* a little sleep */
 		yield();
@@ -347,21 +347,21 @@ card_send_command(const int ioaddr[], co
 	return 0;
 }
 
 
 /*
  * SB1000 hardware routines to be used during frame rx interrupt
  */
 static const int Sb1000TimeOutJiffies = 7 * HZ;
 
 /* Card Wait For Ready (to be used during frame rx) */
-static inline int
+static int
 sb1000_wait_for_ready(const int ioaddr[], const char* name)
 {
 	unsigned long timeout;
 
 	timeout = jiffies + Sb1000TimeOutJiffies;
 	while (inb(ioaddr[1] + 6) & 0x80) {
 		if (time_after_eq(jiffies, timeout)) {
 			printk(KERN_WARNING "%s: sb1000_wait_for_ready timeout\n",
 				name);
 			return -ETIME;
@@ -373,21 +373,21 @@ sb1000_wait_for_ready(const int ioaddr[]
 			printk(KERN_WARNING "%s: sb1000_wait_for_ready timeout\n",
 				name);
 			return -ETIME;
 		}
 	}
 	inb(ioaddr[0] + 7);
 	return 0;
 }
 
 /* Card Wait For Ready Clear (to be used during frame rx) */
-static inline int
+static int
 sb1000_wait_for_ready_clear(const int ioaddr[], const char* name)
 {
 	unsigned long timeout;
 
 	timeout = jiffies + Sb1000TimeOutJiffies;
 	while (inb(ioaddr[1] + 6) & 0x80) {
 		if (time_after_eq(jiffies, timeout)) {
 			printk(KERN_WARNING "%s: sb1000_wait_for_ready_clear timeout\n",
 				name);
 			return -ETIME;
@@ -398,66 +398,66 @@ sb1000_wait_for_ready_clear(const int io
 		if (time_after_eq(jiffies, timeout)) {
 			printk(KERN_WARNING "%s: sb1000_wait_for_ready_clear timeout\n",
 				name);
 			return -ETIME;
 		}
 	}
 	return 0;
 }
 
 /* Card Send Command (to be used during frame rx) */
-static inline void
+static void
 sb1000_send_command(const int ioaddr[], const char* name,
 	const unsigned char out[])
 {
 	outb(out[2], ioaddr[0] + 1);
 	outb(out[3], ioaddr[0] + 2);
 	outb(out[4], ioaddr[0] + 3);
 	outb(out[5], ioaddr[0] + 4);
 	outb(out[1], ioaddr[0] + 5);
 	outb(out[0], ioaddr[0] + 7);
 	if (sb1000_debug > 3)
 		printk(KERN_DEBUG "%s: sb1000_send_command out: %02x%02x%02x%02x"
 			"%02x%02x\n", name, out[0], out[1], out[2], out[3], out[4], out[5]);
 	return;
 }
 
 /* Card Read Status (to be used during frame rx) */
-static inline void
+static void
 sb1000_read_status(const int ioaddr[], unsigned char in[])
 {
 	in[1] = inb(ioaddr[0] + 1);
 	in[2] = inb(ioaddr[0] + 2);
 	in[3] = inb(ioaddr[0] + 3);
 	in[4] = inb(ioaddr[0] + 4);
 	in[0] = inb(ioaddr[0] + 5);
 	return;
 }
 
 /* Issue Read Command (to be used during frame rx) */
-static inline void
+static void
 sb1000_issue_read_command(const int ioaddr[], const char* name)
 {
 	const unsigned char Command0[6] = {0x20, 0x00, 0x00, 0x01, 0x00, 0x00};
 
 	sb1000_wait_for_ready_clear(ioaddr, name);
 	outb(0xa0, ioaddr[0] + 6);
 	sb1000_send_command(ioaddr, name, Command0);
 	return;
 }
 
 
 /*
  * SB1000 commands for open/configuration
  */
 /* reset SB1000 card */
-static inline int
+static int
 sb1000_reset(const int ioaddr[], const char* name)
 {
 	unsigned char st[7];
 	int port, status;
 	const unsigned char Command0[6] = {0x80, 0x16, 0x00, 0x00, 0x00, 0x00};
 
 	port = ioaddr[1] + 6;
 	outb(0x4, port);
 	inb(port);
 	udelay(1000);
@@ -472,21 +472,21 @@ sb1000_reset(const int ioaddr[], const c
 	udelay(0);
 
 	if ((status = card_send_command(ioaddr, name, Command0, st)))
 		return status;
 	if (st[3] != 0xf0)
 		return -EIO;
 	return 0;
 }
 
 /* check SB1000 firmware CRC */
-static inline int
+static int
 sb1000_check_CRC(const int ioaddr[], const char* name)
 {
 	unsigned char st[7];
 	int crc, status;
 	const unsigned char Command0[6] = {0x80, 0x1f, 0x00, 0x00, 0x00, 0x00};
 
 	/* check CRC */
 	if ((status = card_send_command(ioaddr, name, Command0, st)))
 		return status;
 	if (st[1] != st[3] || st[2] != st[4])
@@ -497,34 +497,34 @@ sb1000_check_CRC(const int ioaddr[], con
 
 static inline int
 sb1000_start_get_set_command(const int ioaddr[], const char* name)
 {
 	unsigned char st[7];
 	const unsigned char Command0[6] = {0x80, 0x1b, 0x00, 0x00, 0x00, 0x00};
 
 	return card_send_command(ioaddr, name, Command0, st);
 }
 
-static inline int
+static int
 sb1000_end_get_set_command(const int ioaddr[], const char* name)
 {
 	unsigned char st[7];
 	int status;
 	const unsigned char Command0[6] = {0x80, 0x1b, 0x02, 0x00, 0x00, 0x00};
 	const unsigned char Command1[6] = {0x20, 0x00, 0x00, 0x00, 0x00, 0x00};
 
 	if ((status = card_send_command(ioaddr, name, Command0, st)))
 		return status;
 	return card_send_command(ioaddr, name, Command1, st);
 }
 
-static inline int
+static int
 sb1000_activate(const int ioaddr[], const char* name)
 {
 	unsigned char st[7];
 	int status;
 	const unsigned char Command0[6] = {0x80, 0x11, 0x00, 0x00, 0x00, 0x00};
 	const unsigned char Command1[6] = {0x80, 0x16, 0x00, 0x00, 0x00, 0x00};
 
 	ssleep(1);
 	if ((status = card_send_command(ioaddr, name, Command0, st)))
 		return status;
@@ -687,21 +687,21 @@ sb1000_set_PIDs(const int ioaddr[], cons
 	Command3[2] = p & 0xff;
 	if ((status = card_send_command(ioaddr, name, Command3, st)))
 		return status;
 
 	if ((status = card_send_command(ioaddr, name, Command4, st)))
 		return status;
 	return sb1000_end_get_set_command(ioaddr, name);
 }
 
 
-static inline void
+static void
 sb1000_print_status_buffer(const char* name, unsigned char st[],
 	unsigned char buffer[], int size)
 {
 	int i, j, k;
 
 	printk(KERN_DEBUG "%s: status: %02x %02x\n", name, st[0], st[1]);
 	if (buffer[24] == 0x08 && buffer[25] == 0x00 && buffer[26] == 0x45) {
 		printk(KERN_DEBUG "%s: length: %d protocol: %d from: %d.%d.%d.%d:%d "
 			"to %d.%d.%d.%d:%d\n", name, buffer[28] << 8 | buffer[29],
 			buffer[35], buffer[38], buffer[39], buffer[40], buffer[41],
@@ -718,21 +718,21 @@ sb1000_print_status_buffer(const char* n
 	}
 	return;
 }
 
 /*
  * SB1000 commands for frame rx interrupt
  */
 /* receive a single frame and assemble datagram
  * (this is the heart of the interrupt routine)
  */
-static inline int
+static int
 sb1000_rx(struct net_device *dev)
 {
 
 #define FRAMESIZE 184
 	unsigned char st[2], buffer[FRAMESIZE], session_id, frame_id;
 	short dlen;
 	int ioaddr, ns;
 	unsigned int skbsize;
 	struct sk_buff *skb;
 	struct sb1000_private *lp = netdev_priv(dev);
@@ -881,21 +881,21 @@ dropped_frame:
 	if (ns < NPIDS) {
 		if ((skb = lp->rx_skb[ns])) {
 			dev_kfree_skb(skb);
 			lp->rx_skb[ns] = NULL;
 		}
 		lp->rx_session_id[ns] |= 0x40;
 	}
 	return -1;
 }
 
-static inline void
+static void
 sb1000_error_dpc(struct net_device *dev)
 {
 	char *name;
 	unsigned char st[5];
 	int ioaddr[2];
 	struct sb1000_private *lp = netdev_priv(dev);
 	const unsigned char Command0[6] = {0x80, 0x26, 0x00, 0x00, 0x00, 0x00};
 	const int ErrorDpcCounterInitialize = 200;
 
 	ioaddr[0] = dev->base_addr;

--Boundary-00=_TwB8HLzBgrvpwo5--
