From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [15/22] Cyclades PC300 driver: use struct tty_operations in tty driver
Date: Sun, 29 Jan 2012 18:56:05 -0800
Message-ID: <20120130025605.GP10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khc@pm.waw.pl, davem@davemloft.net, mmarek@suse.cz,
	jkosina@suse.cz, joe@perches.com, justinmattock@gmail.com,
	gregkh@suse.de, alan@linux.intel.com, jdmason@kudzu.us
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use struct tty_operations as required by current kernel.

Signed-off-by: Andrea Shepard <andrea@persephoneslair.org>

diff --git a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
index d1d7a7c..aa1ddde 100644
--- a/drivers/net/wan/pc300_tty.c
+++ b/drivers/net/wan/pc300_tty.c
@@ -120,8 +120,8 @@ static int cpc_tty_unreg_flag = 0;
 /* TTY functions prototype */
 static int cpc_tty_open(struct tty_struct *tty, struct file *flip);
 static void cpc_tty_close(struct tty_struct *tty, struct file *flip);
-static int cpc_tty_write(struct tty_struct *tty, int from_user,
-				const unsigned char *buf, int count);
+static int cpc_tty_write(struct tty_struct *tty, const unsigned char *buf,
+		int count);
 static int cpc_tty_write_room(struct tty_struct *tty);
 static int cpc_tty_chars_in_buffer(struct tty_struct *tty);
 static void cpc_tty_flush_buffer(struct tty_struct *tty);
@@ -133,8 +133,7 @@ static void cpc_tty_trace(pc300dev_t *dev, char* buf, int len, char rxtx);
 static void cpc_tty_signal_off(pc300dev_t *pc300dev, unsigned char);
 static void cpc_tty_signal_on(pc300dev_t *pc300dev, unsigned char);
 
-static int pc300_tiocmset(struct tty_struct *, struct file *,
-			unsigned int, unsigned int);
+static int pc300_tiocmset(struct tty_struct *, unsigned int, unsigned int);
 static int pc300_tiocmget(struct tty_struct *);
 
 /* functions called by PC300 driver */
@@ -178,6 +177,20 @@ static void cpc_tty_signal_on(pc300dev_t *pc300dev, unsigned char signal)
 	CPC_TTY_UNLOCK(card,flags); 
 }
 
+
+static const struct tty_operations pc300_ops = {
+	.open = cpc_tty_open,
+	.close = cpc_tty_close,
+	.write = cpc_tty_write,
+	.write_room = cpc_tty_write_room,
+	.chars_in_buffer = cpc_tty_chars_in_buffer,
+	.tiocmset = pc300_tiocmset,
+	.tiocmget = pc300_tiocmget,
+	.flush_buffer = cpc_tty_flush_buffer,
+	.hangup = cpc_tty_hangup,
+};
+
+
 /*
  * PC300 TTY initialization routine
  *
@@ -190,7 +203,8 @@ static void cpc_tty_signal_on(pc300dev_t *pc300dev, unsigned char signal)
  */
 void cpc_tty_init(pc300dev_t *pc300dev)
 {
-	int port, aux;
+	int aux;
+	long port;
 	st_cpc_tty_area * cpc_tty;
 
 	/* hdlcX - X=interface number */
@@ -224,15 +238,7 @@ void cpc_tty_init(pc300dev_t *pc300dev)
 		serial_drv.flags = TTY_DRIVER_REAL_RAW;
 
 		/* interface routines from the upper tty layer to the tty driver */
-		serial_drv.open = cpc_tty_open;
-		serial_drv.close = cpc_tty_close;
-		serial_drv.write = cpc_tty_write; 
-		serial_drv.write_room = cpc_tty_write_room; 
-		serial_drv.chars_in_buffer = cpc_tty_chars_in_buffer; 
-		serial_drv.tiocmset = pc300_tiocmset;
-		serial_drv.tiocmget = pc300_tiocmget;
-		serial_drv.flush_buffer = cpc_tty_flush_buffer; 
-		serial_drv.hangup = cpc_tty_hangup;
+		tty_set_operations(&serial_drv, &pc300_ops);
 
 		/* register the TTY driver */
 		if (tty_register_driver(&serial_drv)) { 
@@ -403,7 +409,7 @@ static void cpc_tty_close(struct tty_struct *tty, struct file *flip)
 
 	CPC_TTY_DBG("%s: TTY closed\n",cpc_tty->name);
 	
-	if (!serial_drv.refcount && cpc_tty_unreg_flag) {
+	if (!cpc_tty_cnt && cpc_tty_unreg_flag) {
 		cpc_tty_unreg_flag = 0;
 		CPC_TTY_DBG("%s: unregister the tty driver\n", cpc_tty->name);
 		if ((res=tty_unregister_driver(&serial_drv))) { 
@@ -422,7 +428,7 @@ static void cpc_tty_close(struct tty_struct *tty, struct file *flip)
  * o verify the DCD signal
  * o send characters to board and start the transmission
  */
-static int cpc_tty_write(struct tty_struct *tty, int from_user,
+static int cpc_tty_write(struct tty_struct *tty,
 			const unsigned char *buf, int count)
 {
 	st_cpc_tty_area    *cpc_tty; 
@@ -431,6 +437,7 @@ static int cpc_tty_write(struct tty_struct *tty, int from_user,
 	int ch; 
 	unsigned long flags; 
 	struct net_device_stats *stats; 
+	int from_user = 1;
 
 	if (!tty || !tty->driver_data ) { 
 		CPC_TTY_DBG("hdlcX-tty: no TTY in write\n");
@@ -555,8 +562,8 @@ static int cpc_tty_chars_in_buffer(struct tty_struct *tty)
 	return(0); 
 } 
 
-static int pc300_tiocmset(struct tty_struct *tty, struct file *file,
-			unsigned int set, unsigned int clear)
+static int pc300_tiocmset(struct tty_struct *tty,
+			  unsigned int set, unsigned int clear)
 {
 	st_cpc_tty_area    *cpc_tty; 
 
@@ -582,7 +589,7 @@ static int pc300_tiocmset(struct tty_struct *tty, struct file *file,
 	return 0;
 }
 
-static int pc300_tiocmget(struct tty_struct *tty, struct file *file)
+static int pc300_tiocmget(struct tty_struct *tty)
 {
 	unsigned int result;
 	unsigned char status;
@@ -632,10 +639,11 @@ static void cpc_tty_flush_buffer(struct tty_struct *tty)
 	
 	wake_up_interruptible(&tty->write_wait); 
 
-	if ((tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) && tty->ldisc.write_wakeup){
-		CPC_TTY_DBG("%s: call line disc. wake up\n",cpc_tty->name);
-		tty->ldisc.write_wakeup(tty); 
-	} 
+	if ((tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) && tty->ldisc &&
+		tty->ldisc->ops && tty->ldisc->ops->write_wakeup){
+		CPC_TTY_DBG("%s: call line disc. wake up\n", cpc_tty->name);
+		tty->ldisc->ops->write_wakeup(tty);
+	}
 
 	return; 
 } 
@@ -663,7 +671,7 @@ static void cpc_tty_hangup(struct tty_struct *tty)
 		CPC_TTY_DBG("%s: TTY is not opened\n",cpc_tty->name);
 		return ;
 	}
-	if (!serial_drv.refcount && cpc_tty_unreg_flag) {
+	if (!cpc_tty_cnt && cpc_tty_unreg_flag) {
 		cpc_tty_unreg_flag = 0;
 		CPC_TTY_DBG("%s: unregister the tty driver\n", cpc_tty->name);
 		if ((res=tty_unregister_driver(&serial_drv))) { 
@@ -1069,18 +1077,12 @@ void cpc_tty_unregister_service(pc300dev_t *pc300dev)
 	}
 
 	if (--cpc_tty_cnt == 0) { 
-		if (serial_drv.refcount) {
-			CPC_TTY_DBG("%s: unregister is not possible, refcount=%d",
-							cpc_tty->name, serial_drv.refcount);
-			cpc_tty_cnt++;
-			cpc_tty_unreg_flag = 1;
-			return;
-		} else { 
-			CPC_TTY_DBG("%s: unregister the tty driver\n", cpc_tty->name);
-			if ((res=tty_unregister_driver(&serial_drv))) { 
-				CPC_TTY_DBG("%s: ERROR ->unregister the tty driver error=%d\n",
-								cpc_tty->name,res);
-			}
+		CPC_TTY_DBG("%s: unregister the tty driver\n", cpc_tty->name);
+		res = tty_unregister_driver(&serial_drv);
+		if (res) {
+			CPC_TTY_DBG(
+				"%s: ERROR ->unregister the tty driver error=%d\n",
+				cpc_tty->name, res);
 		}
 	}
 	CPC_TTY_LOCK(pc300dev->chan->card,flags);
