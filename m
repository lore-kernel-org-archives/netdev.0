From: Richard Leitner <richard.leitner-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/2] net: ethernet: fsl: add phy reset after clk enable
 option
Date: Fri, 7 Jul 2017 07:50:47 +0200
Message-ID: <81105c77-d48f-271b-2de1-c877b9413184@skidata.com>
References: <1499346330-12166-1-git-send-email-richard.leitner@skidata.com>
 <1499346330-12166-2-git-send-email-richard.leitner@skidata.com>
 <AM4PR0401MB2260ECD4508E26FF16670004FFAA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "dev-M/VWbR8SM2SsTnJN9+BGXg@public.gmane.org" <dev-M/VWbR8SM2SsTnJN9+BGXg@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Richard Leitner <richard.leitner-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org>
To: Andy Duan <fugang.duan-3arQi8VN3Tc@public.gmane.org>,
        "robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "mark.rutland-5wv7dgnIgG8@public.gmane.org" <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AM4PR0401MB2260ECD4508E26FF16670004FFAA0-4rsfagO7TJxhEPOT2zA1/I3W/0Ik+aLCnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On 07/07/2017 07:30 AM, Andy Duan wrote:
> From: Richard Leitner <richard.leitner-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org> Sent: Thursday, July 06, 2017 9:06 PM
>> To: Andy Duan <fugang.duan-3arQi8VN3Tc@public.gmane.org>; robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org;
>> mark.rutland-5wv7dgnIgG8@public.gmane.org
>> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
>> kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; dev-M/VWbR8SM2SsTnJN9+BGXg@public.gmane.org; Richard Leitner
>> <richard.leitner-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org>
>> Subject: [PATCH 2/2] net: ethernet: fsl: add phy reset after clk enable option
>>
>> Some PHYs (for example the LAN8710) doesn't allow turning the clocks off and
>> on again without reset (according to their datasheet). Exactly this behaviour
>> was introduced for power saving reasons by commit e8fcfcd5684a
>> ("net: fec: optimize the clock management to save power") Therefore add a
>> devictree option to perform a PHY reset and configuration after every clock
>> enable.
>>
>> For a better understanding here's a outline of the time response of the clock
>> and reset lines before and after this patch:
>>
>> 			  v--fec_probe()              v--fec_enet_open()
>> 			  v                           v
>> 	w/o patch eCLK:
>> ___||||||||____________________|||||||||||||||||
>> 	w/o patch nRST: ----__------------------------------------------
>> 	w/o patch CONF:
>> _______XX_______________________________________
>>
>> 	w/  patch eCLK:
>> ___||||||||____________________|||||||||||||||||
>> 	w/  patch nRST: ----__--------------------------__--------------
>> 	w/  patch CONF:
>> _______XX__________________________XX___________
>> 			  ^                           ^
>> 			  ^--fec_probe()              ^--fec_enet_open()
>>
>> In our case this problem does occur at about every 10th to 50th POR of an
>> LAN8710 connected to an i.MX6 SoC. The typical symptom of this problem is a
>> "swinging" ethernet link. Similar issues were experienced by users of the NXP
>> forum:
>> 	https://community.nxp.com/thread/389902
>> 	https://community.nxp.com/message/309354
>> With this patch applied the issue didn't occur for at least a few hundred PORs
>> of our board.
>>
>> Fixes: e8fcfcd5684a ("net: fec: optimize the clock management to sa...")
>> Signed-off-by: Richard Leitner <richard.leitner-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org>

...

>> *ndev, bool enable)
>> 		ret = clk_prepare_enable(fep->clk_ref);
>> 		if (ret)
>> 			goto failed_clk_ref;
>> +
>> +		/* reset the phy after clk is enabled if it's configured */
>> +		if (fep->phy_reset_after_clk_enable) {
>> +			ret = fec_reset_phy(ndev);
>> +			if (ret)
>> +				goto failed_reset;
>> +			if (ndev->phydev) {
>> +				ret = phy_init_hw(ndev->phydev);
>> +				if (ret)
>> +					goto failed_reset;
>> +			}
>> +		}
>
> Since it is common issue so long as using the PHY, can you move it into smsc phy driver like in .smsc_phy_reset() function ?
> And get the reset pin from phy dts node.

During my first glance at this problem I had the same "feeling" that it 
should go into smsc.c. Therefore I've tried that already, but I haven't 
found a suitable "place" for that. My basic problem is: Where do I know 
(from smsc.c view) when the enetrefclk was disabled/enabled again 
without changing fec_main.c?

Some more points that come into my mind:
  - The smsc_phy_reset function is registered as "soft_reset". Would it 
be OK to use nRST in it?
  - Would it be OK to call the phy_init_hw function from within the 
smsc_phy_reset?
  - IMHO I'd have to move the reset gpio binding inside the phy node 
then. Isn't that a pretty big change doing that for all PHYs/FECs? Would 
it be "worth" it?

Sorry for these many (maybe noobish) questions, but I'm pretty new to 
the kernels fec/phy stuff ;-)

>
> Andy
>

Thanks & regards,
Richard.L
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
