From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] bluetooth/rfcomm/: make some code static
Date: Sun, 19 Dec 2004 17:13:23 +0100
Message-ID: <20041219161323.GZ21288@stusta.de>
References: <20041214041352.GZ23151@stusta.de> <1103009649.2143.65.camel@pegasus> <20041219160758.GY21288@stusta.de>
Reply-To: bluez-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Max Krasnyansky <maxk@qualcomm.com>, bluez-devel@lists.sf.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Network Development Mailing List <netdev@oss.sgi.com>
Return-path: <bluez-devel-admin@lists.sourceforge.net>
To: Marcel Holtmann <marcel@holtmann.org>
Content-Disposition: inline
In-Reply-To: <20041219160758.GY21288@stusta.de>
Sender: bluez-devel-admin@lists.sourceforge.net
Errors-To: bluez-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=bluez-devel>
List-Id: netdev.vger.kernel.org

The patch below makes some needlessly global code static.


diffstat output:
 include/net/bluetooth/rfcomm.h |   27 ------------------------
 net/bluetooth/rfcomm/core.c    |   37 ++++++++++++++++++++++++++-------
 net/bluetooth/rfcomm/sock.c    |    4 +--
 3 files changed, 32 insertions(+), 36 deletions(-)


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.10-rc3-mm1-full/include/net/bluetooth/rfcomm.h.old	2004-12-14 02:19:37.000000000 +0100
+++ linux-2.6.10-rc3-mm1-full/include/net/bluetooth/rfcomm.h	2004-12-14 02:27:24.000000000 +0100
@@ -216,22 +216,6 @@
 #define RFCOMM_CFC_DISABLED 0
 #define RFCOMM_CFC_ENABLED  RFCOMM_MAX_CREDITS
 
-extern struct task_struct *rfcomm_thread;
-extern unsigned long rfcomm_event;
-
-static inline void rfcomm_schedule(uint event)
-{
-	if (!rfcomm_thread)
-		return;
-	//set_bit(event, &rfcomm_event);
-	set_bit(RFCOMM_SCHED_WAKEUP, &rfcomm_event);
-	wake_up_process(rfcomm_thread);
-}
-
-extern struct semaphore rfcomm_sem;
-#define rfcomm_lock()	down(&rfcomm_sem);
-#define rfcomm_unlock()	up(&rfcomm_sem);
-
 /* ---- RFCOMM DLCs (channels) ---- */
 struct rfcomm_dlc *rfcomm_dlc_alloc(int prio);
 void rfcomm_dlc_free(struct rfcomm_dlc *d);
@@ -271,11 +255,6 @@
 }
 
 /* ---- RFCOMM sessions ---- */
-struct rfcomm_session *rfcomm_session_add(struct socket *sock, int state);
-struct rfcomm_session *rfcomm_session_get(bdaddr_t *src, bdaddr_t *dst);
-struct rfcomm_session *rfcomm_session_create(bdaddr_t *src, bdaddr_t *dst, int *err);
-void   rfcomm_session_del(struct rfcomm_session *s);
-void   rfcomm_session_close(struct rfcomm_session *s, int err);
 void   rfcomm_session_getaddr(struct rfcomm_session *s, bdaddr_t *src, bdaddr_t *dst);
 
 static inline void rfcomm_session_hold(struct rfcomm_session *s)
@@ -283,12 +262,6 @@
 	atomic_inc(&s->refcnt);
 }
 
-static inline void rfcomm_session_put(struct rfcomm_session *s)
-{
-	if (atomic_dec_and_test(&s->refcnt))
-		rfcomm_session_del(s);
-}
-
 /* ---- RFCOMM chechsum ---- */
 extern u8 rfcomm_crc_table[];
 
--- linux-2.6.10-rc3-mm1-full/net/bluetooth/rfcomm/core.c.old	2004-12-14 02:19:43.000000000 +0100
+++ linux-2.6.10-rc3-mm1-full/net/bluetooth/rfcomm/core.c	2004-12-14 02:27:41.000000000 +0100
@@ -61,8 +61,12 @@
 struct proc_dir_entry *proc_bt_rfcomm;
 #endif
 
-struct task_struct *rfcomm_thread;
-DECLARE_MUTEX(rfcomm_sem);
+static struct task_struct *rfcomm_thread;
+
+static DECLARE_MUTEX(rfcomm_sem);
+#define rfcomm_lock()	down(&rfcomm_sem);
+#define rfcomm_unlock()	up(&rfcomm_sem);
+
 unsigned long rfcomm_event;
 
 static LIST_HEAD(session_list);
@@ -81,6 +85,10 @@
 
 static void rfcomm_process_connect(struct rfcomm_session *s);
 
+static struct rfcomm_session *rfcomm_session_create(bdaddr_t *src, bdaddr_t *dst, int *err);
+static struct rfcomm_session *rfcomm_session_get(bdaddr_t *src, bdaddr_t *dst);
+static void rfcomm_session_del(struct rfcomm_session *s);
+
 /* ---- RFCOMM frame parsing macros ---- */
 #define __get_dlci(b)     ((b & 0xfc) >> 2)
 #define __get_channel(b)  ((b & 0xf8) >> 3)
@@ -111,6 +119,21 @@
 #define __get_rpn_stop_bits(line) (((line) >> 2) & 0x1)
 #define __get_rpn_parity(line)    (((line) >> 3) & 0x3)
 
+static inline void rfcomm_schedule(uint event)
+{
+	if (!rfcomm_thread)
+		return;
+	//set_bit(event, &rfcomm_event);
+	set_bit(RFCOMM_SCHED_WAKEUP, &rfcomm_event);
+	wake_up_process(rfcomm_thread);
+}
+
+static inline void rfcomm_session_put(struct rfcomm_session *s)
+{
+	if (atomic_dec_and_test(&s->refcnt))
+		rfcomm_session_del(s);
+}
+
 /* ---- RFCOMM FCS computation ---- */
 
 /* CRC on 2 bytes */
@@ -458,7 +481,7 @@
 }
 
 /* ---- RFCOMM sessions ---- */
-struct rfcomm_session *rfcomm_session_add(struct socket *sock, int state)
+static struct rfcomm_session *rfcomm_session_add(struct socket *sock, int state)
 {
 	struct rfcomm_session *s = kmalloc(sizeof(*s), GFP_KERNEL);
 	if (!s)
@@ -487,7 +510,7 @@
 	return s;
 }
 
-void rfcomm_session_del(struct rfcomm_session *s)
+static void rfcomm_session_del(struct rfcomm_session *s)
 {
 	int state = s->state;
 
@@ -505,7 +528,7 @@
 		module_put(THIS_MODULE);
 }
 
-struct rfcomm_session *rfcomm_session_get(bdaddr_t *src, bdaddr_t *dst)
+static struct rfcomm_session *rfcomm_session_get(bdaddr_t *src, bdaddr_t *dst)
 {
 	struct rfcomm_session *s;
 	struct list_head *p, *n;
@@ -521,7 +544,7 @@
 	return NULL;
 }
 
-void rfcomm_session_close(struct rfcomm_session *s, int err)
+static void rfcomm_session_close(struct rfcomm_session *s, int err)
 {
 	struct rfcomm_dlc *d;
 	struct list_head *p, *n;
@@ -542,7 +565,7 @@
 	rfcomm_session_put(s);
 }
 
-struct rfcomm_session *rfcomm_session_create(bdaddr_t *src, bdaddr_t *dst, int *err)
+static struct rfcomm_session *rfcomm_session_create(bdaddr_t *src, bdaddr_t *dst, int *err)
 {
 	struct rfcomm_session *s = NULL;
 	struct sockaddr_l2 addr;
--- linux-2.6.10-rc3-mm1-full/net/bluetooth/rfcomm/sock.c.old	2004-12-14 02:28:14.000000000 +0100
+++ linux-2.6.10-rc3-mm1-full/net/bluetooth/rfcomm/sock.c	2004-12-14 02:28:33.000000000 +0100
@@ -393,7 +393,7 @@
 	return err;
 }
 
-int rfcomm_sock_listen(struct socket *sock, int backlog)
+static int rfcomm_sock_listen(struct socket *sock, int backlog)
 {
 	struct sock *sk = sock->sk;
 	int err = 0;
@@ -437,7 +437,7 @@
 	return err;
 }
 
-int rfcomm_sock_accept(struct socket *sock, struct socket *newsock, int flags)
+static int rfcomm_sock_accept(struct socket *sock, struct socket *newsock, int flags)
 {
 	DECLARE_WAITQUEUE(wait, current);
 	struct sock *sk = sock->sk, *nsk;



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
