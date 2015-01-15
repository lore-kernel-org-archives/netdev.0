From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH] ixgbe: Re-enable relaxed ordering as part of
 init/restart sequence for non-DCA config
Date: Thu, 15 Jan 2015 00:01:24 +0000
Message-ID: <87618083B2453E4A8714035B62D67992501E1DD6@FMSMSX105.amr.corp.intel.com>
References: <20150114144009.GG19534@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Linux NICS <Linux-nics@isotope.jf.intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20150114144009.GG19534@oracle.com>
Content-Language: en-US
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Sowmini Varadhan [mailto:sowmini.varadhan@oracle.com] 
>Relaxed ordering is disabled by default at driver initialization
>and re-enabled when DCA is used. The reason it is disabled  was
>due to an issue on some chipsets (see comments in ixgbe_update_tx_dca()).
>But when DCA is not used, RO needs to be re-enabled, else we have
>a serialization bottleneck on platforms like SPARC.
>
>This patch eliminates the bottleneck for ixgbe when DCA is not configured.
>
>Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
>Cc: Emil Tantilov <emil.s.tantilov@intel.com>
>---
> drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  |    1 +
> drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |   20 ++++++++++++++++++++
> drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |    1 +
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |   11 +++++++++++
> drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |    1 +
> drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c   |    1 +
> 6 files changed, 35 insertions(+), 0 deletions(-)
>
>diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
>index c5c97b4..85c7a28 100644
>--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
>+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
>@@ -1161,6 +1161,7 @@ static struct ixgbe_mac_operations mac_ops_82598 = {
> 	.clear_hw_cntrs		= &ixgbe_clear_hw_cntrs_generic,
> 	.get_media_type		= &ixgbe_get_media_type_82598,
> 	.enable_rx_dma          = &ixgbe_enable_rx_dma_generic,
>+	.enable_relaxed_ordering = &ixgbe_enable_relaxed_ordering,

The IXGBE_DCA_TXCTRL register for 82598 is at a different offset. Also there is a limit of 16 registers. The function we have in our code for 82598 is as follows:

/**
 *  ixgbe_enable_relaxed_ordering_82598 - enable relaxed ordering
 *  @hw: pointer to hardware structure
 *
 **/
void ixgbe_enable_relaxed_ordering_82598(struct ixgbe_hw *hw)
{
	u32 regval;
	u32 i;

	/* Enable relaxed ordering */
	for (i = 0; ((i < hw->mac.max_tx_queues) &&
	     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
		regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(i));
		regval |= IXGBE_DCA_TXCTRL_DESC_WRO_EN;
		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(i), regval);
	}

	for (i = 0; ((i < hw->mac.max_rx_queues) &&
	     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
		regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
		regval |= IXGBE_DCA_RXCTRL_DATA_WRO_EN |
			  IXGBE_DCA_RXCTRL_HEAD_WRO_EN;
		IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
	}
}

Thanks,
Emil
