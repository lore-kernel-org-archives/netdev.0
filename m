From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v5 5/6] bonding: remove the counter and simplify
 bond_for_each_slave_from()
Date: Wed, 25 Sep 2013 12:10:17 +0200
Message-ID: <20130925101016.GA23575@redhat.com>
References: <5242B25F.7020505@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10849 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754790Ab3IYKMN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 06:12:13 -0400
Content-Disposition: inline
In-Reply-To: <5242B25F.7020505@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 25, 2013 at 05:52:31PM +0800, Ding Tianhong wrote:
>Restructure the bond_for_each_slave_from(),
>remove the checking for bond->slave_cnt,
>make the new loop be more simple and racy.

The whole bond_for_each_slave_from() should be removed and replaced with a
standard bond_for_each_slave() - which is already in the process:

http://patchwork.ozlabs.org/patch/277701/
http://patchwork.ozlabs.org/patch/277717/
http://patchwork.ozlabs.org/patch/277716/
http://patchwork.ozlabs.org/patch/277702/
http://patchwork.ozlabs.org/patch/277703/

After that we're ready to use the standard and less painful
list_for_each_entry() analogue - bond_for_each_slave() - which can
afterwards be easily RCUified by just replacing bond_for_each_slave() with
bond_for_each_slave_rcu().

>
>Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
>Suggested-by: Veaceslav Falico <vfalico@redhat.com>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>Cc: Nikolay Aleksandrov <nikolay@redhat.com>
>Cc: Veaceslav Falico <vfalico@redhat.com>
>---
> drivers/net/bonding/bond_alb.c  | 3 +--
> drivers/net/bonding/bond_main.c | 6 ++----
> drivers/net/bonding/bonding.h   | 6 +++---
> 3 files changed, 6 insertions(+), 9 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index f428ef57..4813dc6 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -383,7 +383,6 @@ static struct slave *rlb_next_rx_slave(struct bonding *bond)
> {
> 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
> 	struct slave *rx_slave, *slave, *start_at;
>-	int i = 0;
>
> 	if (bond_info->next_rx_slave)
> 		start_at = bond_info->next_rx_slave;
>@@ -392,7 +391,7 @@ static struct slave *rlb_next_rx_slave(struct bonding *bond)
>
> 	rx_slave = NULL;
>
>-	bond_for_each_slave_from(bond, slave, i, start_at) {
>+	bond_for_each_slave_from(bond, slave, start_at) {
> 		if (SLAVE_IS_OK(slave)) {
> 			if (!rx_slave) {
> 				rx_slave = slave;
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 55bbb8b..fbe25bc 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -782,7 +782,6 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
> 	struct slave *new_active, *old_active;
> 	struct slave *bestslave = NULL;
> 	int mintime = bond->params.updelay;
>-	int i;
>
> 	new_active = bond->curr_active_slave;
>
>@@ -801,7 +800,7 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
> 	/* remember where to stop iterating over the slaves */
> 	old_active = new_active;
>
>-	bond_for_each_slave_from(bond, new_active, i, old_active) {
>+	bond_for_each_slave_from(bond, new_active, old_active) {
> 		if (new_active->link == BOND_LINK_UP) {
> 			return new_active;
> 		} else if (new_active->link == BOND_LINK_BACK &&
>@@ -2756,7 +2755,6 @@ do_failover:
> static void bond_ab_arp_probe(struct bonding *bond)
> {
> 	struct slave *slave, *next_slave;
>-	int i;
>
> 	read_lock(&bond->curr_slave_lock);
>
>@@ -2788,7 +2786,7 @@ static void bond_ab_arp_probe(struct bonding *bond)
>
> 	/* search for next candidate */
> 	next_slave = bond_next_slave(bond, bond->current_arp_slave);
>-	bond_for_each_slave_from(bond, slave, i, next_slave) {
>+	bond_for_each_slave_from(bond, slave, next_slave) {
> 		if (IS_UP(slave->dev)) {
> 			slave->link = BOND_LINK_BACK;
> 			bond_set_slave_active_flags(slave);
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index eb36f57..e5734ad 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -130,9 +130,9 @@
>  *
>  * Caller must hold bond->lock
>  */
>-#define bond_for_each_slave_from(bond, pos, cnt, start) \
>-	for (cnt = 0, pos = start; pos && cnt < (bond)->slave_cnt; \
>-	     cnt++, pos = bond_next_slave(bond, pos))
>+#define bond_for_each_slave_from(bond, pos, start) \
>+	for (pos = start; pos; (pos = bond_next_slave(bond, pos)) != start ? \
>+	    (pos) : (pos = NULL))
>
> /**
>  * bond_for_each_slave - iterate over all slaves
>-- 
>1.8.0
>
>
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
