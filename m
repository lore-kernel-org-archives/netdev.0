From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/7] tcp: implement rb-tree based retransmit queue
Date: Thu,  5 Oct 2017 22:21:20 -0700
Message-ID: <20171006052127.19913-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:49804 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750781AbdJFFVe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 01:21:34 -0400
Received: by mail-pg0-f51.google.com with SMTP id v13so9416254pgq.6
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 22:21:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implement RB-tree based retransmit queue for TCP,
to better match modern BDP.

Tested:

 On receiver :
 netem on ingress : delay 150ms 200us loss 1
 GRO disabled to force stress and SACK storms.

for f in `seq 1 10`
do
 ./netperf -H lpaa6 -l30 -- -K bbr -o THROUGHPUT|tail -1
done | awk '{print $0} {sum += $0} END {printf "%7u\n",sum}'

Before patch :

323.87  351.48  339.59  338.62  306.72
204.07  304.93  291.88  202.47  176.88
->   2840

After patch:

1700.83 2207.98 2070.17 1544.26 2114.76
2124.89 1693.14 1080.91 2216.82 1299.94
->  18053

Average of 1805 Mbits istead of 284 Mbits.

Eric Dumazet (7):
  net: add rb_to_skb() and other rb tree helpers
  tcp: uninline tcp_write_queue_purge()
  tcp: tcp_tx_timestamp() cleanup
  tcp: tcp_mark_head_lost() optimization
  tcp: reduce tcp_fastretrans_alert() verbosity
  tcp: pass previous skb to tcp_shifted_skb()
  tcp: implement rb-tree based retransmit queue

 include/linux/skbuff.h  |  18 +++++
 include/net/sock.h      |   7 +-
 include/net/tcp.h       | 100 ++++++++++++--------------
 net/ipv4/tcp.c          |  63 ++++++++++++----
 net/ipv4/tcp_fastopen.c |   8 +--
 net/ipv4/tcp_input.c    | 187 ++++++++++++++++++++++++------------------------
 net/ipv4/tcp_ipv4.c     |   2 +-
 net/ipv4/tcp_output.c   | 137 +++++++++++++++++++----------------
 net/ipv4/tcp_timer.c    |  24 ++++---
 net/sched/sch_netem.c   |  14 ++--
 10 files changed, 311 insertions(+), 249 deletions(-)

-- 
2.14.2.920.gcf0c67979c-goog
