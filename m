From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH 2/2] bonding: fix bonding_masters race condition in bond
 unloading
Date: Mon, 08 Apr 2013 11:15:23 +0200
Message-ID: <51628AAB.30908@redhat.com>
References: <1365245678-4455-1-git-send-email-nikolay@redhat.com> <1365245678-4455-2-git-send-email-nikolay@redhat.com> <20130406135020.GA18246@redhat.com> <20130408083044.GA1757@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com,
	davem@davemloft.net
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57765 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935043Ab3DHJSO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Apr 2013 05:18:14 -0400
In-Reply-To: <20130408083044.GA1757@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
>  drivers/net/bonding/bond_main.c  |   13 ++++++-------
>  drivers/net/bonding/bond_sysfs.c |   11 ++++++++---
>  2 files changed, 14 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c
> b/drivers/net/bonding/bond_main.c
> index 2aac890..6671f89 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4797,22 +4797,17 @@ static struct rtnl_link_ops bond_link_ops
> __read_mostly = {
>  
>  /* Create a new bond based on the specified name and bonding parameters.
>   * If name is NULL, obtain a suitable "bond%d" name for us.
> - * Caller must NOT hold rtnl_lock; we need to release it here before we
> - * set up our sysfs entries.
>   */
>  int bond_create(struct net *net, const char *name)
>  {
>      struct net_device *bond_dev;
>      int res;
>  
> -    rtnl_lock();
> -
>      bond_dev = alloc_netdev_mq(sizeof(struct bonding),
>                     name ? name : "bond%d",
>                     bond_setup, tx_queues);
>      if (!bond_dev) {
>          pr_err("%s: eek! can't alloc netdev!\n", name);
> -        rtnl_unlock();
>          return -ENOMEM;
>      }
>  
> @@ -4823,9 +4818,9 @@ int bond_create(struct net *net, const char *name)
>  
>      netif_carrier_off(bond_dev);
>  
> -    rtnl_unlock();
>      if (res < 0)
>          bond_destructor(bond_dev);
> +
>      return res;
>  }
>  
bond_destructor calls free_netdev, which is usually called without rtnl
after unregister_netdevice is called under rtnl.
(net/core/dev.c - free_netdev comments)
> @@ -4879,7 +4874,9 @@ static int __init bonding_init(void)
>      bond_create_debugfs();
>  
>      for (i = 0; i < max_bonds; i++) {
> +        rtnl_lock();
>          res = bond_create(&init_net, NULL);
> +        rtnl_unlock();
>          if (res)
>              goto err;
>      }
> @@ -4901,8 +4898,10 @@ static void __exit bonding_exit(void)
>  
>      bond_destroy_debugfs();
>  
> +    rtnl_lock();
> +    __rtnl_link_unregister(&bond_link_ops);
>      unregister_pernet_subsys(&bond_net_ops);
> -    rtnl_link_unregister(&bond_link_ops);
> +    rtnl_unlock();
>  
The usual way is to obtain net_mutex and then rtnl,
this reverses it.
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>      /*
> diff --git a/drivers/net/bonding/bond_sysfs.c
> b/drivers/net/bonding/bond_sysfs.c
> index ea7a388..cd1d60f 100644
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
> @@ -59,7 +59,8 @@ static ssize_t bonding_show_bonds(struct class *cls,
>      int res = 0;
>      struct bonding *bond;
>  
> -    rtnl_lock();
> +    if (!rtnl_trylock())
> +        return restart_syscall();
>  
>      list_for_each_entry(bond, &bn->dev_list, bond_list) {
>          if (res > (PAGE_SIZE - IFNAMSIZ)) {
> @@ -107,6 +108,9 @@ static ssize_t bonding_store_bonds(struct class *cls,
>      char *ifname;
>      int rv, res = count;
>  
> +    if (!rtnl_trylock())
> +        return restart_syscall();
> +
>      sscanf(buffer, "%16s", command); /* IFNAMSIZ*/
>      ifname = command + 1;
>      if ((strlen(command) <= 1) ||
> @@ -126,7 +130,6 @@ static ssize_t bonding_store_bonds(struct class *cls,
>      } else if (command[0] == '-') {
>          struct net_device *bond_dev;
>  
> -        rtnl_lock();
>          bond_dev = bond_get_by_name(bn, ifname);
>          if (bond_dev) {
>              pr_info("%s is being deleted...\n", ifname);
> @@ -135,10 +138,11 @@ static ssize_t bonding_store_bonds(struct class
> *cls,
>              pr_err("unable to delete non-existent %s\n", ifname);
>              res = -ENODEV;
>          }
> -        rtnl_unlock();
>      } else
>          goto err_no_cmd;
>  
> +    rtnl_unlock();
> +
>      /* Always return either count or an error.  If you return 0, you'll
>       * get called forever, which is bad.
>       */
> @@ -146,6 +150,7 @@ static ssize_t bonding_store_bonds(struct class *cls,
>  
>  err_no_cmd:
>      pr_err("no command found in bonding_masters. Use +ifname or
> -ifname.\n");
> +    rtnl_unlock();
>      return -EPERM;
>  }
>  
