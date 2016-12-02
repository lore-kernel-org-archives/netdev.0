From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Fri, 02 Dec 2016 06:23:17 -0800
Message-ID: <1480688597.18162.354.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20140903165943.372b897b@redhat.com>
         <20161117091638.5fab8494@redhat.com>
         <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
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
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Rick Jones <rick.jones2@hpe.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35175 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933132AbcLBOXU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 09:23:20 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so8070734pga.2
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 06:23:20 -0800 (PST)
In-Reply-To: <1480611857.18162.319.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-01 at 09:04 -0800, Eric Dumazet wrote:
> On Thu, 2016-12-01 at 17:04 +0100, Jesper Dangaard Brouer wrote:
> 
> > I think you misunderstood my concept[1].  I don't want to stop the
> > queue. The new __QUEUE_STATE_FLUSH_NEEDED does not stop the queue, is
> > it just indicating that someone need to flush/ring-doorbell.  Maybe it
> > need another name, because it also indicate that the driver can see
> > that its TX queue is so busy that we don't need to call it immediately.
> > The qdisc layer can then choose to enqueue instead if doing direct xmit.
> 
> But driver ndo_start_xmit() does not have a pointer to qdisc.
> 
> Also the concept of 'queue busy' just because we queued one packet is a
> bit flaky.
> 
> > 
> > When qdisc layer or trafgen/af_packet see this indication it knows it
> > should/must flush the queue when it don't have more work left.  Perhaps
> > through net_tx_action(), by registering itself and e.g. if qdisc_run()
> > is called and queue is empty then check if queue needs a flush. I would
> > also allow driver to flush and clear this bit.
> 
> net_tx_action() is not normally called, unless BQL limit is hit and/or
> some qdiscs with throttling (HTB, TBF, FQ, ...)
> 
> > 
> > I just see it as an extension of your solution, as we still need the
> > driver to figure out then the doorbell/flush can be delayed.
> > p.s. don't be discouraged by this feedback, I'm just very excited and
> > happy that your are working on a solution in this area. As this is a
> > problem area that I've not been able to solve myself for the last
> > approx 2 years. Keep up the good work!
> 
> Do not worry, I appreciate the feedbacks ;)
> 
> BTW, if you are doing tests on mlx4 40Gbit, would you check the
> following quick/dirty hack, using lots of low-rate flows ?
> 
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


Sorry, stupid typo.
This should be "features &= ~NETIF_F_GSO_MASK;" of course

>  
>         return features;
>  }
> 
> 
> 
> 
