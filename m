From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/5) Fix irtty line disc and module semantics
Date: Fri, 15 Aug 2003 15:50:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815155059.44039644.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The irda tty line discipline does not handle the new module
paradigm well.  This patch fixes that:
	- initialize line discipline as data, not with code 
	- set module owner
	- make prototype for irtty_ioctl match expected 
	  arguments from tty discipline
	- get rid of explicit MOD_INC/MOD_DEC

Patch against 2.6.0-test3 latest

Include removal of driver_name which is a global defined but never used!
diff -Nru a/drivers/net/irda/irtty.c b/drivers/net/irda/irtty.c
--- a/drivers/net/irda/irtty.c	Fri Aug 15 11:45:06 2003
+++ b/drivers/net/irda/irtty.c	Fri Aug 15 11:45:06 2003
@@ -39,8 +39,6 @@
 #include <net/irda/wrapper.h>
 #include <net/irda/irda_device.h>
 
-static struct tty_ldisc irda_ldisc;
-
 static int qos_mtt_bits = 0x03;      /* 5 ms or more */
 
 /* Network device fuction prototypes */
@@ -54,7 +52,8 @@
 /* Line discipline function prototypes */
 static int  irtty_open(struct tty_struct *tty);
 static void irtty_close(struct tty_struct *tty);
-static int  irtty_ioctl(struct tty_struct *, void *, int, void *);
+static int  irtty_ioctl(struct tty_struct *, struct file *, 
+			unsigned int, unsigned long);
 static int  irtty_receive_room(struct tty_struct *tty);
 static void irtty_write_wakeup(struct tty_struct *tty);
 static void irtty_receive_buf(struct tty_struct *, const unsigned char *, 
@@ -68,29 +67,22 @@
 static int  irtty_set_mode(struct net_device *dev, int mode);
 static int  irtty_change_speed(struct irda_task *task);
 
-char *driver_name = "irtty";
+static struct tty_ldisc irda_ldisc = {
+	.owner = THIS_MODULE,
+	.magic = TTY_LDISC_MAGIC,
+	.name = "irda",
+	.open = irtty_open,
+	.close = irtty_close,
+	.ioctl = irtty_ioctl,
+	.receive_buf  = irtty_receive_buf,
+	.receive_room = irtty_receive_room,
+	.write_wakeup = irtty_write_wakeup,
+};
 
 int __init irtty_init(void)
 {
 	int status;
 
-	/* Fill in our line protocol discipline, and register it */
-	memset(&irda_ldisc, 0, sizeof( irda_ldisc));
-
-	irda_ldisc.magic = TTY_LDISC_MAGIC;
- 	irda_ldisc.name  = "irda";
-	irda_ldisc.flags = 0;
-	irda_ldisc.open  = irtty_open;
-	irda_ldisc.close = irtty_close;
-	irda_ldisc.read  = NULL;
-	irda_ldisc.write = NULL;
-	irda_ldisc.ioctl = (int (*)(struct tty_struct *, struct file *,
-				    unsigned int, unsigned long)) irtty_ioctl;
- 	irda_ldisc.poll  = NULL;
-	irda_ldisc.receive_buf  = irtty_receive_buf;
-	irda_ldisc.receive_room = irtty_receive_room;
-	irda_ldisc.write_wakeup = irtty_write_wakeup;
-	
 	if ((status = tty_register_ldisc(N_IRDA, &irda_ldisc)) != 0) {
 		ERROR("IrDA: can't register line discipline (err = %d)\n", 
 		      status);
@@ -234,8 +226,6 @@
 
 	MESSAGE("IrDA: Registered device %s\n", dev->name);
 
-	MOD_INC_USE_COUNT;
-
 	return 0;
 }
 
@@ -286,8 +276,6 @@
 	spin_unlock_irqrestore(&self->lock, flags);
 	
 	kfree(self);
-	
- 	MOD_DEC_USE_COUNT;
 }
 
 /*
@@ -468,7 +456,8 @@
  *     The Swiss army knife of system calls :-)
  *
  */
-static int irtty_ioctl(struct tty_struct *tty, void *file, int cmd, void *arg)
+static int irtty_ioctl(struct tty_struct *tty, struct file *file, 
+		       unsigned int cmd, unsigned long arg)
 {
 	dongle_t *dongle;
 	struct irtty_info info;
@@ -492,8 +481,7 @@
 	case TCGETS:
 	case TCGETA:
 		/* Unsure about locking here, to check - Jean II */
-		return n_tty_ioctl(tty, (struct file *) file, cmd, 
-				   (unsigned long) arg);
+		return n_tty_ioctl(tty, (struct file *) file, cmd, arg);
 		break;
 	case IRTTY_IOCTDONGLE:
 		/* Initialize dongle */
@@ -524,7 +512,7 @@
 		memset(&info, 0, sizeof(struct irtty_info)); 
 		strncpy(info.name, self->netdev->name, 5);
 
-		if (copy_to_user(arg, &info, sizeof(struct irtty_info)))
+		if (copy_to_user((void *) arg, &info, sizeof(struct irtty_info)))
 			return -EFAULT;
 		break;
 	default:
@@ -941,8 +929,6 @@
 	 */
 	self->irlap = irlap_open(dev, &self->qos, hwname);
 
-	MOD_INC_USE_COUNT;
-
 	return 0;
 }
 
@@ -963,8 +949,6 @@
 	if (self->irlap)
 		irlap_close(self->irlap);
 	self->irlap = NULL;
-
-	MOD_DEC_USE_COUNT;
 
 	return 0;
 }
