From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/5] net: busy-poll: allow preemption and other optimizations
Date: Tue, 15 Nov 2016 10:15:10 -0800
Message-ID: <1479233715-9905-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Adam Belay <abelay@google.com>, Zach Brown <zach.brown@ni.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:35756 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932951AbcKOSPu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 13:15:50 -0500
Received: by mail-pg0-f51.google.com with SMTP id p66so69154418pga.2
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 10:15:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is time to have preemption points in sk_busy_loop() and improve
its scalability.

Also napi_complete() and friends can tell drivers when it is safe to
not re-enable device interrupts, saving some overhead under
high busy polling.

mlx4 and bnx2x are changed accordingly, to show how this busy polling
status can be exploited by drivers.

Next steps will implement Zach Brown suggestion, where NAPI polling
would be enabled all the time for some chosen queues.
This is needed for efficient epoll() support anyway.

Eric Dumazet (5):
  net: busy-poll: allow preemption in sk_busy_loop()
  net: busy-poll: remove need_resched() from sk_can_busy_loop()
  net: busy-poll: return busypolling status to drivers
  net/mlx4_en: use napi_complete_done() return value
  bnx2x: switch to napi_complete_done()

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |  15 ++--
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |   4 +-
 include/linux/netdevice.h                       |  17 +++-
 include/net/busy_poll.h                         |   5 +-
 net/core/dev.c                                  | 110 +++++++++++++++++++-----
 5 files changed, 113 insertions(+), 38 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
