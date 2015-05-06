From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5 12/21] switchdev: remove old switchdev_port_bridge_setlink
Date: Tue, 05 May 2015 21:33:03 -0700
Message-ID: <5549997F.1090707@cumulusnetworks.com>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com> <1430847297-15728-13-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch, simon.horman@netronome.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35708 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759318AbbEFEdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 00:33:05 -0400
Received: by pdbqd1 with SMTP id qd1so218780486pdb.2
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 21:33:05 -0700 (PDT)
In-Reply-To: <1430847297-15728-13-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/5/15, 10:34 AM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> New attr-based bridge_setlink can recurse lower devs and recover on err, so
> remove old wrapper.  Also, restore br_setlink back to original and don't
> call into SELF port driver.  rtnetlink.c:bridge_setlink already does a call
> into port driver for SELF.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> ---
>   include/net/switchdev.h   |   17 -----------------
>   net/bridge/br_netlink.c   |   11 +----------
>   net/switchdev/switchdev.c |   30 ------------------------------
>   3 files changed, 1 insertion(+), 57 deletions(-)
>
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index aa6c370..ce5ceb2 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -122,8 +122,6 @@ int switchdev_port_attr_set(struct net_device *dev,
>   			    struct switchdev_attr *attr);
>   int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj);
>   int switchdev_port_obj_del(struct net_device *dev, struct switchdev_obj *obj);
> -int switchdev_port_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh,
> -			      u16 flags);
>   int register_switchdev_notifier(struct notifier_block *nb);
>   int unregister_switchdev_notifier(struct notifier_block *nb);
>   int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
> @@ -134,8 +132,6 @@ int switchdev_port_bridge_dellink(struct net_device *dev,
>   				  struct nlmsghdr *nlh, u16 flags);
>   int ndo_dflt_switchdev_port_bridge_dellink(struct net_device *dev,
>   					   struct nlmsghdr *nlh, u16 flags);
> -int ndo_dflt_switchdev_port_bridge_setlink(struct net_device *dev,
> -					   struct nlmsghdr *nlh, u16 flags);
>   int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
>   			   u8 tos, u8 type, u32 nlflags, u32 tb_id);
>   int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
> @@ -168,12 +164,6 @@ static inline int switchdev_port_obj_del(struct net_device *dev,
>   	return -EOPNOTSUPP;
>   }
>   
> -static inline int switchdev_port_bridge_setlink(struct net_device *dev,
> -					    struct nlmsghdr *nlh, u16 flags)
> -{
> -	return -EOPNOTSUPP;
> -}
> -
>   static inline int register_switchdev_notifier(struct notifier_block *nb)
>   {
>   	return 0;
> @@ -212,13 +202,6 @@ static inline int ndo_dflt_switchdev_port_bridge_dellink(struct net_device *dev,
>   	return 0;
>   }
>   
> -static inline int ndo_dflt_switchdev_port_bridge_setlink(struct net_device *dev,
> -							 struct nlmsghdr *nlh,
> -							 u16 flags)
> -{
> -	return 0;
> -}
> -
>   static inline int switchdev_fib_ipv4_add(u32 dst, int dst_len,
>   					 struct fib_info *fi,
>   					 u8 tos, u8 type,
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index dc23453..e9b9435 100644
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
> @@ -628,15 +628,6 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
>   				afspec, RTM_SETLINK);
>   	}
>   
> -	if (p && !(flags & BRIDGE_FLAGS_SELF)) {
> -		/* set bridge attributes in hardware if supported
> -		 */
> -		ret_offload = switchdev_port_bridge_setlink(dev, nlh, flags);
> -		if (ret_offload && ret_offload != -EOPNOTSUPP)
> -			br_warn(p->br, "error setting attrs on port %u(%s)\n",
> -				(unsigned int)p->port_no, p->dev->name);
> -	}
> -
>   	if (err == 0)
>   		br_ifinfo_notify(RTM_NEWLINK, p);
>
the self/master flag requirement is not going to work seamlessly for 
devices that want to mirror
vlans in bridge driver to hw. Plus this results in two notifications and 
one cannot implement rollback
on error if one of them fails. traditionally the kernel has always 
supported the bridge offload api to go to
switch/nic driver directly. We dont break that and continue to support 
self. But, just like how stp state is offloaded
from the bridge driver, can we not continue supporting offload of vlans 
and fdb entries from the bridge driver  ?
I can rework the above code if needed (suggestions welcome). But, not 
supporting it seems inconsistent with other offloads.

rest of the patches look great. Thanks!.
