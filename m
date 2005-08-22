From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] Fix socket bitop damage
Date: Mon, 22 Aug 2005 12:02:18 +0100
Message-ID: <20050822110218.GA7514@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@linux-mips.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The socket flag cleanups that went into 2.6.12-rc1 are basically oring
the flags of an old socket into the socket just being created.
Unfortunately that one was just initialized by sock_init_data(), so already
has SOCK_ZAPPED set.  As the result zapped sockets are created and all
incoming connection will fail due to this bug which again was carefully
replicated to at least AX.25, NET/ROM or ROSE.

In order to keep the abstraction alive I've introduced sock_copy_flags()
to copy the socket flags from one sockets to another and used that
instead of the bitwise copy thing.  Anyway, the idea here has probably
been to copy all flags, so sock_copy_flags() should be the right thing.
With this the ham radio protocols are usable again, so I hope this will
make it into 2.6.13.

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 include/net/sock.h     |    5 +++++
 net/ax25/af_ax25.c     |    7 +------
 net/netrom/af_netrom.c |    7 +------
 net/rose/af_rose.c     |    7 +------
 4 files changed, 8 insertions(+), 18 deletions(-)

Index: linux-cvs/net/netrom/af_netrom.c
===================================================================
--- linux-cvs.orig/net/netrom/af_netrom.c
+++ linux-cvs/net/netrom/af_netrom.c
@@ -465,12 +465,7 @@ static struct sock *nr_make_new(struct s
 	sk->sk_sndbuf   = osk->sk_sndbuf;
 	sk->sk_state    = TCP_ESTABLISHED;
 	sk->sk_sleep    = osk->sk_sleep;
-
-	if (sock_flag(osk, SOCK_ZAPPED))
-		sock_set_flag(sk, SOCK_ZAPPED);
-
-	if (sock_flag(osk, SOCK_DBG))
-		sock_set_flag(sk, SOCK_DBG);
+	sock_copy_flags(sk, osk);
 
 	skb_queue_head_init(&nr->ack_queue);
 	skb_queue_head_init(&nr->reseq_queue);
Index: linux-cvs/include/net/sock.h
===================================================================
--- linux-cvs.orig/include/net/sock.h
+++ linux-cvs/include/net/sock.h
@@ -384,6 +384,11 @@ enum sock_flags {
 	SOCK_QUEUE_SHRUNK, /* write queue has been shrunk recently */
 };
 
+static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
+{
+	nsk->sk_flags = osk->sk_flags;
+}
+
 static inline void sock_set_flag(struct sock *sk, enum sock_flags flag)
 {
 	__set_bit(flag, &sk->sk_flags);
Index: linux-cvs/net/ax25/af_ax25.c
===================================================================
--- linux-cvs.orig/net/ax25/af_ax25.c
+++ linux-cvs/net/ax25/af_ax25.c
@@ -884,12 +884,7 @@ struct sock *ax25_make_new(struct sock *
 	sk->sk_sndbuf   = osk->sk_sndbuf;
 	sk->sk_state    = TCP_ESTABLISHED;
 	sk->sk_sleep    = osk->sk_sleep;
-
-	if (sock_flag(osk, SOCK_DBG))
-		sock_set_flag(sk, SOCK_DBG);
-
-	if (sock_flag(osk, SOCK_ZAPPED))
-		sock_set_flag(sk, SOCK_ZAPPED);
+	sock_copy_flags(sk, osk);
 
 	oax25 = ax25_sk(osk);
 
Index: linux-cvs/net/rose/af_rose.c
===================================================================
--- linux-cvs.orig/net/rose/af_rose.c
+++ linux-cvs/net/rose/af_rose.c
@@ -556,12 +556,7 @@ static struct sock *rose_make_new(struct
 	sk->sk_sndbuf   = osk->sk_sndbuf;
 	sk->sk_state    = TCP_ESTABLISHED;
 	sk->sk_sleep    = osk->sk_sleep;
-
-	if (sock_flag(osk, SOCK_ZAPPED))
-		sock_set_flag(sk, SOCK_ZAPPED);
-
-	if (sock_flag(osk, SOCK_DBG))
-		sock_set_flag(sk, SOCK_DBG);
+	sock_copy_flags(sk, osk);
 
 	init_timer(&rose->timer);
 	init_timer(&rose->idletimer);
