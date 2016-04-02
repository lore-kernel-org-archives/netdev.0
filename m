From: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Subject: Re: [PATCH v2 net-next] net/core: generic support for disabling
 netdev features down stack
Date: Sat, 2 Apr 2016 04:21:15 +0200
Message-ID: <CAHXqBF+rXETarA-ociV5xYUv3jttDGrmtGFsgN0tSGLeMuE_3w@mail.gmail.com>
References: <1446486818-26166-1-git-send-email-jarod@redhat.com> <1446519359-21400-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Michal Kubecek <mkubecek@suse.cz>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f196.google.com ([209.85.213.196]:34760 "EHLO
	mail-ig0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755135AbcDBCVg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 22:21:36 -0400
In-Reply-To: <1446519359-21400-1-git-send-email-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Sorry for digging up an old patch, but... ;-)

dev_disable_lro() is a leftover from ancient times. If you read commit
27660515a,
there is a hint where it should go. Please, read on if you'd like to
fix this properly.

2015-11-03 3:55 GMT+01:00 Jarod Wilson <jarod@redhat.com>:
> There are some netdev features, which when disabled on an upper devic=
e,
> such as a bonding master or a bridge, must be disabled and cannot be
> re-enabled on underlying devices.
[...]
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6288,6 +6288,44 @@ static void rollback_registered(struct net_dev=
ice *dev)
>         list_del(&single);
>  }
>
> +static netdev_features_t netdev_sync_upper_features(struct net_devic=
e *lower,
> +       struct net_device *upper, netdev_features_t features)
> +{
> +       netdev_features_t upper_disables =3D NETIF_F_UPPER_DISABLES;
> +       netdev_features_t feature;
> +
> +       for_each_netdev_feature(&upper_disables, feature) {
> +               if (!(upper->wanted_features & feature)
> +                   && (features & feature)) {
> +                       netdev_dbg(lower, "Dropping feature %pNF, upp=
er dev %s has it off.\n",
> +                                  &feature, upper->name);
> +                       features &=3D ~feature;
> +               }
> +       }

You could do this once:

disable_features =3D ~upper->features & features & NETIF_F_UPPER_DISABL=
ES;
if (features & disable_features)
  netdev_dbg(...)
features &=3D ~disable_features;

> +
> +       return features;
> +}
[...]
> @@ -6370,6 +6410,10 @@ int __netdev_update_features(struct net_device=
 *dev)
>         /* driver might be less strict about feature dependencies */
>         features =3D netdev_fix_features(dev, features);
>
> +       /* some features can't be enabled if they're off an an upper =
device */
> +       netdev_for_each_upper_dev_rcu(dev, upper, iter)
> +               features =3D netdev_sync_upper_features(dev, upper, f=
eatures);
> +
>         if (dev->features =3D=3D features)
>                 return 0;
>

This should go into netdev_fix_features(), as it is a one single place,
where are feature dependencies are verified.

[...]
> @@ -6386,6 +6430,12 @@ int __netdev_update_features(struct net_device=
 *dev)
>                 return -1;
>         }
>
> +       /* some features must be disabled on lower devices when disab=
led
> +        * on an upper device (think: bonding master or bridge)
> +        */
> +       netdev_for_each_lower_dev(dev, lower, iter)
> +               netdev_sync_lower_features(dev, lower, features);
> +
[...]

This should be equal in resulting flags to:

   netdev_for_each_lower_dev(dev, lower...)
     netdev_update_features(lower);

because netdev_fix_features(lower) will see already changed dev->featur=
es.

Best Regards,
Micha=C5=82 Miros=C5=82aw
