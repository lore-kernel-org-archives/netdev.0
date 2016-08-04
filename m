From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Thu, 4 Aug 2016 12:55:41 -0500
Message-ID: <20160804175541.GA2832@rob-hp-laptop>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, andrew@lunn.ch,
	bjorn.andersson@linaro.org, mlangsdo@redhat.com, jcm@redhat.com,
	agross@codeaurora.org, davem@davemloft.net, f.fainelli@gmail.com,
	LinoSanfilippo@gmx.de
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 03, 2016 at 03:12:23PM -0500, Timur Tabi wrote:
> Add supports for ethernet controller HW on Qualcomm Technologies, Inc. SoC.
> This driver supports the following features:
> 1) Checksum offload.
> 2) Interrupt coalescing support.
> 3) SGMII phy.
> 4) phylib interface for external phy
> 
> Based on original work by
> 	Niranjana Vishwanathapura <nvishwan@codeaurora.org>
> 	Gilad Avidov <gavidov@codeaurora.org>
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>
> ---
> 
> v7:
>  - add "phy-version" to DT docs
>  - remove emac_status_bits, use mutexes instead of polling a status bit
>  - test return code from dma_map_single() calls
>  - use __netdev_alloc_skb_ip_align instead of dev_alloc_skb
>  - add a missing free_irq on an error path
>  - return an error code from emac_reinit_locked
>  - support setting the MTU even when the interface is down
>  - use a spinlock not a mutex in emac_get_stats64
>  - don't redundantly set the ethernet device name
>  - remove all hardware timestamp code, since it's incomplete
>  - remove redundant 'reset' param to emac_mac_down()
>  - handle queue throttling properly
> 
> v6:
>  - Properly ordered local variables
>  - use built-in GEN_MASK instead of BITS_MASK
>  - remove redundant call to emac_rx_mode_set from emac_mac_up
>  - removed emac_rfd structure, use dma_addr_t directly instead
>  - removed emac_mac_speed enun, replaced with macros
>  - removed superfluous phy_stop from emac_mac_down(), which prevented reloading module
>  - add missing netif_napi_del
>  - set the DMA mask
> 
> v5:
>  - changed author to Timur, added MAINTAINERS entry
>  - use phylib, replacing internal phy code
>  - added support for EMAC internal SGMII v2
>  - fix ~DIS_INT warning
>  - update DT bindings, including removing unused properties
>  - removed interrupt handler for internal sgmii
>  - removed link status check handler/state (replaced with phylib)
>  - removed periodic timer handler (replaced with phylib)
>  - removed power management code (will be rewritten later)
>  - external phy is now required, not optional
>  - removed redundant EMAC_STATUS_DOWN status flag
>  - removed redundant link status and speed variables
>  - removed redundant status bits (vlan strip, promiscuous, loopback, etc)
>  - removed useless watchdog status
>  - removed command-line parameters
>  - cleaned up probe messages
>  - removed redundant params from emac_sgmii_link_init()
>  - always call netdev_completed_queue() (per review comment)
>  - fix emac_napi_rtx() (per review comment)
>  - removed max_ints loop in interrupt handler
>  - removed redundant mutex around phy read/write calls
>  - added lock for reading emac status (per review comment)
>  - generate random MAC address if it can't be read from firmware
>  - replace EMAC_DMA_ADDR_HI/LO with upper/lower_32_bits
>  - don't test return value from platform_get_resource (per review comment)
>  - use net_warn_ratelimited (per review comment)
>  - don't set the dma masks (will be set by DT or IORT code)
>  - remove unused emac_tx_tpd_ts_save()
>  - removed redundant local MTU variable
> 
> v4:
>  - add missing ipv6 header file
>  - correct compatible string
>  - fix spacing in emac_reg_write arrays
>  - drop unnecessary cell-index property
>  - remove unsupported DT properties from docs
>  - remove GPIO initialization and update docs
> 
> v3:
>  - remove most of the memory barriers by using the non xxx_relaxed() api.
>  - remove RSS and WOL support.
>  - correct comments from physical address to dma address.
>  - rearrange structs to make them packed.
>  - replace polling loops with readl_poll_timeout().
>  - remove unnecessary wrapper functions from phy layer.
>  - add blank line before return statements.
>  - set to null clocks after clk_put().
>  - use module_platform_driver() and dma_set_mask_and_coherent()
>  - replace long hex bitmasks with BIT() macro.
> 
> v2:
>  - replace hw bit fields to macros with bitwise operations.
>  - change all iterators to unsized types (int)
>  - some minor code flow improvements.
>  - change return type to void for functions which return value is never
>    used.
>  - replace instance of xxxxl_relaxed() io followed by mb() with a
>    readl()/writel().
> 
>  .../devicetree/bindings/net/qcom-emac.txt          |   66 +
>  MAINTAINERS                                        |    6 +
>  drivers/net/ethernet/qualcomm/Kconfig              |   11 +
>  drivers/net/ethernet/qualcomm/Makefile             |    2 +
>  drivers/net/ethernet/qualcomm/emac/Makefile        |    7 +
>  drivers/net/ethernet/qualcomm/emac/emac-mac.c      | 1511 ++++++++++++++++++++
>  drivers/net/ethernet/qualcomm/emac/emac-mac.h      |  251 ++++
>  drivers/net/ethernet/qualcomm/emac/emac-phy.c      |  211 +++
>  drivers/net/ethernet/qualcomm/emac/emac-phy.h      |   32 +
>  drivers/net/ethernet/qualcomm/emac/emac-sgmii.c    |  700 +++++++++
>  drivers/net/ethernet/qualcomm/emac/emac-sgmii.h    |   24 +
>  drivers/net/ethernet/qualcomm/emac/emac.c          |  786 ++++++++++
>  drivers/net/ethernet/qualcomm/emac/emac.h          |  356 +++++
>  13 files changed, 3963 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/qcom-emac.txt
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/Makefile
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-mac.c
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-mac.h
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-phy.c
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-phy.h
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-sgmii.h
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac.c
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac.h
> 
> diff --git a/Documentation/devicetree/bindings/net/qcom-emac.txt b/Documentation/devicetree/bindings/net/qcom-emac.txt
> new file mode 100644
> index 0000000..ecf36cc
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/qcom-emac.txt
> @@ -0,0 +1,66 @@
> +Qualcomm EMAC Gigabit Ethernet Controller
> +
> +Required properties:
> +- compatible : Should be "qcom,fsm9900-emac".
> +- reg : Offset and length of the register regions for the device
> +- reg-names : Register region names referenced in 'reg' above.
> +	Required register resource entries are:
> +	"base"   : EMAC controller base register block.
> +	"csr"    : EMAC wrapper register block.
> +	"sgmii"  : EMAC SGMII PHY register block.
> +	Optional register resource entries are:
> +	"ptp"    : EMAC PTP (1588) register block.
> +- interrupts : Interrupt numbers used by this controller
> +- interrupt-names : Interrupt resource names referenced in 'interrupts' above.
> +	Required interrupt resource entries are:
> +	"emac_core0"   : EMAC core0 interrupt.
> +	"sgmii_irq"   : EMAC SGMII interrupt.
> +- mac-address               : The 6-byte MAC address. If present, it is the
> +			      default MAC address.
> +
> +Optional properties:
> +- phy-version : the version of the integrated emac phy, either 1 or 2.

Sounds like 2 different h/w. The compatible property should distinguish 
this.

Rob
