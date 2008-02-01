From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH for 2.6.25 1/2] [NET] ucc_geth: fix module removal
Date: Fri, 1 Feb 2008 16:22:48 +0300
Message-ID: <20080201132248.GA1790@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Li Yang <leoli@freescale.com>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:33404 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754663AbYBANWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 08:22:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- uccf should be set to NULL to not double-free memory on
  subsequent calls;
- ind_hash_q and group_hash_q lists should be initialized in the
  probe() function, instead of struct_init() (called by open()),
  otherwise there will be an oops if ucc_geth_driver removed
  prior 'ifconfig ethX up';
- add unregister_netdev();
- reorder geth_remove() steps.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---

Hi Li,

You kinda promised that these two patches would hit 2.6.25... ;-)

I've rebased the patches so they apply cleanly on the current tree.

Thanks,

 drivers/net/ucc_geth.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 4ffd873..e41da46 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2084,8 +2084,10 @@ static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 	if (!ugeth)
 		return;
 
-	if (ugeth->uccf)
+	if (ugeth->uccf) {
 		ucc_fast_free(ugeth->uccf);
+		ugeth->uccf = NULL;
+	}
 
 	if (ugeth->p_thread_data_tx) {
 		qe_muram_free(ugeth->thread_dat_tx_offset);
@@ -2305,10 +2307,6 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	ug_info = ugeth->ug_info;
 	uf_info = &ug_info->uf_info;
 
-	/* Create CQs for hash tables */
-	INIT_LIST_HEAD(&ugeth->group_hash_q);
-	INIT_LIST_HEAD(&ugeth->ind_hash_q);
-
 	if (!((uf_info->bd_mem_part == MEM_PART_SYSTEM) ||
 	      (uf_info->bd_mem_part == MEM_PART_MURAM))) {
 		if (netif_msg_probe(ugeth))
@@ -3990,6 +3988,10 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	ugeth = netdev_priv(dev);
 	spin_lock_init(&ugeth->lock);
 
+	/* Create CQs for hash tables */
+	INIT_LIST_HEAD(&ugeth->group_hash_q);
+	INIT_LIST_HEAD(&ugeth->ind_hash_q);
+
 	dev_set_drvdata(device, dev);
 
 	/* Set the dev->base_addr to the gfar reg region */
@@ -4040,9 +4042,10 @@ static int ucc_geth_remove(struct of_device* ofdev)
 	struct net_device *dev = dev_get_drvdata(device);
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
 
-	dev_set_drvdata(device, NULL);
-	ucc_geth_memclean(ugeth);
+	unregister_netdev(dev);
 	free_netdev(dev);
+	ucc_geth_memclean(ugeth);
+	dev_set_drvdata(device, NULL);
 
 	return 0;
 }
-- 
1.5.2.2

