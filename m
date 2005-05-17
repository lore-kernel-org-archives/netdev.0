From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 11/12] orinoco: monitor mode support
Date: Tue, 17 May 2005 23:22:17 +0200
Message-ID: <20050517212217.GB12936@electric-eye.fr.zoreil.com>
References: <20050514153100.GL3643@lst.de> <20050514173947.GA32235@electric-eye.fr.zoreil.com> <1116358994.5534.2.camel@dv.roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, jgarzik@pobox.com,
        hermes@gibson.dropbear.id.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pavel Roskin <proski@gnu.org>
Content-Disposition: inline
In-Reply-To: <1116358994.5534.2.camel@dv.roinet.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pavel Roskin <proski@gnu.org> :
> On Sat, 2005-05-14 at 19:39 +0200, Francois Romieu wrote:
> > > + drop:
> > > +	stats->rx_errors++;
> > > +	stats->rx_dropped++;
> > > +}
> > 
> > -> leak (skb).
> 
> Indeed.  Thank you!  Please apply this on top of the original patches:
> 
> Signed-off-by: Pavel Roskin <proski@gnu.org>
> 
> --- orinoco.c
> +++ orinoco.c
> @@ -1180,7 +1180,7 @@ static void orinoco_rx_monitor(struct ne
>  	u16 fc;
>  	int err;
>  	int len;
> -	struct sk_buff *skb;
> +	struct sk_buff *skb = NULL;
>  	struct orinoco_private *priv = netdev_priv(dev);
>  	struct net_device_stats *stats = &priv->stats;
>  	hermes_t *hw = &priv->hw;
> @@ -1268,6 +1268,8 @@ static void orinoco_rx_monitor(struct ne
>   drop:
>  	stats->rx_errors++;
>  	stats->rx_dropped++;
> +	if (skb)
> +		dev_kfree_skb_irq(skb);
>  }
>  
>  static void __orinoco_ev_rx(struct net_device *dev, hermes_t *hw)
> 
> 

I am not fond of unneeded/hidden state variable. What about:

+       /* sanity check the length */
+       if (datalen > IEEE80211_DATA_LEN + 12) {
+               printk(KERN_DEBUG "%s: oversized monitor frame, "
+                      "data length = %d\n", dev->name, datalen);
+               err = -EIO;
+               goto drop;
                ^^^^^^^^^^ -> let's replace by 'goto update_stats;'
And turn:
+   drop:
+       stats->rx_errors++;
+       stats->rx_dropped++;

into:

+   drop:
+       dev_kfree_skb_irq(skb);     
+   update_stats:
+       stats->rx_errors++;
+       stats->rx_dropped++;

This way 'goto drop' really drops and the code does not issue a 'goto drop'
when it actually want to update the stats.

--
Ueimor
