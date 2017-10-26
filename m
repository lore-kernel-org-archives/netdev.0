From: Richard Leitner <richard.leitner@skidata.com>
Subject: Re: [PATCH] net: ethernet: fsl: don't en/disable refclk on open/close
Date: Thu, 26 Oct 2017 10:28:41 +0200
Message-ID: <b3d93ec0-395d-b0ef-0ba2-923cfecb36b1@skidata.com>
References: <20171022131130.8580-1-dev@g0hl1n.net>
 <6656d8d0-874a-574e-9ea9-37f8238bd155@gmail.com>
 <1a54f090-be13-a82d-7d5c-1c76f45df4a8@g0hl1n.net>
 <f0bf60b0-b2fb-9ed3-7800-2a5c6bb6ead8@gmail.com>
 <154bc00e-cf87-6d8d-c3ad-8c3803104e90@g0hl1n.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Richard Leitner <dev@g0hl1n.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        Richard Leitner <richard.leitner@skidata.com>
To: Florian Fainelli <f.fainelli@gmail.com>, <fugang.duan@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <154bc00e-cf87-6d8d-c3ad-8c3803104e90@g0hl1n.net>
Content-Language: de-AT
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 10/23/2017 01:01 AM, Richard Leitner wrote:
> On 10/23/2017 12:48 AM, Florian Fainelli wrote
>> On 10/22/2017 03:30 PM, Richard Leitner wrote:
>>> On 10/22/2017 08:31 PM, Florian Fainelli wrote:
>>>> On 10/22/2017 06:11 AM, Richard Leitner wrote:

...

>>> But back to this patch: Is it OK the way it fixes the issue?
>>
>> Fugang and Andrew probably know this hardware a lot better, I would have
>> to look at the code path a bit more to understand if an alternative
>> solution is possible. It sounds like your patch could create a power
>> consumption regression, so maybe add a check for the PHY ID that is
>> problematic by doing something like:
>>
>> if (priv->phydev->drv && priv->phydev->drv->phy_id == XXXX_XXXX) where
>> XXXX_XXXX is the LAN870 PHY ID (obtained from MII register 2 & 3).
> 
> I already had a patch which does this check and triggers a reset of the 
> PHY after the refclk was enabled (in fec_enet_clk_enable) in case the 
> phy_id matches. This would IMHO avoid all power consumption 
> regressions... It was something like:
> 
> switch (priv->phydev->drv->phy_id) {
> case XXXX:
> case XXXX:
>      ret = fec_reset_phy(ndev);
>      if (ret)
>          goto failed_reset;
>      if (ndev->phydev) {
>          ret = phy_init_hw(ndev->phydev);
>          if (ret)
>              goto failed_reset;
>      }
> }

Another possible solution that came to my mind is to add a flag called 
something like "PHY_RST_AFTER_CLK_EN" to the flags variable in struct 
phy_driver. This flag could then be set in the smsc PHY driver for 
affected PHYs.

Then instead of comparing the phy_id in the MAC driver this flag could 
be checked:

if (phydev->drv->flags & PHY_RST_AFTER_CLK_EN) {
	ret = fec_reset_phy(ndev);
	if (ret)
		goto failed_reset;
	if (ndev->phydev) {
		ret = phy_init_hw(ndev->phydev);
		if (ret)
			goto failed_reset;
	}
}

This approach would IMHO also be easier and less prune to erros for 
porting to other MAC drivers (if needed).

So what would be the better approach in your opinion and how should I 
procede here?

kind regards,
Richard.L
