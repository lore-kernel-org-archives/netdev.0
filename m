From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next] bonding: add bond_tx_drop() helper
Date: Fri, 31 Oct 2014 12:30:32 -0700
Message-ID: <CAF2d9jinGFiLCQecdb2GZhM-_REUo0yw0YP+brJb2zU_Npp-mg@mail.gmail.com>
References: <1414781274.27538.32.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:40908 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755891AbaJaTay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 15:30:54 -0400
Received: by mail-qg0-f41.google.com with SMTP id q107so6221152qgd.28
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2014 12:30:53 -0700 (PDT)
In-Reply-To: <1414781274.27538.32.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 31, 2014 at 11:47 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> From: Eric Dumazet <edumazet@google.com>
>
> Because bonding stats are usually sum of slave stats, it was
> not easy to account for tx drops at bonding layer.
>
> We can use dev->tx_dropped for this, as this counter is later
> added to the device stats (in dev_get_stats())
>
> This extends the idea we had in commit ee6377147409a ("bonding: Simplify
> the xmit function for modes that use xmit_hash") for bond_3ad_xor_xmit()
> to other bonding modes.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Mahesh Bandewar <maheshb@google.com>
>
> ---
>  drivers/net/bonding/bond_alb.c  |    2 +-
>  drivers/net/bonding/bond_main.c |   15 +++++++--------
>  drivers/net/bonding/bonding.h   |    6 ++++++
>  3 files changed, 14 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index d2eadab787c55d8fc0f361755409a880d64abfb3..baa58e79256a8b804e6ab683af6665f0730b86de 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -1326,7 +1326,7 @@ static int bond_do_alb_xmit(struct sk_buff *skb, struct bonding *bond,
>         }
>
>         /* no suitable interface, frame not sent */
> -       dev_kfree_skb_any(skb);
> +       bond_tx_drop(bond->dev, skb);
>  out:
>         return NETDEV_TX_OK;
>  }
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index c9ac06cfe6b7b3a8f62568b70a6ad6d7ca9b44d0..c7520082fb0d7bfbc34ac00b4f4186a30197ad74 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3522,7 +3522,7 @@ static void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int sl
>                 }
>         }
>         /* no slave that can tx has been found */
> -       dev_kfree_skb_any(skb);
> +       bond_tx_drop(bond->dev, skb);
>  }
>
>  /**
> @@ -3584,7 +3584,7 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
>                         slave_id = bond_rr_gen_slave_id(bond);
>                         bond_xmit_slave_id(bond, skb, slave_id % slave_cnt);
>                 } else {
> -                       dev_kfree_skb_any(skb);
> +                       bond_tx_drop(bond_dev, skb);
>                 }
>         }
>
> @@ -3603,7 +3603,7 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
>         if (slave)
>                 bond_dev_queue_xmit(bond, skb, slave->dev);
>         else
> -               dev_kfree_skb_any(skb);
> +               bond_tx_drop(bond_dev, skb);
>
>         return NETDEV_TX_OK;
>  }
> @@ -3747,8 +3747,7 @@ int bond_3ad_xor_xmit(struct sk_buff *skb, struct net_device *dev)
>                 slave = slaves->arr[bond_xmit_hash(bond, skb) % count];
>                 bond_dev_queue_xmit(bond, skb, slave->dev);
>         } else {
> -               dev_kfree_skb_any(skb);
> -               atomic_long_inc(&dev->tx_dropped);
> +               bond_tx_drop(dev, skb);
>         }
>
>         return NETDEV_TX_OK;
> @@ -3778,7 +3777,7 @@ static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
>         if (slave && bond_slave_is_up(slave) && slave->link == BOND_LINK_UP)
>                 bond_dev_queue_xmit(bond, skb, slave->dev);
>         else
> -               dev_kfree_skb_any(skb);
> +               bond_tx_drop(bond_dev, skb);
>
>         return NETDEV_TX_OK;
>  }
> @@ -3858,7 +3857,7 @@ static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_device *dev
>                 /* Should never happen, mode already checked */
>                 netdev_err(dev, "Unknown bonding mode %d\n", BOND_MODE(bond));
>                 WARN_ON_ONCE(1);
> -               dev_kfree_skb_any(skb);
> +               bond_tx_drop(dev, skb);
>                 return NETDEV_TX_OK;
>         }
>  }
> @@ -3878,7 +3877,7 @@ static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
>         if (bond_has_slaves(bond))
>                 ret = __bond_start_xmit(skb, dev);
>         else
> -               dev_kfree_skb_any(skb);
> +               bond_tx_drop(dev, skb);
>         rcu_read_unlock();
>
>         return ret;
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
> index 10920f0686e2f0222203359751581d1b728c6617..bfb0b51c081a27fbbbe64deda058f70860aac49d 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -645,4 +645,10 @@ extern struct bond_parm_tbl ad_select_tbl[];
>  /* exported from bond_netlink.c */
>  extern struct rtnl_link_ops bond_link_ops;
>
> +static inline void bond_tx_drop(struct net_device *dev, struct sk_buff *skb)
> +{
> +       atomic_long_inc(&dev->tx_dropped);
> +       dev_kfree_skb_any(skb);
> +}
> +
>  #endif /* _LINUX_BONDING_H */
>
Nice and simple. Thanks Eric

Acked-by: Mahesh Bandewar <maheshb@google.com>
