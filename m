From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] ipv6: adapt connect for repair move
Date: Thu, 22 Nov 2012 15:13:58 +0400
Message-ID: <1353582838-18876-1-git-send-email-avagin@openvz.org>
Cc: criu@openvz.org, linux-kernel@vger.kernel.org,
	Andrey Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Pavel Emelyanov <xemul@parallels.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is work the same as for ipv4.

All other hacks about tcp repair are in common code for ipv4 and ipv6,
so this patch is enough for repairing ipv6 connections.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 net/ipv4/tcp_ipv4.c   | 13 +------------
 net/ipv4/tcp_output.c |  5 +++++
 net/ipv6/tcp_ipv6.c   |  2 +-
 3 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0c4a643..801eac4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -138,14 +138,6 @@ int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp)
 }
 EXPORT_SYMBOL_GPL(tcp_twsk_unique);
 
-static int tcp_repair_connect(struct sock *sk)
-{
-	tcp_connect_init(sk);
-	tcp_finish_connect(sk, NULL);
-
-	return 0;
-}
-
 /* This will initiate an outgoing connection. */
 int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
@@ -250,10 +242,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	inet->inet_id = tp->write_seq ^ jiffies;
 
-	if (likely(!tp->repair))
-		err = tcp_connect(sk);
-	else
-		err = tcp_repair_connect(sk);
+	err = tcp_connect(sk);
 
 	rt = NULL;
 	if (err)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 9aac058..695984f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3000,6 +3000,11 @@ int tcp_connect(struct sock *sk)
 
 	tcp_connect_init(sk);
 
+	if (unlikely(tp->repair)) {
+		tcp_finish_connect(sk, NULL);
+		return 0;
+	}
+
 	buff = alloc_skb_fclone(MAX_TCP_HEADER + 15, sk->sk_allocation);
 	if (unlikely(buff == NULL))
 		return -ENOBUFS;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 26175bf..4968a53 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -306,7 +306,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (err)
 		goto late_failure;
 
-	if (!tp->write_seq)
+	if (!tp->write_seq && likely(!tp->repair))
 		tp->write_seq = secure_tcpv6_sequence_number(np->saddr.s6_addr32,
 							     np->daddr.s6_addr32,
 							     inet->inet_sport,
-- 
1.7.11.7
