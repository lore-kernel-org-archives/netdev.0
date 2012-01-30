From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [14/22] Cyclades PC300 driver: use struct work_struct in tty driver
Date: Sun, 29 Jan 2012 18:55:06 -0800
Message-ID: <20120130025506.GO10262@cronus.persephoneslair.org>
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

The tty code now requires cpc_tty_rx_work() and cpc_tty_tx_work() to use
struct work_struct; do so.

Signed-off-by: Andrea Shepard <andrea@persephoneslair.org>

diff --git a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
index bf5c2ab..d1d7a7c 100644
--- a/drivers/net/wan/pc300_tty.c
+++ b/drivers/net/wan/pc300_tty.c
@@ -50,6 +50,7 @@
 #include <linux/tty.h>
 #include <linux/tty_flip.h>
 #include <linux/serial.h>
+#include <linux/workqueue.h>
 
 #include <asm/io.h>
 #include <asm/uaccess.h>
@@ -125,8 +126,8 @@ static int cpc_tty_write_room(struct tty_struct *tty);
 static int cpc_tty_chars_in_buffer(struct tty_struct *tty);
 static void cpc_tty_flush_buffer(struct tty_struct *tty);
 static void cpc_tty_hangup(struct tty_struct *tty);
-static void cpc_tty_rx_work(void *data);
-static void cpc_tty_tx_work(void *data);
+static void cpc_tty_rx_work(struct work_struct *work);
+static void cpc_tty_tx_work(struct work_struct *work);
 static int cpc_tty_send_to_card(pc300dev_t *dev,void *buf, int len);
 static void cpc_tty_trace(pc300dev_t *dev, char* buf, int len, char rxtx);
 static void cpc_tty_signal_off(pc300dev_t *pc300dev, unsigned char);
@@ -256,8 +257,8 @@ void cpc_tty_init(pc300dev_t *pc300dev)
 	cpc_tty->tty_minor = port + CPC_TTY_MINOR_START;
 	cpc_tty->pc300dev = pc300dev; 
 
-	INIT_WORK(&cpc_tty->tty_tx_work, cpc_tty_tx_work, (void *)cpc_tty);
-	INIT_WORK(&cpc_tty->tty_rx_work, cpc_tty_rx_work, (void *)port);
+	INIT_WORK(&cpc_tty->tty_tx_work, cpc_tty_tx_work);
+	INIT_WORK(&cpc_tty->tty_rx_work, cpc_tty_rx_work);
 	
 	cpc_tty->buf_rx.first = cpc_tty->buf_rx.last = 0;
 
@@ -680,9 +681,10 @@ static void cpc_tty_hangup(struct tty_struct *tty)
  * o call the line disc. read
  * o free memory
  */
-static void cpc_tty_rx_work(void * data)
+static void cpc_tty_rx_work(struct work_struct *work)
 {
-	int port, i, j;
+	int i, j;
+	unsigned long port;
 	st_cpc_tty_area *cpc_tty; 
 	st_cpc_rx_buf * buf;
 	char flags=0,flg_rx=1; 
@@ -691,19 +693,27 @@ static void cpc_tty_rx_work(void * data)
 
 	for (i=0; (i < 4) && flg_rx ; i++) {
 		flg_rx = 0;
-		port = (int) data;
+		cpc_tty = container_of(work, st_cpc_tty_area, tty_rx_work);
+		port = cpc_tty - cpc_tty_area;
+
 		for (j=0; j < CPC_TTY_NPORTS; j++) {
 			cpc_tty = &cpc_tty_area[port];
-		
-			if ((buf=cpc_tty->buf_rx.first) != 0) {
-															
-				if (cpc_tty->tty && (cpc_tty->tty->ldisc.receive_buf)) { 
-					CPC_TTY_DBG("%s: call line disc. receive_buf\n",cpc_tty->name);
-					cpc_tty->tty->ldisc.receive_buf(cpc_tty->tty, (char *)(buf->data), 
-					&flags, buf->size);
-				}	
+			buf = cpc_tty->buf_rx.first;
+			if (buf != NULL) {
+				if (cpc_tty->tty && cpc_tty->tty->ldisc &&
+				    cpc_tty->tty->ldisc->ops &&
+				    cpc_tty->tty->ldisc->ops->receive_buf) {
+					CPC_TTY_DBG(
+					  "%s: call line disc. receive_buf\n",
+					  cpc_tty->name);
+					cpc_tty->tty->
+					  ldisc->ops->
+					  receive_buf(cpc_tty->tty,
+						(char *)(buf->data),
+						&flags, buf->size);
+				}
 				cpc_tty->buf_rx.first = cpc_tty->buf_rx.first->next;
-				kfree((unsigned char *)buf);
+				kfree((void *)buf);
 				buf = cpc_tty->buf_rx.first;
 				flg_rx = 1;
 			}
@@ -896,9 +906,10 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
  * o if need call line discipline wakeup
  * o call wake_up_interruptible
  */
-static void cpc_tty_tx_work(void *data)
+static void cpc_tty_tx_work(struct work_struct *work)
 {
-	st_cpc_tty_area *cpc_tty = (st_cpc_tty_area *) data; 
+	st_cpc_tty_area *cpc_tty =
+		container_of(work, st_cpc_tty_area, tty_tx_work);
 	struct tty_struct *tty; 
 
 	CPC_TTY_DBG("%s: cpc_tty_tx_work init\n",cpc_tty->name);
@@ -908,9 +919,10 @@ static void cpc_tty_tx_work(void *data)
 		return; 
 	}
 
-	if ((tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) && tty->ldisc.write_wakeup){
-		CPC_TTY_DBG("%s:call line disc. wakeup\n",cpc_tty->name);
-		tty->ldisc.write_wakeup (tty); 
+	if ((tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) && tty->ldisc &&
+	     tty->ldisc->ops && tty->ldisc->ops->write_wakeup) {
+		CPC_TTY_DBG("%s:call line disc. wakeup\n", cpc_tty->name);
+		tty->ldisc->ops->write_wakeup(tty);
 	}
 
 	wake_up_interruptible(&tty->write_wait); 
