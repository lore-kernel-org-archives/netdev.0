From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net/phy: micrel: Add workaround for bad autoneg
Date: Wed, 21 Oct 2015 14:46:50 -0700
Message-ID: <562807CA.8020503@gmail.com>
References: <1445455024-5519-1-git-send-email-nathan.sullivan@ni.com> <CAGVrzcZNcvkw_egX0rAOe_CZnrQj8pDONJDr973Dw-ec1Ce91g@mail.gmail.com> <20151021194234.GA5746@nathan3500-linux-VM>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nathan Sullivan <nathan.sullivan@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151021194234.GA5746@nathan3500-linux-VM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21/10/15 12:42, Nathan Sullivan wrote:
> On Wed, Oct 21, 2015 at 12:20:21PM -0700, Florian Fainelli wrote:
>> 2015-10-21 12:17 GMT-07:00 Nathan Sullivan <nathan.sullivan@ni.com>:
>>> Very rarely, the KSZ9031 will appear to complete autonegotiation, but
>>> will drop all traffic afterwards.  When this happens, the idle error
>>> count will read 0xFF after autonegotiation completes.  Reset the PHY
>>> when in that state.
>>>
>>> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
>>> ---
>>>  drivers/net/phy/micrel.c |   23 ++++++++++++++++++++++-
>>>  1 file changed, 22 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
>>> index 499185e..cf6312f 100644
>>> --- a/drivers/net/phy/micrel.c
>>> +++ b/drivers/net/phy/micrel.c
>>> @@ -514,6 +514,27 @@ static int ksz8873mll_read_status(struct phy_device *phydev)
>>>         return 0;
>>>  }
>>>
>>> +static int ksz9031_read_status(struct phy_device *phydev)
>>> +{
>>> +       int err;
>>> +       int regval;
>>> +
>>> +       err = genphy_read_status(phydev);
>>> +       if (err)
>>> +               return err;
>>> +
>>> +       /* Make sure the PHY is not broken. Read idle error count,
>>> +        * and reset the PHY if it is maxed out.
>>> +        */
>>> +       regval = phy_read(phydev, MII_STAT1000);
>>> +       if ((regval & 0xFF) == 0xFF) {
>>
>> Don't you also need to set phydev->state to PHY_READY here to force
>> the state machine to restart?
>>
> 
> I don't think so, we stay in the PHY_AN state since phy_init_hw will restart
> autonegotiation.  Setting link=0 will go through PHY_NOLINK then back to
> PHY_AN, so we wait for autoneg to complete again.

Good point, thanks for clarifiying that part.
-- 
Florian
