From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] merge udp_opt with udp_sock
Date: Tue, 11 Jan 2005 04:51:17 -0200
Message-ID: <41E37765.4030105@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000602060905070006080609"
Cc: Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000602060905070006080609
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/connection_sock-2.6

Regards,

- Arnaldo

--------------000602060905070006080609
Content-Type: text/plain;
 name="udp.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="udp.patch"

===================================================================


ChangeSet@1.2279, 2005-01-11 02:47:15-02:00, acme@conectiva.com.br
  [UDP] merge udp_sock with udp_opt
  
  No need for two structs, follow the new inet_sock layout
  style.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 include/linux/ipv6.h |    3 +--
 include/linux/udp.h  |   22 +++++++++-------------
 net/ipv4/udp.c       |   16 ++++++++--------
 net/ipv6/udp.c       |   10 +++++-----
 4 files changed, 23 insertions(+), 28 deletions(-)


diff -Nru a/include/linux/ipv6.h b/include/linux/ipv6.h
--- a/include/linux/ipv6.h	2005-01-11 04:45:45 -02:00
+++ b/include/linux/ipv6.h	2005-01-11 04:45:45 -02:00
@@ -262,8 +262,7 @@
 };
 
 struct udp6_sock {
-	struct inet_sock  inet;
-	struct udp_opt	  udp;
+	struct udp_sock	  udp;
 	struct ipv6_pinfo inet6;
 };
 
diff -Nru a/include/linux/udp.h b/include/linux/udp.h
--- a/include/linux/udp.h	2005-01-11 04:45:45 -02:00
+++ b/include/linux/udp.h	2005-01-11 04:45:45 -02:00
@@ -40,26 +40,22 @@
 #include <net/sock.h>
 #include <linux/ip.h>
 
-struct udp_opt {
-	int		pending;	/* Any pending frames ? */
-	unsigned int	corkflag;	/* Cork is required */
-  	__u16		encap_type;	/* Is this an Encapsulation socket? */
+struct udp_sock {
+	/* inet_sock has to be the first member */
+	struct inet_sock inet;
+	int		 pending;	/* Any pending frames ? */
+	unsigned int	 corkflag;	/* Cork is required */
+  	__u16		 encap_type;	/* Is this an Encapsulation socket? */
 	/*
 	 * Following member retains the infomation to create a UDP header
 	 * when the socket is uncorked.
 	 */
-	__u16		len;		/* total length of pending frames */
-};
-
-/* WARNING: don't change the layout of the members in udp_sock! */
-struct udp_sock {
-	struct inet_sock  inet;
-	struct udp_opt	  udp;
+	__u16		 len;		/* total length of pending frames */
 };
 
-static inline struct udp_opt * udp_sk(const struct sock *__sk)
+static inline struct udp_sock *udp_sk(const struct sock *sk)
 {
-	return &((struct udp_sock *)__sk)->udp;
+	return (struct udp_sock *)sk;
 }
 
 #endif
diff -Nru a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c	2005-01-11 04:45:45 -02:00
+++ b/net/ipv4/udp.c	2005-01-11 04:45:45 -02:00
@@ -386,7 +386,7 @@
  */
 static void udp_flush_pending_frames(struct sock *sk)
 {
-	struct udp_opt *up = udp_sk(sk);
+	struct udp_sock *up = udp_sk(sk);
 
 	if (up->pending) {
 		up->len = 0;
@@ -398,7 +398,7 @@
 /*
  * Push out all pending data as one UDP datagram. Socket is locked.
  */
-static int udp_push_pending_frames(struct sock *sk, struct udp_opt *up)
+static int udp_push_pending_frames(struct sock *sk, struct udp_sock *up)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct flowi *fl = &inet->cork.fl;
@@ -483,7 +483,7 @@
 		size_t len)
 {
 	struct inet_sock *inet = inet_sk(sk);
-	struct udp_opt *up = udp_sk(sk);
+	struct udp_sock *up = udp_sk(sk);
 	int ulen = len;
 	struct ipcm_cookie ipc;
 	struct rtable *rt = NULL;
@@ -672,7 +672,7 @@
 static int udp_sendpage(struct sock *sk, struct page *page, int offset,
 			size_t size, int flags)
 {
-	struct udp_opt *up = udp_sk(sk);
+	struct udp_sock *up = udp_sk(sk);
 	int ret;
 
 	if (!up->pending) {
@@ -902,7 +902,7 @@
 #ifndef CONFIG_XFRM
 	return 1; 
 #else
-	struct udp_opt *up = udp_sk(sk);
+	struct udp_sock *up = udp_sk(sk);
   	struct udphdr *uh = skb->h.uh;
 	struct iphdr *iph;
 	int iphlen, len;
@@ -988,7 +988,7 @@
  */
 static int udp_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 {
-	struct udp_opt *up = udp_sk(sk);
+	struct udp_sock *up = udp_sk(sk);
 
 	/*
 	 *	Charge it to the socket, dropping if the queue is full.
@@ -1223,7 +1223,7 @@
 static int udp_setsockopt(struct sock *sk, int level, int optname, 
 			  char __user *optval, int optlen)
 {
-	struct udp_opt *up = udp_sk(sk);
+	struct udp_sock *up = udp_sk(sk);
 	int val;
 	int err = 0;
 
@@ -1272,7 +1272,7 @@
 static int udp_getsockopt(struct sock *sk, int level, int optname, 
 			  char __user *optval, int __user *optlen)
 {
-	struct udp_opt *up = udp_sk(sk);
+	struct udp_sock *up = udp_sk(sk);
 	int val, len;
 
 	if (level != SOL_UDP)
diff -Nru a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c	2005-01-11 04:45:45 -02:00
+++ b/net/ipv6/udp.c	2005-01-11 04:45:45 -02:00
@@ -549,7 +549,7 @@
  */
 static void udp_v6_flush_pending_frames(struct sock *sk)
 {
-	struct udp_opt *up = udp_sk(sk);
+	struct udp_sock *up = udp_sk(sk);
 
 	if (up->pending) {
 		up->len = 0;
@@ -562,7 +562,7 @@
  *	Sending
  */
 
-static int udp_v6_push_pending_frames(struct sock *sk, struct udp_opt *up)
+static int udp_v6_push_pending_frames(struct sock *sk, struct udp_sock *up)
 {
 	struct sk_buff *skb;
 	struct udphdr *uh;
@@ -623,7 +623,7 @@
 		  struct msghdr *msg, size_t len)
 {
 	struct ipv6_txoptions opt_space;
-	struct udp_opt *up = udp_sk(sk);
+	struct udp_sock *up = udp_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *) msg->msg_name;
@@ -878,7 +878,7 @@
 static int udpv6_setsockopt(struct sock *sk, int level, int optname, 
 			  char __user *optval, int optlen)
 {
-	struct udp_opt *up = udp_sk(sk);
+	struct udp_sock *up = udp_sk(sk);
 	int val;
 	int err = 0;
 
@@ -925,7 +925,7 @@
 static int udpv6_getsockopt(struct sock *sk, int level, int optname, 
 			  char __user *optval, int __user *optlen)
 {
-	struct udp_opt *up = udp_sk(sk);
+	struct udp_sock *up = udp_sk(sk);
 	int val, len;
 
 	if (level != SOL_UDP)


--------------000602060905070006080609--
