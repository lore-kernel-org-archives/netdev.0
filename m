From: akpm@osdl.org
Subject: [patch 02/13] X.25: When receiving a call, check listening sockets for matching call user data.
Date: Sun, 21 Nov 2004 22:43:47 -0800
Message-ID: <200411220643.iAM6hx900606@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, ahendry@tusc.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Andrew Hendry <ahendry@tusc.com.au>

If a listening socket sets call user data, ensure it only receives calls
with matching call user data.  Also ensure incoming calls with matching
call user data dont go to another listening socket.

Signed-off-by: Andrew Hendry <ahendry@tusc.com.au>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/include/net/x25.h  |    1 
 25-akpm/net/x25/af_x25.c   |   62 ++++++++++++++++++++++++++++++++++-----------
 25-akpm/net/x25/x25_subr.c |   19 +++++++++++++
 3 files changed, 67 insertions(+), 15 deletions(-)

diff -puN include/net/x25.h~x25-when-receiving-a-call-check-listening-sockets-for-matching-call-user-data include/net/x25.h
--- 25/include/net/x25.h~x25-when-receiving-a-call-check-listening-sockets-for-matching-call-user-data	2004-11-21 22:42:30.462051304 -0800
+++ 25-akpm/include/net/x25.h	2004-11-21 22:42:30.468050392 -0800
@@ -243,6 +243,7 @@ extern int  x25_validate_nr(struct sock 
 extern void x25_write_internal(struct sock *, int);
 extern int  x25_decode(struct sock *, struct sk_buff *, int *, int *, int *, int *, int *);
 extern void x25_disconnect(struct sock *, int, unsigned char, unsigned char);
+extern int x25_check_calluserdata(struct x25_calluserdata *,struct x25_calluserdata *);
 
 /* x25_timer.c */
 extern void x25_start_heartbeat(struct sock *);
diff -puN net/x25/af_x25.c~x25-when-receiving-a-call-check-listening-sockets-for-matching-call-user-data net/x25/af_x25.c
--- 25/net/x25/af_x25.c~x25-when-receiving-a-call-check-listening-sockets-for-matching-call-user-data	2004-11-21 22:42:30.463051152 -0800
+++ 25-akpm/net/x25/af_x25.c	2004-11-21 22:43:04.031947904 -0800
@@ -223,14 +223,19 @@ static void x25_insert_socket(struct soc
 
 /*
  *	Find a socket that wants to accept the Call Request we just
- *	received.
+ *	received. Check the full list for an address/cud match.
+ *	If no cuds match return the next_best thing, an address match.
+ *	Note: if a listening socket has cud set it must only get calls
+ *	with matching cud.
  */
-static struct sock *x25_find_listener(struct x25_address *addr)
+static struct sock *x25_find_listener(struct x25_address *addr, struct x25_calluserdata *calluserdata)
 {
 	struct sock *s;
+	struct sock *next_best;
 	struct hlist_node *node;
 
 	read_lock_bh(&x25_list_lock);
+	next_best = NULL;
 
 	sk_for_each(s, node, &x25_list)
 		if ((!strcmp(addr->x25_addr,
@@ -238,9 +243,24 @@ static struct sock *x25_find_listener(st
 		     !strcmp(addr->x25_addr,
 			     null_x25_address.x25_addr)) &&
 		     s->sk_state == TCP_LISTEN) {
-			sock_hold(s);
-			goto found;
+
+			/*
+			 * Found a listening socket, now check the incoming
+			 * call user data vs this sockets call user data
+			 */
+			if (x25_check_calluserdata(&x25_sk(s)->calluserdata, calluserdata)) {
+				sock_hold(s);
+				goto found;
+			}
+			if (x25_sk(s)->calluserdata.cudlength == 0) {
+				next_best = s;
+			}
 		}
+	if (next_best) {
+		s = next_best;
+		sock_hold(s);
+		goto found;
+	}
 	s = NULL;
 found:
 	read_unlock_bh(&x25_list_lock);
@@ -814,6 +834,7 @@ int x25_rx_call_request(struct sk_buff *
 	struct x25_opt *makex25;
 	struct x25_address source_addr, dest_addr;
 	struct x25_facilities facilities;
+	struct x25_calluserdata calluserdata;
 	int len, rc;
 
 	/*
@@ -828,9 +849,27 @@ int x25_rx_call_request(struct sk_buff *
 	skb_pull(skb, x25_addr_ntoa(skb->data, &source_addr, &dest_addr));
 
 	/*
-	 *	Find a listener for the particular address.
+	 *	Get the length of the facilities, skip past them for the moment
+	 *	get the call user data because this is needed to determine
+	 *	the correct listener
+	 */
+	len = skb->data[0] + 1;
+	skb_pull(skb,len);
+
+	/*
+	 *	Incoming Call User Data.
+	 */
+	if (skb->len >= 0) {
+		memcpy(calluserdata.cuddata, skb->data, skb->len);
+		calluserdata.cudlength = skb->len;
+	}
+
+	skb_push(skb,len);
+
+	/*
+	 *	Find a listener for the particular address/cud pair.
 	 */
-	sk = x25_find_listener(&source_addr);
+	sk = x25_find_listener(&source_addr,&calluserdata);
 
 	/*
 	 *	We can't accept the Call Request.
@@ -859,7 +898,7 @@ int x25_rx_call_request(struct sk_buff *
 		goto out_sock_put;
 
 	/*
-	 *	Remove the facilities, leaving any Call User Data.
+	 *	Remove the facilities
 	 */
 	skb_pull(skb, len);
 
@@ -873,17 +912,10 @@ int x25_rx_call_request(struct sk_buff *
 	makex25->neighbour     = nb;
 	makex25->facilities    = facilities;
 	makex25->vc_facil_mask = x25_sk(sk)->vc_facil_mask;
+	makex25->calluserdata  = calluserdata;
 
 	x25_write_internal(make, X25_CALL_ACCEPTED);
 
-	/*
-	 *	Incoming Call User Data.
-	 */
-	if (skb->len >= 0) {
-		memcpy(makex25->calluserdata.cuddata, skb->data, skb->len);
-		makex25->calluserdata.cudlength = skb->len;
-	}
-
 	makex25->state = X25_STATE_3;
 
 	sk->sk_ack_backlog++;
diff -puN net/x25/x25_subr.c~x25-when-receiving-a-call-check-listening-sockets-for-matching-call-user-data net/x25/x25_subr.c
--- 25/net/x25/x25_subr.c~x25-when-receiving-a-call-check-listening-sockets-for-matching-call-user-data	2004-11-21 22:42:30.465050848 -0800
+++ 25-akpm/net/x25/x25_subr.c	2004-11-21 22:43:04.035947296 -0800
@@ -367,3 +367,22 @@ void x25_check_rbuf(struct sock *sk)
 		x25_stop_timer(sk);
 	}
 }
+
+/*
+ * Compare 2 calluserdata structures, used to find correct listening sockets
+ * when call user data is used.
+ */
+int x25_check_calluserdata(struct x25_calluserdata *ours, struct x25_calluserdata *theirs)
+{
+	int i;
+	if (ours->cudlength != theirs->cudlength)
+		return 0;
+
+	for (i=0;i<ours->cudlength;i++) {
+		if (ours->cuddata[i] != theirs->cuddata[i]) {
+			return 0;
+		}
+	}
+	return 1;
+}
+
_
