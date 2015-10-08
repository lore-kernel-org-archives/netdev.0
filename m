From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next RFC 3/3] switchdev: introduce deferred variants
 of obj_add/del helpers
Date: Thu, 8 Oct 2015 09:45:58 +0300
Message-ID: <CAJ3xEMhEupHZvdQfBucemQwyjtQUcwwc5D5MhYqpctJGqtcTsA@mail.gmail.com>
References: <1444242652-17260-1-git-send-email-jiri@resnulli.us>
	<1444242652-17260-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, idosch@mellanox.com,
	Elad Raz <eladr@mellanox.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>,
	john fastabend <john.fastabend@gmail.com>,
	David Laight <David.Laight@aculab.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35267 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbbJHGp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 02:45:59 -0400
Received: by ioiz6 with SMTP id z6so47792684ioi.2
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 23:45:58 -0700 (PDT)
In-Reply-To: <1444242652-17260-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 7, 2015 at 9:30 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Similar to the attr usecase, the caller knows if he is holding RTNL and is
> in atomic section. So let the called to decide the correct call variant.
>
> This allows drivers to sleep inside their ops and wait for hw to get the
> operation status. Then the status is propagated into switchdev core.
> This avoids silent errors in drivers.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 7f7d551..2086767 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -139,7 +139,7 @@ static void fdb_del_external_learn(struct net_bridge_fdb_entry *f)
>                 .vid = f->vlan_id,
>         };
>
> -       switchdev_port_obj_del(f->dst->dev, &fdb.obj);
> +       switchdev_port_obj_del_deferred(f->dst->dev, &fdb.obj);
>  }


>  static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index c29f4ee..49e6e6f 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -362,6 +362,75 @@ int switchdev_port_obj_add(struct net_device *dev,
>  }
>  EXPORT_SYMBOL_GPL(switchdev_port_obj_add);
>
> +struct switchdev_obj_work {
> +       struct work_struct work;
> +       struct net_device *dev;
> +       struct switchdev_obj obj;
> +       bool add; /* add of del */
> +};
> +
> +static void switchdev_port_obj_work(struct work_struct *work)
> +{
> +       struct switchdev_obj_work *ow =
> +                       container_of(work, struct switchdev_obj_work, work);
> +       int err;
> +
> +       rtnl_lock();
> +       if (ow->add)
> +               err = switchdev_port_obj_add(ow->dev, &ow->obj);
> +       else
> +               err = switchdev_port_obj_del(ow->dev, &ow->obj);
> +       if (err && err != -EOPNOTSUPP)
> +               netdev_err(ow->dev, "failed (err=%d) to %s object (id=%d)\n",
> +                          err, ow->add ? "add" : "del", ow->obj.id);

This introduced a regression to the 2-phase commit scheme, since the
prepare commit can fail
and that would go un-noticed toward the upper layer, agree?

Or.

> +       rtnl_unlock();
> +
> +       dev_put(ow->dev);
> +       kfree(ow);
> +}
