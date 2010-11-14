From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Reduce number of pointer dereferences in IPv4 netfilter LOG
 module function dump_packet()
Date: Sun, 14 Nov 2010 22:35:27 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1011142212310.1253@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Netfilter Core Team <coreteam@netfilter.org>
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


By adding two pointer variables to 
net/ipv4/netfilter/ipt_LOG.c::dump_packet() we can save 16 bytes of .text 
and 9 pointer dereferences.

before this patch we did 20 pointer dereferences and had this object file 
size:
   text    data     bss     dec     hex filename
   6233     600    3080    9913    26b9 net/ipv4/netfilter/ipt_LOG.o

after this patch we do just 11 pointer dereferences and have this object 
file size:
   text    data     bss     dec     hex filename
   6217     600    3080    9897    26a9 net/ipv4/netfilter/ipt_LOG.o


Please Cc me on replies.


Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 ipt_LOG.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index 72ffc8f..02a92de 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -39,6 +39,8 @@ static void dump_packet(struct sbuff *m,
 	struct iphdr _iph;
 	const struct iphdr *ih;
 	unsigned int logflags;
+	struct sock *sk;
+	struct socket *sk_socket;
 
 	if (info->type == NF_LOG_TYPE_LOG)
 		logflags = info->u.log.logflags;
@@ -335,13 +337,15 @@ static void dump_packet(struct sbuff *m,
 	}
 
 	/* Max length: 15 "UID=4294967295 " */
-	if ((logflags & IPT_LOG_UID) && !iphoff && skb->sk) {
-		read_lock_bh(&skb->sk->sk_callback_lock);
-		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
+	sk = skb->sk;
+	sk_socket = sk->sk_socket;
+	if ((logflags & IPT_LOG_UID) && !iphoff && sk) {
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

