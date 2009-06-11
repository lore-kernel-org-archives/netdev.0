From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC] Restricting MDIO reads
Date: Thu, 11 Jun 2009 17:04:07 +0100
Message-ID: <1244736247.2785.35.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:41627 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754990AbZFKQEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 12:04:09 -0400
Received: from [82.69.137.158] (helo=opal.uk.level5networks.com)
	by smarthost03.mail.zen.net.uk with esmtp (Exim 4.63)
	(envelope-from <bhutchings@solarflare.com>)
	id 1MEml8-0003Ye-HT
	for netdev@vger.kernel.org; Thu, 11 Jun 2009 16:04:10 +0000
Received: from [10.17.20.50] (achroite.uk.level5networks.com [10.17.20.50])
	by opal.uk.level5networks.com (8.12.8/8.12.8) with ESMTP id n5BG47Xx019871
	for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 17:04:09 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently most drivers[1] that support the "MII" ioctls allow all users
to read MDIO registers, while MDIO writes require CAP_NET_ADMIN.

However, some MDIO registers and register bits have read-to-clear (latc=
h
high, latch low or non-rollover) or multi-word latching semantics[2].
So reading from them may interfere with the driver or other users and
should also require CAP_NET_ADMIN.

It's not clear to me just which registers should be safe to read, and
this can vary between PHYs.   I think the correct thing to do is either
to restrict all MDIO reads or to whitelist standard-defined safe
registers.

Which applications, if any, depend on performing MDIO reads as an
unprivileged user?  Which registers do they expect to read?

Ben.

[1]
These generic implementations allow reads by all users:
    =EF=BB=BFmdio, mii, pci-skeleton, phylib

These full drivers allow reads by all users:
    3c574_cs, axnet_cs, bnx2, bnx2x, cassini, emac, natsemi, pcnet_cs,
    r8169, sis900, skge, sky2, sungem, tg3, tlan, tulip, xirc2ps_cs,
    yellowfin
(This excludes drivers that simulate MDIO reads.)

These require CAP_NET_ADMIN for reads:
    =EF=BB=BFamd8111e, atl1, atl1e, atl2, =EF=BB=BFigb, =EF=BB=BFvia-ve=
locity

[2]
At least the following register bits are defined as having read-to-clea=
r
or multi-word latching semantics:

c22: 1.2:1, 1.4
c28: 6.1, 6.4
c33: 12.12:7
c37: 6.1
c40: 10.15
c45: 1.1.2, 1.8.11:10, 1.33.12, 1.33.14, 1.36.15:0, 1.99.15:12, 2.1.2,
2.1.7, 2.33.7:0, 2.33.11:9, 3.1.2, 3.8.11:10, 3.33.15:0, 3.66.15:0,
3.67.15:0, 3.69.15:0, 3.70.15:0, 3.71.15:0, 3.72.15:0, 3.73.15:0, 4.1.2=
,
4.8.11:10, 5.1.0, 5.1.2, 5.8.11:10, 6.17.1:0, 6.24.15:0, 6.25.15:0,
6.25.16:0, 7.1.2, 7.1.4, 7.1.6, 7.33.15, 29.9.15:0, 29.10.15:0,
29.11.15:0

Any reserved bits and vendor-defined registers may also have such
semantics.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

