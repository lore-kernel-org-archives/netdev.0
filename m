From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next 02/10] switchdev: introduce transaction item
 queue for attr_set and obj_add
Date: Tue, 22 Sep 2015 09:10:24 -0700
Message-ID: <CAE4R7bCycFZ0XrhGy0DR9jxb+s=SgrM2GAvLcNfSZdQUFDAJgA@mail.gmail.com>
References: <1442930031-4732-1-git-send-email-jiri@resnulli.us> <1442930031-4732-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"Rosen, Rami" <rami.rosen@intel.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:35505 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758788AbbIVQKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 12:10:44 -0400
Received: by oiww128 with SMTP id w128so8190308oiw.2
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 09:10:43 -0700 (PDT)
In-Reply-To: <1442930031-4732-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 22, 2015 at 6:53 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Now, the memory allocation in prepare/commit state is done separatelly
> in each driver (rocker). Introduce the similar mechanism in generic
> switchdev code, in form of queue. That can be used not only for memory
> allocations, but also for different items. Commit/abort item destruction
> is handled as well.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index df5a544..55a8411 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -1,6 +1,6 @@
>  /*
>   * net/switchdev/switchdev.c - Switch device API
> - * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
> + * Copyright (c) 2014-2015 Jiri Pirko <jiri@resnulli.us>
>   * Copyright (c) 2014-2015 Scott Feldman <sfeldma@gmail.com>
>   *
>   * This program is free software; you can redistribute it and/or modify
> @@ -16,9 +16,56 @@
>  #include <linux/notifier.h>
>  #include <linux/netdevice.h>
>  #include <linux/if_bridge.h>
> +#include <linux/list.h>
>  #include <net/ip_fib.h>
>  #include <net/switchdev.h>
>
> +void switchdev_trans_item_enqueue(struct switchdev_trans *trans,
> +                                 void *data, void (*destructor)(void const *),
> +                                 struct switchdev_trans_item *tritem)
> +{
> +       tritem->data = data;
> +       tritem->destructor = destructor;
> +       list_add_tail(&tritem->list, &trans->item_list);
> +}
> +EXPORT_SYMBOL_GPL(switchdev_trans_item_enqueue);
> +
> +static struct switchdev_trans_item *
> +__switchdev_trans_item_dequeue(struct switchdev_trans *trans)
> +{
> +       struct switchdev_trans_item *tritem;
> +
> +       if (list_empty(&trans->item_list))
> +               return NULL;
> +       tritem = list_first_entry(&trans->item_list,
> +                                 struct switchdev_trans_item, list);
> +       list_del(&tritem->list);
> +       return tritem;
> +}
> +
> +void *switchdev_trans_item_dequeue(struct switchdev_trans *trans)
> +{
> +       struct switchdev_trans_item *tritem;
> +
> +       tritem = __switchdev_trans_item_dequeue(trans);
> +       BUG_ON(!tritem);
> +       return tritem->data;
> +}
> +EXPORT_SYMBOL_GPL(switchdev_trans_item_dequeue);

Please add header comment block for these EXPORT_SYMBOL_GPL funcs.
