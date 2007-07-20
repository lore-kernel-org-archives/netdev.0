From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [ofa-general] Re: [PATCH 02/10] Networking include file changes.
Date: Fri, 20 Jul 2007 10:25:05 -0700
Message-ID: <1184952305.12431.16.camel@localhost.localdomain>
References: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
	<20070720063216.26341.80316.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	kaber@trash.net, jagana@us.ibm.com,
	general@lists.openfabrics.org, netdev@vger.kernel.org,
	tgraf@suug.ch, jeff@garzik.org, hadi@cyberus.ca,
	davem@davemloft.net, mchan@broadcom.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070720063216.26341.80316.sendpatchset@localhost.localdomain>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-07-20 at 12:02 +0530, Krishna Kumar wrote:
> Networking include file changes for batching.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  linux/netdevice.h |   10 ++++++++++
>  net/pkt_sched.h   |    6 +++---
>  2 files changed, 13 insertions(+), 3 deletions(-)
> 
> diff -ruNp org/include/linux/netdevice.h new/include/linux/netdevice.h
> --- org/include/linux/netdevice.h	2007-07-20 07:49:28.000000000 +0530
> +++ new/include/linux/netdevice.h	2007-07-20 08:30:55.000000000 +0530
> @@ -264,6 +264,8 @@ enum netdev_state_t
>  	__LINK_STATE_QDISC_RUNNING,
>  };
> 
> +/* Minimum length of device hardware queue for batching to work */
> +#define MIN_QUEUE_LEN_BATCH	16
> 
>  /*
>   * This structure holds at boot time configured netdevice settings. They
> @@ -340,6 +342,7 @@ struct net_device
>  #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
>  #define NETIF_F_GSO		2048	/* Enable software GSO. */
>  #define NETIF_F_LLTX		4096	/* LockLess TX */
> +#define NETIF_F_BATCH_SKBS	8192	/* Driver supports batch skbs API */
>  #define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
> 
>  	/* Segmentation offload features */
> @@ -452,6 +455,8 @@ struct net_device
>  	struct Qdisc		*qdisc_sleeping;
>  	struct list_head	qdisc_list;
>  	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
> +	unsigned long		xmit_slots;	/* Device free slots */
> +	struct sk_buff_head	*skb_blist;	/* List of batch skbs */
> 
>  	/* Partially transmitted GSO packet. */
>  	struct sk_buff		*gso_skb;
> @@ -472,6 +477,9 @@ struct net_device
>  	void			*priv;	/* pointer to private data	*/
>  	int			(*hard_start_xmit) (struct sk_buff *skb,
>  						    struct net_device *dev);
> +	int			(*hard_start_xmit_batch) (struct net_device
> +							  *dev);
> +
>  	/* These may be needed for future network-power-down code. */
>  	unsigned long		trans_start;	/* Time (in jiffies) of last Tx	*/
> 
> @@ -832,6 +840,8 @@ extern int		dev_set_mac_address(struct n
>  					    struct sockaddr *);
>  extern int		dev_hard_start_xmit(struct sk_buff *skb,
>  					    struct net_device *dev);
> +extern int		dev_add_skb_to_blist(struct sk_buff *skb,
> +					     struct net_device *dev);
> 
>  extern void		dev_init(void);
> 
> diff -ruNp org/include/net/pkt_sched.h new/include/net/pkt_sched.h
> --- org/include/net/pkt_sched.h	2007-07-20 07:49:28.000000000 +0530
> +++ new/include/net/pkt_sched.h	2007-07-20 08:30:22.000000000 +0530
> @@ -80,13 +80,13 @@ extern struct qdisc_rate_table *qdisc_ge
>  		struct rtattr *tab);
>  extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
> 
> -extern void __qdisc_run(struct net_device *dev);
> +extern void __qdisc_run(struct net_device *dev, struct sk_buff_head *blist);

Why do we need this additional 'blist' argument?
Is this different from dev->skb_blist?

> 
> -static inline void qdisc_run(struct net_device *dev)
> +static inline void qdisc_run(struct net_device *dev, struct sk_buff_head *blist)
>  {
>  	if (!netif_queue_stopped(dev) &&
>  	    !test_and_set_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
> -		__qdisc_run(dev);
> +		__qdisc_run(dev, blist);
>  }
> 
>  extern int tc_classify_compat(struct sk_buff *skb, struct tcf_proto *tp,
