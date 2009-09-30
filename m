From: Bernhard Kaindl <bernhard.kaindl@gmx.net>
Subject: [PATCH] Regression: e100_phy_init() isolates even selected PHY, causes
 10 seconds boot delay
Date: Wed, 30 Sep 2009 22:33:31 +0200
Message-ID: <4AC3C09B.3040203@gmx.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030805010003070403080809"
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Bruce Allan <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:1962 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753678AbZI3Uda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 16:33:30 -0400
Received: by fg-out-1718.google.com with SMTP id 22so2247432fge.1
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2009 13:33:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030805010003070403080809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Dear David, Dear Bruce,

The current e100.c:e100_phy_init() electrically isolates all
the PHYs (even the selected PHY -- for a short time!) from the MII.

This happens only for a short duration before the isolation
of the selected PHY is reverted, but it's enough to cause a
major disturbance in the startup of our e100-based cards:

On a number of Embedded/Industry Pentium boards which are in use,
the result is that the initial DHCP negotiation takes more
than 10 seconds to complete with 2.6.30 and .31, while it's
done in a fraction of a second with 2.6.29 and earlier
(kernels tested with no delay range from 2.6.23 to 2.6.29)

That regression was introduced on March 31 in the by a patch
from Bruce which first appeared in 2.6.30-rc3:

http://marc.info/?l=linux-netdev&m=123766715429780&w=2
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=b55de80e49892002a1878013ab9aee1a30970be6

> From: Bruce Allan <bruce.w.allan@intel.com>
>
> This patch enables support for the new Intel 82552 adapter (new PHY paired
> with the existing MAC in the ICH7 chipset).  No new features are added to
> the driver, however there are minor changes due to updated registers and a
> few workarounds for hardware errata.

In the middle, the patch has two changes for e100_phy_init()

The first one looks like a code optimization and does not appear to matching
the criteria described by Bruce in his submission, so assume it made it into
the patch submission by accident:

> @@ -1276,16 +1294,12 @@ static int e100_phy_init(struct nic *nic)
> 	if (addr == 32)
> 		return -EAGAIN;
>
> -	/* Selected the phy and isolate the rest */
> -	for (addr = 0; addr < 32; addr++) {
> -		if (addr != nic->mii.phy_id) {
> -			mdio_write(netdev, addr, MII_BMCR, BMCR_ISOLATE);
> -		} else {
> -			bmcr = mdio_read(netdev, addr, MII_BMCR);
> -			mdio_write(netdev, addr, MII_BMCR,
> -				bmcr & ~BMCR_ISOLATE);
> -		}
> -	}
> +	/* Isolate all the PHY ids */
> +	for (addr = 0; addr < 32; addr++)
> +		mdio_write(netdev, addr, MII_BMCR, BMCR_ISOLATE);
> +	/* Select the discovered PHY */
> +	bmcr &= ~BMCR_ISOLATE;
> +	mdio_write(netdev, nic->mii.phy_id, MII_BMCR, bmcr);
>
> 	/* Get phy ID */
> 	id_lo = mdio_read(netdev, nic->mii.phy_id, MII_PHYSID1);

If this was meant as a workaround for a hardware errata, it should
have been mentioned to ensure that no one undoes the change without
knowing.

Anyway:

What this does is that it removes the 2.6.23-2.6.29 PHY isolation loop
which ensured that *ONLY* PHY addresses which *do not* match the selected
PHY address are electrically isolated:

> -	/* Selected the phy and isolate the rest */
> -	for (addr = 0; addr < 32; addr++) {
> -             if (addr != nic->mii.phy_id) {
> -                     mdio_write(netdev, addr, MII_BMCR, BMCR_ISOLATE);

The 2.6.29 loop cleared the isolate bit of the discovered PHY in the
else clause of this if statement:

> -		} else {
> -			bmcr = mdio_read(netdev, addr, MII_BMCR);
> -			mdio_write(netdev, addr, MII_BMCR,
> -				bmcr & ~BMCR_ISOLATE);
> -		}

This loop is then replaced with electrical isolation of *_ALL_* PHYs:

> +	/* Isolate all the PHY ids */
> +	for (addr = 0; addr < 32; addr++)
> +		mdio_write(netdev, addr, MII_BMCR, BMCR_ISOLATE);

Which is reverted for the discovered PHY afterwards:

> +	/* Select the discovered PHY */
> +	bmcr &= ~BMCR_ISOLATE;
> +	mdio_write(netdev, nic->mii.phy_id, MII_BMCR, bmcr);

This change resulted in a delay of the "Link Up" message from the
e100 watchdog routine and in a number of DHCP packages getting lost
for a duration of about five seconds.

I suppose that this may have powered-down our PHYs for a short moment
or at least disturbed the connection which it has with the MII and/or
the outside world.

In any case:

Reverting solely this change alone fixed the 10 second boot delay!

For more information, I attached two driver debug logs of the commands
between firmware load and "Link Up" with and without isolation of the
selected PHY.

----------------------------------------------------------------------

But indeed, there is potential for a possibly valid optimization:

The old e100_phy_init() was reading the "bmcr" variable twice.
First, when probing the PHYs are probed:

/* Discover phy addr by searching addrs in order {1,0,2,..., 31} */
for (addr = 0; addr < 32; addr++) {
	nic->mii.phy_id = (addr == 0) ? 1 : (addr == 1) ? 0 : addr;
	bmcr = mdio_read(netdev, nic->mii.phy_id, MII_BMCR);
	stat = mdio_read(netdev, nic->mii.phy_id, MII_BMSR);
	stat = mdio_read(netdev, nic->mii.phy_id, MII_BMSR);
	if (!((bmcr == 0xFFFF) || ((stat == 0) && (bmcr == 0))))
		break;
-> When the selected PHY is found, the loop aborts here, so bmcr
     has the bmcr of the selected PHY
}

and second, when the old PHY setup loop was clearing the isolate bit:

> -		} else {
> -			bmcr = mdio_read(netdev, addr, MII_BMCR);
> -			mdio_write(netdev, addr, MII_BMCR,
> -				bmcr & ~BMCR_ISOLATE);
> -		}

Reading the MII_BMCR value twice was therefore not strictly necessary,
so I think this was the optimization which Bruce had in mind, and his
other motivation may have been to simplify the PHY setup loop.

So, what should be done is to only isolate the other PHYs and just clear
the isolate bit of the selected PHY, in the simplest possible way.

The patch which we are now using with 2.6.31 to fix this regression
does the following:

* Remove the loop which isolates *ALL* PHYs and then clears of
   the isolate bit of the selected PHY.

* Keep the new code which just clears the isolate bit of the BMCR
   of the discovered PHY

* Afterwards, isolate the unused PHYs.

This essentially resembles what the 2.6.23-2.6.29 code did, only
clearing the isolate bit of the discovered PHY is explicitly done
first, while before, it was in the middle of the PHY isolation loop.

A plain revert is probably safest in case of real paranoia here.
Electrically, this should be the same what we had until 2.6.30-rc3:

Tested by me and my colleagues:

--- linux-2.6.31/drivers/net/e100.c
+++ linux-2.6.31/drivers/net/e100.c
@@ -1294,13 +1294,15 @@ static int e100_phy_init(struct nic *nic
   	if (addr == 32)
   		return -EAGAIN;

-	/* Isolate all the PHY ids */
-	for (addr = 0; addr < 32; addr++)
-		mdio_write(netdev, addr, MII_BMCR, BMCR_ISOLATE);
   	/* Select the discovered PHY */
   	bmcr &= ~BMCR_ISOLATE;
   	mdio_write(netdev, nic->mii.phy_id, MII_BMCR, bmcr);

+	/* Electrically isolate only the unused PHYs */
+	for (addr = 0; addr < 32; addr++)
+		if (addr != nic->mii.phy_id)
+			mdio_write(netdev, addr, MII_BMCR, BMCR_ISOLATE);
+
   	/* Get phy ID */
   	id_lo = mdio_read(netdev, nic->mii.phy_id, MII_PHYSID1);
   	id_hi = mdio_read(netdev, nic->mii.phy_id, MII_PHYSID2);

Signed-off-by: Bernhard Kaindl <bernhard.kaindl@gmx.net>

Best Regards,
Bernhard Kaindl

--------------030805010003070403080809
Content-Type: text/plain;
 name="e100_phy_init_without_isolation.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="e100_phy_init_without_isolation.txt"

Without the optimzation which isolates the PHY, the link goes up within a 1/10th of
a second after starting to load the firmware:

 7.588075 e100 0000:00:09.0 firmware: using built-in firmware e100/d101s_ucode.bin
 7.604133 e100_configure: [00-07]=16:08:00:01:00:00:26:07
 7.608117 e100_configure: [08-15]=01:00:2E:00:60:00:F2:48
 7.608117 e100_configure: [16-23]=00:40:FA:86:3F:05:00:00
 7.610785 e100_set_multicast_list: mc_count=0, flags=0x1002
 7.615390 e100_configure: [00-07]=16:08:00:01:00:00:26:07
 7.619380 e100_configure: [08-15]=01:00:2E:00:60:00:F2:48
 7.619380 e100_configure: [16-23]=00:40:FA:86:3F:05:00:00
 7.619380 e100_intr: stat_ack = 0x20
 7.622719 e100_watchdog: right now = -74502
 7.627045 mdio_ctrl: READ:addr=1, reg=4, data_in=0x0000, data_out=0x182405E1
 7.630994 mdio_ctrl: READ:addr=1, reg=0, data_in=0x0000, data_out=0x18203000
 7.634011 mdio_ctrl: READ:addr=1, reg=5, data_in=0x0000, data_out=0x182541E1
 7.639498 mdio_ctrl: READ:addr=1, reg=1, data_in=0x0000, data_out=0x1821782D
 7.643447 mdio_ctrl: READ:addr=1, reg=1, data_in=0x0000, data_out=0x1821782D
 7.646419 NIC Link is Up 100 Mbps Full Duplex


--------------030805010003070403080809
Content-Type: text/plain;
 name="e100_phy_init_with_isolation.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="e100_phy_init_with_isolation.txt"

With the isolation of the PHY, 'link up' takes more than 2 seconds:

 8.241194 e100 0000:00:09.0 firmware: using built-in firmware e100/d101s_ucode.bin
 8.259478 e100_configure: [00-07]=16:08:00:01:00:00:26:07
 8.263462 e100_configure: [08-15]=01:00:2E:00:60:00:F2:48
 8.263462 e100_configure: [16-23]=00:40:FA:86:3F:05:00:00
 8.266134 e100_set_multicast_list: mc_count=0, flags=0x1002
 8.270737 e100_configure: [00-07]=16:08:00:01:00:00:26:07
 8.274727 e100_configure: [08-15]=01:00:2E:00:60:00:F2:48
 8.274727 e100_configure: [16-23]=00:40:FA:86:3F:05:00:00
 8.274727 e100_intr: stat_ack = 0x20
 8.278066 e100_watchdog: right now = -74619
 8.282389 mdio_ctrl: READ:addr=1, reg=4, data_in=0x0000, data_out=0x182405E1
 8.286339 mdio_ctrl: READ:addr=1, reg=0, data_in=0x0000, data_out=0x18203000
 8.289356 mdio_ctrl: READ:addr=1, reg=5, data_in=0x0000, data_out=0x182501E1
 8.294842 mdio_ctrl: READ:addr=1, reg=1, data_in=0x0000, data_out=0x18217809
 8.298791 mdio_ctrl: READ:addr=1, reg=1, data_in=0x0000, data_out=0x18217809
 8.301810 mdio_ctrl: READ:addr=1, reg=1, data_in=0x0000, data_out=0x18217809
 8.307293 mdio_ctrl: READ:addr=1, reg=1, data_in=0x0000, data_out=0x18217809
 8.311244 mdio_ctrl: READ:addr=1, reg=1, data_in=0x0000, data_out=0x18217809
 8.314260 mdio_ctrl: READ:addr=1, reg=1, data_in=0x0000, data_out=0x18217809
 8.318211 e100_rx_indicate: status=0x0000
 8.322954 e100_tx_clean: cb[0]->status = 0xA000
 8.326946 e100_tx_clean: cb[1]->status = 0xA000
 8.329309 e100_tx_clean: cb[2]->status = 0xA000
 8.334034 e100_tx_clean: cb[3]->status = 0xA000
 8.338028 e100_tx_clean: cb[4]->status = 0xA000
...
 8.355248 e100_configure: [00-07]=16:08:00:01:00:00:26:07
 8.359238 e100_configure: [08-15]=01:00:2E:00:60:00:F2:48
 8.359238 e100_configure: [16-23]=00:40:FA:86:3F:05:00:00
 8.359238 e100_intr: stat_ack = 0x20
 8.362559 e100_rx_indicate: status=0x0000
 8.366550 e100_tx_clean: cb[5]->status = 0xA000
 8.369792 e100_tx_clean: cb[6]->status = 0xA000
 8.374548 e100_set_multicast_list: mc_count=1, flags=0x1003
 8.379152 e100_configure: [00-07]=16:08:00:01:00:00:26:07
 8.383143 e100_configure: [08-15]=01:00:2E:00:60:00:F2:48
 8.383143 e100_configure: [16-23]=00:40:FA:86:3F:05:00:00
 8.383143 e100_intr: stat_ack = 0x20
 8.386435 e100_rx_indicate: status=0x0000
 8.390425 e100_tx_clean: cb[7]->status = 0xA000
 8.393667 e100_tx_clean: cb[8]->status = 0xA000
 8.398399 e100_intr: stat_ack = 0x20
 8.403041 e100_rx_indicate: status=0x0000
 8.407033 e100_set_multicast_list: mc_count=1, flags=0x1003
 8.410971 e100_configure: [00-07]=16:08:00:01:00:00:26:07
 8.414961 e100_configure: [08-15]=01:00:2E:00:60:00:F2:48
 8.414961 e100_configure: [16-23]=00:40:FA:86:3F:05:00:00
 8.414961 e100_intr: stat_ack = 0x20
 8.418260 e100_rx_indicate: status=0x0000
 8.422249 e100_tx_clean: cb[9]->status = 0xA000
 8.425492 e100_tx_clean: cb[10]->status = 0xA000
 8.430746 e100_intr: stat_ack = 0x20
 8.435388 e100_rx_indicate: status=0x0000
10.567601 e100_watchdog: right now = -74046
10.571931 mdio_ctrl: READ:addr=1, reg=4, data_in=0x0000, data_out=0x182405E1
10.577416 mdio_ctrl: READ:addr=1, reg=0, data_in=0x0000, data_out=0x18203000
10.582911 mdio_ctrl: READ:addr=1, reg=5, data_in=0x0000, data_out=0x182541E1
10.586862 mdio_ctrl: READ:addr=1, reg=1, data_in=0x0000, data_out=0x18217829
10.589877 mdio_ctrl: READ:addr=1, reg=1, data_in=0x0000, data_out=0x1821782D
10.595317 NIC Link is Up 100 Mbps Full Duplex


--------------030805010003070403080809--
