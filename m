From: Mason <slash.tmp@free.fr>
Subject: Problem with PHY state machine when using interrupts
Date: Mon, 24 Jul 2017 13:07:47 +0200
Message-ID: <65b9f1f5-724c-cd03-1c39-59405e773efa@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:29783 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751539AbdGXLIE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Jul 2017 07:08:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

When I set the link down via 'ip link set eth0 down'
(as opposed to pulling the Ethernet cable) things don't happen as expected:

The driver's adjust_link() callback is never called, and doesn't
get a chance make some required changes. And when I set the link
up again, there is no network connectivity.

I get this problem only if I enable interrupts on my PHY.
If I use polling, things work as expected.


When I set the link down, devinet_ioctl() eventually calls
ndo_set_rx_mode() and ndo_stop()

In ndo_stop() the driver calls
phy_stop(phydev);
which disables interrupts and sets the state to HALTED.

In phy_state_machine()
the PHY_HALTED case does call the adjust_link() callback:

		if (phydev->link) {
			phydev->link = 0;
			netif_carrier_off(phydev->attached_dev);
			phy_adjust_link(phydev);
			do_suspend = true;
		}

But it's not called when I use interrupts...

Perhaps because there are no interrupts generated?
Or even if there were, they have been turned off by phy_stop?

Basically, it seems like when I use interrupts,
the phy_state_machine() is not called on link down,
which breaks the MAC driver's expectations.

Am I barking up the wrong tree?

Regards.
