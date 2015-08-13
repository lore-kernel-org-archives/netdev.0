From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH] net: allow sleeping when modifying store_rps_map
Date: Thu, 13 Aug 2015 11:46:19 -0700
Message-ID: <CALx6S36f+fcuOQ1jjWvMG-c13Umj50V0RNyVaT+R+HOLKR3RVQ@mail.gmail.com>
References: <1439488996-31227-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439488996-31227-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 13, 2015 at 11:03 AM, Sasha Levin <sasha.levin@oracle.com> wrote:
> Commit 10e4ea751 ("net: Fix race condition in store_rps_map") has moved the
> manipulation of the rps_needed jump label under a spinlock. Since changing
> the state of a jump label may sleep this is incorrect and causes warnings
> during runtime.
>
> Make rps_map_lock a mutex to allow sleeping under it.
>
> Fixes: 10e4ea751 ("net: Fix race condition in store_rps_map")
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  net/core/net-sysfs.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index 39ec694..b279077 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -689,7 +689,7 @@ static ssize_t store_rps_map(struct netdev_rx_queue *queue,
>         struct rps_map *old_map, *map;
>         cpumask_var_t mask;
>         int err, cpu, i;
> -       static DEFINE_SPINLOCK(rps_map_lock);
> +       static DEFINE_MUTEX(rps_map_mutex);
>
>         if (!capable(CAP_NET_ADMIN))
>                 return -EPERM;
> @@ -722,9 +722,9 @@ static ssize_t store_rps_map(struct netdev_rx_queue *queue,
>                 map = NULL;
>         }
>
> -       spin_lock(&rps_map_lock);
> +       mutex_lock(&rps_map_mutex);
>         old_map = rcu_dereference_protected(queue->rps_map,
> -                                           lockdep_is_held(&rps_map_lock));
> +                                           mutex_is_locked(&rps_map_mutex));
>         rcu_assign_pointer(queue->rps_map, map);
>
>         if (map)
> @@ -732,7 +732,7 @@ static ssize_t store_rps_map(struct netdev_rx_queue *queue,
>         if (old_map)
>                 static_key_slow_dec(&rps_needed);
>
> -       spin_unlock(&rps_map_lock);
> +       mutex_unlock(&rps_map_mutex);
>
>         if (old_map)
>                 kfree_rcu(old_map, rcu);
> --
> 1.7.10.4
>

Thanks Sasha!

Acked-by: Tom Herbert <tom@herbertland.com>
