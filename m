From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/4] tcp: tsq: performance series
Date: Fri,  2 Dec 2016 10:25:55 -0800
Message-ID: <1480703159-2327-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:35067 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752152AbcLBS1b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:27:31 -0500
Received: by mail-pg0-f52.google.com with SMTP id p66so110021270pga.2
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 10:26:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under very high TX stress, CPU handling NIC TX completions can spend
considerable amount of cycles handling TSQ (TCP Small Queues) logic.

This patch series avoids some atomic operations, but more important
patch is the 3rd one, allowing other cpus processing ACK packets and
calling tcp_write_xmit() to grab TCP_TSQ_DEFERRED so that
tcp_tasklet_func() can skip already processed sockets.

This avoid lots of lock acquisitions and cache lines accesses,
particularly under load.

Eric Dumazet (4):
  tcp: tsq: add tsq_flags / tsq_enum
  tcp: tsq: remove one locked operation in tcp_wfree()
  tcp: tsq: add shortcut in tcp_tasklet_func()
  tcp: tsq: avoid one atomic in tcp_wfree()

 include/linux/tcp.h   | 11 ++++++++++-
 net/ipv4/tcp_output.c | 54 +++++++++++++++++++++++++++++++--------------------
 2 files changed, 43 insertions(+), 22 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
