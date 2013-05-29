From: "renner@efe-gmbh.de" <renner@efe-gmbh.de>
Subject: [PATCH v2] net: ethernet: xilinx_emaclite: set protocol selector
 bits when writing ANAR
Date: Thu, 30 May 2013 00:36:18 +0200 (CEST)
Message-ID: <1382011039.590745.1369866978593.open-xchange@email.1und1.de>
Reply-To: "renner@efe-gmbh.de" <renner@efe-gmbh.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Michal Simek <monstr@monstr.eu>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:58894 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754316Ab3E2WgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 18:36:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch sets the protocol selector bits (4:0) of the PHY's MII_ADVERTISE
register (ANAR) when writing ADVERTISE_ALL. The protocol selector bits are
indicating IEEE 803.3u support and are fixed / read-only on some PHYs. Not
setting them correctly on others (like TI DP83630) makes the PHY fall back
to 10M HDX mode which should be avoided.

Tested for TI DP83630 PHY on Microblaze platform.

Signed-off-by: Jens Renner <renner@efe-gmbh.de>
---
Changes in v2:
- set ADVERTISE_ALL and protocol selector ADVERTISE_CSMA while all other
  bits will be cleared
- adapted patch title & description (original title: "net: ethernet:
  xilinx_emaclite: keep protocol selector bits by reading ANAR")

>>> David Laight <David.Laight@ACULAB.COM> hat am 28. Mai 2013 um 18:22
>>> geschrieben:
[...]
>>> Given the comment shouldn't this be removing some bits?
>>>
>>> It is a long time since I read the definitions of the ANAR (etc).
>>> But I remember it having at least 5 bits defined for 10M and 100M
>>> operation (including 100T4), so the reference to keeping bits (4:0)
>>> seems confusing.
>>>
>>>    David
>>>
>>
>> David, thanks for your feedback!
>> The bits I mentioned (the 5 least bits in ANAR) are the so-called protocol
>> selection bits (at least that's what they call it at Intel, TI, Marvell,
>> Maxim,
>> etc.). The only value that seems actually to be used is 1 (0b00001) which
>> means
>> 802.3 / fast ethernet capability (maybe 0 for slower devices?). 1 is the
>> default value for all the 10/100(/1000) PHYs I know of, in some PHYs it is
>> even
>> hardcoded (i.e. read-only). It must not be confused with ANAR bits 9:5 where
>> the actual speed and duplex mode can be selected.
>> ADVERTISE_ALL as defined in mii.h lacks this bit, in contrast to
>> ADVERTISE_FULL
>> where it is set through ADVERTISE_CSMA. Whether this is correct or not; at
>> least it makes some sense to me to read what's actually written in these
>> register bits and not to clear them. Otherwise some PHYs might fall back to
>> 10-half as seen for the TI DP83640 which has been used to test this patch.
>> I hope this explains the reason for this patch.
>
[...]
> However if you want to advertise 10M/100M HDX and FDX you need to unset
> the other speed bits (100T4 was assigned a bit, and I'm sure there were
> extra bits reserved for higher speeds - which also need clearing).
> Given that the ANAR is defined by 803.x you shouldn't really have a problem!
[...]
You are right. The 1000BASE-T capability is advertised in another register and
already gets cleared one code line before (see original list mail), while the
100BASE-T4 bit now remains unchanged with my patch which is not intended.

drivers/net/ethernet/xilinx/xilinx_emaclite.c   |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 919b983..b7268b3 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -946,7 +946,8 @@ static int xemaclite_open(struct net_device *dev)
                phy_write(lp->phy_dev, MII_CTRL1000, 0);

                /* Advertise only 10 and 100mbps full/half duplex speeds */
-               phy_write(lp->phy_dev, MII_ADVERTISE, ADVERTISE_ALL);
+               phy_write(lp->phy_dev, MII_ADVERTISE, ADVERTISE_ALL |
+                         ADVERTISE_CSMA);

                /* Restart auto negotiation */
                bmcr = phy_read(lp->phy_dev, MII_BMCR);
