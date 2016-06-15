From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 01/10] net_sched: add the ability to defer skb
 freeing
Date: Wed, 15 Jun 2016 14:33:46 +0200
Message-ID: <20160615143346.2300e64b@redhat.com>
References: <1465874519-25494-1-git-send-email-edumazet@google.com>
	<1465874519-25494-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37358 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753129AbcFOMdw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 08:33:52 -0400
In-Reply-To: <1465874519-25494-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Jun 2016 20:21:50 -0700
Eric Dumazet <edumazet@google.com> wrote:

> qdisc are changed under RTNL protection and often
> while blocking BH and root qdisc spinlock.
> 
> When lots of skbs need to be dropped, we free
> them under these locks causing TX/RX freezes,
> and more generally latency spikes.
> 
> This commit adds rtnl_kfree_skbs(), used to queue
> skbs for deferred freeing.
> 
> Actual freeing happens right after RTNL is released,
> with appropriate scheduling points.
> 
> rtnl_qdisc_drop() can also be used in place
> of disc_drop() when RTNL is held.
> 
> qdisc_reset_queue() and __qdisc_reset_queue() get
> the new behavior, so standard qdiscs like pfifo, pfifo_fast...
> have their ->reset() method automatically handled.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/linux/rtnetlink.h |  5 +++--
>  include/net/sch_generic.h | 16 ++++++++++++----
>  net/core/rtnetlink.c      | 22 ++++++++++++++++++++++
>  net/sched/sch_generic.c   |  2 +-
>  4 files changed, 38 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
> index c006cc900c44..2daece8979f7 100644
> --- a/include/linux/rtnetlink.h
> +++ b/include/linux/rtnetlink.h
[...]
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index d69c4644f8f2..eb49ca24274a 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -71,9 +71,31 @@ void rtnl_lock(void)
>  }
>  EXPORT_SYMBOL(rtnl_lock);
>  
> +static struct sk_buff *defer_kfree_skb_list;
> +void rtnl_kfree_skbs(struct sk_buff *head, struct sk_buff *tail)
> +{
> +	if (head && tail) {
> +		tail->next = defer_kfree_skb_list;
> +		defer_kfree_skb_list = head;
> +	}
> +}
> +EXPORT_SYMBOL(rtnl_kfree_skbs);
> +
>  void __rtnl_unlock(void)
>  {
> +	struct sk_buff *head = defer_kfree_skb_list;
> +
> +	defer_kfree_skb_list = NULL;
> +
>  	mutex_unlock(&rtnl_mutex);
> +
> +	while (head) {
> +		struct sk_buff *next = head->next;
> +
> +		kfree_skb(head);
> +		cond_resched();
> +		head = next;
> +	}
>  }

This looks a lot like kfree_skb_list()....

What about bulk free'ing SKBs here?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
