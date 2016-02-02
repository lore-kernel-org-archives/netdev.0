From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 2/4] net: dev: add batching to net_device
 notifiers
Date: Tue, 2 Feb 2016 22:55:06 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1602022219010.2006@ja.home.ssi.bg>
References: <1454365952-10324-1-git-send-email-noureddine@arista.com> <1454365952-10324-3-git-send-email-noureddine@arista.com>
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
Received: from ja.ssi.bg ([178.16.129.10]:40013 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932913AbcBBUz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 15:55:28 -0500
In-Reply-To: <1454365952-10324-3-git-send-email-noureddine@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 1 Feb 2016, Salam Noureddine wrote:

> @@ -1572,8 +1582,12 @@ rollback:
>  				call_netdevice_notifier(nb, NETDEV_GOING_DOWN,
>  							dev);
>  				call_netdevice_notifier(nb, NETDEV_DOWN, dev);
> +				call_netdevice_notifier(nb, NETDEV_DOWN_BATCH,
> +							dev);
>  			}
>  			call_netdevice_notifier(nb, NETDEV_UNREGISTER, dev);
> +			call_netdevice_notifier(nb, NETDEV_UNREGISTER_BATCH,
> +						dev);

			If the rule is once per net, the above call...

>  		}

		should be here:

		call_netdevice_notifier(nb, NETDEV_UNREGISTER_BATCH,
					net->loopback_dev);

	and also once after outroll label?:

	call_netdevice_notifier(nb, NETDEV_UNREGISTER_BATCH, last);

>  	}
>  
> @@ -1614,8 +1628,12 @@ int unregister_netdevice_notifier(struct notifier_block *nb)
>  				call_netdevice_notifier(nb, NETDEV_GOING_DOWN,
>  							dev);
>  				call_netdevice_notifier(nb, NETDEV_DOWN, dev);
> +				call_netdevice_notifier(nb, NETDEV_DOWN_BATCH,
> +							dev);
>  			}
>  			call_netdevice_notifier(nb, NETDEV_UNREGISTER, dev);
> +			call_netdevice_notifier(nb, NETDEV_UNREGISTER_BATCH,
> +						dev);

			Above call...

>  		}

		should be here, for net->loopback_dev?
Also, is it ok to call NETDEV_DOWN_BATCH many times, as result,
sometimes after NETDEV_UNREGISTER?

>  	}
>  unlock:

> @@ -6427,7 +6447,9 @@ static void net_set_todo(struct net_device *dev)
>  static void rollback_registered_many(struct list_head *head)
>  {
>  	struct net_device *dev, *tmp;
> +	struct net *net, *net_tmp;
>  	LIST_HEAD(close_head);
> +	LIST_HEAD(net_head);
>  
>  	BUG_ON(dev_boot_phase);
>  	ASSERT_RTNL();
> @@ -6504,6 +6526,15 @@ static void rollback_registered_many(struct list_head *head)
>  #endif
>  	}
>  
> +	list_for_each_entry(dev, head, unreg_list) {
> +		net_add_event_list(&net_head, dev_net(dev));
> +	}
> +	list_for_each_entry_safe(net, net_tmp, &net_head, event_list) {
> +		call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH,
> +					 net->loopback_dev);
> +		net_del_event_list(net);
> +	}
> +

	NETDEV_UNREGISTER* should not be called before
following synchronize_net and NETDEV_UNREGISTER. May be
we should split the loop: loop (dev_shutdown+NETDEV_UNREGISTER)
followed by above NETDEV_UNREGISTER_BATCH then again the
loop for all remaining calls.

>  	synchronize_net();
>  
>  	list_for_each_entry(dev, head, unreg_list)

Regards
