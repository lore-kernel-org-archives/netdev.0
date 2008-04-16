From: "M B" <super.firetwister@googlemail.com>
Subject: Phy read timeout in ibm_new_emac driver
Date: Wed, 16 Apr 2008 12:49:46 +0200
Message-ID: <6a6049b80804160349q42120b4bs1c0db49ea5ad055d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ppc-dev <linuxppc-dev@ozlabs.org>,
	"Benjamin Herrenschmidt" <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:12663 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210AbYDPKtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 06:49:47 -0400
Received: by an-out-0708.google.com with SMTP id d31so655188and.103
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2008 03:49:46 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The __emac_mdio_read function of the emac driver (core.c) will retry
100 times and wait 99us (until the last call of emac_phy_done). I
assume this is an off by one error.

	/* Wait for read to complete */
	n = 100;
	while (!emac_phy_done(dev, (r = in_be32(&p->stacr)))) {
		udelay(1);
		if (!--n) {
			DBG2(dev, " -> timeout wait complete\n");
			goto bail;
		}
	}

My Micrel/Kendin KSZ8721BT on my ppc405EP board needs one us longer to
finish. I was able to reproduce this all the time. So I wonder if the
timeout of 100us is defined by the MII standard, or by the author of
the driver?
If it's a standard I've still a bad feeling if we just correct the
timeout to 100us, maybe 110 should be fine. If it's not defined by the
standard, I would add 50% to the timeout. It won't slow down other
phys, but a scan on the phy bus might get slowed down.
Same applies for __emac_mdio_write.

Oh and we could save a us by putting the udelay(1) after the if section ;-)

Regards

Markus
