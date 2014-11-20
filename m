From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: remove from tcp_sendmsg() some fastopen code
Date: Thu, 20 Nov 2014 08:23:54 -0800
Message-ID: <1416500634.8629.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416268176.18588.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1416294380.14060.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAK6E8=dUvde2s7VuUS9rHiA2fU0ZT2bS=ronjM+9BOA=0u-rVw@mail.gmail.com>
	 <20141119.145741.1905980604994551607.davem@davemloft.net>
	 <1416497628.8629.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, nuclearcat@nuclearcat.com,
	netdev@vger.kernel.org, ncardwell@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:56798 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756447AbaKTQX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 11:23:56 -0500
Received: by mail-ig0-f182.google.com with SMTP id hn15so3089179igb.15
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 08:23:55 -0800 (PST)
In-Reply-To: <1416497628.8629.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If we consume iovec bytes in tcp_send_syn_data(), we can remove
annoying fastopen code in tcp_sendmsg() skipping over the already
consumed bytes.

Also add an unlikely(flags & MSG_FASTOPEN), as most TCP sendmsg() do not
ask for FASTOPEN.

Tested:
 Ran our 125 packetdrill fastopen tests

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c        |   14 ++------------
 net/ipv4/tcp_output.c |    4 ++--
 2 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c239f4740d10b10b67ef4fa44c831851fb9e1dcf..227540eef9d0870721258f9ddbace27b417c619e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1089,20 +1089,19 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 	int iovlen, flags, err, copied = 0;
-	int mss_now = 0, size_goal, copied_syn = 0, offset = 0;
+	int mss_now = 0, size_goal, copied_syn = 0;
 	bool sg;
 	long timeo;
 
 	lock_sock(sk);
 
 	flags = msg->msg_flags;
-	if (flags & MSG_FASTOPEN) {
+	if (unlikely(flags & MSG_FASTOPEN)) {
 		err = tcp_sendmsg_fastopen(sk, msg, &copied_syn, size);
 		if (err == -EINPROGRESS && copied_syn > 0)
 			goto out;
 		else if (err)
 			goto out_err;
-		offset = copied_syn;
 	}
 
 	timeo = sock_sndtimeo(sk, flags & MSG_DONTWAIT);
@@ -1151,15 +1150,6 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		unsigned char __user *from = iov->iov_base;
 
 		iov++;
-		if (unlikely(offset > 0)) {  /* Skip bytes copied in SYN */
-			if (offset >= seglen) {
-				offset -= seglen;
-				continue;
-			}
-			seglen -= offset;
-			from += offset;
-			offset = 0;
-		}
 
 		while (seglen > 0) {
 			int copy = 0;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f5bd4bd3f7e669b3fd48a843d55e7313a30a3409..524e5b657e881a348f11def3f48f29a76f54fbab 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3049,8 +3049,8 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 		goto fallback;
 	syn_data->ip_summed = CHECKSUM_PARTIAL;
 	memcpy(syn_data->cb, syn->cb, sizeof(syn->cb));
-	if (unlikely(memcpy_fromiovecend(skb_put(syn_data, space),
-					 fo->data->msg_iov, 0, space))) {
+	if (unlikely(memcpy_fromiovec(skb_put(syn_data, space),
+				      fo->data->msg_iov, space))) {
 		kfree_skb(syn_data);
 		goto fallback;
 	}
