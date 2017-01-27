From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 1/4] mlx5: Make building eswitch configurable
Date: Fri, 27 Jan 2017 10:33:00 -0800
Message-ID: <CALx6S378XJXTku5t2dtWLLCTVDCqiPeVx8si+SPa98E9fYZ=PQ@mail.gmail.com>
References: <20170126233241.2268449-1-tom@herbertland.com> <20170126233241.2268449-2-tom@herbertland.com>
 <CALzJLG-=Mzm+ko-=Ycu2vE6kdvX9zGF5XAP+z4hRv6sgX3G__w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36270 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750710AbdA0Sls (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 13:41:48 -0500
Received: by mail-qt0-f193.google.com with SMTP id h53so11376723qth.3
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 10:41:48 -0800 (PST)
In-Reply-To: <CALzJLG-=Mzm+ko-=Ycu2vE6kdvX9zGF5XAP+z4hRv6sgX3G__w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2017 at 10:19 AM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:
> On Fri, Jan 27, 2017 at 1:32 AM, Tom Herbert <tom@herbertland.com> wrote:
>> Add a configuration option (CONFIG_MLX5_CORE_ESWITCH) for controlling
>> whether the eswitch code is built. Change Kconfig and Makefile
>> accordingly.
>>
>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>> ---
>>  drivers/net/ethernet/mellanox/mlx5/core/Kconfig   | 11 +++
>>  drivers/net/ethernet/mellanox/mlx5/core/Makefile  |  6 +-
>>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 92 +++++++++++++++++------
>>  drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   | 39 +++++++---
>>  drivers/net/ethernet/mellanox/mlx5/core/eq.c      |  4 +-
>>  drivers/net/ethernet/mellanox/mlx5/core/main.c    | 16 ++--
>>  drivers/net/ethernet/mellanox/mlx5/core/sriov.c   |  6 +-
>>  7 files changed, 125 insertions(+), 49 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
>> index ddb4ca4..27aae58 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
>> @@ -30,3 +30,14 @@ config MLX5_CORE_EN_DCB
>>           This flag is depended on the kernel's DCB support.
>>
>>           If unsure, set to Y
>> +
>> +config MLX5_CORE_EN_ESWITCH
>> +       bool "Ethernet switch"
>> +       default y
>> +       depends on MLX5_CORE_EN
>> +       ---help---
>> +         Say Y here if you want to use Ethernet switch (E-switch). E-Switch
>> +         is the software entity that represents and manages ConnectX4
>> +         inter-HCA ethernet l2 switching.
>> +
>> +         If unsure, set to Y
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
>> index 9f43beb..17025d8 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
>> @@ -5,9 +5,11 @@ mlx5_core-y := main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
>>                 mad.o transobj.o vport.o sriov.o fs_cmd.o fs_core.o \
>>                 fs_counters.o rl.o lag.o dev.o
>>
>> -mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o eswitch_offloads.o \
>> +mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o \
>>                 en_main.o en_common.o en_fs.o en_ethtool.o en_tx.o \
>>                 en_rx.o en_rx_am.o en_txrx.o en_clock.o vxlan.o \
>> -               en_tc.o en_arfs.o en_rep.o en_fs_ethtool.o en_selftest.o
>> +               en_tc.o en_arfs.o en_fs_ethtool.o en_selftest.o
>>
>>  mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
>> +
>> +mlx5_core-$(CONFIG_MLX5_CORE_EN_ESWITCH) += eswitch.o eswitch_offloads.o en_rep.o
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>> index e829143..1db4d98 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>> @@ -38,7 +38,9 @@
>>  #include <linux/bpf.h>
>>  #include "en.h"
>>  #include "en_tc.h"
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>  #include "eswitch.h"
>> +#endif
>
> Wouldn't it be cleaner if we left the main code (en_main.c) untouched
> and kept this
> #include "eswitch.h" and instead of filling the main flow code with
> #ifdefs, in eswitch.h
> we can create eswitch mock API functions when
> CONFIG_MLX5_CORE_EN_ESWITCH is not enabled ? the main flow will be
> clean from ifdefs and will complie with mock functions.
>
> we did this with accelerated RFS feature. look for "#ifndef
> CONFIG_RFS_ACCEL" in en.h
>
There are still occurrences of CONFIG_RFS_ACCEL in en_main.c and
main.c. For eswitch its a header problem, not everything related to
eswitch was extracted out of main though backend functions. There is a
lot of code that related to eswitch that is intertwined with the core
code.

>>  #include "vxlan.h"
>>
>>  struct mlx5e_rq_param {
>> @@ -585,10 +587,12 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
>>
>>         switch (priv->params.rq_wq_type) {
>>         case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>                 if (mlx5e_is_vf_vport_rep(priv)) {
>>                         err = -EINVAL;
>>                         goto err_rq_wq_destroy;
>>                 }
>> +#endif
>>
>>                 rq->handle_rx_cqe = mlx5e_handle_rx_cqe_mpwrq;
>>                 rq->alloc_wqe = mlx5e_alloc_rx_mpwqe;
>> @@ -617,10 +621,14 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
>>                         goto err_rq_wq_destroy;
>>                 }
>>
>> -               if (mlx5e_is_vf_vport_rep(priv))
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>> +               if (mlx5e_is_vf_vport_rep(priv)) {
>>                         rq->handle_rx_cqe = mlx5e_handle_rx_cqe_rep;
>> -               else
>> +               } else
>> +#endif
>> +               {
>>                         rq->handle_rx_cqe = mlx5e_handle_rx_cqe;
>> +               }
>>
>>                 rq->alloc_wqe = mlx5e_alloc_rx_wqe;
>>                 rq->dealloc_wqe = mlx5e_dealloc_rx_wqe;
>> @@ -2198,7 +2206,6 @@ static void mlx5e_netdev_set_tcs(struct net_device *netdev)
>>  int mlx5e_open_locked(struct net_device *netdev)
>>  {
>>         struct mlx5e_priv *priv = netdev_priv(netdev);
>> -       struct mlx5_core_dev *mdev = priv->mdev;
>>         int num_txqs;
>>         int err;
>>
>> @@ -2233,11 +2240,13 @@ int mlx5e_open_locked(struct net_device *netdev)
>>         if (priv->profile->update_stats)
>>                 queue_delayed_work(priv->wq, &priv->update_stats_work, 0);
>>
>> -       if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>> +       if (MLX5_CAP_GEN(priv->mdev, vport_group_manager)) {
>>                 err = mlx5e_add_sqs_fwd_rules(priv);
>>                 if (err)
>>                         goto err_close_channels;
>>         }
>> +#endif
>>         return 0;
>>
>>  err_close_channels:
>> @@ -2262,7 +2271,6 @@ int mlx5e_open(struct net_device *netdev)
>>  int mlx5e_close_locked(struct net_device *netdev)
>>  {
>>         struct mlx5e_priv *priv = netdev_priv(netdev);
>> -       struct mlx5_core_dev *mdev = priv->mdev;
>>
>>         /* May already be CLOSED in case a previous configuration operation
>>          * (e.g RX/TX queue size change) that involves close&open failed.
>> @@ -2272,8 +2280,10 @@ int mlx5e_close_locked(struct net_device *netdev)
>>
>>         clear_bit(MLX5E_STATE_OPENED, &priv->state);
>>
>> -       if (MLX5_CAP_GEN(mdev, vport_group_manager))
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>> +       if (MLX5_CAP_GEN(priv->mdev, vport_group_manager))
>>                 mlx5e_remove_sqs_fwd_rules(priv);
>> +#endif
>>
>>         mlx5e_timestamp_cleanup(priv);
>>         netif_carrier_off(priv->netdev);
>> @@ -2742,12 +2752,15 @@ mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
>>         struct mlx5e_vport_stats *vstats = &priv->stats.vport;
>>         struct mlx5e_pport_stats *pstats = &priv->stats.pport;
>>
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>         if (mlx5e_is_uplink_rep(priv)) {
>>                 stats->rx_packets = PPORT_802_3_GET(pstats, a_frames_received_ok);
>>                 stats->rx_bytes   = PPORT_802_3_GET(pstats, a_octets_received_ok);
>>                 stats->tx_packets = PPORT_802_3_GET(pstats, a_frames_transmitted_ok);
>>                 stats->tx_bytes   = PPORT_802_3_GET(pstats, a_octets_transmitted_ok);
>> -       } else {
>> +       } else
>> +#endif
>> +       {
>>                 stats->rx_packets = sstats->rx_packets;
>>                 stats->rx_bytes   = sstats->rx_bytes;
>>                 stats->tx_packets = sstats->tx_packets;
>> @@ -2991,6 +3004,7 @@ static int mlx5e_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>>         }
>>  }
>>
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>  static int mlx5e_set_vf_mac(struct net_device *dev, int vf, u8 *mac)
>>  {
>>         struct mlx5e_priv *priv = netdev_priv(dev);
>> @@ -3093,6 +3107,7 @@ static int mlx5e_get_vf_stats(struct net_device *dev,
>>         return mlx5_eswitch_get_vport_stats(mdev->priv.eswitch, vf + 1,
>>                                             vf_stats);
>>  }
>> +#endif /* CONFIG_MLX5_CORE_EN_ESWITCH */
>>
>>  void mlx5e_add_vxlan_port(struct net_device *netdev,
>>                           struct udp_tunnel_info *ti)
>> @@ -3329,6 +3344,7 @@ static const struct net_device_ops mlx5e_netdev_ops_basic = {
>>  #endif
>>  };
>>
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>  static const struct net_device_ops mlx5e_netdev_ops_sriov = {
>>         .ndo_open                = mlx5e_open,
>>         .ndo_stop                = mlx5e_close,
>> @@ -3358,14 +3374,15 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
>>         .ndo_get_vf_config       = mlx5e_get_vf_config,
>>         .ndo_set_vf_link_state   = mlx5e_set_vf_link_state,
>>         .ndo_get_vf_stats        = mlx5e_get_vf_stats,
>> +       .ndo_has_offload_stats   = mlx5e_has_offload_stats,
>> +       .ndo_get_offload_stats   = mlx5e_get_offload_stats,
>>         .ndo_tx_timeout          = mlx5e_tx_timeout,
>>         .ndo_xdp                 = mlx5e_xdp,
>>  #ifdef CONFIG_NET_POLL_CONTROLLER
>>         .ndo_poll_controller     = mlx5e_netpoll,
>>  #endif
>> -       .ndo_has_offload_stats   = mlx5e_has_offload_stats,
>> -       .ndo_get_offload_stats   = mlx5e_get_offload_stats,
>>  };
>> +#endif /* CONFIG_MLX5_CORE_EN_ESWITCH */
>>
>>  static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
>>  {
>> @@ -3586,13 +3603,16 @@ static void mlx5e_build_nic_netdev(struct net_device *netdev)
>>
>>         SET_NETDEV_DEV(netdev, &mdev->pdev->dev);
>>
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>         if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
>>                 netdev->netdev_ops = &mlx5e_netdev_ops_sriov;
>>  #ifdef CONFIG_MLX5_CORE_EN_DCB
>>                 if (MLX5_CAP_GEN(mdev, qos))
>>                         netdev->dcbnl_ops = &mlx5e_dcbnl_ops;
>>  #endif
>> -       } else {
>> +       } else
>> +#endif
>> +       {
>>                 netdev->netdev_ops = &mlx5e_netdev_ops_basic;
>>         }
>>
>> @@ -3795,14 +3815,16 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
>>  {
>>         struct net_device *netdev = priv->netdev;
>>         struct mlx5_core_dev *mdev = priv->mdev;
>> -       struct mlx5_eswitch *esw = mdev->priv.eswitch;
>> -       struct mlx5_eswitch_rep rep;
>>
>>         mlx5_lag_add(mdev, netdev);
>>
>>         mlx5e_enable_async_events(priv);
>>
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>         if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
>> +               struct mlx5_eswitch *esw = mdev->priv.eswitch;
>> +               struct mlx5_eswitch_rep rep;
>> +
>>                 mlx5_query_nic_vport_mac_address(mdev, 0, rep.hw_id);
>>                 rep.load = mlx5e_nic_rep_load;
>>                 rep.unload = mlx5e_nic_rep_unload;
>> @@ -3810,6 +3832,7 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
>>                 rep.netdev = netdev;
>>                 mlx5_eswitch_register_vport_rep(esw, 0, &rep);
>>         }
>> +#endif
>>
>>         if (netdev->reg_state != NETREG_REGISTERED)
>>                 return;
>> @@ -3827,11 +3850,14 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
>>  static void mlx5e_nic_disable(struct mlx5e_priv *priv)
>>  {
>>         struct mlx5_core_dev *mdev = priv->mdev;
>> -       struct mlx5_eswitch *esw = mdev->priv.eswitch;
>>
>>         queue_work(priv->wq, &priv->set_rx_mode_work);
>> -       if (MLX5_CAP_GEN(mdev, vport_group_manager))
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>> +       if (MLX5_CAP_GEN(priv->mdev, vport_group_manager)) {
>> +               struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
>>                 mlx5_eswitch_unregister_vport_rep(esw, 0);
>> +       }
>> +#endif
>>         mlx5e_disable_async_events(priv);
>>         mlx5_lag_remove(mdev);
>>  }
>> @@ -3942,6 +3968,7 @@ int mlx5e_attach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
>>         return err;
>>  }
>>
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>  static void mlx5e_register_vport_rep(struct mlx5_core_dev *mdev)
>>  {
>>         struct mlx5_eswitch *esw = mdev->priv.eswitch;
>> @@ -3964,6 +3991,7 @@ static void mlx5e_register_vport_rep(struct mlx5_core_dev *mdev)
>>                 mlx5_eswitch_register_vport_rep(esw, vport, &rep);
>>         }
>>  }
>> +#endif
>>
>>  void mlx5e_detach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
>>  {
>> @@ -4028,11 +4056,8 @@ static void mlx5e_detach(struct mlx5_core_dev *mdev, void *vpriv)
>>
>>  static void *mlx5e_add(struct mlx5_core_dev *mdev)
>>  {
>> -       struct mlx5_eswitch *esw = mdev->priv.eswitch;
>> -       int total_vfs = MLX5_TOTAL_VPORTS(mdev);
>>         void *ppriv = NULL;
>>         void *priv;
>> -       int vport;
>>         int err;
>>         struct net_device *netdev;
>>
>> @@ -4040,10 +4065,14 @@ static void *mlx5e_add(struct mlx5_core_dev *mdev)
>>         if (err)
>>                 return NULL;
>>
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>         mlx5e_register_vport_rep(mdev);
>>
>> -       if (MLX5_CAP_GEN(mdev, vport_group_manager))
>> +       if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
>> +               struct mlx5_eswitch *esw = mdev->priv.eswitch;
>>                 ppriv = &esw->offloads.vport_reps[0];
>> +       }
>> +#endif
>>
>>         netdev = mlx5e_create_netdev(mdev, &mlx5e_nic_profile, ppriv);
>>         if (!netdev) {
>> @@ -4074,8 +4103,16 @@ static void *mlx5e_add(struct mlx5_core_dev *mdev)
>>         mlx5e_destroy_netdev(mdev, priv);
>>
>>  err_unregister_reps:
>> -       for (vport = 1; vport < total_vfs; vport++)
>> -               mlx5_eswitch_unregister_vport_rep(esw, vport);
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>> +       {
>> +               int total_vfs = MLX5_TOTAL_VPORTS(mdev);
>> +               struct mlx5_eswitch *esw = mdev->priv.eswitch;
>> +               int vport;
>> +
>> +               for (vport = 1; vport < total_vfs; vport++)
>> +                       mlx5_eswitch_unregister_vport_rep(esw, vport);
>> +       }
>> +#endif
>>
>>         return NULL;
>>  }
>> @@ -4093,13 +4130,18 @@ void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, struct mlx5e_priv *priv)
>>
>>  static void mlx5e_remove(struct mlx5_core_dev *mdev, void *vpriv)
>>  {
>> -       struct mlx5_eswitch *esw = mdev->priv.eswitch;
>> -       int total_vfs = MLX5_TOTAL_VPORTS(mdev);
>>         struct mlx5e_priv *priv = vpriv;
>> -       int vport;
>>
>> -       for (vport = 1; vport < total_vfs; vport++)
>> -               mlx5_eswitch_unregister_vport_rep(esw, vport);
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>> +       {
>> +               struct mlx5_eswitch *esw = mdev->priv.eswitch;
>> +               int total_vfs = MLX5_TOTAL_VPORTS(mdev);
>> +               int vport;
>> +
>> +               for (vport = 1; vport < total_vfs; vport++)
>> +                       mlx5_eswitch_unregister_vport_rep(esw, vport);
>> +       }
>> +#endif
>>
>>         unregister_netdev(priv->netdev);
>>         mlx5e_detach(mdev, vpriv);
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
>> index 640f10f..8e5f565 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
>> @@ -128,6 +128,7 @@ mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
>>         return rule;
>>  }
>>
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>  static struct mlx5_flow_handle *
>>  mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
>>                       struct mlx5_flow_spec *spec,
>> @@ -160,6 +161,7 @@ static void mlx5e_detach_encap(struct mlx5e_priv *priv,
>>                 kfree(e);
>>         }
>>  }
>> +#endif /* CONFIG_MLX5_CORE_EN_ESWITCH */
>>
>>  /* we get here also when setting rule to the FW failed, etc. It means that the
>>   * flow rule itself might not exist, but some offloading related to the actions
>> @@ -168,7 +170,6 @@ static void mlx5e_detach_encap(struct mlx5e_priv *priv,
>>  static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
>>                               struct mlx5e_tc_flow *flow)
>>  {
>> -       struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
>>         struct mlx5_fc *counter = NULL;
>>
>>         if (!IS_ERR(flow->rule)) {
>> @@ -177,11 +178,17 @@ static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
>>                 mlx5_fc_destroy(priv->mdev, counter);
>>         }
>>
>> -       if (esw && esw->mode == SRIOV_OFFLOADS) {
>> -               mlx5_eswitch_del_vlan_action(esw, flow->attr);
>> -               if (flow->attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP)
>> -                       mlx5e_detach_encap(priv, flow);
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>> +       {
>> +               struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
>> +
>> +               if (esw && esw->mode == SRIOV_OFFLOADS) {
>> +                       mlx5_eswitch_del_vlan_action(esw, flow->attr);
>> +                       if (flow->attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP)
>> +                               mlx5e_detach_encap(priv, flow);
>> +               }
>>         }
>> +#endif
>>
>>         if (!mlx5e_tc_num_filters(priv) && (priv->fs.tc.t)) {
>>                 mlx5_destroy_flow_table(priv->fs.tc.t);
>> @@ -679,6 +686,7 @@ static inline int hash_encap_info(struct ip_tunnel_key *key)
>>         return jhash(key, sizeof(*key), 0);
>>  }
>>
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>  static int mlx5e_route_lookup_ipv4(struct mlx5e_priv *priv,
>>                                    struct net_device *mirred_dev,
>>                                    struct net_device **out_dev,
>> @@ -1129,20 +1137,27 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
>>         }
>>         return 0;
>>  }
>> +#endif /* CONFIG_MLX5_CORE_EN_ESWITCH */
>>
>>  int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
>>                            struct tc_cls_flower_offload *f)
>>  {
>>         struct mlx5e_tc_table *tc = &priv->fs.tc;
>>         int err = 0;
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>         bool fdb_flow = false;
>> +#endif
>>         u32 flow_tag, action;
>>         struct mlx5e_tc_flow *flow;
>>         struct mlx5_flow_spec *spec;
>> -       struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
>>
>> -       if (esw && esw->mode == SRIOV_OFFLOADS)
>> -               fdb_flow = true;
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>> +       {
>> +               struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
>> +
>> +               if (esw && esw->mode == SRIOV_OFFLOADS)
>> +                       fdb_flow = true;
>> +       }
>>
>>         if (fdb_flow)
>>                 flow = kzalloc(sizeof(*flow) +
>> @@ -1150,6 +1165,9 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
>>                                GFP_KERNEL);
>>         else
>>                 flow = kzalloc(sizeof(*flow), GFP_KERNEL);
>> +#else
>> +       flow = kzalloc(sizeof(*flow), GFP_KERNEL);
>> +#endif
>>
>>         spec = mlx5_vzalloc(sizeof(*spec));
>>         if (!spec || !flow) {
>> @@ -1163,13 +1181,16 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
>>         if (err < 0)
>>                 goto err_free;
>>
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>         if (fdb_flow) {
>>                 flow->attr  = (struct mlx5_esw_flow_attr *)(flow + 1);
>>                 err = parse_tc_fdb_actions(priv, f->exts, flow);
>>                 if (err < 0)
>>                         goto err_free;
>>                 flow->rule = mlx5e_tc_add_fdb_flow(priv, spec, flow->attr);
>> -       } else {
>> +       } else
>> +#endif
>> +       {
>>                 err = parse_tc_nic_actions(priv, f->exts, &action, &flow_tag);
>>                 if (err < 0)
>>                         goto err_free;
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
>> index ea5d8d3..2c67c25 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
>> @@ -35,7 +35,7 @@
>>  #include <linux/mlx5/driver.h>
>>  #include <linux/mlx5/cmd.h>
>>  #include "mlx5_core.h"
>> -#ifdef CONFIG_MLX5_CORE_EN
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>  #include "eswitch.h"
>>  #endif
>>
>> @@ -462,7 +462,7 @@ static irqreturn_t mlx5_eq_int(int irq, void *eq_ptr)
>>                         }
>>                         break;
>>
>> -#ifdef CONFIG_MLX5_CORE_EN
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>                 case MLX5_EVENT_TYPE_NIC_VPORT_CHANGE:
>>                         mlx5_eswitch_vport_event(dev->priv.eswitch, eqe);
>>                         break;
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
>> index 84f7970..224f499 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
>> @@ -53,7 +53,7 @@
>>  #include <net/devlink.h>
>>  #include "mlx5_core.h"
>>  #include "fs_core.h"
>> -#ifdef CONFIG_MLX5_CORE_EN
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>  #include "eswitch.h"
>>  #endif
>>
>> @@ -941,7 +941,7 @@ static int mlx5_init_once(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
>>                 goto err_tables_cleanup;
>>         }
>>
>> -#ifdef CONFIG_MLX5_CORE_EN
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>         err = mlx5_eswitch_init(dev);
>>         if (err) {
>>                 dev_err(&pdev->dev, "Failed to init eswitch %d\n", err);
>> @@ -958,7 +958,7 @@ static int mlx5_init_once(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
>>         return 0;
>>
>>  err_eswitch_cleanup:
>> -#ifdef CONFIG_MLX5_CORE_EN
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>         mlx5_eswitch_cleanup(dev->priv.eswitch);
>>
>>  err_rl_cleanup:
>> @@ -981,7 +981,7 @@ static int mlx5_init_once(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
>>  static void mlx5_cleanup_once(struct mlx5_core_dev *dev)
>>  {
>>         mlx5_sriov_cleanup(dev);
>> -#ifdef CONFIG_MLX5_CORE_EN
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>         mlx5_eswitch_cleanup(dev->priv.eswitch);
>>  #endif
>>         mlx5_cleanup_rl_table(dev);
>> @@ -1131,7 +1131,7 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
>>                 goto err_fs;
>>         }
>>
>> -#ifdef CONFIG_MLX5_CORE_EN
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>         mlx5_eswitch_attach(dev->priv.eswitch);
>>  #endif
>>
>> @@ -1162,7 +1162,7 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
>>         mlx5_sriov_detach(dev);
>>
>>  err_sriov:
>> -#ifdef CONFIG_MLX5_CORE_EN
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>         mlx5_eswitch_detach(dev->priv.eswitch);
>>  #endif
>>         mlx5_cleanup_fs(dev);
>> @@ -1233,7 +1233,7 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
>>                 mlx5_detach_device(dev);
>>
>>         mlx5_sriov_detach(dev);
>> -#ifdef CONFIG_MLX5_CORE_EN
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>         mlx5_eswitch_detach(dev->priv.eswitch);
>>  #endif
>>         mlx5_cleanup_fs(dev);
>> @@ -1269,7 +1269,7 @@ struct mlx5_core_event_handler {
>>  };
>>
>>  static const struct devlink_ops mlx5_devlink_ops = {
>> -#ifdef CONFIG_MLX5_CORE_EN
>> +#ifdef CONFIG_MLX5_CORE_EN_ESWITCH
>>         .eswitch_mode_set = mlx5_devlink_eswitch_mode_set,
>>         .eswitch_mode_get = mlx5_devlink_eswitch_mode_get,
>>         .eswitch_inline_mode_set = mlx5_devlink_eswitch_inline_mode_set,
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
>> index e086277..0664cc4 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
>> @@ -33,7 +33,7 @@
>>  #include <linux/pci.h>
>>  #include <linux/mlx5/driver.h>
>>  #include "mlx5_core.h"
>> -#ifdef CONFIG_MLX5_CORE_EN
>> +#ifdef CONFIG_MLX5_CORE_ESWITCH
>>  #include "eswitch.h"
>>  #endif
>>
>> @@ -57,7 +57,7 @@ static int mlx5_device_enable_sriov(struct mlx5_core_dev *dev, int num_vfs)
>>                 return -EBUSY;
>>         }
>>
>> -#ifdef CONFIG_MLX5_CORE_EN
>> +#ifdef CONFIG_MLX5_CORE_ESWITCH
>>         err = mlx5_eswitch_enable_sriov(dev->priv.eswitch, num_vfs, SRIOV_LEGACY);
>>         if (err) {
>>                 mlx5_core_warn(dev,
>> @@ -102,7 +102,7 @@ static void mlx5_device_disable_sriov(struct mlx5_core_dev *dev)
>>                 sriov->enabled_vfs--;
>>         }
>>
>> -#ifdef CONFIG_MLX5_CORE_EN
>> +#ifdef CONFIG_MLX5_CORE_ESWITCH
>>         mlx5_eswitch_disable_sriov(dev->priv.eswitch);
>>  #endif
>>
>> --
>> 2.9.3
>>
