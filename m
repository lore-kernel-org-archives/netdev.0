From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH net RESEND] bonding: don't change to 802.3ad mode while
 ARP monitoring is running
Date: Mon, 18 Nov 2013 11:44:42 -0600
Message-ID: <1384796682.4774.26.camel@dcbw.foobar.com>
References: <528710F7.7050207@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33410 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751297Ab3KRRoX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Nov 2013 12:44:23 -0500
In-Reply-To: <528710F7.7050207@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-11-16 at 14:30 +0800, Ding Tianhong wrote:
> Because the ARP monitoring is not support for 802.3ad, but I still
> could change the mode to 802.3ad from ab mode while ARP monitoring
> is running, it is incorrect.
> 
> So add a check for 802.3ad in bonding_store_mode to fix the problem,
> and make a new macro BOND_NO_USES_ARP() to simplify the code.

Instead of failing, couldn't the code stop ARP monitoring and allow the
mode change?  This is similar to setting miimon, which disables ARP
monitoring, or setting ARP monitoring, which disables miimon.

	if (new_value && bond->params.arp_interval) {
		pr_info("%s: MII monitoring cannot be used with ARP monitoring. Disabling ARP monitoring...\n",
			bond->dev->name);
		bond->params.arp_interval = 0;
		if (bond->params.arp_validate)
			bond->params.arp_validate = BOND_ARP_VALIDATE_NONE;
	}

Bond mode is the most important bond option, so it seems like it should
override any of the other sub-options.  I know the code doesn't do this
now, but maybe instead of the patch you propose, it would be nicer to
allow the mode change instead?

Dan

> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  drivers/net/bonding/bond_options.c | 2 +-
>  drivers/net/bonding/bonding.h      | 4 ++++
>  2 files changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
> index 9a5223c..abb4218 100644
> --- a/drivers/net/bonding/bond_options.c
> +++ b/drivers/net/bonding/bond_options.c
> @@ -45,7 +45,7 @@ int bond_option_mode_set(struct bonding *bond, int mode)
>  		return -EPERM;
>  	}
>  
> -	if (BOND_MODE_IS_LB(mode) && bond->params.arp_interval) {
> +	if (BOND_NO_USES_ARP(mode) && bond->params.arp_interval) {
>  		pr_err("%s: %s mode is incompatible with arp monitoring.\n",
>  		       bond->dev->name, bond_mode_tbl[mode].modename);
>  		return -EINVAL;
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
> index 046a605..e2c11cb 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -63,6 +63,10 @@
>  		(((mode) == BOND_MODE_TLB) ||	\
>  		 ((mode) == BOND_MODE_ALB))
>  
> +#define BOND_NO_USES_ARP(mode)				\
> +		(((mode) == BOND_MODE_8023AD)	||	\
> +		 ((mode) == BOND_MODE_TLB)	||	\
> +		 ((mode) == BOND_MODE_ALB))
>  /*
>   * Less bad way to call ioctl from within the kernel; this needs to be
>   * done some other way to get the call out of interrupt context.
