From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH next] bonding: speed/duplex update at NETDEV_UP event
Date: Fri, 29 Sep 2017 13:08:19 -0700
Message-ID: <20170929130819.74879e99@xeon-e3>
References: <20170928010349.8988-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <maheshb@google.com>
To: Mahesh Bandewar <mahesh@bandewar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:47474 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752208AbdI2UI1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 16:08:27 -0400
Received: by mail-pg0-f48.google.com with SMTP id d8so347979pgt.4
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 13:08:27 -0700 (PDT)
In-Reply-To: <20170928010349.8988-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Sep 2017 18:03:49 -0700
Mahesh Bandewar <mahesh@bandewar.net> wrote:

> From: Mahesh Bandewar <maheshb@google.com>
> 
> Some NIC drivers don't have correct speed/duplex settings at the
> time they send NETDEV_UP notification and that messes up the
> bonding state. Especially 802.3ad mode which is very sensitive
> to these settings. In the current implementation we invoke
> bond_update_speed_duplex() when we receive NETDEV_UP, however,
> ignore the return value. If the values we get are invalid
> (UNKNOWN), then slave gets removed from the aggregator with
> speed and duplex set to UNKNOWN while link is still marked as UP.
> 
> This patch fixes this scenario. Also 802.3ad mode is sensitive to
> these conditions while other modes are not, so making sure that it
> doesn't change the behavior for other modes.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/bonding/bond_main.c | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index b7313c1d9dcd..177be373966b 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3076,7 +3076,16 @@ static int bond_slave_netdev_event(unsigned long event,
>  		break;
>  	case NETDEV_UP:
>  	case NETDEV_CHANGE:
> -		bond_update_speed_duplex(slave);
> +		/* For 802.3ad mode only:
> +		 * Getting invalid Speed/Duplex values here will put slave
> +		 * in weird state. So mark it as link-down for the time
> +		 * being and let link-monitoring (miimon) set it right when
> +		 * correct speeds/duplex are available.
> +		 */
> +		if (bond_update_speed_duplex(slave) &&
> +		    BOND_MODE(bond) == BOND_MODE_8023AD)
> +			slave->link = BOND_LINK_DOWN;
> +
>  		if (BOND_MODE(bond) == BOND_MODE_8023AD)
>  			bond_3ad_adapter_speed_duplex_changed(slave);
>  		/* Fallthrough */

Then fix the drivers. Trying to workaround it here isn't helping.

The problem is that miimon is not required.  Bonding can be purely
event driven.
