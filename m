From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4 13/24] switchdev: remove old netdev_switch_port_bridge_setlink
Date: Mon, 13 Apr 2015 21:07:35 -0700
Message-ID: <552C9287.6080904@cumulusnetworks.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com> <1428905838-14920-14-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:34820 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751893AbbDNEHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 00:07:39 -0400
Received: by qkhg7 with SMTP id g7so218350761qkh.2
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 21:07:38 -0700 (PDT)
In-Reply-To: <1428905838-14920-14-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/12/15, 11:17 PM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> New attr-based bridge_setlink can recurse lower devs and recover on err, so
> remove old wrapper.  Also, restore br_setlink back to original and don't call
> into SELF port driver.  rtnetlink.c:bridge_setlink already does a call into
> port driver for SELF.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> ---
>   include/net/switchdev.h   |   18 ---------------
>   net/bridge/br_netlink.c   |   12 +---------
>   net/switchdev/switchdev.c |   55 ---------------------------------------------
>   3 files changed, 1 insertion(+), 84 deletions(-)
>
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index cff53ae..70874fc 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -127,14 +127,10 @@ int register_netdev_switch_notifier(struct notifier_block *nb);
>   int unregister_netdev_switch_notifier(struct notifier_block *nb);
>   int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
>   				 struct netdev_switch_notifier_info *info);
> -int netdev_switch_port_bridge_setlink(struct net_device *dev,
> -				struct nlmsghdr *nlh, u16 flags);
>   int netdev_switch_port_bridge_dellink(struct net_device *dev,
>   				struct nlmsghdr *nlh, u16 flags);
>   int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
>   					       struct nlmsghdr *nlh, u16 flags);
> -int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
> -					       struct nlmsghdr *nlh, u16 flags);
>   int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
>   			       u8 tos, u8 type, u32 nlflags, u32 tb_id);
>   int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
> @@ -189,13 +185,6 @@ static inline int call_netdev_switch_notifiers(unsigned long val, struct net_dev
>   	return NOTIFY_DONE;
>   }
>   
> -static inline int netdev_switch_port_bridge_setlink(struct net_device *dev,
> -						    struct nlmsghdr *nlh,
> -						    u16 flags)
> -{
> -	return -EOPNOTSUPP;
> -}
> -
>   static inline int netdev_switch_port_bridge_dellink(struct net_device *dev,
>   						    struct nlmsghdr *nlh,
>   						    u16 flags)
> @@ -210,13 +199,6 @@ static inline int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *
>   	return 0;
>   }
>   
> -static inline int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
> -							struct nlmsghdr *nlh,
> -							u16 flags)
> -{
> -	return 0;
> -}
> -
>   static inline int netdev_switch_fib_ipv4_add(u32 dst, int dst_len,
>   					     struct fib_info *fi,
>   					     u8 tos, u8 type,
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index 0e4ddb8..45ed1ce 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -586,7 +586,7 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
>   	struct nlattr *afspec;
>   	struct net_bridge_port *p;
>   	struct nlattr *tb[IFLA_BRPORT_MAX + 1];
> -	int err = 0, ret_offload = 0;
> +	int err = 0;
>   
>   	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_PROTINFO);
>   	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
> @@ -628,16 +628,6 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
>   				afspec, RTM_SETLINK);
>   	}
>   
> -	if (p && !(flags & BRIDGE_FLAGS_SELF)) {
> -		/* set bridge attributes in hardware if supported
> -		 */
> -		ret_offload = netdev_switch_port_bridge_setlink(dev, nlh,
> -								flags);
> -		if (ret_offload && ret_offload != -EOPNOTSUPP)
> -			br_warn(p->br, "error setting attrs on port %u(%s)\n",
> -				(unsigned int)p->port_no, p->dev->name);
> -	}
> -

This was there to keep the offload semantics consistent with offload of 
other kernel objects (eg. fib).
your patch-set mandates 'master' and 'self' to program hardware and this 
also generates two notifications
to users-pace.
