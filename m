From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH] datagram: Extend the datagram queue MSG_PEEK-ing
Date: Mon, 20 Feb 2012 16:17:11 +0400
Message-ID: <4F4239C7.6040905@parallels.com>
References: <4F352182.6060601@parallels.com> <20120215.155226.1446930776120577759.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "tj@kernel.org" <tj@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:28383 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752506Ab2BTMR3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Feb 2012 07:17:29 -0500
In-Reply-To: <20120215.155226.1446930776120577759.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'm still thinking about how I feel about this.
> 
> But meanwhile you can fix some thing up, for example I really
> feel that you should make sure that multiple bits aren't set
> at the same time.
> 
> You either mean MSG_PEEK_MORE or MSG_PEEK_AGAIN, so setting both
> makes no sense and should be flagged as an error.

Actually Eric has pointed out the critical issue with this -- if a task
(whose socket's queue we're about to peek) is currently peek-ing this
queue himself, we will peek only the queue's tail and will potentially 
break this task's peeking in case he uses the _MORE/_AGAIN macros :(


I was thinking about another option of doing the same, how about introducing
the peek offset member on sock (get/set via sockopt) which works like

* if == -1, then peek works as before
* if >= 0, then each peek/recvmsg will increase/decrease the value so that
  the next peek peeks next data

It's questionable what to do if the peek_off points into the middle of a
datagram however. Here's an example of how this looks for datagram sockets
(tested on pf_unix), for stream this requires more patching.

What do you think? Does it make sense to go on with this making other 
->recvmsg handlers support peeking offset?

---

diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.h
index 49c1704..832c270 100644
--- a/include/asm-generic/socket.h
+++ b/include/asm-generic/socket.h
@@ -66,5 +66,6 @@
 #define SO_RXQ_OVFL             40
 
 #define SO_WIFI_STATUS		41
+#define SO_PEEK_OFF		42
 #define SCM_WIFI_STATUS	SO_WIFI_STATUS
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 91c1c8b..94b0372 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -357,6 +357,7 @@ struct sock {
 	struct page		*sk_sndmsg_page;
 	struct sk_buff		*sk_send_head;
 	__u32			sk_sndmsg_off;
+	__s32			sk_peek_off;
 	int			sk_write_pending;
 #ifdef CONFIG_SECURITY
 	void			*sk_security;
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 68bbf9f..78e5147 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -180,21 +180,37 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
 		 * However, this function was correct in any case. 8)
 		 */
 		unsigned long cpu_flags;
+		long skip;
 
 		spin_lock_irqsave(&sk->sk_receive_queue.lock, cpu_flags);
-		skb = skb_peek(&sk->sk_receive_queue);
-		if (skb) {
+		skip = sk->sk_peek_off;
+		skb_queue_walk(&sk->sk_receive_queue, skb) {
 			*peeked = skb->peeked;
 			if (flags & MSG_PEEK) {
 				skb->peeked = 1;
 				atomic_inc(&skb->users);
-			} else
+				if (skip >= skb->len) {
+					skip -= skb->len;
+					continue;
+				}
+
+				if (sk->sk_peek_off >= 0)
+					sk->sk_peek_off += (skb->len - skip);
+			} else {
 				__skb_unlink(skb, &sk->sk_receive_queue);
-		}
-		spin_unlock_irqrestore(&sk->sk_receive_queue.lock, cpu_flags);
 
-		if (skb)
+				if (sk->sk_peek_off >= 0) {
+					if (sk->sk_peek_off >= skb->len)
+						sk->sk_peek_off -= skb->len;
+					else
+						sk->sk_peek_off = 0;
+				}
+			}
+
+			spin_unlock_irqrestore(&sk->sk_receive_queue.lock, cpu_flags);
 			return skb;
+		}
+		spin_unlock_irqrestore(&sk->sk_receive_queue.lock, cpu_flags);
 
 		/* User doesn't want to wait */
 		error = -EAGAIN;
diff --git a/net/core/sock.c b/net/core/sock.c
index 02f8dfe..5a5d581 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -792,7 +792,9 @@ set_rcvbuf:
 	case SO_WIFI_STATUS:
 		sock_valbool_flag(sk, SOCK_WIFI_STATUS, valbool);
 		break;
-
+	case SO_PEEK_OFF:
+		sk->sk_peek_off = val;
+		break;
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -1017,6 +1019,9 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 	case SO_WIFI_STATUS:
 		v.val = !!sock_flag(sk, SOCK_WIFI_STATUS);
 		break;
+	case SO_PEEK_OFF:
+		v.val = sk->sk_peek_off;
+		break;
 
 	default:
 		return -ENOPROTOOPT;
@@ -2092,6 +2097,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 
 	sk->sk_sndmsg_page	=	NULL;
 	sk->sk_sndmsg_off	=	0;
+	sk->sk_peek_off		=	-1;
 
 	sk->sk_peer_pid 	=	NULL;
 	sk->sk_peer_cred	=	NULL;
