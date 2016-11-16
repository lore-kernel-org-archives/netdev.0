From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 0/5] net: busy-poll: allow preemption and other
 optimizations
Date: Wed, 16 Nov 2016 10:03:43 -0800
Message-ID: <582C9F7F.2070807@gmail.com>
References: <1479233715-9905-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Adam Belay <abelay@google.com>, Zach Brown <zach.brown@ni.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35578 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752945AbcKPSEH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 13:04:07 -0500
Received: by mail-pg0-f66.google.com with SMTP id p66so15281590pga.2
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 10:04:06 -0800 (PST)
In-Reply-To: <1479233715-9905-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-15 10:15 AM, Eric Dumazet wrote:
> It is time to have preemption points in sk_busy_loop() and improve
> its scalability.
> 
> Also napi_complete() and friends can tell drivers when it is safe to
> not re-enable device interrupts, saving some overhead under
> high busy polling.
> 
> mlx4 and bnx2x are changed accordingly, to show how this busy polling
> status can be exploited by drivers.
> 
> Next steps will implement Zach Brown suggestion, where NAPI polling
> would be enabled all the time for some chosen queues.
> This is needed for efficient epoll() support anyway.

Would you expect to make this a per queue option of the hardware
configured via ethtool/netlink/sysfs and like where users steer traffic
to particular queues using existing ntuple filters or 'tc' or infer it
from the socket layer?

So configuration would be (a) enable busy-polling on queues x,y,z and
then (b) use ntuple/RSS/etc to steer relative traffic to queues. In
this case traffic doesn't need to be bound to a socket in any way.
Seems like a useful generalization.

Thanks,
John

> 
> Eric Dumazet (5):
>   net: busy-poll: allow preemption in sk_busy_loop()
>   net: busy-poll: remove need_resched() from sk_can_busy_loop()
>   net: busy-poll: return busypolling status to drivers
>   net/mlx4_en: use napi_complete_done() return value
>   bnx2x: switch to napi_complete_done()
> 
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |  15 ++--
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c      |   4 +-
>  include/linux/netdevice.h                       |  17 +++-
>  include/net/busy_poll.h                         |   5 +-
>  net/core/dev.c                                  | 110 +++++++++++++++++++-----
>  5 files changed, 113 insertions(+), 38 deletions(-)
> 
