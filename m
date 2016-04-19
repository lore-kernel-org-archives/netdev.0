From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next V4 2/2] intel: ixgbevf: Support Windows hosts
 (Hyper-V)
Date: Tue, 19 Apr 2016 12:11:45 -0700
Message-ID: <CAKgT0UdT2SBYgTWwf5F9x+JPX8eWx_hMf7PE0MCnNDr-9oZaKw@mail.gmail.com>
References: <1461096698-26430-1-git-send-email-kys@microsoft.com>
 <1461096723-26471-1-git-send-email-kys@microsoft.com>
 <1461096723-26471-2-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, Netdev <netdev@vger.kernel.org>,
 Jason Wang <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 jackm@mellanox.com, yevgenyp@mellanox.com,
 John Ronciak <john.ronciak@intel.com>,
 intel-wired-lan <intel-wired-lan@lists.osuosl.org>, eli@mellanox.com,
 Robo Bot <apw@canonical.com>, devel@linuxdriverproject.org,
 David Miller <davem@davemloft.net>
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1461096723-26471-2-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Tue, Apr 19, 2016 at 1:12 PM, K. Y. Srinivasan <kys@microsoft.com> wrote:
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
>         V3: Addressed additional comments from
>             Alexander Duyck <alexander.duyck@gmail.com>
>
>         V4: Addressed kbuild errors reported by:
>             kbuild test robot <lkp@intel.com>
>
>
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   12 ++
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   31 +++-
>  drivers/net/ethernet/intel/ixgbevf/mbx.c          |   12 ++
>  drivers/net/ethernet/intel/ixgbevf/vf.c           |  216 +++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/vf.h           |    2 +
>  5 files changed, 266 insertions(+), 7 deletions(-)
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
> index 007cbe0..c4bb480 100644
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
> @@ -1795,7 +1803,10 @@ static void ixgbevf_configure_rx(struct ixgbevf_adapter *adapter)
>                 ixgbevf_setup_vfmrqc(adapter);
>
>         /* notify the PF of our intent to use this size of frame */
> -       ixgbevf_rlpml_set_vf(hw, netdev->mtu + ETH_HLEN + ETH_FCS_LEN);
> +       if (!ixgbevf_on_hyperv(hw))
> +               ixgbevf_rlpml_set_vf(hw, netdev->mtu + ETH_HLEN + ETH_FCS_LEN);
> +       else
> +               ixgbevf_hv_rlpml_set_vf(hw, netdev->mtu + ETH_HLEN + ETH_FCS_LEN);
>
>         /* Setup the HW Rx Head and Tail Descriptor Pointers and
>          * the Base and Length of the Rx Descriptor Ring
> @@ -2056,7 +2067,10 @@ static void ixgbevf_negotiate_api(struct ixgbevf_adapter *adapter)
>         spin_lock_bh(&adapter->mbx_lock);
>
>         while (api[idx] != ixgbe_mbox_api_unknown) {
> -               err = ixgbevf_negotiate_api_version(hw, api[idx]);
> +               if (!ixgbevf_on_hyperv(hw))
> +                       err = ixgbevf_negotiate_api_version(hw, api[idx]);
> +               else
> +                       err = ixgbevf_hv_negotiate_api_version(hw, api[idx]);
>                 if (!err)
>                         break;
>                 idx++;
> @@ -3727,7 +3741,10 @@ static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
>         netdev->mtu = new_mtu;
>
>         /* notify the PF of our intent to use this size of frame */
> -       ixgbevf_rlpml_set_vf(hw, max_frame);
> +       if (!ixgbevf_on_hyperv(hw))
> +               ixgbevf_rlpml_set_vf(hw, max_frame);
> +       else
> +               ixgbevf_hv_rlpml_set_vf(hw, max_frame);
>
>         return 0;
>  }
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
> index 4d613a4..8f277b9 100644
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
> @@ -126,6 +133,27 @@ static s32 ixgbevf_reset_hw_vf(struct ixgbe_hw *hw)
>  }
>
>  /**
> + * Hyper-V variant; the VF/PF communication is through the PCI
> + * config space.
> + */
> +static s32 ixgbevf_hv_reset_hw_vf(struct ixgbe_hw *hw)
> +{
> +#if IS_ENABLED(CONFIG_PCI_MMCONFIG)
> +       struct ixgbevf_adapter *adapter = hw->back;
> +       int i;
> +
> +       for (i = 0; i < 6; i++)
> +               pci_read_config_byte(adapter->pdev,
> +                                    (i + IXGBE_HV_RESET_OFFSET),
> +                                    &hw->mac.perm_addr[i]);
> +#else
> +       pr_err("PCI_MMCONFIG needs to be enabled for Hyper-V\n");
> +#endif
> +
> +       return 0;
> +}
> +

You should probably just return an error here if MMCONFIG is not
defined.  You can probably move the return into the #if/#else blocks
so that you return 0 if MMCONFIG is supported, and you return
-EOPNOTSUPP if MMCONFIG is not defined.

That way you don't have to worry about confusing the driver and having
it think that it is running with no MAC address assigned by the
administrator.

- Alex
