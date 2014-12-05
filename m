From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/3] bridge: offload bridge port attributes to switch
 asic if feature flag set
Date: Fri, 05 Dec 2014 16:21:48 +0300
Message-ID: <5481B16C.8050904@cogentembedded.com>
References: <1417746401-8140-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: roopa@cumulusnetworks.com, jiri@resnulli.us, sfeldma@gmail.com,
	jhs@mojatatu.com, bcrl@kvack.org, tgraf@suug.ch,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	linville@tuxdriver.com, nhorman@tuxdriver.com,
	nicolas.dichtel@6wind.com, vyasevic@redhat.com,
	f.fainelli@gmail.com, buytenh@wantstofly.org, aviadr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:46403 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbaLENVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 08:21:51 -0500
Received: by mail-lb0-f169.google.com with SMTP id p9so528820lbv.28
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 05:21:50 -0800 (PST)
In-Reply-To: <1417746401-8140-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/5/2014 5:26 AM, roopa@cumulusnetworks.com wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>

> This allows offloading to switch asic without having the user to set
> any flag. And this is done in the bridge driver to rollback kernel settings
> on hw offload failure if required in the future.

> With this, it also makes sure a notification goes out only after the
> attributes are set both in the kernel and hw.
> ---
>   net/bridge/br_netlink.c |   27 ++++++++++++++++++++++++++-
>   1 file changed, 26 insertions(+), 1 deletion(-)

> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index 9f5eb55..ce173f0 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -407,9 +407,21 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
>   				afspec, RTM_SETLINK);
>   	}
>
> +	if ((dev->features & NETIF_F_HW_SWITCH_OFFLOAD) &&
> +			dev->netdev_ops->ndo_bridge_setlink) {
> +		int ret = dev->netdev_ops->ndo_bridge_setlink(dev, nlh);

    Need empty line after declaration.

> +		if (ret && ret != -EOPNOTSUPP) {
> +			/* XXX Fix this in the future to rollback
> +			 * kernel settings and return error
> +			 */
> +			br_warn(p->br, "error offloading bridge attributes "
> +					"on port %u(%s)\n", (unsigned int) p->port_no,

    Don't break up the message strings. Also, your continuation lines should 
start under the next character after ( on the first line.

> +					p->dev->name);
> +		}
> +	}
> +
>   	if (err == 0)
>   		br_ifinfo_notify(RTM_NEWLINK, p);
> -

    Why?

>   out:
>   	return err;
>   }
> @@ -433,6 +445,19 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh)
>   	err = br_afspec((struct net_bridge *)netdev_priv(dev), p,
>   			afspec, RTM_DELLINK);
>
> +	if (dev->features & NETIF_F_HW_SWITCH_OFFLOAD
> +			&& dev->netdev_ops->ndo_bridge_setlink) {
> +		int ret = dev->netdev_ops->ndo_bridge_dellink(dev, nlh);
> +		if (ret && ret != -EOPNOTSUPP) {
> +			/* XXX Fix this in the future to rollback
> +			 * kernel settings and return error
> +			 */
> +			br_warn(p->br, "error offloading bridge attributes "
> +					"on port %u(%s)\n", (unsigned int) p->port_no,
> +					p->dev->name);

    Same comments here.

> +		}
> +	}
> +
>   	return err;
>   }
>   static int br_validate(struct nlattr *tb[], struct nlattr *data[])

WBR, Sergei
