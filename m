From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH v3 net 2/2] net: ixgbe: Use new
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Mon, 21 Aug 2017 17:36:29 +0000
Message-ID: <87618083B2453E4A8714035B62D67992B4095D65@FMSMSX105.amr.corp.intel.com>
References: <1503037265-11144-1-git-send-email-dingtianhong@huawei.com>
 <1503037265-11144-3-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Ding Tianhong <dingtianhong@huawei.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "keescook@chromium.org" <keescook@chromium.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linuxarm@huawei.com" <linuxarm@huawei.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1503037265-11144-3-git-send-email-dingtianhong@huawei.com>
Content-Language: en-US
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: linux-kernel-owner@vger.kernel.org [mailto:linux-kernel-
>owner@vger.kernel.org] On Behalf Of Ding Tianhong
>Sent: Thursday, August 17, 2017 11:21 PM
>To: davem@davemloft.net; Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>;
>keescook@chromium.org; linux-kernel@vger.kernel.org;
>sparclinux@vger.kernel.org; intel-wired-lan@lists.osuosl.org;
>alexander.duyck@gmail.com; netdev@vger.kernel.org; linuxarm@huawei.com
>Cc: Ding Tianhong <dingtianhong@huawei.com>
>Subject: [PATCH v3 net 2/2] net: ixgbe: Use new
>PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
>
>The ixgbe driver use the compile check to determine if it can
>send TLPs to Root Port with the Relaxed Ordering Attribute set,
>this is too inconvenient, now the new flag
>PCI_DEV_FLAGS_NO_RELAXED_ORDERING
>has been added to the kernel and we could check the bit4 in the PCIe
>Device Control register to determine whether we should use the Relaxed
>Ordering Attributes or not, so use this new way in the ixgbe driver.
>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>---
> drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  | 22 ---------------------
>-
> drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 19 -------------------
> 2 files changed, 41 deletions(-)

This change looks good to me for ixgbe.

Acked-by: Emil Tantilov <emil.s.tantilov@intel.com>

Thanks,
Emil 
 
>
>diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
>b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
>index 523f9d0..8a32eb7 100644
>--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
>+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
>@@ -175,31 +175,9 @@ static s32 ixgbe_init_phy_ops_82598(struct ixgbe_hw
>*hw)
>  **/
> static s32 ixgbe_start_hw_82598(struct ixgbe_hw *hw)
> {
>-#ifndef CONFIG_SPARC
>-	u32 regval;
>-	u32 i;
>-#endif
> 	s32 ret_val;
>
> 	ret_val = ixgbe_start_hw_generic(hw);
>-
>-#ifndef CONFIG_SPARC
>-	/* Disable relaxed ordering */
>-	for (i = 0; ((i < hw->mac.max_tx_queues) &&
>-	     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
>-		regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(i));
>-		regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
>-		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(i), regval);
>-	}
>-
>-	for (i = 0; ((i < hw->mac.max_rx_queues) &&
>-	     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
>-		regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
>-		regval &= ~(IXGBE_DCA_RXCTRL_DATA_WRO_EN |
>-			    IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
>-		IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
>-	}
>-#endif
> 	if (ret_val)
> 		return ret_val;
>
>diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
>b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
>index d4933d2..96c324f 100644
>--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
>+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
>@@ -350,25 +350,6 @@ s32 ixgbe_start_hw_gen2(struct ixgbe_hw *hw)
> 	}
> 	IXGBE_WRITE_FLUSH(hw);
>
>-#ifndef CONFIG_SPARC
>-	/* Disable relaxed ordering */
>-	for (i = 0; i < hw->mac.max_tx_queues; i++) {
>-		u32 regval;
>-
>-		regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL_82599(i));
>-		regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
>-		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(i), regval);
>-	}
>-
>-	for (i = 0; i < hw->mac.max_rx_queues; i++) {
>-		u32 regval;
>-
>-		regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
>-		regval &= ~(IXGBE_DCA_RXCTRL_DATA_WRO_EN |
>-			    IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
>-		IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
>-	}
>-#endif
> 	return 0;
> }
>
>--
>1.8.3.1
>

