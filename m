From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 net-next 2/4] net: dev: add batching to net_device
 notifiers
Date: Sat, 6 Feb 2016 20:58:37 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1602062023180.1718@ja.home.ssi.bg>
References: <1454628956-4803-1-git-send-email-noureddine@arista.com> <1454628956-4803-3-git-send-email-noureddine@arista.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
To: Salam Noureddine <noureddine@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:39769 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753211AbcBFS7L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Feb 2016 13:59:11 -0500
In-Reply-To: <1454628956-4803-3-git-send-email-noureddine@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 4 Feb 2016, Salam Noureddine wrote:

> @@ -1572,12 +1583,17 @@ rollback:
>  				call_netdevice_notifier(nb, NETDEV_GOING_DOWN,
>  							dev);
>  				call_netdevice_notifier(nb, NETDEV_DOWN, dev);
> +				call_netdevice_notifier(nb, NETDEV_DOWN_BATCH,
> +							dev);

	I now see that we should split the loop
here, so that NETDEV_DOWN_BATCH is called only once per net:

		bool down = false;

                for_each_netdev(net, dev) {
                        if (dev == last)
                                break;

                        if (dev->flags & IFF_UP) {
                                call_netdevice_notifier(nb, NETDEV_GOING_DOWN,
                                                        dev);
                                call_netdevice_notifier(nb, NETDEV_DOWN, dev);
				down = true;
                        }
                }

		rt_cache_flush and arp_ifdown_all will be called
		on NETDEV_UNREGISTER_BATCH, so use 'down' flag:

		if (down)
			call_netdevice_notifier(nb, NETDEV_DOWN_BATCH,
						net->loopback_dev);
                for_each_netdev(net, dev) {
                        if (dev == last)
                                goto outroll;
                        call_netdevice_notifier(nb, NETDEV_UNREGISTER, dev);
                }
		call_netdevice_notifier(nb, NETDEV_UNREGISTER_BATCH,
					net->loopback_dev);


>  			}
>  			call_netdevice_notifier(nb, NETDEV_UNREGISTER, dev);
>  		}
> +		call_netdevice_notifier(nb, NETDEV_UNREGISTER_BATCH,
> +					net->loopback_dev);
>  	}
>  
>  outroll:
> +	call_netdevice_notifier(nb, NETDEV_UNREGISTER_BATCH, last);
>  	raw_notifier_chain_unregister(&netdev_chain, nb);
>  	goto unlock;
>  }
> @@ -1614,9 +1630,13 @@ int unregister_netdevice_notifier(struct notifier_block *nb)
>  				call_netdevice_notifier(nb, NETDEV_GOING_DOWN,
>  							dev);
>  				call_netdevice_notifier(nb, NETDEV_DOWN, dev);
> +				call_netdevice_notifier(nb, NETDEV_DOWN_BATCH,
> +							dev);

	Same here, split loop for NETDEV_DOWN_BATCH because
arp_ifdown_all is slow.

>  			}
>  			call_netdevice_notifier(nb, NETDEV_UNREGISTER, dev);
>  		}
> +		call_netdevice_notifier(nb, NETDEV_UNREGISTER_BATCH,
> +					net->loopback_dev);
>  	}
>  unlock:
>  	rtnl_unlock();

>  static void rollback_registered_many(struct list_head *head)
>  {
>  	struct net_device *dev, *tmp;
> +	struct net *net, *net_tmp;
>  	LIST_HEAD(close_head);
> +	LIST_HEAD(net_head);
>  
>  	BUG_ON(dev_boot_phase);
>  	ASSERT_RTNL();
> @@ -6465,8 +6489,6 @@ static void rollback_registered_many(struct list_head *head)
>  	synchronize_net();
>  
>  	list_for_each_entry(dev, head, unreg_list) {
> -		struct sk_buff *skb = NULL;
> -
>  		/* Shutdown queueing discipline. */
>  		dev_shutdown(dev);
>  
> @@ -6475,6 +6497,20 @@ static void rollback_registered_many(struct list_head *head)
>  		   this device. They should clean all the things.
>  		*/
>  		call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
> +	}
> +
> +	/* call batch notifiers which act on net namespaces */
> +	list_for_each_entry(dev, head, unreg_list) {
> +		net_add_event_list(&net_head, dev_net(dev));

	Looks like we can move the above net_add_event_list with
the comment into the previous loop after NETDEV_UNREGISTER,
we will save some cycles.

> +	}
> +	list_for_each_entry_safe(net, net_tmp, &net_head, event_list) {
> +		call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH,
> +					 net->loopback_dev);
> +		net_del_event_list(net);
> +	}
> +
> +	list_for_each_entry(dev, head, unreg_list) {
> +		struct sk_buff *skb = NULL;
>  
>  		if (!dev->rtnl_link_ops ||
>  		    dev->rtnl_link_state == RTNL_LINK_INITIALIZED)

Regards
