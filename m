From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 2.6.24] tg3: fix ethtool autonegotiate flags
Date: Tue, 2 Oct 2007 16:16:35 -0400
Message-ID: <20071002201634.GE9140@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: mchan@broadcom.com, davem@davemloft.net, jeff@garzik.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49389 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752950AbXJBUQo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 16:16:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I recently noticed that when calling:

# ethtool -s eth0 autoneg on

on a 5722 (though I'm sure it's not specific to that card) that
subsequent checks of the cards status looked like this:

# ethtool eth0
Settings for eth0:
        Supported ports: [ MII ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Half 1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Half 1000baseT/Full
        Advertised auto-negotiation: No        <---- This seems odd?!?
        Speed: 1000Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: g
        Wake-on: d
        Current message level: 0x000000ff (255)
        Link detected: yes

I noticed that the following commit:

commit 3600d918d870456ea8e7bb9d47f327de5c20f3d6
Author: Michael Chan <mchan@broadcom.com>
Date:   Thu Dec 7 00:21:48 2006 -0800

    [TG3]: Allow partial speed advertisement.

    Honor the advertisement bitmask from ethtool.  We used to always
    advertise the full capability when autoneg was set to on.

changed things around so that ethtool speed settings were strictly
followed.  Unfortunately ethtool doesn't seem to set ADVERTISED_Autoneg
in the advertising field (and maybe it shouldn't have to).  I'd vote
that it should be fixed there, but it should also be added here just in
case someone using ethtool ioctls in their own application gets what
they want.

Adding that flag in tg3_set_settings seemed like the most logical place
since the driver works fine on boot.  This is just an issue when
re-enabling autonegotiation, so we should probably nip it there.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 tg3.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d4ac6e9..0a414be 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8070,7 +8070,8 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	tp->link_config.autoneg = cmd->autoneg;
 	if (cmd->autoneg == AUTONEG_ENABLE) {
-		tp->link_config.advertising = cmd->advertising;
+		tp->link_config.advertising = (cmd->advertising |
+					      ADVERTISED_Autoneg);
 		tp->link_config.speed = SPEED_INVALID;
 		tp->link_config.duplex = DUPLEX_INVALID;
 	} else {
