From: Hermann Lauer <Hermann.Lauer@iwr.uni-heidelberg.de>
Subject: [patch] sumgem: improve ethtool output with fibre card using the internal pcs and a serdes
Date: Thu, 4 Dec 2008 12:34:34 +0100
Message-ID: <20081204113434.GC15643@lemon.iwr.uni-heidelberg.de>
References: <20081125103029.GD12605@lemon.iwr.uni-heidelberg.de> <20081126.011809.241693537.davem@davemloft.net> <20081128000059.GA13712@lemon.iwr.uni-heidelberg.de> <20081201.233539.77173438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="b5gNqxB1S1yM7hjW"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.uni-heidelberg.de ([129.206.100.212]:58504 "EHLO
	relay.uni-heidelberg.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753845AbYLDLem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 06:34:42 -0500
Content-Disposition: inline
In-Reply-To: <20081201.233539.77173438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--b5gNqxB1S1yM7hjW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Attached is a patch which improves the output of ethtool (see below) to
some sensefull values with a sungem fibre card which uses the 
sungem interal pcs connected to a serdes chip. The seriallink case
in the driver is untouched.

Most values are hardcoded, because gigabit fibre autoneg is anyways
limited and the driver don't really support much at the moment
with that hardware.

Please consider for inclusion or comment.
Thanks,
  Hermann

patched# ethtool eth2
Settings for eth2:
        Supported ports: [ FIBRE ]
        Supported link modes:   1000baseT/Half 1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Advertised auto-negotiation: Yes
        Speed: 1000Mb/s
        Duplex: Half
        Port: FIBRE
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: off
        Supports Wake-on: d
        Wake-on: d
        Current message level: 0x00000007 (7)
        Link detected: yes

unpatched# ethtool eth2
Settings for eth2:
        Supported ports: [ ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Advertised auto-negotiation: Yes
        Speed: Unknown! (0)
        Duplex: Half
        Port: Twisted Pair
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: off
        Supports Wake-on: d
        Wake-on: d
        Current message level: 0x00000007 (7)
        Link detected: yes

-- 
Netzwerkadministration/Zentrale Dienste, Interdiziplinaeres 
Zentrum fuer wissenschaftliches Rechnen der Universitaet Heidelberg
IWR; INF 368; 69120 Heidelberg; Tel: (06221)54-8236 Fax: -5224
Email: Hermann.Lauer@iwr.uni-heidelberg.de
--b5gNqxB1S1yM7hjW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sungem-get_settings.patch"

--- linux-2.6.27.7/drivers/net/sungem.c.orig	2008-11-27 18:20:26.000000000 +0100
+++ linux-2.6.27.7/drivers/net/sungem.c	2008-12-04 08:17:28.000000000 +0100
@@ -2680,6 +2680,21 @@ static int gem_get_settings(struct net_d
 		cmd->speed = 0;
 		cmd->duplex = cmd->port = cmd->phy_address =
 			cmd->transceiver = cmd->autoneg = 0;
+
+		/* serdes means usually a Fibre connector, with most fixed */
+		if (gp->phy_type == phy_serdes) {
+			cmd->port = PORT_FIBRE;
+			cmd->supported = (SUPPORTED_1000baseT_Half |
+				SUPPORTED_1000baseT_Full |
+				SUPPORTED_FIBRE | SUPPORTED_Autoneg |
+				SUPPORTED_Pause | SUPPORTED_Asym_Pause);
+			cmd->advertising = cmd->supported;
+			cmd->transceiver = XCVR_INTERNAL;
+			if (gp->lstate == link_up)
+				cmd->speed = SPEED_1000;
+			cmd->duplex = DUPLEX_FULL;
+			cmd->autoneg = 1;
+		}
 	}
 	cmd->maxtxpkt = cmd->maxrxpkt = 0;
 
Signed-off-by: Hermann.Lauer@iwr.uni-heidelberg.de

--b5gNqxB1S1yM7hjW--
