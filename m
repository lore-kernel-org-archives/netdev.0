From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v4 4/4] drivers: net: Add APM X-Gene SoC ethernet driver support.
Date: Mon, 5 May 2014 15:17:15 -0700
Message-ID: <CAGVrzcb2-dYYU4-F5qiLxj8B7CJiwyxekG1jXqG9H223BaG-xw@mail.gmail.com>
References: <1399326447-2329-1-git-send-email-isubramanian@apm.com> <1399326447-2329-5-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	jcm@redhat.com, Greg KH <gregkh@linuxfoundation.org>,
	patches@apm.com,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Keyur Chudgar <kchudgar@apm.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Ravi Patel <rapatel@apm.com>
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399326447-2329-5-git-send-email-isubramanian@apm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-05-05 14:47 GMT-07:00 Iyappan Subramanian <isubramanian@apm.com>:
> This patch adds network driver for APM X-Gene SoC ethernet.
>
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> Signed-off-by: Ravi Patel <rapatel@apm.com>
> Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
> ---
>  drivers/net/ethernet/Kconfig                     |    1 +
>  drivers/net/ethernet/Makefile                    |    1 +
>  drivers/net/ethernet/apm/Kconfig                 |    1 +
>  drivers/net/ethernet/apm/Makefile                |    5 +
>  drivers/net/ethernet/apm/xgene/Kconfig           |    9 +
>  drivers/net/ethernet/apm/xgene/Makefile          |    6 +
>  drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   |  807 +++++++++++++++++++
>  drivers/net/ethernet/apm/xgene/xgene_enet_hw.h   |  353 ++++++++
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.c |  936 ++++++++++++++++++++++
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.h |  131 +++
>  10 files changed, 2250 insertions(+)
>  create mode 100644 drivers/net/ethernet/apm/Kconfig
>  create mode 100644 drivers/net/ethernet/apm/Makefile
>  create mode 100644 drivers/net/ethernet/apm/xgene/Kconfig
>  create mode 100644 drivers/net/ethernet/apm/xgene/Makefile
>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.c
>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.h
>
> diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
> index 39b26fe..871a438 100644
> --- a/drivers/net/ethernet/Kconfig
> +++ b/drivers/net/ethernet/Kconfig
> @@ -24,6 +24,7 @@ source "drivers/net/ethernet/allwinner/Kconfig"
>  source "drivers/net/ethernet/alteon/Kconfig"
>  source "drivers/net/ethernet/altera/Kconfig"
>  source "drivers/net/ethernet/amd/Kconfig"
> +source "drivers/net/ethernet/apm/Kconfig"
>  source "drivers/net/ethernet/apple/Kconfig"
>  source "drivers/net/ethernet/arc/Kconfig"
>  source "drivers/net/ethernet/atheros/Kconfig"
> diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
> index 545d0b3..291df52 100644
> --- a/drivers/net/ethernet/Makefile
> +++ b/drivers/net/ethernet/Makefile
> @@ -10,6 +10,7 @@ obj-$(CONFIG_NET_VENDOR_ALLWINNER) += allwinner/
>  obj-$(CONFIG_NET_VENDOR_ALTEON) += alteon/
>  obj-$(CONFIG_ALTERA_TSE) += altera/
>  obj-$(CONFIG_NET_VENDOR_AMD) += amd/
> +obj-$(CONFIG_NET_XGENE) += apm/
>  obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
>  obj-$(CONFIG_NET_VENDOR_ARC) += arc/
>  obj-$(CONFIG_NET_VENDOR_ATHEROS) += atheros/
> diff --git a/drivers/net/ethernet/apm/Kconfig b/drivers/net/ethernet/apm/Kconfig
> new file mode 100644
> index 0000000..ec63d70
> --- /dev/null
> +++ b/drivers/net/ethernet/apm/Kconfig
> @@ -0,0 +1 @@
> +source "drivers/net/ethernet/apm/xgene/Kconfig"
> diff --git a/drivers/net/ethernet/apm/Makefile b/drivers/net/ethernet/apm/Makefile
> new file mode 100644
> index 0000000..65ce32a
> --- /dev/null
> +++ b/drivers/net/ethernet/apm/Makefile
> @@ -0,0 +1,5 @@
> +#
> +# Makefile for APM X-GENE Ethernet driver.
> +#
> +
> +obj-$(CONFIG_NET_XGENE) += xgene/
> diff --git a/drivers/net/ethernet/apm/xgene/Kconfig b/drivers/net/ethernet/apm/xgene/Kconfig
> new file mode 100644
> index 0000000..616dff6
> --- /dev/null
> +++ b/drivers/net/ethernet/apm/xgene/Kconfig
> @@ -0,0 +1,9 @@
> +config NET_XGENE
> +       tristate "APM X-Gene SoC Ethernet Driver"
> +       select PHYLIB
> +       help
> +         This is the Ethernet driver for the on-chip ethernet interface on the
> +         APM X-Gene SoC.
> +
> +         To compile this driver as a module, choose M here. This module will
> +         be called xgene_enet.
> diff --git a/drivers/net/ethernet/apm/xgene/Makefile b/drivers/net/ethernet/apm/xgene/Makefile
> new file mode 100644
> index 0000000..60de5fa
> --- /dev/null
> +++ b/drivers/net/ethernet/apm/xgene/Makefile
> @@ -0,0 +1,6 @@
> +#
> +# Makefile for APM X-Gene Ethernet Driver.
> +#
> +
> +xgene-enet-objs := xgene_enet_hw.o xgene_enet_main.o
> +obj-$(CONFIG_NET_XGENE) += xgene-enet.o
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> new file mode 100644
> index 0000000..421a841
> --- /dev/null
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> @@ -0,0 +1,807 @@
> +/* Applied Micro X-Gene SoC Ethernet Driver
> + *
> + * Copyright (c) 2014, Applied Micro Circuits Corporation
> + * Authors: Iyappan Subramanian <isubramanian@apm.com>
> + *         Ravi Patel <rapatel@apm.com>
> + *         Keyur Chudgar <kchudgar@apm.com>
> + *
> + * This program is free software; you can redistribute  it and/or modify it
> + * under  the terms of  the GNU General  Public License as published by the
> + * Free Software Foundation;  either version 2 of the  License, or (at your
> + * option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program.  If not, see <http://www.gnu.org/licenses/>.
> + */
> +
> +#include "xgene_enet_main.h"
> +#include "xgene_enet_hw.h"
> +
> +struct xgene_enet_desc_info desc_info[MAX_DESC_INFO_INDEX] = {
> +       [USERINFO] = {0, USERINFO_POS, USERINFO_LEN},
> +       [FPQNUM] = {0, FPQNUM_POS, FPQNUM_LEN},
> +       [STASH] = {0, STASH_POS, STASH_LEN},
> +       [DATAADDR] = {1, DATAADDR_POS, DATAADDR_LEN},
> +       [BUFDATALEN] = {1, BUFDATALEN_POS, BUFDATALEN_LEN},
> +       [BUFLEN] = {1, BUFLEN_POS, BUFLEN_LEN},
> +       [COHERENT] = {1, COHERENT_POS, COHERENT_LEN},
> +       [TCPHDR] = {3, TCPHDR_POS, TCPHDR_LEN},
> +       [IPHDR] = {3, IPHDR_POS, IPHDR_LEN},
> +       [ETHHDR] = {3, ETHHDR_POS, ETHHDR_LEN},
> +       [EC] = {3, EC_POS, EC_LEN},
> +       [IS] = {3, IS_POS, IS_LEN},
> +       [IC] = {3, IC_POS, IC_LEN},
> +       [TYPESEL] = {3, TYPESEL_POS, TYPESEL_LEN},
> +       [HENQNUM] = {3, HENQNUM_POS, HENQNUM_LEN},
> +};
> +
> +void set_desc(void *desc_ptr, enum desc_info_index index, u64 val)
> +{
> +       u64 *desc;
> +       u8 i, start_bit, len;
> +       u64 mask;
> +
> +       desc = desc_ptr;
> +       i = desc_info[index].word_index;
> +       start_bit = desc_info[index].start_bit;
> +       len = desc_info[index].len;
> +       mask = GENMASK_ULL((start_bit + len - 1), start_bit);
> +       desc[i] = (desc[i] & ~mask) | ((val << start_bit) & mask);
> +}

Woah, this is the most interesting way I have seen to abstract
bitfields/masks differences... Can't you just have a different
set_desc()/get_desc() implementation in case you need to handle a
different version of the hardware that has different bits inside its
descriptor? Looking up the bits/masks in a table in a hot-path sounds
sub-optimal to me.

[snip]

> +
> +static u32 xgene_enet_wr_indirect(void *addr, void *wr, void *cmd,
> +                                 void *cmd_done, u32 wr_addr, u32 wr_data)
> +{
> +       u32 cmd_done_val;
> +
> +       iowrite32(wr_addr, addr);
> +       iowrite32(wr_data, wr);
> +       iowrite32(XGENE_ENET_WR_CMD, cmd);
> +       udelay(5);              /* wait 5 us for completion */
> +       cmd_done_val = ioread32(cmd_done);
> +       iowrite32(0, cmd);
> +       return cmd_done_val;

Is not there a bit you could busy wait on to complete this operation?
Is there any guarantee that after waiting 5 micro-seconds you get a
correct value?

> +}
> +
> +static void xgene_enet_wr_mcx_mac(struct xgene_enet_pdata *pdata,
> +                                 u32 wr_addr, u32 wr_data)
> +{
> +       void *addr, *wr, *cmd, *cmd_done;
> +       int ret;
> +
> +       addr = pdata->mcx_mac_addr + MAC_ADDR_REG_OFFSET;
> +       wr = pdata->mcx_mac_addr + MAC_WRITE_REG_OFFSET;
> +       cmd = pdata->mcx_mac_addr + MAC_COMMAND_REG_OFFSET;
> +       cmd_done = pdata->mcx_mac_addr + MAC_COMMAND_DONE_REG_OFFSET;
> +
> +       ret = xgene_enet_wr_indirect(addr, wr, cmd, cmd_done, wr_addr, wr_data);
> +       if (!ret)
> +               netdev_err(pdata->ndev, "MCX mac write failed, addr: %04x\n",
> +                          wr_addr);
> +}
> +
> +static void xgene_enet_rd_csr(struct xgene_enet_pdata *pdata,
> +                             u32 offset, u32 *val)
> +{
> +       void *addr = pdata->eth_csr_addr + offset;
> +
> +       *val = ioread32(addr);
> +}
> +
> +static void xgene_enet_rd_diag_csr(struct xgene_enet_pdata *pdata,
> +                                  u32 offset, u32 *val)
> +{
> +       void *addr = pdata->eth_diag_csr_addr + offset;
> +
> +       *val = ioread32(addr);
> +}
> +
> +static void xgene_enet_rd_mcx_csr(struct xgene_enet_pdata *pdata,
> +                                 u32 offset, u32 *val)
> +{
> +       void *addr = pdata->mcx_mac_csr_addr + offset;
> +
> +       *val = ioread32(addr);
> +}
> +
> +static u32 xgene_enet_rd_indirect(void *addr, void *rd, void *cmd,
> +                                 void *cmd_done, u32 rd_addr, u32 *rd_data)
> +{
> +       u32 cmd_done_val;
> +
> +       iowrite32(rd_addr, addr);
> +       iowrite32(XGENE_ENET_RD_CMD, cmd);
> +       udelay(5);              /* wait 5 us for completion */
> +       cmd_done_val = ioread32(cmd_done);
> +       *rd_data = ioread32(rd);
> +       iowrite32(0, cmd);
> +
> +       return cmd_done_val;
> +}
> +
> +static void xgene_enet_rd_mcx_mac(struct xgene_enet_pdata *pdata,
> +                                 u32 rd_addr, u32 *rd_data)
> +{
> +       void *addr, *rd, *cmd, *cmd_done;
> +       int ret;
> +
> +       addr = pdata->mcx_mac_addr + MAC_ADDR_REG_OFFSET;
> +       rd = pdata->mcx_mac_addr + MAC_READ_REG_OFFSET;
> +       cmd = pdata->mcx_mac_addr + MAC_COMMAND_REG_OFFSET;
> +       cmd_done = pdata->mcx_mac_addr + MAC_COMMAND_DONE_REG_OFFSET;
> +
> +       ret = xgene_enet_rd_indirect(addr, rd, cmd, cmd_done, rd_addr, rd_data);
> +       if (!ret)
> +               netdev_err(pdata->ndev, "MCX mac read failed, addr: %04x\n",
> +                          rd_addr);
> +}
> +
> +static void xgene_enet_rd_mcx_stats(struct xgene_enet_pdata *pdata,
> +                                   u32 rd_addr, u32 *rd_data)
> +{
> +       void *addr, *rd, *cmd, *cmd_done;
> +       int ret;
> +
> +       addr = pdata->mcx_stats_addr + STAT_ADDR_REG_OFFSET;
> +       rd = pdata->mcx_stats_addr + STAT_READ_REG_OFFSET;
> +       cmd = pdata->mcx_stats_addr + STAT_COMMAND_REG_OFFSET;
> +       cmd_done = pdata->mcx_stats_addr + STAT_COMMAND_DONE_REG_OFFSET;
> +
> +       ret = xgene_enet_rd_indirect(addr, rd, cmd, cmd_done, rd_addr, rd_data);
> +       if (!ret)
> +               netdev_err(pdata->ndev, "MCX stats read failed, addr: %04x\n",
> +                          rd_addr);
> +}
> +
> +void xgene_genericmiiphy_write(struct xgene_enet_pdata *pdata, int phy_id,
> +                              u32 reg, u16 data)
> +{

The name could probably be shortened to something like xgen_mii_phy_write()?

> +       u32 addr = 0, wr_data = 0, done;
> +
> +       PHY_ADDR_SET(&addr, phy_id);
> +       REG_ADDR_SET(&addr, reg);
> +       xgene_enet_wr_mcx_mac(pdata, MII_MGMT_ADDRESS_ADDR, addr);
> +
> +       PHY_CONTROL_SET(&wr_data, data);
> +       xgene_enet_wr_mcx_mac(pdata, MII_MGMT_CONTROL_ADDR, wr_data);
> +
> +       usleep_range(20, 30);           /* wait 20 us for completion */
> +       xgene_enet_rd_mcx_mac(pdata, MII_MGMT_INDICATORS_ADDR, &done);
> +       if (done & BUSY_MASK)
> +               netdev_err(pdata->ndev, "MII_MGMT write failed\n");

Please propagate the error to the caller in case you fail the write operation.

> +}
> +
> +void xgene_genericmiiphy_read(struct xgene_enet_pdata *pdata, u8 phy_id,
> +                             u32 reg, u32 *data)
> +{
> +       u32 addr = 0, done;
> +
> +       PHY_ADDR_SET(&addr, phy_id);
> +       REG_ADDR_SET(&addr, reg);
> +       xgene_enet_wr_mcx_mac(pdata, MII_MGMT_ADDRESS_ADDR, addr);
> +       xgene_enet_wr_mcx_mac(pdata, MII_MGMT_COMMAND_ADDR, READ_CYCLE_MASK);
> +
> +       usleep_range(20, 30);           /* wait 20 us for completion */
> +       xgene_enet_rd_mcx_mac(pdata, MII_MGMT_INDICATORS_ADDR, &done);
> +       if (done & BUSY_MASK)
> +               netdev_err(pdata->ndev, "MII_MGMT read failed\n");

Same here

> +
> +       xgene_enet_rd_mcx_mac(pdata, MII_MGMT_STATUS_ADDR, data);
> +       xgene_enet_wr_mcx_mac(pdata, MII_MGMT_COMMAND_ADDR, 0);
> +}
> +
> +void xgene_gmac_set_mac_addr(struct xgene_enet_pdata *pdata)
> +{
> +       u32 addr0, addr1;
> +       u8 *dev_addr = pdata->ndev->dev_addr;
> +
> +       addr0 = (dev_addr[3] << 24) | (dev_addr[2] << 16) |
> +               (dev_addr[1] << 8) | dev_addr[0];
> +       addr1 = (dev_addr[5] << 24) | (dev_addr[4] << 16);
> +       addr1 |= pdata->phy_addr & 0xFFFF;
> +
> +       xgene_enet_wr_mcx_mac(pdata, STATION_ADDR0_ADDR, addr0);
> +       xgene_enet_wr_mcx_mac(pdata, STATION_ADDR1_ADDR, addr1);
> +}
> +

[snip]

> +static void xgene_gmac_phy_enable_scan_cycle(struct xgene_enet_pdata *pdata,
> +                                            int enable)
> +{
> +       u32 val;
> +
> +       xgene_enet_rd_mcx_mac(pdata, MII_MGMT_COMMAND_ADDR, &val);
> +       SCAN_CYCLE_MASK_SET(&val, enable);
> +       xgene_enet_wr_mcx_mac(pdata, MII_MGMT_COMMAND_ADDR, val);
> +
> +       /* Program phy address start scan from 0 and register at address 0x1 */
> +       xgene_enet_rd_mcx_mac(pdata, MII_MGMT_ADDRESS_ADDR, &val);
> +       PHY_ADDR_SET(&val, 0);
> +       REG_ADDR_SET(&val, 1);

If you have a PHY polling unit which monitors the values in MII_BMSR,
please use that constant here instead of 0x1. Should not the PHY
address match what has been provided by the Device Tree? Your binding
example provides a PHY at address 3...

> +       xgene_enet_wr_mcx_mac(pdata, MII_MGMT_ADDRESS_ADDR, val);
> +}
> +
> +void xgene_gmac_reset(struct xgene_enet_pdata *pdata)
> +{
> +       xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_1_ADDR, SOFT_RESET1);
> +       xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_1_ADDR, 0);
> +}
> +
> +void xgene_gmac_init(struct xgene_enet_pdata *pdata, int speed)
> +{
> +       u32 value, mc2;
> +       u32 intf_ctl, rgmii;
> +       u32 icm0, icm2;
> +
> +       xgene_gmac_reset(pdata);
> +
> +       xgene_enet_rd_mcx_csr(pdata, ICM_CONFIG0_REG_0_ADDR, &icm0);
> +       xgene_enet_rd_mcx_csr(pdata, ICM_CONFIG2_REG_0_ADDR, &icm2);
> +       xgene_enet_rd_mcx_mac(pdata, MAC_CONFIG_2_ADDR, &mc2);
> +       xgene_enet_rd_mcx_mac(pdata, INTERFACE_CONTROL_ADDR, &intf_ctl);
> +       xgene_enet_rd_csr(pdata, RGMII_REG_0_ADDR, &rgmii);
> +
> +       switch (speed) {
> +       case SPEED_10:
> +               ENET_INTERFACE_MODE2_SET(&mc2, 1);
> +               CFG_MACMODE_SET(&icm0, 0);
> +               CFG_WAITASYNCRD_SET(&icm2, 500);
> +               rgmii &= ~CFG_SPEED_1250;
> +               break;
> +       case SPEED_100:
> +               ENET_INTERFACE_MODE2_SET(&mc2, 1);
> +               intf_ctl |= ENET_LHD_MODE;
> +               CFG_MACMODE_SET(&icm0, 1);
> +               CFG_WAITASYNCRD_SET(&icm2, 80);
> +               rgmii &= ~CFG_SPEED_1250;
> +               break;
> +       default:
> +               ENET_INTERFACE_MODE2_SET(&mc2, 2);
> +               intf_ctl |= ENET_GHD_MODE;
> +               CFG_TXCLK_MUXSEL0_SET(&rgmii, 4);
> +               xgene_enet_rd_csr(pdata, DEBUG_REG_ADDR, &value);
> +               value |= CFG_BYPASS_UNISEC_TX | CFG_BYPASS_UNISEC_RX;
> +               xgene_enet_wr_csr(pdata, DEBUG_REG_ADDR, value);
> +               break;
> +       }
> +
> +       mc2 |= FULL_DUPLEX2;
> +       xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_2_ADDR, mc2);
> +       xgene_enet_wr_mcx_mac(pdata, INTERFACE_CONTROL_ADDR, intf_ctl);
> +
> +       xgene_gmac_set_mac_addr(pdata);
> +
> +       /* Adjust MDC clock frequency */
> +       xgene_enet_rd_mcx_mac(pdata, MII_MGMT_CONFIG_ADDR, &value);
> +       MGMT_CLOCK_SEL_SET(&value, 7);
> +       xgene_enet_wr_mcx_mac(pdata, MII_MGMT_CONFIG_ADDR, value);
> +
> +       /* Enable drop if bufpool not available */
> +       xgene_enet_rd_csr(pdata, RSIF_CONFIG_REG_ADDR, &value);
> +       value |= CFG_RSIF_FPBUFF_TIMEOUT_EN;
> +       xgene_enet_wr_csr(pdata, RSIF_CONFIG_REG_ADDR, value);
> +
> +       /* Rtype should be copied from FP */
> +       xgene_enet_wr_csr(pdata, RSIF_RAM_DBG_REG0_ADDR, 0);
> +       xgene_enet_wr_csr(pdata, RGMII_REG_0_ADDR, rgmii);
> +
> +       /* Rx-Tx traffic resume */
> +       xgene_enet_wr_csr(pdata, CFG_LINK_AGGR_RESUME_0_ADDR, TX_PORT0);
> +
> +       xgene_enet_wr_mcx_csr(pdata, ICM_CONFIG0_REG_0_ADDR, icm0);
> +       xgene_enet_wr_mcx_csr(pdata, ICM_CONFIG2_REG_0_ADDR, icm2);
> +
> +       xgene_enet_rd_mcx_csr(pdata, RX_DV_GATE_REG_0_ADDR, &value);
> +       value &= ~TX_DV_GATE_EN0;
> +       value &= ~RX_DV_GATE_EN0;
> +       value |= RESUME_RX0;
> +       xgene_enet_wr_mcx_csr(pdata, RX_DV_GATE_REG_0_ADDR, value);
> +
> +       xgene_enet_wr_csr(pdata, CFG_BYPASS_ADDR, RESUME_TX);
> +}
> +
> +/* Start Statistics related functions */
> +static void xgene_gmac_get_rx_stats(struct xgene_enet_pdata *pdata,
> +                                   struct xgene_enet_rx_stats *rx_stat)
> +{
> +       xgene_enet_rd_mcx_stats(pdata, RBYT_ADDR, &rx_stat->byte_cntr);
> +       xgene_enet_rd_mcx_stats(pdata, RPKT_ADDR, &rx_stat->pkt_cntr);
> +       xgene_enet_rd_mcx_stats(pdata, RDRP_ADDR, &rx_stat->dropped_pkt_cntr);
> +       xgene_enet_rd_mcx_stats(pdata, RFCS_ADDR, &rx_stat->fcs_error_cntr);
> +       xgene_enet_rd_mcx_stats(pdata, RFLR_ADDR, &rx_stat->frm_len_err_cntr);
> +       xgene_enet_rd_mcx_stats(pdata, RALN_ADDR, &rx_stat->align_err_cntr);
> +       xgene_enet_rd_mcx_stats(pdata, ROVR_ADDR, &rx_stat->oversize_pkt_cntr);
> +       xgene_enet_rd_mcx_stats(pdata, RUND_ADDR, &rx_stat->undersize_pkt_cntr);
> +}
> +
> +static void xgene_gmac_get_tx_stats(struct xgene_enet_pdata *pdata,
> +                                   struct xgene_enet_tx_stats *tx_stats)
> +{
> +       xgene_enet_rd_mcx_stats(pdata, TBYT_ADDR, &tx_stats->byte_cntr);
> +       xgene_enet_rd_mcx_stats(pdata, TPKT_ADDR, &tx_stats->pkt_cntr);
> +       xgene_enet_rd_mcx_stats(pdata, TDRP_ADDR, &tx_stats->drop_frame_cntr);
> +       xgene_enet_rd_mcx_stats(pdata, TFCS_ADDR, &tx_stats->fcs_error_cntr);
> +       xgene_enet_rd_mcx_stats(pdata, TUND_ADDR,
> +                               &tx_stats->undersize_frame_cntr);
> +}
> +
> +void xgene_gmac_get_stats(struct xgene_enet_pdata *pdata,
> +                         struct xgene_enet_stats *stats)
> +{
> +       xgene_gmac_get_rx_stats(pdata, &stats->rx_stats);
> +       xgene_gmac_get_tx_stats(pdata, &stats->tx_stats);
> +}
> +
> +static void xgene_enet_config_ring_if_assoc(struct xgene_enet_pdata *pdata)
> +{
> +       u32 val = 0xffffffff;
> +
> +       xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIWQASSOC_ADDR, val);
> +       xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIFPQASSOC_ADDR, val);
> +       xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIQMLITEWQASSOC_ADDR, val);
> +       xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIQMLITEFPQASSOC_ADDR, val);
> +}
> +
> +void xgene_enet_cle_bypass(struct xgene_enet_pdata *pdata,
> +                          u32 dst_ring_num, u32 fpsel, u32 nxtfpsel)
> +{
> +       u32 cb;
> +
> +       xgene_enet_rd_csr(pdata, CLE_BYPASS_REG0_0_ADDR, &cb);
> +       cb |= CFG_CLE_BYPASS_EN0;
> +       CFG_CLE_IP_PROTOCOL0_SET(&cb, 3);
> +       xgene_enet_wr_csr(pdata, CLE_BYPASS_REG0_0_ADDR, cb);
> +
> +       xgene_enet_rd_csr(pdata, CLE_BYPASS_REG1_0_ADDR, &cb);
> +       CFG_CLE_DSTQID0_SET(&cb, dst_ring_num);
> +       CFG_CLE_FPSEL0_SET(&cb, fpsel);
> +       xgene_enet_wr_csr(pdata, CLE_BYPASS_REG1_0_ADDR, cb);
> +}
> +
> +void xgene_gmac_rx_enable(struct xgene_enet_pdata *pdata)
> +{
> +       u32 data;
> +
> +       xgene_enet_rd_mcx_mac(pdata, MAC_CONFIG_1_ADDR, &data);
> +       xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_1_ADDR, data | RX_EN);
> +}
> +
> +void xgene_gmac_tx_enable(struct xgene_enet_pdata *pdata)
> +{
> +       u32 data;
> +
> +       xgene_enet_rd_mcx_mac(pdata, MAC_CONFIG_1_ADDR, &data);
> +       xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_1_ADDR, data | TX_EN);
> +}
> +
> +void xgene_gmac_rx_disable(struct xgene_enet_pdata *pdata)
> +{
> +       u32 data;
> +
> +       xgene_enet_rd_mcx_mac(pdata, MAC_CONFIG_1_ADDR, &data);
> +       xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_1_ADDR, data & ~RX_EN);
> +}
> +
> +void xgene_gmac_tx_disable(struct xgene_enet_pdata *pdata)
> +{
> +       u32 data;
> +
> +       xgene_enet_rd_mcx_mac(pdata, MAC_CONFIG_1_ADDR, &data);
> +       xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_1_ADDR, data & ~TX_EN);
> +}

Do any of these functions need to be used outside of this object?

> +
> +void xgene_enet_reset(struct xgene_enet_pdata *pdata)
> +{
> +       u32 val;
> +
> +       clk_prepare_enable(pdata->clk);
> +       clk_disable_unprepare(pdata->clk);
> +       clk_prepare_enable(pdata->clk);
> +       xgene_enet_ecc_init(pdata);
> +       xgene_enet_config_ring_if_assoc(pdata);
> +
> +       /* Enable auto-incr for scanning */
> +       xgene_enet_rd_mcx_mac(pdata, MII_MGMT_CONFIG_ADDR, &val);
> +       val |= SCAN_AUTO_INCR;
> +       MGMT_CLOCK_SEL_SET(&val, 1);
> +       xgene_enet_wr_mcx_mac(pdata, MII_MGMT_CONFIG_ADDR, val);
> +       xgene_gmac_phy_enable_scan_cycle(pdata, 1);
> +}
> +
> +void xgene_gport_shutdown(struct xgene_enet_pdata *pdata)
> +{
> +       clk_disable_unprepare(pdata->clk);
> +}
> +
> +static int xgene_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
> +{
> +       struct xgene_enet_pdata *pdata = bus->priv;
> +       u32 val;
> +
> +       xgene_genericmiiphy_read(pdata, mii_id, regnum, &val);
> +       netdev_dbg(pdata->ndev, "mdio_rd: bus=%d reg=%d val=%x\n",
> +                  mii_id, regnum, val);
> +
> +       return val;
> +}
> +
> +static int xgene_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
> +                                u16 val)
> +{
> +       struct xgene_enet_pdata *pdata = bus->priv;
> +
> +       netdev_dbg(pdata->ndev, "mdio_wr: bus=%d reg=%d val=%x\n",
> +                  mii_id, regnum, val);
> +       xgene_genericmiiphy_write(pdata, mii_id, regnum, val);
> +
> +       return 0;
> +}
> +
> +static void xgene_enet_adjust_link(struct net_device *ndev)
> +{
> +       struct xgene_enet_pdata *pdata = netdev_priv(ndev);
> +       struct phy_device *phydev = pdata->phy_dev;
> +       bool status_change = false;
> +
> +       if (phydev->link && pdata->phy_speed != phydev->speed) {
> +               xgene_gmac_init(pdata, phydev->speed);
> +               pdata->phy_speed = phydev->speed;
> +               status_change = true;
> +       }
> +
> +       if (pdata->phy_link != phydev->link) {
> +               if (!phydev->link)
> +                       pdata->phy_speed = 0;
> +               pdata->phy_link = phydev->link;
> +               status_change = true;
> +       }
> +
> +       if (!status_change)
> +               goto out;

You could just use a 'return' here. Defining a label only makes sense
if multiple code-paths can jump to it.

> +
> +       if (phydev->link) {
> +               xgene_gmac_rx_enable(pdata);
> +               xgene_gmac_tx_enable(pdata);
> +       } else {
> +               xgene_gmac_rx_disable(pdata);
> +               xgene_gmac_tx_disable(pdata);
> +       }
> +       phy_print_status(phydev);
> +out:
> +       return;
> +}
> +
> +static int xgene_enet_phy_connect(struct net_device *ndev)
> +{
> +       struct xgene_enet_pdata *pdata = netdev_priv(ndev);
> +       struct device_node *phy_np;
> +       struct phy_device *phy_dev;
> +       int ret = 0;
> +
> +       struct device *dev = &pdata->pdev->dev;
> +
> +       phy_np = of_parse_phandle(dev->of_node, "phy-handle", 0);
> +
> +       if (!phy_np) {
> +               netdev_dbg(ndev, "No phy-handle found\n");
> +               ret = -ENODEV;
> +       }
> +
> +       phy_dev = of_phy_connect(ndev, phy_np, &xgene_enet_adjust_link,
> +                                0, pdata->phy_mode);
> +       if (!phy_dev) {
> +               netdev_err(ndev, "Could not connect to PHY\n");
> +               ret = -ENODEV;
> +               goto out;
> +       }
> +
> +out:
> +       pdata->phy_link = 0;
> +       pdata->phy_speed = 0;
> +       pdata->phy_dev = phy_dev;
> +
> +       return ret;
> +}
> +
> +int xgene_enet_mdio_config(struct xgene_enet_pdata *pdata)
> +{
> +       struct net_device *ndev = pdata->ndev;
> +       struct device *dev = &pdata->pdev->dev;
> +       struct device_node *child_np = NULL;
> +       struct device_node *mdio_np = NULL;
> +       struct mii_bus *mdio_bus = NULL;
> +       int ret;
> +
> +       for_each_child_of_node(dev->of_node, child_np) {
> +               if (of_device_is_compatible(child_np, "apm,xgene-mdio")) {
> +                       mdio_np = child_np;
> +                       break;
> +               }
> +       }
> +
> +       if (!mdio_np) {
> +               netdev_dbg(ndev, "No mdio node in the dts\n");
> +               ret = -1;
> +               goto err;
> +       }
> +
> +       mdio_bus = mdiobus_alloc();
> +       if (!mdio_bus) {
> +               ret = -ENOMEM;
> +               goto err;
> +       }
> +
> +       mdio_bus->name = "APM X-Gene MDIO bus";
> +       mdio_bus->read = xgene_enet_mdio_read;
> +       mdio_bus->write = xgene_enet_mdio_write;
> +       snprintf(mdio_bus->id, MII_BUS_ID_SIZE, "%s", "xgene-enet-mii");

You should a more specific name here, something that is not going to
conflict as soon as two devices will be instantiated. Something like
pdev->name or np->full_name does work.

> +
> +       mdio_bus->irq = devm_kcalloc(dev, PHY_MAX_ADDR, sizeof(int),
> +                                    GFP_KERNEL);
> +       if (mdio_bus->irq == NULL) {
> +               ret = -ENOMEM;
> +               goto err;
> +       }
> +
> +       mdio_bus->priv = pdata;
> +       mdio_bus->parent = &ndev->dev;
> +
> +       ret = of_mdiobus_register(mdio_bus, mdio_np);
> +       if (ret) {
> +               netdev_err(ndev, "Failed to register MDIO bus\n");
> +               goto err;
> +       }
> +       pdata->mdio_bus = mdio_bus;
> +       ret = xgene_enet_phy_connect(ndev);

if xgene_enet_phy_connect() fails, you are leaking the MDIO bus
structure, this ought to be:

if (ret)
      goto err;

return ret;

> +
> +       return ret;
> +err:
> +       if (mdio_bus) {
> +               if (mdio_bus->irq)
> +                       devm_kfree(dev, mdio_bus->irq);
> +               mdiobus_free(mdio_bus);
> +       }
> +       return ret;

[snip]

> +
> +irqreturn_t xgene_enet_rx_irq(const int irq, void *data)
> +{
> +       struct xgene_enet_desc_ring *rx_ring = data;
> +
> +       if (napi_schedule_prep(&rx_ring->napi)) {
> +               disable_irq_nosync(irq);

Can't you mask the relevant interrupt sources at the Ethernet
controller level instead? This can be pretty expensive in a hot-path
like this.

> +               __napi_schedule(&rx_ring->napi);
> +       }
> +
> +       return IRQ_HANDLED;
> +}
> +
> +static int xgene_enet_tx_completion(struct xgene_enet_desc_ring *cp_ring,
> +                                   struct xgene_enet_desc *desc)
> +{
> +       struct sk_buff *skb;
> +       dma_addr_t pa;
> +       size_t len;
> +       struct device *dev;
> +       u16 skb_index;
> +       int ret = 0;
> +
> +       skb_index = get_desc(desc, USERINFO);
> +       skb = cp_ring->cp_skb[skb_index];
> +
> +       dev = ndev_to_dev(cp_ring->ndev);
> +       pa = (dma_addr_t)get_desc(desc, DATAADDR);
> +       len = get_desc(desc, BUFDATALEN);
> +       dma_unmap_single(dev, pa, len, DMA_TO_DEVICE);
> +
> +       if (likely(skb)) {
> +               dev_kfree_skb_any(skb);
> +       } else {
> +               netdev_err(cp_ring->ndev, "completion skb is NULL\n");
> +               ret = -1;
> +       }
> +
> +       return ret;
> +}
> +
> +static void xgene_enet_checksum_offload(struct xgene_enet_desc *desc,
> +                                       struct sk_buff *skb)
> +{
> +       u32 maclen, nr_frags;
> +       struct iphdr *iph;
> +       u8 l4hlen = 0;
> +       u8 l3hlen = 0;
> +       u8 csum_enable = 0;
> +       u8 proto = 0;
> +       struct net_device *ndev = skb->dev;
> +
> +       if (unlikely(!(ndev->features & NETIF_F_IP_CSUM)))
> +               goto out;
> +       if (unlikely(skb->protocol != htons(ETH_P_IP)) &&
> +           unlikely(skb->protocol != htons(ETH_P_8021Q)))
> +               goto out;

No IPv6 support?

> +
> +       nr_frags = skb_shinfo(skb)->nr_frags;
> +       maclen = xgene_enet_hdr_len(skb->data);
> +       iph = ip_hdr(skb);
> +       l3hlen = ip_hdrlen(skb) >> 2;
> +
> +       if (unlikely(iph->frag_off & htons(IP_MF | IP_OFFSET)))
> +               goto out;
> +       if (likely(iph->protocol == IPPROTO_TCP)) {
> +               l4hlen = tcp_hdrlen(skb) / 4;
> +               csum_enable = 1;
> +               proto = TSO_IPPROTO_TCP;
> +       } else if (iph->protocol == IPPROTO_UDP) {
> +               l4hlen = UDP_HDR_SIZE;
> +               csum_enable = 1;
> +               proto = TSO_IPPROTO_UDP;
> +       }
> +
> +       set_desc(desc, TCPHDR, l4hlen);
> +       set_desc(desc, IPHDR, l3hlen);
> +       set_desc(desc, EC, csum_enable);
> +       set_desc(desc, IS, proto);
> +out:
> +       return;
> +}
> +
> +static int xgene_enet_setup_tx_desc(struct xgene_enet_desc_ring *tx_ring,
> +                                    struct sk_buff *skb)
> +{
> +       struct xgene_enet_desc *desc;
> +       dma_addr_t dma_addr;
> +       u8 ethhdr;
> +       u16 tail = tx_ring->tail;
> +       struct device *dev = ndev_to_dev(tx_ring->ndev);
> +
> +       desc = &tx_ring->desc[tail];
> +       memset(desc, 0, sizeof(struct xgene_enet_desc));
> +
> +       dma_addr = dma_map_single(dev, skb->data, skb->len, DMA_TO_DEVICE);
> +       if (dma_mapping_error(dev, dma_addr)) {
> +               netdev_err(tx_ring->ndev, "DMA mapping error\n");
> +               return -EINVAL;
> +       }
> +       set_desc(desc, DATAADDR, dma_addr);
> +
> +       set_desc(desc, BUFDATALEN, skb->len);
> +       set_desc(desc, COHERENT, 1);
> +       tx_ring->cp_ring->cp_skb[tail] = skb;
> +       set_desc(desc, USERINFO, tail);
> +       set_desc(desc, HENQNUM, tx_ring->dst_ring_num);
> +       set_desc(desc, TYPESEL, 1);
> +       ethhdr = xgene_enet_hdr_len(skb->data);
> +       set_desc(desc, ETHHDR, ethhdr);
> +       set_desc(desc, IC, 1);
> +
> +       xgene_enet_checksum_offload(desc, skb);
> +
> +       /* Hardware expects descriptor in little endian format */
> +       xgene_enet_cpu_to_le64(desc, 4);
> +
> +       return 0;
> +}
> +
> +static netdev_tx_t xgene_enet_start_xmit(struct sk_buff *skb,
> +                                        struct net_device *ndev)
> +{
> +       struct xgene_enet_pdata *pdata = netdev_priv(ndev);
> +       struct xgene_enet_desc_ring *tx_ring = pdata->tx_ring;
> +       struct xgene_enet_desc_ring *cp_ring = tx_ring->cp_ring;
> +       u32 tx_level, cq_level;
> +       u32 pkt_count = 1;
> +
> +       tx_level = xgene_enet_ring_len(tx_ring);
> +       cq_level = xgene_enet_ring_len(cp_ring);
> +       if (tx_level > pdata->tx_qcnt_hi || cq_level > pdata->cp_qcnt_hi) {
> +               netif_stop_queue(ndev);
> +               return NETDEV_TX_BUSY;
> +       }
> +
> +       if (xgene_enet_setup_tx_desc(tx_ring, skb))
> +               goto out;
> +
> +       skb_tx_timestamp(skb);
> +
> +       tx_ring->tail = (tx_ring->tail + 1) & (tx_ring->slots - 1);
> +       iowrite32(pkt_count, tx_ring->cmd);

You should also check the ring space at the end of the
ndo_start_xmit() call and update the TX queue flow control
appropriately.

> +out:
> +       return NETDEV_TX_OK;
> +}
> +
> +void xgene_enet_skip_csum(struct sk_buff *skb)
> +{
> +       struct iphdr *iph = (struct iphdr *)skb->data;
> +
> +       if (!(iph->frag_off & htons(IP_MF | IP_OFFSET)) ||
> +           (iph->protocol != IPPROTO_TCP && iph->protocol != IPPROTO_UDP)) {
> +               skb->ip_summed = CHECKSUM_UNNECESSARY;
> +       }
> +}
> +
> +static int xgene_enet_rx_frame(struct xgene_enet_desc_ring *rx_ring,
> +                               struct xgene_enet_desc *desc)
> +{
> +       struct net_device *ndev = rx_ring->ndev;
> +       struct device *dev = ndev_to_dev(rx_ring->ndev);
> +       struct xgene_enet_desc_ring *buf_pool = rx_ring->buf_pool;
> +       u32 datalen, skb_index;
> +       struct sk_buff *skb;
> +       dma_addr_t pa;
> +       int ret = 0;
> +
> +       skb_index = get_desc(desc, USERINFO);
> +       skb = buf_pool->rx_skb[skb_index];
> +       prefetch(skb->data - NET_IP_ALIGN);

You might be pre-fetching stale data at this point, you have not yet
called dma_unmap_single(), you probably want to move this call after
dma_unmap_single() to do anything useful with the packet contents.

> +
> +       /* Strip off CRC as HW isn't doing this */
> +       datalen = get_desc(desc, BUFDATALEN);
> +       datalen -= 4;
> +       skb_put(skb, datalen);

Don't you have any per-packet descriptor bits that tell you whether
the packet was an error packet (oversized, frame length error, fifo
error etc...).

> +
> +       pa = (dma_addr_t)get_desc(desc, DATAADDR);
> +       dma_unmap_single(dev, pa, XGENE_ENET_MAX_MTU, DMA_FROM_DEVICE);
> +
> +       if (--rx_ring->nbufpool == 0) {
> +               ret = xgene_enet_refill_bufpool(buf_pool, NUM_BUFPOOL);
> +               rx_ring->nbufpool = NUM_BUFPOOL;
> +       }
> +
> +       skb_checksum_none_assert(skb);
> +       skb->protocol = eth_type_trans(skb, ndev);
> +       if (likely((ndev->features & NETIF_F_IP_CSUM) &&
> +                  skb->protocol == htons(ETH_P_IP))) {
> +               xgene_enet_skip_csum(skb);
> +       }

Where are the RX counters increased?
-- 
Florian
