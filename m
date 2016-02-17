From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 367/387]
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c:224:11: error:
 'DCBX_APP_SF_DEFAULT' undeclared
Date: Wed, 17 Feb 2016 15:57:41 +0800
Message-ID: <201602171531.30XnsR5H%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="W/nzBZO5zC0uMSeA"
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:44715 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756450AbcBQH6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 02:58:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   547b9ca879eafeb3507c00dc77002953c9c04b0b
commit: e5d3a51cefbb08c8b8c521f627aef1f998834530 [367/387] bnx2x: extend DCBx support
config: powerpc-defconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout e5d3a51cefbb08c8b8c521f627aef1f998834530
        # save the attached .config to linux build tree
        make.cross ARCH=powerpc 

All errors (new ones prefixed by >>):

   In file included from drivers/net/ethernet/broadcom/bnx2x/bnx2x.h:56:0,
                    from drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c:30:
   drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c: In function 'bnx2x_dcbx_get_ap_feature':
>> drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c:224:11: error: 'DCBX_APP_SF_DEFAULT' undeclared (first use in this function)
              DCBX_APP_SF_DEFAULT) &&
              ^
   drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h:120:45: note: in definition of macro 'GET_FLAGS'
    #define GET_FLAGS(flags, bits)  ((flags) & (bits))
                                                ^
   drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c:224:11: note: each undeclared identifier is reported only once for each function it appears in
              DCBX_APP_SF_DEFAULT) &&
              ^
   drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h:120:45: note: in definition of macro 'GET_FLAGS'
    #define GET_FLAGS(flags, bits)  ((flags) & (bits))
                                                ^

vim +/DCBX_APP_SF_DEFAULT +224 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c

    24	#include <linux/netdevice.h>
    25	#include <linux/types.h>
    26	#include <linux/errno.h>
    27	#include <linux/rtnetlink.h>
    28	#include <net/dcbnl.h>
    29	
  > 30	#include "bnx2x.h"
    31	#include "bnx2x_cmn.h"
    32	#include "bnx2x_dcb.h"
    33	
    34	/* forward declarations of dcbx related functions */
    35	static void bnx2x_pfc_set_pfc(struct bnx2x *bp);
    36	static void bnx2x_dcbx_update_ets_params(struct bnx2x *bp);
    37	static void bnx2x_dcbx_get_ets_pri_pg_tbl(struct bnx2x *bp,
    38						  u32 *set_configuration_ets_pg,
    39						  u32 *pri_pg_tbl);
    40	static void bnx2x_dcbx_get_num_pg_traf_type(struct bnx2x *bp,
    41						    u32 *pg_pri_orginal_spread,
    42						    struct pg_help_data *help_data);
    43	static void bnx2x_dcbx_fill_cos_params(struct bnx2x *bp,
    44					       struct pg_help_data *help_data,
    45					       struct dcbx_ets_feature *ets,
    46					       u32 *pg_pri_orginal_spread);
    47	static void bnx2x_dcbx_separate_pauseable_from_non(struct bnx2x *bp,
    48					struct cos_help_data *cos_data,
    49					u32 *pg_pri_orginal_spread,
    50					struct dcbx_ets_feature *ets);
    51	static void bnx2x_dcbx_fw_struct(struct bnx2x *bp,
    52					 struct bnx2x_func_tx_start_params*);
    53	
    54	/* helpers: read/write len bytes from addr into buff by REG_RD/REG_WR */
    55	static void bnx2x_read_data(struct bnx2x *bp, u32 *buff,
    56					   u32 addr, u32 len)
    57	{
    58		int i;
    59		for (i = 0; i < len; i += 4, buff++)
    60			*buff = REG_RD(bp, addr + i);
    61	}
    62	
    63	static void bnx2x_write_data(struct bnx2x *bp, u32 *buff,
    64					    u32 addr, u32 len)
    65	{
    66		int i;
    67		for (i = 0; i < len; i += 4, buff++)
    68			REG_WR(bp, addr + i, *buff);
    69	}
    70	
    71	static void bnx2x_pfc_set(struct bnx2x *bp)
    72	{
    73		struct bnx2x_nig_brb_pfc_port_params pfc_params = {0};
    74		u32 pri_bit, val = 0;
    75		int i;
    76	
    77		pfc_params.num_of_rx_cos_priority_mask =
    78						bp->dcbx_port_params.ets.num_of_cos;
    79	
    80		/* Tx COS configuration */
    81		for (i = 0; i < bp->dcbx_port_params.ets.num_of_cos; i++)
    82			/*
    83			 * We configure only the pauseable bits (non pauseable aren't
    84			 * configured at all) it's done to avoid false pauses from
    85			 * network
    86			 */
    87			pfc_params.rx_cos_priority_mask[i] =
    88				bp->dcbx_port_params.ets.cos_params[i].pri_bitmask
    89					& DCBX_PFC_PRI_PAUSE_MASK(bp);
    90	
    91		/*
    92		 * Rx COS configuration
    93		 * Changing PFC RX configuration .
    94		 * In RX COS0 will always be configured to lossless and COS1 to lossy
    95		 */
    96		for (i = 0 ; i < MAX_PFC_PRIORITIES ; i++) {
    97			pri_bit = 1 << i;
    98	
    99			if (!(pri_bit & DCBX_PFC_PRI_PAUSE_MASK(bp)))
   100				val |= 1 << (i * 4);
   101		}
   102	
   103		pfc_params.pkt_priority_to_cos = val;
   104	
   105		/* RX COS0 */
   106		pfc_params.llfc_low_priority_classes = DCBX_PFC_PRI_PAUSE_MASK(bp);
   107		/* RX COS1 */
   108		pfc_params.llfc_high_priority_classes = 0;
   109	
   110		bnx2x_acquire_phy_lock(bp);
   111		bp->link_params.feature_config_flags |= FEATURE_CONFIG_PFC_ENABLED;
   112		bnx2x_update_pfc(&bp->link_params, &bp->link_vars, &pfc_params);
   113		bnx2x_release_phy_lock(bp);
   114	}
   115	
   116	static void bnx2x_pfc_clear(struct bnx2x *bp)
   117	{
   118		struct bnx2x_nig_brb_pfc_port_params nig_params = {0};
   119		nig_params.pause_enable = 1;
   120		bnx2x_acquire_phy_lock(bp);
   121		bp->link_params.feature_config_flags &= ~FEATURE_CONFIG_PFC_ENABLED;
   122		bnx2x_update_pfc(&bp->link_params, &bp->link_vars, &nig_params);
   123		bnx2x_release_phy_lock(bp);
   124	}
   125	
   126	static void  bnx2x_dump_dcbx_drv_param(struct bnx2x *bp,
   127					       struct dcbx_features *features,
   128					       u32 error)
   129	{
   130		u8 i = 0;
   131		DP(NETIF_MSG_LINK, "local_mib.error %x\n", error);
   132	
   133		/* PG */
   134		DP(NETIF_MSG_LINK,
   135		   "local_mib.features.ets.enabled %x\n", features->ets.enabled);
   136		for (i = 0; i < DCBX_MAX_NUM_PG_BW_ENTRIES; i++)
   137			DP(NETIF_MSG_LINK,
   138			   "local_mib.features.ets.pg_bw_tbl[%d] %d\n", i,
   139			   DCBX_PG_BW_GET(features->ets.pg_bw_tbl, i));
   140		for (i = 0; i < DCBX_MAX_NUM_PRI_PG_ENTRIES; i++)
   141			DP(NETIF_MSG_LINK,
   142			   "local_mib.features.ets.pri_pg_tbl[%d] %d\n", i,
   143			   DCBX_PRI_PG_GET(features->ets.pri_pg_tbl, i));
   144	
   145		/* pfc */
   146		DP(BNX2X_MSG_DCB, "dcbx_features.pfc.pri_en_bitmap %x\n",
   147						features->pfc.pri_en_bitmap);
   148		DP(BNX2X_MSG_DCB, "dcbx_features.pfc.pfc_caps %x\n",
   149						features->pfc.pfc_caps);
   150		DP(BNX2X_MSG_DCB, "dcbx_features.pfc.enabled %x\n",
   151						features->pfc.enabled);
   152	
   153		DP(BNX2X_MSG_DCB, "dcbx_features.app.default_pri %x\n",
   154						features->app.default_pri);
   155		DP(BNX2X_MSG_DCB, "dcbx_features.app.tc_supported %x\n",
   156						features->app.tc_supported);
   157		DP(BNX2X_MSG_DCB, "dcbx_features.app.enabled %x\n",
   158						features->app.enabled);
   159		for (i = 0; i < DCBX_MAX_APP_PROTOCOL; i++) {
   160			DP(BNX2X_MSG_DCB,
   161			   "dcbx_features.app.app_pri_tbl[%x].app_id %x\n",
   162			   i, features->app.app_pri_tbl[i].app_id);
   163			DP(BNX2X_MSG_DCB,
   164			   "dcbx_features.app.app_pri_tbl[%x].pri_bitmap %x\n",
   165			   i, features->app.app_pri_tbl[i].pri_bitmap);
   166			DP(BNX2X_MSG_DCB,
   167			   "dcbx_features.app.app_pri_tbl[%x].appBitfield %x\n",
   168			   i, features->app.app_pri_tbl[i].appBitfield);
   169		}
   170	}
   171	
   172	static void bnx2x_dcbx_get_ap_priority(struct bnx2x *bp,
   173					       u8 pri_bitmap,
   174					       u8 llfc_traf_type)
   175	{
   176		u32 pri = MAX_PFC_PRIORITIES;
   177		u32 index = MAX_PFC_PRIORITIES - 1;
   178		u32 pri_mask;
   179		u32 *ttp = bp->dcbx_port_params.app.traffic_type_priority;
   180	
   181		/* Choose the highest priority */
   182		while ((MAX_PFC_PRIORITIES == pri) && (0 != index)) {
   183			pri_mask = 1 << index;
   184			if (GET_FLAGS(pri_bitmap, pri_mask))
   185				pri = index ;
   186			index--;
   187		}
   188	
   189		if (pri < MAX_PFC_PRIORITIES)
   190			ttp[llfc_traf_type] = max_t(u32, ttp[llfc_traf_type], pri);
   191	}
   192	
   193	static void bnx2x_dcbx_get_ap_feature(struct bnx2x *bp,
   194					   struct dcbx_app_priority_feature *app,
   195					   u32 error) {
   196		u8 index;
   197		u32 *ttp = bp->dcbx_port_params.app.traffic_type_priority;
   198		u8 iscsi_pri_found = 0, fcoe_pri_found = 0;
   199	
   200		if (GET_FLAGS(error, DCBX_LOCAL_APP_ERROR))
   201			DP(BNX2X_MSG_DCB, "DCBX_LOCAL_APP_ERROR\n");
   202	
   203		if (GET_FLAGS(error, DCBX_LOCAL_APP_MISMATCH))
   204			DP(BNX2X_MSG_DCB, "DCBX_LOCAL_APP_MISMATCH\n");
   205	
   206		if (GET_FLAGS(error, DCBX_REMOTE_APP_TLV_NOT_FOUND))
   207			DP(BNX2X_MSG_DCB, "DCBX_REMOTE_APP_TLV_NOT_FOUND\n");
   208		if (app->enabled &&
   209		    !GET_FLAGS(error, DCBX_LOCAL_APP_ERROR | DCBX_LOCAL_APP_MISMATCH |
   210				      DCBX_REMOTE_APP_TLV_NOT_FOUND)) {
   211	
   212			bp->dcbx_port_params.app.enabled = true;
   213	
   214			/* Use 0 as the default application priority for all. */
   215			for (index = 0 ; index < LLFC_DRIVER_TRAFFIC_TYPE_MAX; index++)
   216				ttp[index] = 0;
   217	
   218			for (index = 0 ; index < DCBX_MAX_APP_PROTOCOL; index++) {
   219				struct dcbx_app_priority_entry *entry =
   220								app->app_pri_tbl;
   221				enum traffic_type type = MAX_TRAFFIC_TYPE;
   222	
   223				if (GET_FLAGS(entry[index].appBitfield,
 > 224					      DCBX_APP_SF_DEFAULT) &&
   225				    GET_FLAGS(entry[index].appBitfield,
   226					      DCBX_APP_SF_ETH_TYPE)) {
   227					type = LLFC_TRAFFIC_TYPE_NW;

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--W/nzBZO5zC0uMSeA
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--W/nzBZO5zC0uMSeA--
