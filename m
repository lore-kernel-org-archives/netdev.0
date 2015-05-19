From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH 3/3] ipvlan: set dev_id for l2 ports to generate unique
 IPv6 addresses
Date: Tue, 19 May 2015 16:59:45 -0700
Message-ID: <CAF2d9jg0abaZY+w54yWTgYgOxJbJTQsf5nhgXJYhA8hOC=C2CQ@mail.gmail.com>
References: <20150514134657.14062.87579.stgit@buzz> <20150514135620.14062.1034.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Benc <jbenc@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:34290 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816AbbETAAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 20:00:07 -0400
Received: by oiko83 with SMTP id o83so23829387oik.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 17:00:05 -0700 (PDT)
In-Reply-To: <20150514135620.14062.1034.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 14, 2015 at 6:56 AM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> All ipvlan ports use one MAC address, this way ipv6 RA tries to assign
> one ipv6 address to all of them. This patch assigns unique dev_id to each
> ipvlan port. This field is used instead of common FF-FE in Modified EUI-64.
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  Documentation/networking/ipvlan.txt |   12 +++++++++++-
>  drivers/net/ipvlan/ipvlan.h         |    1 +
>  drivers/net/ipvlan/ipvlan_main.c    |   20 ++++++++++++++++++++
>  3 files changed, 32 insertions(+), 1 deletion(-)
>
> diff --git a/Documentation/networking/ipvlan.txt b/Documentation/networking/ipvlan.txt
> index cf996394e466..cb0b777bce58 100644
> --- a/Documentation/networking/ipvlan.txt
> +++ b/Documentation/networking/ipvlan.txt
> @@ -24,7 +24,7 @@ using IProute2/ip utility.
>
>         ip link add link <master-dev> <slave-dev> type ipvlan mode { l2 | L3 }
>
> -       e.g. ip link add link ipvl0 eth0 type ipvlan mode l2
> +       e.g. ip link add link eth0 ipvl0 type ipvlan mode l2
>
>
>  4. Operating modes:
> @@ -41,6 +41,15 @@ slave device and packets are switched and queued to the master device to send
>  out. In this mode the slaves will RX/TX multicast and broadcast (if applicable)
>  as well.
>
> +       In L2 mode slave devices receive Router Advertisements from the network
> +and perform autoconfiguration as well as master device. Each port has unique
> +16-bit device id which is used for filling octets 4-5 of Modified EUI-64.
> +That gives 65533 addresses (FF-FE used by master, FF-FF/00-00 reserved/not used).
> +
This is nice, thanks for fixing this! However how is "unique" id
guaranteed? Especially when multiple virtual drivers are stacked? Not
necessarily all of them may use the dev_id, but to avoid any possible
collision, shouldn't the device hierarchy (especially lower_dev) be
traversed before settling on the initial value?

> +       Also lower half of IPv6 address could be set as interface token:
> +
> +       ip token set ::aaaa:bbbb:cccc:dddd dev ipvl0
> +
>  4.2 L3 mode:
>         In this mode TX processing upto L3 happens on the stack instance attached
>  to the slave device and packets are switched to the stack instance of the
> @@ -105,3 +114,4 @@ namespace where L2 on the slave could be changed / misused.
>                         (4) ip -4 addr add 127.0.0.1 dev lo
>                         (5) ip -4 addr add $IPADDR dev ipvl1
>                         (6) ip -4 route add default via $ROUTER dev ipvl1
> +
> diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
> index 54549a6223dd..1ebab84e7a0e 100644
> --- a/drivers/net/ipvlan/ipvlan.h
> +++ b/drivers/net/ipvlan/ipvlan.h
> @@ -95,6 +95,7 @@ struct ipvl_port {
>         struct rcu_head         rcu;
>         int                     count;
>         u16                     mode;
> +       struct ida              ida;
>  };
>
>  static inline struct ipvl_port *ipvlan_port_get_rcu(const struct net_device *d)
> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> index 0cafd3e6f02d..dee0e8441150 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -53,6 +53,7 @@ static int ipvlan_port_create(struct net_device *dev)
>         INIT_LIST_HEAD(&port->ipvlans);
>         for (idx = 0; idx < IPVLAN_HASH_SIZE; idx++)
>                 INIT_HLIST_HEAD(&port->hlhead[idx]);
> +       ida_init(&port->ida);
>
>         err = netdev_rx_handler_register(dev, ipvlan_handle_frame, port);
>         if (err)
> @@ -72,6 +73,7 @@ static void ipvlan_port_destroy(struct net_device *dev)
>
>         dev->priv_flags &= ~IFF_IPVLAN_MASTER;
>         netdev_rx_handler_unregister(dev);
> +       ida_destroy(&port->ida);
>         kfree_rcu(port, rcu);
>  }
>
> @@ -484,6 +486,18 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
>          */
>         memcpy(dev->dev_addr, phy_dev->dev_addr, ETH_ALEN);
>
> +       if (port->mode == IPVLAN_MODE_L2) {
> +               /*
> +                * IPv6 addrconf uses it to produce unique addresses,
> +                * see function addrconf_ifid_eui48.
> +                */
> +               err = ida_simple_get(&port->ida, 1, 0xFFFE, GFP_KERNEL);
> +               if (err > 0)
> +                       dev->dev_id = err;
> +               else if (err != -ENOSPC)
> +                       goto ipvlan_destroy_port;
> +       }
> +
>         dev->priv_flags |= IFF_IPVLAN_SLAVE;
>
>         port->count += 1;
> @@ -518,6 +532,12 @@ static void ipvlan_link_delete(struct net_device *dev, struct list_head *head)
>                         list_del(&addr->anode);
>                 }
>         }
> +
> +       if (dev->dev_id) {
> +               ida_simple_remove(&ipvlan->port->ida, dev->dev_id);
> +               dev->dev_id = 0;
> +       }
> +
>         list_del_rcu(&ipvlan->pnode);
>         unregister_netdevice_queue(dev, head);
>         netdev_upper_dev_unlink(ipvlan->phy_dev, dev);
>
