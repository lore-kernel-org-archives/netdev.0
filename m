From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next 0/5] fix stretch ACK bugs in TCP CUBIC and Reno
Date: Tue, 27 Jan 2015 15:34:38 -0500
Message-ID: <1422390883-15603-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f50.google.com ([209.85.213.50]:54760 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759970AbbA0Ue5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 15:34:57 -0500
Received: by mail-yh0-f50.google.com with SMTP id t59so7034229yho.9
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 12:34:56 -0800 (PST)
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

Neal Cardwell (5):
  tcp: stretch ACK fixes prep
  tcp: fix the timid additive increase on stretch ACKs
  tcp: fix stretch ACK bugs in Reno
  tcp: fix stretch ACK bugs in CUBIC
  tcp: fix timing issue in CUBIC slope calculation

 include/net/tcp.h       |  4 ++--
 net/ipv4/tcp_bic.c      |  2 +-
 net/ipv4/tcp_cong.c     | 32 ++++++++++++++++++++------------
 net/ipv4/tcp_cubic.c    | 38 +++++++++++++++++---------------------
 net/ipv4/tcp_scalable.c |  3 ++-
 net/ipv4/tcp_veno.c     |  2 +-
 net/ipv4/tcp_yeah.c     |  2 +-
 7 files changed, 44 insertions(+), 39 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
