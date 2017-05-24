From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH 3/4] [next-queue]net: i40e: Enable
 mqprio full offload mode in the i40e driver for configuring TCs and queue mapping
Date: Wed, 24 May 2017 15:05:37 -0700
Message-ID: <CAKgT0UfVuVG4JRqHAg5iY5ZLKkYD+L0jtfHNN+uRW7kYm_1P_g@mail.gmail.com>
References: <149524122523.11022.4541073724650541658.stgit@anamdev.jf.intel.com>
 <149524191318.11022.8959648104747338042.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>
To: Amritha Nambiar <amritha.nambiar@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34716 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161305AbdEXWFi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 18:05:38 -0400
Received: by mail-io0-f196.google.com with SMTP id 12so19416128iol.1
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 15:05:38 -0700 (PDT)
In-Reply-To: <149524191318.11022.8959648104747338042.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 19, 2017 at 5:58 PM, Amritha Nambiar
<amritha.nambiar@intel.com> wrote:
> The i40e driver is modified to enable the new mqprio hardware
> offload mode and factor the TCs and queue configuration by
> creating channel VSIs. In this mode, the priority to traffic
> class mapping and the user specified queue ranges are used
> to configure the traffic classes when the 'hw' option is set
> to 2.
>
> Example:
> # tc qdisc add dev eth0 root mqprio num_tc 4\
>   map 0 0 0 0 1 2 2 3 queues 2@0 2@2 1@4 1@5 hw 2
>
> # tc qdisc show dev eth0
> qdisc mqprio 8038: root  tc 4 map 0 0 0 0 1 2 2 3 0 0 0 0 0 0 0 0
>              queues:(0:1) (2:3) (4:4) (5:5)
>
> The HW channels created are removed and all the queue configuration
> is set to default when the qdisc is detached from the root of the
> device.
>
> #tc qdisc del dev eth0 root
>
> This patch also disables setting up channels via ethtool (ethtool -L)
> when the TCs are confgured using mqprio scheduler.
>
> Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e.h         |    4
>  drivers/net/ethernet/intel/i40e/i40e_ethtool.c |    6
>  drivers/net/ethernet/intel/i40e/i40e_main.c    |  311 ++++++++++++++++++++++--
>  3 files changed, 292 insertions(+), 29 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
> index 0915b02..a62f65a 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e.h
> +++ b/drivers/net/ethernet/intel/i40e/i40e.h
> @@ -54,6 +54,8 @@
>  #include <linux/clocksource.h>
>  #include <linux/net_tstamp.h>
>  #include <linux/ptp_clock_kernel.h>
> +#include <net/pkt_cls.h>
> +
>  #include "i40e_type.h"
>  #include "i40e_prototype.h"
>  #include "i40e_client.h"
> @@ -685,6 +687,7 @@ struct i40e_vsi {
>         enum i40e_vsi_type type;  /* VSI type, e.g., LAN, FCoE, etc */
>         s16 vf_id;              /* Virtual function ID for SRIOV VSIs */
>
> +       struct tc_mqprio_qopt_offload mqprio_qopt; /* queue parameters */
>         struct i40e_tc_configuration tc_config;
>         struct i40e_aqc_vsi_properties_data info;
>
> @@ -710,6 +713,7 @@ struct i40e_vsi {
>         u16 cnt_q_avail; /* num of queues available for channel usage */
>         u16 orig_rss_size;
>         u16 current_rss_size;
> +       bool reconfig_rss;
>
>         /* keeps track of next_base_queue to be used for channel setup */
>         atomic_t next_base_queue;
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> index 3d58762..ab52979 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> @@ -3841,6 +3841,12 @@ static int i40e_set_channels(struct net_device *dev,
>         if (vsi->type != I40E_VSI_MAIN)
>                 return -EINVAL;
>
> +       /* We do not support setting channels via ethtool when TCs are
> +        * configured through mqprio
> +        */
> +       if (pf->flags & I40E_FLAG_TC_MQPRIO)
> +               return -EINVAL;
> +
>         /* verify they are not requesting separate vectors */
>         if (!count || ch->rx_count || ch->tx_count)
>                 return -EINVAL;
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index e1bea45..7f61d4f 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -68,6 +68,7 @@ static int i40e_reset(struct i40e_pf *pf);
>  static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired);
>  static void i40e_fdir_sb_setup(struct i40e_pf *pf);
>  static int i40e_veb_get_bw_info(struct i40e_veb *veb);
> +static int i40e_vsi_config_rss(struct i40e_vsi *vsi);
>
>  /* i40e_pci_tbl - PCI Device ID Table
>   *
> @@ -1560,6 +1561,105 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
>  }
>
>  /**
> + * i40e_vsi_setup_queue_map_mqprio - Prepares VSI tc_config to have queue
> + * configurations based on MQPRIO options.
> + * @vsi: the VSI being configured,
> + * @ctxt: VSI context structure
> + * @enabled_tc: number of traffic classes to enable
> + **/
> +static int i40e_vsi_setup_queue_map_mqprio(struct i40e_vsi *vsi,
> +                                          struct i40e_vsi_context *ctxt,
> +                                          u8 enabled_tc)
> +{
> +       u8 netdev_tc = 0, offset = 0;
> +       u16 qcount = 0, max_qcount, qmap, sections = 0;
> +       int i, override_q, pow, num_qps, ret;
> +
> +       if (vsi->type != I40E_VSI_MAIN)
> +               return -EINVAL;
> +
> +       sections = I40E_AQ_VSI_PROP_QUEUE_MAP_VALID;
> +       sections |= I40E_AQ_VSI_PROP_SCHED_VALID;
> +
> +       vsi->tc_config.numtc = vsi->mqprio_qopt.qopt.num_tc;
> +       vsi->tc_config.enabled_tc = enabled_tc ? enabled_tc : 1;
> +
> +       num_qps = vsi->mqprio_qopt.qopt.count[0];
> +
> +       /* find the next higher power-of-2 of num queue pairs */
> +       pow = ilog2(num_qps);
> +       if (!is_power_of_2(num_qps))
> +               pow++;
> +
> +       qmap = (offset << I40E_AQ_VSI_TC_QUE_OFFSET_SHIFT) |
> +               (pow << I40E_AQ_VSI_TC_QUE_NUMBER_SHIFT);
> +
> +       /* Setup queue offset/count for all TCs for given VSI */
> +       max_qcount = vsi->mqprio_qopt.qopt.count[0];
> +
> +       for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
> +               /* See if the given TC is enabled for the given VSI */
> +               if (vsi->tc_config.enabled_tc & BIT(i)) {
> +                       offset = vsi->mqprio_qopt.qopt.offset[i];
> +                       qcount = vsi->mqprio_qopt.qopt.count[i];
> +
> +                       if (qcount > max_qcount)
> +                               max_qcount = qcount;
> +
> +                       vsi->tc_config.tc_info[i].qoffset = offset;
> +                       vsi->tc_config.tc_info[i].qcount = qcount;
> +                       vsi->tc_config.tc_info[i].netdev_tc = netdev_tc++;
> +
> +               } else {
> +                       /* TC is not enabled so set the offset to
> +                        * default queue and allocate one queue
> +                        * for the given TC.
> +                        */
> +                       vsi->tc_config.tc_info[i].qoffset = 0;
> +                       vsi->tc_config.tc_info[i].qcount = 1;
> +                       vsi->tc_config.tc_info[i].netdev_tc = 0;
> +               }
> +       }
> +
> +       /* Set actual Tx/Rx queue pairs */
> +       vsi->num_queue_pairs = offset + qcount;
> +
> +       /* Setup queue TC[0].qmap for given VSI context */
> +       ctxt->info.tc_mapping[0] = cpu_to_le16(qmap);
> +
> +       ctxt->info.mapping_flags |=
> +                                       cpu_to_le16(I40E_AQ_VSI_QUE_MAP_CONTIG);
> +
> +       ctxt->info.queue_mapping[0] = cpu_to_le16(vsi->base_queue);
> +       ctxt->info.valid_sections |= cpu_to_le16(sections);
> +
> +       /* Reconfigure RSS for main VSI with max queue count */
> +       vsi->rss_size = max_qcount;
> +
> +       ret = i40e_vsi_config_rss(vsi);
> +       if (ret) {
> +               dev_info(&vsi->back->pdev->dev,
> +                        "Failed to reconfig rss for num_queues (%u)\n",
> +                        max_qcount);
> +               return ret;
> +       }
> +       vsi->reconfig_rss = true;
> +       dev_dbg(&vsi->back->pdev->dev,
> +               "Reconfigured rss with num_queues (%u)\n", max_qcount);
> +
> +       /* Find queue count available for channel VSIs and starting offset
> +        * for channel VSIs
> +        */
> +       override_q = vsi->mqprio_qopt.qopt.count[0];
> +       if (override_q && (override_q < vsi->num_queue_pairs)) {
> +               vsi->cnt_q_avail = vsi->num_queue_pairs - override_q;
> +               atomic_set(&vsi->next_base_queue, override_q);
> +       }
> +
> +       return 0;
> +}
> +
> +/**
>   * i40e_vsi_setup_queue_map - Setup a VSI queue map based on enabled_tc
>   * @vsi: the VSI being setup
>   * @ctxt: VSI context structure
> @@ -1597,7 +1697,7 @@ static void i40e_vsi_setup_queue_map(struct i40e_vsi *vsi,
>                         numtc = 1;
>                 }
>         } else {
> -               /* At least TC0 is enabled in case of non-DCB case */
> +               /* At least TC0 is enabled in non-DCB, non-MQPRIO case */
>                 numtc = 1;
>         }
>
> @@ -3150,6 +3250,7 @@ static void i40e_vsi_config_dcb_rings(struct i40e_vsi *vsi)
>                         rx_ring->dcb_tc = 0;
>                         tx_ring->dcb_tc = 0;
>                 }
> +               return;
>         }
>
>         for (n = 0; n < I40E_MAX_TRAFFIC_CLASS; n++) {
> @@ -4777,6 +4878,25 @@ static u8 i40e_dcb_get_enabled_tc(struct i40e_dcbx_config *dcbcfg)
>  }
>
>  /**
> + * i40e_mqprio_get_enabled_tc - Get enabled traffic classes
> + * @pf: PF being queried
> + *
> + * Query the current MQPRIO configuration and return the number of
> + * traffic classes enabled.
> + **/
> +static u8 i40e_mqprio_get_enabled_tc(struct i40e_pf *pf)
> +{
> +       struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
> +       u8 num_tc = vsi->mqprio_qopt.qopt.num_tc;
> +       u8 enabled_tc = 1, i;
> +
> +       for (i = 1; i < num_tc; i++)
> +               enabled_tc |= BIT(i);
> +
> +       return enabled_tc;
> +}
> +
> +/**
>   * i40e_pf_get_num_tc - Get enabled traffic classes for PF
>   * @pf: PF being queried
>   *
> @@ -4789,7 +4909,10 @@ static u8 i40e_pf_get_num_tc(struct i40e_pf *pf)
>         u8 num_tc = 0;
>         struct i40e_dcbx_config *dcbcfg = &hw->local_dcbx_config;
>
> -       /* If DCB is not enabled then always in single TC */
> +       if (pf->flags & I40E_FLAG_TC_MQPRIO)
> +               return pf->vsi[pf->lan_vsi]->mqprio_qopt.qopt.num_tc;
> +
> +       /* If neither MQPRIO nor DCB is enabled, then always in single TC */
>         if (!(pf->flags & I40E_FLAG_DCB_ENABLED))
>                 return 1;
>
> @@ -4818,7 +4941,12 @@ static u8 i40e_pf_get_num_tc(struct i40e_pf *pf)
>   **/
>  static u8 i40e_pf_get_tc_map(struct i40e_pf *pf)
>  {
> -       /* If DCB is not enabled for this PF then just return default TC */
> +       if (pf->flags & I40E_FLAG_TC_MQPRIO)
> +               return i40e_mqprio_get_enabled_tc(pf);
> +
> +       /* If neither MQPRIO nor DCB is enabled for this PF then just return
> +        * default TC
> +        */
>         if (!(pf->flags & I40E_FLAG_DCB_ENABLED))
>                 return I40E_DEFAULT_TRAFFIC_CLASS;
>
> @@ -4912,6 +5040,10 @@ static int i40e_vsi_configure_bw_alloc(struct i40e_vsi *vsi, u8 enabled_tc,
>         for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++)
>                 bw_data.tc_bw_credits[i] = bw_share[i];
>
> +       if ((vsi->back->flags & I40E_FLAG_TC_MQPRIO) ||
> +           !vsi->mqprio_qopt.qopt.hw)
> +               return 0;
> +
>         ret = i40e_aq_config_vsi_tc_bw(&vsi->back->hw, vsi->seid, &bw_data,
>                                        NULL);
>         if (ret) {
> @@ -4970,6 +5102,9 @@ static void i40e_vsi_config_netdev_tc(struct i40e_vsi *vsi, u8 enabled_tc)
>                                         vsi->tc_config.tc_info[i].qoffset);
>         }
>
> +       if (pf->flags & I40E_FLAG_TC_MQPRIO)
> +               return;
> +
>         /* Assign UP2TC map for the VSI */
>         for (i = 0; i < I40E_MAX_USER_PRIORITY; i++) {
>                 /* Get the actual TC# for the UP */
> @@ -5020,7 +5155,8 @@ static int i40e_vsi_config_tc(struct i40e_vsi *vsi, u8 enabled_tc)
>         int i;
>
>         /* Check if enabled_tc is same as existing or new TCs */
> -       if (vsi->tc_config.enabled_tc == enabled_tc)
> +       if (vsi->tc_config.enabled_tc == enabled_tc &&
> +           vsi->mqprio_qopt.qopt.hw != TC_MQPRIO_HW_OFFLOAD)
>                 return ret;
>
>         /* Enable ETS TCs with equal BW Share for now across all VSIs */
> @@ -5043,7 +5179,30 @@ static int i40e_vsi_config_tc(struct i40e_vsi *vsi, u8 enabled_tc)
>         ctxt.vf_num = 0;
>         ctxt.uplink_seid = vsi->uplink_seid;
>         ctxt.info = vsi->info;
> -       i40e_vsi_setup_queue_map(vsi, &ctxt, enabled_tc, false);
> +
> +       if (vsi->back->flags & I40E_FLAG_TC_MQPRIO) {
> +               ret = i40e_vsi_setup_queue_map_mqprio(vsi, &ctxt, enabled_tc);
> +               if (ret)
> +                       goto out;
> +
> +       } else {
> +               i40e_vsi_setup_queue_map(vsi, &ctxt, enabled_tc, false);
> +       }
> +
> +       /* On destroying the qdisc, reset vsi->rss_size, as number of enabled
> +        * queues changed.
> +        */
> +       if (!vsi->mqprio_qopt.qopt.hw && vsi->reconfig_rss) {
> +               vsi->rss_size = min_t(int, vsi->back->alloc_rss_size,
> +                                     vsi->num_queue_pairs);
> +               ret = i40e_vsi_config_rss(vsi);
> +               if (ret) {
> +                       dev_info(&vsi->back->pdev->dev,
> +                                "Failed to reconfig rss for num_queues\n");
> +                       return ret;
> +               }
> +               vsi->reconfig_rss = false;
> +       }
>
>         if (vsi->back->flags & I40E_FLAG_IWARP_ENABLED) {
>                 ctxt.info.valid_sections |=
> @@ -5051,7 +5210,9 @@ static int i40e_vsi_config_tc(struct i40e_vsi *vsi, u8 enabled_tc)
>                 ctxt.info.queueing_opt_flags |= I40E_AQ_VSI_QUE_OPT_TCP_ENA;
>         }
>
> -       /* Update the VSI after updating the VSI queue-mapping information */
> +       /* Update the VSI after updating the VSI queue-mapping
> +        * information
> +        */
>         ret = i40e_aq_update_vsi_params(&vsi->back->hw, &ctxt, NULL);
>         if (ret) {
>                 dev_info(&vsi->back->pdev->dev,
> @@ -6168,48 +6329,142 @@ void i40e_down(struct i40e_vsi *vsi)
>  }
>
>  /**
> + * i40e_validate_mqprio_queue_mapping - validate queue mapping info
> + * @vsi: the VSI being configured
> + * @mqprio_qopt: queue parametrs
> + **/
> +int i40e_validate_mqprio_queue_mapping(struct i40e_vsi *vsi,
> +                               struct tc_mqprio_qopt_offload *mqprio_qopt)

So I see a few issues with this. From what I can tell this can be
static. Second is that it is triggering a check in checkpatch for
unaligned parameters.

I would recommend using the gcc coding style if needed so that you
could move the "static int" into a separate line if needed in order to
avoid issues with the line being too long. In addition you might look
at reducing the length of the function name if you still have issues
with being over 80 characters. Maybe something like
i40e_validate_mqprio_qopt instead of calling out the mapping and all
that since it seems like most of this is just about validating the
qopt fields provided in the mqprio_qopt structure anyway.

> +{
> +       int i;
> +
> +       if ((mqprio_qopt->qopt.offset[0] != 0) ||
> +           (mqprio_qopt->qopt.num_tc < 1))
> +               return -EINVAL;
> +
> +       for (i = 0; ; i++) {
> +               if (!mqprio_qopt->qopt.count[i])
> +                       return -EINVAL;
> +
> +               if (mqprio_qopt->min_rate[i] || mqprio_qopt->max_rate[i])
> +                       return -EINVAL;
> +
> +               if (i >= mqprio_qopt->qopt.num_tc - 1)
> +                       break;
> +
> +               if (mqprio_qopt->qopt.offset[i + 1] !=
> +                   (mqprio_qopt->qopt.offset[i] + mqprio_qopt->qopt.count[i]))
> +                       return -EINVAL;
> +       }
> +
> +       if (vsi->num_queue_pairs <
> +           (mqprio_qopt->qopt.offset[i] + mqprio_qopt->qopt.count[i])) {
> +               return -EINVAL;
> +       }
> +
> +       return 0;
> +}
> +
> +/**
>   * i40e_setup_tc - configure multiple traffic classes
>   * @netdev: net device to configure
> - * @tc: number of traffic classes to enable
> + * @tc: pointer to struct tc_to_netdev
>   **/
> -static int i40e_setup_tc(struct net_device *netdev, u8 tc)
> +static int i40e_setup_tc(struct net_device *netdev, struct tc_to_netdev *tc)
>  {
>         struct i40e_netdev_priv *np = netdev_priv(netdev);
>         struct i40e_vsi *vsi = np->vsi;
>         struct i40e_pf *pf = vsi->back;
> -       u8 enabled_tc = 0;
> +       u8 enabled_tc = 0, num_tc = 0, hw = 0;
>         int ret = -EINVAL;
>         int i;
>
> -       /* Check if DCB enabled to continue */
> -       if (!(pf->flags & I40E_FLAG_DCB_ENABLED)) {
> -               netdev_info(netdev, "DCB is not enabled for adapter\n");
> -               goto exit;
> +       if (tc->type == TC_SETUP_MQPRIO) {
> +               hw = tc->mqprio->hw;
> +               num_tc = tc->mqprio->num_tc;
> +       } else if (tc->type == TC_SETUP_MQPRIO_EXT) {
> +               hw = tc->mqprio_qopt->qopt.hw;
> +               num_tc = tc->mqprio_qopt->qopt.num_tc;
>         }
>
> -       /* Check if MFP enabled */
> -       if (pf->flags & I40E_FLAG_MFP_ENABLED) {
> -               netdev_info(netdev, "Configuring TC not supported in MFP mode\n");
> -               goto exit;
> +       if (!hw) {
> +               pf->flags &= ~I40E_FLAG_TC_MQPRIO;
> +               if (tc->type == TC_SETUP_MQPRIO_EXT)
> +                       memcpy(&vsi->mqprio_qopt, tc->mqprio_qopt,
> +                              sizeof(*tc->mqprio_qopt));
> +               goto config_tc;
>         }
>
> -       /* Check whether tc count is within enabled limit */
> -       if (tc > i40e_pf_get_num_tc(pf)) {
> -               netdev_info(netdev, "TC count greater than enabled on link for adapter\n");
> -               goto exit;
> +       switch (hw) {
> +       case TC_MQPRIO_HW_OFFLOAD_TCS:
> +               pf->flags &= ~I40E_FLAG_TC_MQPRIO;
> +               /* Check if DCB enabled to continue */
> +               if (!(pf->flags & I40E_FLAG_DCB_ENABLED)) {
> +                       netdev_info(netdev,
> +                                   "DCB is not enabled for adapter\n");
> +                       goto exit;
> +               }
> +
> +               /* Check if MFP enabled */
> +               if (pf->flags & I40E_FLAG_MFP_ENABLED) {
> +                       netdev_info(netdev,
> +                                   "Configuring TC not supported in MFP mode\n");
> +                       goto exit;
> +               }
> +
> +               /* Check whether tc count is within enabled limit */
> +               if (num_tc > i40e_pf_get_num_tc(pf)) {
> +                       netdev_info(netdev,
> +                                   "TC count greater than enabled on link for adapter\n");
> +                       goto exit;
> +               }
> +               break;
> +       case TC_MQPRIO_HW_OFFLOAD:
> +               if (pf->flags & I40E_FLAG_DCB_ENABLED) {
> +                       netdev_info(netdev,
> +                                   "Full offload of TC Mqprio options is not supported when DCB is enabled\n");
> +                       goto exit;
> +               }
> +
> +               /* Check if MFP enabled */
> +               if (pf->flags & I40E_FLAG_MFP_ENABLED) {
> +                       netdev_info(netdev,
> +                                   "Configuring TC not supported in MFP mode\n");
> +                       goto exit;
> +               }
> +
> +               ret = i40e_validate_mqprio_queue_mapping(vsi,
> +                                                        tc->mqprio_qopt);
> +               if (ret)
> +                       goto exit;
> +
> +               memcpy(&vsi->mqprio_qopt, tc->mqprio_qopt,
> +                      sizeof(*tc->mqprio_qopt));
> +
> +               pf->flags |= I40E_FLAG_TC_MQPRIO;
> +               pf->flags &= ~I40E_FLAG_DCB_ENABLED;
> +
> +               break;
> +       default:
> +               return -EINVAL;
>         }
>
> +config_tc:
>         /* Generate TC map for number of tc requested */
> -       for (i = 0; i < tc; i++)
> +       for (i = 0; i < num_tc; i++)
>                 enabled_tc |= BIT(i);
>
>         /* Requesting same TC configuration as already enabled */
> -       if (enabled_tc == vsi->tc_config.enabled_tc)
> +       if (enabled_tc == vsi->tc_config.enabled_tc &&
> +           hw != TC_MQPRIO_HW_OFFLOAD)
>                 return 0;
>
>         /* Quiesce VSI queues */
>         i40e_quiesce_vsi(vsi);
>
> +       if (!hw && !(pf->flags & I40E_FLAG_TC_MQPRIO))
> +               i40e_remove_queue_channel(vsi);
> +
>         /* Configure VSI for enabled TCs */
>         ret = i40e_vsi_config_tc(vsi, enabled_tc);
>         if (ret) {
> @@ -6229,8 +6484,11 @@ static int i40e_setup_tc(struct net_device *netdev, u8 tc)
>
>         /* Unquiesce VSI */
>         i40e_unquiesce_vsi(vsi);
> +       return ret;
>
>  exit:
> +       /* Reset the configuration data */
> +       memset(&vsi->tc_config, 0, sizeof(vsi->tc_config));
>         i40e_unquiesce_vsi(vsi);
>         return ret;
>  }
> @@ -6238,12 +6496,7 @@ static int i40e_setup_tc(struct net_device *netdev, u8 tc)
>  static int __i40e_setup_tc(struct net_device *netdev, u32 handle, __be16 proto,
>                            struct tc_to_netdev *tc)
>  {
> -       if (tc->type != TC_SETUP_MQPRIO)
> -               return -EINVAL;
> -
> -       tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
> -
> -       return i40e_setup_tc(netdev, tc->mqprio->num_tc);
> +       return i40e_setup_tc(netdev, tc);
>  }
>
>  /**
>
> _______________________________________________
> Intel-wired-lan mailing list
> Intel-wired-lan@osuosl.org
> https://lists.osuosl.org/mailman/listinfo/intel-wired-lan
