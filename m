From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH net-next V2 2/2] intel: ixgbevf: Support
 Windows hosts (Hyper-V)
Date: Mon, 18 Apr 2016 09:17:32 -0700
Message-ID: <CAKgT0UdLxSk6CKVAt232fdthMtUbn9FLru9Q9w1Qjjdv_zKA4g@mail.gmail.com>
References: <1460956943-17560-1-git-send-email-kys@microsoft.com>
	<1460956969-17601-1-git-send-email-kys@microsoft.com>
	<1460956969-17601-3-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	devel@linuxdriverproject.org, olaf@aepfle.de,
	Robo Bot <apw@canonical.com>, Jason Wang <jasowang@redhat.com>,
	eli@mellanox.com, jackm@mellanox.com, yevgenyp@mellanox.com,
	John Ronciak <john.ronciak@intel.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460956969-17601-3-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 17, 2016 at 10:22 PM, K. Y. Srinivasan <kys@microsoft.com> wrote:
> On Hyper-V, the VF/PF communication is a via software mediated path
> as opposed to the hardware mailbox. Make the necessary
> adjustments to support Hyper-V.
>
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> ---
>         V2: Addressed most of the comments from
>             Alexander Duyck <alexander.duyck@gmail.com>
>             and Rustad, Mark D <mark.d.rustad@intel.com>.
>
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   12 ++
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   16 ++-
>  drivers/net/ethernet/intel/ixgbevf/mbx.c          |   12 ++
>  drivers/net/ethernet/intel/ixgbevf/vf.c           |  201 +++++++++++++++++++++
>  4 files changed, 237 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> index 5ac60ee..3296d27 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> @@ -460,9 +460,13 @@ enum ixbgevf_state_t {
>
>  enum ixgbevf_boards {
>         board_82599_vf,
> +       board_82599_vf_hv,
>         board_X540_vf,
> +       board_X540_vf_hv,
>         board_X550_vf,
> +       board_X550_vf_hv,
>         board_X550EM_x_vf,
> +       board_X550EM_x_vf_hv,
>  };
>
>  enum ixgbevf_xcast_modes {
> @@ -477,6 +481,13 @@ extern const struct ixgbevf_info ixgbevf_X550_vf_info;
>  extern const struct ixgbevf_info ixgbevf_X550EM_x_vf_info;
>  extern const struct ixgbe_mbx_operations ixgbevf_mbx_ops;
>
> +
> +extern const struct ixgbevf_info ixgbevf_82599_vf_hv_info;
> +extern const struct ixgbevf_info ixgbevf_X540_vf_hv_info;
> +extern const struct ixgbevf_info ixgbevf_X550_vf_hv_info;
> +extern const struct ixgbevf_info ixgbevf_X550EM_x_vf_hv_info;
> +extern const struct ixgbe_mbx_operations ixgbevf_hv_mbx_ops;
> +
>  /* needed by ethtool.c */
>  extern const char ixgbevf_driver_name[];
>  extern const char ixgbevf_driver_version[];
> @@ -494,6 +505,7 @@ void ixgbevf_free_rx_resources(struct ixgbevf_ring *);
>  void ixgbevf_free_tx_resources(struct ixgbevf_ring *);
>  void ixgbevf_update_stats(struct ixgbevf_adapter *adapter);
>  int ethtool_ioctl(struct ifreq *ifr);
> +bool ixgbevf_on_hyperv(struct ixgbe_hw *hw);
>
>  extern void ixgbevf_write_eitr(struct ixgbevf_q_vector *q_vector);
>
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index 007cbe0..c761d80 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> @@ -62,10 +62,14 @@ static char ixgbevf_copyright[] =
>         "Copyright (c) 2009 - 2015 Intel Corporation.";
>
>  static const struct ixgbevf_info *ixgbevf_info_tbl[] = {
> -       [board_82599_vf] = &ixgbevf_82599_vf_info,
> -       [board_X540_vf]  = &ixgbevf_X540_vf_info,
> -       [board_X550_vf]  = &ixgbevf_X550_vf_info,
> -       [board_X550EM_x_vf] = &ixgbevf_X550EM_x_vf_info,
> +       [board_82599_vf]        = &ixgbevf_82599_vf_info,
> +       [board_82599_vf_hv]     = &ixgbevf_82599_vf_hv_info,
> +       [board_X540_vf]         = &ixgbevf_X540_vf_info,
> +       [board_X540_vf_hv]      = &ixgbevf_X540_vf_hv_info,
> +       [board_X550_vf]         = &ixgbevf_X550_vf_info,
> +       [board_X550_vf_hv]      = &ixgbevf_X550_vf_hv_info,
> +       [board_X550EM_x_vf]     = &ixgbevf_X550EM_x_vf_info,
> +       [board_X550EM_x_vf_hv]  = &ixgbevf_X550EM_x_vf_hv_info,
>  };
>
>  /* ixgbevf_pci_tbl - PCI Device ID Table
> @@ -78,9 +82,13 @@ static const struct ixgbevf_info *ixgbevf_info_tbl[] = {
>   */
>  static const struct pci_device_id ixgbevf_pci_tbl[] = {
>         {PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_VF), board_82599_vf },
> +       {PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_VF_HV), board_82599_vf_hv },
>         {PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X540_VF), board_X540_vf },
> +       {PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X540_VF_HV), board_X540_vf_hv },
>         {PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550_VF), board_X550_vf },
> +       {PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550_VF_HV), board_X550_vf_hv },
>         {PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_VF), board_X550EM_x_vf },
> +       {PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_VF_HV), board_X550EM_x_vf_hv},
>         /* required last entry */
>         {0, }
>  };
> diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.c b/drivers/net/ethernet/intel/ixgbevf/mbx.c
> index dc68fea..298a0da 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/mbx.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/mbx.c
> @@ -346,3 +346,15 @@ const struct ixgbe_mbx_operations ixgbevf_mbx_ops = {
>         .check_for_rst  = ixgbevf_check_for_rst_vf,
>  };
>
> +/**
> + * Mailbox operations when running on Hyper-V.
> + * On Hyper-V, PF/VF communiction is not through the
> + * hardware mailbox; this communication is through
> + * a software mediated path.
> + * Most mail box operations are noop while running on
> + * Hyper-V.
> + */
> +const struct ixgbe_mbx_operations ixgbevf_hv_mbx_ops = {
> +       .init_params    = ixgbevf_init_mbx_params_vf,
> +       .check_for_rst  = ixgbevf_check_for_rst_vf,
> +};
> diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
> index 4d613a4..1ec13c1 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/vf.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
> @@ -27,6 +27,13 @@
>  #include "vf.h"
>  #include "ixgbevf.h"
>
> +/*
> + * On Hyper-V, to reset, we need to read from this offset
> + * from the PCI config space. This is the mechanism used on
> + * Hyper-V to support PF/VF communication.
> + */
> +#define IXGBE_HV_RESET_OFFSET           0x201
> +
>  /**
>   *  ixgbevf_start_hw_vf - Prepare hardware for Tx/Rx
>   *  @hw: pointer to hardware structure
> @@ -126,6 +133,23 @@ static s32 ixgbevf_reset_hw_vf(struct ixgbe_hw *hw)
>  }
>
>  /**
> + * Hyper-V variant; the VF/PF communication is through the PCI
> + * config space.
> + */
> +static s32 ixgbevf_hv_reset_hw_vf(struct ixgbe_hw *hw)
> +{
> +       struct ixgbevf_adapter *adapter = hw->back;
> +       int i;
> +
> +       for (i = 0; i < 6; i++)
> +               pci_read_config_byte(adapter->pdev,
> +                                    (i + IXGBE_HV_RESET_OFFSET),
> +                                    &hw->mac.perm_addr[i]);
> +
> +       return 0;
> +}
> +

I'm still not seeing anything that protects the HyperV VF from being
built with MM_CONFIG disabled.  As such this driver will just fail
with no explanation in such a case.  If nothing else you could add
some code here that printed an error message if MM_CONFIG is disabled
at the very least.

> +/**
>   *  ixgbevf_stop_hw_vf - Generic stop Tx/Rx units
>   *  @hw: pointer to hardware structure
>   *
> @@ -258,6 +282,11 @@ static s32 ixgbevf_set_uc_addr_vf(struct ixgbe_hw *hw, u32 index, u8 *addr)
>         return ret_val;
>  }
>
> +static s32 ixgbevf_hv_set_uc_addr_vf(struct ixgbe_hw *hw, u32 index, u8 *addr)
> +{
> +       return -EOPNOTSUPP;
> +}
> +
>  /**
>   * ixgbevf_get_reta_locked - get the RSS redirection table (RETA) contents.
>   * @adapter: pointer to the port handle
> @@ -416,6 +445,26 @@ static s32 ixgbevf_set_rar_vf(struct ixgbe_hw *hw, u32 index, u8 *addr,
>         return ret_val;
>  }
>
> +/**
> + *  ixgbevf_hv_set_rar_vf - set device MAC address Hyper-V variant
> + *  @hw: pointer to hardware structure
> + *  @index: Receive address register to write
> + *  @addr: Address to put into receive address register
> + *  @vmdq: Unused in this implementation
> + *
> + * We don't really allow setting the device MAC address. However,
> + * if the address being set is the permanent MAC address we will
> + * permit that.
> + **/
> +static s32 ixgbevf_hv_set_rar_vf(struct ixgbe_hw *hw, u32 index, u8 *addr,
> +                                u32 vmdq)
> +{
> +       if (ether_addr_equal(addr, hw->mac.perm_addr))
> +               return 0;
> +
> +       return -EOPNOTSUPP;
> +}
> +
>  static void ixgbevf_write_msg_read_ack(struct ixgbe_hw *hw,
>                                        u32 *msg, u16 size)
>  {
> @@ -473,6 +522,15 @@ static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw,
>  }
>
>  /**
> + * Hyper-V variant - just a stub.
> + */
> +static s32 ixgbevf_hv_update_mc_addr_list_vf(struct ixgbe_hw *hw,
> +                                         struct net_device *netdev)
> +{
> +       return -EOPNOTSUPP;
> +}
> +
> +/**
>   *  ixgbevf_update_xcast_mode - Update Multicast mode
>   *  @hw: pointer to the HW structure
>   *  @netdev: pointer to net device structure
> @@ -513,6 +571,15 @@ static s32 ixgbevf_update_xcast_mode(struct ixgbe_hw *hw,
>  }
>
>  /**
> + * Hyper-V variant - just a stub.
> + */
> +static s32 ixgbevf_hv_update_xcast_mode(struct ixgbe_hw *hw,
> +                                       struct net_device *netdev, int xcast_mode)
> +{
> +       return -EOPNOTSUPP;
> +}
> +
> +/**
>   *  ixgbevf_set_vfta_vf - Set/Unset VLAN filter table address
>   *  @hw: pointer to the HW structure
>   *  @vlan: 12 bit VLAN ID
> @@ -551,6 +618,15 @@ mbx_err:
>  }
>
>  /**
> + * Hyper-V variant - just a stub.
> + */
> +static s32 ixgbevf_hv_set_vfta_vf(struct ixgbe_hw *hw, u32 vlan, u32 vind,
> +                                 bool vlan_on)
> +{
> +       return -EOPNOTSUPP;
> +}
> +
> +/**
>   *  ixgbevf_setup_mac_link_vf - Setup MAC link settings
>   *  @hw: pointer to hardware structure
>   *  @speed: Unused in this implementation
> @@ -656,6 +732,67 @@ out:
>  }
>
>  /**
> + * Hyper-V variant; there is no mailbox communication.
> + */
> +static s32 ixgbevf_hv_check_mac_link_vf(struct ixgbe_hw *hw,
> +                                       ixgbe_link_speed *speed,
> +                                       bool *link_up,
> +                                       bool autoneg_wait_to_complete)
> +{
> +       struct ixgbe_mbx_info *mbx = &hw->mbx;
> +       struct ixgbe_mac_info *mac = &hw->mac;
> +       u32 links_reg;
> +
> +       /* If we were hit with a reset drop the link */
> +       if (!mbx->ops.check_for_rst(hw) || !mbx->timeout)
> +               mac->get_link_status = true;
> +
> +       if (!mac->get_link_status)
> +               goto out;
> +
> +       /* if link status is down no point in checking to see if pf is up */
> +       links_reg = IXGBE_READ_REG(hw, IXGBE_VFLINKS);
> +       if (!(links_reg & IXGBE_LINKS_UP))
> +               goto out;
> +
> +       /* for SFP+ modules and DA cables on 82599 it can take up to 500usecs
> +        * before the link status is correct
> +        */
> +       if (mac->type == ixgbe_mac_82599_vf) {
> +               int i;
> +
> +               for (i = 0; i < 5; i++) {
> +                       udelay(100);
> +                       links_reg = IXGBE_READ_REG(hw, IXGBE_VFLINKS);
> +
> +                       if (!(links_reg & IXGBE_LINKS_UP))
> +                               goto out;
> +               }
> +       }
> +
> +       switch (links_reg & IXGBE_LINKS_SPEED_82599) {
> +       case IXGBE_LINKS_SPEED_10G_82599:
> +               *speed = IXGBE_LINK_SPEED_10GB_FULL;
> +               break;
> +       case IXGBE_LINKS_SPEED_1G_82599:
> +               *speed = IXGBE_LINK_SPEED_1GB_FULL;
> +               break;
> +       case IXGBE_LINKS_SPEED_100_82599:
> +               *speed = IXGBE_LINK_SPEED_100_FULL;
> +               break;
> +       }
> +
> +       /* if we passed all the tests above then the link is up and we no
> +        * longer need to check for link
> +        */
> +       mac->get_link_status = false;
> +
> +out:
> +       *link_up = !mac->get_link_status;
> +       return 0;
> +}
> +
> +/**
>   *  ixgbevf_rlpml_set_vf - Set the maximum receive packet length
>   *  @hw: pointer to the HW structure
>   *  @max_size: value to assign to max frame size
> @@ -663,6 +800,18 @@ out:
>  void ixgbevf_rlpml_set_vf(struct ixgbe_hw *hw, u16 max_size)
>  {
>         u32 msgbuf[2];
> +       u32 reg;
> +
> +       if (ixgbevf_on_hyperv(hw)) {
> +               /* If we are on Hyper-V, we implement
> +                * this functionality differently.
> +                */
> +               reg =  IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(0));
> +               /* CRC == 4 */
> +               reg |= ((max_size + 4) | IXGBE_RXDCTL_RLPML_EN);
> +               IXGBE_WRITE_REG(hw, IXGBE_VFRXDCTL(0), reg);
> +               return;
> +       }
>
>         msgbuf[0] = IXGBE_VF_SET_LPE;
>         msgbuf[1] = max_size;

There is no point in making this one function.  You should split this
code out and create a HyperV version of the function that you can call
instead.  It would help to make this more readable anyway since you
can then drop one level of indentation.

> @@ -679,6 +828,15 @@ int ixgbevf_negotiate_api_version(struct ixgbe_hw *hw, int api)
>         int err;
>         u32 msg[3];
>
> +       if (ixgbevf_on_hyperv(hw)) {
> +               /* Hyper-V only supports api version ixgbe_mbox_api_10
> +                */
> +               if (api != ixgbe_mbox_api_10)
> +                       return IXGBE_ERR_INVALID_ARGUMENT;
> +
> +               return 0;
> +       }
> +
>         /* Negotiate the mailbox API version */
>         msg[0] = IXGBE_VF_API_NEGOTIATE;
>         msg[1] = api;

Same thing here.  You can just create a new function and avoid having
to mess with the mailbox based approach.

> @@ -776,22 +934,65 @@ static const struct ixgbe_mac_operations ixgbevf_mac_ops = {
>         .set_vfta               = ixgbevf_set_vfta_vf,
>  };
>
> +static const struct ixgbe_mac_operations ixgbevf_hv_mac_ops = {
> +       .init_hw                = ixgbevf_init_hw_vf,
> +       .reset_hw               = ixgbevf_hv_reset_hw_vf,
> +       .start_hw               = ixgbevf_start_hw_vf,
> +       .get_mac_addr           = ixgbevf_get_mac_addr_vf,
> +       .stop_adapter           = ixgbevf_stop_hw_vf,
> +       .setup_link             = ixgbevf_setup_mac_link_vf,
> +       .check_link             = ixgbevf_hv_check_mac_link_vf,
> +       .set_rar                = ixgbevf_hv_set_rar_vf,
> +       .update_mc_addr_list    = ixgbevf_hv_update_mc_addr_list_vf,
> +       .update_xcast_mode      = ixgbevf_hv_update_xcast_mode,
> +       .set_uc_addr            = ixgbevf_hv_set_uc_addr_vf,
> +       .set_vfta               = ixgbevf_hv_set_vfta_vf,
> +};
> +
>  const struct ixgbevf_info ixgbevf_82599_vf_info = {
>         .mac = ixgbe_mac_82599_vf,
>         .mac_ops = &ixgbevf_mac_ops,
>  };
>
> +const struct ixgbevf_info ixgbevf_82599_vf_hv_info = {
> +       .mac = ixgbe_mac_82599_vf,
> +       .mac_ops = &ixgbevf_hv_mac_ops,
> +};
> +
>  const struct ixgbevf_info ixgbevf_X540_vf_info = {
>         .mac = ixgbe_mac_X540_vf,
>         .mac_ops = &ixgbevf_mac_ops,
>  };
>
> +const struct ixgbevf_info ixgbevf_X540_vf_hv_info = {
> +       .mac = ixgbe_mac_X540_vf,
> +       .mac_ops = &ixgbevf_hv_mac_ops,
> +};
> +
>  const struct ixgbevf_info ixgbevf_X550_vf_info = {
>         .mac = ixgbe_mac_X550_vf,
>         .mac_ops = &ixgbevf_mac_ops,
>  };
>
> +const struct ixgbevf_info ixgbevf_X550_vf_hv_info = {
> +       .mac = ixgbe_mac_X550_vf,
> +       .mac_ops = &ixgbevf_hv_mac_ops,
> +};
> +
>  const struct ixgbevf_info ixgbevf_X550EM_x_vf_info = {
>         .mac = ixgbe_mac_X550EM_x_vf,
>         .mac_ops = &ixgbevf_mac_ops,
>  };
> +
> +const struct ixgbevf_info ixgbevf_X550EM_x_vf_hv_info = {
> +       .mac = ixgbe_mac_X550EM_x_vf,
> +       .mac_ops = &ixgbevf_hv_mac_ops,
> +};
> +
> +bool ixgbevf_on_hyperv(struct ixgbe_hw *hw)
> +{
> +       if (hw->mbx.ops.check_for_msg == NULL)
> +               return true;
> +       else
> +               return false;
> +}
> --
> 1.7.4.1
>
> _______________________________________________
> Intel-wired-lan mailing list
> Intel-wired-lan@lists.osuosl.org
> http://lists.osuosl.org/mailman/listinfo/intel-wired-lan
