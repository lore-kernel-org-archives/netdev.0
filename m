From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bridge: a netlink notification should be sent
 whenever those attributes change
Date: Thu, 3 Mar 2016 13:29:54 +0100
Message-ID: <56D82E42.4060401@cumulusnetworks.com>
References: <2e80304ba6a0021637e362c83f931dc596f72d89.1457007418.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hannes@stressinduktion.org
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35638 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbcCCM35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 07:29:57 -0500
Received: by mail-wm0-f48.google.com with SMTP id l68so128979764wml.0
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 04:29:56 -0800 (PST)
In-Reply-To: <2e80304ba6a0021637e362c83f931dc596f72d89.1457007418.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/2016 01:16 PM, Xin Long wrote:
> Now when we change the attributes of bridge or br_port by netlink,
> a relevant netlink notification will be sent, but if we change them
> by ioctl or sysfs, no notification will be sent.
> 
> we should ensure that whenever those attributes change internally or from
> sysfs/ioctl, that a netlink notification is sent out to listeners.
> 
> Also, NetworkManager will use this in the future to listen for out-of-band
> bridge master attribute updates and incorporate them into the runtime
> configuration.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/bridge/br_ioctl.c    | 40 ++++++++++++++++++++++++----------------
>  net/bridge/br_sysfs_br.c |  2 ++
>  net/bridge/br_sysfs_if.c |  4 +++-
>  3 files changed, 29 insertions(+), 17 deletions(-)
> 
[snip]
>  static int old_deviceless(struct net *net, void __user *uarg)
> diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
> index 6b80914..231e093 100644
> --- a/net/bridge/br_sysfs_br.c
> +++ b/net/bridge/br_sysfs_br.c
> @@ -44,6 +44,8 @@ static ssize_t store_bridge_parm(struct device *d,
>  		return -EINVAL;
>  
>  	err = (*set)(br, val);
> +	if (!err)
> +		netdev_state_change(br->dev);

This is incorrect because you don't have rtnl here, bridge device sysfs
options take care of rtnl only on per-option basis and they obtain and 
release it themselves, so you won't have rtnl held when you call
netdev_state_change. While I agree that this is needed, a larger change
would be necessary for br_sysfs_br.c.
Off-topic: I've been looking into factoring out the bond option API and reusing
it here as it already has all of this handled, but I won't have time to finish
it before the next merge window, so if you fix the issue here I'm okay with
this as interim solution.

Cheers,
 Nik

>  	return err ? err : len;
>  }
>  
> diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
> index efe415a..0ad8592 100644
> --- a/net/bridge/br_sysfs_if.c
> +++ b/net/bridge/br_sysfs_if.c
> @@ -253,8 +253,10 @@ static ssize_t brport_store(struct kobject *kobj,
>  			spin_lock_bh(&p->br->lock);
>  			ret = brport_attr->store(p, val);
>  			spin_unlock_bh(&p->br->lock);
> -			if (ret == 0)
> +			if (ret == 0) {
> +				br_ifinfo_notify(RTM_NEWLINK, p);
>  				ret = count;
> +			}
>  		}
>  		rtnl_unlock();
>  	}
> 
