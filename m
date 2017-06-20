From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 3/4] ipmr: add netlink notifications on
 igmpmsg cache reports
Date: Tue, 20 Jun 2017 12:33:12 +0300
Message-ID: <9d2287e9-f7cf-8a4f-ff6c-4b086a3b57bd@cumulusnetworks.com>
References: <20170619204417.13230-1-julien@arista.com>
 <20170619204417.13230-4-julien@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        sharpd@cumulusnetworks.com, nicolas.dichtel@6wind.com
To: Julien Gomes <julien@arista.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170619204417.13230-4-julien@arista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19/06/17 23:44, Julien Gomes wrote:
> Add Netlink notifications on cache reports in ipmr, in addition to the
> existing igmpmsg sent to mroute_sk.
> Send RTM_NEWCACHEREPORT notifications to RTNLGRP_IPV4_MROUTE_R.
> 
> MSGTYPE, VIF_ID, SRC_ADDR and DST_ADDR Netlink attributes contain the
> same data as their equivalent fields in the igmpmsg header.
> PKT attribute is the packet sent to mroute_sk, without the added igmpmsg
> header.
> 
> Suggested-by: Ryan Halbrook <halbrook@arista.com>
> Signed-off-by: Julien Gomes <julien@arista.com>
> ---
>  include/uapi/linux/mroute.h | 12 ++++++++
>  net/ipv4/ipmr.c             | 67 +++++++++++++++++++++++++++++++++++++++++++--
>  2 files changed, 77 insertions(+), 2 deletions(-)
> 
> diff --git a/include/uapi/linux/mroute.h b/include/uapi/linux/mroute.h
> index f904367c0cee..e8e5041dea8e 100644
> --- a/include/uapi/linux/mroute.h
> +++ b/include/uapi/linux/mroute.h
> @@ -152,6 +152,18 @@ enum {
>  };
>  #define IPMRA_VIFA_MAX (__IPMRA_VIFA_MAX - 1)
>  
> +/* ipmr netlink cache report attributes */
> +enum {
> +	IPMRA_CREPORT_UNSPEC,
> +	IPMRA_CREPORT_MSGTYPE,
> +	IPMRA_CREPORT_VIF_ID,
> +	IPMRA_CREPORT_SRC_ADDR,
> +	IPMRA_CREPORT_DST_ADDR,
> +	IPMRA_CREPORT_PKT,
> +	__IPMRA_CREPORT_MAX
> +};
> +#define IPMRA_CREPORT_MAX (__IPMRA_CREPORT_MAX - 1)
> +
>  /* That's all usermode folks */
>  
>  #define MFC_ASSERT_THRESH (3*HZ)		/* Maximal freq. of asserts */
> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index 3e7454aa49e8..1e591bcaad6d 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -109,6 +109,7 @@ static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
>  			      struct mfc_cache *c, struct rtmsg *rtm);
>  static void mroute_netlink_event(struct mr_table *mrt, struct mfc_cache *mfc,
>  				 int cmd);
> +static void igmpmsg_netlink_event(struct mr_table *mrt, struct sk_buff *pkt);
>  static void mroute_clean_tables(struct mr_table *mrt, bool all);
>  static void ipmr_expire_process(unsigned long arg);
>  
> @@ -995,8 +996,7 @@ static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
>  	}
>  }
>  
> -/* Bounce a cache query up to mrouted. We could use netlink for this but mrouted
> - * expects the following bizarre scheme.
> +/* Bounce a cache query up to mrouted and netlink.
>   *
>   * Called under mrt_lock.
>   */
> @@ -1062,6 +1062,8 @@ static int ipmr_cache_report(struct mr_table *mrt,
>  		return -EINVAL;
>  	}
>  
> +	igmpmsg_netlink_event(mrt, skb);
> +
>  	/* Deliver to mrouted */
>  	ret = sock_queue_rcv_skb(mroute_sk, skb);
>  	rcu_read_unlock();
> @@ -2341,6 +2343,67 @@ static void mroute_netlink_event(struct mr_table *mrt, struct mfc_cache *mfc,
>  		rtnl_set_sk_err(net, RTNLGRP_IPV4_MROUTE, err);
>  }
>  
> +static void igmpmsg_netlink_event(struct mr_table *mrt, struct sk_buff *pkt)
> +{
> +	struct net *net = read_pnet(&mrt->net);
> +	struct nlmsghdr *nlh;
> +	struct rtgenmsg *rtgenm;
> +	struct igmpmsg *msg;
> +	struct sk_buff *skb;
> +	struct nlattr *nla;
> +	int payloadlen;
> +	int msgsize;
> +
> +	payloadlen = pkt->len - sizeof(struct igmpmsg);
> +	msg = (struct igmpmsg *)skb_network_header(pkt);
> +	msgsize = NLMSG_ALIGN(sizeof(struct rtgenmsg))
> +			+ nla_total_size(1)
> +					/* IPMRA_CREPORT_MSGTYPE */
> +			+ nla_total_size(1)
> +					/* IPMRA_CREPORT_VIF_ID */
> +			+ nla_total_size(4)
> +					/* IPMRA_CREPORT_SRC_ADDR */
> +			+ nla_total_size(4)
> +					/* IPMRA_CREPORT_DST_ADDR */
> +			+ nla_total_size(payloadlen)
> +					/* IPMRA_CREPORT_PKT */
> +			;

If this ends up having another version you could pull this size
calculation into a separate function. E.g. see mroute_msgsize

> +
> +	skb = nlmsg_new(msgsize, GFP_ATOMIC);
> +	if (!skb)
> +		goto errout;
> +
> +	nlh = nlmsg_put(skb, 0, 0, RTM_NEWCACHEREPORT,
> +			sizeof(struct rtgenmsg), 0);
> +	if (!nlh)
> +		goto errout;
> +	rtgenm = nlmsg_data(nlh);
> +	rtgenm->rtgen_family = RTNL_FAMILY_IPMR;
> +	if (nla_put_u8(skb, IPMRA_CREPORT_MSGTYPE, msg->im_msgtype) ||
> +	    nla_put_u8(skb, IPMRA_CREPORT_VIF_ID, msg->im_vif) ||

This would effectively limit the new call to handle 255 ifaces. I used a u32
for the getlink interface's vif id, it'd be nice to be consistent and also allow
for more interfaces in the future (u32 might be too big, but we're not pressed for
space here).

> +	    nla_put_in_addr(skb, IPMRA_CREPORT_SRC_ADDR,
> +			    msg->im_src.s_addr) ||
> +	    nla_put_in_addr(skb, IPMRA_CREPORT_DST_ADDR,
> +			    msg->im_dst.s_addr))
> +		goto nla_put_failure;
> +
> +	nla = nla_reserve(skb, IPMRA_CREPORT_PKT, payloadlen);
> +	if (!nla || skb_copy_bits(pkt, sizeof(struct igmpmsg),
> +				  nla_data(nla), payloadlen))
> +		goto nla_put_failure;
> +
> +	nlmsg_end(skb, nlh);
> +
> +	rtnl_notify(skb, net, 0, RTNLGRP_IPV4_MROUTE_R, NULL, GFP_ATOMIC);
> +	return;
> +
> +nla_put_failure:
> +	nlmsg_cancel(skb, nlh);
> +errout:
> +	kfree_skb(skb);
> +	rtnl_set_sk_err(net, RTNLGRP_IPV4_MROUTE_R, -ENOBUFS);
> +}
> +
>  static int ipmr_rtm_dumproute(struct sk_buff *skb, struct netlink_callback *cb)
>  {
>  	struct net *net = sock_net(skb->sk);
> 
