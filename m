From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] Interface group: core (netlink) part
Date: Tue, 16 Oct 2007 10:34:37 +0200
Message-ID: <4714779D.50104@trash.net>
References: <1192521703479-git-send-email-panther@balabit.hu> <11925217031287-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <11925217031287-git-send-email-panther@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote:
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 4756d58..18ff3c5 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -646,6 +646,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>  	if (dev->master)
>  		NLA_PUT_U32(skb, IFLA_MASTER, dev->master->ifindex);
>  
> +	if (dev->ifgroup)
> +		NLA_PUT_U32(skb, IFLA_IFGROUP, dev->ifgroup);
> +

You need to adjust if_nlmsg_size() to account for this.

>  	if (dev->qdisc_sleeping)
>  		NLA_PUT_STRING(skb, IFLA_QDISC, dev->qdisc_sleeping->ops->id);
>  
> @@ -846,6 +849,11 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
>  		write_unlock_bh(&dev_base_lock);
>  	}
>  
> +	if (tb[IFLA_IFGROUP]) {
> +		dev->ifgroup = nla_get_u32(tb[IFLA_IFGROUP ]);
> +		rtmsg_ifinfo(RTM_NEWLINK, dev, 0);
> +	}


Notifcations should be atomic, not one for every single change. I know
thats not the case currently, but it seems we're missing a notifcation
for some of the attributes anyway (like tx_queue_len, operstate,
linkmode), please consolidate all these and send a single notifcation.
