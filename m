From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] net: fix sysfs symlinks of adjacent devices
Date: Fri, 12 Sep 2014 09:33:39 -0400
Message-ID: <5412F633.8020102@gmail.com>
References: <1410516826-6926-1-git-send-email-git.user@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Andres Freund <andres@anarazel.de>
To: Alexander Fomichev <git.user@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:60516 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753927AbaILNdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 09:33:44 -0400
Received: by mail-qg0-f52.google.com with SMTP id i50so718508qgf.11
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 06:33:42 -0700 (PDT)
In-Reply-To: <1410516826-6926-1-git-send-email-git.user@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2014 06:13 AM, Alexander Fomichev wrote:
> From: "Alexander Y. Fomichev" <git.user@gmail.com>
> 
> __netdev_adjacent_dev_insert may add adjacent device from another
> namespace. Without proper check it leads to emergence of broken
> symlink from/to device not existing in current namespace.
> Fix: check net_ns is the same before netdev_adjacent_sysfs_add/del
> related to: 4c75431ac3520631f1d9e74aa88407e6374dbbc4
> 
> Signed-off-by: Alexander Y. Fomichev <git.user@gmail.com>
> ---
>  net/core/dev.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index ab9a16530c36..887784b2dcde 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4841,7 +4841,8 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
>  	pr_debug("dev_hold for %s, because of link added from %s to %s\n",
>  		 adj_dev->name, dev->name, adj_dev->name);
>  
> -	if (netdev_adjacent_is_neigh_list(dev, dev_list)) {
> +	if (netdev_adjacent_is_neigh_list(dev, dev_list) &&
> +	    net_eq(dev_net(dev), dev_net(adj_dev))) {
>  		ret = netdev_adjacent_sysfs_add(dev, adj_dev, dev_list);
>  		if (ret)
>  			goto free_adj;
> @@ -4862,7 +4863,8 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
>  	return 0;
>  
>  remove_symlinks:
> -	if (netdev_adjacent_is_neigh_list(dev, dev_list))
> +	if (netdev_adjacent_is_neigh_list(dev, dev_list) &&
> +	    net_eq(dev_net(dev), dev_net(adj_dev)))
>  		netdev_adjacent_sysfs_del(dev, adj_dev->name, dev_list);
>  free_adj:
>  	kfree(adj);
> 

Looking over the code, it might make sense to move all the net_eq checks
into adjacent_sysfs calls so as to consolidate them.  I haven't audited
all code paths, but at first glance it should do the right thing.

What do you think?

-vlad
