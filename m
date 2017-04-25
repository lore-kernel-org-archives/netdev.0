From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 00/10] tcp: do not use tcp_time_stamp for rcv autotuning
Date: Tue, 25 Apr 2017 10:15:31 -0700
Message-ID: <20170425171541.3417-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:37159 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951777AbdDYRPu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:15:50 -0400
Received: by mail-it0-f49.google.com with SMTP id x188so80274110itb.0
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:15:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some devices or linux distributions use HZ=100 or HZ=250

TCP receive buffer autotuning has poor behavior caused by this choice.
Since autotuning happens after 4 ms or 10 ms, short distance flows
get their receive buffer tuned to a very high value, but after an initial
period where it was frozen to (too small) initial value.

With BBR (or other CC allowing to increase BDP), we are willing to
increase tcp_rmem[2], but this receive autotuning defect is a blocker
for hosts dealing with gazillions of TCP flows in the data centers,
since many of them have inflated RCVBUF. Risk of OOM is too high.

Note that TSO autodefer, tcp cubic, and TCP TS options (RFC 7323)
also suffer from our dependency to jiffies (via tcp_time_stamp).

We have ongoing efforts to improve all that in the future.

Eric Dumazet (10):
  tcp: add tp->tcp_mstamp field
  tcp: do not pass timestamp to tcp_rack_detect_loss()
  tcp: do not pass timestamp to tcp_rack_mark_lost()
  tcp: do not pass timestamp to tcp_rack_identify_loss()
  tcp: do not pass timestamp to tcp_fastretrans_alert()
  tcp: do not pass timestamp to tcp_rate_gen()
  tcp: do not pass timestamp to tcp_rack_advance()
  tcp: use tp->tcp_mstamp in tcp_clean_rtx_queue()
  tcp: remove ack_time from struct tcp_sacktag_state
  tcp: switch rcv_rtt_est and rcvq_space to high resolution timestamps

 include/linux/tcp.h     | 13 +++++-----
 include/net/tcp.h       |  7 +++--
 net/ipv4/tcp.c          |  2 +-
 net/ipv4/tcp_input.c    | 69 +++++++++++++++++++++++--------------------------
 net/ipv4/tcp_rate.c     |  7 ++---
 net/ipv4/tcp_recovery.c | 18 +++++--------
 6 files changed, 55 insertions(+), 61 deletions(-)

-- 
2.13.0.rc0.306.g87b477812d-goog
