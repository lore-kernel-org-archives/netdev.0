From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH V7 6/7] net: sxgbe: add ethtool related functions support
 Samsung sxgbe
Date: Fri, 21 Mar 2014 08:20:41 -0700
Message-ID: <004e01cf4519$23dd0520$6b970f60$@samsung.com>
References: <00f001cf43e3$caf62580$60e27080$@samsung.com>
 <CAOwfj2MEtb8_ia+Zu429HSq4FMzwmS8VN02V7yLz4LHdHzPyrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	devicetree@vger.kernel.org, 'David Miller' <davem@davemloft.net>,
	'GIRISH K S' <ks.giri@samsung.com>,
	'SIVAREDDY KALLAM' <siva.kallam@samsung.com>,
	'Ilho Lee' <ilho215.lee@samsung.com>,
	'Vipul Chandrakant' <vipul.pandya@samsung.com>
To: 'Vince Bridgers' <vbridgers2013@gmail.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-reply-to: <CAOwfj2MEtb8_ia+Zu429HSq4FMzwmS8VN02V7yLz4LHdHzPyrQ@mail.gmail.com>
Content-language: en-us
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Vince Bridgers <vbridgers2013@gmail.com> wrote :
> On Wed, Mar 19, 2014 at 9:26 PM, Byungho An <bh74.an@samsung.com>
> wrote:
> > From: Vipul Pandya <vipul.pandya@samsung.com>
> >
> > This patch adds ethtool related functions.
> >
> > Signed-off-by: Vipul Pandya <vipul.pandya@samsung.com>
> > Neatening-by: Joe Perches <joe@perches.com>
> > Signed-off-by: Byungho An <bh74.an@samsung.com>
> > ---
> >  drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h  |   25 +-
> >  drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c |  509
> +++++++++++++++++++-
> >  drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c    |    8 +-
> >  drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h     |    6 +
> >  4 files changed, 537 insertions(+), 11 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
> > b/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
> > index f06d439..ef7dc80 100644
> > --- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
> > +++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
> > @@ -42,8 +42,12 @@ struct sxgbe_mtl_ops;
> >  #define SXGBE_RX_QUEUES   16
> >
> >  /* Max/Min RI Watchdog Timer count value */
> > -#define SXGBE_MAX_DMA_RIWT     0xff
> > -#define SXGBE_MIN_DMA_RIWT     0x20
> > +/* Calculated based how much time does it take to fill 256KB Rx
> > +memory
> > + * at 10Gb speed at 156MHz clock rate and considered little less then
> > + * the actual value.
> > + */
> > +#define SXGBE_MAX_DMA_RIWT     0x70
> > +#define SXGBE_MIN_DMA_RIWT     0x01
> >
> >  /* Tx coalesce parameters */
> >  #define SXGBE_COAL_TX_TIMER    40000
> > @@ -194,6 +198,20 @@ enum dma_irq_status {
> >  #define SXGBE_FOR_EACH_QUEUE(max_queues, queue_num)                    \
> >         for (queue_num = 0; queue_num < max_queues; queue_num++)
> >
> > +#define DRV_VERSION "1.0.0"
> > +
> > +#define SXGBE_MAX_RX_CHANNELS  16
> > +#define SXGBE_MAX_TX_CHANNELS  16
> > +
> > +#define START_MAC_REG_OFFSET   0x0000
> > +#define MAX_MAC_REG_OFFSET     0x0DFC
> > +#define START_MTL_REG_OFFSET   0x1000
> > +#define MAX_MTL_REG_OFFSET     0x18FC
> > +#define START_DMA_REG_OFFSET   0x3000
> > +#define MAX_DMA_REG_OFFSET     0x38FC
> > +
> > +#define REG_SPACE_SIZE         0x2000
> > +
> >  /* sxgbe statistics counters */
> >  struct sxgbe_extra_stats {
> >         /* TX/RX IRQ events */
> > @@ -479,6 +497,7 @@ struct sxgbe_priv_data {
> >         /* advanced time stamp support */
> >         u32 adv_ts;
> >         int use_riwt;
> > +       struct ptp_clock *ptp_clock;
> >
> >         /* tc control */
> >         int tx_tc;
> > @@ -515,4 +534,6 @@ const struct sxgbe_mtl_ops
> > *sxgbe_get_mtl_ops(void);  void sxgbe_disable_eee_mode(struct
> > sxgbe_priv_data * const priv);  bool sxgbe_eee_init(struct
> > sxgbe_priv_data * const priv);
> >
> > +int sxgbe_set_flow_ctrl(struct sxgbe_priv_data *priv, int rx, int
> > +tx);
> > +
> >  #endif /* __SXGBE_COMMON_H__ */
> > diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
> > b/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
> > index 9083300..471bc89 100644
> > --- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
> > +++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
> > @@ -12,11 +12,17 @@
> >
> >  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> >
> > +#include <linux/clk.h>
> > +#include <linux/interrupt.h>
> >  #include <linux/kernel.h>
> >  #include <linux/netdevice.h>
> > +#include <linux/net_tstamp.h>
> >  #include <linux/phy.h>
> > +#include <linux/ptp_clock_kernel.h>
> >
> >  #include "sxgbe_common.h"
> > +#include "sxgbe_reg.h"
> > +#include "sxgbe_dma.h"
> >
> >  struct sxgbe_stats {
> >         char stat_string[ETH_GSTRING_LEN]; @@ -32,16 +38,105 @@ struct
> > sxgbe_stats {  }
> >
> >  static const struct sxgbe_stats sxgbe_gstrings_stats[] = {
> > +       /* TX/RX IRQ events */
> > +       SXGBE_STAT(tx_process_stopped_irq),
> > +       SXGBE_STAT(tx_ctxt_desc_err),
> > +       SXGBE_STAT(tx_threshold),
> > +       SXGBE_STAT(rx_threshold),
> > +       SXGBE_STAT(tx_pkt_n),
> > +       SXGBE_STAT(rx_pkt_n),
> > +       SXGBE_STAT(normal_irq_n),
> > +       SXGBE_STAT(tx_normal_irq_n),
> > +       SXGBE_STAT(rx_normal_irq_n),
> > +       SXGBE_STAT(napi_poll),
> > +       SXGBE_STAT(tx_clean),
> > +       SXGBE_STAT(tx_reset_ic_bit),
> > +       SXGBE_STAT(rx_process_stopped_irq),
> > +       SXGBE_STAT(rx_underflow_irq),
> > +
> > +       /* Bus access errors */
> > +       SXGBE_STAT(fatal_bus_error_irq),
> > +       SXGBE_STAT(tx_read_transfer_err),
> > +       SXGBE_STAT(tx_write_transfer_err),
> > +       SXGBE_STAT(tx_desc_access_err),
> > +       SXGBE_STAT(tx_buffer_access_err),
> > +       SXGBE_STAT(tx_data_transfer_err),
> > +       SXGBE_STAT(rx_read_transfer_err),
> > +       SXGBE_STAT(rx_write_transfer_err),
> > +       SXGBE_STAT(rx_desc_access_err),
> > +       SXGBE_STAT(rx_buffer_access_err),
> > +       SXGBE_STAT(rx_data_transfer_err),
> > +
> > +       /* EEE-LPI stats */
> >         SXGBE_STAT(tx_lpi_entry_n),
> >         SXGBE_STAT(tx_lpi_exit_n),
> >         SXGBE_STAT(rx_lpi_entry_n),
> >         SXGBE_STAT(rx_lpi_exit_n),
> >         SXGBE_STAT(eee_wakeup_error_n),
> > +
> > +       /* RX specific */
> > +       /* L2 error */
> > +       SXGBE_STAT(rx_code_gmii_err),
> > +       SXGBE_STAT(rx_watchdog_err),
> > +       SXGBE_STAT(rx_crc_err),
> > +       SXGBE_STAT(rx_gaint_pkt_err),
> > +       SXGBE_STAT(ip_hdr_err),
> > +       SXGBE_STAT(ip_payload_err),
> > +       SXGBE_STAT(overflow_error),
> > +
> > +       /* L2 Pkt type */
> > +       SXGBE_STAT(len_pkt),
> > +       SXGBE_STAT(mac_ctl_pkt),
> > +       SXGBE_STAT(dcb_ctl_pkt),
> > +       SXGBE_STAT(arp_pkt),
> > +       SXGBE_STAT(oam_pkt),
> > +       SXGBE_STAT(untag_okt),
> > +       SXGBE_STAT(other_pkt),
> > +       SXGBE_STAT(svlan_tag_pkt),
> > +       SXGBE_STAT(cvlan_tag_pkt),
> > +       SXGBE_STAT(dvlan_ocvlan_icvlan_pkt),
> > +       SXGBE_STAT(dvlan_osvlan_isvlan_pkt),
> > +       SXGBE_STAT(dvlan_osvlan_icvlan_pkt),
> > +       SXGBE_STAT(dvan_ocvlan_icvlan_pkt),
> > +
> > +       /* L3/L4 Pkt type */
> > +       SXGBE_STAT(not_ip_pkt),
> > +       SXGBE_STAT(ip4_tcp_pkt),
> > +       SXGBE_STAT(ip4_udp_pkt),
> > +       SXGBE_STAT(ip4_icmp_pkt),
> > +       SXGBE_STAT(ip4_unknown_pkt),
> > +       SXGBE_STAT(ip6_tcp_pkt),
> > +       SXGBE_STAT(ip6_udp_pkt),
> > +       SXGBE_STAT(ip6_icmp_pkt),
> > +       SXGBE_STAT(ip6_unknown_pkt),
> > +
> > +       /* Filter specific */
> > +       SXGBE_STAT(vlan_filter_match),
> > +       SXGBE_STAT(sa_filter_fail),
> > +       SXGBE_STAT(da_filter_fail),
> > +       SXGBE_STAT(hash_filter_pass),
> > +       SXGBE_STAT(l3_filter_match),
> > +       SXGBE_STAT(l4_filter_match),
> > +
> > +       /* RX context specific */
> > +       SXGBE_STAT(timestamp_dropped),
> > +       SXGBE_STAT(rx_msg_type_no_ptp),
> > +       SXGBE_STAT(rx_ptp_type_sync),
> > +       SXGBE_STAT(rx_ptp_type_follow_up),
> > +       SXGBE_STAT(rx_ptp_type_delay_req),
> > +       SXGBE_STAT(rx_ptp_type_delay_resp),
> > +       SXGBE_STAT(rx_ptp_type_pdelay_req),
> > +       SXGBE_STAT(rx_ptp_type_pdelay_resp),
> > +       SXGBE_STAT(rx_ptp_type_pdelay_follow_up),
> > +       SXGBE_STAT(rx_ptp_announce),
> > +       SXGBE_STAT(rx_ptp_mgmt),
> > +       SXGBE_STAT(rx_ptp_signal),
> > +       SXGBE_STAT(rx_ptp_resv_msg_type),
> >  };
> >  #define SXGBE_STATS_LEN ARRAY_SIZE(sxgbe_gstrings_stats)
> >
> > -static int sxgbe_ethtool_get_eee(struct net_device *dev,
> > -                                struct ethtool_eee *edata)
> > +static int sxgbe_get_eee(struct net_device *dev,
> > +                        struct ethtool_eee *edata)
> >  {
> >         struct sxgbe_priv_data *priv = netdev_priv(dev);
> >
> > @@ -55,8 +150,8 @@ static int sxgbe_ethtool_get_eee(struct net_device
> *dev,
> >         return phy_ethtool_get_eee(priv->phydev, edata);  }
> >
> > -static int sxgbe_ethtool_set_eee(struct net_device *dev,
> > -                                struct ethtool_eee *edata)
> > +static int sxgbe_set_eee(struct net_device *dev,
> > +                        struct ethtool_eee *edata)
> >  {
> >         struct sxgbe_priv_data *priv = netdev_priv(dev);
> >
> > @@ -80,9 +175,411 @@ static int sxgbe_ethtool_set_eee(struct net_device
> *dev,
> >         return phy_ethtool_set_eee(priv->phydev, edata);  }
> >
> > +static void sxgbe_getdrvinfo(struct net_device *dev,
> > +                            struct ethtool_drvinfo *info) {
> > +       strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
> > +       strlcpy(info->version, DRV_VERSION, sizeof(info->version)); }
> > +
> > +static int sxgbe_getsettings(struct net_device *dev,
> > +                            struct ethtool_cmd *cmd) {
> > +       struct sxgbe_priv_data *priv = netdev_priv(dev);
> > +
> > +       if (priv->phydev)
> > +               return phy_ethtool_gset(priv->phydev, cmd);
> > +
> > +       return -ENODEV;
> > +}
> > +
> > +static int sxgbe_setsettings(struct net_device *dev, struct
> > +ethtool_cmd *cmd) {
> > +       struct sxgbe_priv_data *priv = netdev_priv(dev);
> > +
> > +       if (priv->phydev)
> > +               return phy_ethtool_sset(priv->phydev, cmd);
> > +
> > +       return -ENODEV;
> > +}
> > +
> > +static u32 sxgbe_getmsglevel(struct net_device *dev) {
> > +       struct sxgbe_priv_data *priv = netdev_priv(dev);
> > +       return priv->msg_enable;
> > +}
> > +
> > +static void sxgbe_setmsglevel(struct net_device *dev, u32 level) {
> > +       struct sxgbe_priv_data *priv = netdev_priv(dev);
> > +       priv->msg_enable = level;
> > +}
> > +
> > +static int sxgbe_get_ts_info(struct net_device *dev,
> > +                            struct ethtool_ts_info *info) {
> > +       struct sxgbe_priv_data *priv = netdev_priv(dev);
> > +
> > +       if (!priv->hw_cap.atime_stamp)
> > +               return ethtool_op_get_ts_info(dev, info);
> > +
> > +       info->so_timestamping = (SOF_TIMESTAMPING_TX_SOFTWARE |
> > +                                SOF_TIMESTAMPING_RX_SOFTWARE |
> > +                                SOF_TIMESTAMPING_SOFTWARE |
> > +                                SOF_TIMESTAMPING_TX_HARDWARE |
> > +                                SOF_TIMESTAMPING_RX_HARDWARE |
> > +                                SOF_TIMESTAMPING_RAW_HARDWARE);
> > +
> > +       if (priv->ptp_clock)
> > +               info->phc_index = ptp_clock_index(priv->ptp_clock);
> > +
> > +       info->tx_types = ((1 << HWTSTAMP_TX_OFF) |
> > +                         (1 << HWTSTAMP_TX_ON) |
> > +                         (1 << HWTSTAMP_TX_ONESTEP_SYNC));
> > +
> > +       info->rx_filters = ((1 << HWTSTAMP_FILTER_NONE) |
> > +                           (1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
> > +                           (1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
> > +                           (1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
> > +                           (1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT) |
> > +                           (1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC) |
> > +                           (1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ) |
> > +                           (1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT) |
> > +                           (1 << HWTSTAMP_FILTER_PTP_V2_L2_SYNC) |
> > +                           (1 << HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ) |
> > +                           (1 << HWTSTAMP_FILTER_PTP_V2_EVENT) |
> > +                           (1 << HWTSTAMP_FILTER_PTP_V2_SYNC) |
> > +                           (1 << HWTSTAMP_FILTER_PTP_V2_DELAY_REQ) |
> > +                           (1 << HWTSTAMP_FILTER_ALL));
> > +       return 0;
> > +}
> > +
> > +int sxgbe_set_flow_ctrl(struct sxgbe_priv_data *priv, int rx, int tx)
> > +{
> > +       return 0;
> > +}
> > +
> > +static void sxgbe_get_pauseparam(struct net_device *netdev,
> > +                                struct ethtool_pauseparam *pause) {
> > +       struct sxgbe_priv_data *priv = netdev_priv(netdev);
> > +
> > +       pause->rx_pause = priv->rx_pause;
> > +       pause->tx_pause = priv->tx_pause; }
> > +
> > +static int sxgbe_set_pauseparam(struct net_device *netdev,
> > +                               struct ethtool_pauseparam *pause) {
> > +       struct sxgbe_priv_data *priv = netdev_priv(netdev);
> > +
> > +       if (pause->autoneg)
> > +               return -EINVAL;
> > +
> > +       return sxgbe_set_flow_ctrl(priv, pause->rx_pause,
> > +pause->tx_pause); }
> > +
> > +
> > +
> > +static void sxgbe_get_strings(struct net_device *dev, u32 stringset,
> > +u8 *data) {
> > +       int i;
> > +       u8 *p = data;
> > +
> > +       switch (stringset) {
> > +       case ETH_SS_STATS:
> > +               for (i = 0; i < SXGBE_STATS_LEN; i++) {
> > +                       memcpy(p, sxgbe_gstrings_stats[i].stat_string,
> > +                              ETH_GSTRING_LEN);
> > +                       p += ETH_GSTRING_LEN;
> > +               }
> > +               break;
> > +       default:
> > +               WARN_ON(1);
> > +               break;
> > +       }
> > +}
> > +
> > +static int sxgbe_get_sset_count(struct net_device *netdev, int sset)
> > +{
> > +       int len;
> > +
> > +       switch (sset) {
> > +       case ETH_SS_STATS:
> > +               len = SXGBE_STATS_LEN;
> > +               return len;
> > +       default:
> > +               return -EOPNOTSUPP;
> > +       }
> > +}
> > +
> > +static void sxgbe_get_ethtool_stats(struct net_device *dev,
> > +                                   struct ethtool_stats *dummy, u64
> > +*data) {
> > +       struct sxgbe_priv_data *priv = netdev_priv(dev);
> > +       int i, j = 0;
> > +       char *p;
> > +
> > +       if (priv->eee_enabled) {
> > +               int val = phy_get_eee_err(priv->phydev);
> > +
> > +               if (val)
> > +                       priv->xstats.eee_wakeup_error_n = val;
> > +       }
> > +
> > +       for (i = 0; i < SXGBE_STATS_LEN; i++) {
> > +               p = (char *)priv + sxgbe_gstrings_stats[i].stat_offset;
> > +               data[j++] = (sxgbe_gstrings_stats[i].sizeof_stat ==
sizeof(u64))
> > +                       ? (*(u64 *)p) : (*(u32 *)p);
> > +       }
> > +}
> > +
> > +static void sxgbe_get_channels(struct net_device *dev,
> > +                              struct ethtool_channels *channel) {
> > +       channel->max_rx = SXGBE_MAX_RX_CHANNELS;
> > +       channel->max_tx = SXGBE_MAX_TX_CHANNELS;
> > +       channel->rx_count = SXGBE_RX_QUEUES;
> > +       channel->tx_count = SXGBE_TX_QUEUES; }
> > +
> > +static u32 sxgbe_riwt2usec(u32 riwt, struct sxgbe_priv_data *priv) {
> > +       unsigned long clk = clk_get_rate(priv->sxgbe_clk);
> > +
> > +       if (!clk)
> > +               return 0;
> > +
> > +       return (riwt * 256) / (clk / 1000000); }
> > +
> > +static u32 sxgbe_usec2riwt(u32 usec, struct sxgbe_priv_data *priv) {
> > +       unsigned long clk = clk_get_rate(priv->sxgbe_clk);
> > +
> > +       if (!clk)
> > +               return 0;
> > +
> > +       return (usec * (clk / 1000000)) / 256; }
> > +
> > +static int sxgbe_get_coalesce(struct net_device *dev,
> > +                             struct ethtool_coalesce *ec) {
> > +       struct sxgbe_priv_data *priv = netdev_priv(dev);
> > +
> > +       if (priv->use_riwt)
> > +               ec->rx_coalesce_usecs = sxgbe_riwt2usec(priv->rx_riwt,
> > + priv);
> > +
> > +       return 0;
> > +}
> > +
> > +static int sxgbe_set_coalesce(struct net_device *dev,
> > +                             struct ethtool_coalesce *ec) {
> > +       struct sxgbe_priv_data *priv = netdev_priv(dev);
> > +       unsigned int rx_riwt;
> > +
> > +       rx_riwt = sxgbe_usec2riwt(ec->rx_coalesce_usecs, priv);
> > +
> > +       if ((rx_riwt > SXGBE_MAX_DMA_RIWT) || (rx_riwt <
> SXGBE_MIN_DMA_RIWT))
> > +               return -EINVAL;
> > +       else if (!priv->use_riwt)
> > +               return -EOPNOTSUPP;
> > +
> > +       priv->rx_riwt = rx_riwt;
> > +       priv->hw->dma->rx_watchdog(priv->ioaddr, priv->rx_riwt);
> > +
> > +       return 0;
> > +}
> > +
> > +static int sxgbe_get_rss_hash_opts(struct sxgbe_priv_data *priv,
> > +                                  struct ethtool_rxnfc *cmd) {
> > +       cmd->data = 0;
> > +
> > +       /* Report default options for RSS on sxgbe */
> > +       switch (cmd->flow_type) {
> > +       case TCP_V4_FLOW:
> > +       case UDP_V4_FLOW:
> > +               cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
> > +       case SCTP_V4_FLOW:
> > +       case AH_ESP_V4_FLOW:
> > +       case AH_V4_FLOW:
> > +       case ESP_V4_FLOW:
> > +       case IPV4_FLOW:
> > +               cmd->data |= RXH_IP_SRC | RXH_IP_DST;
> > +               break;
> > +       case TCP_V6_FLOW:
> > +       case UDP_V6_FLOW:
> > +               cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
> > +       case SCTP_V6_FLOW:
> > +       case AH_ESP_V6_FLOW:
> > +       case AH_V6_FLOW:
> > +       case ESP_V6_FLOW:
> > +       case IPV6_FLOW:
> > +               cmd->data |= RXH_IP_SRC | RXH_IP_DST;
> > +               break;
> > +       default:
> > +               return -EINVAL;
> > +       }
> > +
> > +       return 0;
> > +}
> > +
> > +static int sxgbe_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc
> *cmd,
> > +                          u32 *rule_locs) {
> > +       struct sxgbe_priv_data *priv = netdev_priv(dev);
> > +       int ret = -EOPNOTSUPP;
> > +
> > +       switch (cmd->cmd) {
> > +       case ETHTOOL_GRXFH:
> > +               ret = sxgbe_get_rss_hash_opts(priv, cmd);
> > +               break;
> > +       default:
> > +               break;
> > +       }
> > +
> > +       return ret;
> > +}
> > +
> > +static int sxgbe_set_rss_hash_opt(struct sxgbe_priv_data *priv,
> > +                                 struct ethtool_rxnfc *cmd) {
> > +       u32 reg_val = 0;
> > +
> > +       /* RSS does not support anything other than hashing
> > +        * to queues on src and dst IPs and ports
> > +        */
> > +       if (cmd->data & ~(RXH_IP_SRC | RXH_IP_DST |
> > +                         RXH_L4_B_0_1 | RXH_L4_B_2_3))
> > +               return -EINVAL;
> > +
> > +       switch (cmd->flow_type) {
> > +       case TCP_V4_FLOW:
> > +       case TCP_V6_FLOW:
> > +               if (!(cmd->data & RXH_IP_SRC) ||
> > +                   !(cmd->data & RXH_IP_DST) ||
> > +                   !(cmd->data & RXH_L4_B_0_1) ||
> > +                   !(cmd->data & RXH_L4_B_2_3))
> > +                       return -EINVAL;
> > +               reg_val = SXGBE_CORE_RSS_CTL_TCP4TE;
> > +               break;
> > +       case UDP_V4_FLOW:
> > +       case UDP_V6_FLOW:
> > +               if (!(cmd->data & RXH_IP_SRC) ||
> > +                   !(cmd->data & RXH_IP_DST) ||
> > +                   !(cmd->data & RXH_L4_B_0_1) ||
> > +                   !(cmd->data & RXH_L4_B_2_3))
> > +                       return -EINVAL;
> > +               reg_val = SXGBE_CORE_RSS_CTL_UDP4TE;
> > +               break;
> > +       case SCTP_V4_FLOW:
> > +       case AH_ESP_V4_FLOW:
> > +       case AH_V4_FLOW:
> > +       case ESP_V4_FLOW:
> > +       case AH_ESP_V6_FLOW:
> > +       case AH_V6_FLOW:
> > +       case ESP_V6_FLOW:
> > +       case SCTP_V6_FLOW:
> > +       case IPV4_FLOW:
> > +       case IPV6_FLOW:
> > +               if (!(cmd->data & RXH_IP_SRC) ||
> > +                   !(cmd->data & RXH_IP_DST) ||
> > +                   (cmd->data & RXH_L4_B_0_1) ||
> > +                   (cmd->data & RXH_L4_B_2_3))
> > +                       return -EINVAL;
> > +               reg_val = SXGBE_CORE_RSS_CTL_IP2TE;
> > +               break;
> > +       default:
> > +               return -EINVAL;
> > +       }
> > +
> > +       /* Read SXGBE RSS control register and update */
> > +       reg_val |= readl(priv->ioaddr + SXGBE_CORE_RSS_CTL_REG);
> > +       writel(reg_val, priv->ioaddr + SXGBE_CORE_RSS_CTL_REG);
> > +       readl(priv->ioaddr + SXGBE_CORE_RSS_CTL_REG);
> > +
> > +       return 0;
> > +}
> > +
> > +static int sxgbe_set_rxnfc(struct net_device *dev, struct
> > +ethtool_rxnfc *cmd) {
> > +       struct sxgbe_priv_data *priv = netdev_priv(dev);
> > +       int ret = -EOPNOTSUPP;
> > +
> > +       switch (cmd->cmd) {
> > +       case ETHTOOL_SRXFH:
> > +               ret = sxgbe_set_rss_hash_opt(priv, cmd);
> > +               break;
> > +       default:
> > +               break;
> > +       }
> > +
> > +       return ret;
> > +}
> > +
> > +static void sxgbe_get_regs(struct net_device *dev,
> > +                          struct ethtool_regs *regs, void *space) {
> > +       struct sxgbe_priv_data *priv = netdev_priv(dev);
> > +       u32 *reg_space = (u32 *)space;
> > +       int reg_offset;
> > +       int reg_ix = 0;
> > +       void __iomem *ioaddr = priv->ioaddr;
> > +
> 
> nit: you might want to set regs->version so you can differentiate how to
format
> the registers from ethtool if the register structure ever changes, or you
decide
> to add more useful information here.
Ok, it will be updated after this seriese.
Thanks.

> 
> > +       memset(reg_space, 0x0, REG_SPACE_SIZE);
> > +
> > +       /* MAC registers */
> > +       for (reg_offset = START_MAC_REG_OFFSET;
> > +            reg_offset <= MAX_MAC_REG_OFFSET; reg_offset += 4) {
> > +               reg_space[reg_ix] = readl(ioaddr + reg_offset);
> > +               reg_ix++;
> > +       }
> > +
> > +       /* MTL registers */
> > +       for (reg_offset = START_MTL_REG_OFFSET;
> > +            reg_offset <= MAX_MTL_REG_OFFSET; reg_offset += 4) {
> > +               reg_space[reg_ix] = readl(ioaddr + reg_offset);
> > +               reg_ix++;
> > +       }
> > +
> > +       /* DMA registers */
> > +       for (reg_offset = START_DMA_REG_OFFSET;
> > +            reg_offset <= MAX_DMA_REG_OFFSET; reg_offset += 4) {
> > +               reg_space[reg_ix] = readl(ioaddr + reg_offset);
> > +               reg_ix++;
> > +       }
> > +}
> > +
> > +static int sxgbe_get_regs_len(struct net_device *dev) {
> > +       return REG_SPACE_SIZE;
> > +}
> > +
> >  static const struct ethtool_ops sxgbe_ethtool_ops = {
> > -       .get_eee = sxgbe_ethtool_get_eee,
> > -       .set_eee = sxgbe_ethtool_set_eee,
> > +       .get_drvinfo = sxgbe_getdrvinfo,
> > +       .get_settings = sxgbe_getsettings,
> > +       .set_settings = sxgbe_setsettings,
> > +       .get_msglevel = sxgbe_getmsglevel,
> > +       .set_msglevel = sxgbe_setmsglevel,
> > +       .get_link = ethtool_op_get_link,
> > +       .get_ts_info = sxgbe_get_ts_info,
> > +       .get_pauseparam = sxgbe_get_pauseparam,
> > +       .set_pauseparam = sxgbe_set_pauseparam,
> > +       .get_strings = sxgbe_get_strings,
> > +       .get_ethtool_stats = sxgbe_get_ethtool_stats,
> > +       .get_sset_count = sxgbe_get_sset_count,
> > +       .get_channels = sxgbe_get_channels,
> > +       .get_coalesce = sxgbe_get_coalesce,
> > +       .set_coalesce = sxgbe_set_coalesce,
> > +       .get_rxnfc = sxgbe_get_rxnfc,
> > +       .set_rxnfc = sxgbe_set_rxnfc,
> > +       .get_regs = sxgbe_get_regs,
> > +       .get_regs_len = sxgbe_get_regs_len,
> > +       .get_eee = sxgbe_get_eee,
> > +       .set_eee = sxgbe_set_eee,
> >  };
> >
> >  void sxgbe_set_ethtool_ops(struct net_device *netdev) diff --git
> > a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
> > b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
> > index dbbb7ab..8c478c9 100644
> > --- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
> > +++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
> > @@ -2126,9 +2126,6 @@ struct sxgbe_priv_data *sxgbe_dvr_probe(struct
> > device *device,
> >
> >         priv->msg_enable = netif_msg_init(debug, default_msg_level);
> >
> > -       if (flow_ctrl)
> > -               priv->flow_ctrl = SXGBE_FLOW_AUTO;      /* RX/TX pause on
*/
> > -
> >         /* Enable TCP segmentation offload for all DMA channels */
> >         if (priv->hw_cap.tcpseg_offload) {
> >                 SXGBE_FOR_EACH_QUEUE(SXGBE_TX_QUEUES, queue_num) { @@
> > -2142,6 +2139,11 @@ struct sxgbe_priv_data *sxgbe_dvr_probe(struct
> device *device,
> >                 priv->rxcsum_insertion = true;
> >         }
> >
> > +       /* Initialise pause frame settings */
> > +       priv->rx_pause = 1;
> > +       priv->tx_pause = 1;
> > +       sxgbe_set_flow_ctrl(priv, priv->rx_pause, priv->tx_pause);
> > +
> >         /* Rx Watchdog is available, enable depend on platform data */
> >         if (!priv->plat->riwt_off) {
> >                 priv->use_riwt = 1;
> > diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h
> > b/drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h
> > index 85a7b31..5a89acb 100644
> > --- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h
> > +++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h
> > @@ -195,6 +195,12 @@
> >  #define SXGBE_CORE_RSS_ADD_REG         0x0C88
> >  #define SXGBE_CORE_RSS_DATA_REG                0x0C8C
> >
> > +/* RSS control register bits */
> > +#define SXGBE_CORE_RSS_CTL_UDP4TE      BIT(3)
> > +#define SXGBE_CORE_RSS_CTL_TCP4TE      BIT(2)
> > +#define SXGBE_CORE_RSS_CTL_IP2TE       BIT(1)
> > +#define SXGBE_CORE_RSS_CTL_RSSE                BIT(0)
> > +
> >  /* IEEE 1588 registers */
> >  #define SXGBE_CORE_TSTAMP_CTL_REG      0x0D00
> >  #define SXGBE_CORE_SUBSEC_INC_REG      0x0D04
> > --
> > 1.7.10.4
> >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe devicetree"
> > in the body of a message to majordomo@vger.kernel.org More majordomo
> > info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of
> a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
