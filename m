From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCHv2 net] bridge: a netlink notification should be sent
 whenever those attributes change
Date: Tue, 8 Mar 2016 10:44:19 +0100
Message-ID: <56DE9EF3.4010501@cumulusnetworks.com>
References: <b58f9a4012cfc37e730916a092f2ff5530b299fd.1457407644.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hannes@stressinduktion.org
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35492 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084AbcCHJoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 04:44:23 -0500
Received: by mail-wm0-f43.google.com with SMTP id l68so122870671wml.0
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 01:44:23 -0800 (PST)
In-Reply-To: <b58f9a4012cfc37e730916a092f2ff5530b299fd.1457407644.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/08/2016 04:27 AM, Xin Long wrote:
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
>  net/bridge/br_sysfs_br.c |  5 +++++
>  net/bridge/br_sysfs_if.c |  6 +++++-
>  3 files changed, 34 insertions(+), 17 deletions(-)
> 

The patch should be targeted at net-next, not net.

> diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
> index 263b4de..f8fc624 100644
> --- a/net/bridge/br_ioctl.c
> +++ b/net/bridge/br_ioctl.c
[snip]
>  static int old_deviceless(struct net *net, void __user *uarg)
> diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
> index 6b80914..09608e6 100644
> --- a/net/bridge/br_sysfs_br.c
> +++ b/net/bridge/br_sysfs_br.c
> @@ -44,6 +44,11 @@ static ssize_t store_bridge_parm(struct device *d,
>  		return -EINVAL;
>  
>  	err = (*set)(br, val);
> +	if (!err) {
> +		rtnl_lock();

This will deadlock, there's a reason rtnl_trylock() is used in sysfs options.
As I said the br_sysfs_br.c would need more work.

> +		netdev_state_change(br->dev);
> +		rtnl_unlock();
> +	}
>  	return err ? err : len;
>  }
>  
> diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
> index efe415a..64c8422 100644
> --- a/net/bridge/br_sysfs_if.c
> +++ b/net/bridge/br_sysfs_if.c
> @@ -253,8 +253,12 @@ static ssize_t brport_store(struct kobject *kobj,
>  			spin_lock_bh(&p->br->lock);
>  			ret = brport_attr->store(p, val);
>  			spin_unlock_bh(&p->br->lock);
> -			if (ret == 0)
> +			if (!ret) {
> +				rtnl_lock();

rtnl is already held here, this way you deadlock. Again I'm really
curious how this patch was tested, you'd have deadlocked immediately.
On your next submission I'd suggest you add some notes on how you tested
the patch.

> +				br_ifinfo_notify(RTM_NEWLINK, p);
> +				rtnl_unlock();
>  				ret = count;
> +			}
>  		}
>  		rtnl_unlock();
>  	}
> 
