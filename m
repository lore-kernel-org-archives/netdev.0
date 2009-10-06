From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC net-next-2.6] net: speedup sk_wake_async()
Date: Wed, 07 Oct 2009 01:08:08 +0200
Message-ID: <4ACBCDD8.5000306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45503 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753848AbZJFXIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 19:08:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Latency works, part 1


An incoming datagram must bring into cpu cache *lot* of cache lines,
in particular : (other parts omitted (hash chains, ip route cache...))

On 32bit arches :

offsetof(struct sock, sk_rcvbuf)       =0x30    (read)
offsetof(struct sock, sk_lock)         =0x34   (rw)

offsetof(struct sock, sk_sleep)        =0x50 (read)
offsetof(struct sock, sk_rmem_alloc)   =0x64   (rw)
offsetof(struct sock, sk_receive_queue)=0x74   (rw)

offsetof(struct sock, sk_forward_alloc)=0x98   (rw)

offsetof(struct sock, sk_callback_lock)=0xcc    (rw)
offsetof(struct sock, sk_drops)        =0xd8 (read if we add dropcount support, rw if frame dropped)
offsetof(struct sock, sk_filter)       =0xf8    (read)

offsetof(struct sock, sk_socket)       =0x138 (read)

offsetof(struct sock, sk_data_ready)   =0x15c   (read)


We can avoid sk->sk_socket and socket->fasync_list referencing on sockets
with no fasync() structures. (socket->fasync_list ptr is probably already in cache
because it shares a cache line with socket->wait, ie location pointed by sk->sk_sleep)

This avoids one cache line load per incoming packet for common cases (no fasync())

We can leave (or even move in a future patch) sk->sk_socket in a cold location

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h |    3 ++-
 net/socket.c       |    3 +++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 1621935..98398bd 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -504,6 +504,7 @@ enum sock_flags {
 	SOCK_TIMESTAMPING_SOFTWARE,     /* %SOF_TIMESTAMPING_SOFTWARE */
 	SOCK_TIMESTAMPING_RAW_HARDWARE, /* %SOF_TIMESTAMPING_RAW_HARDWARE */
 	SOCK_TIMESTAMPING_SYS_HARDWARE, /* %SOF_TIMESTAMPING_SYS_HARDWARE */
+	SOCK_FASYNC, /* fasync() active */
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
@@ -1396,7 +1397,7 @@ static inline unsigned long sock_wspace(struct sock *sk)
 
 static inline void sk_wake_async(struct sock *sk, int how, int band)
 {
-	if (sk->sk_socket && sk->sk_socket->fasync_list)
+	if (sock_flag(sk, SOCK_FASYNC))
 		sock_wake_async(sk->sk_socket, how, band);
 }
 
diff --git a/net/socket.c b/net/socket.c
index 7565536..d53ad11 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1100,11 +1100,14 @@ static int sock_fasync(int fd, struct file *filp, int on)
 		fna->fa_next = sock->fasync_list;
 		write_lock_bh(&sk->sk_callback_lock);
 		sock->fasync_list = fna;
+		sock_set_flag(sk, SOCK_FASYNC);
 		write_unlock_bh(&sk->sk_callback_lock);
 	} else {
 		if (fa != NULL) {
 			write_lock_bh(&sk->sk_callback_lock);
 			*prev = fa->fa_next;
+			if (!sock->fasync_list)
+				sock_reset_flag(sk, SOCK_FASYNC);
 			write_unlock_bh(&sk->sk_callback_lock);
 			kfree(fa);
 		}
