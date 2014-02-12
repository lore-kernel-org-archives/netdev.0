From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: clear iflink when moving to a new netns
Date: Wed, 12 Feb 2014 08:33:22 -0800
Message-ID: <20140212083322.1559f441@nehalam.linuxnetplumber.net>
References: <1392162690-6647-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:33736 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339AbaBLQd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 11:33:26 -0500
Received: by mail-pd0-f176.google.com with SMTP id w10so9181195pde.21
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 08:33:26 -0800 (PST)
In-Reply-To: <1392162690-6647-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Feb 2014 15:51:28 -0800
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> From: Cong Wang <cwang@twopensource.com>
> 
> BZ: https://bugzilla.kernel.org/show_bug.cgi?id=66691
> 
> macvlan and vlan both use iflink to identify its lower device,
> however, after such device is moved to the new netns, its iflink
> would become meaningless as ifindex is per netns. So, instead of
> forbid them moving to another netns, just clear this field so that
> it will not be dumped at least.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> ---
>  net/core/dev.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 4ad1b78..5e88b0c2 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6608,12 +6608,11 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
>  	dev_net_set(dev, net);
>  
>  	/* If there is an ifindex conflict assign a new one */
> -	if (__dev_get_by_index(net, dev->ifindex)) {
> -		int iflink = (dev->iflink == dev->ifindex);
> +	if (__dev_get_by_index(net, dev->ifindex))
>  		dev->ifindex = dev_new_index(net);
> -		if (iflink)
> -			dev->iflink = dev->ifindex;
> -	}
> +
> +	/* Old iflink is meaningless in the new namespace */
> +	dev->iflink = dev->ifindex;
>  
>  	/* Send a netdev-add uevent to the new namespace */
>  	kobject_uevent(&dev->dev.kobj, KOBJ_ADD);

This also breaks propogation of state changes from lower device
to upper device. Things like carrier and up/down.
