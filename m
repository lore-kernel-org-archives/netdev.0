From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH 7/12] [X25] stop using sk_protinfo
Date: Fri, 21 Jan 2005 01:19:23 -0200
Message-ID: <41F074BB.8090501@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030700020208060201070604"
Cc: Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        Aristeu Rozanski <aris@cathedrallabs.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030700020208060201070604
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David/Aristeu,

	Subject says it all.

Regards,

- Arnaldo


--------------030700020208060201070604
Content-Type: text/plain;
 name="7-x25.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="7-x25.patch"

===================================================================


ChangeSet@1.2005, 2005-01-20 20:59:08-02:00, acme@toy.ghostprotocols.net
  [X25] stop using sk_protinfo
  
  Required to introduce struct connection_sock.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 include/net/x25.h        |   10 +++++++---
 net/x25/af_x25.c         |   36 +++++++++++++-----------------------
 net/x25/x25_facilities.c |    2 +-
 net/x25/x25_in.c         |   10 +++++-----
 net/x25/x25_out.c        |    8 ++++----
 net/x25/x25_proc.c       |    2 +-
 net/x25/x25_subr.c       |   14 +++++++-------
 net/x25/x25_timer.c      |   14 +++++++-------
 8 files changed, 45 insertions(+), 51 deletions(-)


diff -Nru a/include/net/x25.h b/include/net/x25.h
--- a/include/net/x25.h	2005-01-21 00:22:53 -02:00
+++ b/include/net/x25.h	2005-01-21 00:22:53 -02:00
@@ -10,6 +10,7 @@
 #ifndef _X25_H
 #define _X25_H 
 #include <linux/x25.h>
+#include <net/sock.h>
 
 #define	X25_ADDR_LEN			16
 
@@ -129,7 +130,8 @@
 	atomic_t		refcnt;
 };
 
-struct x25_opt {
+struct x25_sock {
+	struct sock		sk;
 	struct x25_address	source_addr, dest_addr;
 	struct x25_neigh	*neighbour;
 	unsigned int		lci;
@@ -141,7 +143,6 @@
 	struct sk_buff_head	fragment_queue;
 	struct sk_buff_head	interrupt_in_queue;
 	struct sk_buff_head	interrupt_out_queue;
-	struct sock		*sk;		/* Backlink to socket */
 	struct timer_list	timer;
 	struct x25_causediag	causediag;
 	struct x25_facilities	facilities;
@@ -149,7 +150,10 @@
 	unsigned long 		vc_facil_mask;	/* inc_call facilities mask */
 };
 
-#define x25_sk(__sk) ((struct x25_opt *)(__sk)->sk_protinfo)
+static inline struct x25_sock *x25_sk(const struct sock *sk)
+{
+	return (struct x25_sock *)sk;
+}
 
 /* af_x25.c */
 extern int  sysctl_x25_restart_request_timeout;
diff -Nru a/net/x25/af_x25.c b/net/x25/af_x25.c
--- a/net/x25/af_x25.c	2005-01-21 00:22:53 -02:00
+++ b/net/x25/af_x25.c	2005-01-21 00:22:53 -02:00
@@ -444,33 +444,23 @@
 
 static struct sock *x25_alloc_socket(void)
 {
-	struct x25_opt *x25;
-	struct sock *sk = sk_alloc(AF_X25, GFP_ATOMIC, 1, NULL);
+	struct x25_sock *x25;
+	struct sock *sk = sk_alloc(AF_X25, GFP_ATOMIC,
+				   sizeof(struct x25_sock), NULL);
 
 	if (!sk)
 		goto out;
 
-	x25 = sk->sk_protinfo = kmalloc(sizeof(*x25), GFP_ATOMIC);
-	if (!x25)
-		goto frees;
-
-	memset(x25, 0, sizeof(*x25));
-
-	x25->sk = sk;
-
 	sock_init_data(NULL, sk);
 	sk_set_owner(sk, THIS_MODULE);
 
+	x25 = x25_sk(sk);
 	skb_queue_head_init(&x25->ack_queue);
 	skb_queue_head_init(&x25->fragment_queue);
 	skb_queue_head_init(&x25->interrupt_in_queue);
 	skb_queue_head_init(&x25->interrupt_out_queue);
 out:
 	return sk;
-frees:
-	sk_free(sk);
-	sk = NULL;
-	goto out;
 }
 
 void x25_init_timers(struct sock *sk);
@@ -478,7 +468,7 @@
 static int x25_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
-	struct x25_opt *x25;
+	struct x25_sock *x25;
 	int rc = -ESOCKTNOSUPPORT;
 
 	if (sock->type != SOCK_SEQPACKET || protocol)
@@ -519,7 +509,7 @@
 static struct sock *x25_make_new(struct sock *osk)
 {
 	struct sock *sk = NULL;
-	struct x25_opt *x25, *ox25;
+	struct x25_sock *x25, *ox25;
 
 	if (osk->sk_type != SOCK_SEQPACKET)
 		goto out;
@@ -557,7 +547,7 @@
 static int x25_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	struct x25_opt *x25;
+	struct x25_sock *x25;
 
 	if (!sk)
 		goto out;
@@ -644,7 +634,7 @@
 		       int addr_len, int flags)
 {
 	struct sock *sk = sock->sk;
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 	struct sockaddr_x25 *addr = (struct sockaddr_x25 *)uaddr;
 	struct x25_route *rt;
 	int rc = 0;
@@ -802,7 +792,7 @@
 {
 	struct sockaddr_x25 *sx25 = (struct sockaddr_x25 *)uaddr;
 	struct sock *sk = sock->sk;
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 
 	if (peer) {
 		if (sk->sk_state != TCP_ESTABLISHED)
@@ -822,7 +812,7 @@
 {
 	struct sock *sk;
 	struct sock *make;
-	struct x25_opt *makex25;
+	struct x25_sock *makex25;
 	struct x25_address source_addr, dest_addr;
 	struct x25_facilities facilities;
 	struct x25_calluserdata calluserdata;
@@ -935,7 +925,7 @@
 		       struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 	struct sockaddr_x25 *usx25 = (struct sockaddr_x25 *)msg->msg_name;
 	struct sockaddr_x25 sx25;
 	struct sk_buff *skb;
@@ -1112,7 +1102,7 @@
 		       int flags)
 {
 	struct sock *sk = sock->sk;
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 	struct sockaddr_x25 *sx25 = (struct sockaddr_x25 *)msg->msg_name;
 	size_t copied;
 	int qbit;
@@ -1201,7 +1191,7 @@
 static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 	void __user *argp = (void __user *)arg;
 	int rc;
 
diff -Nru a/net/x25/x25_facilities.c b/net/x25/x25_facilities.c
--- a/net/x25/x25_facilities.c	2005-01-21 00:22:53 -02:00
+++ b/net/x25/x25_facilities.c	2005-01-21 00:22:53 -02:00
@@ -158,7 +158,7 @@
 int x25_negotiate_facilities(struct sk_buff *skb, struct sock *sk,
 			     struct x25_facilities *new)
 {
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 	struct x25_facilities *ours = &x25->facilities;
 	struct x25_facilities theirs;
 	int len;
diff -Nru a/net/x25/x25_in.c b/net/x25/x25_in.c
--- a/net/x25/x25_in.c	2005-01-21 00:22:53 -02:00
+++ b/net/x25/x25_in.c	2005-01-21 00:22:53 -02:00
@@ -34,7 +34,7 @@
 static int x25_queue_rx_frame(struct sock *sk, struct sk_buff *skb, int more)
 {
 	struct sk_buff *skbo, *skbn = skb;
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 
 	if (more) {
 		x25->fraglen += skb->len;
@@ -89,7 +89,7 @@
 
 	switch (frametype) {
 		case X25_CALL_ACCEPTED: {
-			struct x25_opt *x25 = x25_sk(sk);
+			struct x25_sock *x25 = x25_sk(sk);
 
 			x25_stop_timer(sk);
 			x25->condition = 0x00;
@@ -165,7 +165,7 @@
 {
 	int queued = 0;
 	int modulus;
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 	
 	modulus = (x25->neighbour->extended) ? X25_EMODULUS : X25_SMODULUS;
 
@@ -295,7 +295,7 @@
 		case X25_RESET_REQUEST:
 			x25_write_internal(sk, X25_RESET_CONFIRMATION);
 		case X25_RESET_CONFIRMATION: {
-			struct x25_opt *x25 = x25_sk(sk);
+			struct x25_sock *x25 = x25_sk(sk);
 
 			x25_stop_timer(sk);
 			x25->condition = 0x00;
@@ -322,7 +322,7 @@
 /* Higher level upcall for a LAPB frame */
 int x25_process_rx_frame(struct sock *sk, struct sk_buff *skb)
 {
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 	int queued = 0, frametype, ns, nr, q, d, m;
 
 	if (x25->state == X25_STATE_0)
diff -Nru a/net/x25/x25_out.c b/net/x25/x25_out.c
--- a/net/x25/x25_out.c	2005-01-21 00:22:53 -02:00
+++ b/net/x25/x25_out.c	2005-01-21 00:22:53 -02:00
@@ -54,7 +54,7 @@
 	unsigned char header[X25_EXT_MIN_LEN];
 	int err, frontlen, len;
 	int sent=0, noblock = X25_SKB_CB(skb)->flags & MSG_DONTWAIT;
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 	int header_len = x25->neighbour->extended ? X25_EXT_MIN_LEN :
 						    X25_STD_MIN_LEN;
 	int max_len = x25_pacsize_to_bytes(x25->facilities.pacsize_out);
@@ -116,7 +116,7 @@
  */
 static void x25_send_iframe(struct sock *sk, struct sk_buff *skb)
 {
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 
 	if (!skb)
 		return;
@@ -139,7 +139,7 @@
 	struct sk_buff *skb, *skbn;
 	unsigned short start, end;
 	int modulus;
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 
 	if (x25->state != X25_STATE_3)
 		return;
@@ -212,7 +212,7 @@
 
 void x25_enquiry_response(struct sock *sk)
 {
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 
 	if (x25->condition & X25_COND_OWN_RX_BUSY)
 		x25_write_internal(sk, X25_RNR);
diff -Nru a/net/x25/x25_proc.c b/net/x25/x25_proc.c
--- a/net/x25/x25_proc.c	2005-01-21 00:22:53 -02:00
+++ b/net/x25/x25_proc.c	2005-01-21 00:22:53 -02:00
@@ -134,7 +134,7 @@
 static int x25_seq_socket_show(struct seq_file *seq, void *v)
 {
 	struct sock *s;
-	struct x25_opt *x25;
+	struct x25_sock *x25;
 	struct net_device *dev;
 	const char *devname;
 
diff -Nru a/net/x25/x25_subr.c b/net/x25/x25_subr.c
--- a/net/x25/x25_subr.c	2005-01-21 00:22:53 -02:00
+++ b/net/x25/x25_subr.c	2005-01-21 00:22:53 -02:00
@@ -33,7 +33,7 @@
  */
 void x25_clear_queues(struct sock *sk)
 {
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 
 	skb_queue_purge(&sk->sk_write_queue);
 	skb_queue_purge(&x25->ack_queue);
@@ -51,7 +51,7 @@
 void x25_frames_acked(struct sock *sk, unsigned short nr)
 {
 	struct sk_buff *skb;
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 	int modulus = x25->neighbour->extended ? X25_EMODULUS : X25_SMODULUS;
 
 	/*
@@ -89,7 +89,7 @@
  */
 int x25_validate_nr(struct sock *sk, unsigned short nr)
 {
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 	unsigned short vc = x25->va;
 	int modulus = x25->neighbour->extended ? X25_EMODULUS : X25_SMODULUS;
 
@@ -108,7 +108,7 @@
  */
 void x25_write_internal(struct sock *sk, int frametype)
 {
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 	struct sk_buff *skb;
 	unsigned char  *dptr;
 	unsigned char  facilities[X25_MAX_FAC_LEN];
@@ -248,7 +248,7 @@
 int x25_decode(struct sock *sk, struct sk_buff *skb, int *ns, int *nr, int *q,
 	       int *d, int *m)
 {
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 	unsigned char *frame = skb->data;
 
 	*ns = *nr = *q = *d = *m = 0;
@@ -315,7 +315,7 @@
 void x25_disconnect(struct sock *sk, int reason, unsigned char cause,
 		    unsigned char diagnostic)
 {
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 
 	x25_clear_queues(sk);
 	x25_stop_timer(sk);
@@ -342,7 +342,7 @@
  */
 void x25_check_rbuf(struct sock *sk)
 {
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 
 	if (atomic_read(&sk->sk_rmem_alloc) < (sk->sk_rcvbuf / 2) &&
 	    (x25->condition & X25_COND_OWN_RX_BUSY)) {
diff -Nru a/net/x25/x25_timer.c b/net/x25/x25_timer.c
--- a/net/x25/x25_timer.c	2005-01-21 00:22:53 -02:00
+++ b/net/x25/x25_timer.c	2005-01-21 00:22:53 -02:00
@@ -31,7 +31,7 @@
 
 void x25_init_timers(struct sock *sk)
 {
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 
 	init_timer(&x25->timer);
 	x25->timer.data     = (unsigned long)sk;
@@ -54,28 +54,28 @@
 
 void x25_start_t2timer(struct sock *sk)
 {
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 
 	mod_timer(&x25->timer, jiffies + x25->t2);
 }
 
 void x25_start_t21timer(struct sock *sk)
 {
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 
 	mod_timer(&x25->timer, jiffies + x25->t21);
 }
 
 void x25_start_t22timer(struct sock *sk)
 {
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 
 	mod_timer(&x25->timer, jiffies + x25->t22);
 }
 
 void x25_start_t23timer(struct sock *sk)
 {
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 
 	mod_timer(&x25->timer, jiffies + x25->t23);
 }
@@ -87,7 +87,7 @@
 
 unsigned long x25_display_timer(struct sock *sk)
 {
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 
 	if (!timer_pending(&x25->timer))
 		return 0;
@@ -138,7 +138,7 @@
  */
 static inline void x25_do_timer_expiry(struct sock * sk)
 {
-	struct x25_opt *x25 = x25_sk(sk);
+	struct x25_sock *x25 = x25_sk(sk);
 
 	switch (x25->state) {
 



--------------030700020208060201070604--
