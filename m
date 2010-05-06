From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] bridge: update sysfs link names if port device names
 have changed
Date: Thu, 6 May 2010 11:53:18 -0700
Message-ID: <20100506115318.0b9ee289@nehalam>
References: <4BE30B3D.9000600@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43160 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752123Ab0EFSx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 14:53:56 -0400
In-Reply-To: <4BE30B3D.9000600@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 06 May 2010 19:32:29 +0100
Simon Arlott <simon@fire.lp0.eu> wrote:

> Links for each port are created in sysfs using the device
> name, but this could be changed after being added to the
> bridge.
> 
> As well as being unable to remove interfaces after this
> occurs (because userspace tools don't recognise the new
> name, and the kernel won't recognise the old name), adding
> another interface with the old name to the bridge will
> cause an error trying to create the sysfs link.
> 
> This fixes the problem by listening for NETDEV_CHANGENAME
> notifications and renaming the link.
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=12743
> 
> Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
> ---
>  fs/sysfs/symlink.c       |    1 +
>  net/bridge/br_if.c       |    2 +-
>  net/bridge/br_notify.c   |    4 ++++
>  net/bridge/br_private.h  |    5 +++++
>  net/bridge/br_sysfs_if.c |   19 +++++++++++++++++--
>  5 files changed, 28 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/sysfs/symlink.c b/fs/sysfs/symlink.c
> index b93ec51..942f239 100644
> --- a/fs/sysfs/symlink.c
> +++ b/fs/sysfs/symlink.c
> @@ -261,3 +261,4 @@ const struct inode_operations sysfs_symlink_inode_operations = {
>  
>  EXPORT_SYMBOL_GPL(sysfs_create_link);
>  EXPORT_SYMBOL_GPL(sysfs_remove_link);
> +EXPORT_SYMBOL_GPL(sysfs_rename_link);
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index 0b6b1f2..17175a5 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -132,7 +132,7 @@ static void del_nbp(struct net_bridge_port *p)
>  	struct net_bridge *br = p->br;
>  	struct net_device *dev = p->dev;
>  
> -	sysfs_remove_link(br->ifobj, dev->name);
> +	sysfs_remove_link(br->ifobj, p->sysfs_name);
>  
>  	dev_set_promiscuity(dev, -1);
>  
> diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
> index 763a3ec..9004406 100644
> --- a/net/bridge/br_notify.c
> +++ b/net/bridge/br_notify.c
> @@ -82,6 +82,10 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
>  	case NETDEV_UNREGISTER:
>  		br_del_if(br, dev);
>  		break;
> +
> +	case NETDEV_CHANGENAME:
> +		br_sysfs_renameif(p);
> +		break;
>  	}
>  
>  	/* Events that may cause spanning tree to refresh */
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 846d7d1..dcbe744 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -96,6 +96,9 @@ struct net_bridge_port
>  {
>  	struct net_bridge		*br;
>  	struct net_device		*dev;
> +#ifdef CONFIG_SYSFS
> +	char				sysfs_name[IFNAMSIZ];
> +#endif
>  	struct list_head		list;

Ok, but the sysfs_name should go at end of net_bridge_port structure
since it is only used in special case code. And putting in middle
of structure kills cache locality.
