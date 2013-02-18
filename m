From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net 1/3] bonding: Fix race condition between bond_enslave() and bond_3ad_update_lacp_rate()
Date: Mon, 18 Feb 2013 13:09:13 -0800
Message-ID: <21028.1361221753@death.nxdomain>
References: <1361210344-14907-1-git-send-email-nikolay@redhat.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:45538 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756022Ab3BRVJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 16:09:40 -0500
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 18 Feb 2013 16:09:37 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 4CACA38C801A
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 16:09:21 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1IL9K0S65798150
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 16:09:20 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1IL9JKV008368
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 18:09:20 -0300
In-reply-to: <1361210344-14907-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:

>port->slave can be NULL since it's being initialized in bond_enslave
>thus dereferencing a NULL pointer in bond_3ad_update_lacp_rate()
>Also fix a minor bug, which could cause a port not to have
>AD_STATE_LACP_TIMEOUT since there's no sync between
>bond_3ad_update_lacp_rate() and bond_3ad_bind_slave(), by changing
>the read_lock to a write_lock_bh in bond_3ad_update_lacp_rate().

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>---
> drivers/net/bonding/bond_3ad.c | 6 ++++--
> 1 file changed, 4 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index a030e63..1720742 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -2494,11 +2494,13 @@ void bond_3ad_update_lacp_rate(struct bonding *bond)
> 	struct port *port = NULL;
> 	int lacp_fast;
>
>-	read_lock(&bond->lock);
>+	write_lock_bh(&bond->lock);
> 	lacp_fast = bond->params.lacp_fast;
>
> 	bond_for_each_slave(bond, slave, i) {
> 		port = &(SLAVE_AD_INFO(slave).port);
>+		if (port->slave == NULL)
>+			continue;
> 		__get_state_machine_lock(port);
> 		if (lacp_fast)
> 			port->actor_oper_port_state |= AD_STATE_LACP_TIMEOUT;
>@@ -2507,5 +2509,5 @@ void bond_3ad_update_lacp_rate(struct bonding *bond)
> 		__release_state_machine_lock(port);
> 	}
>
>-	read_unlock(&bond->lock);
>+	write_unlock_bh(&bond->lock);
> }
>-- 
>1.7.11.7
>
