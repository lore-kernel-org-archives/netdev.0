From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net v3] net/mlx5e: Fix race in mlx5e_sw_stats and mlx5e_vport_stats
Date: Sat, 22 Apr 2017 03:24:16 +0300
Message-ID: <CALzJLG-TOt4A8jE8ghYR1FJtJXgYk4vvpE+q9MF7rqoseErrig@mail.gmail.com>
References: <20170421044012.1955130-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34438 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1042890AbdDVAYh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 20:24:37 -0400
Received: by mail-qk0-f193.google.com with SMTP id d80so9365214qke.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 17:24:37 -0700 (PDT)
In-Reply-To: <20170421044012.1955130-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 21, 2017 at 7:40 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> We have observed a sudden spike in rx/tx_packets and rx/tx_bytes
> reported under /proc/net/dev.  There is a race in mlx5e_update_stats()
> and some of the get-stats functions (the one that we hit is the
> mlx5e_get_stats() which is called by ndo_get_stats64()).
>
> In particular, the very first thing mlx5e_update_sw_counters()
> does is 'memset(s, 0, sizeof(*s))'.  For example, if mlx5e_get_stats()
> is unlucky at one point, rx_bytes and rx_packets could be 0.  One second
> later, a normal (and much bigger than 0) value will be reported.
>
> This patch is to use a 'struct mlx5e_sw_stats temp' to avoid
> a direct memset zero on priv->stats.sw.
>
> mlx5e_update_vport_counters() has a similar race.  Hence, addressed
> together.  However, memset zero is removed instead because
> it is not needed.
>
> I am lucky enough to catch this 0-reset in rx multicast:
> eth0: 41457665   76804   70    0    0    70          0     47085 15586634   87502    3    0    0     0       3          0
> eth0: 41459860   76815   70    0    0    70          0     47094 15588376   87516    3    0    0     0       3          0
> eth0: 41460577   76822   70    0    0    70          0         0 15589083   87521    3    0    0     0       3          0
> eth0: 41463293   76838   70    0    0    70          0     47108 15595872   87538    3    0    0     0       3          0
> eth0: 41463379   76839   70    0    0    70          0     47116 15596138   87539    3    0    0     0       3          0
>
> v2: Remove memset zero from mlx5e_update_vport_counters()
> v1: Use temp and memcpy
>
> Fixes: 9218b44dcc05 ("net/mlx5e: Statistics handling refactoring")
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Suggested-by: Saeed Mahameed <saeedm@mellanox.com>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> ---

Thank you Martin and Eric for the fix, we will follow up with the
spinlock fix soon.

Acked-by: Saeed Mahameed <saeedm@mellanox.com>
