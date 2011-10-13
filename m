From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH net-next] bonding: fix wrong port enabling in 802.3ad
Date: Thu, 13 Oct 2011 14:21:23 -0300
Message-ID: <1318526483-16073-1-git-send-email-fbl@redhat.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17801 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753711Ab1JMRVt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Oct 2011 13:21:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The port shouldn't be enabled unless its current MUX
state is DISTRIBUTING which is correctly handled by
ad_mux_machine(), otherwise the packet sent can be
lost because the other end may not be ready.

The issue happens on every port initialization, but
as the ports are expected to move quickly to DISTRIBUTING,
it doesn't cause much problem.  However, it does cause
constant packet loss if the other peer has the port
configured to stay in STANDBY (i.e. SYNC set to OFF).

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---

The comments there suggests it was a workaround for losses
of link events, but I couldn't track the changelog as it
seems to be pretty old.  Thus, as all the link notification
stuff has been improved a lot, maybe this is not an issue
anymore.  At least, I didn't find any problem while
unplugging/plugging cables here.

 drivers/net/bonding/bond_3ad.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 47b928e..b33c099 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1135,13 +1135,6 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			__record_pdu(lacpdu, port);
 			port->sm_rx_timer_counter = __ad_timer_to_ticks(AD_CURRENT_WHILE_TIMER, (u16)(port->actor_oper_port_state & AD_STATE_LACP_TIMEOUT));
 			port->actor_oper_port_state &= ~AD_STATE_EXPIRED;
-			// verify that if the aggregator is enabled, the port is enabled too.
-			//(because if the link goes down for a short time, the 802.3ad will not
-			// catch it, and the port will continue to be disabled)
-			if (port->aggregator
-			    && port->aggregator->is_active
-			    && !__port_is_enabled(port))
-				__enable_port(port);
 			break;
 		default:    //to silence the compiler
 			break;
-- 
1.7.6
