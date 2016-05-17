From: David Mosberger <davidm@egauge.net>
Subject: Re: [PATCH] net: phy: Ensure the state machine is called when phy is UP
Date: Tue, 17 May 2016 17:35:30 -0600
Message-ID: <CALnQHM0WbaPra2qV0ZoiS=CRy726OK+U=iBBPCFkh_4Lxs_z5A@mail.gmail.com>
References: <CALnQHM0edN=40GHHwRrOMkQEMsHk2haRoj21bwD2ySfYoLGVvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	David Mosberger <davidm@egauge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:33605 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416AbcEQXfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 19:35:31 -0400
Received: by mail-io0-f175.google.com with SMTP id f89so44294981ioi.0
        for <netdev@vger.kernel.org>; Tue, 17 May 2016 16:35:31 -0700 (PDT)
In-Reply-To: <CALnQHM0edN=40GHHwRrOMkQEMsHk2haRoj21bwD2ySfYoLGVvA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Resending with mailing list address corrected.  Sorry about that.]

I believe I'm seeing the same issue as in this thread:

  http://www.spinics.net/lists/netdev/msg373670.html

macb Ethernet driver and after upgrading from 4.4.0 to 4.60, the
Ethernet interface would not initialize unless I force autonegation
(e.g., with mii-diag -r).  It looks to me the code may always have
been broken, but since this check for PHY_POLL was introduced to
phy_state_machine():

/* Only re-schedule a PHY state machine change if we are polling the
* PHY, if PHY_IGNORE_INTERRUPT is set, then we will be moving
* between states from phy_mac_interrupt()
*/
if (phydev->irq == PHY_POLL)
        queue_delayed_work(system_power_efficient_wq, &phydev->state_queue,
  PHY_STATE_TIME * HZ);

The bug no longer gets papered over with.  The sequence of events I'm seeing:

[    0.810000] macb f8008000.ethernet: invalid hw address, using random
[    0.820000] libphy: MACB_mii_bus: probed
[    0.900000] kszphy_config_intr: mask 200 MII_KSZPHY_INTCS 0
[    0.900000] kszphy_ack_interrupt: rc 0
[    0.900000] kszphy_config_intr: mask 200 MII_KSZPHY_INTCS 500
[    0.910000] Micrel KSZ8081 or KSZ8091 f8008000.etherne:01: attached
PHY driver [Micrel KSZ8081 or KSZ8091]
(mii_bus:phy_addr=f8008000.etherne:01, irq=117)
[    0.930000] macb f8008000.ethernet eth0: Cadence GEM rev 0x00020203
at 0xf8008000 irq 27 (ca:83:b2:75:81:e2)
[    0.940000] kszphy_config_intr: mask 200 MII_KSZPHY_INTCS 0
[    0.940000] kszphy_ack_interrupt: rc 0
[    0.950000] kszphy_config_intr: mask 200 MII_KSZPHY_INTCS 500
[    0.950000] libphy: phy_state_machine: state 2
 :
[    3.060000] kszphy_config_intr: mask 200 MII_KSZPHY_INTCS 0
[    3.060000] kszphy_ack_interrupt: rc 1
[    3.070000] kszphy_config_intr: mask 200 MII_KSZPHY_INTCS 500
[    3.070000] libphy: phy_state_machine: state 2
 :
[    7.960000] macb: macb_open: calling phy_start()
[    7.970000] libphy: phy_start: old state 2
[    7.970000] libphy: phy_start: new state 4

So if I understand this right, at 3.06 seconds, a LINKUP interrupt
gets reported, but since the phy is in state PHY_READY, the interrupt
gets ignored.

At 7.96 seconds, phy_start() gets called, but even though this enters
state PHY_UP, it does not trigger phy_state_machine() and therefore
doesn't trigger autonegotiation.  I'm not quite sure how this is
intended to be handled properly.  I believe Alexandre Belloni's patch
would do the trick:

 http://www.spinics.net/lists/netdev/msg373324.html

Or has this been fixed in some other way already?

  --david
-- 
Love Linux kernel hacking?  Know Python?  We are hiring!  Contact us
at jobs@egauge.net
