From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] 8139too: send NETDEV_CHANGE manually when autoneg is
 disabled
Date: Wed, 6 Mar 2013 20:22:52 +0000
Message-ID: <1362601372.3126.23.camel@bwh-desktop.uk.solarflarecom.com>
References: <1362596784-19443-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <wfp5p@virginia.edu>,
	<jasowang@redhat.com>, <junchangwang@gmail.com>,
	<greearb@candelatech.com>, <ivecera@redhat.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:57329 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752304Ab3CFUXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 15:23:06 -0500
In-Reply-To: <1362596784-19443-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-06 at 20:06 +0100, Veaceslav Falico wrote:
> When setting autoneg off (with any additional parameters, like
> speed/duplex), 8139too doesn't do an interface reset, and thus doesn't
> notify anyone that its speed/duplex might have changed (bonding and bridge
> will not see the speed changes, per example).
>
> Verify if we've force_media and send notification manually, so that the
> listeners have a chance to see the changes. It's quite ugly, however I
> don't see anything better.

Isn't this really a bug in mii_check_media()?  It shouldn't shortcut the
calls to netif_carrier_{off,on}() just because mii->force_media is set.

Ben.

> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
>  drivers/net/ethernet/realtek/8139too.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
> index 1276ac7..96ee18c 100644
> --- a/drivers/net/ethernet/realtek/8139too.c
> +++ b/drivers/net/ethernet/realtek/8139too.c
> @@ -2393,6 +2393,11 @@ static int rtl8139_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>  	spin_lock_irq(&tp->lock);
>  	rc = mii_ethtool_sset(&tp->mii, cmd);
>  	spin_unlock_irq(&tp->lock);
> +	/*
> +	 * we don't restart on autoneg off, so notify manually
> +	 */
> +	if (tp->mii.force_media)
> +		call_netdevice_notifiers(NETDEV_CHANGE, dev);
>  	return rc;
>  }
>  

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
