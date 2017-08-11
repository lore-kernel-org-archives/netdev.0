From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] bonding: ratelimit failed speed/duplex update warning
Date: Fri, 11 Aug 2017 03:59:06 -0700
Message-ID: <1502449146.3099.10.camel@perches.com>
References: <20170811100413.16234-1-futur.andy@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Andreas Born <futur.andy@googlemail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0246.hostedemail.com ([216.40.44.246]:42804 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751618AbdHKK7J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 06:59:09 -0400
In-Reply-To: <20170811100413.16234-1-futur.andy@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-08-11 at 12:04 +0200, Andreas Born wrote:
> bond_miimon_commit() handles the UP transition for each slave of a bond
> in the case of MII. It is triggered 10 times per second for the default
> MII Polling interval of 100ms. For device drivers that do not implement
> __ethtool_get_link_ksettings() the call to bond_update_speed_duplex()
> fails persistently while the MII status could remain UP. That is, in this and
> other cases where the speed/duplex update keeps failing over a longer
> period of time while the MII state is UP, a warning is printed every MII
> polling interval.
> 
> To address these excessive warnings pr_warn_ratelimited() should be used
> instead. pr_warn_once() would not be sufficient since the call to
> bond_update_speed_duplex() could recover to meanwhile succeed and fail
> again later.
[]
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
[]
> @@ -2144,9 +2144,9 @@ static void bond_miimon_commit(struct bonding *bond)
>  			if (bond_update_speed_duplex(slave) &&
>  			    bond_needs_speed_duplex(bond)) {
>  				slave->link = BOND_LINK_DOWN;
> -				netdev_warn(bond->dev,
> -					    "failed to get link speed/duplex for %s\n",
> -					    slave->dev->name);
> +				pr_warn_ratelimited("%s: failed to get link speed/duplex for %s\n",
> +						    bond->dev->name,
> +						    slave->dev->name);

This is more commonly done using

		if (net_ratelimit())
			netdev_warn(etc...)
