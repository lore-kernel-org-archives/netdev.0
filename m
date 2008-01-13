From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [AX25]: sparse cleanups
Date: Sun, 13 Jan 2008 12:01:28 +0100
Message-ID: <4789EF88.9090303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020005060400020606030105"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:34693 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200AbYAMLBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 06:01:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020005060400020606030105
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

net/ax25/ax25_route.c:251:13: warning: context imbalance in 
'ax25_rt_seq_start' - wrong count at exit
net/ax25/ax25_route.c:276:13: warning: context imbalance in 'ax25_rt_seq_stop' 
- unexpected unlock
net/ax25/ax25_std_timer.c:65:25: warning: expensive signed divide
net/ax25/ax25_uid.c:46:1: warning: symbol 'ax25_uid_list' was not declared. 
Should it be static?
net/ax25/ax25_uid.c:146:13: warning: context imbalance in 'ax25_uid_seq_start' 
- wrong count at exit
net/ax25/ax25_uid.c:169:13: warning: context imbalance in 'ax25_uid_seq_stop' 
- unexpected unlock
net/ax25/af_ax25.c:573:28: warning: expensive signed divide
net/ax25/af_ax25.c:1865:13: warning: context imbalance in 'ax25_info_start' - 
wrong count at exit
net/ax25/af_ax25.c:1888:13: warning: context imbalance in 'ax25_info_stop' - 
unexpected unlock
net/ax25/ax25_ds_timer.c:133:25: warning: expensive signed divide

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

  net/ax25/af_ax25.c        |    4 +++-
  net/ax25/ax25_ds_timer.c  |    2 +-
  net/ax25/ax25_route.c     |    2 ++
  net/ax25/ax25_std_timer.c |    4 ++--
  net/ax25/ax25_uid.c       |    6 ++++--
  5 files changed, 12 insertions(+), 6 deletions(-)


--------------020005060400020606030105
Content-Type: text/plain;
 name="ax25.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ax25.patch"

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index a028d37..1bc0e85 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -570,7 +570,7 @@ static int ax25_setsockopt(struct socket *sock, int level, int optname,
 			res = -EINVAL;
 			break;
 		}
-		ax25->rtt = (opt * HZ) / 2;
+		ax25->rtt = (opt * HZ) >> 1;
 		ax25->t1  = opt * HZ;
 		break;
 
@@ -1863,6 +1863,7 @@ static int ax25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 #ifdef CONFIG_PROC_FS
 
 static void *ax25_info_start(struct seq_file *seq, loff_t *pos)
+	__acquires(ax25_list_lock)
 {
 	struct ax25_cb *ax25;
 	struct hlist_node *node;
@@ -1886,6 +1887,7 @@ static void *ax25_info_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void ax25_info_stop(struct seq_file *seq, void *v)
+	__releases(ax25_list_lock)
 {
 	spin_unlock_bh(&ax25_list_lock);
 }
diff --git a/net/ax25/ax25_ds_timer.c b/net/ax25/ax25_ds_timer.c
index 4f44185..c4e3b02 100644
--- a/net/ax25/ax25_ds_timer.c
+++ b/net/ax25/ax25_ds_timer.c
@@ -130,7 +130,7 @@ void ax25_ds_heartbeat_expiry(ax25_cb *ax25)
 		 */
 		if (sk != NULL) {
 			if (atomic_read(&sk->sk_rmem_alloc) <
-			    (sk->sk_rcvbuf / 2) &&
+			    (sk->sk_rcvbuf >> 1) &&
 			    (ax25->condition & AX25_COND_OWN_RX_BUSY)) {
 				ax25->condition &= ~AX25_COND_OWN_RX_BUSY;
 				ax25->condition &= ~AX25_COND_ACK_PENDING;
diff --git a/net/ax25/ax25_route.c b/net/ax25/ax25_route.c
index 9ecf6f1..38c7f30 100644
--- a/net/ax25/ax25_route.c
+++ b/net/ax25/ax25_route.c
@@ -249,6 +249,7 @@ int ax25_rt_ioctl(unsigned int cmd, void __user *arg)
 #ifdef CONFIG_PROC_FS
 
 static void *ax25_rt_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(ax25_route_lock)
 {
 	struct ax25_route *ax25_rt;
 	int i = 1;
@@ -274,6 +275,7 @@ static void *ax25_rt_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void ax25_rt_seq_stop(struct seq_file *seq, void *v)
+	__releases(ax25_route_lock)
 {
 	read_unlock(&ax25_route_lock);
 }
diff --git a/net/ax25/ax25_std_timer.c b/net/ax25/ax25_std_timer.c
index f2f6918..96e4b92 100644
--- a/net/ax25/ax25_std_timer.c
+++ b/net/ax25/ax25_std_timer.c
@@ -32,7 +32,7 @@
 
 void ax25_std_heartbeat_expiry(ax25_cb *ax25)
 {
-	struct sock *sk=ax25->sk;
+	struct sock *sk = ax25->sk;
 
 	if (sk)
 		bh_lock_sock(sk);
@@ -62,7 +62,7 @@ void ax25_std_heartbeat_expiry(ax25_cb *ax25)
 		 */
 		if (sk != NULL) {
 			if (atomic_read(&sk->sk_rmem_alloc) <
-			    (sk->sk_rcvbuf / 2) &&
+			    (sk->sk_rcvbuf >> 1) &&
 			    (ax25->condition & AX25_COND_OWN_RX_BUSY)) {
 				ax25->condition &= ~AX25_COND_OWN_RX_BUSY;
 				ax25->condition &= ~AX25_COND_ACK_PENDING;
diff --git a/net/ax25/ax25_uid.c b/net/ax25/ax25_uid.c
index ce0b13d..5f4eb73 100644
--- a/net/ax25/ax25_uid.c
+++ b/net/ax25/ax25_uid.c
@@ -43,10 +43,10 @@
  *	Callsign/UID mapper. This is in kernel space for security on multi-amateur machines.
  */
 
-HLIST_HEAD(ax25_uid_list);
+static HLIST_HEAD(ax25_uid_list);
 static DEFINE_RWLOCK(ax25_uid_lock);
 
-int ax25_uid_policy = 0;
+int ax25_uid_policy;
 
 EXPORT_SYMBOL(ax25_uid_policy);
 
@@ -144,6 +144,7 @@ int ax25_uid_ioctl(int cmd, struct sockaddr_ax25 *sax)
 #ifdef CONFIG_PROC_FS
 
 static void *ax25_uid_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(ax25_uid_lock)
 {
 	struct ax25_uid_assoc *pt;
 	struct hlist_node *node;
@@ -167,6 +168,7 @@ static void *ax25_uid_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void ax25_uid_seq_stop(struct seq_file *seq, void *v)
+	__releases(ax25_uid_lock)
 {
 	read_unlock(&ax25_uid_lock);
 }

--------------020005060400020606030105--
