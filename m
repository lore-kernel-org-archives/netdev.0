From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] of_mdio: fix phy interrupt passing
Date: Wed, 19 Feb 2014 23:18:52 +0300
Message-ID: <530511AC.7030907@cogentembedded.com>
References: <1392654580-3706-1-git-send-email-ben.dooks@codethink.co.uk> <CAGVrzcYeuTA0Yd5YyOTuWQfnwLw9zP87MaYJOLwprZRCtvuaXw@mail.gmail.com> <530249EF.4060803@codethink.co.uk> <CAGVrzcZGW05uNj75VG7w4iSGre4OzEMhHedQfaynekrbhP4NLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@linaro.org>,
	linux-kernel <linux-kernel@lists.codethink.co.uk>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcZGW05uNj75VG7w4iSGre4OzEMhHedQfaynekrbhP4NLQ@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 02/17/2014 08:48 PM, Florian Fainelli wrote:

>>>> The of_mdiobus_register_phy() is not setting phy->irq this causing
>>>> some drivers to incorrectly assume that the PHY does not have an
>>>> IRQ associated with it or install an interrupt handler for the
>>>> PHY.

>>>> Simplify the code setting irq and set the phy->irq at the same
>>>> time so that the case if mdio->irq is not NULL is easier to read.

>>> The real bug fix, which is not properly explained here, is that
>>> irq_of_parse_and_map() should return values > 0 when the interrupt is
>>> valid, so this makes me wonder why we are not propagating the return
>>> value from irq_of_parse_and_map() in case the call to
>>> of_irq_parse_one() does return something non-zero?

>> No, the first issue is phy->dev never gets set, which causes the
>> issue. The cleanup was added as it seemed easier to put it in with
>> this.

> Ok, that really needs to be mentioned in the commit message, even
> being quite familiar (and possibly dumb too) with the code, I could
> not figure this out by reading your patch.

    Yes, the main issue was that phy->irq wasn't overridden from the value set 
by phy_device_create().

>> I think phy->irq is already initialised to PHY_POLL and thus there
>> is no need to set phy->irq if the irq_of_parse_and_map() fails.

> That is correct, the reason why I introduced 7d97637 ("net: of_mdio:
> do not overwrite PHY interrupt configuration") was that you are also
> allowed to change the irq type before calling into
> of_mdiobus_register(),

    Not really: of_mdiobus_register() init's all of mdio->irq[] with IRQ_POLL, 
thus wiping out all of the previous initialization, so I don't know what you 
did achieve with the aforementioned commit.

> so we want to preserve other irq values being
> set here, such as PHY_IGNORE_INTERRUPT. Your patch does take care of
> that since it only overrides the irq in case we could parse it.

    And it should have stayed that way. The latter change was unnecessary.

WBR, Sergei

