From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH] Get rid of sk_protinfo use in rose
Date: Mon, 21 Mar 2005 09:50:37 +0000
Message-ID: <20050321095037.GA10220@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@oss.sgi.com, linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Below patch puts struct sock into rose_cb to get rid of the need for the
use of sk_protinfo in rose_sk().  While we're touching the data structure
convert it from a typedef into a struct.

Index: bk-afu/net/rose/rose_in.c
===================================================================
--- bk-afu.orig/net/rose/rose_in.c	2005-03-21 09:33:42.000000000 +0000
+++ bk-afu/net/rose/rose_in.c	2005-03-21 09:34:39.000000000 +0000
@@ -41,7 +41,7 @@
  */
 static int rose_state1_machine(struct sock *sk, struct sk_buff *skb, int frametype)
 {
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 
 	switch (frametype) {
 	case ROSE_CALL_ACCEPTED:
@@ -78,7 +78,7 @@
  */
 static int rose_state2_machine(struct sock *sk, struct sk_buff *skb, int frametype)
 {
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 
 	switch (frametype) {
 	case ROSE_CLEAR_REQUEST:
@@ -106,7 +106,7 @@
  */
 static int rose_state3_machine(struct sock *sk, struct sk_buff *skb, int frametype, int ns, int nr, int q, int d, int m)
 {
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 	int queued = 0;
 
 	switch (frametype) {
@@ -216,7 +216,7 @@
  */
 static int rose_state4_machine(struct sock *sk, struct sk_buff *skb, int frametype)
 {
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 
 	switch (frametype) {
 	case ROSE_RESET_REQUEST:
@@ -265,7 +265,7 @@
 /* Higher level upcall for a LAPB frame */
 int rose_process_rx_frame(struct sock *sk, struct sk_buff *skb)
 {
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 	int queued = 0, frametype, ns, nr, q, d, m;
 
 	if (rose->state == ROSE_STATE_0)
Index: bk-afu/net/rose/rose_route.c
===================================================================
--- bk-afu.orig/net/rose/rose_route.c	2005-03-21 09:33:42.000000000 +0000
+++ bk-afu/net/rose/rose_route.c	2005-03-21 09:34:39.000000000 +0000
@@ -899,7 +899,8 @@
 	 */
 	if ((sk = rose_find_socket(lci, rose_neigh)) != NULL) {
 		if (frametype == ROSE_CALL_REQUEST) {
-			rose_cb *rose = rose_sk(sk);
+			struct rose_sock *rose = rose_sk(sk);
+
 			/* Remove an existing unused socket */
 			rose_clear_queues(sk);
 			rose->cause	 = ROSE_NETWORK_CONGESTION;
Index: bk-afu/net/rose/rose_timer.c
===================================================================
--- bk-afu.orig/net/rose/rose_timer.c	2005-03-21 09:33:42.000000000 +0000
+++ bk-afu/net/rose/rose_timer.c	2005-03-21 09:34:39.000000000 +0000
@@ -46,7 +46,7 @@
 
 void rose_start_t1timer(struct sock *sk)
 {
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 
 	del_timer(&rose->timer);
 
@@ -59,7 +59,7 @@
 
 void rose_start_t2timer(struct sock *sk)
 {
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 
 	del_timer(&rose->timer);
 
@@ -72,7 +72,7 @@
 
 void rose_start_t3timer(struct sock *sk)
 {
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 
 	del_timer(&rose->timer);
 
@@ -85,7 +85,7 @@
 
 void rose_start_hbtimer(struct sock *sk)
 {
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 
 	del_timer(&rose->timer);
 
@@ -98,7 +98,7 @@
 
 void rose_start_idletimer(struct sock *sk)
 {
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 
 	del_timer(&rose->idletimer);
 
@@ -129,7 +129,7 @@
 static void rose_heartbeat_expiry(unsigned long param)
 {
 	struct sock *sk = (struct sock *)param;
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 
 	bh_lock_sock(sk);
 	switch (rose->state) {
@@ -166,7 +166,7 @@
 static void rose_timer_expiry(unsigned long param)
 {
 	struct sock *sk = (struct sock *)param;
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 
 	bh_lock_sock(sk);
 	switch (rose->state) {
Index: bk-afu/include/net/rose.h
===================================================================
--- bk-afu.orig/include/net/rose.h	2005-03-21 09:33:42.000000000 +0000
+++ bk-afu/include/net/rose.h	2005-03-21 09:34:39.000000000 +0000
@@ -6,7 +6,9 @@
 
 #ifndef _ROSE_H
 #define _ROSE_H 
+
 #include <linux/rose.h>
+#include <net/sock.h>
 
 #define	ROSE_ADDR_LEN			5
 
@@ -114,7 +116,8 @@
 	unsigned int		rand;
 };
 
-typedef struct {
+struct rose_sock {
+	struct sock		sock;
 	rose_address		source_addr,   dest_addr;
 	ax25_address		source_call,   dest_call;
 	unsigned char		source_ndigis, dest_ndigis;
@@ -135,10 +138,9 @@
 	struct rose_facilities_struct facilities;
 	struct timer_list	timer;
 	struct timer_list	idletimer;
-	struct sock		*sk;		/* Backlink to socket */
-} rose_cb;
+};
 
-#define rose_sk(__sk) ((rose_cb *)(__sk)->sk_protinfo)
+#define rose_sk(sk) ((struct rose_sock *)(sk))
 
 /* af_rose.c */
 extern ax25_address rose_callsign;
Index: bk-afu/net/rose/rose_subr.c
===================================================================
--- bk-afu.orig/net/rose/rose_subr.c	2005-03-21 09:33:42.000000000 +0000
+++ bk-afu/net/rose/rose_subr.c	2005-03-21 09:34:39.000000000 +0000
@@ -28,7 +28,7 @@
 #include <linux/interrupt.h>
 #include <net/rose.h>
 
-static int rose_create_facilities(unsigned char *buffer, rose_cb *rose);
+static int rose_create_facilities(unsigned char *buffer, struct rose_sock *rose);
 
 /*
  *	This routine purges all of the queues of frames.
@@ -47,7 +47,7 @@
 void rose_frames_acked(struct sock *sk, unsigned short nr)
 {
 	struct sk_buff *skb;
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 
 	/*
 	 * Remove all the ack-ed frames from the ack queue.
@@ -85,7 +85,7 @@
  */
 int rose_validate_nr(struct sock *sk, unsigned short nr)
 {
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 	unsigned short vc = rose->va;
 
 	while (vc != rose->vs) {
@@ -102,7 +102,7 @@
  */
 void rose_write_internal(struct sock *sk, int frametype)
 {
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 	struct sk_buff *skb;
 	unsigned char  *dptr;
 	unsigned char  lci1, lci2;
@@ -396,7 +396,7 @@
 	return 1;
 }
 
-static int rose_create_facilities(unsigned char *buffer, rose_cb *rose)
+static int rose_create_facilities(unsigned char *buffer, struct rose_sock *rose)
 {
 	unsigned char *p = buffer + 1;
 	char *callsign;
@@ -492,7 +492,7 @@
 
 void rose_disconnect(struct sock *sk, int reason, int cause, int diagnostic)
 {
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 
 	rose_stop_timer(sk);
 	rose_stop_idletimer(sk);
Index: bk-afu/net/rose/rose_out.c
===================================================================
--- bk-afu.orig/net/rose/rose_out.c	2005-03-21 09:33:42.000000000 +0000
+++ bk-afu/net/rose/rose_out.c	2005-03-21 09:34:39.000000000 +0000
@@ -33,7 +33,7 @@
  */
 static void rose_send_iframe(struct sock *sk, struct sk_buff *skb)
 {
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 
 	if (skb == NULL)
 		return;
@@ -48,7 +48,7 @@
 
 void rose_kick(struct sock *sk)
 {
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 	struct sk_buff *skb, *skbn;
 	unsigned short start, end;
 
@@ -112,7 +112,7 @@
 
 void rose_enquiry_response(struct sock *sk)
 {
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 
 	if (rose->condition & ROSE_COND_OWN_RX_BUSY)
 		rose_write_internal(sk, ROSE_RNR);
Index: bk-afu/net/rose/af_rose.c
===================================================================
--- bk-afu.orig/net/rose/af_rose.c	2005-03-21 09:33:42.000000000 +0000
+++ bk-afu/net/rose/af_rose.c	2005-03-21 09:34:39.000000000 +0000
@@ -128,24 +128,7 @@
 
 static struct sock *rose_alloc_sock(void)
 {
-	rose_cb *rose;
-	struct sock *sk = sk_alloc(PF_ROSE, GFP_ATOMIC, 1, NULL);
-
-	if (!sk)
-		goto out;
-
-	rose = sk->sk_protinfo = kmalloc(sizeof(*rose), GFP_ATOMIC);
-	if (!rose)
-		goto frees;
-
-	memset(rose, 0x00, sizeof(*rose));
-	rose->sk = sk;
-out:
-	return sk;
-frees:
-	sk_free(sk);
-	sk = NULL;
-	goto out;
+	return sk_alloc(PF_ROSE, GFP_ATOMIC, sizeof(struct rose_sock), NULL);
 }
 
 /*
@@ -169,7 +152,7 @@
 
 	spin_lock_bh(&rose_list_lock);
 	sk_for_each(s, node, &rose_list) {
-		rose_cb *rose = rose_sk(s);
+		struct rose_sock *rose = rose_sk(s);
 
 		if (rose->neighbour == neigh) {
 			rose_disconnect(s, ENETUNREACH, ROSE_OUT_OF_ORDER, 0);
@@ -190,7 +173,7 @@
 
 	spin_lock_bh(&rose_list_lock);
 	sk_for_each(s, node, &rose_list) {
-		rose_cb *rose = rose_sk(s);
+		struct rose_sock *rose = rose_sk(s);
 
 		if (rose->device == dev) {
 			rose_disconnect(s, ENETUNREACH, ROSE_OUT_OF_ORDER, 0);
@@ -247,7 +230,7 @@
 
 	spin_lock_bh(&rose_list_lock);
 	sk_for_each(s, node, &rose_list) {
-		rose_cb *rose = rose_sk(s);
+		struct rose_sock *rose = rose_sk(s);
 
 		if (!rosecmp(&rose->source_addr, addr) &&
 		    !ax25cmp(&rose->source_call, call) &&
@@ -256,7 +239,7 @@
 	}
 
 	sk_for_each(s, node, &rose_list) {
-		rose_cb *rose = rose_sk(s);
+		struct rose_sock *rose = rose_sk(s);
 
 		if (!rosecmp(&rose->source_addr, addr) &&
 		    !ax25cmp(&rose->source_call, &null_ax25_address) &&
@@ -279,7 +262,7 @@
 
 	spin_lock_bh(&rose_list_lock);
 	sk_for_each(s, node, &rose_list) {
-		rose_cb *rose = rose_sk(s);
+		struct rose_sock *rose = rose_sk(s);
 
 		if (rose->lci == lci && rose->neighbour == neigh)
 			goto found;
@@ -372,7 +355,7 @@
 	char __user *optval, int optlen)
 {
 	struct sock *sk = sock->sk;
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 	int opt;
 
 	if (level != SOL_ROSE)
@@ -432,7 +415,7 @@
 	char __user *optval, int __user *optlen)
 {
 	struct sock *sk = sock->sk;
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 	int val = 0;
 	int len;
 
@@ -491,7 +474,7 @@
 	struct sock *sk = sock->sk;
 
 	if (sk->sk_state != TCP_LISTEN) {
-		rose_cb *rose = rose_sk(sk);
+		struct rose_sock *rose = rose_sk(sk);
 
 		rose->dest_ndigis = 0;
 		memset(&rose->dest_addr, 0, ROSE_ADDR_LEN);
@@ -508,7 +491,7 @@
 static int rose_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
-	rose_cb *rose;
+	struct rose_sock *rose;
 
 	if (sock->type != SOCK_SEQPACKET || protocol != 0)
 		return -ESOCKTNOSUPPORT;
@@ -547,7 +530,7 @@
 static struct sock *rose_make_new(struct sock *osk)
 {
 	struct sock *sk;
-	rose_cb *rose, *orose;
+	struct rose_sock *rose, *orose;
 
 	if (osk->sk_type != SOCK_SEQPACKET)
 		return NULL;
@@ -600,7 +583,7 @@
 static int rose_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	rose_cb *rose;
+	struct rose_sock *rose;
 
 	if (sk == NULL) return 0;
 
@@ -646,7 +629,7 @@
 static int rose_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 {
 	struct sock *sk = sock->sk;
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 	struct sockaddr_rose *addr = (struct sockaddr_rose *)uaddr;
 	struct net_device *dev;
 	ax25_address *user, *source;
@@ -705,7 +688,7 @@
 static int rose_connect(struct socket *sock, struct sockaddr *uaddr, int addr_len, int flags)
 {
 	struct sock *sk = sock->sk;
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 	struct sockaddr_rose *addr = (struct sockaddr_rose *)uaddr;
 	unsigned char cause, diagnostic;
 	ax25_address *user;
@@ -906,7 +889,7 @@
 {
 	struct full_sockaddr_rose *srose = (struct full_sockaddr_rose *)uaddr;
 	struct sock *sk = sock->sk;
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 	int n;
 
 	if (peer != 0) {
@@ -935,7 +918,7 @@
 {
 	struct sock *sk;
 	struct sock *make;
-	rose_cb *make_rose;
+	struct rose_sock *make_rose;
 	struct rose_facilities_struct facilities;
 	int n, len;
 
@@ -1016,7 +999,7 @@
 			struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 	struct sockaddr_rose *usrose = (struct sockaddr_rose *)msg->msg_name;
 	int err;
 	struct full_sockaddr_rose srose;
@@ -1186,7 +1169,7 @@
 			struct msghdr *msg, size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 	struct sockaddr_rose *srose = (struct sockaddr_rose *)msg->msg_name;
 	size_t copied;
 	unsigned char *asmptr;
@@ -1251,7 +1234,7 @@
 static int rose_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
-	rose_cb *rose = rose_sk(sk);
+	struct rose_sock *rose = rose_sk(sk);
 	void __user *argp = (void __user *)arg;
 
 	switch (cmd) {
@@ -1384,7 +1367,7 @@
 
 	else {
 		struct sock *s = v;
-		rose_cb *rose = rose_sk(s);
+		struct rose_sock *rose = rose_sk(s);
 		const char *devname, *callsign;
 		const struct net_device *dev = rose->device;
 
