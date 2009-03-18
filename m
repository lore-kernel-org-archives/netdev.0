From: "Tomi Orava" <tomimo@ncircle.nullnet.fi>
Subject: Re: [Bugme-new] [Bug 12886] New: skge wake on lan
Date: Wed, 18 Mar 2009 09:32:34 +0200 (EET)
Message-ID: <919358a27b164c5f76cf42d3b3063050.squirrel@ncircle.nullnet.fi>
References: <bug-12886-10286@http.bugzilla.kernel.org/>
    <200903171101.32812.rjw@sisk.pl>
    <9e1133f653c918ec3c19c8fe28452a9f.squirrel@ncircle.nullnet.fi>
    <200903172223.14608.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	"Stephen Hemminger" <shemminger@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xdsl-83-150-88-111.nebulazone.fi ([83.150.88.111]:40862 "EHLO
	ncircle.nullnet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259AbZCRHci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 03:32:38 -0400
In-Reply-To: <200903172223.14608.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again,

>> The previously mentioned patch reverted the ethtool output is
>> (ie. this is a working 2.6.28.7 system atm):
>
> I wonder what it shows if that commit is not reverted (in fact it is
> necessary
> on some other systems for things to work correctly).

Ethtool eth0 shows on latest 2.6.28.8 kernel with your manually merged
patch below:

Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Half 1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Half 1000baseT/Full
        Advertised auto-negotiation: Yes
        Speed: 1000Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: pg
        Wake-on: g
        Current message level: 0x00000037 (55)
        Link detected: yes

Ie. looks like exactly the same as with the commit reverted.

>
> Also, please check if the appended patch helps (of course, without
> reverting
> the commit).
>
> ---
>  drivers/net/skge.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> Index: linux-2.6/drivers/net/skge.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/skge.c
> +++ linux-2.6/drivers/net/skge.c
> @@ -3856,8 +3856,9 @@ static struct net_device *skge_devinit(s
>  	skge->speed = -1;
>  	skge->advertising = skge_supported_modes(hw);
>
> -	if (device_may_wakeup(&hw->pdev->dev))
> -		skge->wol = wol_supported(hw) & WAKE_MAGIC;
> +	skge->wol = wol_supported(hw) & WAKE_MAGIC;
> +	if (skge->wol && device_can_wakeup(&hw->pdev->dev))
> +		device_set_wakeup_enable(&hw->pdev->dev, true);
>
>  	hw->dev[port] = dev;

Hmm, looks like this patch is against a 2.6.28.8 tree with the commit
reverted. I merged the couple lines as following.

line 3859:

        // if (pci_wake_enabled(hw->pdev))
        //      skge->wol = wol_supported(hw) & WAKE_MAGIC;
        skge->wol = wol_supported(hw) & WAKE_MAGIC;
        if (skge->wol && device_can_wakeup(&hw->pdev->dev))
                device_set_wakeup_enable(&hw->pdev->dev, true);

and this really seems to fix the problem. The system is able to wake
up via etherwake just fine.

Regards,
Tomi Orava

-- 


