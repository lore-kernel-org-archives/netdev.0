From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH RESEND] net:8021q:Fix error handling in the function
 vlan_changelink
Date: Thu, 7 Jan 2016 21:56:53 +0000
Message-ID: <20160107215652.GA10494@macbook.localdomain>
References: <1452203271-9310-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452203271-9310-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07.01, Nicholas Krause wrote:
> This fixes error handling in the function vlan_changelink to properly
> check if its internal calls to the functions vlan_dev_change_flags
> and vlan_dev_set_egress_priority have failed by returning a error
> code which if this occurs return immediately to the caller of
> vlan_changelink to signal to the caller that a failure has occurred
> when calling this particular function.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  net/8021q/vlan_netlink.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
> index c92b52f..10e79b8 100644
> --- a/net/8021q/vlan_netlink.c
> +++ b/net/8021q/vlan_netlink.c
> @@ -93,10 +93,13 @@ static int vlan_changelink(struct net_device *dev,
>  	struct ifla_vlan_qos_mapping *m;
>  	struct nlattr *attr;
>  	int rem;
> +	int err = 0;
>  
>  	if (data[IFLA_VLAN_FLAGS]) {
>  		flags = nla_data(data[IFLA_VLAN_FLAGS]);
> -		vlan_dev_change_flags(dev, flags->flags, flags->mask);
> +		err = vlan_dev_change_flags(dev, flags->flags, flags->mask);
> +		if (err)
> +			goto err;
>  	}
>  	if (data[IFLA_VLAN_INGRESS_QOS]) {
>  		nla_for_each_nested(attr, data[IFLA_VLAN_INGRESS_QOS], rem) {
> @@ -107,10 +110,13 @@ static int vlan_changelink(struct net_device *dev,
>  	if (data[IFLA_VLAN_EGRESS_QOS]) {
>  		nla_for_each_nested(attr, data[IFLA_VLAN_EGRESS_QOS], rem) {
>  			m = nla_data(attr);
> -			vlan_dev_set_egress_priority(dev, m->from, m->to);
> +			err = vlan_dev_set_egress_priority(dev, m->from, m->to);
> +			if (err)
> +				break;

The netlink interface is supposed to provide transactional semantics. If you
want to handle this case properly, you need to unroll previous configuration
changes.

>  		}
>  	}
> -	return 0;
> +err:
> +	return err;
>  }
>  
>  static int vlan_newlink(struct net *src_net, struct net_device *dev,
> -- 
> 2.1.4
> 
