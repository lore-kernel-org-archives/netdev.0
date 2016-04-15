From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: Ensure the state machine is called when phy is
 UP
Date: Fri, 15 Apr 2016 13:10:12 -0700
Message-ID: <57114AA4.5080803@gmail.com>
References: <1460750172-7796-1-git-send-email-alexandre.belloni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460750172-7796-1-git-send-email-alexandre.belloni@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/04/16 12:56, Alexandre Belloni wrote:
> Commit d5c3d84657db ("net: phy: Avoid polling PHY with
> PHY_IGNORE_INTERRUPTS") removed the last polling done on the phy. Since
> then, the last actual poll done on the phy happens PHY_STATE_TIME seconds
> (that is actually one second) after registering the phy. If the interface
> is not UP by that time, any previous IRQ indicating the link is up is
> ignored. Moreover, nothing will start the autonegociation so the phy will
> simply change from READY to UP and never actually go to RUNNING.

What do you mean by that? phy_start() will start auto-negotiation.

> 
> The one second delay explains why the issue is not seen when booting from
> NFS or when the interface is configured at boot time.
> 
> To solve that, ensure the state machine is called as soon as the state
> changes from READY to UP.

The fix may be good, but I would like to see which driver are you
observing this with? Also, having a capture of the PHY state machine
with debug prints enabled could help us figure out the sequence of
events leading to what you observed.

Assuming you might be using the macb driver, I see a race condition in
how macb_probe() registers for its MDIO bus and probes for the PHY,
after calling register_netdev(), which is something that is not good,
because as soon as register_netdev() is called, an in-kernel notifier
can start opening the device for use before you have returned...

> 
> Fixes: d5c3d84657db ("net: phy: Avoid polling PHY with PHY_IGNORE_INTERRUPTS")
> Signed-off-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>
> ---
>  drivers/net/phy/phy.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 5590b9c182c9..25f6bfd1c8fd 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -787,6 +787,9 @@ void phy_start(struct phy_device *phydev)
>  		break;
>  	case PHY_READY:
>  		phydev->state = PHY_UP;
> +		cancel_delayed_work_sync(&phydev->state_queue);
> +		queue_delayed_work(system_power_efficient_wq,
> +				   &phydev->state_queue, 0);
>  		break;
>  	case PHY_HALTED:
>  		/* make sure interrupts are re-enabled for the PHY */
> 


-- 
Florian
