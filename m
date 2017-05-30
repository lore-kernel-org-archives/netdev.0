From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] net: phy: micrel: Restore led_mode and clk_sel on
 resume
Date: Tue, 30 May 2017 15:19:16 -0700
Message-ID: <30fb605c-675b-8458-aff7-36532635ccc2@gmail.com>
References: <cover.1496164448.git.leonard.crestez@nxp.com>
 <a8d0393c977b0d6fdab5d48ad13ca4d1ca893a07.1496164448.git.leonard.crestez@nxp.com>
 <44ddeaeb-3e23-3d88-cc5c-9ed290507648@gmail.com>
 <1496182080.19669.11.camel@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Johan Hovold <johan@kernel.org>,
        Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        Philipp Zabel <p.zabel@pengutronix.de>,
        Fabio Estevam <fabio.estevam@nxp.com>, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Shawn Guo <shawnguo@kernel.org>
To: Leonard Crestez <leonard.crestez@nxp.com>,
        Andrew Lunn <andrew@lunn.ch>, Andy Duan <fugang.duan@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496182080.19669.11.camel@nxp.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/30/2017 03:08 PM, Leonard Crestez wrote:
> On Tue, 2017-05-30 at 11:05 -0700, Florian Fainelli wrote:
>> On 05/30/2017 10:34 AM, Leonard Crestez wrote:
>>> These bits seem to be lost after a suspend/resume cycle so just set them
>>> again.
>>>
>>> This patch fixes ethernet suspend/resume on imx6ul-14x14-evk boards.
>>>
>>> Signed-off-by: Leonard Crestez <leonard.crestez@nxp.com>
>>> ---
>>>  drivers/net/phy/micrel.c | 15 +++++++++++++++
>>>  1 file changed, 15 insertions(+)
>>>
>>> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
>>> index 6a5fd18..c53ee17 100644
>>> --- a/drivers/net/phy/micrel.c
>>> +++ b/drivers/net/phy/micrel.c
>>> @@ -700,6 +700,9 @@ static int kszphy_suspend(struct phy_device *phydev)
>>>  
>>>  static int kszphy_resume(struct phy_device *phydev)
>>>  {
>>> +	struct kszphy_priv *priv = phydev->priv;
>>> +	int ret;
>>> +
>>>  	genphy_resume(phydev);
>>>  
>>>  	/* Enable PHY Interrupts */
>>> @@ -709,6 +712,18 @@ static int kszphy_resume(struct phy_device *phydev)
>>>  			phydev->drv->config_intr(phydev);
>>>  	}
>>>  
>>> +	if (priv->rmii_ref_clk_sel) {
>>> +		ret = kszphy_rmii_clk_sel(phydev, priv->rmii_ref_clk_sel_val);
>>> +		if (ret) {
>>> +			phydev_err(phydev,
>>> +				   "failed to set rmii reference clock\n");
>>> +			return ret;
>>> +		}
>>> +	}
>>> +
>>> +	if (priv->led_mode >= 0)
>>> +		kszphy_setup_led(phydev, priv->type->led_mode_reg, priv->led_mode);
>>
>> Should not we actually call kszphy_config_init() in order to restore
>> broadcast and nand disable bits as well?
> 
> I don't know. In my case the B_CAST_OFF bit doesn't seem to be lost and
> NAND_TREE_ON is already off by the time it gets to linux.
> 
> The bit that get lost seem to disappear just as the phy is resumed. I
> added some prints and they look like this:
> 
> PM: early resume of devices complete after 6.534 msecs
> begin resume
> 0x1F=0x8190 0x16=0x202
> after genphy_resume 0x1F=0x8100 0x16=0x202
> end
> resume 0x1F=0x8190 0x16=0x202

OK, so it actually would not hurt to call config_init() again here, right?

> 
>> If not, I would be more comfortable if we did create a specific function
>> that takes care of setting the reference clock and LED mode.
> 
> Ok, I can add a function called kszphy_config_reset() with a comment
> explaining it's for bits lost on reset/resume.
> 
> Or perhaps a better option would be to just save/restore the entire
> 0x1F register?

Register 0 through 15 are standardized, but those after that are not,
and PHYs with a gazillion of registers already need to have a specific
set of suspend/resume sequence due to their proprietary indirect
register scheme, so we cannot quite come up with a generic function that
would cache all 16 or 32 registers and flat out restore those.

Similarly, having phy_resume() systematically calling into config_init()
is a bit of a stretch and can be pretty inefficient.
-- 
Florian
