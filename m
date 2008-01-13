From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [X25]: Avoid divides and sparse warnings
Date: Sun, 13 Jan 2008 11:33:01 +0100
Message-ID: <4789E8DD.2020901@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080909060501010102040304"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:42395 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259AbYAMKdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 05:33:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080909060501010102040304
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

   CHECK   net/x25/af_x25.c
net/x25/af_x25.c:117:46: warning: expensive signed divide
   CHECK   net/x25/x25_facilities.c
net/x25/x25_facilities.c:209:30: warning: expensive signed divide
   CHECK   net/x25/x25_in.c
net/x25/x25_in.c:250:26: warning: expensive signed divide
   CHECK   net/x25/x25_proc.c
net/x25/x25_proc.c:48:11: warning: context imbalance in 'x25_seq_route_start' 
- wrong count at exit
net/x25/x25_proc.c:72:13: warning: context imbalance in 'x25_seq_route_stop' - 
unexpected unlock
net/x25/x25_proc.c:112:11: warning: context imbalance in 
'x25_seq_socket_start' - wrong count at exit
net/x25/x25_proc.c:129:13: warning: context imbalance in 'x25_seq_socket_stop' 
- unexpected unlock
net/x25/x25_proc.c:190:11: warning: context imbalance in 
'x25_seq_forward_start' - wrong count at exit
net/x25/x25_proc.c:215:13: warning: context imbalance in 
'x25_seq_forward_stop' - unexpected unlock
   CHECK   net/x25/x25_subr.c
net/x25/x25_subr.c:362:57: warning: expensive signed divide

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

  net/x25/af_x25.c         |    4 ++--
  net/x25/x25_facilities.c |    4 +---
  net/x25/x25_in.c         |    2 +-
  net/x25/x25_proc.c       |    6 ++++++
  net/x25/x25_subr.c       |    2 +-
  5 files changed, 11 insertions(+), 7 deletions(-)


--------------080909060501010102040304
Content-Type: text/plain;
 name="x25.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x25.patch"

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 92cfe8e..07fad7c 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -83,9 +83,9 @@ struct compat_x25_subscrip_struct {
 int x25_addr_ntoa(unsigned char *p, struct x25_address *called_addr,
 		  struct x25_address *calling_addr)
 {
-	int called_len, calling_len;
+	unsigned int called_len, calling_len;
 	char *called, *calling;
-	int i;
+	unsigned int i;
 
 	called_len  = (*p >> 0) & 0x0F;
 	calling_len = (*p >> 4) & 0x0F;
diff --git a/net/x25/x25_facilities.c b/net/x25/x25_facilities.c
index dec404a..a21f664 100644
--- a/net/x25/x25_facilities.c
+++ b/net/x25/x25_facilities.c
@@ -205,9 +205,7 @@ int x25_create_facilities(unsigned char *buffer,
 	}
 
 	if (dte_facs->calling_len && (facil_mask & X25_MASK_CALLING_AE)) {
-		unsigned bytecount = (dte_facs->calling_len % 2) ?
-					dte_facs->calling_len / 2 + 1 :
-					dte_facs->calling_len / 2;
+		unsigned bytecount = (dte_facs->calling_len + 1) >> 1;
 		*p++ = X25_FAC_CALLING_AE;
 		*p++ = 1 + bytecount;
 		*p++ = dte_facs->calling_len;
diff --git a/net/x25/x25_in.c b/net/x25/x25_in.c
index 1c88762..7d7c3ab 100644
--- a/net/x25/x25_in.c
+++ b/net/x25/x25_in.c
@@ -247,7 +247,7 @@ static int x25_state3_machine(struct sock *sk, struct sk_buff *skb, int frametyp
 					break;
 				}
 				if (atomic_read(&sk->sk_rmem_alloc) >
-				    (sk->sk_rcvbuf / 2))
+				    (sk->sk_rcvbuf >> 1))
 					x25->condition |= X25_COND_OWN_RX_BUSY;
 			}
 			/*
diff --git a/net/x25/x25_proc.c b/net/x25/x25_proc.c
index 7d55e50..78b0534 100644
--- a/net/x25/x25_proc.c
+++ b/net/x25/x25_proc.c
@@ -41,6 +41,7 @@ found:
 }
 
 static void *x25_seq_route_start(struct seq_file *seq, loff_t *pos)
+	__acquires(x25_route_list_lock)
 {
 	loff_t l = *pos;
 
@@ -70,6 +71,7 @@ out:
 }
 
 static void x25_seq_route_stop(struct seq_file *seq, void *v)
+	__releases(x25_route_list_lock)
 {
 	read_unlock_bh(&x25_route_list_lock);
 }
@@ -105,6 +107,7 @@ found:
 }
 
 static void *x25_seq_socket_start(struct seq_file *seq, loff_t *pos)
+	__acquires(x25_list_lock)
 {
 	loff_t l = *pos;
 
@@ -127,6 +130,7 @@ out:
 }
 
 static void x25_seq_socket_stop(struct seq_file *seq, void *v)
+	__releases(x25_list_lock)
 {
 	read_unlock_bh(&x25_list_lock);
 }
@@ -183,6 +187,7 @@ found:
 }
 
 static void *x25_seq_forward_start(struct seq_file *seq, loff_t *pos)
+	__acquires(x25_forward_list_lock)
 {
 	loff_t l = *pos;
 
@@ -213,6 +218,7 @@ out:
 }
 
 static void x25_seq_forward_stop(struct seq_file *seq, void *v)
+	__releases(x25_forward_list_lock)
 {
 	read_unlock_bh(&x25_forward_list_lock);
 }
diff --git a/net/x25/x25_subr.c b/net/x25/x25_subr.c
index 8d6220a..511a598 100644
--- a/net/x25/x25_subr.c
+++ b/net/x25/x25_subr.c
@@ -359,7 +359,7 @@ void x25_check_rbuf(struct sock *sk)
 {
 	struct x25_sock *x25 = x25_sk(sk);
 
-	if (atomic_read(&sk->sk_rmem_alloc) < (sk->sk_rcvbuf / 2) &&
+	if (atomic_read(&sk->sk_rmem_alloc) < (sk->sk_rcvbuf >> 1) &&
 	    (x25->condition & X25_COND_OWN_RX_BUSY)) {
 		x25->condition &= ~X25_COND_OWN_RX_BUSY;
 		x25->condition &= ~X25_COND_ACK_PENDING;

--------------080909060501010102040304--
