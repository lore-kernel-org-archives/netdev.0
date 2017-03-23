From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: handle state correctly in phy_stop_machine
Date: Thu, 23 Mar 2017 14:41:52 -0700
Message-ID: <d3696191-fabc-d150-eb3f-df60f3bcfbe3@gmail.com>
References: <1490214421-7269-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andrew Lunn <andrew@lunn.ch>
To: Zach Brown <zach.brown@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490214421-7269-1-git-send-email-zach.brown@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/22/2017 01:27 PM, Zach Brown wrote:
> From: Nathan Sullivan <nathan.sullivan@ni.com>
> 
> If the PHY is halted on stop, then do not set the state to PHY_UP.  This
> ensures the phy will be restarted later in phy_start when the machine is
> started again.

So essentially what you want to "defeat" here is entering phy_start()
with PHY_UP therefore not run this part:

        case PHY_HALTED:
                /* make sure interrupts are re-enabled for the PHY */
                if (phydev->irq != PHY_POLL) {
                        err = phy_enable_interrupts(phydev);
                        if (err < 0)
                                break;
                }

                phydev->state = PHY_RESUMING;
                do_resume = true;
                break;

which is what re-enables interrupts and makes sure the PHY is resumed,
right?

If that's the scenario, I guess:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> 
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
> Signed-off-by: Brad Mouring <brad.mouring@ni.com>
> Acked-by: Xander Huff <xander.huff@ni.com>
> Acked-by: Kyle Roeschley <kyle.roeschley@ni.com>
> ---
>  drivers/net/phy/phy.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 7cc1b7d..fe2d4c4 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -678,7 +678,7 @@ void phy_stop_machine(struct phy_device *phydev)
>  	cancel_delayed_work_sync(&phydev->state_queue);
>  
>  	mutex_lock(&phydev->lock);
> -	if (phydev->state > PHY_UP)
> +	if (phydev->state > PHY_UP && phydev->state != PHY_HALTED)
>  		phydev->state = PHY_UP;
>  	mutex_unlock(&phydev->lock);
>  }
> 


-- 
Florian
