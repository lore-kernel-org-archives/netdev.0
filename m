From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v2 net-next 2/2] net: rename sysfs symlinks on device
 name change
Date: Wed, 15 Jan 2014 10:50:30 +0800
Message-ID: <52D5F776.4090101@huawei.com>
References: <1389733131-15390-1-git-send-email-vfalico@redhat.com> <1389733131-15390-3-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Cong Wang <amwang@redhat.com>
To: Veaceslav Falico <vfalico@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:1975 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbaAOCwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 21:52:05 -0500
In-Reply-To: <1389733131-15390-3-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/15 4:58, Veaceslav Falico wrote:
> Currently, we don't rename the upper/lower_ifc symlinks in
> /sys/class/net/*/ , which might result stale/duplicate links/names.
> 
> Fix this by adding netdev_adjacent_rename_links(dev, oldname) which renames
> all the upper/lower interface's links to dev from the upper/lower_oldname
> to the new name.
> 
> We don't need a rollback because only we control these symlinks and if we
> fail to rename them - sysfs will anyway complain.
> 
> Reported-by: Ding Tianhong <dingtianhong@huawei.com>
> CC: Ding Tianhong <dingtianhong@huawei.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Eric Dumazet <edumazet@google.com>
> CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> CC: Cong Wang <amwang@redhat.com>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
> 
> Notes:
>     v1->v2:
>     Don't export netdev_adjacent_rename_links() - it's only used in dev.c
> 
>  include/linux/netdevice.h |  1 +
>  net/core/dev.c            | 22 ++++++++++++++++++++++
>  2 files changed, 23 insertions(+)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index a2a70cc..61f8338 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2937,6 +2937,7 @@ int netdev_master_upper_dev_link_private(struct net_device *dev,
>  					 void *private);
>  void netdev_upper_dev_unlink(struct net_device *dev,
>  			     struct net_device *upper_dev);
> +void netdev_adjacent_rename_links(struct net_device *dev, char *oldname);
>  void *netdev_lower_dev_get_private(struct net_device *dev,
>  				   struct net_device *lower_dev);
>  int skb_checksum_help(struct sk_buff *skb);
> diff --git a/net/core/dev.c b/net/core/dev.c
> index c578d4e..d4f08c8 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1117,6 +1117,8 @@ rollback:
>  
>  	write_seqcount_end(&devnet_rename_seq);
>  
> +	netdev_adjacent_rename_links(dev, oldname);
> +
>  	write_lock_bh(&dev_base_lock);
>  	hlist_del_rcu(&dev->name_hlist);
>  	write_unlock_bh(&dev_base_lock);
> @@ -1136,6 +1138,7 @@ rollback:
>  			err = ret;
>  			write_seqcount_begin(&devnet_rename_seq);
>  			memcpy(dev->name, oldname, IFNAMSIZ);
> +			memcpy(oldname, newname, IFNAMSIZ);
>  			goto rollback;
>  		} else {
>  			pr_err("%s: name change rollback failed: %d\n",
> @@ -4971,6 +4974,25 @@ void netdev_upper_dev_unlink(struct net_device *dev,
>  }
>  EXPORT_SYMBOL(netdev_upper_dev_unlink);
>  
> +void netdev_adjacent_rename_links(struct net_device *dev, char *oldname)
> +{
> +	struct netdev_adjacent *iter;
> +
> +	list_for_each_entry(iter, &dev->adj_list.upper, list) {
> +		netdev_adjacent_sysfs_del(iter->dev, oldname,
> +					  &iter->dev->adj_list.lower);
> +		netdev_adjacent_sysfs_add(iter->dev, dev,
> +					  &iter->dev->adj_list.lower);
> +	}
> +
> +	list_for_each_entry(iter, &dev->adj_list.lower, list) {
> +		netdev_adjacent_sysfs_del(iter->dev, oldname,
> +					  &iter->dev->adj_list.upper);
> +		netdev_adjacent_sysfs_add(iter->dev, dev,
> +					  &iter->dev->adj_list.upper);
> +	}
> +}
> +

why no all_adj_list, only adj_list?

I think you have add the dev to the upper_dev's upper_dev by all_adj_list, and lower_dev, so you have to check them.

Regards
Ding

>  void *netdev_lower_dev_get_private(struct net_device *dev,
>  				   struct net_device *lower_dev)
>  {
> 
