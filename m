From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next v3 06/16] i40e: Implementation of vxlan ndo's
Date: Fri, 20 Dec 2013 23:06:06 +0200
Message-ID: <CAJZOPZLScxFtDXLFwUE+S1yRv_VJ2TL5kccA5WU_Jn4ROjdnqw@mail.gmail.com>
References: <1387563694-3166-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1387563694-3166-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:50269 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938Ab3LTVGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 16:06:06 -0500
Received: by mail-pb0-f44.google.com with SMTP id rq2so3117928pbb.3
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 13:06:06 -0800 (PST)
In-Reply-To: <1387563694-3166-7-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 8:21 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Joseph Gasparakis <joseph.gasparakis@intel.com>
>
> This adds the implementation for the vxlan ndo's.  This allows
> the hardware to do RX checksum offload for inner packets on the UDP
> ports that vxlan notifies us about.
>
> Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/Kconfig               |  1 +
>  drivers/net/ethernet/intel/i40e/i40e.h           |  2 +
>  drivers/net/ethernet/intel/i40e/i40e_common.c    | 57 +++++++++++++++
>  drivers/net/ethernet/intel/i40e/i40e_main.c      | 92 ++++++++++++++++++++++++
>  drivers/net/ethernet/intel/i40e/i40e_prototype.h |  6 ++
>  drivers/net/ethernet/intel/i40e/i40e_type.h      |  1 +
>  6 files changed, 159 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
> index 41a2fa2..38e47ed 100644
> --- a/drivers/net/ethernet/intel/Kconfig
> +++ b/drivers/net/ethernet/intel/Kconfig
> @@ -244,6 +244,7 @@ config IXGBEVF
>  config I40E
>         tristate "Intel(R) Ethernet Controller XL710 Family support"
>         depends on PCI
> +       depends on VXLAN || !VXLAN
>         ---help---
>           This driver supports Intel(R) Ethernet Controller XL710 Family of
>           devices.  For more information on how to identify your adapter, go
> diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
> index 31dd265..5d88cf4 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e.h
> +++ b/drivers/net/ethernet/intel/i40e/i40e.h
> @@ -207,6 +207,8 @@ struct i40e_pf {
>         u8 atr_sample_rate;
>         bool wol_en;
>
> +       __be16  vxlan_ports[I40E_MAX_PF_UDP_OFFLOAD_PORTS];
> +
>         enum i40e_interrupt_policy int_policy;
>         u16 rx_itr_default;
>         u16 tx_itr_default;
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
> index cba1eb4..ca58263 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_common.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
> @@ -1671,6 +1671,63 @@ i40e_status i40e_aq_start_lldp(struct i40e_hw *hw,
>  }
>
>  /**
> + * i40e_aq_add_udp_tunnel
> + * @hw: pointer to the hw struct
> + * @udp_port: the UDP port to add
> + * @header_len: length of the tunneling header length in DWords
> + * @protocol_index: protocol index type
> + * @cmd_details: pointer to command details structure or NULL
> + **/
> +i40e_status i40e_aq_add_udp_tunnel(struct i40e_hw *hw,
> +                               u16 udp_port, u8 header_len,
> +                               u8 protocol_index, u8 *filter_index,
> +                               struct i40e_asq_cmd_details *cmd_details)
> +{
> +       struct i40e_aq_desc desc;
> +       struct i40e_aqc_add_udp_tunnel *cmd =
> +               (struct i40e_aqc_add_udp_tunnel *)&desc.params.raw;
> +       struct i40e_aqc_del_udp_tunnel_completion *resp =
> +               (struct i40e_aqc_del_udp_tunnel_completion *)&desc.params.raw;
> +       i40e_status status;
> +
> +       i40e_fill_default_direct_cmd_desc(&desc, i40e_aqc_opc_add_udp_tunnel);
> +
> +       cmd->udp_port = cpu_to_le16(udp_port);
> +       cmd->header_len = header_len;
> +       cmd->protocol_index = protocol_index;
> +
> +       status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);

so i40e_asq_send_command is called with a spinlock held or under
rcu_read_lock from the vxlan driver code but might sleep, as it takes
a mutex, seems problematic.

> +
> +       if (!status)
> +               *filter_index = resp->index;
> +
> +       return status;
> +}
> +
> +/**
> + * i40e_aq_del_udp_tunnel
> + * @hw: pointer to the hw struct
> + * @index: filter index
> + * @cmd_details: pointer to command details structure or NULL
> + **/
> +i40e_status i40e_aq_del_udp_tunnel(struct i40e_hw *hw, u8 index,
> +                               struct i40e_asq_cmd_details *cmd_details)
> +{
> +       struct i40e_aq_desc desc;
> +       struct i40e_aqc_remove_udp_tunnel *cmd =
> +               (struct i40e_aqc_remove_udp_tunnel *)&desc.params.raw;
> +       i40e_status status;
> +
> +       i40e_fill_default_direct_cmd_desc(&desc, i40e_aqc_opc_del_udp_tunnel);
> +
> +       cmd->index = index;
> +
> +       status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
> +
> +       return status;
> +}
> +
> +/**
>   * i40e_aq_delete_element - Delete switch element
>   * @hw: pointer to the hw struct
>   * @seid: the SEID to delete from the switch
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index b0cfb4c..7b759a6 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -27,6 +27,9 @@
>
>  /* Local includes */
>  #include "i40e.h"
> +#if IS_ENABLED(CONFIG_VXLAN)
> +#include "net/vxlan.h"
> +#endif
>
>  const char i40e_driver_name[] = "i40e";
>  static const char i40e_driver_string[] =
> @@ -3993,6 +3996,9 @@ static int i40e_open(struct net_device *netdev)
>                                     "couldn't set broadcast err %d aq_err %d\n",
>                                     err, pf->hw.aq.asq_last_status);
>         }
> +#if IS_ENABLED(CONFIG_VXLAN)
> +       vxlan_get_rx_port(netdev);
> +#endif
>
>         return 0;
>
> @@ -5900,6 +5906,90 @@ static int i40e_set_features(struct net_device *netdev,
>         return 0;
>  }
>
> +/**
> + * i40e_get_vxlan_port_idx - Lookup a possibly offloaded for Rx UDP port
> + * @pf: board private structure
> + * @port: The UDP port to look up
> + *
> + * Returns the index number or I40E_MAX_PF_UDP_OFFLOAD_PORTS if port not found
> + **/
> +static u8 i40e_get_vxlan_port_idx(struct i40e_pf *pf, __be16 port)
> +{
> +       u8 i;
> +
> +       for (i = 0; i < I40E_MAX_PF_UDP_OFFLOAD_PORTS; i++) {
> +               if (pf->vxlan_ports[i] == port)
> +                       return i;
> +       }
> +
> +       return i;
> +}
> +
> +/**
> + * i40e_add_vxlan_port - Get notifications about VXLAN ports that come up
> + * @netdev: This physical port's netdev
> + * @sa_family: Socket Family that VXLAN is notifying us about
> + * @port: New UDP port number that VXLAN started listening to
> + **/
> +static void i40e_add_vxlan_port(struct net_device *netdev,
> +                                sa_family_t sa_family, __be16 port)
> +{
> +       struct i40e_netdev_priv *np = netdev_priv(netdev);
> +       struct i40e_vsi *vsi = np->vsi;
> +       struct i40e_pf *pf = vsi->back;
> +       const int vxlan_hdr_qwords = 4;
> +       struct i40e_hw *hw = &pf->hw;
> +       i40e_status aq_ret;
> +       u8 filter_index;
> +
> +       if (sa_family == AF_INET6)
> +               return;
> +
> +       aq_ret = i40e_aq_add_udp_tunnel(hw, ntohs(port), vxlan_hdr_qwords,
> +                                    I40E_AQC_TUNNEL_TYPE_UDP, &filter_index,
> +                                    NULL);
> +
> +       if (!aq_ret && filter_index < I40E_MAX_PF_UDP_OFFLOAD_PORTS)
> +               pf->vxlan_ports[filter_index] = port;
> +       else
> +               dev_warn(&pf->pdev->dev, "Could not use port %d for VXLAN offload\n",
> +                        ntohs(port));
> +}
> +
> +/**
> + * i40e_del_vxlan_port - Get notifications about VXLAN ports that go away
> + * @netdev: This physical port's netdev
> + * @sa_family: Socket Family that VXLAN is notifying us about
> + * @port: UDP port number that VXLAN stopped listening to
> + **/
> +static void i40e_del_vxlan_port(struct net_device *netdev,
> +                                sa_family_t sa_family, __be16 port)
> +{
> +       struct i40e_netdev_priv *np = netdev_priv(netdev);
> +       struct i40e_vsi *vsi = np->vsi;
> +       struct i40e_pf *pf = vsi->back;
> +       struct i40e_hw *hw = &pf->hw;
> +       i40e_status aq_ret;
> +       u8 filter_index;
> +
> +       if (sa_family == AF_INET6)
> +               return;
> +
> +       filter_index = i40e_get_vxlan_port_idx(pf, port);
> +
> +       if (filter_index < I40E_MAX_PF_UDP_OFFLOAD_PORTS) {
> +               aq_ret = i40e_aq_del_udp_tunnel(hw, filter_index, NULL);
> +               if (!aq_ret)
> +                       pf->vxlan_ports[filter_index] = 0;
> +               else
> +                       dev_warn(&pf->pdev->dev, "Could not remove VXLAN port %d\n",
> +                                ntohs(port));
> +       } else {
> +               dev_warn(&pf->pdev->dev, "Received notification to remove VXLAN port %d but port was not added before.\n",
> +                        ntohs(port));
> +       }
> +}
> +
>  static const struct net_device_ops i40e_netdev_ops = {
>         .ndo_open               = i40e_open,
>         .ndo_stop               = i40e_close,
> @@ -5921,6 +6011,8 @@ static const struct net_device_ops i40e_netdev_ops = {
>         .ndo_set_vf_vlan        = i40e_ndo_set_vf_port_vlan,
>         .ndo_set_vf_tx_rate     = i40e_ndo_set_vf_bw,
>         .ndo_get_vf_config      = i40e_ndo_get_vf_config,
> +       .ndo_add_vxlan_port     = i40e_add_vxlan_port,
> +       .ndo_del_vxlan_port     = i40e_del_vxlan_port,
>  };
>
>  /**
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
> index db7bf93..5c458bb 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
> +++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
> @@ -157,6 +157,12 @@ i40e_status i40e_aq_stop_lldp(struct i40e_hw *hw, bool shutdown_agent,
>                                 struct i40e_asq_cmd_details *cmd_details);
>  i40e_status i40e_aq_start_lldp(struct i40e_hw *hw,
>                                 struct i40e_asq_cmd_details *cmd_details);
> +i40e_status i40e_aq_add_udp_tunnel(struct i40e_hw *hw,
> +                               u16 udp_port, u8 header_len,
> +                               u8 protocol_index, u8 *filter_index,
> +                               struct i40e_asq_cmd_details *cmd_details);
> +i40e_status i40e_aq_del_udp_tunnel(struct i40e_hw *hw, u8 index,
> +                               struct i40e_asq_cmd_details *cmd_details);
>  i40e_status i40e_aq_delete_element(struct i40e_hw *hw, u16 seid,
>                                 struct i40e_asq_cmd_details *cmd_details);
>  i40e_status i40e_aq_mac_address_write(struct i40e_hw *hw,
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
> index d683c30..bb960cd 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_type.h
> +++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
> @@ -59,6 +59,7 @@
>  #define I40E_MAX_VSI_QP                        16
>  #define I40E_MAX_VF_VSI                        3
>  #define I40E_MAX_CHAINED_RX_BUFFERS    5
> +#define I40E_MAX_PF_UDP_OFFLOAD_PORTS  16
>
>  /* Max default timeout in ms, */
>  #define I40E_MAX_NVM_TIMEOUT           18000
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
