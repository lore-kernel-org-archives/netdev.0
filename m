From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [RFC PATCH 2/2] net: mvneta: Add naive RSS support
Date: Fri, 6 Nov 2015 20:15:31 +0100
Message-ID: <CAPv3WKecZuSfk4LpCehWoijiA6Ea306qn5iyNbg4TucYuOZauw@mail.gmail.com>
References: <1446834911-29910-1-git-send-email-gregory.clement@free-electrons.com>
	<1446834911-29910-3-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446834911-29910-3-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gregory,

2015-11-06 19:35 GMT+01:00 Gregory CLEMENT <gregory.clement@free-electrons.com>:
> This patch add the support for the RSS related ethtool
> function. Currently it only use one entry in the indirection table which
> allows associating an mveneta interface to a given CPU.
>
> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 114 ++++++++++++++++++++++++++++++++++
>  1 file changed, 114 insertions(+)
>
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index c38326b848f9..5f810a458443 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -259,6 +259,11 @@
>
>  #define MVNETA_TX_MTU_MAX              0x3ffff
>
> +/* The RSS lookup table actually has 256 entries but we do not use
> + * them yet
> + */
> +#define MVNETA_RSS_LU_TABLE_SIZE       1
> +
>  /* TSO header size */
>  #define TSO_HEADER_SIZE 128
>
> @@ -380,6 +385,8 @@ struct mvneta_port {
>         int use_inband_status:1;
>
>         u64 ethtool_stats[ARRAY_SIZE(mvneta_statistics)];
> +
> +       u32 indir[MVNETA_RSS_LU_TABLE_SIZE];
>  };
>
>  /* The mvneta_tx_desc and mvneta_rx_desc structures describe the
> @@ -3173,6 +3180,107 @@ static int mvneta_ethtool_get_sset_count(struct net_device *dev, int sset)
>         return -EOPNOTSUPP;
>  }
>
> +static u32 mvneta_ethtool_get_rxfh_indir_size(struct net_device *dev)
> +{
> +       return MVNETA_RSS_LU_TABLE_SIZE;
> +}
> +
> +static int mvneta_ethtool_get_rxnfc(struct net_device *dev,
> +                                   struct ethtool_rxnfc *info,
> +                                   u32 *rules __always_unused)
> +{
> +       switch (info->cmd) {
> +       case ETHTOOL_GRXRINGS:
> +               info->data =  rxq_number;
> +               return 0;
> +       case ETHTOOL_GRXFH:
> +               return -EOPNOTSUPP;
> +       default:
> +               return -EOPNOTSUPP;
> +       }
> +}
> +
> +static int  mvneta_config_rss(struct mvneta_port *pp)
> +{
> +       int cpu;
> +       u32 val;
> +
> +       netif_tx_stop_all_queues(pp->dev);
> +
> +       /* Mask all ethernet port interrupts */
> +       mvreg_write(pp, MVNETA_INTR_NEW_MASK, 0);

Shouldn't the interrupts be masked on each online cpu? There is percpu
unmask function (mvneta_percpu_unmask_interrupt), so maybe ther should
be also mvneta_percpu_mask_interrupt. With this masking should look
like below:

     for_each_online_cpu(cpu)
               smp_call_function_single(cpu, mvneta_percpu_unmask_interrupt,
                                        pp, true);

> +       mvreg_write(pp, MVNETA_INTR_OLD_MASK, 0);
> +       mvreg_write(pp, MVNETA_INTR_MISC_MASK, 0);
> +
> +       /* We have to synchronise on the napi of each CPU */
> +       for_each_online_cpu(cpu) {
> +               struct mvneta_pcpu_port *pcpu_port =
> +                       per_cpu_ptr(pp->ports, cpu);
> +
> +               napi_synchronize(&pcpu_port->napi);
> +               napi_disable(&pcpu_port->napi);
> +       }
> +
> +       pp->rxq_def = pp->indir[0];
> +
> +       /* update unicast mapping */
> +       mvneta_set_rx_mode(pp->dev);
> +
> +       /* Update val of portCfg register accordingly with all RxQueue types */
> +       val = MVNETA_PORT_CONFIG_DEFL_VALUE(pp->rxq_def);
> +       mvreg_write(pp, MVNETA_PORT_CONFIG, val);
> +
> +       /* Update the elected CPU matching the new rxq_def */
> +       mvneta_percpu_elect(pp);
> +
> +       /* We have to synchronise on the napi of each CPU */
> +       for_each_online_cpu(cpu) {
> +               struct mvneta_pcpu_port *pcpu_port =
> +                       per_cpu_ptr(pp->ports, cpu);
> +
> +               napi_enable(&pcpu_port->napi);
> +       }
> +

rxq_def changed, but txq vs CPU mapping remained as in the beginning -
is it intentional?

Best regards,
Marcin
