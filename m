From: "Gary N Spiess" <Gary.Spiess@Intermec.com>
Subject: Re: [PATCH] natsemi update 3/4 External PHY operation
Date: Mon, 07 Jun 2004 16:08:45 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406071608450571.1B7B9754@136.179.85.112>
References: <200406041455290031.0BC56C76@136.179.85.112>
 <40C33D38.1060102@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <40C33D38.1060102@colorfullife.com>
To: manfred@colorfullife.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Manfred,

> +       if (phy_id == PHY_ADDR_INTERNAL)
> +               phy_id = np->phy_addr_external;
- Your point is well taken.  That *is* confusing, but what I meant to do.  
The existing driver code was already written to reference the "current PHY" with address 1.  To select a different address to represent the current PHY would have required me to touch more lines of source.

- My external and internal PHY hardware both default to address 31.  When I want to reference the external PHY, I must change the internal address to something else.  Because I already clobbered the meaning of address '1' to mean the 'current PHY' (as described above), I also used the number for the actual address of the internal PHY.  I don't think there is a benefit to determining that '1' was not being used by an external PHY.

- The short cable fix (to the best of my knowledge) is internal PHY related.  The unmodified code didn't cause me problems when operating with an external PHY.

- The partial reset fix (again, to the best of my knowledge) is only needed when the internal PHY being used has reset, but the MAC has not.  The dspcfg != np->dspcfg test identifies an internal PHY that has been reset, and triggers the driver to do a a complete MAC/PHY reset.  When using an external PHY, the test continually causes unneeded resets.  The change to set np->dspcfg to 0 prevents it.  This was the minimal change to get the desired results.

- I have not been able to actually use the bit-banging MII interface to reference the internal PHY, regardless of which address it occupies.  That's why I've chosen the internal PHY to be if_port = PORT_TP and external to be if_port = PORT_MII.  You won't be able to use the internal PHY without also enabling the short cable and partial reset fixes.

Gary

*********** REPLY SEPARATOR  ***********

On 6/6/2004 at 5:50 PM Manfred Spraul wrote:

>Gary N Spiess wrote:
>
>>Relocate the internal phy to phy_address=1, and add find_mii() to locate
>the address of the external mii phy.
>>
>What if phy_address 1 is already in use?
>
>>         }
>> +       if (phy_id == PHY_ADDR_INTERNAL)
>> +               phy_id = np->phy_addr_external;
>> +
>
>Hmm. If the phy_id is internal then it's external.
>What do you actually try to do? If I understand the hardware correctly, 
>it supports
>- an internal PHY. Accessed through mapped registers. Used if 
>dev->if_port == PORT_TP.
>- an external MII bus. Accessed by bit banging. Used if dev->if_port == 
>PORT_MII.
>- most users of mdio_{read,write} want to access the currently selected 
>PHY, but they call mdio_read(,1,). The "if (phy_id ==INTERNAL) 
>phy_id=external" line is a hack to handle that.
>
>What about defining a PHY_ADDR_CUR (32, whatever). Everyone except the 
>probe code uses that value and mdio_read selects the correct port/phy 
>value from the dev structure. Or create a mdio_read_cur() function.
>
>> +       /* if external phy, then DSPCFG register isn't functional.
>> +          Fix the value here so the "nasty random phy-reset" code
>doesn't
>> +          think it needs to reinitialize the chip.
>> +        */
>> +       if (dev->if_port != PORT_TP)
>> +               np->dspcfg = 0;
>> +
>
>What about making the phy reset itself dependant on if->if_port? This 
>approach just asks for bugs - switch with ethtool from PORT_TP to 
>PORT_MII and suddenly short cables stop working.
>
>--
>    Manfred


 oooooooooooooooooooooooooooooooooooooooooooooooooo
 Gary Spiess (Gary.Spiess@Intermec.com)
 MobileLan Wireless Products Group, Intermec Technology Corp
 voice: 319 369-3580  fax: 319 369-3804
