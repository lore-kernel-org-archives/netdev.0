From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next v1 1/2] bridge: export port_no and port_id via
 IFA_INFO_DATA
Date: Fri, 30 Nov 2012 07:52:54 -0800
Message-ID: <20121130075254.14aac5ce@nehalam.linuxnetplumber.net>
References: <1354269514-1863-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46691 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030928Ab2K3PyO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2012 10:54:14 -0500
In-Reply-To: <1354269514-1863-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Nov 2012 17:58:32 +0800
Cong Wang <amwang@redhat.com> wrote:

> port_no will be used to get ifindex of a port in user-space,
> export it togather with port_id.
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> Acked-by: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  include/uapi/linux/if_link.h |    2 ++
>  net/bridge/br_netlink.c      |    8 +++++++-
>  2 files changed, 9 insertions(+), 1 deletions(-)
> 
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index bb58aeb..9cd91a9 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -218,6 +218,8 @@ enum {
>  	IFLA_BRPORT_MODE,	/* mode (hairpin)          */
>  	IFLA_BRPORT_GUARD,	/* bpdu guard              */
>  	IFLA_BRPORT_PROTECT,	/* root port protection    */
> +	IFLA_BRPORT_NO,		/* port no                 */
> +	IFLA_BRPORT_ID,		/* port id                 */
>  	__IFLA_BRPORT_MAX
>  };
>  #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index 65429b9..7b7414e 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -28,6 +28,8 @@ static inline size_t br_port_info_size(void)
>  		+ nla_total_size(1)	/* IFLA_BRPORT_MODE */
>  		+ nla_total_size(1)	/* IFLA_BRPORT_GUARD */
>  		+ nla_total_size(1)	/* IFLA_BRPORT_PROTECT */
> +		+ nla_total_size(2)	/* IFLA_BRPORT_NO */
> +		+ nla_total_size(2)	/* IFLA_BRPORT_ID */
>  		+ 0;
>  }
>  
> @@ -53,7 +55,9 @@ static int br_port_fill_attrs(struct sk_buff *skb,
>  	    nla_put_u32(skb, IFLA_BRPORT_COST, p->path_cost) ||
>  	    nla_put_u8(skb, IFLA_BRPORT_MODE, mode) ||
>  	    nla_put_u8(skb, IFLA_BRPORT_GUARD, !!(p->flags & BR_BPDU_GUARD)) ||
> -	    nla_put_u8(skb, IFLA_BRPORT_PROTECT, !!(p->flags & BR_ROOT_BLOCK)))
> +	    nla_put_u8(skb, IFLA_BRPORT_PROTECT, !!(p->flags & BR_ROOT_BLOCK)) ||
> +	    nla_put_u16(skb, IFLA_BRPORT_NO, p->port_no) ||
> +	    nla_put_u16(skb, IFLA_BRPORT_ID, p->port_id))
>  		return -EMSGSIZE;
>  
>  	return 0;
> @@ -168,6 +172,8 @@ static const struct nla_policy ifla_brport_policy[IFLA_BRPORT_MAX + 1] = {
>  	[IFLA_BRPORT_MODE]	= { .type = NLA_U8 },
>  	[IFLA_BRPORT_GUARD]	= { .type = NLA_U8 },
>  	[IFLA_BRPORT_PROTECT]	= { .type = NLA_U8 },
> +	[IFLA_BRPORT_NO]	= { .type = NLA_U16 },
> +	[IFLA_BRPORT_ID]	= { .type = NLA_U16 },
>  };
>  
>  /* Change the state of the port and notify spanning tree */

I don't think these are necessary. The device is already available and the relationship
can be determined from other messages. This is what RSTP daemon does.
