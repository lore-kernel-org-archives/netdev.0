From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 00/15] tcp: TCP TS option use 1 ms clock
Date: Tue, 16 May 2017 13:59:59 -0700
Message-ID: <20170516210014.31176-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:32868 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750775AbdEPV1v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 17:27:51 -0400
Received: by mail-pf0-f169.google.com with SMTP id e193so86496353pfh.0
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 14:27:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP Timestamps option is defined in RFC 7323

Traditionally on linux, it has been tied to the internal
'jiffy' variable, because it had been a cheap and good enough
generator.

Unfortunately some distros use HZ=250 or even HZ=100 leading
to not very useful TCP timestamps.

For TCP flows in the DC, Google has used usec resolution for more
than two years with great success [1].
RCVBUF autotuning is more precise.

This series converts tp->tcp_mstamp to a plain u64 value storing
a 1 usec TCP clock.

This choice will allow us to upstream the 1 usec TS option as
discussed in IETF 97.

Kathleen Nichols [2] and others advocate for 1ms TS clocks for
network analysis. (1ms being the lowest value supported by RFC 7323.)

[1] https://www.ietf.org/proceedings/97/slides/slides-97-tcpm-tcp-options-for-low-latency-00.pdf
[2] http://netseminar.stanford.edu/seminars/02_02_17.pdf

Eric Dumazet (15):
  tcp: use tp->tcp_mstamp in output path
  tcp: introduce tcp_jiffies32
  dccp: do not use tcp_time_stamp
  tcp: use tcp_jiffies32 to feed tp->lsndtime
  tcp: use tcp_jiffies32 to feed tp->snd_cwnd_stamp
  tcp_bbr: use tcp_jiffies32 instead of tcp_time_stamp
  tcp: bic,cubic: use tcp_jiffies32 instead of tcp_time_stamp
  tcp: use tcp_jiffies32 for rcv_tstamp and lrcvtime
  tcp: use tcp_jiffies32 to feed probe_timestamp
  tcp: uses jiffies_32 to feed tp->chrono_start
  tcp: use tcp_jiffies32 in __tcp_oow_rate_limited()
  tcp_westwood: use tcp_jiffies32 instead of tcp_time_stamp
  tcp_lp: cache tcp_time_stamp
  tcp: replace misc tcp_time_stamp to tcp_jiffies32
  tcp: switch TCP TS option (RFC 7323) to 1ms clock

 include/linux/skbuff.h           |  62 +------------------
 include/linux/tcp.h              |  22 +++----
 include/net/tcp.h                |  74 ++++++++++++++++++-----
 net/dccp/ccids/ccid2.c           |   8 +--
 net/dccp/ccids/ccid2.h           |   2 +-
 net/ipv4/syncookies.c            |   8 +--
 net/ipv4/tcp.c                   |  10 ++--
 net/ipv4/tcp_bbr.c               |  34 +++++------
 net/ipv4/tcp_bic.c               |   6 +-
 net/ipv4/tcp_cubic.c             |  14 ++---
 net/ipv4/tcp_htcp.c              |   2 +-
 net/ipv4/tcp_input.c             | 126 +++++++++++++++++++--------------------
 net/ipv4/tcp_ipv4.c              |  16 ++---
 net/ipv4/tcp_lp.c                |  17 +++---
 net/ipv4/tcp_metrics.c           |   2 +-
 net/ipv4/tcp_minisocks.c         |   8 +--
 net/ipv4/tcp_output.c            |  51 ++++++++--------
 net/ipv4/tcp_rate.c              |  16 ++---
 net/ipv4/tcp_recovery.c          |  24 ++++----
 net/ipv4/tcp_timer.c             |  17 +++---
 net/ipv4/tcp_westwood.c          |   6 +-
 net/ipv6/syncookies.c            |   2 +-
 net/ipv6/tcp_ipv6.c              |   4 +-
 net/netfilter/nf_synproxy_core.c |   2 +-
 24 files changed, 259 insertions(+), 274 deletions(-)

-- 
2.13.0.303.g4ebf302169-goog
