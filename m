From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] net: skb_queue_purge(): lock/unlock the list only
 once
Date: Fri, 08 Sep 2017 09:01:19 -0700
Message-ID: <1504886479.15310.74.camel@edumazet-glaptop3.roam.corp.google.com>
References: <45aab5effc0c424a992646a97cf2ec14-mfwitten@gmail.com>
         <60c8906b751d4915be456009c220516e-mfwitten@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Witten <mfwitten@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <60c8906b751d4915be456009c220516e-mfwitten@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-09-08 at 05:06 +0000, Michael Witten wrote:
> Date: Thu, 7 Sep 2017 20:07:40 +0000
> With this commit, the list's lock is locked/unlocked only once
> for the duration of `skb_queue_purge()'.
> 
> Hitherto, the list's lock has been locked/unlocked every time
> an item is dequeued; this seems not only inefficient, but also
> incorrect, as the whole point of `skb_queue_purge()' is to clear
> the list, presumably without giving anything else a chance to
> manipulate the list in the interim.
> 
> Signed-off-by: Michael Witten <mfwitten@gmail.com>
> ---
>  net/core/skbuff.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 68065d7d383f..66c0731a2a5f 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2834,9 +2834,13 @@ EXPORT_SYMBOL(skb_dequeue_tail);
>   */
>  void skb_queue_purge(struct sk_buff_head *list)
>  {
> +	unsigned long flags;
>  	struct sk_buff *skb;
> -	while ((skb = skb_dequeue(list)) != NULL)
> +
> +	spin_lock_irqsave(&list->lock, flags);
> +	while ((skb = __skb_dequeue(list)) != NULL)
>  		kfree_skb(skb);
> +	spin_unlock_irqrestore(&list->lock, flags);
>  }
>  EXPORT_SYMBOL(skb_queue_purge);
>  


No, this is very wrong :

Holding hard IRQ for a potential very long time is going to break
horribly. Some lists can have 10,000+ skbs in them.

Note that net-next tree is currently closed, please read 
Documentation/networking/netdev-FAQ.txt
