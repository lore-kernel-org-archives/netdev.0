From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 0/8] tcp: tsq: performance series
Date: Sat,  3 Dec 2016 11:14:49 -0800
Message-ID: <1480792497-16607-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:36249 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750960AbcLCTXq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 14:23:46 -0500
Received: by mail-pg0-f46.google.com with SMTP id f188so119750892pgc.3
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 11:23:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under very high TX stress, CPU handling NIC TX completions can spend
considerable amount of cycles handling TSQ (TCP Small Queues) logic.

This patch series avoids some atomic operations, but most notable
patch is the 3rd one, allowing other cpus processing ACK packets and
calling tcp_write_xmit() to grab TCP_TSQ_DEFERRED so that
tcp_tasklet_func() can skip already processed sockets.

This avoid lots of lock acquisitions and cache lines accesses,
particularly under load.

In v2, I added :

- tcp_small_queue_check() change to allow 1st and 2nd packets
  in write queue to be sent, even in the case TX completion of
  already acknowledged packets did not happen yet.
  This helps when TX completion coalescing parameters are set
  even to insane values, and/or busy polling is used.

- A reorganization of struct sock fields to
  lower false sharing and increase data locality.

- Then I moved tsq_flags from tcp_sock to struct sock also
  to reduce cache line misses during TX completions.

I measured an overall throughput gain of 22 % for heavy TCP use
over a single TX queue.

Eric Dumazet (8):
  tcp: tsq: add tsq_flags / tsq_enum
  tcp: tsq: remove one locked operation in tcp_wfree()
  tcp: tsq: add shortcut in tcp_tasklet_func()
  tcp: tsq: avoid one atomic in tcp_wfree()
  tcp: tsq: add a shortcut in tcp_small_queue_check()
  tcp: tcp_mtu_probe() is likely to exit early
  net: reorganize struct sock for better data locality
  tcp: tsq: move tsq_flags close to sk_wmem_alloc

 include/linux/tcp.h   | 12 +++++--
 include/net/sock.h    | 51 +++++++++++++++--------------
 net/ipv4/tcp.c        |  4 +--
 net/ipv4/tcp_ipv4.c   |  2 +-
 net/ipv4/tcp_output.c | 91 +++++++++++++++++++++++++++++++--------------------
 net/ipv4/tcp_timer.c  |  4 +--
 net/ipv6/tcp_ipv6.c   |  2 +-
 7 files changed, 98 insertions(+), 68 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
