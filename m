From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: call phy_scan_fixups() after PHY reset
Date: Sat, 16 Nov 2013 03:46:12 +0300
Message-ID: <5286C054.9090602@cogentembedded.com>
References: <523CEAD2.7030706@cogentembedded.com>	<5271712A.6020105@cogentembedded.com>	<52795282.20708@cogentembedded.com> <20131105.150153.251029756944194421.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, laurent.pinchart+renesas@ideasonboard.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20131105.150153.251029756944194421.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 11/05/2013 11:01 PM, David Miller wrote:

>>     David, will you ever reply to this mail?

> I really haven't had the time with my backlog, and it's been so long ago
> that I've forgotten all of the context.

    Hm, I thought I provided enough context and also that's what mail archives 
are for... :-)

> Sorry, someone will have to start the conversation up anew.

    Anyway, here's the story told anew, with all the gory details. :-)
    Many Renesas R-Car development boards use Micrel KSZ8041 as a PHY for the 
SoC Ethernet device. This PHY has bits 14-15 of the PHY control register 1 (at 
address 0x1E) selecting LED mode for 2 LED outputs: value 00 means LED0 acting 
as LINK/ACTIVITY and LED1 as SPEED, value 01 means LED0 acting as LINK and 
LED1 as ACTIVITY; these bits are subject to the PHY reset via BMCR and get 
reset to 00 -- this is IMO bad design since it makes more sense for the LED 
mode to be pin-strapped from the external switches and so not changed on every 
PHY reset.
    Now LED0 is also connected to the sideband ETH_LINK signal of the SoC 
Ethernet device which indicates the link state to the Ethernet core (so called 
feLic); strictly speaking, it's not needed by the driver as it can receive the 
link state from the PHY via phylib. On the BOCK-W board we had the Ethenet 
LEDs labelled matching the 00 value of the bits 14-15, we had no issues with 
the LED mode changing after reset but we had an issue with ETH_LINK bouncing 
off/on after each packet with which we dealt by completely ignoring this 
signal in the 'sh_eth' driver (this is possible using 'no_ether_link' driver's 
platform data field). Now, on the newer Lager/ Koelsch boards we have the 
Ethenet LEDs labelled matching the 01 value of the bits 14-15, so we should 
get the valid ETH_LINK signal (except it's inverted but we deal with this 
using 'ether_link_active_low' platform data field)... if the 'sh_eth' driver 
didn't reset the PHY each time the device is opened, which gets us back to the 
value of 00 of the PHY LED control bits and so to the issue of bouncing 
ETH_LINK signal (that unfortunately leads to an NFS timeout with NFS root) and 
the LED behavior doesn't match to the LED labels anymore.

    Now, about the ways to deal with this issue that I see.
    First I thought about using PHY platform fixup mechanism which is already 
hooked up to a PHY reset in phy_mii_ioctl() (the code is somewhat naive though 
as it doesn't wait for the reset completion before calling fixups and the 
driver's config_init() method). All I needed is calling fixups after direct 
PHY reset done via phy_write() but I didn't want to add a hook there due to 
that reset completion wait loop that was obviously necessary (this function is 
simple *inline*), so went for a simplistic local phy_scan_fixups() call (that 
function was helpfully already exported although not called by anyone except 
phylib itself) after PHY reset in the 'sh_eth' driver which you saw in my 
patch and which you didn't like; I've also coded the PHY platform fixup which 
got successfully merged via arch/arm/mach-shmobile/ subtree at that time. Your 
argument was that the driver is going against the control flow provided by 
phylib (it's not alone doing PHY reset, I should note) and so you wanted me to 
embed everything into phylib control flow. I replied that I fear the 
unexpected consequencies of doing compulsory PHY reset for every driver using 
phylib (that's how I understood your idea at least)... then, after a long 
pause, I suggested to code phy_reset() function within phylib which the 
drivers that currently do reset their PHYs could use instead of open coding 
the reset bit polling loop, etc. and which would include a hook for the 
platform fixups and PHY driver config_init() call. I'd still like to hear your 
opinion on this approach -- which is less invasive.
    What I can also do in this case is again ignore ETH_LINK signal in the 
'sh_eth' driver and stop caring about the LED functions matching to what's 
designed for the boards. This doesn't need PHY platform fixup or any change in 
phylib and Ethernet driver.
    What I also can do is stop resetting PHY in the 'sh_eth' driver (only 
getting it out of sleep for which the reset doesn't seem necessary), although 
we'd still need the PHY platform fixup for the PHY resets done via 
phy_mii_ioctl()... I'm not so much familiar with the driver to be sure it 
won't hurt (the driver is used on e.g. some SH platforms I don't get any 
access to) and I couldn't get any useful input from the driver's primary 
author -- but perhaps it's really not necessary. What do you think?

WBR, Sergei

