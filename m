From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [BUG] tg3 v3.26 patch and "FIBRE" partno(A7109-6)
Date: Thu, 18 Aug 2005 01:22:20 -0700
Message-ID: <B1508D50A0692F42B217C22C02D84972067F090F@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Grant Grundler" <iod00d@hp.com>, davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Grant Grundler wrote:

> Dave, Michael,
> I was looking at a new problem Matthew Wilcox reported:
> 	tg3 networking failed on rx8620 IOX Core LAN
> 
> He was testing 2.6.13-rc6 on an HP rx8620 (ia64).
> The NIC gets no link when "ifconfig up" and ethtool says:
>         Supported ports: [ FIBRE ]
> 
> when it should say "[ MII ]".
> 
> I worked backwards and found v3.25 is the last version that
> ethtool reports "MII" and gets a link at 100BT (FDx and HDx).

I stared at the old and new tg3 code for a while and I think
I know what's going on in your case.

The boot code must be incorrectly reporting serdes in
NIC_SRAM_DATA_CFG. With older tg3, it always reads the PHY
ID if ASF is not enabled and if the PHY ID is valid, it will
ignore the serdes bit in NIC_SRAM_DATA_CFG and determine
whether it's copper/serdes based on the PHY ID.

In the new tg3, because the code is slightly different with
the new tg3_get_eeprom_hw_cfg(), it will always set the
TG3_FLG2_PHY_SERDES flag if the serdes bit in
NIC_SRAM_DATA_CFG is set.

So the problem is caused by wrong eeprom serdes configuration
and a slight change in the driver code. The old driver works
because the PHY ID overrides it. The new driver trusts the
eeprom's serdes configuration bit.

I will look at the code some more tomorrow to see if there
is an easy way to fix it in the new tg3.

Thanks.
