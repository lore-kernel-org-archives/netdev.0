From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 0/3] tcp: no longer keep around headers in input path
Date: Mon, 15 Sep 2014 04:19:50 -0700
Message-ID: <1410779993-31464-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:43233 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863AbaIOLUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 07:20:09 -0400
Received: by mail-ig0-f202.google.com with SMTP id h18so520688igc.3
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 04:20:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looking at tcp_try_coalesce() I was wondering why I did :

if (tcp_hdr(from)->fin)
     return false;

The answer would be to allow the aggregation, if we simply OR the FIN and PSH
flags eventually present in @from to @to packet. (Note a change is also
needed in skb_try_coalesce() to avoid calling skb_put() with 0 len)

Then, looking at tcp_recvmsg(), I realized we access tcp_hdr(skb)->syn
(and maybe tcp_hdr(skb)->fin) for every packet we process from socket
receive queue.

We have to understand TCP flags are cold in cpu caches most of the time
(assuming TCP timestamps, and that application calls recvmsg() a long
time after incoming packet was processed), and bringing a whole
cache line only to access one bit is not very nice.

It would make sense to use in TCP input path TCP_SKB_CB(skb)->tcp_flags
as we do in output path.

This saves one cache line miss, and TCP tcp_collapse() can avoid dealing
with the headers.


Eric Dumazet (3):
  tcp: use TCP_SKB_CB(skb)->tcp_flags in input path
  tcp: allow segment with FIN in tcp_try_coalesce()
  tcp: do not copy headers in tcp_collapse()

 net/core/skbuff.c    |  3 ++-
 net/ipv4/tcp.c       | 18 ++++++++++--------
 net/ipv4/tcp_input.c | 31 ++++++++-----------------------
 net/ipv4/tcp_ipv4.c  |  1 +
 net/ipv6/tcp_ipv6.c  |  1 +
 5 files changed, 22 insertions(+), 32 deletions(-)

-- 
2.1.0.rc2.206.gedb03e5
