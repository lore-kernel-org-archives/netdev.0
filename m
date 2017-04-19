From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 2/2] net: phy: Don't miss phy_suspend() on PHY_HALTED
 for PHYs with interrupts
Date: Wed, 19 Apr 2017 09:31:42 -0700
Message-ID: <09f70540-d680-255e-3f13-668dbea54f24@gmail.com>
References: <1490180524-28675-1-git-send-email-rogerq@ti.com>
 <1490180524-28675-3-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, davem@davemloft.ne, nsekhar@ti.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "stable # v4 . 9+" <stable@vger.kernel.org>,
        Alexander Kochetkov <al.kochet@gmail.com>
To: Roger Quadros <rogerq@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490180524-28675-3-git-send-email-rogerq@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/22/2017 04:02 AM, Roger Quadros wrote:
> phy_suspend() doesn't get called as part of phy_stop() for PHYs
> using interrupts because the phy state machine is never triggered
> after a phy_stop().
> 
> Explicitly trigger the PHY state machine in phy_stop() so that it can
> see the new PHY state (HALTED) and suspend the PHY.
> 
> As most PHYLIB consumers will call phy_stop() with rtnl_lock() held
> from ndo_close() so we use don't wait for workqueue cancellation in
> phy_trigger_machine() by passing false for the 'sync' argument.

Sorry for this long delay in responding. I am not exactly sure if this
thing to do here. phy_stop() does not have a requirement to suspend the
PHY as it is currently defined. You may want to manually suspend the PHY
after a phy_stop() by explicitly calling phy_suspend().

Let me think about it some more.

> 
> Fixes: 3c293f4e08b5 ("net: phy: Trigger state machine on state change and not polling.")
> Cc: stable <stable@vger.kernel.org> # v4.9+
> Signed-off-by: Roger Quadros <rogerq@ti.com>
> ---
>  drivers/net/phy/phy.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 49dedf8..ab14e7b 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -907,6 +907,7 @@ void phy_stop(struct phy_device *phydev)
>  	 * of rtnl_lock(), but PHY_HALTED shall guarantee phy_change()
>  	 * will not reenable interrupts.
>  	 */
> +	phy_trigger_machine(phydev, false);
>  }
>  EXPORT_SYMBOL(phy_stop);
>  
> 


-- 
Florian
