From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next RFC 6/9] net: dsa: forward timestamping callbacks
 to switch drivers
Date: Thu, 28 Sep 2017 10:40:05 -0700
Message-ID: <c4b98f32-c495-623a-53b0-56c1cdf9806a@gmail.com>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-7-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>
To: Brandon Streiff <brandon.streiff@ni.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506612341-18061-7-git-send-email-brandon.streiff@ni.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/28/2017 08:25 AM, Brandon Streiff wrote:
> Forward the rx/tx timestamp machinery from the dsa infrastructure to the
> switch driver.
> 
> On the rx side, defer delivery of skbs until we have an rx timestamp.
> This mimicks the behavior of skb_defer_rx_timestamp. The implementation
> does have to thread through the tagging protocol handlers because
> it is where that we know which switch and port the skb goes to.
> 
> On the tx side, identify PTP packets, clone them, and pass them to the
> underlying switch driver before we transmit. This mimicks the behavior
> of skb_tx_timestamp.
> 
> Signed-off-by: Brandon Streiff <brandon.streiff@ni.com>
> ---
>  include/net/dsa.h     | 13 +++++++++++--
>  net/dsa/dsa.c         | 39 ++++++++++++++++++++++++++++++++++++++-
>  net/dsa/slave.c       | 25 +++++++++++++++++++++++++
>  net/dsa/tag_brcm.c    |  6 +++++-
>  net/dsa/tag_dsa.c     |  6 +++++-
>  net/dsa/tag_edsa.c    |  6 +++++-
>  net/dsa/tag_ksz.c     |  6 +++++-
>  net/dsa/tag_lan9303.c |  6 +++++-
>  net/dsa/tag_mtk.c     |  6 +++++-
>  net/dsa/tag_qca.c     |  6 +++++-
>  net/dsa/tag_trailer.c |  6 +++++-
>  11 files changed, 114 insertions(+), 11 deletions(-)
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index 1163af1..4daf7f7 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -101,11 +101,14 @@ struct dsa_platform_data {
>  };
>  
>  struct packet_type;
> +struct dsa_switch;
>  
>  struct dsa_device_ops {
>  	struct sk_buff *(*xmit)(struct sk_buff *skb, struct net_device *dev);
>  	struct sk_buff *(*rcv)(struct sk_buff *skb, struct net_device *dev,
> -			       struct packet_type *pt);
> +			       struct packet_type *pt,
> +			       struct dsa_switch **src_dev,
> +			       int *src_port);
>  	int (*flow_dissect)(const struct sk_buff *skb, __be16 *proto,
>  			    int *offset);
>  };
> @@ -134,7 +137,9 @@ struct dsa_switch_tree {
>  	/* Copy of tag_ops->rcv for faster access in hot path */
>  	struct sk_buff *	(*rcv)(struct sk_buff *skb,
>  				       struct net_device *dev,
> -				       struct packet_type *pt);
> +				       struct packet_type *pt,
> +				       struct dsa_switch **src_dev,
> +				       int *src_port);
>  
>  	/*
>  	 * The switch port to which the CPU is attached.
> @@ -449,6 +454,10 @@ struct dsa_switch_ops {
>  				     struct ifreq *ifr);
>  	int	(*port_hwtstamp_set)(struct dsa_switch *ds, int port,
>  				     struct ifreq *ifr);
> +	void	(*port_txtstamp)(struct dsa_switch *ds, int port,
> +				 struct sk_buff *clone, unsigned int type);
> +	bool	(*port_rxtstamp)(struct dsa_switch *ds, int port,
> +				 struct sk_buff *skb, unsigned int type);
>  };
>  
>  struct dsa_switch_driver {
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 81c852e..42e7286 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -22,6 +22,7 @@
>  #include <linux/netdevice.h>
>  #include <linux/sysfs.h>
>  #include <linux/phy_fixed.h>
> +#include <linux/ptp_classify.h>
>  #include <linux/gpio/consumer.h>
>  #include <linux/etherdevice.h>
>  
> @@ -157,6 +158,37 @@ struct net_device *dsa_dev_to_net_device(struct device *dev)
>  }
>  EXPORT_SYMBOL_GPL(dsa_dev_to_net_device);
>  
> +/* Determine if we should defer delivery of skb until we have a rx timestamp.
> + *
> + * Called from dsa_switch_rcv. For now, this will only work if tagging is
> + * enabled on the switch. Normally the MAC driver would retrieve the hardware
> + * timestamp when it reads the packet out of the hardware. However in a DSA
> + * switch, the DSA driver owning the interface to which the packet is
> + * delivered is never notified unless we do so here.
> + */
> +static bool dsa_skb_defer_rx_timestamp(struct dsa_switch *ds, int port,
> +				       struct sk_buff *skb)

You should not need the port information here because it's already
implied from skb->dev which points to the DSA slave network device, see
below.

> +{
> +	unsigned int type;
> +
> +	if (skb_headroom(skb) < ETH_HLEN)
> +		return false;

Are you positive this is necessary? Because we called dst->rcv() we have
called eth_type_trans() which already made sure about that

> +
> +	__skb_push(skb, ETH_HLEN);
> +
> +	type = ptp_classify_raw(skb);
> +
> +	__skb_pull(skb, ETH_HLEN);
> +
> +	if (type == PTP_CLASS_NONE)
> +		return false;
> +
> +	if (likely(ds->ops->port_rxtstamp))
> +		return ds->ops->port_rxtstamp(ds, port, skb, type);
> +
> +	return false;
> +}

Can we also have a fast-path bypass in case time stamping is not
supported by the switch so we don't have to even try to classify this
packet only to realize we don't have a port_rxtsamp() operation later?
You can either gate this with a compile-time option, or use e.g: a
static key or something like an early test?

> +
>  static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
>  			  struct packet_type *pt, struct net_device *unused)
>  {
> @@ -164,6 +196,8 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
>  	struct sk_buff *nskb = NULL;
>  	struct pcpu_sw_netstats *s;
>  	struct dsa_slave_priv *p;
> +	struct dsa_switch *ds = NULL;
> +	int source_port;
>  
>  	if (unlikely(dst == NULL)) {
>  		kfree_skb(skb);
> @@ -174,7 +208,7 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
>  	if (!skb)
>  		return 0;
>  
> -	nskb = dst->rcv(skb, dev, pt);
> +	nskb = dst->rcv(skb, dev, pt, &ds, &source_port);

I don't think this is necessary, what dst->rcv() does is actually
properly assign skb->dev to the correct dsa slave network device, which
has the information about the port number already in its private context.

>  	if (!nskb) {
>  		kfree_skb(skb);
>  		return 0;
> @@ -192,6 +226,9 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
>  	s->rx_bytes += skb->len;
>  	u64_stats_update_end(&s->syncp);
>  
> +	if (dsa_skb_defer_rx_timestamp(ds, source_port, skb))
> +		return 0;

Can we just propagate an integer return value from
dsa_skb_defer_rx_timestamp()?

> +
>  	netif_receive_skb(skb);
>  
>  	return 0;
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 2cf6a83..a278335 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -22,6 +22,7 @@
>  #include <net/tc_act/tc_mirred.h>
>  #include <linux/if_bridge.h>
>  #include <linux/netpoll.h>
> +#include <linux/ptp_classify.h>
>  
>  #include "dsa_priv.h"
>  
> @@ -407,6 +408,25 @@ static inline netdev_tx_t dsa_slave_netpoll_send_skb(struct net_device *dev,
>  	return NETDEV_TX_OK;
>  }
>  
> +static void dsa_skb_tx_timestamp(struct dsa_slave_priv *p,
> +				 struct sk_buff *skb)
> +{
> +	struct dsa_switch *ds = p->dp->ds;
> +	struct sk_buff *clone;
> +	unsigned int type;
> +
> +	type = ptp_classify_raw(skb);
> +	if (type == PTP_CLASS_NONE)
> +		return;

If we don't have a port_txtstamp option, is there even value in
classifying this packet?
-- 
Florian
