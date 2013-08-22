From: boris brezillon <b.brezillon@overkiz.com>
Subject: Re: [RFC PATCH] phylib: mdio: handle register/unregister/register
 sequence
Date: Thu, 22 Aug 2013 15:05:48 +0200
Message-ID: <52160CAC.3040603@overkiz.com>
References: <1377174836-10569-1-git-send-email-b.brezillon@overkiz.com>
 <CAGVrzcaByva=8xiswcsW1B8G4dL=jY0RdaHKzNqaT_0Lrwbprg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Nick Bowler <nbowler@elliptictech.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Grant Likely <grant.likely@secretlab.ca>, Mark Brown <broonie@kernel.org>,
 netdev <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAGVrzcaByva=8xiswcsW1B8G4dL=jY0RdaHKzNqaT_0Lrwbprg@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hello Florian,

Thanks for your answer.

On 22/08/2013 14:43, Florian Fainelli wrote:
> Hello Boris,
>
> 2013/8/22 Boris BREZILLON <b.brezillon@overkiz.com>:
>> Hello,
>>
>> This patch is a proposal to support the register/unregister/register
>> sequence on a given mdio bus.
>>
>> I use the register/unregister/register sequence to add a fallback when the
>> of_mdiobus_register (this function calls mdiobus_register with phy_mask
>> set to ~0) does not register any phy device (because the device tree does
>> not define any phy).
>> In this case I call mdiobus_unregister and then call mdiobus_register with
>> a phy_mask set to 0 to trigger a full mdio bus scan.
>>
>> I'm not sure this is the right way to do it (this is why I added RFC in the
>> subject).
>>
>> Could someone help me figuring out what I should use to implement my fallback ?
>>
>> 1) use the register/unregister/register sequence
>> 2) reimplement the "for (i = 0; i < PHY_MAX_ADDR; i++)" mdiobus_scan loop
> I think solution 2 is nicer, in that case, would it be enough in your
> case to export a function called mdiobus_scan()? You could call at a
> time you know PHY devices have a chance of having been probed?
mdiobus_scan is already exported:
struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr);

This function scans the presence of a phy device at a given address.

What I need is a loop which scan all the possible address on the given
mdio bus:

struct phy_device *mdiobus_full_scan(struct mii_bus *bus)
{
     int i;
     for (i = 0; i < PHY_MAX_ADDR; i++) {
         if ((bus->phy_mask & (1 << i)) == 0) {
             struct phy_device *phydev;

             phydev = mdiobus_scan(bus, i);
             if (IS_ERR(phydev)) {
                 err = PTR_ERR(phydev);
                 goto error;
             }
         }
     }
     return 0;

error:
     while (--i >= 0) {
         if (bus->phy_map[i])
             device_unregister(&bus->phy_map[i]->dev);
     }
}
EXPORT_SYMBOL(mdiobus_full_scan);

Since I am the only one who need this kind of functionnality right now, 
I'm not sure
this is a good idea to export a new function.

This behaviour may be implemented in the of_mdiobus_register function:
when no dt phy node are found in the mdio bus dt node, we could launch a 
full
scan.

What do you think ?

Best Regards,

Boris
