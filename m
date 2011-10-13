From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next] bonding: fix wrong port enabling in 802.3ad
Date: Thu, 13 Oct 2011 10:46:31 -0700
Message-ID: <18216.1318527991@death>
References: <1318526483-16073-1-git-send-email-fbl@redhat.com>
Cc: netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:55208 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756696Ab1JMRr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Oct 2011 13:47:57 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p9DHWTlD004530
	for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 13:32:29 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9DHkYBa140588
	for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 13:46:34 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9DHkXVx001195
	for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 14:46:34 -0300
In-reply-to: <1318526483-16073-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flavio Leitner <fbl@redhat.com> wrote:

>The port shouldn't be enabled unless its current MUX
>state is DISTRIBUTING which is correctly handled by
>ad_mux_machine(), otherwise the packet sent can be
>lost because the other end may not be ready.
>
>The issue happens on every port initialization, but
>as the ports are expected to move quickly to DISTRIBUTING,
>it doesn't cause much problem.  However, it does cause
>constant packet loss if the other peer has the port
>configured to stay in STANDBY (i.e. SYNC set to OFF).

	This may explain another misbehavior I've been looking into: if
the bond's outgoing LACPDUs are lost (never received by the switch), but
the switch's incoming LACPDUs are received, bonding puts the port into
use, and packets to the switch are dropped by the switch.

>Signed-off-by: Flavio Leitner <fbl@redhat.com>
>---
>
>The comments there suggests it was a workaround for losses
>of link events, but I couldn't track the changelog as it
>seems to be pretty old.  Thus, as all the link notification
>stuff has been improved a lot, maybe this is not an issue
>anymore.  At least, I didn't find any problem while
>unplugging/plugging cables here.

	I believe this code fragment is original to the 802.3ad
submission, which would have been around 2003 or so.

	Did you check the standard for what it says should happen in
this case?  I'm guessing this is something not specified by the
standard, given the comment, but we should check to make sure.

	-J

> drivers/net/bonding/bond_3ad.c |    7 -------
> 1 files changed, 0 insertions(+), 7 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index 47b928e..b33c099 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -1135,13 +1135,6 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
> 			__record_pdu(lacpdu, port);
> 			port->sm_rx_timer_counter = __ad_timer_to_ticks(AD_CURRENT_WHILE_TIMER, (u16)(port->actor_oper_port_state & AD_STATE_LACP_TIMEOUT));
> 			port->actor_oper_port_state &= ~AD_STATE_EXPIRED;
>-			// verify that if the aggregator is enabled, the port is enabled too.
>-			//(because if the link goes down for a short time, the 802.3ad will not
>-			// catch it, and the port will continue to be disabled)
>-			if (port->aggregator
>-			    && port->aggregator->is_active
>-			    && !__port_is_enabled(port))
>-				__enable_port(port);
> 			break;
> 		default:    //to silence the compiler
> 			break;
>-- 
>1.7.6
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
