From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Reduce number of pointer dereferences in IPv6 netfilter LOG
 module function dump_packet()
Date: Sun, 14 Nov 2010 22:47:28 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1011142241260.1253@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jan Rekorajski <baggins@pld.org.pl>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Netfilter Core Team <coreteam@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


By adding two pointer variables to 
net/ipv6/netfilter/ip6t_LOG.c::dump_packet() we can save 19 bytes of .text 
and many pointer dereferences.

before:
   text    data     bss     dec     hex filename
   6258     600    3088    9946    26da net/ipv6/netfilter/ip6t_LOG.o

after:
   text    data     bss     dec     hex filename
   6239     600    3088    9927    26c7 net/ipv6/netfilter/ip6t_LOG.o


Please Cc me on replies.


Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 ip6t_LOG.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index 09c8889..51d10a5 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -46,6 +46,8 @@ static void dump_packet(struct sbuff *m,
 	unsigned int ptr;
 	unsigned int hdrlen = 0;
 	unsigned int logflags;
+	struct sock *sk;
+	struct socket *sk_socket;
 
 	if (info->type == NF_LOG_TYPE_LOG)
 		logflags = info->u.log.logflags;
@@ -358,13 +360,15 @@ static void dump_packet(struct sbuff *m,
 	}
 
 	/* Max length: 15 "UID=4294967295 " */
-	if ((logflags & IP6T_LOG_UID) && recurse && skb->sk) {
-		read_lock_bh(&skb->sk->sk_callback_lock);
-		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
+	sk = skb->sk;
+	sk_socket = sk->sk_socket;
+	if ((logflags & IP6T_LOG_UID) && recurse && sk) {
+		read_lock_bh(&sk->sk_callback_lock);
+		if (sk_socket && sk_socket->file)
 			sb_add(m, "UID=%u GID=%u ",
-				skb->sk->sk_socket->file->f_cred->fsuid,
-				skb->sk->sk_socket->file->f_cred->fsgid);
-		read_unlock_bh(&skb->sk->sk_callback_lock);
+				sk_socket->file->f_cred->fsuid,
+				sk_socket->file->f_cred->fsgid);
+		read_unlock_bh(&sk->sk_callback_lock);
 	}
 
 	/* Max length: 16 "MARK=0xFFFFFFFF " */



-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

