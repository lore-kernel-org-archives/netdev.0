From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Consolidate rose socket grafting.
Date: Tue, 17 Jun 2008 02:42:24 -0700 (PDT)
Message-ID: <20080617.024224.160706790.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-hams@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Finally, this is the rose version of the ax25 socket
grafting change.

Someone sufficiently motivated might want to make a nice
radio protocol stack common layer.  As several have noticed
and noted in the past, rose ax25 and netrom all have
an enormous amount of duplicated code.

Applied and pushed to net-next-2.6

rose: Use sock_graft() and remove bogus sk_socket and sk_sleep init.

This is the rose variant of changeset
9375cb8a1232d2a15fe34bec4d3474872e02faec
("ax25: Use sock_graft() and remove bogus sk_socket and sk_sleep init.")

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/rose/af_rose.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 1ebf652..af86bcb 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -566,13 +566,11 @@ static struct sock *rose_make_new(struct sock *osk)
 #endif
 
 	sk->sk_type     = osk->sk_type;
-	sk->sk_socket   = osk->sk_socket;
 	sk->sk_priority = osk->sk_priority;
 	sk->sk_protocol = osk->sk_protocol;
 	sk->sk_rcvbuf   = osk->sk_rcvbuf;
 	sk->sk_sndbuf   = osk->sk_sndbuf;
 	sk->sk_state    = TCP_ESTABLISHED;
-	sk->sk_sleep    = osk->sk_sleep;
 	sock_copy_flags(sk, osk);
 
 	init_timer(&rose->timer);
@@ -924,14 +922,12 @@ static int rose_accept(struct socket *sock, struct socket *newsock, int flags)
 		goto out_release;
 
 	newsk = skb->sk;
-	newsk->sk_socket = newsock;
-	newsk->sk_sleep = &newsock->wait;
+	sock_graft(newsk, newsock);
 
 	/* Now attach up the new socket */
 	skb->sk = NULL;
 	kfree_skb(skb);
 	sk->sk_ack_backlog--;
-	newsock->sk = newsk;
 
 out_release:
 	release_sock(sk);
-- 
1.5.5.1.308.g1fbb5

