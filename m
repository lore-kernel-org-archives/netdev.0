From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH] net: devmap fix mutex in rcu critical section
Date: Fri, 04 Aug 2017 14:58:15 -0700
Message-ID: <5984EDF7.3060808@gmail.com>
References: <20170804212132.7678.11425.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, daniel@iogearbox.net,
        alexander.levin@verizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:38798 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751312AbdHDV6Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 17:58:25 -0400
Received: by mail-pg0-f66.google.com with SMTP id 123so2849195pga.5
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 14:58:25 -0700 (PDT)
In-Reply-To: <20170804212132.7678.11425.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/04/2017 02:21 PM, John Fastabend wrote:
> Originally we used a mutex to protect concurrent devmap update
> and delete operations from racing with netdev unregister notifier
> callbacks.
> 

[...]

>  }
> @@ -396,22 +385,20 @@ static int dev_map_notification(struct notifier_block *notifier,
>  

Daniel reminds me this is not in a rcu_read_lock/unlock() section as
needed, so v2 on its way. Thanks!

>  	switch (event) {
>  	case NETDEV_UNREGISTER:
> -		mutex_lock(&dev_map_list_mutex);

		rcu_read_lock();

>  		list_for_each_entry(dtab, &dev_map_list, list) {
>  			for (i = 0; i < dtab->map.max_entries; i++) {
> -				struct bpf_dtab_netdev *dev;
> +				struct bpf_dtab_netdev *dev, *odev;
>  
> -				dev = dtab->netdev_map[i];
> +				dev = READ_ONCE(dtab->netdev_map[i]);
>  				if (!dev ||
>  				    dev->dev->ifindex != netdev->ifindex)
>  					continue;
> -				dev = xchg(&dtab->netdev_map[i], NULL);
> -				if (dev)
> +				odev = cmpxchg(&dtab->netdev_map[i], dev, NULL);
> +				if (dev == odev)
>  					call_rcu(&dev->rcu,
>  						 __dev_map_entry_free);
>  			}
>  		}

		rcu_read_unlock();

> -		mutex_unlock(&dev_map_list_mutex);
>  		break;
>  	default:
>  		break;
> 
