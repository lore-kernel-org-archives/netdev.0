From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3 1/4] ethernet: Add new driver for Marvell Armada 375
 network unit
Date: Tue, 8 Jul 2014 00:18:23 +0200
Message-ID: <20140707221823.GC16677@electric-eye.fr.zoreil.com>
References: <1404758751-2346-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1404758751-2346-2-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Marcin Wojtas <mw@semihalf.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38298 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbaGGWS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 18:18:59 -0400
Content-Disposition: inline
In-Reply-To: <1404758751-2346-2-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ezequiel Garcia <ezequiel.garcia@free-electrons.com> :
[...]
> diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
> new file mode 100644
> index 0000000..21931a1
> --- /dev/null
> +++ b/drivers/net/ethernet/marvell/mvpp2.c
[...]
> +static inline void mvpp2_mib_counters_clear(struct mvpp2_port *pp)
> +{
> +	int i;
> +	u32 dummy;
> +
> +	/* Perform dummy reads from MIB counters */
> +	for (i = 0; i < MVPP2_MIB_LATE_COLLISION; i += 4)
> +		dummy = readl(pp->pp2->lms_base +
> +			      (MVPP2_MIB_COUNTERS_BASE(pp->id) + i));
                              ^ excess parenthesis

Please reduce the scope of the dummy variable and add curly braces in the
(multi-line) "for" block.

You may remove the "Perform dummy ..." comment. The code is literate enough.

[...]
> +/* Update lookup field in tcam sw entry */
> +static void mvpp2_prs_tcam_lu_set(struct mvpp2_prs_entry *pe, unsigned int lu)
> +{
> +	pe->tcam.byte[MVPP2_PRS_TCAM_LU_BYTE] = lu;
> +	pe->tcam.byte[MVPP2_PRS_TCAM_EN_OFFS(MVPP2_PRS_TCAM_LU_BYTE)] =
> +							      MVPP2_PRS_LU_MASK;

Use a local u8 *b = pe->tcam.byte; ?

> +}
> +
> +/* Update mask for single port in tcam sw entry */
> +static void mvpp2_prs_tcam_port_set(struct mvpp2_prs_entry *pe,
> +				    unsigned int port, bool add)
> +{
> +	if (add)
> +		pe->tcam.byte[MVPP2_PRS_TCAM_EN_OFFS(MVPP2_PRS_TCAM_PORT_BYTE)]
> +								&= ~(1 << port);
> +	else
> +		pe->tcam.byte[MVPP2_PRS_TCAM_EN_OFFS(MVPP2_PRS_TCAM_PORT_BYTE)]
> +								 |= (1 << port);

Use a local u8 *b = pe->tcam.byte; ?

[...]
> +/* Compare tcam data bytes with a pattern */
> +static bool mvpp2_prs_tcam_data_cmp(struct mvpp2_prs_entry *pe,
> +				    unsigned int offs, unsigned int size,
> +					   unsigned char *bytes)
> +{
> +	unsigned char byte, mask;
> +	int i;
> +
> +	for (i = 0; i < size; i++) {
> +		mvpp2_prs_tcam_data_byte_get(pe, offs + i, &byte, &mask);
> +
> +		if (byte != bytes[i])
> +			return false;

Please reduce the scope of "byte" and "mask".

> +	}
> +	return true;
> +}
> +
> +/* Update ai bits in tcam sw entry */
> +static void mvpp2_prs_tcam_ai_update(struct mvpp2_prs_entry *pe,
> +				     unsigned int bits, unsigned int enable)
> +{
> +	int i;
> +
> +	for (i = 0; i < MVPP2_PRS_AI_BITS; i++)
> +		if (enable & BIT(i)) {
> +			if (bits & BIT(i))
> +				pe->tcam.byte[MVPP2_PRS_TCAM_AI_BYTE] |=
> +								       (1 << i);
> +			else
> +				pe->tcam.byte[MVPP2_PRS_TCAM_AI_BYTE] &=
> +								      ~(1 << i);
> +		}

Curly braces for the "for" loop + local variable for &pe->tcam.byte[foo]

[...]
> +/* Update ri bits in sram sw entry */
> +static void mvpp2_prs_sram_ri_update(struct mvpp2_prs_entry *pe,
> +				     unsigned int bits, unsigned int mask)
> +{
> +	unsigned int i;
> +
> +	for (i = 0; i < MVPP2_PRS_SRAM_RI_CTRL_BITS; i++)

Please add curly braces.

> +		if (mask & BIT(i)) {

Invert the test and add a "continue" statement to recover the missing indent
level ?

> +			if (bits & BIT(i))
> +				mvpp2_prs_sram_bits_set(pe,
> +							MVPP2_PRS_SRAM_RI_OFFS + i, 1);
> +			else
> +				mvpp2_prs_sram_bits_clear(pe,
> +							  MVPP2_PRS_SRAM_RI_OFFS + i, 1);
> +			mvpp2_prs_sram_bits_set(pe,
> +						MVPP2_PRS_SRAM_RI_CTRL_OFFS + i, 1);
> +		}
> +}
> +
> +/* Obtain ri bits and their mask from sram sw entry */
> +static void mvpp2_prs_sram_ri_get(struct mvpp2_prs_entry *pe,
> +				  unsigned int *bits, unsigned int *mask)
> +{
> +	*bits = pe->sram.word[MVPP2_PRS_SRAM_RI_WORD];
> +	*mask = pe->sram.word[MVPP2_PRS_SRAM_RI_CTRL_WORD];
> +}
> +
> +/* Update ai bits in sram sw entry */
> +static void mvpp2_prs_sram_ai_update(struct mvpp2_prs_entry *pe,
> +				     unsigned int bits, unsigned int mask)
> +{
> +	unsigned int i;
> +
> +	for (i = 0; i < MVPP2_PRS_SRAM_AI_CTRL_BITS; i++)

Curly braces.

> +		if (mask & BIT(i)) {
> +			if (bits & BIT(i))
> +				mvpp2_prs_sram_bits_set(pe,
> +							MVPP2_PRS_SRAM_AI_OFFS + i, 1);
> +			else
> +				mvpp2_prs_sram_bits_clear(pe,
> +							  MVPP2_PRS_SRAM_AI_OFFS + i, 1);
> +			mvpp2_prs_sram_bits_set(pe,
> +						MVPP2_PRS_SRAM_AI_CTRL_OFFS + i, 1);
> +		}
> +}
> +
> +/* Read ai bits from sram sw entry */
> +static void mvpp2_prs_sram_ai_get(struct mvpp2_prs_entry *pe,
> +				  unsigned int *bits, unsigned int *enable)
> +{
> +	*bits = (pe->sram.byte[MVPP2_BIT_TO_BYTE(MVPP2_PRS_SRAM_AI_OFFS)]
> +		>> (MVPP2_PRS_SRAM_AI_OFFS % 8)) |

Move ">>" to the end of the previous line.

Use local variable for pe->sram.byte.

> +		(pe->sram.byte[MVPP2_BIT_TO_BYTE(MVPP2_PRS_SRAM_AI_OFFS +
> +		MVPP2_PRS_SRAM_AI_CTRL_BITS)] <<
> +		(8 - (MVPP2_PRS_SRAM_AI_OFFS % 8)));
> +
> +	*enable = (pe->sram.byte[MVPP2_BIT_TO_BYTE(MVPP2_PRS_SRAM_AI_CTRL_OFFS)]
> +		  >> (MVPP2_PRS_SRAM_AI_CTRL_OFFS % 8)) |
> +		  (pe->sram.byte[MVPP2_BIT_TO_BYTE(MVPP2_PRS_SRAM_AI_CTRL_OFFS +
> +		  MVPP2_PRS_SRAM_AI_CTRL_BITS)] <<
> +		  (8 - (MVPP2_PRS_SRAM_AI_CTRL_OFFS % 8)));
[...]
> +static struct mvpp2_prs_entry *mvpp2_prs_flow_find(struct mvpp2 *pp2, int flow)
> +{
> +	struct mvpp2_prs_entry *pe;
> +	unsigned int enable;
> +	unsigned int bits;

Excess scope.

> +	int tid;
> +
> +	pe = kzalloc(sizeof(*pe), GFP_KERNEL);
> +	if (!pe)
> +		return NULL;
> +	mvpp2_prs_tcam_lu_set(pe, MVPP2_PRS_LU_FLOWS);
> +
> +	/* Go through the all entires with MVPP2_PRS_LU_FLOWS */
> +	for (tid = MVPP2_PRS_TCAM_SRAM_SIZE - 1; tid >= 0; tid--) {
> +		if ((!pp2->prs_shadow[tid].valid) ||

Excess parenthesis.

> +		    (pp2->prs_shadow[tid].lu != MVPP2_PRS_LU_FLOWS))
> +			continue;
> +
> +		pe->index = tid;
> +		mvpp2_prs_hw_read(pp2, pe);
> +		mvpp2_prs_sram_ai_get(pe, &bits, &enable);
> +
> +		/* Sram store classification lookup ID in AI bits [5:0] */
> +		if ((bits & MVPP2_PRS_FLOW_ID_MASK) == flow)
> +			return pe;
> +	}
> +	kfree(pe);
> +
> +	return NULL;
> +}
> +
> +/* Return first free tcam index, seeking from start to end */
> +static int mvpp2_prs_tcam_first_free(struct mvpp2 *pp2, unsigned char start,
> +				     unsigned char end)
> +{
> +	int tid;
> +	bool found = false;
> +
> +	if (start > end)
> +		swap(start, end);
> +
> +	for (tid = start; tid <= end; tid++) {
> +		if (!pp2->prs_shadow[tid].valid) {
> +			found = true;
> +			break;

Don't break: test for tid < MVPP2_PRS_TCAM_SRAM_SIZE and return.

> +		}
> +	}
> +
> +	if (found && (tid < MVPP2_PRS_TCAM_SRAM_SIZE))
> +		return tid;
> +	return -EINVAL;
[...]
> +static void mvpp2_prs_mac_all_multi_set(struct mvpp2 *pp2, int port, bool add)
> +{
> +	struct mvpp2_prs_entry pe;
> +	unsigned int index = 0;
> +	unsigned int i;
> +
> +	/* Ethernet multicast address first byte is
> +	 * 0x01 for IPv4 and 0x33 for IPv6
> +	 */
> +	unsigned char da_mc[MVPP2_PRS_MAX_MAC_MC] = { 0x01, 0x33 };
> +
> +	for (i = MVPP2_PRS_IP4_MAC_MC; i < MVPP2_PRS_MAX_MAC_MC; i++) {
> +		if (i == MVPP2_PRS_IP4_MAC_MC)
> +			index = MVPP2_PE_MAC_MC_ALL;
> +		else
> +			index = MVPP2_PE_MAC_MC_IP6;

Ternary ?

[...]
> +/* Set entry for dsa packets */
> +static void mvpp2_prs_dsa_tag_set(struct mvpp2 *pp2, int port, bool add,
> +				  bool tagged, bool extend)
> +{
> +	struct mvpp2_prs_entry pe;
> +	int tid;
> +	int shift;
> +
> +	if (extend) {
> +		if (tagged)
> +			tid = MVPP2_PE_EDSA_TAGGED;
> +		else
> +			tid = MVPP2_PE_EDSA_UNTAGGED;

Ternary ?

> +		shift = 8;
> +	} else {
> +		if (tagged)
> +			tid = MVPP2_PE_DSA_TAGGED;
> +		else
> +			tid = MVPP2_PE_DSA_UNTAGGED;

Ternary ?

[...]
> +static void mvpp2_prs_dsa_tag_ethertype_set(struct mvpp2 *pp2, int port,
> +					    bool add, bool tagged, bool extend)
> +{
> +	struct mvpp2_prs_entry pe;
> +	int tid, shift, port_mask;
> +
> +	if (extend) {
> +		if (tagged)
> +			tid = MVPP2_PE_ETYPE_EDSA_TAGGED;
> +		else
> +			tid = MVPP2_PE_ETYPE_EDSA_UNTAGGED;

Ternary ?

> +		port_mask = 0;
> +		shift = 8;
> +	} else {
> +		if (tagged)
> +			tid = MVPP2_PE_ETYPE_DSA_TAGGED;
> +		else
> +			tid = MVPP2_PE_ETYPE_DSA_UNTAGGED;

Ternary ?

[...]
> +static struct mvpp2_prs_entry *mvpp2_prs_vlan_find(struct mvpp2 *pp2,
> +						   unsigned short tpid, int ai)
> +{
> +	struct mvpp2_prs_entry *pe;
> +	unsigned int ri_bits, ai_bits;
> +	unsigned int enable;
> +	unsigned char tpid_arr[2];
> +	int tid;

Nitnit: please xmas-treefy (wherever possible).

> +
> +	pe = kzalloc(sizeof(*pe), GFP_KERNEL);
> +	if (!pe)
> +		return NULL;
> +	mvpp2_prs_tcam_lu_set(pe, MVPP2_PRS_LU_VLAN);
> +
> +	tpid_arr[0] = ((unsigned char *)&tpid)[1];
> +	tpid_arr[1] = ((unsigned char *)&tpid)[0];
> +
> +	/* Go through the all entries with MVPP2_PRS_LU_VLAN */
> +	for (tid = MVPP2_PE_FIRST_FREE_TID;
> +	     tid <= MVPP2_PE_LAST_FREE_TID; tid++) {
> +		if ((!pp2->prs_shadow[tid].valid) ||

Excess parenthesis.

> +		    (pp2->prs_shadow[tid].lu != MVPP2_PRS_LU_VLAN))
> +			continue;
> +
> +		pe->index = tid;
> +
> +		mvpp2_prs_hw_read(pp2, pe);
> +		if (mvpp2_prs_tcam_data_cmp(pe, 0, 2, tpid_arr)) {
> +			/* Get vlan type */
> +			mvpp2_prs_sram_ri_get(pe, &ri_bits, &enable);
> +			ri_bits = (ri_bits & MVPP2_PRS_RI_VLAN_MASK);
> +
> +			/* Get current ai value from tcam */
> +			mvpp2_prs_tcam_ai_get(pe, &ai_bits, &enable);
> +			/* Clear double vlan bit */
> +			ai_bits &= ~MVPP2_PRS_DBL_VLAN_AI_BIT;
> +
> +			if (ai != ai_bits)
> +				continue;
> +
> +			if ((ri_bits == MVPP2_PRS_RI_VLAN_SINGLE) ||
> +			    (ri_bits == MVPP2_PRS_RI_VLAN_TRIPLE))

Excess parenthesis.

> +				return pe;
> +		}
> +	}
> +	kfree(pe);
> +
> +	return NULL;
> +}
> +
> +/* Add/update single/triple vlan entry */
> +static int mvpp2_prs_vlan_add(struct mvpp2 *pp2, unsigned short tpid, int ai,
> +			      unsigned int port_map)
> +{
> +	struct mvpp2_prs_entry *pe;
> +	unsigned int bits, enable;
> +	int tid_aux, tid;
> +
> +	pe = mvpp2_prs_vlan_find(pp2, tpid, ai);
> +
> +	if (!pe) {
> +		/* Create new tcam entry */
> +		tid = mvpp2_prs_tcam_first_free(pp2, MVPP2_PE_LAST_FREE_TID,
> +						MVPP2_PE_FIRST_FREE_TID);
> +		if (tid < 0)
> +			return tid;
> +
> +		pe = kzalloc(sizeof(*pe), GFP_KERNEL);
> +		if (!pe)
> +			return -ENOMEM;
> +
> +		/* Get last double vlan tid */
> +		for (tid_aux = MVPP2_PE_LAST_FREE_TID;
> +		     tid_aux >= MVPP2_PE_FIRST_FREE_TID; tid_aux--) {
> +			if ((!pp2->prs_shadow[tid_aux].valid) ||

Excess parenthesis.

[...]
> +static int mvpp2_prs_double_vlan_ai_free_get(struct mvpp2 *pp2)
> +{
> +	int i;
> +
> +	for (i = 1; i < MVPP2_PRS_DBL_VLANS_MAX; i++)
> +		if (!pp2->prs_double_vlans[i])
> +			return i;

Curly braces.

> +
> +	return -EINVAL;
> +}
> +
> +/* Search for existing double vlan entry */
> +static struct mvpp2_prs_entry *mvpp2_prs_double_vlan_find(struct mvpp2 *pp2,
> +							  unsigned short tpid1,
> +							  unsigned short tpid2)
> +{
> +	struct mvpp2_prs_entry *pe;
> +	unsigned int enable, bits;

Excess scope.

> +	unsigned char tpid_arr1[2];
> +	unsigned char tpid_arr2[2];

unsigned char tpid[2][2] ?

> +	int tid;
> +
> +	tpid_arr1[0] = ((unsigned char *)&tpid1)[1];
> +	tpid_arr1[1] = ((unsigned char *)&tpid1)[0];

Use endian safe shift and mask ?

> +
> +	tpid_arr2[0] = ((unsigned char *)&tpid2)[1];
> +	tpid_arr2[1] = ((unsigned char *)&tpid2)[0];

Duplicated code :o)

> +
> +	pe = kzalloc(sizeof(*pe), GFP_KERNEL);
> +	if (!pe)
> +		return NULL;
> +	mvpp2_prs_tcam_lu_set(pe, MVPP2_PRS_LU_VLAN);
> +
> +	/* Go through the all entries with MVPP2_PRS_LU_VLAN */
> +	for (tid = MVPP2_PE_FIRST_FREE_TID;
> +	     tid <= MVPP2_PE_LAST_FREE_TID; tid++) {
> +		if ((!pp2->prs_shadow[tid].valid) ||
> +		    (pp2->prs_shadow[tid].lu != MVPP2_PRS_LU_VLAN))
> +			continue;
> +
> +		pe->index = tid;
> +		mvpp2_prs_hw_read(pp2, pe);

It should be possible to factor out the test or test + pe->... = ... + hw_read.

> +
> +		if (mvpp2_prs_tcam_data_cmp(pe, 0, 2, tpid_arr1) &&
> +		    mvpp2_prs_tcam_data_cmp(pe, 4, 2, tpid_arr2)) {

The "size" parameter of mvpp2_prs_tcam_data_cmp is always "2".
OTOH, if you use a single 4 bytes array for tpid_arr, you'll be able
to issue a single mvpp2_prs_tcam_data_cmp call.

Off to bed.

-- 
Ueimor
