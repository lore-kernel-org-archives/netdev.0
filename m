From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Thu, 1 Dec 2016 20:17:07 +0100
Message-ID: <20161201201707.5f51a02e@redhat.com>
References: <20140903165943.372b897b@redhat.com>
        <20161117144248.23500001@redhat.com>
        <1479392258.8455.249.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117155753.17b76f5a@redhat.com>
        <1479399679.8455.255.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117193021.580589ae@redhat.com>
        <1479408683.8455.273.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161121170351.50a09ee1@redhat.com>
        <1479751857.8455.419.camel@edumazet-glaptop3.roam.corp.google.com>
        <1480402716.18162.124.camel@edumazet-glaptop3.roam.corp.google.com>
        <CALzJLG_G3G-_jFFD0xiAOfR-k69rhb_2ia4LHZroE-oEFxApnQ@mail.gmail.com>
        <1480520661.18162.177.camel@edumazet-glaptop3.roam.corp.google.com>
        <CALzJLG9iCWkk2WTGrkFhZ61Sx5R-JDCxANhLQZPO8E47QGwOmQ@mail.gmail.com>
        <20161201130505.0b4a5cd5@redhat.com>
        <1480602274.18162.285.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161201170443.28a8c032@redhat.com>
        <1480611857.18162.319.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Rick Jones <rick.jones2@hpe.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47500 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758489AbcLATRM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Dec 2016 14:17:12 -0500
In-Reply-To: <1480611857.18162.319.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 01 Dec 2016 09:04:17 -0800 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> BTW, if you are doing tests on mlx4 40Gbit,

I'm mostly testing with mlx5 50Gbit, but I do have 40G NIC in the
machines too.

>  would you check the
> following quick/dirty hack, using lots of low-rate flows ?

What tool should I use to send "low-rate flows"?

And what am I looking for?

> mlx4 has really hard time to transmit small TSO packets (2 or 3 MSS)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 12ea3405f442..96940666abd3 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -2631,6 +2631,11 @@ static void mlx4_en_del_vxlan_port(struct  net_device *dev,
>         queue_work(priv->mdev->workqueue, &priv->vxlan_del_task);
>  }
>  
> +static int mlx4_gso_segs_min = 4; /* TSO packets with less than 4 segments are segmented */
> +module_param_named(mlx4_gso_segs_min, mlx4_gso_segs_min, uint, 0644);
> +MODULE_PARM_DESC(mlx4_gso_segs_min, "threshold for software segmentation of small TSO packets");
> +
> +
>  static netdev_features_t mlx4_en_features_check(struct sk_buff *skb,
>                                                 struct net_device *dev,
>                                                 netdev_features_t features)
> @@ -2651,6 +2656,8 @@ static netdev_features_t mlx4_en_features_check(struct sk_buff *skb,
>                     (udp_hdr(skb)->dest != priv->vxlan_port))
>                         features &= ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
>         }
> +       if (skb_is_gso(skb) && skb_shinfo(skb)->gso_segs < mlx4_gso_segs_min)
> +               features &= NETIF_F_GSO_MASK;
>  
>         return features;
>  }
 

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
