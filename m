From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/2] [RFC] NET: Implement a standard ndev_printk family
Date: Mon, 11 Jun 2007 15:19:15 -0700
Message-ID: <20070611151915.398add18@localhost.localdomain>
References: <20070611213721.23014.4812.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, davem@davemloft.net,
	arjan@linux.intel.com, joe@perches.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:45424 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753377AbXFKWTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 18:19:55 -0400
In-Reply-To: <20070611213721.23014.4812.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 11 Jun 2007 14:37:21 -0700
Auke Kok <auke-jan.h.kok@intel.com> wrote:

> A lot of netdevices implement their own variant of printk and use
> use variations of dev_printk, printk or others that use msg_enable,
> which has been an eyesore with countless variations across drivers.
> 
> This patch implements a standard ndev_printk and derivatives
> such as ndev_err, ndev_info, ndev_warn that allows drivers to
> transparently use both the msg_enable and a generic netdevice
> message layout. It moves the msg_enable over to the net_device
> struct and allows drivers to obsolete ethtool handling code of
> the msg_enable value.
> 
> The current code has each driver contain a copy of msg_enable and
> handle the setting/changing through ethtool that way. Since the
> netdev name is stored in the net_device struct, those two are
> not coherently available in a uniform way across all drivers (a
> single macro or function would not work since all drivers name
> their net_device members differently). This makes netdevice
> driver writes reinvent the wheel over and over again.
> 
> It thus makes sense to move msg_enable to the net_device. This
> gives us the opportunity to (1) initialize it by default with a
> globally sane value, (2) remove msg_enable handling code w/r
> ethtool for drivers that know and use the msg_enable member
> of the net_device struct. (3) Ethtool code can just modify the
> net_device msg_enable for drivers that do not have custom
> msg_enable get/set handlers so converted drivers lose some
> code for that as well.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  include/linux/netdevice.h |   38 ++++++++++++++++++++++++++++++++++++++
>  net/core/dev.c            |    5 +++++
>  net/core/ethtool.c        |   14 +++++++-------
>  3 files changed, 50 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 3a70f55..d185f41 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -540,6 +540,8 @@ struct net_device
>  	struct device		dev;
>  	/* space for optional statistics and wireless sysfs groups */
>  	struct attribute_group  *sysfs_groups[3];
> +
> +	int			msg_enable;
>  };

Since msg_enable is used as bits, it should be unsigned (probably unsigned long).
