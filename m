From: Wolfgang Grandegger <wg@grandegger.com>
Subject: alchemy/gpr: au1000_eth regression with v2.6.37rc2
Date: Thu, 18 Nov 2010 20:59:15 +0100
Message-ID: <4CE58593.50509@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: Linux-MIPS <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I just realized that the v2.6.37-rc2 kernel does not boot any more on
the Alchemy GPR board. It works fine with v2.6.36. It hangs in the
probe function of the au1000_eth driver when probing the second
ethernet port (eth1):

  au1000_eth_mii: probed
  au1000-eth au1000-eth.0: (unregistered net_device): attached PHY driver [Generic PHY] (mii_bus:phy_addr=0:00, irq=-1)
  au1000-eth au1000-eth.0: eth0: Au1xx0 Ethernet found at 0x10500000, irq 35
  au1000_eth: au1000_eth version 1.7 Pete Popov <ppopov@embeddedalley.com>
  ... hangs ...

Similar messages should follow for eth1. I narrowed down (bisect'ed) the
problem to commit:

  commit d0e7cb5d401695809ba8c980124ab1d8c66efc8b
  Author: Florian Fainelli <florian@openwrt.org>
  Date:   Wed Sep 8 11:15:13 2010 +0000

    au1000-eth: remove volatiles, switch to I/O accessors
    
    Remove all the volatile keywords where they were used, switch to using the
    proper readl/writel accessors.
    
    Signed-off-by: Florian Fainelli <florian@openwrt.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

The kernel actually hangs when accessing "&aup->mac->mii_control" in
au1000_mdio_read(), but only for eth1. Any idea what does go wrong?

In principle, I do not want to access the MII regs of the MAC because
eth0 and eth1 are connected to switches. But that's not possible, even
with "aup->phy_static_config=1" and "aup->phy_addr=0".

TIA,

Wolfgang.

