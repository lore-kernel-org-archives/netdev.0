From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 6/6] net: Free skbs from irqs when possible.
Date: Tue, 18 Mar 2014 09:32:46 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6E0047@AcuExch.aculab.com>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
	<20140317.154916.2276987764507311378.davem@davemloft.net>
	<87iorcgh5d.fsf_-_@xmission.com> <87fvmgf2c7.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
	"mpm@selenic.com" <mpm@selenic.com>,
	"satyam.sharma@gmail.com" <satyam.sharma@gmail.com>
To: "'Eric W. Biederman'" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:52937 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754249AbaCRJeE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 05:34:04 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 18027-01 for <netdev@vger.kernel.org>;
 Tue, 18 Mar 2014 09:34:00 +0000 (GMT)
In-Reply-To: <87fvmgf2c7.fsf_-_@xmission.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Of Eric W.> Biederman
> Add a test skb_irq_freeable to report when it is safe to free a skb
> from irq context.
> 
> It is not safe to free an skb from irq context when:
> - The skb has a destructor as some skb destructors call local_bh_disable
>   or spin_lock_bh.
> - There is xfrm state as __xfrm_state_destroy calls spin_lock_bh.
> - There is netfilter conntrack state as destroy_conntrack calls
>   spin_lock_bh.
> - If there is a refcounted dst entry on the skb, as __dst_free
>   calls spin_lock_bh.
> - If there is a frag_list, which could be a list of any skbs.

That is a lot of conditions to check....

> Otherwise it appears safe to free a skb from interrupt context.
> 
> - Update the warning in skb_releae_head_state to warn about freeing
>   skb's in the wrong context.
> 
> - Update __dev_kfree_skb_irq to free all skbs that it can immediately
> 
> - Kill zap_completion_queue because there is no point going through
>   a queue of packets that are not safe to free and looking for packets
>   that are safe to free.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  include/linux/skbuff.h |   13 +++++++++++++
>  net/core/dev.c         |   14 +++++++++-----
>  net/core/netpoll.c     |   32 --------------------------------
>  net/core/skbuff.c      |   13 ++++++++++---
>  4 files changed, 32 insertions(+), 40 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 03db95ab8a8c..53f72b53fd47 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2833,6 +2833,19 @@ static inline void skb_init_secmark(struct sk_buff *skb)
>  { }
>  #endif
> 
> +static inline bool skb_irq_freeable(struct sk_buff *skb)
> +{
> +	return !skb->destructor &&
> +#if IS_ENABLED(CONFIG_XFRM)
> +		!skb->sp &&
> +#endif
> +#if IS_ENABLED(CONFIG_NF_CONNTRACK)
> +		!skb->nfct &&
> +#endif
> +		(!skb->_skb_refdst || (skb->_skb_refdst & SKB_DST_NOREF)) &&
> +		!skb_has_frag_list(skb);
> +}
> +
>  static inline void skb_set_queue_mapping(struct sk_buff *skb, u16 queue_mapping)
>  {
>  	skb->queue_mapping = queue_mapping;
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 8b3ea4058a5e..99fd079488aa 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2164,11 +2164,15 @@ void __dev_kfree_skb_irq(struct sk_buff *skb, enum skb_free_reason reason)
>  		return;
>  	}
>  	get_kfree_skb_cb(skb)->reason = reason;
> -	local_irq_save(flags);
> -	skb->next = __this_cpu_read(softnet_data.completion_queue);
> -	__this_cpu_write(softnet_data.completion_queue, skb);
> -	raise_softirq_irqoff(NET_TX_SOFTIRQ);
> -	local_irq_restore(flags);
> +	if (unlikely(skb_irq_freeable(skb))) {
> +		__kfree_skb(skb);
> +	} else {
> +		local_irq_save(flags);
> +		skb->next = __this_cpu_read(softnet_data.completion_queue);
> +		__this_cpu_write(softnet_data.completion_queue, skb);
> +		raise_softirq_irqoff(NET_TX_SOFTIRQ);
> +		local_irq_restore(flags);
> +	}

You've even marked the condition with 'unlikely'.
So I wonder how much you gain from the direct free?

	David
