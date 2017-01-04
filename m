From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] phy state machine: failsafe leave invalid RUNNING state
Date: Wed, 4 Jan 2017 07:13:23 -0800
Message-ID: <6845805d-4dae-0a3a-c56c-6feb86f4b553@gmail.com>
References: <1483542298-9747-1-git-send-email-zefir.kurtisi@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35655 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968330AbdADPNv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 10:13:51 -0500
Received: by mail-oi0-f68.google.com with SMTP id v84so74696130oie.2
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 07:13:25 -0800 (PST)
In-Reply-To: <1483542298-9747-1-git-send-email-zefir.kurtisi@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/04/2017 07:04 AM, Zefir Kurtisi wrote:
> While in RUNNING state, phy_state_machine() checks for link changes by
> comparing phydev->link before and after calling phy_read_status().
> This works as long as it is guaranteed that phydev->link is never
> changed outside the phy_state_machine().
> 
> If in some setups this happens, it causes the state machine to miss
> a link loss and remain RUNNING despite phydev->link being 0.
> 
> This has been observed running a dsa setup with a process continuously
> polling the link states over ethtool each second (SNMPD RFC-1213
> agent). Disconnecting the link on a phy followed by a ETHTOOL_GSET
> causes dsa_slave_get_settings() / dsa_slave_get_link_ksettings() to
> call phy_read_status() and with that modify the link status - and
> with that bricking the phy state machine.

That's the interesting part of the analysis, how does this brick the PHY
state machine? Is the PHY driver changing the link status in the
read_status callback that it implements?

> 
> This patch adds a fail-safe check while in RUNNING, which causes to
> move to CHANGELINK when the link is gone and we are still RUNNING.
> 
> Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
> ---
>  drivers/net/phy/phy.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 28548af..0f9a61e 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -966,6 +966,15 @@ void phy_state_machine(struct work_struct *work)
>  			if (old_link != phydev->link)
>  				phydev->state = PHY_CHANGELINK;
>  		}
> +		/*
> +		 * Failsafe: check that nobody set phydev->link=0 between two
> +		 * poll cycles, otherwise we won't leave RUNNING state as long
> +		 * as link remains down.
> +		 */
> +		if (!phydev->link && phydev->state == PHY_RUNNING) {
> +			phydev->state = PHY_CHANGELINK;
> +			dev_warn(&phydev->dev, "no link in PHY_RUNNING\n");
> +		}
>  		break;
>  	case PHY_CHANGELINK:
>  		err = phy_read_status(phydev);
> 

-- 
Florian
