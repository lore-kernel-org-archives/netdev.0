From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: only send arp monitor packets if no other traffic
Date: Wed, 16 May 2012 12:08:23 -0700
Message-ID: <21472.1337195303@death.nxdomain>
References: <4FB3F67C.6000401@genband.com>
Cc: netdev <netdev@vger.kernel.org>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:41240 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760391Ab2EPTIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 15:08:46 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 16 May 2012 13:08:45 -0600
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 18884C9006E
	for <netdev@vger.kernel.org>; Wed, 16 May 2012 15:08:40 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4GJ8euP084006
	for <netdev@vger.kernel.org>; Wed, 16 May 2012 15:08:41 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4GJ8SaV011678
	for <netdev@vger.kernel.org>; Wed, 16 May 2012 13:08:28 -0600
In-reply-to: <4FB3F67C.6000401@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen <chris.friesen@genband.com> wrote:

>In order to minimize network traffic, when using load balancing modes
>only send out arp monitor packets if it's been more than delta_in_ticks
>jiffies since we either received or transmitted packets.  The rationale
>behind this is that if there is a lot of other traffic going on we don't
>need the arp monitor packets to determine whether or not the link is
>working.
>
>This makes the most difference if you have a lot of hosts all arping
>the same target at high frequency.

	This logic would not work for the active-backup case (it would
break arp_validate, for one thing), but might be ok for the loadbalance
(balance-xor, balance-rr) case.

	This might adversely affect cases where the switch ports are not
configured into a port channel; in that case, the ARP broadcasts would
be sent to all slaves, but with this patch, will no longer be.  That's
technically not a correct configuration, but seems to be in use
nevertheless.

	I didn't think that the ARP monitor was particularly popular for
the loadbalance case, since it is not as reliable.  It depends upon the
switch to insure that some traffic comes in to each slave, and low
traffic periods can result in false detection of link failures.  Even
with the ARPs being sent out, if those are not evenly balanced by the
switch, false failure detections can occur.

	-J


>Signed-off-by: Chris Friesen <chris.friesen@genand.com>
>---
> drivers/net/bonding/bond_main.c |    8 ++++++--
> 1 files changed, 6 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index bc13b3d..4c8459a 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2885,8 +2885,12 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
> 		 * do - all replies will be rx'ed on same link causing slaves
> 		 * to be unstable during low/no traffic periods
> 		 */
>-		if (IS_UP(slave->dev))
>-			bond_arp_send_all(bond, slave);
>+		if (IS_UP(slave->dev)) {
>+			if (time_after_eq(jiffies, dev_trans_start(slave->dev) + delta_in_ticks) ||
>+			    time_after_eq(jiffies, slave->dev->last_rx + delta_in_ticks)) {
>+				bond_arp_send_all(bond, slave);
>+			}
>+		}
> 	}
>
> 	if (do_failover) {
>
>-- 
>
>Chris Friesen
>Software Designer
>3500 Carling Avenue
>Ottawa, Ontario K2H 8E9
>www.genband.com

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
