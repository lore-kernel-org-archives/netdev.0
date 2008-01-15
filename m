From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [ROSE]: Supress sparse warnings
Date: Tue, 15 Jan 2008 12:23:20 +0100
Message-ID: <20080115122320.1fadbbe7.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:58471 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751074AbYAOLXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 06:23:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  CHECK   net/rose/af_rose.c
net/rose/af_rose.c:125:11: warning: expensive signed divide
net/rose/af_rose.c:976:46: warning: expensive signed divide
net/rose/af_rose.c:1379:13: warning: context imbalance in 'rose_info_start' - wrong count at exit
net/rose/af_rose.c:1406:13: warning: context imbalance in 'rose_info_stop' - unexpected unlock
  CHECK   net/rose/rose_in.c
net/rose/rose_in.c:185:25: warning: expensive signed divide
  CHECK   net/rose/rose_route.c
net/rose/rose_route.c:997:46: warning: expensive signed divide
net/rose/rose_route.c:1070:13: warning: context imbalance in 'rose_node_start' - wrong count at exit
net/rose/rose_route.c:1093:13: warning: context imbalance in 'rose_node_stop' - unexpected unlock
net/rose/rose_route.c:1146:13: warning: context imbalance in 'rose_neigh_start' - wrong count at exit
net/rose/rose_route.c:1169:13: warning: context imbalance in 'rose_neigh_stop' - unexpected unlock
net/rose/rose_route.c:1229:13: warning: context imbalance in 'rose_route_start' - wrong count at exit
net/rose/rose_route.c:1252:13: warning: context imbalance in 'rose_route_stop' - unexpected unlock

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

 net/rose/af_rose.c    |    8 +++++---
 net/rose/rose_in.c    |    2 +-
 net/rose/rose_route.c |   10 ++++++++--
 3 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 323d42a..4a31a81 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -116,7 +116,7 @@ int rosecmp(rose_address *addr1, rose_address *addr2)
  */
 int rosecmpm(rose_address *addr1, rose_address *addr2, unsigned short mask)
 {
-	int i, j;
+	unsigned int i, j;
 
 	if (mask > 10)
 		return 1;
@@ -973,8 +973,8 @@ int rose_rx_call_request(struct sk_buff *skb, struct net_device *dev, struct ros
 	 */
 	memset(&facilities, 0x00, sizeof(struct rose_facilities_struct));
 
-	len  = (((skb->data[3] >> 4) & 0x0F) + 1) / 2;
-	len += (((skb->data[3] >> 0) & 0x0F) + 1) / 2;
+	len  = (((skb->data[3] >> 4) & 0x0F) + 1) >> 1;
+	len += (((skb->data[3] >> 0) & 0x0F) + 1) >> 1;
 	if (!rose_parse_facilities(skb->data + len + 4, &facilities)) {
 		rose_transmit_clear_request(neigh, lci, ROSE_INVALID_FACILITY, 76);
 		return 0;
@@ -1377,6 +1377,7 @@ static int rose_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 
 #ifdef CONFIG_PROC_FS
 static void *rose_info_start(struct seq_file *seq, loff_t *pos)
+	__acquires(rose_list_lock)
 {
 	int i;
 	struct sock *s;
@@ -1404,6 +1405,7 @@ static void *rose_info_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void rose_info_stop(struct seq_file *seq, void *v)
+	__releases(rose_list_lock)
 {
 	spin_unlock_bh(&rose_list_lock);
 }
diff --git a/net/rose/rose_in.c b/net/rose/rose_in.c
index 4ee0879..7f7fcb4 100644
--- a/net/rose/rose_in.c
+++ b/net/rose/rose_in.c
@@ -182,7 +182,7 @@ static int rose_state3_machine(struct sock *sk, struct sk_buff *skb, int framety
 				break;
 			}
 			if (atomic_read(&sk->sk_rmem_alloc) >
-			    (sk->sk_rcvbuf / 2))
+			    (sk->sk_rcvbuf >> 1))
 				rose->condition |= ROSE_COND_OWN_RX_BUSY;
 		}
 		/*
diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index 540c0f2..fb9359f 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -994,8 +994,8 @@ int rose_route_frame(struct sk_buff *skb, ax25_cb *ax25)
 		goto out;
 	}
 
-	len  = (((skb->data[3] >> 4) & 0x0F) + 1) / 2;
-	len += (((skb->data[3] >> 0) & 0x0F) + 1) / 2;
+	len  = (((skb->data[3] >> 4) & 0x0F) + 1) >> 1;
+	len += (((skb->data[3] >> 0) & 0x0F) + 1) >> 1;
 
 	memset(&facilities, 0x00, sizeof(struct rose_facilities_struct));
 
@@ -1068,6 +1068,7 @@ out:
 #ifdef CONFIG_PROC_FS
 
 static void *rose_node_start(struct seq_file *seq, loff_t *pos)
+	__acquires(rose_neigh_list_lock)
 {
 	struct rose_node *rose_node;
 	int i = 1;
@@ -1091,6 +1092,7 @@ static void *rose_node_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void rose_node_stop(struct seq_file *seq, void *v)
+	__releases(rose_neigh_list_lock)
 {
 	spin_unlock_bh(&rose_neigh_list_lock);
 }
@@ -1144,6 +1146,7 @@ const struct file_operations rose_nodes_fops = {
 };
 
 static void *rose_neigh_start(struct seq_file *seq, loff_t *pos)
+	__acquires(rose_neigh_list_lock)
 {
 	struct rose_neigh *rose_neigh;
 	int i = 1;
@@ -1167,6 +1170,7 @@ static void *rose_neigh_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void rose_neigh_stop(struct seq_file *seq, void *v)
+	__releases(rose_neigh_list_lock)
 {
 	spin_unlock_bh(&rose_neigh_list_lock);
 }
@@ -1227,6 +1231,7 @@ const struct file_operations rose_neigh_fops = {
 
 
 static void *rose_route_start(struct seq_file *seq, loff_t *pos)
+	__acquires(rose_route_list_lock)
 {
 	struct rose_route *rose_route;
 	int i = 1;
@@ -1250,6 +1255,7 @@ static void *rose_route_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void rose_route_stop(struct seq_file *seq, void *v)
+	__releases(rose_route_list_lock)
 {
 	spin_unlock_bh(&rose_route_list_lock);
 }
