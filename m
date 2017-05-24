From: Wei Wang <weiwan@google.com>
Subject: [PATCH net] tcp: avoid fastopen API to be used on AF_UNSPEC
Date: Wed, 24 May 2017 09:59:31 -0700
Message-ID: <20170524165931.22502-1-tracywwnj@gmail.com>
Cc: Yuchung Cheng <ycheng@google.com>,
        Vegard Nossum <vegard.nossum@oracle.com>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35447 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1164145AbdEXQ7q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 12:59:46 -0400
Received: by mail-pf0-f169.google.com with SMTP id n23so142167494pfb.2
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 09:59:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

Fastopen API should be used to perform fastopen operations on the TCP
socket. It does not make sense to use fastopen API to perform disconnect
by calling it with AF_UNSPEC. The fastopen data path is also prone to
race conditions and bugs when using with AF_UNSPEC.

One issue reported and analyzed by Vegard Nossum is as follows:
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Thread A:                            Thread B:
------------------------------------------------------------------------
sendto()
 - tcp_sendmsg()
     - sk_stream_memory_free() = 0
         - goto wait_for_sndbuf
	     - sk_stream_wait_memory()
	        - sk_wait_event() // sleep
          |                          sendto(flags=MSG_FASTOPEN, dest_addr=AF_UNSPEC)
	  |                           - tcp_sendmsg()
	  |                              - tcp_sendmsg_fastopen()
	  |                                 - __inet_stream_connect()
	  |                                    - tcp_disconnect() //because of AF_UNSPEC
	  |                                       - tcp_transmit_skb()// send RST
	  |                                    - return 0; // no reconnect!
	  |                           - sk_stream_wait_connect()
	  |                                 - sock_error()
	  |                                    - xchg(&sk->sk_err, 0)
	  |                                    - return -ECONNRESET
	- ... // wake up, see sk->sk_err == 0
    - skb_entail() on TCP_CLOSE socket

If the connection is reopened then we will send a brand new SYN packet
after thread A has already queued a buffer. At this point I think the
socket internal state (sequence numbers etc.) becomes messed up.

When the new connection is closed, the FIN-ACK is rejected because the
sequence number is outside the window. The other side tries to
retransmit,
but __tcp_retransmit_skb() calls tcp_trim_head() on an empty skb which
corrupts the skb data length and hits a BUG() in copy_and_csum_bits().
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Hence, this patch adds a check for AF_UNSPEC in the fastopen data path
and return EOPNOTSUPP to user if such case happens.

Fixes: cf60af03ca4e7 ("tcp: Fast Open client - sendmsg(MSG_FASTOPEN)")
Reported-by: Vegard Nossum <vegard.nossum@oracle.com>
Signed-off-by: Wei Wang <weiwan@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 60203f1c793e..fea7c4f2d36c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1161,9 +1161,12 @@ static int tcp_sendmsg_fastopen(struct sock *sk, struct msghdr *msg,
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
+	struct sockaddr *uaddr = msg->msg_name;
 	int err, flags;
 
-	if (!(sysctl_tcp_fastopen & TFO_CLIENT_ENABLE))
+	if (!(sysctl_tcp_fastopen & TFO_CLIENT_ENABLE) ||
+	    (uaddr && msg->msg_namelen >= sizeof(uaddr->sa_family) &&
+	     uaddr->sa_family == AF_UNSPEC))
 		return -EOPNOTSUPP;
 	if (tp->fastopen_req)
 		return -EALREADY; /* Another Fast Open is in progress */
@@ -1185,7 +1188,7 @@ static int tcp_sendmsg_fastopen(struct sock *sk, struct msghdr *msg,
 		}
 	}
 	flags = (msg->msg_flags & MSG_DONTWAIT) ? O_NONBLOCK : 0;
-	err = __inet_stream_connect(sk->sk_socket, msg->msg_name,
+	err = __inet_stream_connect(sk->sk_socket, uaddr,
 				    msg->msg_namelen, flags, 1);
 	/* fastopen_req could already be freed in __inet_stream_connect
 	 * if the connection times out or gets rst
-- 
2.13.0.219.gdb65acc882-goog
