From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: clear saved_syn in tcp_disconnect()
Date: Sat, 08 Apr 2017 08:07:33 -0700
Message-ID: <1491664053.10124.92.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35239 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752512AbdDHPHj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 11:07:39 -0400
Received: by mail-it0-f65.google.com with SMTP id y18so1537064itc.2
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 08:07:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In the (very unlikely) case a passive socket becomes a listener,
we do not want to duplicate its saved SYN headers.

This would lead to double frees, use after free, and please hackers and
various fuzzers 

Tested:
    0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
   +0 setsockopt(3, IPPROTO_TCP, TCP_SAVE_SYN, [1], 4) = 0
   +0 fcntl(3, F_SETFL, O_RDWR|O_NONBLOCK) = 0

   +0 bind(3, ..., ...) = 0
   +0 listen(3, 5) = 0

   +0 < S 0:0(0) win 32972 <mss 1460,nop,wscale 7>
   +0 > S. 0:0(0) ack 1 <...>
  +.1 < . 1:1(0) ack 1 win 257
   +0 accept(3, ..., ...) = 4

   +0 connect(4, AF_UNSPEC, ...) = 0
   +0 close(3) = 0
   +0 bind(4, ..., ...) = 0
   +0 listen(4, 5) = 0

   +0 < S 0:0(0) win 32972 <mss 1460,nop,wscale 7>
   +0 > S. 0:0(0) ack 1 <...>
  +.1 < . 1:1(0) ack 1 win 257


Fixes: cd8ae85299d5 ("tcp: provide SYN headers for passive connections")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 94f0b5b50e0d728c3edab175aee9d769cd80907f..04843ae77b9ecacb3e4f2e81096f11d35ae1915e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2322,6 +2322,7 @@ int tcp_disconnect(struct sock *sk, int flags)
 	tcp_init_send_head(sk);
 	memset(&tp->rx_opt, 0, sizeof(tp->rx_opt));
 	__sk_dst_reset(sk);
+	tcp_saved_syn_free(tp);
 
 	/* Clean up fastopen related fields */
 	tcp_free_fastopen_req(tp);
