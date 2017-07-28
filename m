From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: Re: [PATCH net v2] net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()
Date: Fri, 28 Jul 2017 21:53:51 +0200
Message-ID: <36d359f3-6dc5-1e2c-c788-30d680ed7e98@free.fr>
References: <20170728185836.28759-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Russell King <rmk@armlinux.org.uk>, Mason <slash.tmp@free.fr>
To: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:37418 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752599AbdG1TyL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Jul 2017 15:54:11 -0400
In-Reply-To: <20170728185836.28759-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/07/2017 20:58, Florian Fainelli wrote:

> Marc reported that he was not getting the PHY library adjust_link()
> callback function to run when calling phy_stop() + phy_disconnect()
> which does not indeed happen because we set the state machine to
> PHY_HALTED but we don't get to run it to process this state past that
> point.
> 
> Fix this with a synchronous call to phy_state_machine() in order to have
> the state machine actually act on PHY_HALTED, set the PHY device's link
> down, turn the network device's carrier off and finally call the
> adjust_link() function.
> 
> Reported-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
> Fixes: a390d1f379cf ("phylib: convert state_queue work to delayed_work")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes in v2:
> 
> - reword subject and commit message based on changes
> - dropped flush_scheduled_work() since it is redundant
> 
>  drivers/net/phy/phy.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index d0626bf5c540..5068c582d502 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -749,6 +749,9 @@ void phy_stop_machine(struct phy_device *phydev)
>  	if (phydev->state > PHY_UP && phydev->state != PHY_HALTED)
>  		phydev->state = PHY_UP;
>  	mutex_unlock(&phydev->lock);
> +
> +	/* Now we can run the state machine synchronously */
> +	phy_state_machine(&phydev->state_queue.work);
>  }
>  
>  /**

Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>

Regards.
