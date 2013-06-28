From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] Set the correct RTNL family for multicast netconf
 messages
Date: Fri, 28 Jun 2013 08:26:17 -0700
Message-ID: <20130628082617.42a802a4@nehalam.linuxnetplumber.net>
References: <1372376687.21767.10.camel@imac-linux.luckyscavenger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"nicolas.dichtel@6wind.com" <nicolas.dichtel@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Mike Davison <Mike.Davison@vyatta.com>
To: Sven-Thorsten Dietrich <sven@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372376687.21767.10.camel@imac-linux.luckyscavenger.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Jun 2013 16:44:47 -0700
Sven-Thorsten Dietrich <sven@vyatta.com> wrote:

> There may be other cases that require a special case, so I chose the switch approach.
> 
> Please note, that all other messages from ipmr[6].c correctly set the family, while these do not.
> 
> Thanks
> 
> Sven
> 
> 
> 
> Subject: Set correct RTNL family for multicast netconf messages
> From: Sven-Thorsten Dietrich sven@vyatta.com Thu Jun 27 16:40:17 2013 -0700
> Date: Thu Jun 27 16:40:17 2013 -0700:
> 
> 
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index dfc39d4..695858b 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -1705,7 +1705,16 @@ static int inet_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
>  		return -EMSGSIZE;
>  
>  	ncm = nlmsg_data(nlh);
> -	ncm->ncm_family = AF_INET;
> +
> +	switch (type) {
> +		case NETCONFA_MC_FORWARDING:
> +			ncm->ncm_family = RTNL_FAMILY_IPMR;
> +			break;
> +
> +		default:
> +			ncm->ncm_family = AF_INET;
> +			break;
> +	}
>  
>  	if (nla_put_s32(skb, NETCONFA_IFINDEX, ifindex) < 0)
>  		goto nla_put_failure;
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 4ab4c38..a177da4 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -492,7 +492,16 @@ static int inet6_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
>  		return -EMSGSIZE;
>  
>  	ncm = nlmsg_data(nlh);
> -	ncm->ncm_family = AF_INET6;
> +
> +	switch (type) {
> +		case NETCONFA_MC_FORWARDING:
> +			ncm->ncm_family = RTNL_FAMILY_IP6MR;
> +			break;
> +
> +		default:
> +			ncm->ncm_family = AF_INET6;
> +			break;
> +	}
>  
>  	if (nla_put_s32(skb, NETCONFA_IFINDEX, ifindex) < 0)
>  		goto nla_put_failure;
> 

Found another issue that needs some thought.
If type == ALL, in that case the family comes up as AF_INET.
That means that if application is doing a request to get netconf
it will receive a different answer than if it is montoring for netconf
changes.

One way to solve would be to split fill_devconf into two parts, one
for unicast, and one for multicast.
