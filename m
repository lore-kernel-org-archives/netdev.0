From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v5 5/8] switchdev: introduce possibility to defer obj_add/del
Date: Mon, 19 Oct 2015 00:55:59 -0700
Message-ID: <CAE4R7bDpGYsQA+S+B6wOWJHeXsrPFXkpnuy_wYSdzgRRB_jbZg@mail.gmail.com>
References: <1444844455-12508-1-git-send-email-jiri@resnulli.us> <1444844455-12508-6-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	john fastabend <john.fastabend@gmail.com>,
	David Laight <David.Laight@aculab.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:33467 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbbJSH4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 03:56:19 -0400
Received: by oiad129 with SMTP id d129so31396699oia.0
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 00:56:19 -0700 (PDT)
In-Reply-To: <1444844455-12508-6-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2015 at 10:40 AM, Jiri Pirko <jiri@resnulli.us> wrote:
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
> ---
>  include/net/switchdev.h   |   1 +
>  net/switchdev/switchdev.c | 100 ++++++++++++++++++++++++++++++++++++----------
>  2 files changed, 81 insertions(+), 20 deletions(-)
>
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index f8672d7..bc865e2 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -69,6 +69,7 @@ enum switchdev_obj_id {
>
>  struct switchdev_obj {
>         enum switchdev_obj_id id;
> +       u32 flags;
>  };
>
>  /* SWITCHDEV_OBJ_ID_PORT_VLAN */
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index 5963d7a..eac68c4 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -362,21 +362,8 @@ static int __switchdev_port_obj_add(struct net_device *dev,
>         return err;
>  }
>
> -/**
> - *     switchdev_port_obj_add - Add port object
> - *
> - *     @dev: port device
> - *     @id: object ID
> - *     @obj: object to add
> - *
> - *     Use a 2-phase prepare-commit transaction model to ensure
> - *     system is not left in a partially updated state due to
> - *     failure from driver/device.
> - *
> - *     rtnl_lock must be held.
> - */
> -int switchdev_port_obj_add(struct net_device *dev,
> -                          const struct switchdev_obj *obj)
> +static int switchdev_port_obj_add_now(struct net_device *dev,
> +                                     const struct switchdev_obj *obj)
>  {
>         struct switchdev_trans trans;
>         int err;
> @@ -418,18 +405,53 @@ int switchdev_port_obj_add(struct net_device *dev,
>
>         return err;
>  }
> -EXPORT_SYMBOL_GPL(switchdev_port_obj_add);
> +
> +static void switchdev_port_obj_add_deferred(struct net_device *dev,
> +                                           const void *data)
> +{
> +       const struct switchdev_obj *obj = data;
> +       int err;
> +
> +       err = switchdev_port_obj_add_now(dev, obj);
> +       if (err && err != -EOPNOTSUPP)
> +               netdev_err(dev, "failed (err=%d) to add object (id=%d)\n",
> +                          err, obj->id);
> +}
> +
> +static int switchdev_port_obj_add_defer(struct net_device *dev,
> +                                       const struct switchdev_obj *obj)
> +{
> +       return switchdev_deferred_enqueue(dev, obj, sizeof(*obj),
> +                                         switchdev_port_obj_add_deferred);
> +}

Hi Jiri,

I think there is a problem here with this patch.  When we defer adding
an obj, we're only copying the inner struct switchdev_obj.  The rest
of the containing obj is lost.  So when
switchdev_port_obj_add_deferred() runs, we're up casting to garbage.
So if this FDB obj was deferred, the addr, vid, and ndm_state members
would be garbage:

struct switchdev_obj_port_fdb {
        struct switchdev_obj obj;
        unsigned char addr[ETH_ALEN];
        u16 vid;
        u16 ndm_state;
};
