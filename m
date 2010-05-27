From: Flavio Leitner <fbl@sysclose.org>
Subject: Re: [v5 Patch 1/3] netpoll: add generic support for bridge and
 bonding devices
Date: Thu, 27 May 2010 15:05:45 -0300
Message-ID: <20100527180545.GA2345@sysclose.org>
References: <20100505081514.5157.83783.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdcbbj.dreamhost.com ([208.97.132.119]:58335 "EHLO
	homiemail-a20.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754493Ab0E0SFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 14:05:50 -0400
Content-Disposition: inline
In-Reply-To: <20100505081514.5157.83783.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi guys!

I finally could test this to see if an old problem reported on bugzilla[1] was
fixed now, but unfortunately it is still there.

The ticket is private I guess, but basically the problem happens when bonding
driver tries to print something after it had taken the write_lock (monitor
functions, enslave/de-enslave), so the printk() will pass through netpoll, then
on bonding again which no matter what mode you use, it will try to read_lock()
the lock again. The result is a deadlock and the entire system hangs.

I manage to get a fresh backtrace with mode 1, see below:

 
[   93.167079] Call Trace:
[   93.167079]  [<ffffffff81034cf9>] warn_slowpath_common+0x77/0x8f
[   93.167079]  [<ffffffff81034d5e>] warn_slowpath_fmt+0x3c/0x3e
[   93.167079]  [<ffffffff81366aef>] ? _raw_read_trylock+0x11/0x4b
[   93.167079]  [<ffffffffa02a2c42>] ? bond_start_xmit+0x12b/0x401 [bonding]
-> read_lock fails
[   93.167079]  [<ffffffffa02a2c9f>] bond_start_xmit+0x188/0x401 [bonding]
[   93.167079]  [<ffffffff81055b37>] ? trace_hardirqs_off+0xd/0xf
[   93.167079]  [<ffffffff812dfdb9>] netpoll_send_skb+0xbd/0x1f3
[   93.167079]  [<ffffffff812e00ed>] netpoll_send_udp+0x1fe/0x20d
[   93.167079]  [<ffffffffa02c017c>] write_msg+0x89/0xcd [netconsole]
[   93.167079]  [<ffffffff81034e65>] __call_console_drivers+0x67/0x79
[   93.167079]  [<ffffffff81034ed0>] _call_console_drivers+0x59/0x5d
[   93.167079]  [<ffffffff810352d3>] release_console_sem+0x121/0x1d7
[   93.167079]  [<ffffffff8103590a>] vprintk+0x35d/0x393
[   93.167079]  [<ffffffff8103f947>] ? add_timer+0x17/0x19
[   93.167079]  [<ffffffff81046ddf>] ? queue_delayed_work_on+0xa2/0xa9
[   93.167079]  [<ffffffff81363bb8>] printk+0x3c/0x44
[   93.167079]  [<ffffffffa02a3b17>] bond_select_active_slave+0x105/0x109 [bonding] 
-> write_locked
[   93.167079]  [<ffffffffa02a4798>] bond_mii_monitor+0x479/0x4ed [bonding]
[   93.167079]  [<ffffffff81046009>] worker_thread+0x1ef/0x2e2

In this case, the message should be 
    "bonding: bond0: making interface eth0 the new active one"

I did the following patch to discard the packet if it was IN_NETPOLL
and the read_lock() fails, so I could go ahead testing it:

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5e12462..a3b8bad 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4258,8 +4258,19 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
 	struct bonding *bond = netdev_priv(bond_dev);
 	int res = 1;
 
-	read_lock(&bond->lock);
-	read_lock(&bond->curr_slave_lock);
+	if (read_trylock(&bond->lock) == 0 && 
+		(bond_dev->flags & IFF_IN_NETPOLL)) {
+			dev_kfree_skb(skb);
+			return NETDEV_TX_OK;
+	}
+
+	if (read_trylock(&bond->curr_slave_lock) == 0 && 
+		(bond_dev->flags & IFF_IN_NETPOLL)) {
+			read_unlock(&bond->lock);
+			dev_kfree_skb(skb);
+			return NETDEV_TX_OK;
+	}
+			
 
 	if (!BOND_IS_OK(bond))
 		goto out;


and I found another problem.  The function netpoll_send_skb() checks
if the npinfo's queue length is zero and if it's not, it will queue
the packet to make sure it's in order and then schedule the thread
to run. Later, the thread wakes up running queue_process() which disables
interrupts before calling ndo_start_xmit().  However, dev_queue_xmit()
uses rcu_*_bh() and before return, it will enable the interrupts again,
spitting this:

------------[ cut here ]------------
WARNING: at kernel/softirq.c:143 local_bh_enable+0x3c/0x86()
Hardware name: Precision WorkStation 490
Modules linked in: netconsole bonding sunrpc ip6t_REJECT xt_tcpudp nf_conntrack_ipv6]
Pid: 17, comm: events/2 Not tainted 2.6.34-04700-gd938a70 #21
Call Trace:
 [<ffffffff810381d6>] warn_slowpath_common+0x77/0x8f
 [<ffffffff810381fd>] warn_slowpath_null+0xf/0x11
 [<ffffffff8103d691>] local_bh_enable+0x3c/0x86
 [<ffffffff812e4d85>] dev_queue_xmit+0x462/0x493
 [<ffffffffa018805f>] bond_dev_queue_xmit+0x1bd/0x1e3 [bonding]
 [<ffffffffa01881dd>] bond_start_xmit+0x158/0x37b [bonding]
-> interrupts disabled
 [<ffffffff812f3fca>] queue_process+0x9d/0xf9
 [<ffffffff8104d022>] worker_thread+0x19d/0x224
 [<ffffffff812f3f2d>] ? queue_process+0x0/0xf9
 [<ffffffff81050819>] ? autoremove_wake_function+0x0/0x34
 [<ffffffff8104ce85>] ? worker_thread+0x0/0x224
 [<ffffffff8105040b>] kthread+0x7a/0x82
 [<ffffffff810036d4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81050391>] ? kthread+0x0/0x82
 [<ffffffff810036d0>] ? kernel_thread_helper+0x0/0x10
---[ end trace 74e3904503fdb632 ]---

kernel/softirq.c:
141 static inline void _local_bh_enable_ip(unsigned long ip)
142 {
143         WARN_ON_ONCE(in_irq() || irqs_disabled());
144 #ifdef CONFIG_TRACE_IRQFLAGS
145         local_irq_disable();
146 #endif
147         /*
148          * Are softirqs going to be turned on now:
149          */


The git is updated up to:
  d938a70 be2net: increase POST timeout for EEH recovery

Two slave interfaces, bonding mode 1, netconsole over bond0.

[1] https://bugzilla.redhat.com/show_bug.cgi?id=248374#c5


regards,
fbl


On Wed, May 05, 2010 at 04:11:15AM -0400, Amerigo Wang wrote:
> V5:
> Fix coding style problems pointed by David.
> 
> V4:
> Use "unlikely" to mark netpoll call path, suggested by Stephen.
> Handle NETDEV_GOING_DOWN case.
> 
> V3:
> Update to latest Linus' tree.
> Fix deadlocks when releasing slaves of bonding devices.
> Thanks to Andy.
> 
> V2:
> Fix some bugs of previous version.
> Remove ->netpoll_setup and ->netpoll_xmit, they are not necessary.
> Don't poll all underlying devices, poll ->real_dev in struct netpoll.
> Thanks to David for suggesting above.
> 
> ------------>
> 
> This whole patchset is for adding netpoll support to bridge and bonding
> devices. I already tested it for bridge, bonding, bridge over bonding,
> and bonding over bridge. It looks fine now.
> 
> 
> To make bridge and bonding support netpoll, we need to adjust
> some netpoll generic code. This patch does the following things:
> 
> 1) introduce two new priv_flags for struct net_device:
>    IFF_IN_NETPOLL which identifies we are processing a netpoll;
>    IFF_DISABLE_NETPOLL is used to disable netpoll support for a device
>    at run-time;
> 
> 2) introduce one new method for netdev_ops:
>    ->ndo_netpoll_cleanup() is used to clean up netpoll when a device is
>      removed.
> 
> 3) introduce netpoll_poll_dev() which takes a struct net_device * parameter;
>    export netpoll_send_skb() and netpoll_poll_dev() which will be used later;
> 
> 4) hide a pointer to struct netpoll in struct netpoll_info, ditto.
> 
> 5) introduce ->real_dev for struct netpoll.
> 
> 6) introduce a new status NETDEV_BONDING_DESLAE, which is used to disable
>    netconsole before releasing a slave, to avoid deadlocks.
> 
> Cc: David Miller <davem@davemloft.net>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: WANG Cong <amwang@redhat.com>
> 
> ---
> 
> Index: linux-2.6/include/linux/if.h
> ===================================================================
> --- linux-2.6.orig/include/linux/if.h
> +++ linux-2.6/include/linux/if.h
> @@ -71,6 +71,8 @@
>  					 * release skb->dst
>  					 */
>  #define IFF_DONT_BRIDGE 0x800		/* disallow bridging this ether dev */
> +#define IFF_IN_NETPOLL	0x1000		/* whether we are processing netpoll */
> +#define IFF_DISABLE_NETPOLL	0x2000	/* disable netpoll at run-time */
>  
>  #define IF_GET_IFACE	0x0001		/* for querying only */
>  #define IF_GET_PROTO	0x0002
> Index: linux-2.6/include/linux/netdevice.h
> ===================================================================
> --- linux-2.6.orig/include/linux/netdevice.h
> +++ linux-2.6/include/linux/netdevice.h
> @@ -667,6 +667,7 @@ struct net_device_ops {
>  						        unsigned short vid);
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	void                    (*ndo_poll_controller)(struct net_device *dev);
> +	void			(*ndo_netpoll_cleanup)(struct net_device *dev);
>  #endif
>  	int			(*ndo_set_vf_mac)(struct net_device *dev,
>  						  int queue, u8 *mac);
> Index: linux-2.6/include/linux/netpoll.h
> ===================================================================
> --- linux-2.6.orig/include/linux/netpoll.h
> +++ linux-2.6/include/linux/netpoll.h
> @@ -14,6 +14,7 @@
>  
>  struct netpoll {
>  	struct net_device *dev;
> +	struct net_device *real_dev;
>  	char dev_name[IFNAMSIZ];
>  	const char *name;
>  	void (*rx_hook)(struct netpoll *, int, char *, int);
> @@ -36,8 +37,11 @@ struct netpoll_info {
>  	struct sk_buff_head txq;
>  
>  	struct delayed_work tx_work;
> +
> +	struct netpoll *netpoll;
>  };
>  
> +void netpoll_poll_dev(struct net_device *dev);
>  void netpoll_poll(struct netpoll *np);
>  void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
>  void netpoll_print_options(struct netpoll *np);
> @@ -47,6 +51,7 @@ int netpoll_trap(void);
>  void netpoll_set_trap(int trap);
>  void netpoll_cleanup(struct netpoll *np);
>  int __netpoll_rx(struct sk_buff *skb);
> +void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb);
>  
>  
>  #ifdef CONFIG_NETPOLL
> Index: linux-2.6/net/core/netpoll.c
> ===================================================================
> --- linux-2.6.orig/net/core/netpoll.c
> +++ linux-2.6/net/core/netpoll.c
> @@ -179,9 +179,8 @@ static void service_arp_queue(struct net
>  	}
>  }
>  
> -void netpoll_poll(struct netpoll *np)
> +void netpoll_poll_dev(struct net_device *dev)
>  {
> -	struct net_device *dev = np->dev;
>  	const struct net_device_ops *ops;
>  
>  	if (!dev || !netif_running(dev))
> @@ -201,6 +200,11 @@ void netpoll_poll(struct netpoll *np)
>  	zap_completion_queue();
>  }
>  
> +void netpoll_poll(struct netpoll *np)
> +{
> +	netpoll_poll_dev(np->dev);
> +}
> +
>  static void refill_skbs(void)
>  {
>  	struct sk_buff *skb;
> @@ -282,7 +286,7 @@ static int netpoll_owner_active(struct n
>  	return 0;
>  }
>  
> -static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
> +void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
>  {
>  	int status = NETDEV_TX_BUSY;
>  	unsigned long tries;
> @@ -308,7 +312,9 @@ static void netpoll_send_skb(struct netp
>  		     tries > 0; --tries) {
>  			if (__netif_tx_trylock(txq)) {
>  				if (!netif_tx_queue_stopped(txq)) {
> +					dev->priv_flags |= IFF_IN_NETPOLL;
>  					status = ops->ndo_start_xmit(skb, dev);
> +					dev->priv_flags &= ~IFF_IN_NETPOLL;
>  					if (status == NETDEV_TX_OK)
>  						txq_trans_update(txq);
>  				}
> @@ -756,7 +762,10 @@ int netpoll_setup(struct netpoll *np)
>  		atomic_inc(&npinfo->refcnt);
>  	}
>  
> -	if (!ndev->netdev_ops->ndo_poll_controller) {
> +	npinfo->netpoll = np;
> +
> +	if ((ndev->priv_flags & IFF_DISABLE_NETPOLL) ||
> +	    !ndev->netdev_ops->ndo_poll_controller) {
>  		printk(KERN_ERR "%s: %s doesn't support polling, aborting.\n",
>  		       np->name, np->dev_name);
>  		err = -ENOTSUPP;
> @@ -878,6 +887,7 @@ void netpoll_cleanup(struct netpoll *np)
>  			}
>  
>  			if (atomic_dec_and_test(&npinfo->refcnt)) {
> +				const struct net_device_ops *ops;
>  				skb_queue_purge(&npinfo->arp_tx);
>  				skb_queue_purge(&npinfo->txq);
>  				cancel_rearming_delayed_work(&npinfo->tx_work);
> @@ -885,7 +895,11 @@ void netpoll_cleanup(struct netpoll *np)
>  				/* clean after last, unfinished work */
>  				__skb_queue_purge(&npinfo->txq);
>  				kfree(npinfo);
> -				np->dev->npinfo = NULL;
> +				ops = np->dev->netdev_ops;
> +				if (ops->ndo_netpoll_cleanup)
> +					ops->ndo_netpoll_cleanup(np->dev);
> +				else
> +					np->dev->npinfo = NULL;
>  			}
>  		}
>  
> @@ -908,6 +922,7 @@ void netpoll_set_trap(int trap)
>  		atomic_dec(&trapped);
>  }
>  
> +EXPORT_SYMBOL(netpoll_send_skb);
>  EXPORT_SYMBOL(netpoll_set_trap);
>  EXPORT_SYMBOL(netpoll_trap);
>  EXPORT_SYMBOL(netpoll_print_options);
> @@ -915,4 +930,5 @@ EXPORT_SYMBOL(netpoll_parse_options);
>  EXPORT_SYMBOL(netpoll_setup);
>  EXPORT_SYMBOL(netpoll_cleanup);
>  EXPORT_SYMBOL(netpoll_send_udp);
> +EXPORT_SYMBOL(netpoll_poll_dev);
>  EXPORT_SYMBOL(netpoll_poll);
> Index: linux-2.6/drivers/net/netconsole.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/netconsole.c
> +++ linux-2.6/drivers/net/netconsole.c
> @@ -665,7 +665,8 @@ static int netconsole_netdev_event(struc
>  	struct netconsole_target *nt;
>  	struct net_device *dev = ptr;
>  
> -	if (!(event == NETDEV_CHANGENAME || event == NETDEV_UNREGISTER))
> +	if (!(event == NETDEV_CHANGENAME || event == NETDEV_UNREGISTER ||
> +	      event == NETDEV_BONDING_DESLAVE || event == NETDEV_GOING_DOWN))
>  		goto done;
>  
>  	spin_lock_irqsave(&target_list_lock, flags);
> @@ -677,19 +678,21 @@ static int netconsole_netdev_event(struc
>  				strlcpy(nt->np.dev_name, dev->name, IFNAMSIZ);
>  				break;
>  			case NETDEV_UNREGISTER:
> -				if (!nt->enabled)
> -					break;
>  				netpoll_cleanup(&nt->np);
> +				/* Fall through */
> +			case NETDEV_GOING_DOWN:
> +			case NETDEV_BONDING_DESLAVE:
>  				nt->enabled = 0;
> -				printk(KERN_INFO "netconsole: network logging stopped"
> -					", interface %s unregistered\n",
> -					dev->name);
>  				break;
>  			}
>  		}
>  		netconsole_target_put(nt);
>  	}
>  	spin_unlock_irqrestore(&target_list_lock, flags);
> +	if (event == NETDEV_UNREGISTER || event == NETDEV_BONDING_DESLAVE)
> +		printk(KERN_INFO "netconsole: network logging stopped, "
> +			"interface %s %s\n",  dev->name,
> +			event == NETDEV_UNREGISTER ? "unregistered" : "released slaves");
>  
>  done:
>  	return NOTIFY_DONE;
> Index: linux-2.6/include/linux/notifier.h
> ===================================================================
> --- linux-2.6.orig/include/linux/notifier.h
> +++ linux-2.6/include/linux/notifier.h
> @@ -203,6 +203,7 @@ static inline int notifier_to_errno(int 
>  #define NETDEV_BONDING_NEWTYPE  0x000F
>  #define NETDEV_POST_INIT	0x0010
>  #define NETDEV_UNREGISTER_BATCH 0x0011
> +#define NETDEV_BONDING_DESLAVE  0x0012
>  
>  #define SYS_DOWN	0x0001	/* Notify of system down */
>  #define SYS_RESTART	SYS_DOWN
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Flavio
