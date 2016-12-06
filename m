From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH net-next 1/1] driver: ipvlan: Free the port memory
 directly with kfree instead of kfree_rcu
Date: Tue, 6 Dec 2016 14:31:57 +0800
Message-ID: <CA+6hz4pGw-+HvKVDCiFmXRd6YwioUXdZfOghtx0aFb6EPxcj5A@mail.gmail.com>
References: <1480998547-9013-1-git-send-email-fgao@ikuai8.com> <1481005511.18162.564.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgau1.qq.com ([54.206.16.166]:49185 "EHLO smtpbgau1.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751180AbcLFGea (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 01:34:30 -0500
Received: from mail-ua0-f175.google.com (unknown [209.85.217.175])
        by esmtp4.qq.com (ESMTP) with SMTP id 0
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 14:31:59 +0800 (CST)
Received: by mail-ua0-f175.google.com with SMTP id 20so372427456uak.0
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 22:32:00 -0800 (PST)
In-Reply-To: <1481005511.18162.564.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Tue, Dec 6, 2016 at 2:25 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2016-12-06 at 12:29 +0800, fgao@ikuai8.com wrote:
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> There is no one which may reference the "port" in ipvlan_port_create
>> when netdev_rx_handler_register failed. So it could free it directly
>> with kfree instead of kfree_rcu.
>>
>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>> ---
>>  drivers/net/ipvlan/ipvlan_main.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
>> index c6aa667..1a601151 100644
>> --- a/drivers/net/ipvlan/ipvlan_main.c
>> +++ b/drivers/net/ipvlan/ipvlan_main.c
>> @@ -128,7 +128,7 @@ static int ipvlan_port_create(struct net_device *dev)
>>       return 0;
>>
>>  err:
>> -     kfree_rcu(port, rcu);
>> +     kfree(port);
>>       return err;
>>  }
>>
>
> This looks a partial patch.
>
> If you really care, why don't you also replace the kfree_rcu() in
> ipvlan_port_destroy() ?

Because I don't fully hold the ipvlan codes now, I am afraid of that
there is someone which may get the port address when
ipvlan_port_destroy. So the original ipvlan_port_destroy uses the
kfree_rcu to avoid it.

I am sure there is unnecessary to use kfree in ipvlan_port_create.

Regards
Feng

>
>
>
> diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
> index 05a62d2216c54651f6158c35d446d2e395b38dc3..031093e1c25f55244e6bdfde4ebeb65c0f2f10c1 100644
> --- a/drivers/net/ipvlan/ipvlan.h
> +++ b/drivers/net/ipvlan/ipvlan.h
> @@ -97,7 +97,6 @@ struct ipvl_port {
>         struct work_struct      wq;
>         struct sk_buff_head     backlog;
>         int                     count;
> -       struct rcu_head         rcu;
>  };
>
>  static inline struct ipvl_port *ipvlan_port_get_rcu(const struct net_device *d)
> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> index 5430460167b5e8945d29a3febdd324461bf5af5c..ffe8994e64fc1791ef07d80ad2340bc82d541bba 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -128,7 +128,7 @@ static int ipvlan_port_create(struct net_device *dev)
>         return 0;
>
>  err:
> -       kfree_rcu(port, rcu);
> +       kfree(port);
>         return err;
>  }
>
> @@ -145,7 +145,7 @@ static void ipvlan_port_destroy(struct net_device *dev)
>         netdev_rx_handler_unregister(dev);
>         cancel_work_sync(&port->wq);
>         __skb_queue_purge(&port->backlog);
> -       kfree_rcu(port, rcu);
> +       kfree(port);
>  }
>
>  #define IPVLAN_FEATURES \
>
>
>
