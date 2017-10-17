From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [RFC PATCH next 2/2] i40e: add support for
 macvlan hardware offload
Date: Tue, 17 Oct 2017 14:32:33 -0700
Message-ID: <CAKgT0Uft_kCyct==am7W0TGUo-YzUhSVkJir83uGx_XwMuxsHg@mail.gmail.com>
References: <1508275089-430113-1-git-send-email-shannon.nelson@oracle.com> <1508275089-430113-3-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Netdev <netdev@vger.kernel.org>
To: Shannon Nelson <shannon.nelson@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:52675 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934833AbdJQVcf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 17:32:35 -0400
Received: by mail-qt0-f193.google.com with SMTP id 31so6716363qtz.9
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 14:32:34 -0700 (PDT)
In-Reply-To: <1508275089-430113-3-git-send-email-shannon.nelson@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 2:18 PM, Shannon Nelson
<shannon.nelson@oracle.com> wrote:
> This patch adds support for macvlan hardware offload (l2-fwd-offload)
> feature using the XL710's macvlan-to-queue filtering machanism.  These
> are most useful for supporting separate mac addresses for Container
> virtualization using Docker and similar configurations.
>
> The basic design is to partition off some of the PF's general LAN queues
> outside of the standard RSS pool and use them as the offload queues.
> This especially makes sense on machines with more than 64 CPUs: since
> the RSS pool is limited to a maximum of 64, the queues assigned to the
> remaining CPUs essentially go unused.  When on a machine with fewer than
> 64 CPUs, we shrink the RSS pool and use the upper queues for the offload.
>
> If the user has added Flow Director filters, enabling of macvlan offload
> is disallowed.
>
> To use this feature, use ethtool to enable l2-fwd-offload
>         ethtool -K ethX l2-fwd-offload on
> When the next macvlan devices are created on ethX, the macvlan driver
> will automatically attempt to setup the hardweare offload.
>
> Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e.h         |   10 +
>  drivers/net/ethernet/intel/i40e/i40e_ethtool.c |   15 ++
>  drivers/net/ethernet/intel/i40e/i40e_main.c    |  239 +++++++++++++++++++++++-
>  drivers/net/ethernet/intel/i40e/i40e_txrx.h    |    1 +
>  4 files changed, 264 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
> index a187f53..4868ae2 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e.h
> +++ b/drivers/net/ethernet/intel/i40e/i40e.h
> @@ -365,6 +365,10 @@ struct i40e_pf {
>         u8 atr_sample_rate;
>         bool wol_en;
>
> +       u16 macvlan_hint;
> +       u16 macvlan_used;
> +       u16 macvlan_num;
> +
>         struct hlist_head fdir_filter_list;
>         u16 fdir_pf_active_filters;
>         unsigned long fd_flush_timestamp;
> @@ -712,6 +716,12 @@ struct i40e_netdev_priv {
>         struct i40e_vsi *vsi;
>  };
>
> +struct i40e_fwd {
> +       struct net_device *vdev;
> +       u16 tx_base_queue;
> +       /* future expansion here might include number of queues */
> +};
> +
>  /* struct that defines an interrupt vector */
>  struct i40e_q_vector {
>         struct i40e_vsi *vsi;
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> index afd3ca8..e1628c1 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> @@ -3817,6 +3817,13 @@ static int i40e_set_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *cmd)
>         struct i40e_pf *pf = vsi->back;
>         int ret = -EOPNOTSUPP;
>
> +       if (pf->macvlan_num) {
> +               dev_warn(&pf->pdev->dev,
> +                        "Remove %d remaining macvlan offloads to change filter options\n",
> +                        pf->macvlan_used);
> +               return -EBUSY;
> +       }
> +
>         switch (cmd->cmd) {
>         case ETHTOOL_SRXFH:
>                 ret = i40e_set_rss_hash_opt(pf, cmd);
> @@ -3909,6 +3916,14 @@ static int i40e_set_channels(struct net_device *dev,
>         if (count > i40e_max_channels(vsi))
>                 return -EINVAL;
>
> +       /* verify that macvlan offloads are not in use */
> +       if (pf->macvlan_num) {
> +               dev_warn(&pf->pdev->dev,
> +                        "Remove %d remaining macvlan offloads to change channel count\n",
> +                        pf->macvlan_used);
> +               return -EBUSY;
> +       }
> +
>         /* verify that the number of channels does not invalidate any current
>          * flow director rules
>          */
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index e4b8a4b..7b26c6f 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -9221,6 +9221,66 @@ static void i40e_clear_rss_lut(struct i40e_vsi *vsi)
>  }
>
>  /**
> + * i40e_fix_features - fix the proposed netdev feature flags
> + * @netdev: ptr to the netdev being adjusted
> + * @features: the feature set that the stack is suggesting
> + * Note: expects to be called while under rtnl_lock()
> + **/
> +static netdev_features_t i40e_fix_features(struct net_device *netdev,
> +                                          netdev_features_t features)
> +{
> +       struct i40e_netdev_priv *np = netdev_priv(netdev);
> +       struct i40e_pf *pf = np->vsi->back;
> +       struct i40e_vsi *vsi = np->vsi;
> +
> +       /* make sure there are queues to be used for macvlan offload */
> +       if (features & NETIF_F_HW_L2FW_DOFFLOAD &&
> +           !(netdev->features & NETIF_F_HW_L2FW_DOFFLOAD)) {
> +               const u8 drop = I40E_FILTER_PROGRAM_DESC_DEST_DROP_PACKET;
> +               struct i40e_fdir_filter *rule;
> +               struct hlist_node *node2;
> +               u16 rss, unused;
> +
> +               /* Find a set of queues to be used for macvlan offload.
> +                * If there aren't many queues outside of the RSS set
> +                * that could be used for macvlan, try shrinking the
> +                * set to free up some queues, after checking if there
> +                * are any Flow Director rules we might break.
> +                */
> +
> +               rss = vsi->rss_size;
> +               unused = vsi->num_queue_pairs - rss;
> +               if (unused < (vsi->rss_size / 2)) {
> +                       rss = vsi->rss_size / 2;
> +                       unused = vsi->num_q_vectors - rss;
> +               }
> +               pf->macvlan_num = unused;
> +
> +               /* check the flow director rules */
> +               hlist_for_each_entry_safe(rule, node2,
> +                                         &pf->fdir_filter_list, fdir_node) {
> +                       if (rule->dest_ctl != drop && rss <= rule->q_index) {
> +                               dev_warn(&pf->pdev->dev,
> +                                        "Remove user defined filter %d to enable macvlan offload\n",
> +                                        rule->fd_id);
> +                               features &= ~NETIF_F_HW_L2FW_DOFFLOAD;
> +                               pf->macvlan_num = 0;
> +                       }
> +               }
> +       } else if (!(features & NETIF_F_HW_L2FW_DOFFLOAD) &&
> +                   netdev->features & NETIF_F_HW_L2FW_DOFFLOAD) {
> +               if (pf->macvlan_used) {
> +                       dev_warn(&pf->pdev->dev,
> +                                "Remove %d remaining macvlan offloads to disable macvlan offload\n",
> +                                pf->macvlan_used);
> +                       features |= NETIF_F_HW_L2FW_DOFFLOAD;
> +               }
> +       }
> +
> +       return features;
> +}
> +
> +/**
>   * i40e_set_features - set the netdev feature flags
>   * @netdev: ptr to the netdev being adjusted
>   * @features: the feature set that the stack is suggesting
> @@ -9247,6 +9307,45 @@ static int i40e_set_features(struct net_device *netdev,
>
>         need_reset = i40e_set_ntuple(pf, features);
>
> +       /* keep this section last in this function as it
> +        * might take care of the need_reset for the others
> +        */
> +       if (features & NETIF_F_HW_L2FW_DOFFLOAD &&
> +           !(netdev->features & NETIF_F_HW_L2FW_DOFFLOAD)) {
> +               /* reserve queues for macvlan use */
> +               u16 rss = vsi->num_q_vectors - pf->macvlan_num;
> +
> +               if (rss != vsi->rss_size) {
> +                       if (i40e_reconfig_rss_queues(pf, rss))
> +                               need_reset = false;
> +               }
> +
> +               pf->macvlan_hint = rss;
> +               pf->macvlan_used = 0;
> +
> +       } else if (!(features & NETIF_F_HW_L2FW_DOFFLOAD) &&
> +                   netdev->features & NETIF_F_HW_L2FW_DOFFLOAD) {
> +               /* return macvlan queues to general use */
> +               int num_qs = vsi->rss_size + pf->macvlan_num;
> +               int i;
> +
> +               /* stop the upperdev queues if not already stopped */
> +               for (i = vsi->rss_size; i < num_qs; i++) {
> +                       struct i40e_fwd *fwd = vsi->tx_rings[i]->fwd;
> +
> +                       if (fwd)
> +                               netif_tx_stop_all_queues(fwd->vdev);
> +               }
> +
> +               /* rebuild the rss layout with the restored queues */
> +               if (i40e_reconfig_rss_queues(pf, num_qs))
> +                       need_reset = false;
> +
> +               pf->macvlan_hint = 0;
> +               pf->macvlan_used = 0;
> +               pf->macvlan_num = 0;
> +       }
> +
>         if (need_reset)
>                 i40e_do_reset(pf, BIT_ULL(__I40E_PF_RESET_REQUESTED), true);
>
> @@ -9674,6 +9773,137 @@ static int i40e_xdp(struct net_device *dev,
>         }
>  }
>
> +/**
> + * i40e_select_queue - select the Tx queue, watching for macvlan offloads
> + * @dev: netdevice
> + * @skb: packet to be sent
> + * @accel_priv: hint for offloading macvlan
> + * @fallback: alternative function to use if we don't care which Tx
> + **/
> +static u16 i40e_select_queue(struct net_device *dev, struct sk_buff *skb,
> +                            void *accel_priv, select_queue_fallback_t fallback)
> +{
> +       struct i40e_fwd *fwd = accel_priv;
> +
> +       if (fwd)
> +               return fwd->tx_base_queue;
> +
> +       return fallback(dev, skb);
> +}
> +

So the select_queue function being needed is the deal breaker on all
of this as far as I am concerned. We aren't allowed to use it under
other cases so why should macvlan be an exception to the rule?

I think we should probably look at a different approach for this. For
example why is it we need to use a different transmit path for a
macvlan packet vs any other packet? On the Rx side we get the
advantage of avoiding the software hashing and demux. What do we get
for reserving queues for transmit?

My plan for this is to go back and "fix" ixgbe so we can get it away
from having to use the select_queue call for the macvlan offload and
then maybe look at proving a few select NDO operations for allowing
macvlans that are being offloaded to make specific calls into the
hardware to perform tasks as needed.

- Alex
