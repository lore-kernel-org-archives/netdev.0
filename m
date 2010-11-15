From: sergey belov <gexlie@gmail.com>
Subject: NETPOLL on bond interfaces
Date: Mon, 15 Nov 2010 16:49:35 +0300
Message-ID: <AANLkTingysT7=+AiGCh4kiY27RK9jz40ci1y_of4o-FC@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:64379 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755672Ab0KONuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 08:50:07 -0500
Received: by qwj8 with SMTP id 8so65519qwj.19
        for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 05:50:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before 2.6.36 came out I was using this patch to enable netpoll on bond
interfaces (see below)

When I tried to apply this patch to 2.6.36 sources some chunks was failed.

[root@kernel-x32 experimental]# patch -p0 < netpoll.patch
patching file a/drivers/net/bonding/bond_main.c
Hunk #1 FAILED at 75.
Hunk #2 FAILED at 416.
Hunk #3 succeeded at 1334 with fuzz 2 (offset 23 lines).
Hunk #4 succeeded at 1729 with fuzz 1 (offset 15 lines).
Hunk #5 succeeded at 1837 (offset 42 lines).
Hunk #6 succeeded at 2026 (offset 19 lines).
Hunk #7 succeeded at 4490 with fuzz 1 (offset 11 lines).
Hunk #8 succeeded at 4674 (offset 68 lines).
2 out of 8 hunks FAILED -- saving rejects to file
a/drivers/net/bonding/bond_main.c.rej
patching file a/drivers/net/bonding/bonding.h
Hunk #2 succeeded at 227 (offset 4 lines).
patching file a/include/linux/netdevice.h
Hunk #1 FAILED at 52.
Hunk #2 FAILED at 625.
2 out of 2 hunks FAILED -- saving rejects to file
a/include/linux/netdevice.h.rej
patching file a/include/linux/netpoll.h
Hunk #1 succeeded at 43 with fuzz 2 (offset 9 lines).
patching file a/net/core/netpoll.c
Reversed (or previously applied) patch detected!  Assume -R? [n]


Inspecting changelog at
http://www.kernel.org/pub/linux/kernel/v2.6/ChangeLog-2.6.36 I found there
are a lot of changes was done inside of the bonding and netpoll subsystem.

Could please someone provide me new patch to enable netpoll on bond ifaces
or send me a workaround how to enable it in any other way.

We need to use it only to enable netconsole on our servers with bond.


   1. diff --git a/drivers/net/bonding/bond_main.c
   b/drivers/net/bonding/bond_main.c
   2. index d927f71..6304720 100644
   3. --- a/drivers/net/bonding/bond_main.c
   4. +++ b/drivers/net/bonding/bond_main.c
   5. @@ -75,6 +75,7 @@
   6.  #include <linux/jiffies.h>
   7.  #include <net/route.h>
   8.  #include <net/net_namespace.h>
   9. +#include <linux/netpoll.h>
   10.  #include "bonding.h"
   11.  #include "bond_3ad.h"
   12.  #include "bond_alb.h"
   13. @@ -415,7 +416,12 @@ int bond_dev_queue_xmit(struct bonding *bond,
   struct sk_buff *skb,
   14.         }
   15.
   16.         skb->priority = 1;
   17. -       dev_queue_xmit(skb);
   18. +#ifdef CONFIG_NET_POLL_CONTROLLER
   19. +       if (bond->netpoll)
   20. +               netpoll_send_skb(bond->netpoll, skb);
   21. +       else
   22. +#endif
   23. +               dev_queue_xmit(skb);
   24.
   25.         return 0;
   26.  }
   27. @@ -1305,6 +1311,44 @@ static void bond_detach_slave(struct bonding
   *bond, struct slave *slave)
   28.         bond->slave_cnt--;
   29.  }
   30.
   31. +#ifdef CONFIG_NET_POLL_CONTROLLER
   32. +static int slaves_support_netpoll(struct net_device *bond_dev)
   33. +{
   34. +       struct bonding *bond = netdev_priv(bond_dev);
   35. +       struct slave *slave;
   36. +       int i;
   37. +
   38. +       bond_for_each_slave(bond, slave, i)
   39. +               if (!slave->dev->netdev_ops->ndo_poll_controller)
   40. +                       return 0;
   41. +       return 1;
   42. +}
   43. +
   44. +static void bond_poll_controller(struct net_device *bond_dev)
   45. +{
   46. +       struct bonding *bond = netdev_priv(bond_dev);
   47. +       struct slave *slave;
   48. +       int i;
   49. +
   50. +       if (slaves_support_netpoll(bond_dev))
   51. +               bond_for_each_slave(bond, slave, i)
   52. +                       netpoll_poll_dev(slave->dev);
   53. +}
   54. +
   55. +static int bond_netpoll_setup(struct net_device *bond_dev,
   56. +                             struct netpoll_info *npinfo)
   57. +{
   58. +       struct bonding *bond = netdev_priv(bond_dev);
   59. +       struct slave *slave;
   60. +       int i;
   61. +
   62. +       bond_for_each_slave(bond, slave, i)
   63. +               if (slave->dev)
   64. +                       slave->dev->npinfo = npinfo;
   65. +       return 0;
   66. +}
   67. +#endif
   68. +
   69.  /*---------------------------------- IOCTL
   ----------------------------------*/
   70.
   71.  static int bond_sethwaddr(struct net_device *bond_dev,
   72. @@ -1670,6 +1714,16 @@ int bond_enslave(struct net_device *bond_dev,
   struct net_device *slave_dev)
   73.                         bond->primary_slave = new_slave;
   74.         }
   75.
   76. +#ifdef CONFIG_NET_POLL_CONTROLLER
   77. +       if (slaves_support_netpoll(bond_dev))
   78. +               slave_dev->npinfo = bond_dev->npinfo;
   79. +       else {
   80. +               pr_err(DRV_NAME "New slave device %s does not support
   netpoll.\n",
   81. +                      slave_dev->name);
   82. +               pr_err(DRV_NAME "netpoll disabled for %s.\n",
   bond_dev->name);
   83. +       }
   84. +#endif
   85. +
   86.         write_lock_bh(&bond->curr_slave_lock);
   87.
   88.         switch (bond->params.mode) {
   89. @@ -1741,6 +1795,10 @@ int bond_enslave(struct net_device *bond_dev,
   struct net_device *slave_dev)
   90.
   91.  /* Undo stages on error */
   92.  err_close:
   93. +#ifdef CONFIG_NET_POLL_CONTROLLER
   94. +       if (slave_dev->npinfo)
   95. +               slave_dev->npinfo = NULL;
   96. +#endif
   97.         dev_close(slave_dev);
   98.
   99.  err_unset_master:
   100. @@ -1949,6 +2007,10 @@ int bond_release(struct net_device *bond_dev,
   struct net_device *slave_dev)
   101.                                    IFF_SLAVE_INACTIVE | IFF_BONDING
   |
   102.                                    IFF_SLAVE_NEEDARP);
   103.
   104. +#ifdef CONFIG_NET_POLL_CONTROLLER
   105. +       if (slave_dev->npinfo)
   106. +               slave_dev->npinfo = NULL;
   107. +#endif
   108.         kfree(slave);
   109.
   110.         return 0;  /* deletion OK */
   111. @@ -4417,6 +4479,20 @@ out:
   112.         return 0;
   113.  }
   114.
   115. +#ifdef CONFIG_NET_POLL_CONTROLLER
   116. +int bond_netpoll_start_xmit(struct netpoll *np, struct sk_buff *skb
   )
   117. +{
   118. +       struct bonding *bond = netdev_priv(skb->dev);
   119. +       int ret;
   120. +
   121. +       bond->netpoll = np;
   122. +       ret = bond->dev->netdev_ops->ndo_start_xmit(skb, bond->dev);
   123. +       bond->netpoll = NULL;
   124. +
   125. +       return ret;
   126. +}
   127. +#endif
   128. +
   129.  /*------------------------- Device initialization
   ---------------------------*/
   130.
   131.  static void bond_set_xmit_hash_policy(struct bonding *bond)
   132. @@ -4530,6 +4606,9 @@ static const struct net_device_ops
   bond_netdev_ops = {
   133.         .ndo_change_mtu         = bond_change_mtu,
   134.         .ndo_set_mac_address    = bond_set_mac_address,
   135.         .ndo_neigh_setup        = bond_neigh_setup,
   136. +       .ndo_netpoll_setup      = bond_netpoll_setup,
   137. +       .ndo_netpoll_start_xmit = bond_netpoll_start_xmit,
   138. +       .ndo_poll_controller    = bond_poll_controller,
   139.         .ndo_vlan_rx_register   = bond_vlan_rx_register,
   140.         .ndo_vlan_rx_add_vid    = bond_vlan_rx_add_vid,
   141.         .ndo_vlan_rx_kill_vid   = bond_vlan_rx_kill_vid,
   142. diff --git a/drivers/net/bonding/bonding.h
   b/drivers/net/bonding/bonding.h
   143. index 6290a50..563d28c 100644
   144. --- a/drivers/net/bonding/bonding.h
   145. +++ b/drivers/net/bonding/bonding.h
   146. @@ -18,6 +18,7 @@
   147.  #include <linux/timer.h>
   148.  #include <linux/proc_fs.h>
   149.  #include <linux/if_bonding.h>
   150. +#include <linux/netpoll.h>
   151.  #include <linux/kobject.h>
   152.  #include <linux/in6.h>
   153.  #include "bond_3ad.h"
   154. @@ -222,6 +223,10 @@ struct bonding {
   155.  #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
   156.         struct   in6_addr master_ipv6;
   157.  #endif
   158. +#ifdef CONFIG_NET_POLL_CONTROLLER
   159. +       struct   netpoll *netpoll;
   160. +#endif
   161. +
   162.  };
   163.
   164.  /**
   165. diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
   166. index d4a4d98..e1724b2 100644
   167. --- a/include/linux/netdevice.h
   168. +++ b/include/linux/netdevice.h
   169. @@ -52,6 +52,7 @@
   170.
   171.  struct vlan_group;
   172.  struct netpoll_info;
   173. +struct netpoll;
   174.  /* 802.11 specific */
   175.  struct wireless_dev;
   176.                                         /* source back-compat hooks
   */
   177. @@ -624,6 +625,10 @@ struct net_device_ops {
   178.                                                         unsigned
   short vid);
   179.  #ifdef CONFIG_NET_POLL_CONTROLLER
   180.  #define HAVE_NETDEV_POLL
   181. +       int                     (*ndo_netpoll_setup)(struct
   net_device *dev,
   182. +                                                    struct
   netpoll_info *npinfo);
   183. +       int                     (*ndo_netpoll_start_xmit)(struct
   netpoll *np,
   184. +                                                         struct
   sk_buff *skb);
   185.         void                    (*ndo_poll_controller)(struct
   net_device *dev);
   186.  #endif
   187.  #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
   188. diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
   189. index 2524267..39d42e4 100644
   190. --- a/include/linux/netpoll.h
   191. +++ b/include/linux/netpoll.h
   192. @@ -34,7 +34,9 @@ struct netpoll_info {
   193.  };
   194.
   195.  void netpoll_poll(struct netpoll *np);
   196. +void netpoll_poll_dev(struct net_device *dev);
   197.  void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
   ;
   198. +void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb);
   199.  void netpoll_print_options(struct netpoll *np);
   200.  int netpoll_parse_options(struct netpoll *np, char *opt);
   201.  int netpoll_setup(struct netpoll *np);
   202. diff --git a/net/core/netpoll.c b/net/core/netpoll.c
   203. index 9675f31..3776b26 100644
   204. --- a/net/core/netpoll.c
   205. +++ b/net/core/netpoll.c
   206. @@ -174,9 +174,8 @@ static void service_arp_queue(struct
   netpoll_info *npi)
   207.         }
   208.  }
   209.
   210. -void netpoll_poll(struct netpoll *np)
   211. +void netpoll_poll_dev(struct net_device *dev)
   212.  {
   213. -       struct net_device *dev = np->dev;
   214.         const struct net_device_ops *ops;
   215.
   216.         if (!dev || !netif_running(dev))
   217. @@ -196,6 +195,11 @@ void netpoll_poll(struct netpoll *np)
   218.         zap_completion_queue();
   219.  }
   220.
   221. +void netpoll_poll(struct netpoll *np)
   222. +{
   223. +       netpoll_poll_dev(np->dev);
   224. +}
   225. +
   226.  static void refill_skbs(void)
   227.  {
   228.         struct sk_buff *skb;
   229. @@ -277,11 +281,11 @@ static int netpoll_owner_active(struct
   net_device *dev)
   230.         return 0;
   231.  }
   232.
   233. -static void netpoll_send_skb(struct netpoll *np, struct sk_buff
   *skb)
   234. +void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
   235.  {
   236.         int status = NETDEV_TX_BUSY;
   237.         unsigned long tries;
   238. -       struct net_device *dev = np->dev;
   239. +       struct net_device *dev = skb->dev;
   240.         const struct net_device_ops *ops = dev->netdev_ops;
   241.         struct netpoll_info *npinfo = np->dev->npinfo;
   242.
   243. @@ -303,7 +307,10 @@ static void netpoll_send_skb(struct netpoll
   *np, struct sk_buff *skb)
   244.                      tries > 0; --tries) {
   245.                         if (__netif_tx_trylock(txq)) {
   246.                                 if (!netif_tx_queue_stopped(txq)) {
   247. -                                       status = ops->ndo_start_xmit
   (skb, dev);
   248. +                                       if (
   ops->ndo_netpoll_start_xmit)
   249. +                                               status =
   ops->ndo_netpoll_start_xmit(np,skb);
   250. +                                       else
   251. +                                               status =
   ops->ndo_start_xmit(skb, dev);
   252.                                         if (status == NETDEV_TX_OK)
   253.                                                 txq_trans_update(txq
   );
   254.                                 }
   255. @@ -789,6 +796,9 @@ int netpoll_setup(struct netpoll *np)
   256.         /* avoid racing with NAPI reading npinfo */
   257.         synchronize_rcu();
   258.
   259. +       if (ndev->netdev_ops->ndo_netpoll_setup)
   260. +               ndev->netdev_ops->ndo_netpoll_setup(ndev, npinfo);
   261. +
   262.         return 0;
   263.
   264.   release:
   265. @@ -859,4 +869,6 @@ EXPORT_SYMBOL(netpoll_parse_options);
   266.  EXPORT_SYMBOL(netpoll_setup);
   267.  EXPORT_SYMBOL(netpoll_cleanup);
   268.  EXPORT_SYMBOL(netpoll_send_udp);
   269. +EXPORT_SYMBOL(netpoll_send_skb);
   270.  EXPORT_SYMBOL(netpoll_poll);
   271. +EXPORT_SYMBOL(netpoll_poll_dev);
