From: Michael Witten <mfwitten@gmail.com>
Subject: [PATCH net 0/3] net: TCP/IP: A few minor cleanups
Date: Sun, 01 Oct 2017 22:19:02 -0000
Message-ID: <14527e6c082e4ea282a3f833118c68df-mfwitten@gmail.com>
References: <45aab5effc0c424a992646a97cf2ec14-mfwitten@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <45aab5effc0c424a992646a97cf2ec14-mfwitten@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patch series is an ad hoc "cleanup" that I made
while perusing the code (I'm not well versed in this code, so I
would not be surprised if there were objections to the changes):

  [1] net: __sock_cmsg_send(): Remove unused parameter `msg'
  [2] net: inet_recvmsg(): Remove unnecessary bitwise operation
  [3] net: skb_queue_purge(): lock/unlock the queue only once

Each patch will be sent as an individual reply to this email;
the total diff is appended below for your convenience.

You may also fetch these patches from GitHub:

  git checkout --detach 5969d1bb3082b41eba8fd2c826559abe38ccb6df
  git pull https://github.com/mfwitten/linux.git net/tcp-ip/01-cleanup/02

Overall:

  include/net/sock.h     |  2 +-
  net/core/skbuff.c      | 26 ++++++++++++++++++--------
  net/core/sock.c        |  4 ++--
  net/ipv4/af_inet.c     |  2 +-
  net/ipv4/ip_sockglue.c |  2 +-
  net/ipv6/datagram.c    |  2 +-
  6 files changed, 24 insertions(+), 14 deletions(-)

Sincerly,
Michael Witten

diff --git a/include/net/sock.h b/include/net/sock.h
index 03a362568357..83373d7148a9 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1562,7 +1562,7 @@ struct sockcm_cookie {
 	u16 tsflags;
 };
 
-int __sock_cmsg_send(struct sock *sk, struct msghdr *msg, struct cmsghdr *cmsg,
+int __sock_cmsg_send(struct sock *sk, struct cmsghdr *cmsg,
 		     struct sockcm_cookie *sockc);
 int sock_cmsg_send(struct sock *sk, struct msghdr *msg,
 		   struct sockcm_cookie *sockc);
diff --git a/net/core/sock.c b/net/core/sock.c
index 9b7b6bbb2a23..425e03fe1c56 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2091,7 +2091,7 @@ struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
 }
 EXPORT_SYMBOL(sock_alloc_send_skb);
 
-int __sock_cmsg_send(struct sock *sk, struct msghdr *msg, struct cmsghdr *cmsg,
+int __sock_cmsg_send(struct sock *sk, struct cmsghdr *cmsg,
 		     struct sockcm_cookie *sockc)
 {
 	u32 tsflags;
@@ -2137,7 +2137,7 @@ int sock_cmsg_send(struct sock *sk, struct msghdr *msg,
 			return -EINVAL;
 		if (cmsg->cmsg_level != SOL_SOCKET)
 			continue;
-		ret = __sock_cmsg_send(sk, msg, cmsg, sockc);
+		ret = __sock_cmsg_send(sk, cmsg, sockc);
 		if (ret)
 			return ret;
 	}
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index e558e4f9597b..c79b7822b0b9 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -263,7 +263,7 @@ int ip_cmsg_send(struct sock *sk, struct msghdr *msg, struct ipcm_cookie *ipc,
 		}
 #endif
 		if (cmsg->cmsg_level == SOL_SOCKET) {
-			err = __sock_cmsg_send(sk, msg, cmsg, &ipc->sockc);
+			err = __sock_cmsg_send(sk, cmsg, &ipc->sockc);
 			if (err)
 				return err;
 			continue;
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index a1f918713006..1d1926a4cbe2 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -756,7 +756,7 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 		}
 
 		if (cmsg->cmsg_level == SOL_SOCKET) {
-			err = __sock_cmsg_send(sk, msg, cmsg, sockc);
+			err = __sock_cmsg_send(sk, cmsg, sockc);
 			if (err)
 				return err;
 			continue;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index e31108e5ef79..2dbed042a412 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -791,7 +791,7 @@ int inet_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 	sock_rps_record_flow(sk);
 
 	err = sk->sk_prot->recvmsg(sk, msg, size, flags & MSG_DONTWAIT,
-				   flags & ~MSG_DONTWAIT, &addr_len);
+				   flags, &addr_len);
 	if (err >= 0)
 		msg->msg_namelen = addr_len;
 	return err;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 68065d7d383f..bd26b0bde784 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2825,18 +2825,28 @@
 EXPORT_SYMBOL(skb_dequeue_tail);
 
 /**
- *	skb_queue_purge - empty a list
- *	@list: list to empty
+ *	skb_queue_purge - empty a queue
+ *	@q: the queue to empty
  *
- *	Delete all buffers on an &sk_buff list. Each buffer is removed from
- *	the list and one reference dropped. This function takes the list
- *	lock and is atomic with respect to other list locking functions.
+ *	Dequeue and free each socket buffer that is in @q.
+ *
+ *	This function is atomic with respect to other queue-locking functions.
  */
-void skb_queue_purge(struct sk_buff_head *list)
+void skb_queue_purge(struct sk_buff_head *q)
 {
-	struct sk_buff *skb;
-	while ((skb = skb_dequeue(list)) != NULL)
+	unsigned long flags;
+	struct sk_buff *skb, *next, *head = (struct sk_buff *)q;
+
+	spin_lock_irqsave(&q->lock, flags);
+	skb = q->next;
+	__skb_queue_head_init(q);
+	spin_unlock_irqrestore(&q->lock, flags);
+
+	while (skb != head) {
+		next = skb->next;
 		kfree_skb(skb);
+		skb = next;
+	}
 }
 EXPORT_SYMBOL(skb_queue_purge);
 
-- 
2.14.1
