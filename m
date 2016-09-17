From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH v2 net-next 00/16] tcp: BBR congestion control algorithm
Date: Sat, 17 Sep 2016 13:35:33 -0400
Message-ID: <1474133749-12895-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:36788 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752569AbcIQRf6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 13:35:58 -0400
Received: by mail-qt0-f179.google.com with SMTP id l91so55914211qte.3
        for <netdev@vger.kernel.org>; Sat, 17 Sep 2016 10:35:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp: BBR congestion control algorithm

This patch series implements a new TCP congestion control algorithm:
BBR (Bottleneck Bandwidth and RTT). A paper with a detailed
description of BBR will be published in ACM Queue, September-October
2016, as "BBR: Congestion-Based Congestion Control". BBR is widely
deployed in production at Google.

The patch series starts with a set of supporting infrastructure
changes, including a few that extend the congestion control
framework. The last patch adds BBR as a TCP congestion control
module. Please see individual patches for the details.

- v1 -> v2: fix issues caught by build bots:
 - fix "tcp: export data delivery rate" to use rate64 instead of rate,
   so there is a 64-bit numerator for the do_div call
 - fix conflicting definitions for minmax caused by
   "tcp: use windowed min filter library for TCP min_rtt estimation"
   with a new commit:
   tcp: cdg: rename struct minmax in tcp_cdg.c to avoid a naming conflict
 - fix warning about the use of __packed in
   "tcp: track data delivery rate for a TCP connection",
   which involves the addition of a new commit:
   tcp: switch back to proper tcp_skb_cb size check in tcp_init()  

Eric Dumazet (2):
  net_sched: sch_fq: add low_rate_threshold parameter
  tcp: switch back to proper tcp_skb_cb size check in tcp_init()

Neal Cardwell (8):
  lib/win_minmax: windowed min or max estimator
  tcp: use windowed min filter library for TCP min_rtt estimation
  tcp: count packets marked lost for a TCP connection
  tcp: allow congestion control module to request TSO skb segment count
  tcp: export tcp_tso_autosize() and parameterize minimum number of TSO
    segments
  tcp: export tcp_mss_to_mtu() for congestion control modules
  tcp: increase ICSK_CA_PRIV_SIZE from 64 bytes to 88
  tcp_bbr: add BBR congestion control

Soheil Hassas Yeganeh (2):
  tcp: cdg: rename struct minmax in tcp_cdg.c to avoid a naming conflict
  tcp: track application-limited rate samples

Yuchung Cheng (4):
  tcp: track data delivery rate for a TCP connection
  tcp: export data delivery rate
  tcp: allow congestion control to expand send buffer differently
  tcp: new CC hook to set sending rate with rate_sample in any CA state

 include/linux/tcp.h                |  14 +-
 include/linux/win_minmax.h         |  37 ++
 include/net/inet_connection_sock.h |   4 +-
 include/net/tcp.h                  |  53 ++-
 include/uapi/linux/inet_diag.h     |  13 +
 include/uapi/linux/pkt_sched.h     |   2 +
 include/uapi/linux/tcp.h           |   3 +
 lib/Makefile                       |   2 +-
 lib/win_minmax.c                   |  98 +++++
 net/ipv4/Kconfig                   |  18 +
 net/ipv4/Makefile                  |   3 +-
 net/ipv4/tcp.c                     |  26 +-
 net/ipv4/tcp_bbr.c                 | 875 +++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_cdg.c                 |  12 +-
 net/ipv4/tcp_cong.c                |   2 +-
 net/ipv4/tcp_input.c               | 154 +++----
 net/ipv4/tcp_minisocks.c           |   5 +-
 net/ipv4/tcp_output.c              |  27 +-
 net/ipv4/tcp_rate.c                | 186 ++++++++
 net/sched/sch_fq.c                 |  22 +-
 20 files changed, 1449 insertions(+), 107 deletions(-)
 create mode 100644 include/linux/win_minmax.h
 create mode 100644 lib/win_minmax.c
 create mode 100644 net/ipv4/tcp_bbr.c
 create mode 100644 net/ipv4/tcp_rate.c

-- 
2.8.0.rc3.226.g39d4020
