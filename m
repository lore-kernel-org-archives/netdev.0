From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH] Get rid of sk_protinfo use in netrom
Date: Mon, 21 Mar 2005 09:49:05 +0000
Message-ID: <20050321094905.GA10022@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@oss.sgi.com, linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Below patch puts struct sock into nr_cb to get rid of the need for the
use of sk_protinfo in nr_sk().  While we're touching the data structure
convert it from a typedef into a struct.

Index: bk-afu/net/netrom/nr_timer.c
===================================================================
--- bk-afu.orig/net/netrom/nr_timer.c	2005-03-17 23:54:00.000000000 +0000
+++ bk-afu/net/netrom/nr_timer.c	2005-03-20 10:40:08.000000000 +0000
@@ -38,7 +38,7 @@
 
 void nr_init_timers(struct sock *sk)
 {
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 
 	init_timer(&nr->t1timer);
 	nr->t1timer.data     = (unsigned long)sk;
@@ -63,28 +63,28 @@
 
 void nr_start_t1timer(struct sock *sk)
 {
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 
 	mod_timer(&nr->t1timer, jiffies + nr->t1);
 }
 
 void nr_start_t2timer(struct sock *sk)
 {
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 
 	mod_timer(&nr->t2timer, jiffies + nr->t2);
 }
 
 void nr_start_t4timer(struct sock *sk)
 {
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 
 	mod_timer(&nr->t4timer, jiffies + nr->t4);
 }
 
 void nr_start_idletimer(struct sock *sk)
 {
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 
 	if (nr->idle > 0)
 		mod_timer(&nr->idletimer, jiffies + nr->idle);
@@ -128,7 +128,7 @@
 static void nr_heartbeat_expiry(unsigned long param)
 {
 	struct sock *sk = (struct sock *)param;
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 
 	bh_lock_sock(sk);
 	switch (nr->state) {
@@ -167,7 +167,7 @@
 static void nr_t2timer_expiry(unsigned long param)
 {
 	struct sock *sk = (struct sock *)param;
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 
 	bh_lock_sock(sk);
 	if (nr->condition & NR_COND_ACK_PENDING) {
@@ -189,7 +189,7 @@
 static void nr_idletimer_expiry(unsigned long param)
 {
 	struct sock *sk = (struct sock *)param;
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 
 	bh_lock_sock(sk);
 
@@ -217,7 +217,7 @@
 static void nr_t1timer_expiry(unsigned long param)
 {
 	struct sock *sk = (struct sock *)param;
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 
 	bh_lock_sock(sk);
 	switch (nr->state) {
Index: bk-afu/include/net/netrom.h
===================================================================
--- bk-afu.orig/include/net/netrom.h	2005-03-19 20:00:15.000000000 +0000
+++ bk-afu/include/net/netrom.h	2005-03-20 10:36:50.000000000 +0000
@@ -55,7 +55,8 @@
 #define NR_MAX_WINDOW_SIZE		127			/* Maximum Window Allowable - 127 */
 #define	NR_MAX_PACKET_SIZE		236			/* Maximum Packet Length - 236 */
 
-typedef struct {
+struct nr_sock {
+	struct sock		sock;
 	ax25_address		user_addr, source_addr, dest_addr;
 	struct net_device		*device;
 	unsigned char		my_index,   my_id;
@@ -72,10 +73,9 @@
 	struct sk_buff_head	ack_queue;
 	struct sk_buff_head	reseq_queue;
 	struct sk_buff_head	frag_queue;
-	struct sock		*sk;		/* Backlink to socket */
-} nr_cb;
+};
 
-#define nr_sk(__sk) ((nr_cb *)(__sk)->sk_protinfo)
+#define nr_sk(sk) ((struct nr_sock *)(sk))
 
 struct nr_neigh {
 	struct hlist_node	neigh_node;
Index: bk-afu/net/netrom/af_netrom.c
===================================================================
--- bk-afu.orig/net/netrom/af_netrom.c	2005-03-19 20:00:13.000000000 +0000
+++ bk-afu/net/netrom/af_netrom.c	2005-03-20 10:44:54.000000000 +0000
@@ -66,24 +66,7 @@
 
 static struct sock *nr_alloc_sock(void)
 {
-	nr_cb *nr;
-	struct sock *sk = sk_alloc(PF_NETROM, GFP_ATOMIC, 1, NULL);
-
-	if (!sk)
-		goto out;
-
-	nr = sk->sk_protinfo = kmalloc(sizeof(*nr), GFP_ATOMIC);
-	if (!nr)
-		goto frees;
-
-	memset(nr, 0x00, sizeof(*nr));
-	nr->sk = sk;
-out:
-	return sk;
-frees:
-	sk_free(sk);
-	sk = NULL;
-	goto out;
+	return  sk_alloc(PF_NETROM, GFP_ATOMIC, sizeof(struct nr_sock), NULL);
 }
 
 /*
@@ -169,7 +152,7 @@
 
 	spin_lock_bh(&nr_list_lock);
 	sk_for_each(s, node, &nr_list) {
-		nr_cb *nr = nr_sk(s);
+		struct nr_sock *nr = nr_sk(s);
 		
 		if (nr->my_index == index && nr->my_id == id) {
 			bh_lock_sock(s);
@@ -193,7 +176,7 @@
 
 	spin_lock_bh(&nr_list_lock);
 	sk_for_each(s, node, &nr_list) {
-		nr_cb *nr = nr_sk(s);
+		struct nr_sock *nr = nr_sk(s);
 		
 		if (nr->your_index == index && nr->your_id == id &&
 		    !ax25cmp(&nr->dest_addr, dest)) {
@@ -300,7 +283,7 @@
 	char __user *optval, int optlen)
 {
 	struct sock *sk = sock->sk;
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 	int opt;
 
 	if (level != SOL_NETROM)
@@ -352,7 +335,7 @@
 	char __user *optval, int __user *optlen)
 {
 	struct sock *sk = sock->sk;
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 	int val = 0;
 	int len; 
 
@@ -418,7 +401,7 @@
 static int nr_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
-	nr_cb *nr;
+	struct nr_sock *nr;
 
 	if (sock->type != SOCK_SEQPACKET || protocol != 0)
 		return -ESOCKTNOSUPPORT;
@@ -456,7 +439,7 @@
 static struct sock *nr_make_new(struct sock *osk)
 {
 	struct sock *sk;
-	nr_cb *nr, *onr;
+	struct nr_sock *nr, *onr;
 
 	if (osk->sk_type != SOCK_SEQPACKET)
 		return NULL;
@@ -508,7 +491,7 @@
 static int nr_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	nr_cb *nr;
+	struct nr_sock *nr;
 
 	if (sk == NULL) return 0;
 
@@ -556,7 +539,7 @@
 static int nr_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 {
 	struct sock *sk = sock->sk;
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 	struct full_sockaddr_ax25 *addr = (struct full_sockaddr_ax25 *)uaddr;
 	struct net_device *dev;
 	ax25_address *user, *source;
@@ -625,7 +608,7 @@
 	int addr_len, int flags)
 {
 	struct sock *sk = sock->sk;
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 	struct sockaddr_ax25 *addr = (struct sockaddr_ax25 *)uaddr;
 	ax25_address *user, *source = NULL;
 	struct net_device *dev;
@@ -822,7 +805,7 @@
 {
 	struct full_sockaddr_ax25 *sax = (struct full_sockaddr_ax25 *)uaddr;
 	struct sock *sk = sock->sk;
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 
 	lock_sock(sk);
 	if (peer != 0) {
@@ -850,7 +833,7 @@
 {
 	struct sock *sk;
 	struct sock *make;	
-	nr_cb *nr_make;
+	struct nr_sock *nr_make;
 	ax25_address *src, *dest, *user;
 	unsigned short circuit_index, circuit_id;
 	unsigned short peer_circuit_index, peer_circuit_id;
@@ -1015,7 +998,7 @@
 		      struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 	struct sockaddr_ax25 *usax = (struct sockaddr_ax25 *)msg->msg_name;
 	int err;
 	struct sockaddr_ax25 sax;
@@ -1273,7 +1256,7 @@
 {
 	struct sock *s = v;
 	struct net_device *dev;
-	nr_cb *nr;
+	struct nr_sock *nr;
 	const char *devname;
 
 	if (v == SEQ_START_TOKEN)
Index: bk-afu/net/netrom/nr_in.c
===================================================================
--- bk-afu.orig/net/netrom/nr_in.c	2005-03-17 23:53:59.000000000 +0000
+++ bk-afu/net/netrom/nr_in.c	2005-03-20 10:38:57.000000000 +0000
@@ -34,7 +34,7 @@
 static int nr_queue_rx_frame(struct sock *sk, struct sk_buff *skb, int more)
 {
 	struct sk_buff *skbo, *skbn = skb;
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 
 	skb_pull(skb, NR_NETWORK_LEN + NR_TRANSPORT_LEN);
 
@@ -76,7 +76,7 @@
 {
 	switch (frametype) {
 	case NR_CONNACK: {
-		nr_cb *nr = nr_sk(sk);
+		struct nr_sock *nr = nr_sk(sk);
 
 		nr_stop_t1timer(sk);
 		nr_start_idletimer(sk);
@@ -138,7 +138,7 @@
  */
 static int nr_state3_machine(struct sock *sk, struct sk_buff *skb, int frametype)
 {
-	nr_cb *nrom = nr_sk(sk);
+	struct nr_sock *nrom = nr_sk(sk);
 	struct sk_buff_head temp_queue;
 	struct sk_buff *skbn;
 	unsigned short save_vr;
@@ -264,7 +264,7 @@
 /* Higher level upcall for a LAPB frame - called with sk locked */
 int nr_process_rx_frame(struct sock *sk, struct sk_buff *skb)
 {
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 	int queued = 0, frametype;
 
 	if (nr->state == NR_STATE_0)
Index: bk-afu/net/netrom/nr_subr.c
===================================================================
--- bk-afu.orig/net/netrom/nr_subr.c	2005-03-17 23:54:00.000000000 +0000
+++ bk-afu/net/netrom/nr_subr.c	2005-03-20 10:39:42.000000000 +0000
@@ -34,7 +34,7 @@
  */
 void nr_clear_queues(struct sock *sk)
 {
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 
 	skb_queue_purge(&sk->sk_write_queue);
 	skb_queue_purge(&nr->ack_queue);
@@ -49,7 +49,7 @@
  */
 void nr_frames_acked(struct sock *sk, unsigned short nr)
 {
-	nr_cb *nrom = nr_sk(sk);
+	struct nr_sock *nrom = nr_sk(sk);
 	struct sk_buff *skb;
 
 	/*
@@ -88,7 +88,7 @@
  */
 int nr_validate_nr(struct sock *sk, unsigned short nr)
 {
-	nr_cb *nrom = nr_sk(sk);
+	struct nr_sock *nrom = nr_sk(sk);
 	unsigned short vc = nrom->va;
 
 	while (vc != nrom->vs) {
@@ -104,7 +104,7 @@
  */
 int nr_in_rx_window(struct sock *sk, unsigned short ns)
 {
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 	unsigned short vc = nr->vr;
 	unsigned short vt = (nr->vl + nr->window) % NR_MODULUS;
 
@@ -122,7 +122,7 @@
  */
 void nr_write_internal(struct sock *sk, int frametype)
 {
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 	struct sk_buff *skb;
 	unsigned char  *dptr;
 	int len, timeout;
Index: bk-afu/net/netrom/nr_out.c
===================================================================
--- bk-afu.orig/net/netrom/nr_out.c	2005-03-17 23:53:59.000000000 +0000
+++ bk-afu/net/netrom/nr_out.c	2005-03-20 10:39:20.000000000 +0000
@@ -82,7 +82,7 @@
  */
 static void nr_send_iframe(struct sock *sk, struct sk_buff *skb)
 {
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 
 	if (skb == NULL)
 		return;
@@ -101,7 +101,7 @@
 void nr_send_nak_frame(struct sock *sk)
 {
 	struct sk_buff *skb, *skbn;
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 
 	if ((skb = skb_peek(&nr->ack_queue)) == NULL)
 		return;
@@ -125,7 +125,7 @@
 
 void nr_kick(struct sock *sk)
 {
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 	struct sk_buff *skb, *skbn;
 	unsigned short start, end;
 
@@ -188,7 +188,7 @@
 
 void nr_transmit_buffer(struct sock *sk, struct sk_buff *skb)
 {
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 	unsigned char *dptr;
 
 	/*
@@ -223,7 +223,7 @@
 
 void nr_establish_data_link(struct sock *sk)
 {
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 
 	nr->condition = 0x00;
 	nr->n2count   = 0;
@@ -241,7 +241,7 @@
  */
 void nr_enquiry_response(struct sock *sk)
 {
-	nr_cb *nr = nr_sk(sk);
+	struct nr_sock *nr = nr_sk(sk);
 	int frametype = NR_INFOACK;
 
 	if (nr->condition & NR_COND_OWN_RX_BUSY) {
@@ -259,7 +259,7 @@
 
 void nr_check_iframes_acked(struct sock *sk, unsigned short nr)
 {
-	nr_cb *nrom = nr_sk(sk);
+	struct nr_sock *nrom = nr_sk(sk);
 
 	if (nrom->vs == nr) {
 		nr_frames_acked(sk, nr);
