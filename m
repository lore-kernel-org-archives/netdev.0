From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next] net: remove dead code for add/del multiple
Date: Fri, 13 Dec 2013 21:27:54 -0500
Message-ID: <CAGCdqXHtie_5o=99aQgeP7HakaRQiuzs8N5OyC4MHrjk0xAmzg@mail.gmail.com>
References: <20131213123556.4175da1b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:47788 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752378Ab3LNC1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 21:27:55 -0500
Received: by mail-wi0-f181.google.com with SMTP id hq4so60092wib.14
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 18:27:54 -0800 (PST)
In-Reply-To: <20131213123556.4175da1b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 13, 2013 at 3:35 PM, Stephen Hemminger <shemming@brocade.com> wrote:
> These function to manipulate multiple addresses are not used anywhere
> in current net-next tree. Some out of tree code maybe using these but
> too bad; they should submit their code upstream..
>
> Also, make __hw_addr_flush local since only used by dev_addr_lists.c
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

I initially provided the API for completeness sake.  Since no-one currently
needs it, I guess I am ok with this change.  If a need arises, we can
put it back.

-vlad

>
> ---
>  include/linux/netdevice.h |   11 -----
>  net/core/dev_addr_lists.c |   97 ----------------------------------------------
>  2 files changed, 1 insertion(+), 107 deletions(-)
>
> --- a/include/linux/netdevice.h 2013-12-13 12:31:44.098150763 -0800
> +++ b/include/linux/netdevice.h 2013-12-13 12:32:01.117841519 -0800
> @@ -2810,17 +2810,10 @@ int register_netdev(struct net_device *d
>  void unregister_netdev(struct net_device *dev);
>
>  /* General hardware address lists handling functions */
> -int __hw_addr_add_multiple(struct netdev_hw_addr_list *to_list,
> -                          struct netdev_hw_addr_list *from_list,
> -                          int addr_len, unsigned char addr_type);
> -void __hw_addr_del_multiple(struct netdev_hw_addr_list *to_list,
> -                           struct netdev_hw_addr_list *from_list,
> -                           int addr_len, unsigned char addr_type);
>  int __hw_addr_sync(struct netdev_hw_addr_list *to_list,
>                    struct netdev_hw_addr_list *from_list, int addr_len);
>  void __hw_addr_unsync(struct netdev_hw_addr_list *to_list,
>                       struct netdev_hw_addr_list *from_list, int addr_len);
> -void __hw_addr_flush(struct netdev_hw_addr_list *list);
>  void __hw_addr_init(struct netdev_hw_addr_list *list);
>
>  /* Functions used for device addresses handling */
> @@ -2828,10 +2821,6 @@ int dev_addr_add(struct net_device *dev,
>                  unsigned char addr_type);
>  int dev_addr_del(struct net_device *dev, const unsigned char *addr,
>                  unsigned char addr_type);
> -int dev_addr_add_multiple(struct net_device *to_dev,
> -                         struct net_device *from_dev, unsigned char addr_type);
> -int dev_addr_del_multiple(struct net_device *to_dev,
> -                         struct net_device *from_dev, unsigned char addr_type);
>  void dev_addr_flush(struct net_device *dev);
>  int dev_addr_init(struct net_device *dev);
>
> --- a/net/core/dev_addr_lists.c 2013-12-13 12:31:44.042151781 -0800
> +++ b/net/core/dev_addr_lists.c 2013-12-13 12:32:01.117841519 -0800
> @@ -186,47 +186,6 @@ static int __hw_addr_sync_multiple(struc
>         return err;
>  }
>
> -int __hw_addr_add_multiple(struct netdev_hw_addr_list *to_list,
> -                          struct netdev_hw_addr_list *from_list,
> -                          int addr_len, unsigned char addr_type)
> -{
> -       int err;
> -       struct netdev_hw_addr *ha, *ha2;
> -       unsigned char type;
> -
> -       list_for_each_entry(ha, &from_list->list, list) {
> -               type = addr_type ? addr_type : ha->type;
> -               err = __hw_addr_add(to_list, ha->addr, addr_len, type);
> -               if (err)
> -                       goto unroll;
> -       }
> -       return 0;
> -
> -unroll:
> -       list_for_each_entry(ha2, &from_list->list, list) {
> -               if (ha2 == ha)
> -                       break;
> -               type = addr_type ? addr_type : ha2->type;
> -               __hw_addr_del(to_list, ha2->addr, addr_len, type);
> -       }
> -       return err;
> -}
> -EXPORT_SYMBOL(__hw_addr_add_multiple);
> -
> -void __hw_addr_del_multiple(struct netdev_hw_addr_list *to_list,
> -                           struct netdev_hw_addr_list *from_list,
> -                           int addr_len, unsigned char addr_type)
> -{
> -       struct netdev_hw_addr *ha;
> -       unsigned char type;
> -
> -       list_for_each_entry(ha, &from_list->list, list) {
> -               type = addr_type ? addr_type : ha->type;
> -               __hw_addr_del(to_list, ha->addr, addr_len, type);
> -       }
> -}
> -EXPORT_SYMBOL(__hw_addr_del_multiple);
> -
>  /* This function only works where there is a strict 1-1 relationship
>   * between source and destionation of they synch. If you ever need to
>   * sync addresses to more then 1 destination, you need to use
> @@ -264,7 +223,7 @@ void __hw_addr_unsync(struct netdev_hw_a
>  }
>  EXPORT_SYMBOL(__hw_addr_unsync);
>
> -void __hw_addr_flush(struct netdev_hw_addr_list *list)
> +static void __hw_addr_flush(struct netdev_hw_addr_list *list)
>  {
>         struct netdev_hw_addr *ha, *tmp;
>
> @@ -274,7 +233,6 @@ void __hw_addr_flush(struct netdev_hw_ad
>         }
>         list->count = 0;
>  }
> -EXPORT_SYMBOL(__hw_addr_flush);
>
>  void __hw_addr_init(struct netdev_hw_addr_list *list)
>  {
> @@ -400,59 +358,6 @@ int dev_addr_del(struct net_device *dev,
>  }
>  EXPORT_SYMBOL(dev_addr_del);
>
> -/**
> - *     dev_addr_add_multiple - Add device addresses from another device
> - *     @to_dev: device to which addresses will be added
> - *     @from_dev: device from which addresses will be added
> - *     @addr_type: address type - 0 means type will be used from from_dev
> - *
> - *     Add device addresses of the one device to another.
> - **
> - *     The caller must hold the rtnl_mutex.
> - */
> -int dev_addr_add_multiple(struct net_device *to_dev,
> -                         struct net_device *from_dev,
> -                         unsigned char addr_type)
> -{
> -       int err;
> -
> -       ASSERT_RTNL();
> -
> -       if (from_dev->addr_len != to_dev->addr_len)
> -               return -EINVAL;
> -       err = __hw_addr_add_multiple(&to_dev->dev_addrs, &from_dev->dev_addrs,
> -                                    to_dev->addr_len, addr_type);
> -       if (!err)
> -               call_netdevice_notifiers(NETDEV_CHANGEADDR, to_dev);
> -       return err;
> -}
> -EXPORT_SYMBOL(dev_addr_add_multiple);
> -
> -/**
> - *     dev_addr_del_multiple - Delete device addresses by another device
> - *     @to_dev: device where the addresses will be deleted
> - *     @from_dev: device supplying the addresses to be deleted
> - *     @addr_type: address type - 0 means type will be used from from_dev
> - *
> - *     Deletes addresses in to device by the list of addresses in from device.
> - *
> - *     The caller must hold the rtnl_mutex.
> - */
> -int dev_addr_del_multiple(struct net_device *to_dev,
> -                         struct net_device *from_dev,
> -                         unsigned char addr_type)
> -{
> -       ASSERT_RTNL();
> -
> -       if (from_dev->addr_len != to_dev->addr_len)
> -               return -EINVAL;
> -       __hw_addr_del_multiple(&to_dev->dev_addrs, &from_dev->dev_addrs,
> -                              to_dev->addr_len, addr_type);
> -       call_netdevice_notifiers(NETDEV_CHANGEADDR, to_dev);
> -       return 0;
> -}
> -EXPORT_SYMBOL(dev_addr_del_multiple);
> -
>  /*
>   * Unicast list handling functions
>   */
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
