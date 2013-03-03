From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 1/5] net: implement support for low latency socket
 polling
Date: Sun, 03 Mar 2013 10:35:04 -0800
Message-ID: <1362335704.15793.81.camel@edumazet-glaptop>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
	 <20130227175555.10611.42794.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130227175555.10611.42794.stgit@gitlad.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-02-27 at 09:55 -0800, Eliezer Tamir wrote:

> index 821c7f4..d1d1016 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -408,6 +408,10 @@ struct sk_buff {
>  	struct sock		*sk;
>  	struct net_device	*dev;
>  
> +#ifdef CONFIG_INET_LL_RX_POLL
> +	struct napi_struct	*dev_ref; /* where this skb came from */
> +#endif
> +
>  	/*
>  	 * This is the control buffer. It is free to use for every
>  	 * layer. Please put your private variables there. If you

Yes, thats the killer, because :

1) It adds 8 bytes per skb, and we are going to reach the 256 bytes per
sk_buff boundary. cloned skbs will use an extra cache line.

It might make sense to union this on dma_cookie, as dma_cookie is only
used on TX path.

2) We need to reference count napi structs.

For 2) , we would need to add a percpu ref counter (a bit like struct
netdevice -> pcpu_refcnt)

Alternative to 2) would be to use a generation id, incremented every
time a napi used in spin polling enabled driver is dismantled (and freed
after RCU grace period)

And store in sockets not only the pointer to napi_struct, but the
current generation id : If the generation id doesnt match, disable
the spinpoll until next packet rebuilds the cache again.
