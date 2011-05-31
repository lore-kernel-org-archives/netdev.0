From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] ftrace: tracepoint of net_dev_xmit sees freed skb and
 causes panic
Date: Tue, 31 May 2011 11:13:11 -0400
Message-ID: <1306854791.11899.30.camel@gandalf.stny.rr.com>
References: <4DE49D52.709@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, mingo@elte.hu,
	fweisbec@gmail.com, mathieu.desnoyers@efficios.com,
	tglx@linutronix.de, kosaki.motohiro@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DE49D52.709@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-05-31 at 16:48 +0900, Koki Sanagi wrote:
> Because there is a possibility that skb is kfree_skb()ed and zero cleared
> after ndo_start_xmit, we should not see the contents of skb like skb->len and
> skb->dev->name after ndo_start_xmit. But trace_net_dev_xmit does that
> and causes panic by NULL pointer dereference.
> This patch fixes trace_net_dev_xmit not to see the contents of skb directly.


>  
>  	if (likely(!skb->next)) {
>  		u32 features;
> @@ -2139,8 +2140,9 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>  			}
>  		}
>  
> +		skb_len = skb->len;
>  		rc = ops->ndo_start_xmit(skb, dev);
> -		trace_net_dev_xmit(skb, rc);
> +		trace_net_dev_xmit(skb, rc, dev, skb_len);
>  		if (rc == NETDEV_TX_OK)
>  			txq_trans_update(txq);
>  		return rc;
> @@ -2160,8 +2162,9 @@ gso:
>  		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
>  			skb_dst_drop(nskb);
>  
> +		skb_len = nskb->len;
>  		rc = ops->ndo_start_xmit(nskb, dev);
> -		trace_net_dev_xmit(nskb, rc);
> +		trace_net_dev_xmit(nskb, rc, dev, skb_len);

What if you just put the tracepoint before the call to
ops->ndo_start_xmit?

-- Steve

>  		if (unlikely(rc != NETDEV_TX_OK)) {
>  			if (rc & ~NETDEV_TX_MASK)
>  				goto out_kfree_gso_skb;
