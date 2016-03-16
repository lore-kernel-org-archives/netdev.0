From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: Micrel Phy - Is there a way to configure the Phy not to do 802.3x
 flow control?
Date: Wed, 16 Mar 2016 11:08:14 -0400
Message-ID: <56E976DE.9040000@ti.com>
References: <56D8B83E.7000303@ti.com> <56D8D3D7.6070900@gmail.com>
 <56E1A55F.3090906@ti.com> <56E1B75F.9070100@gmail.com>
 <56E1CD4D.20405@ti.com> <56E30EE5.4050904@ti.com>
 <56E321DE.9030408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, <johan@kernel.org>,
	"open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
	"Kwok, WingMan" <w-kwok2@ti.com>, Andrew Lunn <andrew@lunnc.ch>,
	<opendmb@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:35777 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934826AbcCPPIS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 11:08:18 -0400
In-Reply-To: <56E321DE.9030408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/2016 02:51 PM, Florian Fainelli wrote:
> On 11/03/16 10:31, Murali Karicheri wrote:
>> On 03/10/2016 02:38 PM, Murali Karicheri wrote:
>>> On 03/10/2016 01:05 PM, Florian Fainelli wrote:
>>>> On 10/03/16 08:48, Murali Karicheri wrote:
>>>>> On 03/03/2016 07:16 PM, Florian Fainelli wrote:
>>>>>> On 03/03/16 14:18, Murali Karicheri wrote:
>>>>>>> Hi,
>>>>>>>
>>>>>>> We are using Micrel Phy in one of our board and wondering if we can force the
>>>>>>> Phy to disable flow control at start. I have a 1G ethernet switch connected
>>>>>>> to Phy and the phy always enable flow control. I would like to configure the
>>>>>>> phy not to flow control. Is that possible and if yes, what should I do in the
>>>>>>> my Ethernet driver to tell the Phy not to enable flow control?
>>>>>>
>>>>>> The PHY is not doing flow control per-se, your pseudo Ethernet MAC in
>>>>>> the switch is doing, along with the link partner advertising support for
>>>>>> it. You would want to make sure that your PHY device interface (provided
>>>>>> that you are using the PHY library) is not starting with Pause
>>>>>> advertised, but it could be supported.
>>>>>
>>>>> Understood that Phy is just advertise FC. The Micrel phy for 9031 advertise
>>>>> by default FC supported. After negotiation, I see that Phylib provide the 
>>>>> link status with parameter pause = 1, asym_pause = 1. How do I tell the Phy not
>>>>> to advertise?
>>>>>
>>>>> I call following sequence in the Ethernet driver.
>>>>>
>>>>> of_phy_connect(x,y,hndlr,a,z);
>>>>
>>>> Here you should be able to change phydev->advertising and
>>>> phydev->supported to mask the ADVERTISED_Pause | ADVERTISED_AsymPause
>>>> bits and have phy_start() restart with that which should disable pause
>>>> and asym_pause as seen by your adjust_link handler.
>>>>
>>> Ok. Good point. I will try this. Thanks for your suggestion.
>>>
>> I had to make following changes to the phy_device.c to allow the phy device
>> report maximum common flow control capability to Ethernet driver through
>> handler. My driver code looks like this.
>>
>>                 slave->phy = of_phy_connect(gbe_intf->ndev,
>>                                             slave->phy_node,
>>                                             hndlr, 0,
>>                                             phy_mode);
>>                 if (!slave->phy) {
>>                         dev_err(priv->dev, "phy not found on slave %d\n",
>>                                 slave->slave_num);
>>                         return -ENODEV;
>>                 }
>>                 dev_dbg(priv->dev, "phy found: id is: 0x%s\n",
>>                         dev_name(&slave->phy->dev));
>>
>>                 slave->phy->supported &=
>>                                 ~(SUPPORTED_Pause | SUPPORTED_Asym_Pause);
>>                 slave->phy->advertising = slave->phy->supported;
>>                 phy_start(slave->phy);
>>                 phy_read_status(slave->phy);
>>
>> And then in the phy_device.c, I did to get flow control off reported in
>> handler for link status update.
> 
> 
> 
>>
>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
>> index d551df6..55412ad 100644
>> --- a/drivers/net/phy/phy_device.c
>> +++ b/drivers/net/phy/phy_device.c
>> @@ -1021,8 +1021,8 @@ int genphy_read_status(struct phy_device *phydev)
>>                                 phydev->duplex = DUPLEX_FULL;
>>  
>>                 if (phydev->duplex == DUPLEX_FULL) {
>> -                       phydev->pause = lpa & LPA_PAUSE_CAP ? 1 : 0;
>> -                       phydev->asym_pause = lpa & LPA_PAUSE_ASYM ? 1 : 0;
>> +                       phydev->pause = adv & lpa & LPA_PAUSE_CAP ? 1 : 0;
>> +                       phydev->asym_pause = adv & lpa & LPA_PAUSE_ASYM ? 1 : 0;
> 
> What it means before your patch is that flow control is reported to the
> PHY device if the link partner advertises that, with your patch applied,
> it is reported only if the link partner and yourself advertise flow control.
> 
> You seem to be willing to have phydev->pause and phydev->asym_pause
> reflect the resolved pause capability, as opposed to the link partner's
> pause capability, which I am not convinced is correct here, because we
> need to take into account the user-configured pause configuration as
> well. Your adjust_link function should be the one deciding whether pause
> frame advertising and enabling is appropriate based on: locally
> configured pause settings (enabled, disabled, autoneg) and the link
> partner's pause capability.
> 
> I do agree that the two fields are confusing and poorly documented, and
> we should probably be consolidating the pause frame behavior in PHYLIB
> as opposed to letting drivers deal with like e.g: gianfar, bcm63xx_enet,
> tg3 etc.
> 
>>  
>> Could you explain, why the common maximum capability is not reported to the
>> driver as per standard?? Or Am I understood it wrong?
> 
> I do not understand the question, what is "maximum capability" in that
> context and what standard are you refering to?
> 
I assume the Phylib is responsible for deciding what is the flow
control pause and asym pause status to the driver through adjust_link.
When driver starts the phy, it also tells its capabilities (for example
it can reset some of the capabilities available in the Phy driver. In this
particular case, Pause is a feature supported by Micrel phy. I have reset
this feature in my driver by resetting this feature bit in the phy_device
as suggested earlier in this discussion). So phylib has all knowledge
available to disable flow control in this scenario even if LP is capable
of flow control. Wondering why every driver has to take this decision
again to enable or disable flow control instead of telling the driver
what to do. 

Looks like Marvel driver (reproduced below) does this logic. I think the
802.3x flow control states, but I don't have access to the standard documentation.
However I find the documentation at 
http://www.studioreti.it/slide/08_SwFlowContr_E_A.pdf.

Page 17 states the behavior based on Local device & Link partner's 
capabilities. Probably adjust_link() should tell the outcome in pause
and asym_pause so that driver can enable/disable fc. Also user's action
to be taken into account as well so that fc can be disabled if desired.

Code from drivers/net/phy/marvel.c

static int marvell_read_status(struct phy_device *phydev)
{

        int adv;
        int err;
        int lpa;
        int lpagb;
        int status = 0;

        /* Update the link, but return if there
         * was an error */
        err = genphy_update_link(phydev);
        if (err)
                return err;

        if (AUTONEG_ENABLE == phydev->autoneg) {
                status = phy_read(phydev, MII_M1011_PHY_STATUS);
                if (status < 0)
                        return status;

                lpa = phy_read(phydev, MII_LPA);
                if (lpa < 0)
                        return lpa;

                lpagb = phy_read(phydev, MII_STAT1000);
                if (lpagb < 0)
                        return lpagb;

                adv = phy_read(phydev, MII_ADVERTISE);
                if (adv < 0)
                        return adv;

                phydev->lp_advertising = mii_stat1000_to_ethtool_lpa_t(lpagb) |
                                         mii_lpa_to_ethtool_lpa_t(lpa);

                lpa &= adv;

                if (status & MII_M1011_PHY_STATUS_FULLDUPLEX        int adv;
        int err;
        int lpa;
        int lpagb;
        int status = 0;

        /* Update the link, but return if there
         * was an error */
        err = genphy_update_link(phydev);
        if (err)
                return err;
)
                        phydev->duplex = DUPLEX_FULL;
                else
                        phydev->duplex = DUPLEX_HALF;

                status = status & MII_M1011_PHY_STATUS_SPD_MASK;
                phydev->pause = phydev->asym_pause = 0;

                switch (status) {
                case MII_M1011_PHY_STATUS_1000:
                        phydev->speed = SPEED_1000;
                        break;

                case MII_M1011_PHY_STATUS_100:
                        phydev->speed = SPEED_100;
                        break;

                default:
                        phydev->speed = SPEED_10;

                        break;
                }

                if (phydev->duplex == DUPLEX_FULL) {
                        phydev->pause = lpa & LPA_PAUSE_CAP ? 1 : 0;
                        phydev->asym_pause = lpa & LPA_PAUSE_ASYM ? 1 : 0;
                }
        } else {
                int bmcr = phy_read(phydev, MII_BMCR);

                if (bmcr < 0)
                        return bmcr;

                if (bmcr & BMCR_FULLDPLX)
                        phydev->duplex = DUPLEX_FULL;
                else
                        phydev->duplex = DUPLEX_HALF;

                if (bmcr & BMCR_SPEED1000)
                        phydev->speed = SPEED_1000;
                else if (bmcr & BMCR_SPEED100)
                        phydev->speed = SPEED_100;
                else
                        phydev->speed = SPEED_10;

                phydev->pause = phydev->asym_pause = 0;
                phydev->lp_advertising = 0;
        }

        return 0;
}


-- 
Murali Karicheri
Linux Kernel, Keystone
