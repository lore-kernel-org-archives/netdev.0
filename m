From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH 9/9] llc: use sock slab cache
Date: Thu, 20 Jan 2005 00:04:50 -0200
Message-ID: <41EF11C2.5020900@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070707050508020109050103"
Cc: Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070707050508020109050103
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David,

	The last one in this series, for LLC.

- Arnaldo


--------------070707050508020109050103
Content-Type: text/plain;
 name="llc_sock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="llc_sock.patch"

===================================================================


ChangeSet@1.2345, 2005-01-19 23:07:31-02:00, acme@toy.ghostprotocols.net
  [LLC] use a private slab cache for socks
  
  Required to get rid of sk_protinfo and to introduce struct connection_sock,
  also for consistency with other protocol families implementations.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 include/net/llc_conn.h |   13 +++++-
 net/llc/af_llc.c       |   40 +++++++++++++++------
 net/llc/llc_c_ac.c     |   92 ++++++++++++++++++++++++-------------------------
 net/llc/llc_c_ev.c     |    2 -
 net/llc/llc_conn.c     |   50 +++++++++-----------------
 net/llc/llc_if.c       |    4 +-
 net/llc/llc_proc.c     |    8 ++--
 net/llc/llc_sap.c      |    2 -
 8 files changed, 111 insertions(+), 100 deletions(-)


diff -Nru a/include/net/llc_conn.h b/include/net/llc_conn.h
--- a/include/net/llc_conn.h	2005-01-19 23:52:40 -02:00
+++ b/include/net/llc_conn.h	2005-01-19 23:52:40 -02:00
@@ -13,6 +13,7 @@
  */
 #include <linux/timer.h>
 #include <net/llc_if.h>
+#include <net/sock.h>
 #include <linux/llc.h>
 
 #define LLC_EVENT                1
@@ -28,8 +29,9 @@
 	u16		  expire;	/* timer expire time */
 };
 
-struct llc_opt {
-	struct sock	    *sk;		/* sock that has this llc_opt */
+struct llc_sock {
+	/* struct sock must be the first member of llc_sock */
+	struct sock	    sk;
 	struct sockaddr_llc addr;		/* address sock is bound to */
 	u8		    state;		/* state of connection */
 	struct llc_sap	    *sap;		/* pointer to parent SAP */
@@ -75,7 +77,12 @@
 					      Used for resending FRMR */
 };
 
-#define llc_sk(__sk) ((struct llc_opt *)(__sk)->sk_protinfo)
+static inline struct llc_sock *llc_sk(const struct sock *sk)
+{
+	return (struct llc_sock *)sk;
+}
+
+extern kmem_cache_t *llc_sk_slab;
 
 static __inline__ void llc_set_backlog_type(struct sk_buff *skb, char type)
 {
diff -Nru a/net/llc/af_llc.c b/net/llc/af_llc.c
--- a/net/llc/af_llc.c	2005-01-19 23:52:40 -02:00
+++ b/net/llc/af_llc.c	2005-01-19 23:52:40 -02:00
@@ -42,6 +42,8 @@
 static int llc_ui_wait_for_data(struct sock *sk, int timeout);
 static int llc_ui_wait_for_busy_core(struct sock *sk, int timeout);
 
+kmem_cache_t *llc_sk_slab;
+
 #if 0
 #define dprintk(args...) printk(KERN_DEBUG args)
 #else
@@ -113,7 +115,7 @@
  */
 static int llc_ui_send_data(struct sock* sk, struct sk_buff *skb, int noblock)
 {
-	struct llc_opt* llc = llc_sk(sk);
+	struct llc_sock* llc = llc_sk(sk);
 	int rc = 0;
 
 	if (llc_data_accept_state(llc->state) || llc->p_flag) {
@@ -169,7 +171,7 @@
 static int llc_ui_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	struct llc_opt *llc;
+	struct llc_sock *llc;
 
 	if (!sk)
 		goto out;
@@ -244,7 +246,7 @@
 static int llc_ui_autobind(struct socket *sock, struct sockaddr_llc *addr)
 {
 	struct sock *sk = sock->sk;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	struct llc_sap *sap;
 	int rc = -EINVAL;
 
@@ -293,7 +295,7 @@
 {
 	struct sockaddr_llc *addr = (struct sockaddr_llc *)uaddr;
 	struct sock *sk = sock->sk;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	struct llc_sap *sap;
 	int rc = -EINVAL;
 
@@ -394,7 +396,7 @@
 			  int addrlen, int flags)
 {
 	struct sock *sk = sock->sk;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	struct sockaddr_llc *addr = (struct sockaddr_llc *)uaddr;
 	struct net_device *dev;
 	int rc = -EINVAL;
@@ -571,7 +573,7 @@
 static int llc_ui_wait_for_busy_core(struct sock *sk, int timeout)
 {
 	DECLARE_WAITQUEUE(wait, current);
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	int rc;
 
 	add_wait_queue_exclusive(sk->sk_sleep, &wait);
@@ -612,7 +614,7 @@
 static int llc_ui_accept(struct socket *sock, struct socket *newsock, int flags)
 {
 	struct sock *sk = sock->sk, *newsk;
-	struct llc_opt *llc, *newllc;
+	struct llc_sock *llc, *newllc;
 	struct sk_buff *skb;
 	int rc = -EOPNOTSUPP;
 
@@ -728,7 +730,7 @@
 			  struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	struct sockaddr_llc *addr = (struct sockaddr_llc *)msg->msg_name;
 	int flags = msg->msg_flags;
 	int noblock = flags & MSG_DONTWAIT;
@@ -819,7 +821,7 @@
 {
 	struct sockaddr_llc sllc;
 	struct sock *sk = sock->sk;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	int rc = 0;
 
 	lock_sock(sk);
@@ -883,7 +885,7 @@
 			     char __user *optval, int optlen)
 {
 	struct sock *sk = sock->sk;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	int rc = -EINVAL, opt;
 
 	lock_sock(sk);
@@ -958,7 +960,7 @@
 			     char __user *optval, int __user *optlen)
 {
 	struct sock *sk = sock->sk;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	int val = 0, len = 0, rc = -EINVAL;
 
 	lock_sock(sk);
@@ -1032,6 +1034,13 @@
 static int __init llc2_init(void)
 {
 	int rc;
+	
+	llc_sk_slab = kmem_cache_create("llc_sock",
+					sizeof(struct llc_sock), 0,
+					SLAB_HWCACHE_ALIGN, NULL, NULL);
+
+	if (llc_sk_slab == NULL)
+		return -ENOMEM;
 
 	llc_build_offset_table();
 	llc_station_init();
@@ -1041,7 +1050,11 @@
 		sock_register(&llc_ui_family_ops);
 		llc_add_pack(LLC_DEST_SAP, llc_sap_handler);
 		llc_add_pack(LLC_DEST_CONN, llc_conn_handler);
+	} else {
+		kmem_cache_destroy(llc_sk_slab);
+		llc_sk_slab = NULL;
 	}
+
 	return rc;
 }
 
@@ -1052,6 +1065,11 @@
 	llc_remove_pack(LLC_DEST_CONN);
 	sock_unregister(PF_LLC);
 	llc_proc_exit();
+
+	if (llc_sk_slab != NULL) {
+		kmem_cache_destroy(llc_sk_slab);
+		llc_sk_slab = NULL;
+	}
 }
 
 module_init(llc2_init);
diff -Nru a/net/llc/llc_c_ac.c b/net/llc/llc_c_ac.c
--- a/net/llc/llc_c_ac.c	2005-01-19 23:52:40 -02:00
+++ b/net/llc/llc_c_ac.c	2005-01-19 23:52:40 -02:00
@@ -44,7 +44,7 @@
 
 int llc_conn_ac_clear_remote_busy(struct sock *sk, struct sk_buff *skb)
 {
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	if (llc->remote_busy_flag) {
 		u8 nr;
@@ -68,7 +68,7 @@
 	sap = llc_sap_find(dsap);
 	if (sap) {
 		struct llc_conn_state_ev *ev = llc_conn_ev(skb);
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 
 		llc_pdu_decode_sa(skb, llc->daddr.mac);
 		llc_pdu_decode_da(skb, llc->laddr.mac);
@@ -146,7 +146,7 @@
 	int rc = 1;
 	struct llc_conn_state_ev *ev = llc_conn_ev(skb);
 	struct llc_pdu_un *pdu = llc_pdu_un_hdr(skb);
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	switch (ev->type) {
 	case LLC_CONN_EV_TYPE_PDU:
@@ -207,7 +207,7 @@
 int llc_conn_ac_stop_rej_tmr_if_data_flag_eq_2(struct sock *sk,
 					       struct sk_buff *skb)
 {
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	if (llc->data_flag == 2)
 		del_timer(&llc->rej_sent_timer.timer);
@@ -220,7 +220,7 @@
 	struct sk_buff *nskb = llc_alloc_frame();
 
 	if (nskb) {
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 
 		nskb->dev = llc->dev;
@@ -246,7 +246,7 @@
 	struct sk_buff *nskb = llc_alloc_frame();
 
 	if (nskb) {
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 		u8 f_bit;
 
@@ -273,7 +273,7 @@
 	struct sk_buff *nskb = llc_alloc_frame();
 
 	if (nskb) {
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 		u8 f_bit = 1;
 
@@ -299,7 +299,7 @@
 	int rc = -ENOBUFS;
 	struct sk_buff *nskb;
 	struct llc_pdu_sn *pdu = llc_pdu_sn_hdr(skb);
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	llc->rx_pdu_hdr = *((u32 *)pdu);
 	if (LLC_PDU_IS_CMD(pdu))
@@ -334,7 +334,7 @@
 
 	if (nskb) {
 		u8 f_bit = 0;
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 		struct llc_pdu_sn *pdu = (struct llc_pdu_sn *)&llc->rx_pdu_hdr;
 
@@ -364,7 +364,7 @@
 	llc_pdu_decode_pf_bit(skb, &f_bit);
 	nskb = llc_alloc_frame();
 	if (nskb) {
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 		struct llc_pdu_sn *pdu = llc_pdu_sn_hdr(skb);
 
@@ -388,7 +388,7 @@
 int llc_conn_ac_send_i_cmd_p_set_1(struct sock *sk, struct sk_buff *skb)
 {
 	int rc;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	struct llc_sap *sap = llc->sap;
 
 	llc_pdu_header_init(skb, LLC_PDU_TYPE_I, sap->laddr.lsap,
@@ -405,7 +405,7 @@
 static int llc_conn_ac_send_i_cmd_p_set_0(struct sock *sk, struct sk_buff *skb)
 {
 	int rc;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	struct llc_sap *sap = llc->sap;
 
 	llc_pdu_header_init(skb, LLC_PDU_TYPE_I, sap->laddr.lsap,
@@ -422,7 +422,7 @@
 int llc_conn_ac_send_i_xxx_x_set_0(struct sock *sk, struct sk_buff *skb)
 {
 	int rc;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	struct llc_sap *sap = llc->sap;
 
 	llc_pdu_header_init(skb, LLC_PDU_TYPE_I, sap->laddr.lsap,
@@ -454,7 +454,7 @@
 	struct sk_buff *nskb = llc_alloc_frame();
 
 	if (nskb) {
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 
 		nskb->dev = llc->dev;
@@ -490,7 +490,7 @@
 	struct sk_buff *nskb = llc_alloc_frame();
 
 	if (nskb) {
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 
 		nskb->dev = llc->dev;
@@ -516,7 +516,7 @@
 
 	if (nskb) {
 		u8 f_bit = 1;
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 
 		nskb->dev = llc->dev;
@@ -541,7 +541,7 @@
 	struct sk_buff *nskb = llc_alloc_frame();
 
 	if (nskb) {
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 		u8 f_bit = 0;
 
@@ -567,7 +567,7 @@
 	struct sk_buff *nskb = llc_alloc_frame();
 
 	if (nskb) {
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 
 		nskb->dev = llc->dev;
@@ -592,7 +592,7 @@
 	struct sk_buff *nskb = llc_alloc_frame();
 
 	if (nskb) {
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 		u8 f_bit = 1;
 
@@ -619,7 +619,7 @@
 
 	if (nskb) {
 		u8 f_bit = 0;
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 
 		nskb->dev = llc->dev;
@@ -640,7 +640,7 @@
 
 int llc_conn_ac_set_remote_busy(struct sock *sk, struct sk_buff *skb)
 {
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	if (!llc->remote_busy_flag) {
 		llc->remote_busy_flag = 1;
@@ -656,7 +656,7 @@
 	struct sk_buff *nskb = llc_alloc_frame();
 
 	if (nskb) {
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 
 		nskb->dev = llc->dev;
@@ -681,7 +681,7 @@
 	struct sk_buff *nskb = llc_alloc_frame();
 
 	if (nskb) {
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 
 		nskb->dev = llc->dev;
@@ -706,7 +706,7 @@
 	struct sk_buff *nskb = llc_alloc_frame();
 
 	if (nskb) {
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 		u8 f_bit = 1;
 
@@ -732,7 +732,7 @@
 	struct sk_buff *nskb = llc_alloc_frame();
 
 	if (nskb) {
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 		u8 f_bit = 1;
 
@@ -758,7 +758,7 @@
 	struct sk_buff *nskb = llc_alloc_frame();
 
 	if (nskb) {
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 
 		nskb->dev = llc->dev;
@@ -783,7 +783,7 @@
 	struct sk_buff *nskb = llc_alloc_frame();
 
 	if (nskb) {
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 
 		nskb->dev = llc->dev;
@@ -816,7 +816,7 @@
 {
 	int rc = -ENOBUFS;
 	struct sk_buff *nskb = llc_alloc_frame();
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	if (nskb) {
 		struct llc_sap *sap = llc->sap;
@@ -849,7 +849,7 @@
 
 	llc_pdu_decode_pf_bit(skb, &f_bit);
 	if (nskb) {
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 
 		nskb->dev = llc->dev;
@@ -882,7 +882,7 @@
 
 int llc_conn_ac_start_p_timer(struct sock *sk, struct sk_buff *skb)
 {
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	llc_conn_set_p_flag(sk, 1);
 	mod_timer(&llc->pf_cycle_timer.timer,
@@ -903,7 +903,7 @@
 int llc_conn_ac_send_ack_if_needed(struct sock *sk, struct sk_buff *skb)
 {
 	u8 pf_bit;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	llc_pdu_decode_pf_bit(skb, &pf_bit);
 	llc->ack_pf |= pf_bit & 1;
@@ -950,7 +950,7 @@
 					      struct sk_buff *skb)
 {
 	int rc;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	struct llc_sap *sap = llc->sap;
 
 	llc_pdu_header_init(skb, LLC_PDU_TYPE_I, sap->laddr.lsap,
@@ -976,7 +976,7 @@
  */
 int llc_conn_ac_send_i_as_ack(struct sock *sk, struct sk_buff *skb)
 {
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	if (llc->ack_must_be_send) {
 		llc_conn_ac_send_i_rsp_f_set_ackpf(sk, skb);
@@ -1004,7 +1004,7 @@
 	struct sk_buff *nskb = llc_alloc_frame();
 
 	if (nskb) {
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 
 		nskb->dev = llc->dev;
@@ -1035,7 +1035,7 @@
  */
 static int llc_conn_ac_inc_npta_value(struct sock *sk, struct sk_buff *skb)
 {
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	if (!llc->inc_cntr) {
 		llc->dec_step = 0;
@@ -1058,7 +1058,7 @@
  */
 int llc_conn_ac_adjust_npta_by_rr(struct sock *sk, struct sk_buff *skb)
 {
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	if (!llc->connect_step && !llc->remote_busy_flag) {
 		if (!llc->dec_step) {
@@ -1084,7 +1084,7 @@
  */
 int llc_conn_ac_adjust_npta_by_rnr(struct sock *sk, struct sk_buff *skb)
 {
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	if (llc->remote_busy_flag)
 		if (!llc->dec_step) {
@@ -1109,7 +1109,7 @@
  */
 int llc_conn_ac_dec_tx_win_size(struct sock *sk, struct sk_buff *skb)
 {
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	u8 unacked_pdu = skb_queue_len(&llc->pdu_unack_q);
 
 	llc->k -= unacked_pdu;
@@ -1128,7 +1128,7 @@
  */
 int llc_conn_ac_inc_tx_win_size(struct sock *sk, struct sk_buff *skb)
 {
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	llc->k += 1;
 	if (llc->k > 128)
@@ -1138,7 +1138,7 @@
 
 int llc_conn_ac_stop_all_timers(struct sock *sk, struct sk_buff *skb)
 {
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	del_timer(&llc->pf_cycle_timer.timer);
 	del_timer(&llc->ack_timer.timer);
@@ -1151,7 +1151,7 @@
 
 int llc_conn_ac_stop_other_timers(struct sock *sk, struct sk_buff *skb)
 {
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	del_timer(&llc->rej_sent_timer.timer);
 	del_timer(&llc->pf_cycle_timer.timer);
@@ -1163,7 +1163,7 @@
 
 int llc_conn_ac_start_ack_timer(struct sock *sk, struct sk_buff *skb)
 {
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	mod_timer(&llc->ack_timer.timer, jiffies + llc->ack_timer.expire * HZ);
 	return 0;
@@ -1171,7 +1171,7 @@
 
 int llc_conn_ac_start_rej_timer(struct sock *sk, struct sk_buff *skb)
 {
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	mod_timer(&llc->rej_sent_timer.timer,
 		  jiffies + llc->rej_sent_timer.expire * HZ);
@@ -1181,7 +1181,7 @@
 int llc_conn_ac_start_ack_tmr_if_not_running(struct sock *sk,
 					     struct sk_buff *skb)
 {
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	if (!timer_pending(&llc->ack_timer.timer))
 		mod_timer(&llc->ack_timer.timer,
@@ -1197,7 +1197,7 @@
 
 int llc_conn_ac_stop_p_timer(struct sock *sk, struct sk_buff *skb)
 {
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	del_timer(&llc->pf_cycle_timer.timer);
 	llc_conn_set_p_flag(sk, 0);
@@ -1215,7 +1215,7 @@
 	int acked;
 	u16 unacked = 0;
 	struct llc_pdu_sn *pdu = llc_pdu_sn_hdr(skb);
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	llc->last_nr = PDU_SUPV_GET_Nr(pdu);
 	acked = llc_conn_remove_acked_pdus(sk, llc->last_nr, &unacked);
diff -Nru a/net/llc/llc_c_ev.c b/net/llc/llc_c_ev.c
--- a/net/llc/llc_c_ev.c	2005-01-19 23:52:40 -02:00
+++ b/net/llc/llc_c_ev.c	2005-01-19 23:52:40 -02:00
@@ -78,7 +78,7 @@
 	u8 nr1, nr2;
 	struct sk_buff *skb;
 	struct llc_pdu_sn *pdu;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	int rc = 0;
 
 	if (llc->dev->flags & IFF_LOOPBACK)
diff -Nru a/net/llc/llc_conn.c b/net/llc/llc_conn.c
--- a/net/llc/llc_conn.c	2005-01-19 23:52:40 -02:00
+++ b/net/llc/llc_conn.c	2005-01-19 23:52:40 -02:00
@@ -53,7 +53,7 @@
 int llc_conn_state_process(struct sock *sk, struct sk_buff *skb)
 {
 	int rc;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	struct llc_conn_state_ev *ev = llc_conn_ev(skb);
 
 	/*
@@ -221,7 +221,7 @@
 	struct sk_buff *skb;
 	struct llc_pdu_sn *pdu;
 	u16 nbr_unack_pdus;
-	struct llc_opt *llc;
+	struct llc_sock *llc;
 	u8 howmany_resend = 0;
 
 	llc_conn_remove_acked_pdus(sk, nr, &nbr_unack_pdus);
@@ -263,7 +263,7 @@
 {
 	struct sk_buff *skb;
 	u16 nbr_unack_pdus;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	u8 howmany_resend = 0;
 
 	llc_conn_remove_acked_pdus(sk, nr, &nbr_unack_pdus);
@@ -305,7 +305,7 @@
 	struct sk_buff *skb;
 	struct llc_pdu_sn *pdu;
 	int nbr_acked = 0;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	int q_len = skb_queue_len(&llc->pdu_unack_q);
 
 	if (!q_len)
@@ -366,7 +366,7 @@
 static int llc_conn_service(struct sock *sk, struct sk_buff *skb)
 {
 	int rc = 1;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	struct llc_conn_state_trans *trans;
 
 	if (llc->state > NBR_CONN_STATES)
@@ -399,7 +399,7 @@
 	struct llc_conn_state_trans **next_trans;
 	llc_conn_ev_qfyr_t *next_qualifier;
 	struct llc_conn_state_ev *ev = llc_conn_ev(skb);
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	struct llc_conn_state *curr_state =
 					&llc_conn_state_table[llc->state - 1];
 
@@ -478,7 +478,7 @@
 
 	read_lock_bh(&sap->sk_list.lock);
 	sk_for_each(rc, node, &sap->sk_list.list) {
-		struct llc_opt *llc = llc_sk(rc);
+		struct llc_sock *llc = llc_sk(rc);
 
 		if (llc->laddr.lsap == laddr->lsap &&
 		    llc->daddr.lsap == daddr->lsap &&
@@ -511,7 +511,7 @@
 
 	read_lock_bh(&sap->sk_list.lock);
 	sk_for_each(rc, node, &sap->sk_list.list) {
-		struct llc_opt *llc = llc_sk(rc);
+		struct llc_sock *llc = llc_sk(rc);
 
 		if (rc->sk_type == SOCK_STREAM && rc->sk_state == TCP_LISTEN &&
 		    llc->laddr.lsap == laddr->lsap &&
@@ -650,7 +650,7 @@
 static int llc_conn_rcv(struct sock* sk, struct sk_buff *skb)
 {
 	struct llc_conn_state_ev *ev = llc_conn_ev(skb);
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	if (!llc->dev)
 		llc->dev = skb->dev;
@@ -675,7 +675,7 @@
 		 * Didn't find an active connection; verify if there
 		 * is a listening socket for this llc addr
 		 */
-		struct llc_opt *llc;
+		struct llc_sock *llc;
 		struct sock *parent = llc_lookup_listener(sap, &daddr);
 
 		if (!parent) {
@@ -756,7 +756,7 @@
 static int llc_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	int rc = 0;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	if (llc_backlog_type(skb) == LLC_PACKET) {
 		if (llc->state > 1) /* not closed */
@@ -786,17 +786,10 @@
  *
  *     Initializes a socket with default llc values.
  */
-static int llc_sk_init(struct sock* sk)
+static void llc_sk_init(struct sock* sk)
 {
-	struct llc_opt *llc = kmalloc(sizeof(*llc), GFP_ATOMIC);
-	int rc = -ENOMEM;
+	struct llc_sock *llc = llc_sk(sk);
 
-	if (!llc)
-		goto out;
-	memset(llc, 0, sizeof(*llc));
-	rc = 0;
-
-	llc->sk	      = sk;
 	llc->state    = LLC_CONN_STATE_ADM;
 	llc->inc_cntr = llc->dec_cntr = 2;
 	llc->dec_step = llc->connect_step = 1;
@@ -827,9 +820,6 @@
 		        * tx_win of remote LLC) */
 	skb_queue_head_init(&llc->pdu_unack_q);
 	sk->sk_backlog_rcv = llc_backlog_rcv;
-	sk->sk_protinfo = llc;
-out:
-	return rc;
 }
 
 /**
@@ -842,12 +832,12 @@
  */
 struct sock *llc_sk_alloc(int family, int priority)
 {
-	struct sock *sk = sk_alloc(family, priority, 1, NULL);
+	struct sock *sk = sk_alloc(family, priority,
+				   sizeof(struct llc_sock), llc_sk_slab);
 
 	if (!sk)
 		goto out;
-	if (llc_sk_init(sk))
-		goto outsk;
+	llc_sk_init(sk);
 	sock_init_data(NULL, sk);
 	sk_set_owner(sk, THIS_MODULE);
 #ifdef LLC_REFCNT_DEBUG
@@ -857,10 +847,6 @@
 #endif
 out:
 	return sk;
-outsk:
-	sk_free(sk);
-	sk = NULL;
-	goto out;
 }
 
 /**
@@ -871,7 +857,7 @@
  */
 void llc_sk_free(struct sock *sk)
 {
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	llc->state = LLC_CONN_OUT_OF_SVC;
 	/* Stop all (possibly) running timers */
@@ -908,7 +894,7 @@
  */
 void llc_sk_reset(struct sock *sk)
 {
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	llc_conn_ac_stop_all_timers(sk, NULL);
 	skb_queue_purge(&sk->sk_write_queue);
diff -Nru a/net/llc/llc_if.c b/net/llc/llc_if.c
--- a/net/llc/llc_if.c	2005-01-19 23:52:40 -02:00
+++ b/net/llc/llc_if.c	2005-01-19 23:52:40 -02:00
@@ -45,7 +45,7 @@
 {
 	struct llc_conn_state_ev *ev;
 	int rc = -ECONNABORTED;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 
 	if (llc->state == LLC_CONN_STATE_ADM)
 		goto out;
@@ -86,7 +86,7 @@
 	int rc = -EISCONN;
 	struct llc_addr laddr, daddr;
 	struct sk_buff *skb;
-	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sock *llc = llc_sk(sk);
 	struct sock *existing;
 
 	laddr.lsap = llc->sap->laddr.lsap;
diff -Nru a/net/llc/llc_proc.c b/net/llc/llc_proc.c
--- a/net/llc/llc_proc.c	2005-01-19 23:52:40 -02:00
+++ b/net/llc/llc_proc.c	2005-01-19 23:52:40 -02:00
@@ -65,7 +65,7 @@
 static void *llc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct sock* sk, *next;
-	struct llc_opt *llc;
+	struct llc_sock *llc;
 	struct llc_sap *sap;
 
 	++*pos;
@@ -102,7 +102,7 @@
 {
 	if (v && v != SEQ_START_TOKEN) {
 		struct sock *sk = v;
-		struct llc_opt *llc = llc_sk(sk);
+		struct llc_sock *llc = llc_sk(sk);
 		struct llc_sap *sap = llc->sap;
 
 		read_unlock_bh(&sap->sk_list.lock);
@@ -113,7 +113,7 @@
 static int llc_seq_socket_show(struct seq_file *seq, void *v)
 {
 	struct sock* sk;
-	struct llc_opt *llc;
+	struct llc_sock *llc;
 
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq, "SKt Mc local_mac_sap        remote_mac_sap   "
@@ -160,7 +160,7 @@
 static int llc_seq_core_show(struct seq_file *seq, void *v)
 {
 	struct sock* sk;
-	struct llc_opt *llc;
+	struct llc_sock *llc;
 
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq, "Connection list:\n"
diff -Nru a/net/llc/llc_sap.c b/net/llc/llc_sap.c
--- a/net/llc/llc_sap.c	2005-01-19 23:52:40 -02:00
+++ b/net/llc/llc_sap.c	2005-01-19 23:52:40 -02:00
@@ -283,7 +283,7 @@
 
 	read_lock_bh(&sap->sk_list.lock);
 	sk_for_each(rc, node, &sap->sk_list.list) {
-		struct llc_opt *llc = llc_sk(rc);
+		struct llc_sock *llc = llc_sk(rc);
 
 		if (rc->sk_type == SOCK_DGRAM &&
 		    llc->laddr.lsap == laddr->lsap &&



--------------070707050508020109050103--
