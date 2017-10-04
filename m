From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next v4 1/3] bridge: add new
 BR_NEIGH_SUPPRESS port flag to suppress arp and nd flood
Date: Wed, 4 Oct 2017 16:21:35 +0900
Message-ID: <c4a04560-07c8-7d9e-d64c-558f99cfc653@lab.ntt.co.jp>
References: <1507093953-59929-1-git-send-email-roopa@cumulusnetworks.com>
	<1507093953-59929-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, davem@davemloft.net
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1507093953-59929-2-git-send-email-roopa@cumulusnetworks.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 2017/10/04 14:12, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch adds a new bridge port flag BR_NEIGH_SUPPRESS to
> suppress arp and nd flood on bridge ports. It implements
> rfc7432, section 10.
> https://tools.ietf.org/html/rfc7432#section-10
> for ethernet VPN deployments. It is similar to the existing
> BR_ARP_PROXY flag but has a few semantic differences to conform
> to EVPN standard. In case of EVPN, it is mainly used to
> avoid flooding to tunnel ports like vxlan. Unlike the existing
> flags it suppresses flood of all neigh discovery packets
> (arp, nd) to tunnel ports.
> 
> This patch adds netlink and sysfs support to set this bridge port
> flag.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
...
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index dea88a2..d8c2706 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -138,6 +138,7 @@ static inline size_t br_port_info_size(void)
>  		+ nla_total_size(1)	/* IFLA_BRPORT_PROXYARP */
>  		+ nla_total_size(1)	/* IFLA_BRPORT_PROXYARP_WIFI */
>  		+ nla_total_size(1)	/* IFLA_BRPORT_VLAN_TUNNEL */
> +		+ nla_total_size(1)	/* IFLA_BRPORT_NEIGH_SUPPRESS */
>  		+ nla_total_size(sizeof(struct ifla_bridge_id))	/* IFLA_BRPORT_ROOT_ID */
>  		+ nla_total_size(sizeof(struct ifla_bridge_id))	/* IFLA_BRPORT_BRIDGE_ID */
>  		+ nla_total_size(sizeof(u16))	/* IFLA_BRPORT_DESIGNATED_PORT */
> @@ -210,7 +211,9 @@ static int br_port_fill_attrs(struct sk_buff *skb,
>  	    nla_put_u8(skb, IFLA_BRPORT_CONFIG_PENDING, p->config_pending) ||
>  	    nla_put_u8(skb, IFLA_BRPORT_VLAN_TUNNEL, !!(p->flags &
>  							BR_VLAN_TUNNEL)) ||
> -	    nla_put_u16(skb, IFLA_BRPORT_GROUP_FWD_MASK, p->group_fwd_mask))
> +	    nla_put_u16(skb, IFLA_BRPORT_GROUP_FWD_MASK, p->group_fwd_mask) ||
> +	    nla_put_u8(skb, IFLA_BRPORT_NEIGH_SUPPRESS, !!(p->flags &
> +							BR_NEIGH_SUPPRESS)))

Wouldn't it be better to make the indentation like this?

... !!(p->flags &
       BR_NEIGH_SUPPRESS)))

>  		return -EMSGSIZE;
>  
>  	timerval = br_timer_value(&p->message_age_timer);
> @@ -692,6 +695,7 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
>  {
>  	unsigned long old_flags = p->flags;
>  	bool br_vlan_tunnel_old = false;
> +	int neigh_suppress_old = 0;
>  	int err;
>  
>  	err = br_set_port_flag(p, tb, IFLA_BRPORT_MODE, BR_HAIRPIN_MODE);
> @@ -785,6 +789,12 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
>  		p->group_fwd_mask = fwd_mask;
>  	}
>  
> +	neigh_suppress_old = (p->flags & BR_NEIGH_SUPPRESS);
> +	br_set_port_flag(p, tb, IFLA_BRPORT_NEIGH_SUPPRESS,
> +			 BR_NEIGH_SUPPRESS);
> +	if (neigh_suppress_old != (p->flags & BR_NEIGH_SUPPRESS))
> +		br_recalculate_neigh_suppress_enabled(p->br);
> +

You are calling br_recalculate_neigh_suppress_enabled() from within
br_port_flags_change() immediately after this.
I think you can just call br_set_port_flag() here.

>  	br_port_flags_change(p, old_flags ^ p->flags);
>  	return 0;
>  }

-- 
Toshiaki Makita
