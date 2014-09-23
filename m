From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 0/3] tcp: better TCP_SKB_CB layout
Date: Tue, 23 Sep 2014 03:34:09 -0700
Message-ID: <1411468452-3729-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:58013 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755806AbaIWKeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 06:34:16 -0400
Received: by mail-ie0-f201.google.com with SMTP id rd18so703505iec.2
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 03:34:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP had the assumption that IPCB and IP6CB are first members of skb->cb[]

This is fine, except that IPCB/IP6CB are used in TCP for a very short time
in input path.

What really matters for TCP stack is to get skb->next,
TCP_SKB_CB(skb)->seq, and TCP_SKB_CB(skb)->end_seq in the same cache line.

skb that are immediately consumed do not care because whole skb->cb[] is
hot in cpu cache, while skb that sit in wocket write queue or receive queues
do not need TCP_SKB_CB(skb)->header at all.

This patch set implements the prereq for IPv4, IPv6, and TCP to make this
possible. This makes TCP more efficient.


Eric Dumazet (3):
  ipv4: rename ip_options_echo to __ip_options_echo()
  ipv6: add a struct inet6_skb_parm param to ipv6_opt_accepted()
  tcp: better TCP_SKB_CB layout to reduce cache line misses

 include/net/ip.h      | 15 ++++++++++++---
 include/net/ipv6.h    |  3 ++-
 include/net/tcp.h     | 12 ++++++------
 net/dccp/ipv6.c       |  2 +-
 net/ipv4/ip_options.c |  6 ++----
 net/ipv4/ip_output.c  |  8 +++++---
 net/ipv4/tcp_ipv4.c   | 17 +++++++++++++----
 net/ipv4/tcp_output.c |  5 +++++
 net/ipv6/af_inet6.c   |  4 ++--
 net/ipv6/syncookies.c |  2 +-
 net/ipv6/tcp_ipv6.c   | 12 ++++++++++--
 11 files changed, 59 insertions(+), 27 deletions(-)

-- 
2.1.0.rc2.206.gedb03e5
