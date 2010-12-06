From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Behaviour of ETHTOOL_GLINK for an interface that's down
Date: Mon, 06 Dec 2010 21:59:46 +0000
Message-ID: <1291672786.5405.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sf-linux-drivers <linux-net-drivers@solarflare.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:24332 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325Ab0LFV7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 16:59:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ETHTOOL_GLINK is yet another ethtool operation that has unclear
semantics that results in differing behaviour when the interface is
down.

The two reasonable semantics I can see are:
1. Report whether the host has a working link, i.e. netif_running() &&
netif_carrier_on().
2. Report whether the port has a working link.  For hardware interfaces,
poll the PHY or firmware unless the port is powered-off.  For software
interfaces, report whether the interface could plausibly pass traffic.

The default implementation (ethtool_op_get_link) uses
netif_carrier_ok(), implementing the rather unreasonable semantics:
3. Report whether the port had a working link when the interface was
last up.

At least one driver works around this by setting carrier off in its
ndo_stop() operation.

Here's a small sample of driver behaviours:

bnx2: (1)
bnx2x: (1) (I think)
cxgb3: (1) (but also (2) because PHY is powered off)
e1000e: (2)
gianfar: (3)
igb: (2)
ixgbe: (1)
niu: (3)
sfc: (3) (approximately)
sky2: (3)
tg3: (3) (but also (1) due to setting carrier off in tg3_close())

DaveM said that Network Manager may require (2), although I don't think
this is correct.  At least the current version brings all managed
interfaces up whether or not they have link-up already.

My personal preference is for (1).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

