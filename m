From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH 4/12][AF_PACKET] stop using sk_protinfo
Date: Fri, 21 Jan 2005 01:19:07 -0200
Message-ID: <41F074AB.2080103@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040005070908010906030206"
Cc: Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040005070908010906030206
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David,

	Subject says it all.

Regards,

- Arnaldo


--------------040005070908010906030206
Content-Type: text/plain;
 name="4-af_packet.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="4-af_packet.patch"

===================================================================


ChangeSet@1.2002, 2005-01-20 20:41:35-02:00, acme@toy.ghostprotocols.net
  [AF_PACKET] stop using sk_protinfo
  
  Required to introduce struct connection_sock.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 af_packet.c |   55 ++++++++++++++++++++++++++-----------------------------
 1 files changed, 26 insertions(+), 29 deletions(-)


diff -Nru a/net/packet/af_packet.c b/net/packet/af_packet.c
--- a/net/packet/af_packet.c	2005-01-21 00:23:28 -02:00
+++ b/net/packet/af_packet.c	2005-01-21 00:23:28 -02:00
@@ -170,8 +170,9 @@
 
 static void packet_flush_mclist(struct sock *sk);
 
-struct packet_opt
-{
+struct packet_sock {
+	/* struct sock has to be the first member of packet_sock */
+	struct sock		sk;
 	struct tpacket_stats	stats;
 #ifdef CONFIG_PACKET_MMAP
 	char *			*pg_vec;
@@ -199,7 +200,7 @@
 
 #ifdef CONFIG_PACKET_MMAP
 
-static inline char *packet_lookup_frame(struct packet_opt *po, unsigned int position)
+static inline char *packet_lookup_frame(struct packet_sock *po, unsigned int position)
 {
 	unsigned int pg_vec_pos, frame_offset;
 	char *frame;
@@ -213,7 +214,10 @@
 }
 #endif
 
-#define pkt_sk(__sk) ((struct packet_opt *)(__sk)->sk_protinfo)
+static inline struct packet_sock *pkt_sk(struct sock *sk)
+{
+	return (struct packet_sock *)sk;
+}
 
 static void packet_sock_destruct(struct sock *sk)
 {
@@ -225,8 +229,6 @@
 		return;
 	}
 
-	if (pkt_sk(sk))
-		kfree(pkt_sk(sk));
 	atomic_dec(&packet_socks_nr);
 #ifdef PACKET_REFCNT_DEBUG
 	printk(KERN_DEBUG "PACKET socket %p is free, %d are alive\n", sk, atomic_read(&packet_socks_nr));
@@ -440,7 +442,7 @@
 {
 	struct sock *sk;
 	struct sockaddr_ll *sll;
-	struct packet_opt *po;
+	struct packet_sock *po;
 	u8 * skb_head = skb->data;
 	int skb_len = skb->len;
 	unsigned snaplen;
@@ -541,7 +543,7 @@
 static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,  struct packet_type *pt)
 {
 	struct sock *sk;
-	struct packet_opt *po;
+	struct packet_sock *po;
 	struct sockaddr_ll *sll;
 	struct tpacket_hdr *h;
 	u8 * skb_head = skb->data;
@@ -699,7 +701,7 @@
 	 */
 	 
 	if (saddr == NULL) {
-		struct packet_opt *po = pkt_sk(sk);
+		struct packet_sock *po = pkt_sk(sk);
 
 		ifindex	= po->ifindex;
 		proto	= po->num;
@@ -786,7 +788,7 @@
 static int packet_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	struct packet_opt *po;
+	struct packet_sock *po;
 
 	if (!sk)
 		return 0;
@@ -844,7 +846,7 @@
 
 static int packet_do_bind(struct sock *sk, struct net_device *dev, int protocol)
 {
-	struct packet_opt *po = pkt_sk(sk);
+	struct packet_sock *po = pkt_sk(sk);
 	/*
 	 *	Detach an existing hook if present.
 	 */
@@ -961,7 +963,7 @@
 static int packet_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
-	struct packet_opt *po;
+	struct packet_sock *po;
 	int err;
 
 	if (!capable(CAP_NET_RAW))
@@ -976,7 +978,8 @@
 	sock->state = SS_UNCONNECTED;
 
 	err = -ENOBUFS;
-	sk = sk_alloc(PF_PACKET, GFP_KERNEL, 1, NULL);
+	sk = sk_alloc(PF_PACKET, GFP_KERNEL,
+		      sizeof(struct packet_sock), NULL);
 	if (sk == NULL)
 		goto out;
 
@@ -988,10 +991,7 @@
 	sock_init_data(sock,sk);
 	sk_set_owner(sk, THIS_MODULE);
 
-	po = sk->sk_protinfo = kmalloc(sizeof(*po), GFP_KERNEL);
-	if (!po)
-		goto out_free;
-	memset(po, 0, sizeof(*po));
+	po = pkt_sk(sk);
 	sk->sk_family = PF_PACKET;
 	po->num = protocol;
 
@@ -1021,9 +1021,6 @@
 	sk_add_node(sk, &packet_sklist);
 	write_unlock_bh(&packet_sklist_lock);
 	return(0);
-
-out_free:
-	sk_free(sk);
 out:
 	return err;
 }
@@ -1141,7 +1138,7 @@
 {
 	struct net_device *dev;
 	struct sock *sk = sock->sk;
-	struct packet_opt *po = pkt_sk(sk);
+	struct packet_sock *po = pkt_sk(sk);
 	struct sockaddr_ll *sll = (struct sockaddr_ll*)uaddr;
 
 	if (peer)
@@ -1195,7 +1192,7 @@
 
 static int packet_mc_add(struct sock *sk, struct packet_mreq *mreq)
 {
-	struct packet_opt *po = pkt_sk(sk);
+	struct packet_sock *po = pkt_sk(sk);
 	struct packet_mclist *ml, *i;
 	struct net_device *dev;
 	int err;
@@ -1274,7 +1271,7 @@
 
 static void packet_flush_mclist(struct sock *sk)
 {
-	struct packet_opt *po = pkt_sk(sk);
+	struct packet_sock *po = pkt_sk(sk);
 	struct packet_mclist *ml;
 
 	if (!po->mclist)
@@ -1355,7 +1352,7 @@
 {
 	int len;
 	struct sock *sk = sock->sk;
-	struct packet_opt *po = pkt_sk(sk);
+	struct packet_sock *po = pkt_sk(sk);
 
 	if (level != SOL_PACKET)
 		return -ENOPROTOOPT;
@@ -1401,7 +1398,7 @@
 
 	read_lock(&packet_sklist_lock);
 	sk_for_each(sk, node, &packet_sklist) {
-		struct packet_opt *po = pkt_sk(sk);
+		struct packet_sock *po = pkt_sk(sk);
 
 		switch (msg) {
 		case NETDEV_UNREGISTER:
@@ -1504,7 +1501,7 @@
 				poll_table *wait)
 {
 	struct sock *sk = sock->sk;
-	struct packet_opt *po = pkt_sk(sk);
+	struct packet_sock *po = pkt_sk(sk);
 	unsigned int mask = datagram_poll(file, sock, wait);
 
 	spin_lock_bh(&sk->sk_receive_queue.lock);
@@ -1579,7 +1576,7 @@
 static int packet_set_ring(struct sock *sk, struct tpacket_req *req, int closing)
 {
 	char **pg_vec = NULL;
-	struct packet_opt *po = pkt_sk(sk);
+	struct packet_sock *po = pkt_sk(sk);
 	int was_running, num, order = 0;
 	int err = 0;
 	
@@ -1709,7 +1706,7 @@
 static int packet_mmap(struct file *file, struct socket *sock, struct vm_area_struct *vma)
 {
 	struct sock *sk = sock->sk;
-	struct packet_opt *po = pkt_sk(sk);
+	struct packet_sock *po = pkt_sk(sk);
 	unsigned long size;
 	unsigned long start;
 	int err = -EINVAL;
@@ -1839,7 +1836,7 @@
 		seq_puts(seq, "sk       RefCnt Type Proto  Iface R Rmem   User   Inode\n");
 	else {
 		struct sock *s = v;
-		const struct packet_opt *po = pkt_sk(s);
+		const struct packet_sock *po = pkt_sk(s);
 
 		seq_printf(seq,
 			   "%p %-6d %-4d %04x   %-5d %1d %-6u %-6u %-6lu\n",



--------------040005070908010906030206--
