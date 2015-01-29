From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next v2 0/5] fix stretch ACK bugs in TCP CUBIC and Reno
Date: Wed, 28 Jan 2015 20:01:34 -0500
Message-ID: <1422493299-22114-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:39210 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbbA2BHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 20:07:21 -0500
Received: by mail-yk0-f181.google.com with SMTP id 79so10907691ykr.12
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 17:07:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series fixes the TCP CUBIC and Reno congestion control
modules to properly handle stretch ACKs in their respective additive
increase modes, and in the transitions from slow start to additive
increase.

This finishes the project started by commit 9f9843a751d0a2057 ("tcp:
properly handle stretch acks in slow start"), which fixed behavior for
TCP congestion control when handling stretch ACKs in slow start mode.

Motivation: In the Jan 2015 netdev thread 'BW regression after "tcp:
refine TSO autosizing"', Eyal Perry documented a regression that Eric
Dumazet determined was caused by improper handling of TCP stretch
ACKs.

Background: LRO, GRO, delayed ACKs, and middleboxes can cause "stretch
ACKs" that cover more than the RFC-specified maximum of 2
packets. These stretch ACKs can cause serious performance shortfalls
in common congestion control algorithms, like Reno and CUBIC, which
were designed and tuned years ago with receiver hosts that were not
using LRO or GRO, and were instead ACKing every other packet.

Testing: at Google we have been using this approach for handling
stretch ACKs for CUBIC datacenter and Internet traffic for several
years, with good results.

v2:
 * fixed return type of tcp_slow_start() to be u32 instead of int

Neal Cardwell (5):
  tcp: stretch ACK fixes prep
  tcp: fix the timid additive increase on stretch ACKs
  tcp: fix stretch ACK bugs in Reno
  tcp: fix stretch ACK bugs in CUBIC
  tcp: fix timing issue in CUBIC slope calculation

 include/net/tcp.h       |  4 ++--
 net/ipv4/tcp_bic.c      |  2 +-
 net/ipv4/tcp_cong.c     | 32 ++++++++++++++++++++------------
 net/ipv4/tcp_cubic.c    | 39 +++++++++++++++++----------------------
 net/ipv4/tcp_scalable.c |  3 ++-
 net/ipv4/tcp_veno.c     |  2 +-
 net/ipv4/tcp_yeah.c     |  2 +-
 7 files changed, 44 insertions(+), 40 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
