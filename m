From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Deadlock, L2TP over IP are not working, 3.4.1
Date: Thu, 07 Jun 2012 23:30:06 +0200
Message-ID: <1339104606.6001.4.camel@edumazet-glaptop>
References: <7ed49f446365ac625437702d92946add@visp.net.lb>
	 <20120607205356.GA2491@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120607205356.GA2491@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-06-07 at 22:53 +0200, Francois Romieu wrote:

> Any reason why it could not be made LLTX ?
> 

>  /* via l2tp_session_priv() */
> @@ -87,25 +95,56 @@ static int l2tp_eth_dev_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct l2tp_eth *priv = netdev_priv(dev);
>  	struct l2tp_session *session = priv->session;
> +	struct l2tp_eth_stats *tstats = &priv->tstats;
>  
>  	l2tp_xmit_skb(session, skb, session->hdr_len);
>  
> -	dev->stats.tx_bytes += skb->len;
> -	dev->stats.tx_packets++;
> +	u64_stats_update_begin(&tstats->syncp);
> +	tstats->packets++;
> +	tstats->bytes += skb->len;
> +	u64_stats_update_end(&tstats->syncp);
>  
>  	return 0;
>  }
>  

Its racy.

If LLTX is used, this means several cpus can execute this code at the
same time.

You need percpu stats, or use atomic primitives.
