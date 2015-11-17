From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/9] net: extend busy polling support
Date: Tue, 17 Nov 2015 05:56:55 -0800
Message-ID: <1447768624-14962-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>, Eli Cohen <eli@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>,
	Rida Assaf <rida@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33182 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975AbbKQN5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 08:57:15 -0500
Received: by pabfh17 with SMTP id fh17so10398790pab.0
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 05:57:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series extends busy polling range to tunnels devices,
and allows NAPI drivers to support busy polling with trivial changes.

No need to provide ndo_busy_poll() method and extra synchronization
between ndo_busy_poll() and normal napi->poll() method. This was proven
very difficult and bug prone.

mlx5 driver is changed to support busy polling using this new method,
and a second mlx5 patch adds napi_complete_done() support and proper
SNMP accounting.

bnx2x and mlx4 drivers are converted to new infrastructure,
reducing kernel bloat and improving performance.

Eric Dumazet (9):
  net: better skb->sender_cpu and skb->napi_id cohabitation
  mlx4: mlx4_en_low_latency_recv() called with BH disabled
  net: un-inline sk_busy_loop()
  net: allow BH servicing in sk_busy_loop()
  net: network drivers no longer need to implement ndo_busy_poll()
  mlx5: add busy polling support
  mlx5: support napi_complete_done()
  bnx2x: remove bnx2x_low_latency_recv() support
  mlx4: remove mlx4_en_low_latency_recv()

 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h       | 113 -------------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c   |  46 +-------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h   |   7 --
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |   3 -
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c   |  17 ---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |  40 -------
 drivers/net/ethernet/mellanox/mlx4/en_rx.c        |  15 +--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      | 126 ----------------------
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   6 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |  16 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c |  11 +-
 include/linux/netdevice.h                         |   9 --
 include/linux/skbuff.h                            |   3 -
 include/net/busy_poll.h                           |  45 +-------
 net/core/dev.c                                    |  91 ++++++++++++----
 16 files changed, 98 insertions(+), 452 deletions(-)

-- 
2.6.0.rc2.230.g3dd15c0
