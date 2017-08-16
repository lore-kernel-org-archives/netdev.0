From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Wed, 16 Aug 2017 11:28:42 +0200
Message-ID: <1502875722.3548.11.camel@redhat.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca>
         <1502702846.8411.25.camel@redhat.com> <1846443.VTclhqQinN@ring00>
         <CAF=yD-L9CpW-DRtKfWWWKcNKcPSWvXOkTGZoKBq6=fQMrcKVWQ@mail.gmail.com>
         <1502724662.8411.53.camel@redhat.com>
         <CAF=yD-+ZNPtF1h1OT=_4yuE7=XtireP_OtbyBefHGdwtJ_ontQ@mail.gmail.com>
         <1502811641.3475.7.camel@redhat.com>
         <CAF=yD-Lacw9T7G0XZBdHZwEb6HgRuaBoyUN1oTvWixu4a0Fy6Q@mail.gmail.com>
         <CAF=yD-+jBim==ktwYUNAFkn-N4eabqgNME8NXM77v9-U_bfWPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Network Development <netdev@vger.kernel.org>,
        "Macieira, Thiago" <thiago.macieira@intel.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42804 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751224AbdHPJ2v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 05:28:51 -0400
In-Reply-To: <CAF=yD-+jBim==ktwYUNAFkn-N4eabqgNME8NXM77v9-U_bfWPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-15 at 13:00 -0400, Willem de Bruijn wrote:
> > There is another difference between reading sk_peek_offset in the
> > caller or in __skb_try_recv_from_queue. The latter is called repeatedly
> > when it returns NULL. Each call can modify *off. I believe that it needs
> > to restart with _off at sk->sk_peek_off each time, as it restarts from the
> > head of the queue each time.
> 
> I made a mistake here. *off is not updated when returning NULL.
> 
> In that case, it is better to read sk_peek_offset once, than to read
> it each time __skb_try_recv_from_queue is entered.

If I read the above correctly, you are arguining in favor of the
addittional flag version, right?

Regarding the MSG flag exaustion, there are a bunch of flags defined
but apparently unused (MSG_FIN, MSG_SYN, MSG_RST) since long time (if
I'm not too low on coffee).

We can shadow one of them (or ev. drop the above defines, if really
unused).

I think that the MSG_PEEK_OFF should be explicitly cleared in
sk_peek_offset() when the sk_peek_off is negative, to avoid beeing
fooled by stray bits passed by the us, like in the following:
---
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 8b13db5163cc..3b7f53b9cc08 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -286,6 +286,7 @@ struct ucred {
 #define MSG_SENDPAGE_NOTLAST 0x20000 /* sendpage() internal : not the last page */
 #define MSG_BATCH	0x40000 /* sendmmsg(): more messages coming */
 #define MSG_EOF         MSG_FIN
+#define MSG_PEEK_OFF	MSG_FIN /* Peeking with offset for datagram sockets */
 
 #define MSG_FASTOPEN	0x20000000	/* Send data in TCP SYN */
 #define MSG_CMSG_CLOEXEC 0x40000000	/* Set close_on_exec for file
diff --git a/include/net/sock.h b/include/net/sock.h
index 7c0632c7e870..452f9aac2e6a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -504,12 +504,17 @@ enum sk_pacing {
 
 int sk_set_peek_off(struct sock *sk, int val);
 
-static inline int sk_peek_offset(struct sock *sk, int flags)
+static inline int sk_peek_offset(struct sock *sk, int *flags)
 {
-	if (unlikely(flags & MSG_PEEK)) {
+	if (unlikely(*flags & MSG_PEEK)) {
 		s32 off = READ_ONCE(sk->sk_peek_off);
-		if (off >= 0)
+		if (off >= 0) {
+			*flags |= MSG_PEEK_OFF;
 			return off;
+		}
+
+		/* clear evental stray bits in the user-provided bitmask */
+		*flags &= ~MSG_PEEK_OFF;
 	}
 
 	return 0;
diff --git a/net/core/datagram.c b/net/core/datagram.c
index ee5647bd91b3..91e1d014d64c 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -175,8 +175,8 @@ struct sk_buff *__skb_try_recv_from_queue(struct sock *sk,
 	*last = queue->prev;
 	skb_queue_walk(queue, skb) {
 		if (flags & MSG_PEEK) {
-			if (_off >= skb->len && (skb->len || _off ||
-						 skb->peeked)) {
+			if (flags & MSG_PEEK_OFF && _off >= skb->len &&
+			    (skb->len || _off || skb->peeked)) {
 				_off -= skb->len;
 				continue;
 			}
diff --git a/net/core/sock.c b/net/core/sock.c
index ac2a404c73eb..0c123540b02f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2408,9 +2408,7 @@ EXPORT_SYMBOL(__sk_mem_reclaim);
 
 int sk_set_peek_off(struct sock *sk, int val)
 {
-	if (val < 0)
-		return -EINVAL;
-
+	/* a negative value will disable peeking with offset */
 	sk->sk_peek_off = val;
 	return 0;
 }
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index a7c804f73990..7e1bcd3500f4 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1574,7 +1574,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 		return ip_recv_error(sk, msg, len, addr_len);
 
 try_again:
-	peeking = off = sk_peek_offset(sk, flags);
+	peeking = off = sk_peek_offset(sk, &flags);
 	skb = __skb_recv_udp(sk, flags, noblock, &peeked, &off, &err);
 	if (!skb)
 		return err;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 578142b7ca3e..86fb4ff8934c 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -362,7 +362,7 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 		return ipv6_recv_rxpmtu(sk, msg, len, addr_len);
 
 try_again:
-	peeking = off = sk_peek_offset(sk, flags);
+	peeking = off = sk_peek_offset(sk, &flags);
 	skb = __skb_recv_udp(sk, flags, noblock, &peeked, &off, &err);
 	if (!skb)
 		return err;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 7b52a380d710..06c740939d9d 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2124,7 +2124,7 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
 	do {
 		mutex_lock(&u->iolock);
 
-		skip = sk_peek_offset(sk, flags);
+		skip = sk_peek_offset(sk, &flags);
 		skb = __skb_try_recv_datagram(sk, flags, NULL, &peeked, &skip,
 					      &err, &last);
 		if (skb)
@@ -2304,10 +2304,7 @@ static int unix_stream_read_generic(struct unix_stream_read_state *state,
         */
        mutex_lock(&u->iolock);
 
-       if (flags & MSG_PEEK)
-               skip = sk_peek_offset(sk, flags);
-       else
-               skip = 0;
+       skip = sk_peek_offset(sk, &flags);
 
        do {
                int chunk;
