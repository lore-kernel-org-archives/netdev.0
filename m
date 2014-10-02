From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next v6 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Wed, 1 Oct 2014 21:40:39 -0700
Message-ID: <CAHA+R7PiP2Ce-+3S6Uy5kkKjk1sN6uE2gXzvL_HtfnyVHLoKoQ@mail.gmail.com>
References: <1412152711-12646-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:49737 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857AbaJBEkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 00:40:41 -0400
Received: by mail-la0-f54.google.com with SMTP id gm9so1588701lab.41
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 21:40:39 -0700 (PDT)
In-Reply-To: <1412152711-12646-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 1, 2014 at 1:38 AM, Mahesh Bandewar <maheshb@google.com> wrote:
> +int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave)
> +{
> +       struct slave *slave;
> +       struct list_head *iter;
> +       struct bond_up_slave *new_arr, *old_arr;
> +       int slaves_in_agg;
> +       int agg_id = 0;
> +       int ret = 0;
> +
> +#ifdef CONFIG_LOCKDEP
> +       WARN_ON(lockdep_is_held(&bond->mode_lock));
> +#endif


I think you can use lockdep_is_held().

> +
> +       new_arr = kzalloc(offsetof(struct bond_up_slave, arr[bond->slave_cnt]),
> +                         GFP_KERNEL);
> +       if (!new_arr) {
> +               ret = -ENOMEM;
> +               pr_err("Failed to build slave-array.\n");
> +               goto out;
> +       }


No need to print an error message for OOM, it is already noisy. :)


> +       if (BOND_MODE(bond) == BOND_MODE_8023AD) {
> +               struct ad_info ad_info;
> +
> +               if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
> +                       pr_debug("bond_3ad_get_active_agg_info failed\n");


I suspect how useful this debug info is since your patch is almost ready
to merge.

> +                       kfree_rcu(new_arr, rcu);
> +                       /* No active aggragator means its not safe to use

s/its/it's/

> +                        * the previous array.
> +                        */
> +                       old_arr = rtnl_dereference(bond->slave_arr);
> +                       if (old_arr) {
> +                               RCU_INIT_POINTER(bond->slave_arr, NULL);
> +                               kfree_rcu(old_arr, rcu);
> +                       }
> +                       goto out;
> +               }
> +               slaves_in_agg = ad_info.ports;
> +               agg_id = ad_info.aggregator_id;
> +       }



Thanks.
