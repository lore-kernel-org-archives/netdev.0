From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 0/7] RACK loss detection
Date: Fri, 16 Oct 2015 21:57:40 -0700
Message-ID: <1445057867-32257-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35026 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbbJQE6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 00:58:03 -0400
Received: by payp3 with SMTP id p3so7576282pay.2
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 21:58:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RACK (Recent ACK) loss recovery uses the notion of time instead of
packet sequence (FACK) or counts (dupthresh).

It's inspired by the FACK heuristic in tcp_mark_lost_retrans(): when a
limited transmit (new data packet) is sacked in recovery, then any
retransmission sent before that newly sacked packet was sent must have
been lost, since at least one round trip time has elapsed.

But that existing heuristic from tcp_mark_lost_retrans()
has several limitations:
  1) it can't detect tail drops since it depends on limited transmit
  2) it's disabled upon reordering (assumes no reordering)
  3) it's only enabled in fast recovery but not timeout recovery

RACK addresses these limitations with a core idea: an unacknowledged
packet P1 is deemed lost if a packet P2 that was sent later is is
s/acked, since at least one round trip has passed.

Since RACK cares about the time sequence instead of the data sequence
of packets, it can detect tail drops when a later retransmission is
s/acked, while FACK or dupthresh can't. For reordering RACK uses a
dynamically adjusted reordering window ("reo_wnd") to reduce false
positives on ever (small) degree of reordering, similar to the delayed
Early Retransmit.

In the current patch set RACK is only a supplemental loss detection
and does not trigger fast recovery. However we are developing RACK
to replace or consolidate FACK/dupthresh, early retransmit, and
thin-dupack. These heuristics all implicitly bear the time notion.
For example, the delayed Early Retransmit is simply applying RACK
to trigger the fast recovery with small inflight.

RACK requires measuring the minimum RTT. Tracking a global min is less
robust due to traffic engineering pathing changes. Therefore it uses a
windowed filter by Kathleen Nichols. The min RTT can also be useful
for various other purposes like congestion control or stat monitoring.

This patch has been used on Google servers for well over 1 year. RACK
has also been implemented in the QUIC protocol. We are submitting an
IETF draft as well.

Yuchung Cheng (7):
  tcp: apply Kern's check on RTTs used for congestion control
  tcp: track min RTT using windowed min-filter
  tcp: remove tcp_mark_lost_retrans()
  tcp: add tcp_tsopt_ecr_before helper
  tcp: skb_mstamp_after helper
  tcp: track the packet timings in RACK
  tcp: use RACK to detect losses

 Documentation/networking/ip-sysctl.txt |  17 ++++
 include/linux/skbuff.h                 |   9 ++
 include/linux/tcp.h                    |  11 +-
 include/net/tcp.h                      |  21 ++++
 net/ipv4/Makefile                      |   1 +
 net/ipv4/sysctl_net_ipv4.c             |  14 +++
 net/ipv4/tcp.c                         |   1 +
 net/ipv4/tcp_input.c                   | 180 +++++++++++++++++++--------------
 net/ipv4/tcp_minisocks.c               |   3 +
 net/ipv4/tcp_output.c                  |   6 --
 net/ipv4/tcp_recovery.c                | 109 ++++++++++++++++++++
 11 files changed, 286 insertions(+), 86 deletions(-)
 create mode 100644 net/ipv4/tcp_recovery.c

-- 
2.6.0.rc2.230.g3dd15c0
