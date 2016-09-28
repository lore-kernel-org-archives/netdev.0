From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 5/6] net: phy: Trigger state machine on state change
 and not polling.
Date: Wed, 28 Sep 2016 14:31:54 -0700
Message-ID: <de3b7050-4346-1a7a-4a27-feb8bb8affc4@gmail.com>
References: <1475051544-18561-1-git-send-email-andrew@lunn.ch>
 <1475051544-18561-6-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35570 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752857AbcI1Vb4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 17:31:56 -0400
Received: by mail-pf0-f194.google.com with SMTP id 6so2608018pfl.2
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 14:31:56 -0700 (PDT)
In-Reply-To: <1475051544-18561-6-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2016 01:32 AM, Andrew Lunn wrote:
> The phy_start() is used to indicate the PHY is now ready to do its
> work. The state is changed, normally to PHY_UP which means that both
> the MAC and the PHY are ready.
> 
> If the phy driver is using polling, when the next poll happens, the
> state machine notices the PHY is now in PHY_UP, and kicks off
> auto-negotiation, if needed.
> 
> If however, the PHY is using interrupts, there is no polling. The phy
> is stuck in PHY_UP until the next interrupt comes along. And there is
> no reason for the PHY to interrupt.
> 
> Have phy_start() schedule the state machine to run, which both speeds
> up the polling use case, and makes the interrupt use case actually
> work.
> 
> This problems exists whenever there is a state change which will not
> cause an interrupt. Trigger the state machine in these cases,
> e.g. phy_error().
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

No particular objections, this should also fix this:

http://lists.openwall.net/netdev/2016/05/17/147

> ---
>  drivers/net/phy/phy.c | 22 ++++++++++++++++++++--
>  1 file changed, 20 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 940450c6cd2c..f446ce04caf3 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -608,6 +608,21 @@ void phy_start_machine(struct phy_device *phydev)
>  }
>  
>  /**
> + * phy_trigger_machine - trigger the state machine to run
> + *
> + * @phydev: the phy_device struct
> + *
> + * Description: There has been a change in state which requires that the
> + *   state machine runs.
> + */
> +
> +static void phy_trigger_machine(struct phy_device *phydev)
> +{
> +	cancel_delayed_work_sync(&phydev->state_queue);
> +	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue, 0);
> +}
> +
> +/**
>   * phy_stop_machine - stop the PHY state machine tracking
>   * @phydev: target phy_device struct
>   *
> @@ -639,6 +654,8 @@ static void phy_error(struct phy_device *phydev)
>  	mutex_lock(&phydev->lock);
>  	phydev->state = PHY_HALTED;
>  	mutex_unlock(&phydev->lock);
> +
> +	phy_trigger_machine(phydev);
>  }
>  
>  /**
> @@ -785,8 +802,7 @@ void phy_change(struct phy_device *phydev)
>  	}
>  
>  	/* reschedule state queue work to run as soon as possible */
> -	cancel_delayed_work_sync(&phydev->state_queue);
> -	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue, 0);
> +	phy_trigger_machine(phydev);
>  	return;
>  
>  ignore:
> @@ -875,6 +891,8 @@ void phy_start(struct phy_device *phydev)
>  	/* if phy was suspended, bring the physical link up again */
>  	if (do_resume)
>  		phy_resume(phydev);
> +
> +	phy_trigger_machine(phydev);
>  }
>  EXPORT_SYMBOL(phy_start);
>  
> 


-- 
Florian
