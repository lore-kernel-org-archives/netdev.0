From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net 2/3] bonding: Fix initialize after use for 3ad machine state spinlock
Date: Mon, 18 Feb 2013 13:33:10 -0800
Message-ID: <21258.1361223190@death.nxdomain>
References: <1361210344-14907-1-git-send-email-nikolay@redhat.com> <1361210344-14907-2-git-send-email-nikolay@redhat.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:47634 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753857Ab3BRVdO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 16:33:14 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 18 Feb 2013 16:33:14 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 7E27D38C801D
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 16:33:12 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1ILXBMW35651770
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 16:33:11 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1ILXB7L028252
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 16:33:11 -0500
In-reply-to: <1361210344-14907-2-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:

>The 3ad machine state spinlock can be used before it is inititialized
>while doing bond_enslave() (and the port is being initialized) since
>port->slave is set before the lock is prepared, thus causing soft
>lock-ups and a multitude of other nasty bugs.

	Does this change cause the "uninitialized port" warnings in
bond_3ad_state_machine_handler and bond_3ad_rx_indication to
intermittently print during the enslavement process?  If so (and it
looks to me like it will), I think the warnings should be removed, since
after this change, port->slave being NULL isn't really an error
condition that needs a warning to the log.

>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>---
> drivers/net/bonding/bond_3ad.c | 9 ++++-----
> 1 file changed, 4 insertions(+), 5 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index 1720742..96d471e 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -389,13 +389,13 @@ static u8 __get_duplex(struct port *port)
>
> /**
>  * __initialize_port_locks - initialize a port's STATE machine spinlock
>- * @port: the port we're looking at
>+ * @port: the slave of the port we're looking at
>  *
>  */
>-static inline void __initialize_port_locks(struct port *port)
>+static inline void __initialize_port_locks(struct slave *port)
> {
> 	// make sure it isn't called twice
>-	spin_lock_init(&(SLAVE_AD_INFO(port->slave).state_machine_lock));
>+	spin_lock_init(&(SLAVE_AD_INFO(port).state_machine_lock));

	Change the name of the variable here, too, not just the type.
This is confusing.

	-J

> }
>
> //conversions
>@@ -1910,6 +1910,7 @@ int bond_3ad_bind_slave(struct slave *slave)
>
> 		ad_initialize_port(port, bond->params.lacp_fast);
>
>+		__initialize_port_locks(slave);
> 		port->slave = slave;
> 		port->actor_port_number = SLAVE_AD_INFO(slave).id;
> 		// key is determined according to the link speed, duplex and user key(which is yet not supported)
>@@ -1932,8 +1933,6 @@ int bond_3ad_bind_slave(struct slave *slave)
> 		port->next_port_in_aggregator = NULL;
>
> 		__disable_port(port);
>-		__initialize_port_locks(port);
>-
>
> 		// aggregator initialization
> 		aggregator = &(SLAVE_AD_INFO(slave).aggregator);
>-- 
>1.7.11.7
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
