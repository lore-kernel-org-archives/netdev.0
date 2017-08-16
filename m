From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net 2/2] net: ixgbe: Use new IXGBE_FLAG2_ROOT_NO_RELAXED_ORDERING
 flag
Date: Wed, 16 Aug 2017 11:17:29 -0700
Message-ID: <CAKgT0UehVMW65WqDGk1n7o3Qw+op3e_AqDQ3WB8F046PCmGdvw@mail.gmail.com>
References: <1502876507-9360-1-git-send-email-dingtianhong@huawei.com> <1502876507-9360-3-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Kees Cook <keescook@chromium.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        sparclinux@vger.kernel.org,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1502876507-9360-3-git-send-email-dingtianhong@huawei.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 16, 2017 at 2:41 AM, Ding Tianhong <dingtianhong@huawei.com> wrote:
> The ixgbe driver use the compile check to determine if it can
> send TLPs to Root Port with the Relaxed Ordering Attribute set,
> this is too inconvenient, now the new flag PCI_DEV_FLAGS_NO_RELAXED_ORDERING
> has been added to the kernel and we could check the bit4 in the PCIe
> Davice Control register to determine whether we should use the Relaxed
> Ordering Attributes or not, so we add a new flag which called
> IXGBE_FLAG2_ROOT_NO_RELAXED_ORDERING to the ixgbe driver, it will
> be set if the Root Port couldn't deal the upstream TLPs with Relaxed
> Ordering Attribute, then the driver could know what to do next.
>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

I would say this is a good start but you probably don't even need the
IXGBE_FLAG2 bit. The hardware will honor the PCIe configuration space.
So I would just say you should probably drop the checks all together
and just strip the #ifdef CONFIG_SPARC bits. It should make the
resultant patch quite small and have the exact same effect.

> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h        |  1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  | 37 ++++++++++++-------------
>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 32 +++++++++++----------
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   | 17 ++++++++++++
>  4 files changed, 53 insertions(+), 34 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> index dd55787..50e0553 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> @@ -621,6 +621,7 @@ struct ixgbe_adapter {
>  #define IXGBE_FLAG2_EEE_CAPABLE                        BIT(14)
>  #define IXGBE_FLAG2_EEE_ENABLED                        BIT(15)
>  #define IXGBE_FLAG2_RX_LEGACY                  BIT(16)
> +#define IXGBE_FLAG2_ROOT_NO_RELAXED_ORDERING   BIT(17)
>
>         /* Tx fast path data */
>         int num_tx_queues;
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
> index 523f9d0..0727a30 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
> @@ -175,31 +175,30 @@ static s32 ixgbe_init_phy_ops_82598(struct ixgbe_hw *hw)
>   **/
>  static s32 ixgbe_start_hw_82598(struct ixgbe_hw *hw)
>  {
> -#ifndef CONFIG_SPARC
> -       u32 regval;
> -       u32 i;
> -#endif
> +       u32 regval, i;
>         s32 ret_val;
> +       struct ixgbe_adapter *adapter = hw->back;
>
>         ret_val = ixgbe_start_hw_generic(hw);
>
> -#ifndef CONFIG_SPARC
> -       /* Disable relaxed ordering */
> -       for (i = 0; ((i < hw->mac.max_tx_queues) &&
> -            (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
> -               regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(i));
> -               regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
> -               IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(i), regval);
> -       }
> +       if (adapter->flags2 & IXGBE_FLAG2_ROOT_NO_RELAXED_ORDERING) {
> +               /* Disable relaxed ordering */
> +               for (i = 0; ((i < hw->mac.max_tx_queues) &&
> +                    (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
> +                       regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(i));
> +                       regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
> +                       IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(i), regval);
> +               }
>
> -       for (i = 0; ((i < hw->mac.max_rx_queues) &&
> -            (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
> -               regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
> -               regval &= ~(IXGBE_DCA_RXCTRL_DATA_WRO_EN |
> -                           IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
> -               IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
> +               for (i = 0; ((i < hw->mac.max_rx_queues) &&
> +                    (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
> +                       regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
> +                       regval &= ~(IXGBE_DCA_RXCTRL_DATA_WRO_EN |
> +                                   IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
> +                       IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
> +               }
>         }
> -#endif
> +
>         if (ret_val)
>                 return ret_val;
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> index d4933d2..2473c0b 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> @@ -342,6 +342,7 @@ s32 ixgbe_start_hw_generic(struct ixgbe_hw *hw)
>  s32 ixgbe_start_hw_gen2(struct ixgbe_hw *hw)
>  {
>         u32 i;
> +       struct ixgbe_adapter *adapter = hw->back;
>
>         /* Clear the rate limiters */
>         for (i = 0; i < hw->mac.max_tx_queues; i++) {
> @@ -350,25 +351,26 @@ s32 ixgbe_start_hw_gen2(struct ixgbe_hw *hw)
>         }
>         IXGBE_WRITE_FLUSH(hw);
>
> -#ifndef CONFIG_SPARC
> -       /* Disable relaxed ordering */
> -       for (i = 0; i < hw->mac.max_tx_queues; i++) {
> -               u32 regval;
> +       if (adapter->flags2 & IXGBE_FLAG2_ROOT_NO_RELAXED_ORDERING) {
> +               /* Disable relaxed ordering */
> +               for (i = 0; i < hw->mac.max_tx_queues; i++) {
> +                       u32 regval;
>
> -               regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL_82599(i));
> -               regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
> -               IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(i), regval);
> -       }
> +                       regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL_82599(i));
> +                       regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
> +                       IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(i), regval);
> +               }
>
> -       for (i = 0; i < hw->mac.max_rx_queues; i++) {
> -               u32 regval;
> +               for (i = 0; i < hw->mac.max_rx_queues; i++) {
> +                       u32 regval;
>
> -               regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
> -               regval &= ~(IXGBE_DCA_RXCTRL_DATA_WRO_EN |
> -                           IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
> -               IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
> +                       regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
> +                       regval &= ~(IXGBE_DCA_RXCTRL_DATA_WRO_EN |
> +                                   IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
> +                       IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
> +               }
>         }
> -#endif
> +
>         return 0;
>  }
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index f1dbdf2..f576be7 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -10081,6 +10081,23 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>                 goto err_ioremap;
>         }
>
> +       /* If possible, we use PCIe Relaxed Ordering Attribute to deliver
> +        * Ingress Packet Data to Free List Buffers in order to allow for
> +        * chipset performance optimizations between the Root Complex and
> +        * Memory Controllers.  (Messages to the associated Ingress Queue
> +        * notifying new Packet Placement in the Free Lists Buffers will be
> +        * send without the Relaxed Ordering Attribute thus guaranteeing that
> +        * all preceding PCIe Transaction Layer Packets will be processed
> +        * first.)  But some Root Complexes have various issues with Upstream
> +        * Transaction Layer Packets with the Relaxed Ordering Attribute set.
> +        * The PCIe devices which under the Root Complexes will be cleared the
> +        * Relaxed Ordering bit in the configuration space, So we check our
> +        * PCIe configuration space to see if it's flagged with advice against
> +        * using Relaxed Ordering.
> +        */
> +       if (!pcie_relaxed_ordering_enabled(pdev))
> +               adapter->flags2 |= IXGBE_FLAG2_ROOT_NO_RELAXED_ORDERING;
> +
>         netdev->netdev_ops = &ixgbe_netdev_ops;
>         ixgbe_set_ethtool_ops(netdev);
>         netdev->watchdog_timeo = 5 * HZ;
> --
> 1.8.3.1
>
>
