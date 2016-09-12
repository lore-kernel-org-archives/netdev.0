From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC V3 PATCH 18/26] net/netpolicy: set tx queues according to policy
Date: Mon, 12 Sep 2016 13:23:24 -0700
Message-ID: <CALx6S36C3cJvH==e3FVf5jox=-OqEziEQTXvr8hmqshMgbGd8w@mail.gmail.com>
References: <1473692159-4017-1-git-send-email-kan.liang@intel.com> <1473692159-4017-19-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Ingo Molnar <mingo@redhat.com>, peterz@infradead.org,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, akpm@linux-foundation.org,
        Kees Cook <keescook@chromium.org>, viro@zeniv.linux.org.uk,
        gorcunov@openvz.org, John Stultz <john.stultz@linaro.org>,
        Alexander Duyck <aduyck@mirantis.com>,
        Ben Hutchings <ben@decadent.org.uk>,
        David Decotigny <decot@googlers.com>,
        Florian Westphal <fw@strlen.de>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>, r
To: "Liang, Kan" <kan.liang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33518 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750832AbcILUXZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 16:23:25 -0400
Received: by mail-qt0-f193.google.com with SMTP id p47so613747qtc.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 13:23:25 -0700 (PDT)
In-Reply-To: <1473692159-4017-19-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 12, 2016 at 7:55 AM,  <kan.liang@intel.com> wrote:
> From: Kan Liang <kan.liang@intel.com>
>
> When the device tries to transmit a packet, netdev_pick_tx is called to
> find the available tx queues. If the net policy is applied, it picks up
> the assigned tx queue from net policy subsystem, and redirect the
> traffic to the assigned queue.
>
> Signed-off-by: Kan Liang <kan.liang@intel.com>
> ---
>  include/net/sock.h |  9 +++++++++
>  net/core/dev.c     | 20 ++++++++++++++++++--
>  2 files changed, 27 insertions(+), 2 deletions(-)
>
> diff --git a/include/net/sock.h b/include/net/sock.h
> index e1e9e3d..ca97f35 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -2280,4 +2280,13 @@ extern int sysctl_optmem_max;
>  extern __u32 sysctl_wmem_default;
>  extern __u32 sysctl_rmem_default;
>
> +/* Return netpolicy instance information from socket. */
> +static inline struct netpolicy_instance *netpolicy_find_instance(struct sock *sk)
> +{
> +#ifdef CONFIG_NETPOLICY
> +       if (is_net_policy_valid(sk->sk_netpolicy.policy))
> +               return &sk->sk_netpolicy;
> +#endif
> +       return NULL;
> +}
>  #endif /* _SOCK_H */
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 34b5322..b9a8044 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3266,6 +3266,7 @@ struct netdev_queue *netdev_pick_tx(struct net_device *dev,
>                                     struct sk_buff *skb,
>                                     void *accel_priv)
>  {
> +       struct sock *sk = skb->sk;
>         int queue_index = 0;
>
>  #ifdef CONFIG_XPS
> @@ -3280,8 +3281,23 @@ struct netdev_queue *netdev_pick_tx(struct net_device *dev,
>                 if (ops->ndo_select_queue)
>                         queue_index = ops->ndo_select_queue(dev, skb, accel_priv,
>                                                             __netdev_pick_tx);
> -               else
> -                       queue_index = __netdev_pick_tx(dev, skb);
> +               else {
> +#ifdef CONFIG_NETPOLICY
> +                       struct netpolicy_instance *instance;
> +
> +                       queue_index = -1;
> +                       if (dev->netpolicy && sk) {
> +                               instance = netpolicy_find_instance(sk);
> +                               if (instance) {
> +                                       if (!instance->dev)
> +                                               instance->dev = dev;
> +                                       queue_index = netpolicy_pick_queue(instance, false);
> +                               }
> +                       }
> +                       if (queue_index < 0)
> +#endif

I doubt this produces the intended effect. Several drivers use
ndo_select_queue (such as mlx4) where there might do something special
for a few packets but end up called the default handler which
__netdev_pick_tx for most packets. So in such cases the netpolicy path
would be routinely bypassed. Maybe this code should be in
__netdev_pick_tx.

Tom

> +                               queue_index = __netdev_pick_tx(dev, skb);
> +               }
>
>                 if (!accel_priv)
>                         queue_index = netdev_cap_txqueue(dev, queue_index);
> --
> 2.5.5
>
