From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH] natsemi update 3/4 External PHY operation
Date: Sun, 06 Jun 2004 17:50:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40C33D38.1060102@colorfullife.com>
References: <200406041455290031.0BC56C76@136.179.85.112>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Gary N Spiess <Gary.Spiess@Intermec.com>
In-Reply-To: <200406041455290031.0BC56C76@136.179.85.112>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Gary N Spiess wrote:

>Relocate the internal phy to phy_address=1, and add find_mii() to locate the address of the external mii phy.
>
What if phy_address 1 is already in use?

>         }
> +       if (phy_id == PHY_ADDR_INTERNAL)
> +               phy_id = np->phy_addr_external;
> +

Hmm. If the phy_id is internal then it's external.
What do you actually try to do? If I understand the hardware correctly, 
it supports
- an internal PHY. Accessed through mapped registers. Used if 
dev->if_port == PORT_TP.
- an external MII bus. Accessed by bit banging. Used if dev->if_port == 
PORT_MII.
- most users of mdio_{read,write} want to access the currently selected 
PHY, but they call mdio_read(,1,). The "if (phy_id ==INTERNAL) 
phy_id=external" line is a hack to handle that.

What about defining a PHY_ADDR_CUR (32, whatever). Everyone except the 
probe code uses that value and mdio_read selects the correct port/phy 
value from the dev structure. Or create a mdio_read_cur() function.

> +       /* if external phy, then DSPCFG register isn't functional.
> +          Fix the value here so the "nasty random phy-reset" code doesn't
> +          think it needs to reinitialize the chip.
> +        */
> +       if (dev->if_port != PORT_TP)
> +               np->dspcfg = 0;
> +

What about making the phy reset itself dependant on if->if_port? This 
approach just asks for bugs - switch with ethtool from PORT_TP to 
PORT_MII and suddenly short cables stop working.

--
    Manfred
