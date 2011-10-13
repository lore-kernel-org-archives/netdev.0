From: David Daney <david.s.daney-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/3] netdev/phy: Add driver for Broadcom BCM8706 10G
 Ethernet PHY
Date: Wed, 12 Oct 2011 21:45:43 -0700
Message-ID: <4E966CF7.7060901@gmail.com>
References: <1318442783-29058-1-git-send-email-david.daney@cavium.com>
 <1318442783-29058-4-git-send-email-david.daney@cavium.com>
 <20111013003129.GC14042@ponder.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, afleming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20111013003129.GC14042-e0URQFbLeQY2iJbIjFUEsiwD8/FfD2ys@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/12/2011 05:31 PM, Grant Likely wrote:
> On Wed, Oct 12, 2011 at 11:06:23AM -0700, David Daney wrote:
>> Add a driver and PHY_ID number for said device.  This is a 10Gig PHY
>> which uses MII_ADDR_C45 addressing, it is always 10G full duplex, so
>> there is no autonegotiation.  All we do is report link state and send
>> interrupts when it changes.
>>
>> If the PHY has a device tree of_node associated with it, the
>> "broadcom,c45-reg-init" property is used to supply register
>> initialization values when config_init() is called.
>>
>> Signed-off-by: David Daney<david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>> ---
>>
[...]
>> +The Broadcom BCM8706 is a 10G Ethernet PHY.  It has these bindings in
>> +addition to the standard PHY bindings.
>> +
>> +Compatible: Should contain "broadcom,bcm8706" and
>> +            "ethernet-phy-ieee802.3-c45"
>> +
>> +Optional Properties:
>> +
>> +- broadcom,c45-reg-init : one of more sets of 4 cells.  The first cell
>> +  is the device type, the second a register address, the third cell
>> +  contains a mask to be ANDed with the existing register value, and
>> +  the fourth cell is ORed with he result to yield the new register
>> +  value.
> ... a mask value of '0' should also guarantee that the driver does not do a read before the write.

The implementation does that, I will update the binding text to reflect 
this.

> What have we got so far in this regard for other phys and devices?

http://devicetree.org/Compatible%3Dmarvell,88e1149r

This is basically the same thing adapted for the page select register 
specific to Marvell PHYs.

>    I
> don't think it necessary to put 'c45' in the property name.  reg-init
> should be sufficient.

10M/100M/1G PHYs from different manufacturers and even within a single 
manufacturer have a wide variety of ways to multiplex many registers 
into the 5 bit addressing scheme allowed by clause 22.  The Marvell 
scheme already implemented doesn't work for Broadcom.

For clause 45, there are more address bits...

>    I'd like to hear from others if it would be
> valuable to have a 'reg-init-sequence' property of the above format.

A clause 45 specific property might work for *all* 10G PHYs, the same 
cannot be said for clause 22, hence my idea to put 'c45' in the name

> What does the device type cell indicate?  Wouldn't the driver
> naturally have the device id from the address of the cell?
>

There are three portions to a clause 45 address:

phy_id:  Denoted by the "reg" property is a 5-bit value that identifies 
a particular PHY on the MDIO bus.

device id: Really a sub-device within a given PHY, another 5-bit value 
contained in the first cell of the proposed register init sequence.  
Clause 45 defines several different standard device ids.

register id: a 16-bit address that identifies a particular 16-bit 
register within the 'device' (or sub-device if you will.

Does that answer your question?

In theory we could compose the 5-bit device id and 16-bit register 
address into a single 32-bit cell in the init sequence property, but I 
chose to have them separate.

>> +static int __init bcm8706_init(void)
>> +{
>> +	int ret;
>> +
>> +	ret = phy_driver_register(&bcm8706_driver);
>> +
>> +	return ret;
>> +}
>> +module_init(bcm8706_init);
> or simply:
> static int __init bcm8706_init(void)
> {
> 	return phy_driver_register(&bcm8706_driver);
> }
> module_init(bcm8706_init);
>

Yes, I will make that change.

David Daney
