From: Grant Grundler <iod00d@hp.com>
Subject: Re: [PATCH] tg3: Fix link failure in 5701
Date: Thu, 9 Jun 2005 16:28:30 -0700
Message-ID: <20050609232830.GC12434@esmail.cup.hp.com>
References: <1118086942.5008.14.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, iod00d@hp.com, peterc@gelato.unsw.edu.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1118086942.5008.14.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2005 at 12:42:22PM -0700, Michael Chan wrote:
> On some 5701 devices with older bootcode, the LED configuration bits in
> SRAM may be invalid with value zero. The fix is to check for invalid
> bits (0) and default to PHY 1 mode. Incorrect LED mode will lead to
> error in programming the PHY.

Michael, David,
I confirmed this patch in fact fixes the problem on currently
shipping rx7620 and rx8620 "Core LAN" cards. I expected it would
but now have nice warm fuzzies that it really 100% does.

One minor issue: I unloaded the unpatched tg3 v3.29 driver and
then did not get a link when loaded the patched tg3 v3.30 driver.
Unplugging and replugging the cable made this work.
v3.30 continued to work fine after a reboot.


lspci for the offending rx8620 NIC is:
[root@n2 net]# lspci -vs 00:01.0
00:01.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5701 Gigabit Ethe
rnet (rev 15)
	Subsystem: Hewlett-Packard Company HP IOX Core Lan 1000Base-T [A7109AX]
	Flags: 66Mhz, medium devsel, IRQ 50
	Memory at 00000f0100000000 (64-bit, non-prefetchable) [size=64K]
	Capabilities: [40] PCI-X non-bridge device.
	Capabilities: [48] Power Management version 2
	Capabilities: [50] Vital Product Data
	Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable

(aka Subsystem 103c:12c1.)

rx7620 Core LAN has Subsystem Device ID 0x1300 and is also expected
to have this problem. (I've just now submitted an entry to pciids.sf.net)

I'm told another "Core LAN" NIC from an older platform (rx5670)
_may_ also have bad "boot code".  But I don't have any to test with
and don't know what the SubSys DevID is.

BTW, I am still pushing for a recipe to update the bootcode.
This is just painfully slow. Not surprising given the number
of organizations involved.

hth,
grant

> 
> Thanks to Grant Grundler for debugging the problem.
> 
> >From Grant:
> | In May, 2004,  tg3 v3.4 changed how MAC_LED_CTRL (0x40c) was getting
> | programmed and how to determine what to program into LED_CTRL. The new
> | code trusted NIC_SRAM_DATA_CFG (0x00000b58) to indicate what to write
> | to LED_CTRL and MII EXT_CTRL registers. On "IOX Core Lan", SRAM was
> | saying MODE_MAC (0x0) and that doesn't work.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> diff -Nru led1/drivers/net/tg3.c led2/drivers/net/tg3.c
> --- led1/drivers/net/tg3.c	2005-06-06 10:19:56.692541944 -0700
> +++ led2/drivers/net/tg3.c	2005-06-06 10:34:49.251852304 -0700
> @@ -8555,6 +8555,16 @@
>  
>  		case NIC_SRAM_DATA_CFG_LED_MODE_MAC:
>  			tp->led_ctrl = LED_CTRL_MODE_MAC;
> +
> +			/* Default to PHY_1_MODE if 0 (MAC_MODE) is
> +			 * read on some older 5700/5701 bootcode.
> +			 */
> +			if (GET_ASIC_REV(tp->pci_chip_rev_id) ==
> +			    ASIC_REV_5700 ||
> +			    GET_ASIC_REV(tp->pci_chip_rev_id) ==
> +			    ASIC_REV_5701)
> +				tp->led_ctrl = LED_CTRL_MODE_PHY_1;
> +
>  			break;
>  
>  		case SHASTA_EXT_LED_SHARED:
> 
> 
> 
