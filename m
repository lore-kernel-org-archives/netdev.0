From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 1/3] bonding: allow previous slave to be used when re-balancing traffic on tlb/alb interfaces
Date: Fri, 02 Oct 2009 18:13:57 -0700
Message-ID: <8075.1254532437@death.nxdomain.ibm.com>
References: <1254269731-7341-1-git-send-email-fubar@us.ibm.com> <1254269731-7341-2-git-send-email-fubar@us.ibm.com>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:51529 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756063AbZJCBOA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2009 21:14:00 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9314jfX021445
	for <netdev@vger.kernel.org>; Fri, 2 Oct 2009 21:04:45 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n931E4b8244182
	for <netdev@vger.kernel.org>; Fri, 2 Oct 2009 21:14:04 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n931E40g017694
	for <netdev@vger.kernel.org>; Fri, 2 Oct 2009 21:14:04 -0400
In-reply-to: <1254269731-7341-2-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh <fubar@us.ibm.com> wrote:

>From: Andy Gospodarek <andy@greyhouse.net>
>
>When using tlb (mode 5) or alb (mode 6) bonding, a task runs every 10s
>and re-balances the output devices based on load.  I was trying to
>diagnose some connectivity issues and realized that a high-traffic host
>would often switch output interfaces every 10s.  I discovered this
>happened because the 'least loaded interface' was chosen as the next
>output interface for any given stream and quite often some lower load
>traffic would slip in an take the interface previously used by our
>stream.  This meant the 'least loaded interface' was no longer the one
>we used during the last interval.
>
>The switching of streams to another interface was not extremely helpful
>as it would force the destination host or router to update its ARP
>tables and produce some additional ARP traffic as the destination host
>verified that is was using the MAC address it expected.  Having the
>destination MAC for a given IP change every 10s seems undesirable.
>
>The decision was made to use the same slave during this interval if the
>current load on that interface was < 10.  A load of < 10 indicates that
>during the last 10s sample, roughly 100bytes were sent by all streams
>currently assigned to that interface.  This essentially means the
>interface is unloaded, but allows for a few frames that will probably
>have minimal impact to slip into the same interface we were using in the
>past.

	Andy, I've been doing some further testing with this patch, and
I'm seeing some panics that I believe are related to this patch.  It
appears that the last_slave isn't cleared (or isn't cleared soon enough)
when a slave is released, and concurrent transmit activity is getting
into alb_get_best_slave() and finding a last_slave pointer that is stale
(points to no slave currently on the slave list).

	This seems to reproduce fairly consistently when I set up alb
mode with two slaves, change the active slave so that alb mode moves the
MACs around, then release the inactive slave.  I run a concurrent "ping
-f" of some remote host.

	I added some code to tlb_clear_slave to set last_last to NULL if
save_load is 0, but the problem still happened.  I think the race is
that bond_alb_deinit_slave is called with the bond->lock released, but
the slave has already been detached in bond_release, and concurrent
transmit activity gets in and looks up last_slave.

	I'm out of time for today, so I'll look at this more on Monday
if I haven't heard back from you.

	-J

>Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>
>---
> drivers/net/bonding/bond_alb.c |   21 ++++++++++++++++++++-
> drivers/net/bonding/bond_alb.h |    4 ++++
> 2 files changed, 24 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index 9b5936f..cf2842e 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -150,6 +150,7 @@ static inline void tlb_init_table_entry(struct tlb_client_info *entry, int save_
> 		entry->load_history = 1 + entry->tx_bytes /
> 				      BOND_TLB_REBALANCE_INTERVAL;
> 		entry->tx_bytes = 0;
>+		entry->last_slave = entry->tx_slave;
> 	}
>
> 	entry->tx_slave = NULL;
>@@ -270,6 +271,24 @@ static struct slave *tlb_get_least_loaded_slave(struct bonding *bond)
> 	return least_loaded;
> }
>
>+/* Caller must hold bond lock for read and hashtbl lock */
>+static struct slave *tlb_get_best_slave(struct bonding *bond, u32 hash_index)
>+{
>+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>+	struct tlb_client_info *tx_hash_table = bond_info->tx_hashtbl;
>+	struct slave *last_slave = tx_hash_table[hash_index].last_slave;
>+	struct slave *next_slave = NULL;
>+
>+	if (last_slave && SLAVE_IS_OK(last_slave)) {
>+		/* Use the last slave listed in the tx hashtbl if:
>+		   the last slave currently is essentially unloaded. */
>+		if (SLAVE_TLB_INFO(last_slave).load < 10)
>+			next_slave = last_slave;
>+	}
>+
>+	return next_slave ? next_slave : tlb_get_least_loaded_slave(bond);
>+}
>+
> /* Caller must hold bond lock for read */
> static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u32 skb_len)
> {
>@@ -282,7 +301,7 @@ static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u3
> 	hash_table = bond_info->tx_hashtbl;
> 	assigned_slave = hash_table[hash_index].tx_slave;
> 	if (!assigned_slave) {
>-		assigned_slave = tlb_get_least_loaded_slave(bond);
>+		assigned_slave = tlb_get_best_slave(bond, hash_index);
>
> 		if (assigned_slave) {
> 			struct tlb_slave_info *slave_info =
>diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
>index 50968f8..b65fd29 100644
>--- a/drivers/net/bonding/bond_alb.h
>+++ b/drivers/net/bonding/bond_alb.h
>@@ -36,6 +36,10 @@ struct tlb_client_info {
> 				 * packets to a Client that the Hash function
> 				 * gave this entry index.
> 				 */
>+	struct slave *last_slave; /* Pointer to last slave used for transmiting
>+				 * packets to a Client that the Hash function
>+				 * gave this entry index.
>+				 */
> 	u32 tx_bytes;		/* Each Client acumulates the BytesTx that
> 				 * were tranmitted to it, and after each
> 				 * CallBack the LoadHistory is devided
>-- 
>1.6.0.2
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
