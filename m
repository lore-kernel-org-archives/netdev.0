From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-2.6 2/3] bonding: Change active slave quietly when bond is down
Date: Mon, 13 Dec 2010 12:41:44 -0800
Message-ID: <32030.1292272904@death>
References: <1292264216.9860.11.camel@bwh-desktop> <1292264396.9860.14.camel@bwh-desktop>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:38368 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754855Ab0LMUls (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Dec 2010 15:41:48 -0500
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oBDKNeQI026429
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 15:23:41 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 978534DE803E
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 15:39:44 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBDKflkR400042
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 15:41:47 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBDKfkHh009578
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 18:41:47 -0200
In-reply-to: <1292264396.9860.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> wrote:

>bond_change_active_slave() may be called when a slave is added, even
>if the bond has not been brought up yet.  It may then attempt to send
>packets, and further it may use mcast_work which is uninitialised
>before the bond is brought up.  Add the necessary checks for
>netif_running(bond->dev).

	I wondered if it would be better to instead arrange for
bond_change_active_slave (and bond_select_active_slave, which calls it)
to not be called when the bond is down, but that would require quite a
bit of change to bond_enslave and bond_open.

	-J

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


>Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
>---
> drivers/net/bonding/bond_main.c |   15 +++++++++------
> 1 files changed, 9 insertions(+), 6 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index ef370c9..3b16c34 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1178,11 +1178,13 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
> 				bond_do_fail_over_mac(bond, new_active,
> 						      old_active);
>
>-			bond->send_grat_arp = bond->params.num_grat_arp;
>-			bond_send_gratuitous_arp(bond);
>+			if (netif_running(bond->dev)) {
>+				bond->send_grat_arp = bond->params.num_grat_arp;
>+				bond_send_gratuitous_arp(bond);
>
>-			bond->send_unsol_na = bond->params.num_unsol_na;
>-			bond_send_unsolicited_na(bond);
>+				bond->send_unsol_na = bond->params.num_unsol_na;
>+				bond_send_unsolicited_na(bond);
>+			}
>
> 			write_unlock_bh(&bond->curr_slave_lock);
> 			read_unlock(&bond->lock);
>@@ -1196,8 +1198,9 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
>
> 	/* resend IGMP joins since active slave has changed or
> 	 * all were sent on curr_active_slave */
>-	if ((USES_PRIMARY(bond->params.mode) && new_active) ||
>-	    bond->params.mode == BOND_MODE_ROUNDROBIN) {
>+	if (((USES_PRIMARY(bond->params.mode) && new_active) ||
>+	     bond->params.mode == BOND_MODE_ROUNDROBIN) &&
>+	    netif_running(bond->dev)) {
> 		bond->igmp_retrans = bond->params.resend_igmp;
> 		queue_delayed_work(bond->wq, &bond->mcast_work, 0);
> 	}
>-- 
>1.7.3.2
>
>
>
>-- 
>Ben Hutchings, Senior Software Engineer, Solarflare Communications
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
