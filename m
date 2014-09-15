From: "Alexander Y. Fomichev" <git.user@gmail.com>
Subject: Re: [PATCH net] net: fix sysfs symlinks of adjacent devices
Date: Mon, 15 Sep 2014 14:18:43 +0400
Message-ID: <CAChDUfSxwQXRTKY35zEPzY4hh+=E5r62DtMMxJw3yCs_2B9MTw@mail.gmail.com>
References: <1410516826-6926-1-git-send-email-git.user@gmail.com>
	<5412F633.8020102@gmail.com>
	<20140914.174507.2303420279405209295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: vyasevich@gmail.com, netdev <netdev@vger.kernel.org>,
	Cong Wang <cwang@twopensource.com>, vyasevic@redhat.com,
	Andres Freund <andres@anarazel.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:56140 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083AbaIOKSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 06:18:53 -0400
Received: by mail-we0-f173.google.com with SMTP id u56so3693071wes.4
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 03:18:44 -0700 (PDT)
In-Reply-To: <20140914.174507.2303420279405209295.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tnx, i had thinking move it to netdev_adjacent_sysfs_add/del.. but
this is better.

On Mon, Sep 15, 2014 at 1:45 AM, David Miller <davem@davemloft.net> wrote:
> From: Vlad Yasevich <vyasevich@gmail.com>
> Date: Fri, 12 Sep 2014 09:33:39 -0400
>
>> Looking over the code, it might make sense to move all the net_eq checks
>> into adjacent_sysfs calls so as to consolidate them.  I haven't audited
>> all code paths, but at first glance it should do the right thing.
>>
>> What do you think?
>
> Agreed, let's do the following then?
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index ab9a165..a70e49e 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4809,9 +4809,14 @@ static void netdev_adjacent_sysfs_del(struct net_device *dev,
>         sysfs_remove_link(&(dev->dev.kobj), linkname);
>  }
>
> -#define netdev_adjacent_is_neigh_list(dev, dev_list) \
> -               (dev_list == &dev->adj_list.upper || \
> -                dev_list == &dev->adj_list.lower)
> +static bool netdev_adjacent_is_neigh_list(struct net_device *dev,
> +                                         struct net_device *adj_dev,
> +                                         struct list_head *dev_list)
> +{
> +       return (dev_list == &dev->adj_list.upper ||
> +               dev_list == &dev->adj_list.lower) &&
> +               net_eq(dev_net(dev), dev_net(adj_dev));
> +}
>
>  static int __netdev_adjacent_dev_insert(struct net_device *dev,
>                                         struct net_device *adj_dev,
> @@ -4841,7 +4846,7 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
>         pr_debug("dev_hold for %s, because of link added from %s to %s\n",
>                  adj_dev->name, dev->name, adj_dev->name);
>
> -       if (netdev_adjacent_is_neigh_list(dev, dev_list)) {
> +       if (netdev_adjacent_is_neigh_list(dev, adj_dev, dev_list)) {
>                 ret = netdev_adjacent_sysfs_add(dev, adj_dev, dev_list);
>                 if (ret)
>                         goto free_adj;
> @@ -4862,7 +4867,7 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
>         return 0;
>
>  remove_symlinks:
> -       if (netdev_adjacent_is_neigh_list(dev, dev_list))
> +       if (netdev_adjacent_is_neigh_list(dev, adj_dev, dev_list))
>                 netdev_adjacent_sysfs_del(dev, adj_dev->name, dev_list);
>  free_adj:
>         kfree(adj);
> @@ -4895,8 +4900,7 @@ static void __netdev_adjacent_dev_remove(struct net_device *dev,
>         if (adj->master)
>                 sysfs_remove_link(&(dev->dev.kobj), "master");
>
> -       if (netdev_adjacent_is_neigh_list(dev, dev_list) &&
> -           net_eq(dev_net(dev),dev_net(adj_dev)))
> +       if (netdev_adjacent_is_neigh_list(dev, adj_dev, dev_list))
>                 netdev_adjacent_sysfs_del(dev, adj_dev->name, dev_list);
>
>         list_del_rcu(&adj->list);



-- 
Best regards.
       Alexander Y. Fomichev <git.user@gmail.com>
