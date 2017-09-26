From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 3/6] net: dsa: mv88e6xxx: Fixed port netdev check for VLANs
Date: Wed, 27 Sep 2017 00:26:00 +0200
Message-ID: <1506464764-12699-4-git-send-email-andrew@lunn.ch>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:57002 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967343AbdIZW00 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 18:26:26 -0400
In-Reply-To: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having the same VLAN on multiple bridges is currently unsupported as
an offload. mv88e6xxx_port_check_hw_vlan() is used to ensure that a
VLAN is not on multiple bridges when adding a VLAN range to a port. It
loops the ports and checks to see if there are ports in a different
bridge with the same VLAN.

While walking all switch ports, the code was checking if the new port
has a netdev attached to it. If not, skip checking the port being
walked. This seems like a typ0. If the new port does not have a
netdev, how has a VLAN been added to it in the first place, requiring
this check be performed at all? More likely, we should be checking if
the port being walked has a netdev. Without it having a netdev, it
cannot have a VLAN on it, so there is no need to check further for
that particular port.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index c6678aa9b4ef..884f0507cf48 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1120,7 +1120,7 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 			if (dsa_is_dsa_port(ds, i) || dsa_is_cpu_port(ds, i))
 				continue;
 
-			if (!ds->ports[port].netdev)
+			if (!ds->ports[i].netdev)
 				continue;
 
 			if (vlan.member[i] ==
-- 
2.14.1
