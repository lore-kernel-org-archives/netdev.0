From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH] bonding: don't call alb_set_slave_mac_addr() while atomic
Date: Mon, 17 Jun 2013 19:30:03 +0200
Message-ID: <20130617173003.GA17707@redhat.com>
References: <1371489982-4381-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: fubar@us.ibm.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24088 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751062Ab3FQRax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jun 2013 13:30:53 -0400
Content-Disposition: inline
In-Reply-To: <1371489982-4381-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 17, 2013 at 07:26:22PM +0200, Veaceslav Falico wrote:
>alb_set_slave_mac_addr() sets the mac address in alb mode via
>dev_set_mac_address(), which might sleep. It's called from
>alb_handle_addr_collision_on_attach() in atomic context (under
>read_lock(bond->lock)), thus triggering a bug.
>
>Fix this by moving the lock inside alb_handle_addr_collision_on_attach().
>
>v1->v2:
>As Nikolay Aleksandrov noticed, we can drop the bond->lock completely.
>Also, use bond_slave_has_mac(), when possible.
>
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Self-NAK, sent it by hand, forgot to add one space in the command line.
Will send a new one.

Sorry for the noise.

>---
> drivers/net/bonding/bond_alb.c | 40 +++++-----------------------------------
> 1 file changed, 5 insertions(+), 35 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index a236234..27fe329 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -1175,16 +1175,13 @@ static void alb_change_hw_addr_on_detach(struct bonding *bond, struct slave *sla
>  * @slave.
>  *
>  * assumption: this function is called before @slave is attached to the
>- * 	       bond slave list.
>- *
>- * caller must hold the bond lock for write since the mac addresses are compared
>- * and may be swapped.
>+ *	       bond slave list.
>  */
> static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slave *slave)
> {
>-	struct slave *tmp_slave1, *tmp_slave2, *free_mac_slave;
>+	struct slave *tmp_slave1, *free_mac_slave = NULL;
> 	struct slave *has_bond_addr = bond->curr_active_slave;
>-	int i, j, found = 0;
>+	int i;
>
> 	if (bond->slave_cnt == 0) {
> 		/* this is the first slave */
>@@ -1196,15 +1193,7 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
> 	 * slaves in the bond.
> 	 */
> 	if (!ether_addr_equal_64bits(slave->perm_hwaddr, bond->dev->dev_addr)) {
>-		bond_for_each_slave(bond, tmp_slave1, i) {
>-			if (ether_addr_equal_64bits(tmp_slave1->dev->dev_addr,
>-						    slave->dev->dev_addr)) {
>-				found = 1;
>-				break;
>-			}
>-		}
>-
>-		if (!found)
>+		if (!bond_slave_has_mac(bond, slave->dev->dev_addr))
> 			return 0;
>
> 		/* Try setting slave mac to bond address and fall-through
>@@ -1215,19 +1204,8 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
> 	/* The slave's address is equal to the address of the bond.
> 	 * Search for a spare address in the bond for this slave.
> 	 */
>-	free_mac_slave = NULL;
>-
> 	bond_for_each_slave(bond, tmp_slave1, i) {
>-		found = 0;
>-		bond_for_each_slave(bond, tmp_slave2, j) {
>-			if (ether_addr_equal_64bits(tmp_slave1->perm_hwaddr,
>-						    tmp_slave2->dev->dev_addr)) {
>-				found = 1;
>-				break;
>-			}
>-		}
>-
>-		if (!found) {
>+		if (!bond_slave_has_mac(bond, tmp_slave1->perm_hwaddr)) {
> 			/* no slave has tmp_slave1's perm addr
> 			 * as its curr addr
> 			 */
>@@ -1607,15 +1585,7 @@ int bond_alb_init_slave(struct bonding *bond, struct slave *slave)
> 		return res;
> 	}
>
>-	/* caller must hold the bond lock for write since the mac addresses
>-	 * are compared and may be swapped.
>-	 */
>-	read_lock(&bond->lock);
>-
> 	res = alb_handle_addr_collision_on_attach(bond, slave);
>-
>-	read_unlock(&bond->lock);
>-
> 	if (res) {
> 		return res;
> 	}
>-- 
>1.8.1.4
>
