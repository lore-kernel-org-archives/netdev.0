From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: Re: Need help with mdiobus_register and phy
Date: Thu, 20 Oct 2016 14:55:17 +0200
Message-ID: <bff7ab7f-93e4-8d78-ac73-e97d1832d155@neratec.com>
References: <5800D214.70808@codeaurora.org> <20161014124928.GJ5822@lunn.ch>
 <5800D474.1030303@codeaurora.org> <20161014125736.GK5822@lunn.ch>
 <5800D796.1030602@codeaurora.org> <20161014131852.GM5822@lunn.ch>
 <58010E79.2030607@codeaurora.org> <20161014172514.GA23455@lunn.ch>
 <535FE9FE-0D69-4874-BBF0-F0662C2157DB@gmail.com>
 <58023F90.5070302@codeaurora.org> <20161015180219.GB6918@lunn.ch>
 <58027540.6080604@codeaurora.org>
 <7dced72e-c441-06d1-161d-3bccad34f2cd@neratec.com>
 <58053A33.4030108@codeaurora.org>
 <21038884-a76e-1647-9194-be510a2f9da4@neratec.com>
 <58061831.6080005@codeaurora.org>
 <dfff1abf-f506-bffa-8e09-edeebd753be5@neratec.com>
 <58076403.3060608@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:19655 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932345AbcJTMzV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 08:55:21 -0400
In-Reply-To: <58076403.3060608@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/19/2016 02:16 PM, Timur Tabi wrote:
> Zefir Kurtisi wrote:
>> Ok then, if you can wait some days, I'll prepare and provide you a more detailed
>> failure report to allow you testing if the issue happens with other NICs.
> 
> That sounds great.
> 

I am now able again to reproduce the issue reliably, let's see if it is helpful
enough to check if this a problem unique to our setup.

As described earlier, the HW is as follows:
(copper)--[at8031]--(SGMII)--[eTSEC/mpc85xx]

We are using OpenWRT/LEDE as SW platform, therefore I can't do the tests on the
latest kernel but provide a reference to inspect the problem. The kernel used is
4.4.21 with the relevant drivers (ath803x and gianfar_driver) being either clean
or patched with OWRT/LEDE modifications (issue happens in either case).


The process for detecting the failure is rather trivial: continuously put the
Ethernet interface down and up and try to get some data through until it fails.
The script I used to run on the device (over serial) is:
#----------------------------------------------------------
HOST=192.168.1.100
TIMEOUT=20

while true; do
	ifconfig eth0 down
	ifconfig eth0 up

        ping $HOST -c 1 -w $TIMEOUT || {
                echo "Ping failed after $TIMEOUT seconds"
                exit 1
        }
done
#----------------------------------------------------------
In my setup, it takes less than 5 minutes for the script to exit. Once running
into this state, the relevant registers read from at803x are as follows:
* copper status              (0x01): 0x796d
* fiber  status              (0x01): 0x6149
* copper phy specific status (0x11): 0xbc10
* fiber  phy specific status (0x11): 0x8100
* copper/fiber status        (0x1b): 0x020e

In essence
* the copper link is up with autonegotiation completed
  (switch/peer link indication is also up), but
* the SGMII link is down
  (bits LINK and MR_AN_COMPLETE in PHY specific status fiber cleared)
* although SGMII is synchronized (SYNC_STATUS bit in same register set)

The SGMII link does not recover from this state thereafter, the only reliable way
to get it up again I found is to do a power down/up cycle at the fiber/SGMII side,
which is what the patch I contributed does.


Now the interesting (and new for me) part is: if I remove the at803x driver from
the system and use the generic phy instead, the problem does not happen (or at
least not while running for one full day). I don't see any significant differences
between what at803x does above genphy (gpio based HW reset is not run for 8031 in
at803x_link_change_notify()). Using the genphy is not an option for us, since we
have the PHY also attached to fiber and need dedicated handling.


Hope this helps for the beginning, let me know if you need more information.


Cheers,
Zefir
