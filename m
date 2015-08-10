From: Jakub Kicinski <moorray3@wp.pl>
Subject: [PATCH 3/3] gianfar: remove faulty filer optimizer
Date: Mon, 10 Aug 2015 22:12:20 +0200
Message-ID: <1439237540-11302-4-git-send-email-moorray3@wp.pl>
References: <1439237540-11302-1-git-send-email-moorray3@wp.pl>
Cc: netdev@vger.kernel.org, Jakub Kicinski <kubakici@wp.pl>
To: "David S. Miller" <davem@davemloft.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:15256 "EHLO mx4.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932726AbbHJUMd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2015 16:12:33 -0400
In-Reply-To: <1439237540-11302-1-git-send-email-moorray3@wp.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <kubakici@wp.pl>

Current filer rule optimization is broken in several ways:
 (1) It destroys rule ordering.
 (2) It performs reads/writes beyond end of allocated tables.
 (3) It breaks badly for rules with more than 2 specifiers
     (e.g. matching ip, port, tos).
 (4) We observed that the masking rules it generates do not
     play well with clustering on P2020.  Only first rule
     of the cluster would ever fire.  Given that optimizer
     relies heavily on masking this is very hard to fix.

The fact that nobody noticed (1), (3) or (4) makes me think
that this feature is not very widely used and we should just
remove it.

Reported-by: Aleksander Dutkowski <adutkowski@gmail.com>
Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
---
 drivers/net/ethernet/freescale/gianfar_ethtool.c | 337 -----------------------
 1 file changed, 337 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index b955ed83ca98..6bdc89179b72 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -902,27 +902,6 @@ static int gfar_check_filer_hardware(struct gfar_private *priv)
 	return 0;
 }
 
-static int gfar_comp_asc(const void *a, const void *b)
-{
-	return memcmp(a, b, 4);
-}
-
-static int gfar_comp_desc(const void *a, const void *b)
-{
-	return -memcmp(a, b, 4);
-}
-
-static void gfar_swap(void *a, void *b, int size)
-{
-	u32 *_a = a;
-	u32 *_b = b;
-
-	swap(_a[0], _b[0]);
-	swap(_a[1], _b[1]);
-	swap(_a[2], _b[2]);
-	swap(_a[3], _b[3]);
-}
-
 /* Write a mask to filer cache */
 static void gfar_set_mask(u32 mask, struct filer_table *tab)
 {
@@ -1272,310 +1251,6 @@ static int gfar_convert_to_filer(struct ethtool_rx_flow_spec *rule,
 	return 0;
 }
 
-/* Copy size filer entries */
-static void gfar_copy_filer_entries(struct gfar_filer_entry dst[0],
-				    struct gfar_filer_entry src[0], s32 size)
-{
-	while (size > 0) {
-		size--;
-		dst[size].ctrl = src[size].ctrl;
-		dst[size].prop = src[size].prop;
-	}
-}
-
-/* Delete the contents of the filer-table between start and end
- * and collapse them
- */
-static int gfar_trim_filer_entries(u32 begin, u32 end, struct filer_table *tab)
-{
-	int length;
-
-	if (end > MAX_FILER_CACHE_IDX || end < begin)
-		return -EINVAL;
-
-	end++;
-	length = end - begin;
-
-	/* Copy */
-	while (end < tab->index) {
-		tab->fe[begin].ctrl = tab->fe[end].ctrl;
-		tab->fe[begin++].prop = tab->fe[end++].prop;
-
-	}
-	/* Fill up with don't cares */
-	while (begin < tab->index) {
-		tab->fe[begin].ctrl = 0x60;
-		tab->fe[begin].prop = 0xFFFFFFFF;
-		begin++;
-	}
-
-	tab->index -= length;
-	return 0;
-}
-
-/* Make space on the wanted location */
-static int gfar_expand_filer_entries(u32 begin, u32 length,
-				     struct filer_table *tab)
-{
-	if (length == 0 || length + tab->index > MAX_FILER_CACHE_IDX ||
-	    begin > MAX_FILER_CACHE_IDX)
-		return -EINVAL;
-
-	gfar_copy_filer_entries(&(tab->fe[begin + length]), &(tab->fe[begin]),
-				tab->index - length + 1);
-
-	tab->index += length;
-	return 0;
-}
-
-static int gfar_get_next_cluster_start(int start, struct filer_table *tab)
-{
-	for (; (start < tab->index) && (start < MAX_FILER_CACHE_IDX - 1);
-	     start++) {
-		if ((tab->fe[start].ctrl & (RQFCR_AND | RQFCR_CLE)) ==
-		    (RQFCR_AND | RQFCR_CLE))
-			return start;
-	}
-	return -1;
-}
-
-static int gfar_get_next_cluster_end(int start, struct filer_table *tab)
-{
-	for (; (start < tab->index) && (start < MAX_FILER_CACHE_IDX - 1);
-	     start++) {
-		if ((tab->fe[start].ctrl & (RQFCR_AND | RQFCR_CLE)) ==
-		    (RQFCR_CLE))
-			return start;
-	}
-	return -1;
-}
-
-/* Uses hardwares clustering option to reduce
- * the number of filer table entries
- */
-static void gfar_cluster_filer(struct filer_table *tab)
-{
-	s32 i = -1, j, iend, jend;
-
-	while ((i = gfar_get_next_cluster_start(++i, tab)) != -1) {
-		j = i;
-		while ((j = gfar_get_next_cluster_start(++j, tab)) != -1) {
-			/* The cluster entries self and the previous one
-			 * (a mask) must be identical!
-			 */
-			if (tab->fe[i].ctrl != tab->fe[j].ctrl)
-				break;
-			if (tab->fe[i].prop != tab->fe[j].prop)
-				break;
-			if (tab->fe[i - 1].ctrl != tab->fe[j - 1].ctrl)
-				break;
-			if (tab->fe[i - 1].prop != tab->fe[j - 1].prop)
-				break;
-			iend = gfar_get_next_cluster_end(i, tab);
-			jend = gfar_get_next_cluster_end(j, tab);
-			if (jend == -1 || iend == -1)
-				break;
-
-			/* First we make some free space, where our cluster
-			 * element should be. Then we copy it there and finally
-			 * delete in from its old location.
-			 */
-			if (gfar_expand_filer_entries(iend, (jend - j), tab) ==
-			    -EINVAL)
-				break;
-
-			gfar_copy_filer_entries(&(tab->fe[iend + 1]),
-						&(tab->fe[jend + 1]), jend - j);
-
-			if (gfar_trim_filer_entries(jend - 1,
-						    jend + (jend - j),
-						    tab) == -EINVAL)
-				return;
-
-			/* Mask out cluster bit */
-			tab->fe[iend].ctrl &= ~(RQFCR_CLE);
-		}
-	}
-}
-
-/* Swaps the masked bits of a1<>a2 and b1<>b2 */
-static void gfar_swap_bits(struct gfar_filer_entry *a1,
-			   struct gfar_filer_entry *a2,
-			   struct gfar_filer_entry *b1,
-			   struct gfar_filer_entry *b2, u32 mask)
-{
-	u32 temp[4];
-	temp[0] = a1->ctrl & mask;
-	temp[1] = a2->ctrl & mask;
-	temp[2] = b1->ctrl & mask;
-	temp[3] = b2->ctrl & mask;
-
-	a1->ctrl &= ~mask;
-	a2->ctrl &= ~mask;
-	b1->ctrl &= ~mask;
-	b2->ctrl &= ~mask;
-
-	a1->ctrl |= temp[1];
-	a2->ctrl |= temp[0];
-	b1->ctrl |= temp[3];
-	b2->ctrl |= temp[2];
-}
-
-/* Generate a list consisting of masks values with their start and
- * end of validity and block as indicator for parts belonging
- * together (glued by ANDs) in mask_table
- */
-static u32 gfar_generate_mask_table(struct gfar_mask_entry *mask_table,
-				    struct filer_table *tab)
-{
-	u32 i, and_index = 0, block_index = 1;
-
-	for (i = 0; i < tab->index; i++) {
-
-		/* LSByte of control = 0 sets a mask */
-		if (!(tab->fe[i].ctrl & 0xF)) {
-			mask_table[and_index].mask = tab->fe[i].prop;
-			mask_table[and_index].start = i;
-			mask_table[and_index].block = block_index;
-			if (and_index >= 1)
-				mask_table[and_index - 1].end = i - 1;
-			and_index++;
-		}
-		/* cluster starts and ends will be separated because they should
-		 * hold their position
-		 */
-		if (tab->fe[i].ctrl & RQFCR_CLE)
-			block_index++;
-		/* A not set AND indicates the end of a depended block */
-		if (!(tab->fe[i].ctrl & RQFCR_AND))
-			block_index++;
-	}
-
-	mask_table[and_index - 1].end = i - 1;
-
-	return and_index;
-}
-
-/* Sorts the entries of mask_table by the values of the masks.
- * Important: The 0xFF80 flags of the first and last entry of a
- * block must hold their position (which queue, CLusterEnable, ReJEct,
- * AND)
- */
-static void gfar_sort_mask_table(struct gfar_mask_entry *mask_table,
-				 struct filer_table *temp_table, u32 and_index)
-{
-	/* Pointer to compare function (_asc or _desc) */
-	int (*gfar_comp)(const void *, const void *);
-
-	u32 i, size = 0, start = 0, prev = 1;
-	u32 old_first, old_last, new_first, new_last;
-
-	gfar_comp = &gfar_comp_desc;
-
-	for (i = 0; i < and_index; i++) {
-		if (prev != mask_table[i].block) {
-			old_first = mask_table[start].start + 1;
-			old_last = mask_table[i - 1].end;
-			sort(mask_table + start, size,
-			     sizeof(struct gfar_mask_entry),
-			     gfar_comp, &gfar_swap);
-
-			/* Toggle order for every block. This makes the
-			 * thing more efficient!
-			 */
-			if (gfar_comp == gfar_comp_desc)
-				gfar_comp = &gfar_comp_asc;
-			else
-				gfar_comp = &gfar_comp_desc;
-
-			new_first = mask_table[start].start + 1;
-			new_last = mask_table[i - 1].end;
-
-			gfar_swap_bits(&temp_table->fe[new_first],
-				       &temp_table->fe[old_first],
-				       &temp_table->fe[new_last],
-				       &temp_table->fe[old_last],
-				       RQFCR_QUEUE | RQFCR_CLE |
-				       RQFCR_RJE | RQFCR_AND);
-
-			start = i;
-			size = 0;
-		}
-		size++;
-		prev = mask_table[i].block;
-	}
-}
-
-/* Reduces the number of masks needed in the filer table to save entries
- * This is done by sorting the masks of a depended block. A depended block is
- * identified by gluing ANDs or CLE. The sorting order toggles after every
- * block. Of course entries in scope of a mask must change their location with
- * it.
- */
-static int gfar_optimize_filer_masks(struct filer_table *tab)
-{
-	struct filer_table *temp_table;
-	struct gfar_mask_entry *mask_table;
-
-	u32 and_index = 0, previous_mask = 0, i = 0, j = 0, size = 0;
-	s32 ret = 0;
-
-	/* We need a copy of the filer table because
-	 * we want to change its order
-	 */
-	temp_table = kmemdup(tab, sizeof(*temp_table), GFP_KERNEL);
-	if (temp_table == NULL)
-		return -ENOMEM;
-
-	mask_table = kcalloc(MAX_FILER_CACHE_IDX / 2 + 1,
-			     sizeof(struct gfar_mask_entry), GFP_KERNEL);
-
-	if (mask_table == NULL) {
-		ret = -ENOMEM;
-		goto end;
-	}
-
-	and_index = gfar_generate_mask_table(mask_table, tab);
-
-	gfar_sort_mask_table(mask_table, temp_table, and_index);
-
-	/* Now we can copy the data from our duplicated filer table to
-	 * the real one in the order the mask table says
-	 */
-	for (i = 0; i < and_index; i++) {
-		size = mask_table[i].end - mask_table[i].start + 1;
-		gfar_copy_filer_entries(&(tab->fe[j]),
-				&(temp_table->fe[mask_table[i].start]), size);
-		j += size;
-	}
-
-	/* And finally we just have to check for duplicated masks and drop the
-	 * second ones
-	 */
-	for (i = 0; i < tab->index && i < MAX_FILER_CACHE_IDX; i++) {
-		if (tab->fe[i].ctrl == 0x80) {
-			previous_mask = i++;
-			break;
-		}
-	}
-	for (; i < tab->index && i < MAX_FILER_CACHE_IDX; i++) {
-		if (tab->fe[i].ctrl == 0x80) {
-			if (tab->fe[i].prop == tab->fe[previous_mask].prop) {
-				/* Two identical ones found!
-				 * So drop the second one!
-				 */
-				gfar_trim_filer_entries(i, i, tab);
-			} else
-				/* Not identical! */
-				previous_mask = i;
-		}
-	}
-
-	kfree(mask_table);
-end:	kfree(temp_table);
-	return ret;
-}
-
 /* Write the bit-pattern from software's buffer to hardware registers */
 static int gfar_write_filer_table(struct gfar_private *priv,
 				  struct filer_table *tab)
@@ -1622,7 +1297,6 @@ static int gfar_process_filer_changes(struct gfar_private *priv)
 {
 	struct ethtool_flow_spec_container *j;
 	struct filer_table *tab;
-	s32 i = 0;
 	s32 ret = 0;
 
 	/* So index is set to zero, too! */
@@ -1647,17 +1321,6 @@ static int gfar_process_filer_changes(struct gfar_private *priv)
 		}
 	}
 
-	i = tab->index;
-
-	/* Optimizations to save entries */
-	gfar_cluster_filer(tab);
-	gfar_optimize_filer_masks(tab);
-
-	pr_debug("\tSummary:\n"
-		 "\tData on hardware: %d\n"
-		 "\tCompression rate: %d%%\n",
-		 tab->index, 100 - (100 * tab->index) / i);
-
 	/* Write everything to hardware */
 	ret = gfar_write_filer_table(priv, tab);
 	if (ret == -EBUSY) {
-- 
2.1.0
