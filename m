From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [patch net-next] bonding: create netlink event when bonding
 option is changed
Date: Tue, 19 Aug 2014 16:34:01 -0400
Message-ID: <20140819203401.GA1954@gospo.home.greyhouse.net>
References: <1408456932-10318-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, j.vosburgh@gmail.com,
	vfalico@gmail.com, andy@greyhouse.net, nikolay@redhat.com,
	dingtianhong@huawei.com, sfeldma@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:33728 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbaHSUeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2014 16:34:05 -0400
Content-Disposition: inline
In-Reply-To: <1408456932-10318-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2014 at 04:02:12PM +0200, Jiri Pirko wrote:
> Userspace needs to be notified if one changes some option.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  drivers/net/bonding/bond_options.c | 2 ++
>  include/linux/netdevice.h          | 1 +
>  2 files changed, 3 insertions(+)
> 
> diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
> index dc73463..d8dc17f 100644
> --- a/drivers/net/bonding/bond_options.c
> +++ b/drivers/net/bonding/bond_options.c
> @@ -625,6 +625,8 @@ int __bond_opt_set(struct bonding *bond,
>  out:
>  	if (ret)
>  		bond_opt_error_interpret(bond, opt, ret, val);
> +	else
> +		call_netdevice_notifiers(NETDEV_CHANGEINFODATA, bond->dev);
Is this valuable where the configuration change to the bonding driver
came from netlink.  Do you have a good example why this useful in the
netlink path as well as when using sysfs?  It would seem more logical to
add call_netdevice_notifiers to bonding_sysfs_store_option so anything
listening to netlink messages or the netlink cache can know to check for
changes.

>  
>  	return ret;
>  }
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 967ddcc..44bc4bd 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2017,6 +2017,7 @@ struct pcpu_sw_netstats {
>  #define NETDEV_CHANGEUPPER	0x0015
>  #define NETDEV_RESEND_IGMP	0x0016
>  #define NETDEV_PRECHANGEMTU	0x0017 /* notify before mtu change happened */
> +#define NETDEV_CHANGEINFODATA	0x0018
>  
>  int register_netdevice_notifier(struct notifier_block *nb);
>  int unregister_netdevice_notifier(struct notifier_block *nb);
> -- 
> 1.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
