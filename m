From: Andy Fleming <afleming@freescale.com>
Subject: Re: [RFC PATCH 1/4] PHY Abstraction Layer III (now with more
	splitiness)
Date: Wed, 27 Jul 2005 13:01:40 -0500
Message-ID: <21ACDE8D-755B-4F46-BD55-444C1DD75330@freescale.com>
References: <Pine.LNX.4.61.0507251134470.15537@cde-tx32-ldt113.sps.mot.com>
	<20050725210646.GA17828@electric-eye.fr.zoreil.com>
Mime-Version: 1.0 (Apple Message framework v733)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	linuxppc-embedded <linuxppc-embedded@ozlabs.org>
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
In-Reply-To: <20050725210646.GA17828@electric-eye.fr.zoreil.com>
To: Francois Romieu <romieu@fr.zoreil.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org


On Jul 25, 2005, at 16:06, Francois Romieu wrote:

[snip]
>
>> +config DAVICOM_PHY
>> +    bool "Drivers for Davicom PHYs"
>> +    depends on PHYLIB
>> +    ---help---
>> +      Currently supports dm9161e and dm9131
>>
> [snip]


Yeah, I resisted splitting the patch up for this reason.  Suffice it  
to say, you have to apply patch #2 to not break everything.   
Splitting the PHY driver code from the PHY layer is just for  
"convenience"


>> +int mdiobus_register(struct mii_bus *bus)
>> +{
>> +    int i;
>> +    int err = 0;
>> +
>> +    spin_lock_init(&bus->mdio_lock);
>> +
>> +    if (NULL == bus || NULL == bus->name ||
>> +            NULL == bus->read ||
>> +            NULL == bus->write)
>>
>
> Be spartan:
>     if (!bus || !bus->name || !bus->read || !bus->write)


I think we have to agree to disagree here.  I could be convinced, but  
I'm partial to using NULL explicitly.


>> +
>> +/* Convenience function to print out the current phy status
>> + */
>> +void phy_print_status(struct phy_device *phydev)
>> +{
>> +    pr_info("%s: Link is %s", phydev->dev.bus_id,
>> +            phydev->link ? "Up" : "Down");
>> +    if (phydev->link)
>> +        printk(" - %d/%s", phydev->speed,
>>
>
> Missing KERN_SOMETHING in the printk.


Actually, KERN_SOMETHING would muck up the line, and make it look  
like this:

phy0:0: Link is Up<3> - 1000/Full

That's why it's like that.


>> +/* A mapping of all SUPPORTED settings to speed/duplex */
>> +static struct phy_setting settings[] = {
>> +    { .speed = 10000, .duplex = DUPLEX_FULL,
>> +        .setting = SUPPORTED_10000baseT_Full,
>> +    },
>> +    { .speed = SPEED_1000, .duplex = DUPLEX_FULL,
>> +        .setting = SUPPORTED_1000baseT_Full,
>> +    },
>> +    { .speed = SPEED_1000, .duplex = DUPLEX_HALF,
>> +        .setting = SUPPORTED_1000baseT_Half,
>> +    },
>> +    { .speed = SPEED_100, .duplex = DUPLEX_FULL,
>> +        .setting = SUPPORTED_100baseT_Full,
>> +    },
>> +    { .speed = SPEED_100, .duplex = DUPLEX_HALF,
>> +        .setting = SUPPORTED_100baseT_Half,
>> +    },
>> +    { .speed = SPEED_10, .duplex = DUPLEX_FULL,
>> +        .setting = SUPPORTED_10baseT_Full,
>> +    },
>> +    { .speed = SPEED_10, .duplex = DUPLEX_HALF,
>> +        .setting = SUPPORTED_10baseT_Half,
>> +    },
>> +};
>>
>
> Would you veto some macro to initialise this array ?


Depends on the macro.  :)  I'm not keen on writing it, but I would  
support one that:

a) works
b) Isn't uglier than the current solution.  :)


>> +static inline int phy_find_setting(int speed, int duplex)
>> +{
>> +    int idx = 0;
>> +
>> +    while (idx < MAX_NUM_SETTINGS &&
>> +            (settings[idx].speed != speed ||
>> +            settings[idx].duplex != duplex))
>> +        idx++;
>>
>
> "for" loop in disguise ?


Well....  I think it falls into the gray area.  It's searching until  
it finds something, which implies "while" to me.  Really it's more of  
a while...until.  Of course, a for loop could be used, but I often  
worry about using a for loop's iterator variable outside of the  
loop.  I will change to ARRAY_SIZE, though.


>
>
>> +
>> +    return idx < MAX_NUM_SETTINGS ? idx : MAX_NUM_SETTINGS - 1;
>>
>
> Ok (dunno if "idx % MAX_NUM_SETTINGS" is more idiomatic or not).


That would be completely different.  The current code makes sure  
that, if no valid match was found, the last value in the array is  
returned.  Using % would result in the first value being returned.  I  
was defaulting to the lowest setting.


>> +int phy_start_interrupts(struct phy_device *phydev)
>> +{
>> +    int err = 0;
>> +
>> +    INIT_WORK(&phydev->phy_queue, phy_change, phydev);
>> +
>> +    if (request_irq(phydev->irq, phy_interrupt,
>> +                SA_SHIRQ,
>> +                "phy_interrupt",
>> +                phydev) < 0) {
>>
>
> Please, don't do that :o(
>
>     err = request_irq(phydev->irq, phy_interrupt, SA_SHIRQ,
>               "phy_interrupt", phydev);
>     if (err < 0)
>         ...


I did a cursory search, and didn't find any other drivers which use  
this method.  Which is the method preferred in Linux?


>> +        printk(KERN_ERR "%s: Can't get IRQ %d (PHY)\n",
>> +                phydev->bus->name,
>> +                phydev->irq);
>> +        phydev->irq = PHY_POLL;
>> +        return 0;
>>
>
> The description of the function says "Returns 0 on success".


Failing to request the IRQ does not result in failure of the  
function.  It falls back to polling, instead.

However, it can fail if phy_enable_interrupts() fails, which would  
happen if a hardware issue occurred.


>> +    /* Otherwise, we allocate the device, and initialize the
>> +     * default values */
>> +    dev = kmalloc(sizeof(*dev), GFP_KERNEL);
>> +
>> +    if (NULL == dev) {
>> +        errno = -ENOMEM;
>> +        return NULL;
>> +    }
>> +
>> +    memset(dev, 0, sizeof(*dev));
>>
>
> The kernel provides kcalloc.


I went looking for it, and found it in fs/cifs/misc.c.  I'm hesitant  
to link to a function defined in the filesystem code just to save 1  
line of code


I agree with all the other suggestions, and will implement them.
