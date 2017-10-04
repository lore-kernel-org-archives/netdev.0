From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 0/3] tcp: improving RACK cpu performance
Date: Wed,  4 Oct 2017 12:59:57 -0700
Message-ID: <20171004200000.39257-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:52341 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750797AbdJDUAS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 16:00:18 -0400
Received: by mail-pg0-f46.google.com with SMTP id i195so7058464pgd.9
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 13:00:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch set improves the CPU consumption of the RACK TCP loss
recovery algorithm, in particular for high-speed networks. Currently,
for every ACK in recovery RACK can potentially iterate over all sent
packets in the write queue. On large BDP networks with non-trivial
losses the RACK write queue walk CPU usage becomes unreasonably high.

This patch introduces a new queue in TCP that keeps only skbs sent and
not yet (s)acked or marked lost, in time order instead of sequence
order.  With that, RACK can examine this time-sorted list and only
check packets that were sent recently, within the reordering window,
per ACK. This is the fastest way without any write queue walks. The
number of skbs examined per ACK is reduced by orders of magnitude.


Eric Dumazet (1):
  tcp: new list for sent but unacked skbs for RACK recovery

Yuchung Cheng (2):
  tcp: more efficient RACK loss detection
  tcp: a small refactor of RACK loss detection

 include/linux/skbuff.h   | 11 ++++++++--
 include/linux/tcp.h      |  1 +
 include/net/tcp.h        | 24 +++++++++++++++++++++-
 net/ipv4/tcp.c           |  2 ++
 net/ipv4/tcp_input.c     |  9 +++++++--
 net/ipv4/tcp_minisocks.c |  1 +
 net/ipv4/tcp_output.c    | 42 ++++++++++++++++++++++++++++----------
 net/ipv4/tcp_recovery.c  | 52 ++++++++++++++++++------------------------------
 8 files changed, 93 insertions(+), 49 deletions(-)

-- 
2.14.2.920.gcf0c67979c-goog
