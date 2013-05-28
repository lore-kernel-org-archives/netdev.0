From: "renner@efe-gmbh.de" <renner@efe-gmbh.de>
Subject: RE: [PATCH] net: ethernet: xilinx_emaclite: keep protocol selector
 bits by reading ANAR
Date: Tue, 28 May 2013 21:35:45 +0200 (CEST)
Message-ID: <635022046.487018.1369769745682.open-xchange@email.1und1.de>
References: <51A4D6FE.3080308@efe-gmbh.de> <AE90C24D6B3A694183C094C60CF0A2F6026B7251@saturn3.aculab.com>
Reply-To: "renner@efe-gmbh.de" <renner@efe-gmbh.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org, David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:60383 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753578Ab3E1Tfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 15:35:47 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7251@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> David Laight <David.Laight@ACULAB.COM> hat am 28. Mai 2013 um 18:22
> geschrieben:
>
>
> > This patch reads the PHY's MII_ADVERTISE register (ANAR) before modifying
> > it.
> > Hence, the protocol selector bits (4:0) which indicate IEEE 803.3u support
> > are
> > prevented from being cleared.
> > ...
> >                 /* Advertise only 10 and 100mbps full/half duplex speeds */
> > -               phy_write(lp->phy_dev, MII_ADVERTISE, ADVERTISE_ALL);
> > +               adv = phy_read(lp->phy_dev, MII_ADVERTISE);
> > +               if (adv < 0)
> > +                       return adv;
> > +               phy_write(lp->phy_dev, MII_ADVERTISE, adv | ADVERTISE_ALL);
>
> Given the comment shouldn't this be removing some bits?
>
> It is a long time since I read the definitions of the ANAR (etc).
> But I remember it having at least 5 bits defined for 10M and 100M
> operation (including 100T4), so the reference to keeping bits (4:0)
> seems confusing.
>
>    David
>

David, thanks for your feedback!
The bits I mentioned (the 5 least bits in ANAR) are the so-called protocol
selection bits (at least that's what they call it at Intel, TI, Marvell, Maxim,
etc.). The only value that seems actually to be used is 1 (0b00001) which means
802.3 / fast ethernet capability (maybe 0 for slower devices?). 1 is the
default value for all the 10/100(/1000) PHYs I know of, in some PHYs it is even
hardcoded (i.e. read-only). It must not be confused with ANAR bits 9:5 where
the actual speed and duplex mode can be selected.
ADVERTISE_ALL as defined in mii.h lacks this bit, in contrast to ADVERTISE_FULL
where it is set through ADVERTISE_CSMA. Whether this is correct or not; at
least it makes some sense to me to read what's actually written in these
register bits and not to clear them. Otherwise some PHYs might fall back to
10-half as seen for the TI DP83640 which has been used to test this patch.
I hope this explains the reason for this patch.

Jens.
