From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 6/6] ucc_geth: Remove UGETH_FILTERING dead code
Date: Thu, 18 Dec 2008 21:23:35 +0300
Message-ID: <20081218182335.GF30682@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Cc: David Miller <davem@davemloft.net>, Li Yang <leoli@freescale.com>,
	Timur Tabi <timur@freescale.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:26603 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752295AbYLRSXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 13:23:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code appears to be dead: nobody call these functions, plus build
breaks when UGETH_FILTERING is enabled:

ucc_geth.c:1848: warning: 'struct enet_addr' declared inside parameter list
ucc_geth.c:1848: warning: its scope is only this definition or declaration, which is probably not what you want
ucc_geth.c: In function 'ugeth_82xx_filtering_get_match_addr_in_hash':
ucc_geth.c:1856: error: dereferencing pointer to incomplete type
ucc_geth.c:1874: error: dereferencing pointer to incomplete type
ucc_geth.c:1877: warning: return from incompatible pointer type
ucc_geth.c: At top level:
ucc_geth.c:1885: warning: 'struct enet_addr' declared inside parameter list
ucc_geth.c: In function 'ugeth_82xx_filtering_add_addr_in_hash':
ucc_geth.c:1894: error: dereferencing pointer to incomplete type
ucc_geth.c:1909: warning: passing argument 2 of 'ugeth_82xx_filtering_get_match_addr_in_hash' from incompatible pointer type
ucc_geth.c:1909: warning: assignment from incompatible pointer type
ucc_geth.c:1918: error: dereferencing pointer to incomplete type
ucc_geth.c: At top level:
ucc_geth.c:1928: warning: 'struct enet_addr' declared inside parameter list
ucc_geth.c: In function 'ugeth_82xx_filtering_clear_addr_in_hash':
ucc_geth.c:1947: warning: passing argument 2 of 'ugeth_82xx_filtering_get_match_addr_in_hash' from incompatible pointer type
ucc_geth.c:1947: warning: assignment from incompatible pointer type
ucc_geth.c:1954: error: dereferencing pointer to incomplete type
ucc_geth.c: At top level:
ucc_geth.c:2060: warning: 'struct enet_addr' declared inside parameter list
ucc_geth.c: In function 'ugeth_82xx_filtering_add_addr_in_paddr':
ucc_geth.c:2064: error: dereferencing pointer to incomplete type
ucc_geth.c:2073: error: dereferencing pointer to incomplete type
ucc_geth.c:2075: warning: passing argument 2 of 'hw_add_addr_in_paddr' from incompatible pointer type
make[2]: *** [ucc_geth.o] Error 1

The code is there since the driver was merged, and nobody seem to be
interested in fixing or actually using it. If we ever want the
filtering support, we can always revert the patch and fix it, but so
far it just draws reader's attention.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/Kconfig    |    4 -
 drivers/net/ucc_geth.c |  262 ------------------------------------------------
 2 files changed, 0 insertions(+), 266 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 231eeaf..88b684e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2276,10 +2276,6 @@ config UGETH_MAGIC_PACKET
 	bool "Magic Packet detection support"
 	depends on UCC_GETH
 
-config UGETH_FILTERING
-	bool "Mac address filtering support"
-	depends on UCC_GETH
-
 config UGETH_TX_ON_DEMAND
 	bool "Transmit on Demand support"
 	depends on UCC_GETH
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 20c065c..6c2d074 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -188,17 +188,6 @@ static void mem_disp(u8 *addr, int size)
 }
 #endif /* DEBUG */
 
-#ifdef CONFIG_UGETH_FILTERING
-static void enqueue(struct list_head *node, struct list_head *lh)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&ugeth_lock, flags);
-	list_add_tail(node, lh);
-	spin_unlock_irqrestore(&ugeth_lock, flags);
-}
-#endif /* CONFIG_UGETH_FILTERING */
-
 static struct list_head *dequeue(struct list_head *lh)
 {
 	unsigned long flags;
@@ -391,23 +380,6 @@ static int dump_init_enet_entries(struct ucc_geth_private *ugeth,
 }
 #endif
 
-#ifdef CONFIG_UGETH_FILTERING
-static struct enet_addr_container *get_enet_addr_container(void)
-{
-	struct enet_addr_container *enet_addr_cont;
-
-	/* allocate memory */
-	enet_addr_cont = kmalloc(sizeof(struct enet_addr_container), GFP_KERNEL);
-	if (!enet_addr_cont) {
-		ugeth_err("%s: No memory for enet_addr_container object.",
-			  __func__);
-		return NULL;
-	}
-
-	return enet_addr_cont;
-}
-#endif /* CONFIG_UGETH_FILTERING */
-
 static void put_enet_addr_container(struct enet_addr_container *enet_addr_cont)
 {
 	kfree(enet_addr_cont);
@@ -420,28 +392,6 @@ static void set_mac_addr(__be16 __iomem *reg, u8 *mac)
 	out_be16(&reg[2], ((u16)mac[1] << 8) | mac[0]);
 }
 
-#ifdef CONFIG_UGETH_FILTERING
-static int hw_add_addr_in_paddr(struct ucc_geth_private *ugeth,
-                                u8 *p_enet_addr, u8 paddr_num)
-{
-	struct ucc_geth_82xx_address_filtering_pram *p_82xx_addr_filt;
-
-	if (!(paddr_num < NUM_OF_PADDRS)) {
-		ugeth_warn("%s: Illegal paddr_num.", __func__);
-		return -EINVAL;
-	}
-
-	p_82xx_addr_filt =
-	    (struct ucc_geth_82xx_address_filtering_pram *) ugeth->p_rx_glbl_pram->
-	    addressfiltering;
-
-	/* Ethernet frames are defined in Little Endian mode,    */
-	/* therefore to insert the address we reverse the bytes. */
-	set_mac_addr(&p_82xx_addr_filt->paddr[paddr_num].h, p_enet_addr);
-	return 0;
-}
-#endif /* CONFIG_UGETH_FILTERING */
-
 static int hw_clear_addr_in_paddr(struct ucc_geth_private *ugeth, u8 paddr_num)
 {
 	struct ucc_geth_82xx_address_filtering_pram __iomem *p_82xx_addr_filt;
@@ -1802,196 +1752,6 @@ static void ugeth_dump_regs(struct ucc_geth_private *ugeth)
 #endif
 }
 
-#ifdef CONFIG_UGETH_FILTERING
-static int ugeth_ext_filtering_serialize_tad(struct ucc_geth_tad_params *
-					     p_UccGethTadParams,
-					     struct qe_fltr_tad *qe_fltr_tad)
-{
-	u16 temp;
-
-	/* Zero serialized TAD */
-	memset(qe_fltr_tad, 0, QE_FLTR_TAD_SIZE);
-
-	qe_fltr_tad->serialized[0] |= UCC_GETH_TAD_V;	/* Must have this */
-	if (p_UccGethTadParams->rx_non_dynamic_extended_features_mode ||
-	    (p_UccGethTadParams->vtag_op != UCC_GETH_VLAN_OPERATION_TAGGED_NOP)
-	    || (p_UccGethTadParams->vnontag_op !=
-		UCC_GETH_VLAN_OPERATION_NON_TAGGED_NOP)
-	    )
-		qe_fltr_tad->serialized[0] |= UCC_GETH_TAD_EF;
-	if (p_UccGethTadParams->reject_frame)
-		qe_fltr_tad->serialized[0] |= UCC_GETH_TAD_REJ;
-	temp =
-	    (u16) (((u16) p_UccGethTadParams->
-		    vtag_op) << UCC_GETH_TAD_VTAG_OP_SHIFT);
-	qe_fltr_tad->serialized[0] |= (u8) (temp >> 8);	/* upper bits */
-
-	qe_fltr_tad->serialized[1] |= (u8) (temp & 0x00ff);	/* lower bits */
-	if (p_UccGethTadParams->vnontag_op ==
-	    UCC_GETH_VLAN_OPERATION_NON_TAGGED_Q_TAG_INSERT)
-		qe_fltr_tad->serialized[1] |= UCC_GETH_TAD_V_NON_VTAG_OP;
-	qe_fltr_tad->serialized[1] |=
-	    p_UccGethTadParams->rqos << UCC_GETH_TAD_RQOS_SHIFT;
-
-	qe_fltr_tad->serialized[2] |=
-	    p_UccGethTadParams->vpri << UCC_GETH_TAD_V_PRIORITY_SHIFT;
-	/* upper bits */
-	qe_fltr_tad->serialized[2] |= (u8) (p_UccGethTadParams->vid >> 8);
-	/* lower bits */
-	qe_fltr_tad->serialized[3] |= (u8) (p_UccGethTadParams->vid & 0x00ff);
-
-	return 0;
-}
-
-static struct enet_addr_container_t
-    *ugeth_82xx_filtering_get_match_addr_in_hash(struct ucc_geth_private *ugeth,
-						 struct enet_addr *p_enet_addr)
-{
-	struct enet_addr_container *enet_addr_cont;
-	struct list_head *p_lh;
-	u16 i, num;
-	int32_t j;
-	u8 *p_counter;
-
-	if ((*p_enet_addr)[0] & ENET_GROUP_ADDR) {
-		p_lh = &ugeth->group_hash_q;
-		p_counter = &(ugeth->numGroupAddrInHash);
-	} else {
-		p_lh = &ugeth->ind_hash_q;
-		p_counter = &(ugeth->numIndAddrInHash);
-	}
-
-	if (!p_lh)
-		return NULL;
-
-	num = *p_counter;
-
-	for (i = 0; i < num; i++) {
-		enet_addr_cont =
-		    (struct enet_addr_container *)
-		    ENET_ADDR_CONT_ENTRY(dequeue(p_lh));
-		for (j = ENET_NUM_OCTETS_PER_ADDRESS - 1; j >= 0; j--) {
-			if ((*p_enet_addr)[j] != (enet_addr_cont->address)[j])
-				break;
-			if (j == 0)
-				return enet_addr_cont;	/* Found */
-		}
-		enqueue(p_lh, &enet_addr_cont->node);	/* Put it back */
-	}
-	return NULL;
-}
-
-static int ugeth_82xx_filtering_add_addr_in_hash(struct ucc_geth_private *ugeth,
-						 struct enet_addr *p_enet_addr)
-{
-	enum ucc_geth_enet_address_recognition_location location;
-	struct enet_addr_container *enet_addr_cont;
-	struct list_head *p_lh;
-	u8 i;
-	u32 limit;
-	u8 *p_counter;
-
-	if ((*p_enet_addr)[0] & ENET_GROUP_ADDR) {
-		p_lh = &ugeth->group_hash_q;
-		limit = ugeth->ug_info->maxGroupAddrInHash;
-		location =
-		    UCC_GETH_ENET_ADDRESS_RECOGNITION_LOCATION_GROUP_HASH;
-		p_counter = &(ugeth->numGroupAddrInHash);
-	} else {
-		p_lh = &ugeth->ind_hash_q;
-		limit = ugeth->ug_info->maxIndAddrInHash;
-		location =
-		    UCC_GETH_ENET_ADDRESS_RECOGNITION_LOCATION_INDIVIDUAL_HASH;
-		p_counter = &(ugeth->numIndAddrInHash);
-	}
-
-	if ((enet_addr_cont =
-	     ugeth_82xx_filtering_get_match_addr_in_hash(ugeth, p_enet_addr))) {
-		list_add(p_lh, &enet_addr_cont->node);	/* Put it back */
-		return 0;
-	}
-	if ((!p_lh) || (!(*p_counter < limit)))
-		return -EBUSY;
-	if (!(enet_addr_cont = get_enet_addr_container()))
-		return -ENOMEM;
-	for (i = 0; i < ENET_NUM_OCTETS_PER_ADDRESS; i++)
-		(enet_addr_cont->address)[i] = (*p_enet_addr)[i];
-	enet_addr_cont->location = location;
-	enqueue(p_lh, &enet_addr_cont->node);	/* Put it back */
-	++(*p_counter);
-
-	hw_add_addr_in_hash(ugeth, enet_addr_cont->address);
-	return 0;
-}
-
-static int ugeth_82xx_filtering_clear_addr_in_hash(struct ucc_geth_private *ugeth,
-						   struct enet_addr *p_enet_addr)
-{
-	struct ucc_geth_82xx_address_filtering_pram *p_82xx_addr_filt;
-	struct enet_addr_container *enet_addr_cont;
-	struct ucc_fast_private *uccf;
-	enum comm_dir comm_dir;
-	u16 i, num;
-	struct list_head *p_lh;
-	u32 *addr_h, *addr_l;
-	u8 *p_counter;
-
-	uccf = ugeth->uccf;
-
-	p_82xx_addr_filt =
-	    (struct ucc_geth_82xx_address_filtering_pram *) ugeth->p_rx_glbl_pram->
-	    addressfiltering;
-
-	if (!
-	    (enet_addr_cont =
-	     ugeth_82xx_filtering_get_match_addr_in_hash(ugeth, p_enet_addr)))
-		return -ENOENT;
-
-	/* It's been found and removed from the CQ. */
-	/* Now destroy its container */
-	put_enet_addr_container(enet_addr_cont);
-
-	if ((*p_enet_addr)[0] & ENET_GROUP_ADDR) {
-		addr_h = &(p_82xx_addr_filt->gaddr_h);
-		addr_l = &(p_82xx_addr_filt->gaddr_l);
-		p_lh = &ugeth->group_hash_q;
-		p_counter = &(ugeth->numGroupAddrInHash);
-	} else {
-		addr_h = &(p_82xx_addr_filt->iaddr_h);
-		addr_l = &(p_82xx_addr_filt->iaddr_l);
-		p_lh = &ugeth->ind_hash_q;
-		p_counter = &(ugeth->numIndAddrInHash);
-	}
-
-	comm_dir = 0;
-	if (uccf->enabled_tx)
-		comm_dir |= COMM_DIR_TX;
-	if (uccf->enabled_rx)
-		comm_dir |= COMM_DIR_RX;
-	if (comm_dir)
-		ugeth_disable(ugeth, comm_dir);
-
-	/* Clear the hash table. */
-	out_be32(addr_h, 0x00000000);
-	out_be32(addr_l, 0x00000000);
-
-	/* Add all remaining CQ elements back into hash */
-	num = --(*p_counter);
-	for (i = 0; i < num; i++) {
-		enet_addr_cont =
-		    (struct enet_addr_container *)
-		    ENET_ADDR_CONT_ENTRY(dequeue(p_lh));
-		hw_add_addr_in_hash(ugeth, enet_addr_cont->address);
-		enqueue(p_lh, &enet_addr_cont->node);	/* Put it back */
-	}
-
-	if (comm_dir)
-		ugeth_enable(ugeth, comm_dir);
-
-	return 0;
-}
-#endif /* CONFIG_UGETH_FILTERING */
-
 static int ugeth_82xx_filtering_clear_all_addr_in_hash(struct ucc_geth_private *
 						       ugeth,
 						       enum enet_addr_type
@@ -2054,28 +1814,6 @@ static int ugeth_82xx_filtering_clear_all_addr_in_hash(struct ucc_geth_private *
 	return 0;
 }
 
-#ifdef CONFIG_UGETH_FILTERING
-static int ugeth_82xx_filtering_add_addr_in_paddr(struct ucc_geth_private *ugeth,
-						  struct enet_addr *p_enet_addr,
-						  u8 paddr_num)
-{
-	int i;
-
-	if ((*p_enet_addr)[0] & ENET_GROUP_ADDR)
-		ugeth_warn
-		    ("%s: multicast address added to paddr will have no "
-		     "effect - is this what you wanted?",
-		     __func__);
-
-	ugeth->indAddrRegUsed[paddr_num] = 1;	/* mark this paddr as used */
-	/* store address in our database */
-	for (i = 0; i < ENET_NUM_OCTETS_PER_ADDRESS; i++)
-		ugeth->paddr[paddr_num][i] = (*p_enet_addr)[i];
-	/* put in hardware */
-	return hw_add_addr_in_paddr(ugeth, p_enet_addr, paddr_num);
-}
-#endif /* CONFIG_UGETH_FILTERING */
-
 static int ugeth_82xx_filtering_clear_addr_in_paddr(struct ucc_geth_private *ugeth,
 						    u8 paddr_num)
 {
-- 
1.5.6.5
