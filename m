From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: A new 10GB Ethernet Driver by Chelsio Communications
Date: Fri, 25 Mar 2005 00:55:59 -0500
Message-ID: <4243A7EF.40201@pobox.com>
References: <Pine.LNX.4.58.0503110356340.14213@server.graphe.net>	<20050311131143.30412d5a.akpm@osdl.org>	<Pine.LNX.4.58.0503111620050.29845@server.graphe.net>	<20050311170055.5b26147d.akpm@osdl.org>	<Pine.LNX.4.58.0503231456190.6109@server.graphe.net>	<42438F49.80002@pobox.com> <20050324201826.154a2a50.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>
To: christoph@lameter.com, sbardone@chelsio.com, Netdev <netdev@oss.sgi.com>
In-Reply-To: <20050324201826.154a2a50.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Review comments (many) follow.

Still needs work.

Overall:  t1_write_reg_4 and friends should be converted to native 
readl/writel functions.  Don't use wrappers for low-level I/O functions.


> diff -puN /dev/null drivers/net/chelsio/ch_ethtool.h
> --- /dev/null	2004-08-10 19:55:00.000000000 -0600
> +++ 25-akpm/drivers/net/chelsio/ch_ethtool.h	2005-03-24 21:17:43.000000000 -0700
> +enum {
> +	ETHTOOL_SETREG,
> +	ETHTOOL_GETREG,

It's not a good idea to add "black hole" interfaces such as low level 
register read/write interfaces, generally.


> +	ETHTOOL_SETTPI,
> +	ETHTOOL_GETTPI,
> +	ETHTOOL_DEVUP,
> +	ETHTOOL_GETMTUTAB,
> +	ETHTOOL_SETMTUTAB,
> +	ETHTOOL_GETMTU,
> +	ETHTOOL_SET_PM,
> +	ETHTOOL_GET_PM,
> +	ETHTOOL_GET_TCAM,
> +	ETHTOOL_SET_TCAM,
> +	ETHTOOL_GET_TCB,
> +	ETHTOOL_READ_TCAM_WORD,
> +};

Please don't use the public ETHTOOL_ namespace for these values.


> +struct ethtool_reg {
> +	uint32_t cmd;
> +	uint32_t addr;
> +	uint32_t val;
> +};
> +
> +struct ethtool_mtus {
> +	uint32_t cmd;
> +	uint16_t mtus[NMTUS];
> +};
> +
> +struct ethtool_pm {
> +	uint32_t cmd;
> +	uint32_t tx_pg_sz;
> +	uint32_t tx_num_pg;
> +	uint32_t rx_pg_sz;
> +	uint32_t rx_num_pg;
> +	uint32_t pm_total;
> +};

some of these struct members are never used


> +struct ethtool_tcam {
> +	uint32_t cmd;
> +	uint32_t tcam_size;
> +	uint32_t nservers;
> +	uint32_t nroutes;
> +};
> +
> +struct ethtool_tcb {
> +	uint32_t cmd;
> +	uint32_t tcb_index;
> +	uint32_t tcb_data[TCB_WORDS];
> +};
> +
> +struct ethtool_tcam_word {
> +	uint32_t cmd;
> +	uint32_t addr;
> +	uint32_t buf[3];
> +};

1) don't use "ethtool_" namespace for these NIC-specific structs

2) unless this header is shared with userspace, you should be using 
u8/u16/u32 types.


> diff -puN /dev/null drivers/net/chelsio/common.h
> --- /dev/null	2004-08-10 19:55:00.000000000 -0600
> +++ 25-akpm/drivers/net/chelsio/common.h	2005-03-24 21:17:43.000000000 -0700
> +#define DIMOF(x) (sizeof(x)/sizeof(x[0]))

delete, and use standard ARRAY_SIZE() macro


> +#define NMTUS      8
> +#define MAX_NPORTS 4
> +#define TCB_SIZE   128

enum?


> +enum {
> +	CHBT_BOARD_7500,
> +	CHBT_BOARD_8000,
> +	CHBT_BOARD_CHT101,
> +	CHBT_BOARD_CHT110,
> +	CHBT_BOARD_CHT210,
> +	CHBT_BOARD_CHT204,
> +	CHBT_BOARD_N110,
> +	CHBT_BOARD_N210,
> +	CHBT_BOARD_COUGAR,
> +	CHBT_BOARD_6800,
> +	CHBT_BOARD_SIMUL
> +};
> +
> +enum {
> +	CHBT_TERM_FPGA,
> +	CHBT_TERM_T1,
> +	CHBT_TERM_T2,
> +	CHBT_TERM_T3
> +};
> +
> +enum {
> +	CHBT_MAC_CHELSIO_A,
> +	CHBT_MAC_IXF1010,
> +	CHBT_MAC_PM3393,
> +	CHBT_MAC_VSC7321,
> +	CHBT_MAC_DUMMY
> +};
> +
> +enum {
> +	CHBT_PHY_88E1041,
> +	CHBT_PHY_88E1111,
> +	CHBT_PHY_88X2010,
> +	CHBT_PHY_XPAK,
> +	CHBT_PHY_MY3126,
> +	CHBT_PHY_DUMMY
> +};
> +
> +enum {
> +	PAUSE_RX = 1,
> +	PAUSE_TX = 2,
> +	PAUSE_AUTONEG = 4
> +};

I believe these should be bits, in the "(1 << n)" notation?


> +/* Revisions of T1 chip */
> +#define TERM_T1A     0
> +#define TERM_T1B     1
> +#define TERM_T2      3

why not enums for these, too?


> +struct tp_params {
> +	unsigned int pm_size;
> +	unsigned int cm_size;
> +	unsigned int pm_rx_base;
> +	unsigned int pm_tx_base;
> +	unsigned int pm_rx_pg_size;
> +	unsigned int pm_tx_pg_size;
> +	unsigned int pm_rx_num_pgs;
> +	unsigned int pm_tx_num_pgs;
> +	unsigned int use_5tuple_mode;
> +};

where is this ever used?


> +struct sge_params {
> +	unsigned int cmdQ_size[2];
> +	unsigned int freelQ_size[2];
> +	unsigned int large_buf_capacity;
> +	unsigned int rx_coalesce_usecs;
> +	unsigned int last_rx_coalesce_raw;
> +	unsigned int default_rx_coalesce_usecs;
> +	unsigned int sample_interval_usecs;
> +	unsigned int coalesce_enable;
> +	unsigned int polling;
> +};
> +
> +struct mc5_params {
> +	unsigned int mode;	/* selects MC5 width */
> +	unsigned int nservers;	/* size of server region */
> +	unsigned int nroutes;	/* size of routing region */
> +};
> +
> +/* Default MC5 region sizes */
> +#define DEFAULT_SERVER_REGION_LEN 256
> +#define DEFAULT_RT_REGION_LEN 1024

enum?


> +struct pci_params {
> +	unsigned short speed;
> +	unsigned char  width;
> +	unsigned char  is_pcix;
> +};

please don't use "pci_" namespace.

Also, typically you want a boolean variable defined as a bit flag in an 
'unsigned long' variable, or at least a bitfield "unsigned foo : 1;".


> +struct adapter_params {
> +	struct sge_params sge;
> +	struct mc5_params mc5;
> +	struct tp_params  tp;
> +	struct pci_params pci;
> +
> +	const struct board_info *brd_info;
> +
> +	unsigned short mtus[NMTUS];
> +	unsigned int   nports;         /* # of ethernet ports */
> +	unsigned int   stats_update_period;
> +	unsigned short chip_revision;
> +	unsigned char  chip_version;
> +	unsigned char  is_asic;
> +};

ditto the above comment about booleans, for 'is_asic'


> +struct pci_err_cnt {
> +	unsigned int master_parity_err;
> +	unsigned int sig_target_abort;
> +	unsigned int rcv_target_abort;
> +	unsigned int rcv_master_abort;
> +	unsigned int sig_sys_err;
> +	unsigned int det_parity_err;
> +	unsigned int pio_parity_err;
> +	unsigned int wf_parity_err;
> +	unsigned int rf_parity_err;
> +	unsigned int cf_parity_err;
> +};

* counters should typically be unsigned long

* don't use "pci_" namespace


> +struct link_config {
> +	unsigned int   supported;        /* link capabilities */
> +	unsigned int   advertising;      /* advertised capabilities */
> +	unsigned short requested_speed;  /* speed user has requested */
> +	unsigned short speed;            /* actual link speed */
> +	unsigned char  requested_duplex; /* duplex user has requested */
> +	unsigned char  duplex;           /* actual link duplex */
> +	unsigned char  requested_fc;     /* flow control user has requested */
> +	unsigned char  fc;               /* actual link flow control */
> +	unsigned char  autoneg;          /* autonegotiating? */
> +};
> +
> +#define SPEED_INVALID   0xffff
> +#define DUPLEX_INVALID  0xff
> +
> +struct mdio_ops;
> +struct gmac;
> +struct gphy;
> +
> +struct board_info {
> +	unsigned char           board;
> +	unsigned char           port_number;
> +	unsigned long           caps;
> +	unsigned char           chip_term;
> +	unsigned char           chip_mac;
> +	unsigned char           chip_phy;
> +	unsigned int            clock_core;
> +	unsigned int            clock_mc3;
> +	unsigned int            clock_mc4;
> +	unsigned int            espi_nports;
> +	unsigned int            clock_cspi;
> +	unsigned int            clock_elmer0;
> +	unsigned char           mdio_mdien;
> +	unsigned char           mdio_mdiinv;
> +	unsigned char           mdio_mdc;
> +	unsigned char           mdio_phybaseaddr;
> +	struct gmac            *gmac;
> +	struct gphy            *gphy;
> +	struct mdio_ops	       *mdio_ops;

can this be made 'const' ?


> +	const char             *desc;
> +};
> +
> +#include "osdep.h"
> +
> +#ifndef PCI_VENDOR_ID_CHELSIO
> +#define PCI_VENDOR_ID_CHELSIO 0x1425
> +#endif

remove this, and patch include/linux/pci_ids.h

> +int t1_tpi_write(adapter_t *adapter, u32 addr, u32 value);
> +int t1_tpi_read(adapter_t *adapter, u32 addr, u32 *value);
> +
> +void t1_interrupts_enable(adapter_t *adapter);
> +void t1_interrupts_disable(adapter_t *adapter);
> +void t1_interrupts_clear(adapter_t *adapter);
> +int elmer0_ext_intr_handler(adapter_t *adapter);
> +int t1_slow_intr_handler(adapter_t *adapter);
> +
> +int t1_link_start(struct cphy *phy, struct cmac *mac, struct link_config *lc);
> +const struct board_info *t1_get_board_info(unsigned int board_id);
> +const struct board_info *t1_get_board_info_from_ids(unsigned int devid,
> +						    unsigned short ssid);
> +int t1_seeprom_read(adapter_t *adapter, u32 addr, u32 *data);
> +int t1_get_board_rev(adapter_t *adapter, const struct board_info *bi,
> +		     struct adapter_params *p);
> +int t1_init_hw_modules(adapter_t *adapter);
> +int t1_init_sw_modules(adapter_t *adapter, const struct board_info *bi);
> +void t1_free_sw_modules(adapter_t *adapter);
> +void t1_fatal_err(adapter_t *adapter);
> +#endif

please use the 'extern' prefix for these functions.

also, for all headers, please append a comment after the ending #endif, 
indicating what symbol the #endif closes.  example:

	#endif /* CHELSIO_COMMON_H */


> diff -puN /dev/null drivers/net/chelsio/cpl5_cmd.h
> --- /dev/null	2004-08-10 19:55:00.000000000 -0600
> +++ 25-akpm/drivers/net/chelsio/cpl5_cmd.h	2005-03-24 21:17:43.000000000 -0700
> +/*
> + * We want this header's alignment to be no more stringent than 2-byte aligned.
> + * All fields are u8 or u16 except for the length.  However that field is not
> + * used so we break it into 2 16-bit parts to easily meet our alignment needs.
> + */

Use

	struct foo {
		...
	} __attribute__ ((packed));

to eliminate the compiler's ABI struct member padding and alignment.


> +struct cpl_tx_pkt {
> +	__u8 opcode;
> +#if defined(__LITTLE_ENDIAN_BITFIELD)
> +	__u8 iff:4;
> +	__u8 ip_csum_dis:1;
> +	__u8 l4_csum_dis:1;
> +	__u8 vlan_valid:1;
> +	__u8 rsvd:1;
> +#else
> +	__u8 rsvd:1;
> +	__u8 vlan_valid:1;
> +	__u8 l4_csum_dis:1;
> +	__u8 ip_csum_dis:1;
> +	__u8 iff:4;
> +#endif
> +	__u16 vlan;
> +	__u16 len_hi;
> +	__u16 len_lo;
> +};
> +
> +struct cpl_tx_pkt_lso {
> +	__u8 opcode;
> +#if defined(__LITTLE_ENDIAN_BITFIELD)
> +	__u8 iff:4;
> +	__u8 ip_csum_dis:1;
> +	__u8 l4_csum_dis:1;
> +	__u8 vlan_valid:1;
> +	__u8 rsvd:1;
> +#else
> +	__u8 rsvd:1;
> +	__u8 vlan_valid:1;
> +	__u8 l4_csum_dis:1;
> +	__u8 ip_csum_dis:1;
> +	__u8 iff:4;
> +#endif
> +	__u16 vlan;
> +	__u32 len;
> +
> +	__u32 rsvd2;
> +	__u8 rsvd3;
> +#if defined(__LITTLE_ENDIAN_BITFIELD)
> +	__u8 tcp_hdr_words:4;
> +	__u8 ip_hdr_words:4;
> +#else
> +	__u8 ip_hdr_words:4;
> +	__u8 tcp_hdr_words:4;
> +#endif
> +	__u16 eth_type_mss;
> +};
> +
> +struct cpl_rx_pkt {
> +	__u8 opcode;
> +#if defined(__LITTLE_ENDIAN_BITFIELD)
> +	__u8 iff:4;
> +	__u8 csum_valid:1;
> +	__u8 bad_pkt:1;
> +	__u8 vlan_valid:1;
> +	__u8 rsvd:1;
> +#else
> +	__u8 rsvd:1;
> +	__u8 vlan_valid:1;
> +	__u8 bad_pkt:1;
> +	__u8 csum_valid:1;
> +	__u8 iff:4;
> +#endif
> +	__u16 csum;
> +	__u16 vlan;
> +	__u16 len;
> +};

two general comments:

1) prefer u8/u16/u32 kernel types to __u8/__u16/__u32 compiler types.

2) using bitflags in the code, rather than bitfields, are generally 
easier to maintain.  the choice is yours, but I encourage doing it like:

	struct foo {
		u32 bar;
	};

	...

	u32 tmp = le32_to_cpu(dma_structure->foo);
	u32 tmp1 = tmp & 0xf;	/* get lower 4 bits */
	u32 tmp2 = tmp & (1 << 30); /* get bit 30 */
	etc.


> +#endif
> diff -puN /dev/null drivers/net/chelsio/cxgb2.c
> --- /dev/null	2004-08-10 19:55:00.000000000 -0600
> +++ 25-akpm/drivers/net/chelsio/cxgb2.c	2005-03-24 21:17:43.000000000 -0700
> +static inline void cancel_mac_stats_update(struct adapter *ap)
> +{
> +	cancel_delayed_work(&ap->stats_update_task);
> +}
> +
> +#if BITS_PER_LONG == 64 && !defined(CONFIG_X86_64)
> +# define FMT64 "l"
> +#else
> +# define FMT64 "ll"
> +#endif
> +
> +# define DRV_TYPE ""

delete this, it is unused


> +# define MODULE_DESC "Chelsio Network Driver"

1) don't use the MODULE_xxx namespace for your own purposes

2) just include this string inline.  don't define a macro for it at all.


> +static char driver_name[]    = DRV_NAME;

delete this, and just use DRV_NAME inline.  The compiler should merge 
references to duplicate read-only strings.


> +static char driver_version[] = "2.1.0";

ditto the DRV_NAME issue.

> +#define PCI_DMA_64BIT ~0ULL
> +#define PCI_DMA_32BIT 0xffffffffULL

delete, and use DMA_{32,64}BIT_MASK in include/linux/dma-mapping.h.


> +#define MAX_CMDQ_ENTRIES 16384
> +#define MAX_CMDQ1_ENTRIES 1024
> +#define MAX_RX_BUFFERS 16384
> +#define MAX_RX_JUMBO_BUFFERS 16384
> +#define MAX_TX_BUFFERS_HIGH	16384U
> +#define MAX_TX_BUFFERS_LOW	1536U
> +#define MIN_FL_ENTRIES 32
> +
> +#define PORT_MASK ((1 << MAX_NPORTS) - 1)

enum?


> +#define DFLT_MSG_ENABLE (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK | \
> +			 NETIF_MSG_TIMER | NETIF_MSG_IFDOWN | NETIF_MSG_IFUP |\
> +			 NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
> +
> +/*
> + * The EEPROM is actually bigger but only the first few bytes are used so we
> + * only report those.
> + */
> +#define EEPROM_SIZE 32
> +
> +MODULE_DESCRIPTION(MODULE_DESC);
> +MODULE_AUTHOR("Chelsio Communications");
> +MODULE_LICENSE("GPL");
> +MODULE_DEVICE_TABLE(pci, t1_pci_tbl);
> +
> +static int dflt_msg_enable = DFLT_MSG_ENABLE;
> +
> +MODULE_PARM(dflt_msg_enable, "i");
> +MODULE_PARM_DESC(dflt_msg_enable, "Chelsio T1 message enable bitmap");
> +
> +
> +static const char pci_speed[][4] = {
> +	"33", "66", "100", "133"
> +};
> +
> +/*
> + * Setup MAC to receive the types of packets we want.
> + */
> +static void t1_set_rxmode(struct net_device *dev)
> +{
> +	struct adapter *adapter = dev->priv;
> +	struct cmac *mac = adapter->port[dev->if_port].mac;
> +	struct t1_rx_mode rm;
> +
> +	rm.dev = dev;
> +	rm.idx = 0;
> +	rm.list = dev->mc_list;
> +	mac->ops->set_rx_mode(mac, &rm);
> +}

delete mac->ops->set_rx_mode() hook, and call pm3393_set_rx_mode() directly


> +static void link_report(struct port_info *p)
> +{
> +	if (!netif_carrier_ok(p->dev))
> +		printk(KERN_INFO "%s: link is down\n", p->dev->name);
> +	else {
> +		const char *s = "10 Mbps";
> +
> +		switch (p->link_config.speed) {
> +			case SPEED_10000: s = "10 Gbps"; break;
> +			case SPEED_1000:  s = "1000 Mbps"; break;
> +			case SPEED_100:   s = "100 Mbps"; break;
> +		}
> +
> +		printk(KERN_INFO "%s: link is up at %s, %s duplex\n",
> +		       p->dev->name, s,
> +		       p->link_config.duplex == DUPLEX_FULL ? "full" : "half");
> +	}
> +}

Consider using a printk() message as close as possible to the one in 
drivers/net/mii.c:

                 printk(KERN_INFO "%s: link up, %sMbps, %s-duplex, lpa 
0x%04X\n",


> +void t1_link_changed(struct adapter *adapter, int port_id, int link_stat,
> +			int speed, int duplex, int pause)
> +{
> +	struct port_info *p = &adapter->port[port_id];
> +
> +	if (link_stat != netif_carrier_ok(p->dev)) {
> +		if (link_stat)
> +			netif_carrier_on(p->dev);
> +		else
> +			netif_carrier_off(p->dev);
> +		link_report(p);
> +
> +	}
> +}
> +
> +static void link_start(struct port_info *p)
> +{
> +	struct cmac *mac = p->mac;
> +
> +	mac->ops->reset(mac);
> +	if (mac->ops->macaddress_set)
> +		mac->ops->macaddress_set(mac, p->dev->dev_addr);
> +	t1_set_rxmode(p->dev);
> +	t1_link_start(p->phy, mac, &p->link_config);
> +	mac->ops->enable(mac, MAC_DIRECTION_RX | MAC_DIRECTION_TX);
> +}

delete hooks, call MAC functions directly


> +static void enable_hw_csum(struct adapter *adapter)
> +{
> +	if (adapter->flags & TSO_CAPABLE)
> +		t1_tp_set_ip_checksum_offload(adapter->tp, 1); /* for TSO only */
> +	if (adapter->flags & UDP_CSUM_CAPABLE)
> +		t1_tp_set_udp_checksum_offload(adapter->tp, 1);
> +	t1_tp_set_tcp_checksum_offload(adapter->tp, 1);
> +}
> +
> +/*
> + * Things to do upon first use of a card.
> + * This must run with the rtnl lock held.
> + */
> +static int cxgb_up(struct adapter *adapter)
> +{
> +	int err = 0;
> +
> +	if (!(adapter->flags & FULL_INIT_DONE)) {
> +		err = t1_init_hw_modules(adapter);
> +		if (err)
> +			goto out_err;
> +
> +		enable_hw_csum(adapter);
> +		adapter->flags |= FULL_INIT_DONE;
> +	}
> +
> +	t1_interrupts_clear(adapter);
> +
> +	if ((err = request_irq(adapter->pdev->irq, &t1_interrupt, SA_SHIRQ,
> +			       adapter->name, adapter)))
> +		goto out_err;
> +
> +	t1_sge_start(adapter->sge);
> +	t1_interrupts_enable(adapter);
> +
> +	err = 0;
> + out_err:
> +	return err;

leak on error.  You should free the resources allocated on 
t1_init_hw_modules().


> + * Release resources when all the ports have been stopped.
> + */
> +static void cxgb_down(struct adapter *adapter)
> +{
> +	t1_sge_stop(adapter->sge);
> +	t1_interrupts_disable(adapter);
> +	free_irq(adapter->pdev->irq, adapter);
> +}
> +
> +static int cxgb_open(struct net_device *dev)
> +{
> +	int err;
> +	struct adapter *adapter = dev->priv;
> +	int other_ports = adapter->open_device_map & PORT_MASK;
> +
> +	if (!adapter->open_device_map && (err = cxgb_up(adapter)) < 0)
> +		return err;
> +
> +	__set_bit(dev->if_port, &adapter->open_device_map);

do you need atomicity for adapter->open_device_map ?

If not, just open-code the bitsetting:

	adapter->open_device_map |= (1 << n)


> +	link_start(&adapter->port[dev->if_port]);
> +	netif_start_queue(dev);
> +	if (!other_ports && adapter->params.stats_update_period)
> +		schedule_mac_stats_update(adapter,
> +					  adapter->params.stats_update_period);
> +	return 0;
> +}
> +
> +static int cxgb_close(struct net_device *dev)
> +{
> +	struct adapter *adapter = dev->priv;
> +	struct port_info *p = &adapter->port[dev->if_port];
> +	struct cmac *mac = p->mac;
> +
> +	netif_stop_queue(dev);
> +	mac->ops->disable(mac, MAC_DIRECTION_TX | MAC_DIRECTION_RX);
> +	netif_carrier_off(dev);

delete hook


> +	clear_bit(dev->if_port, &adapter->open_device_map);
> +	if (adapter->params.stats_update_period &&
> +	    !(adapter->open_device_map & PORT_MASK)) {
> +		/* Stop statistics accumulation. */
> +		smp_mb__after_clear_bit();
> +		spin_lock(&adapter->work_lock);   /* sync with update task */
> +		spin_unlock(&adapter->work_lock);
> +		cancel_mac_stats_update(adapter);

reconsider.  instead, you should flush the workqueue.

and also, the atomicity of adapter->open_device_map isn't needed.


> +	if (!adapter->open_device_map)
> +		cxgb_down(adapter);
> +	return 0;
> +}
> +
> +static struct net_device_stats *t1_get_stats(struct net_device *dev)
> +{
> +	struct adapter *adapter = dev->priv;
> +	struct port_info *p = &adapter->port[dev->if_port];
> +	struct net_device_stats *ns = &p->netstats;
> +	const struct cmac_statistics *pstats;
> +
> +	/* Do a full update of the MAC stats */
> +	pstats = p->mac->ops->statistics_update(p->mac,
> +						      MAC_STATS_UPDATE_FULL);
> +
> +	ns->tx_packets = pstats->TxUnicastFramesOK +
> +		pstats->TxMulticastFramesOK + pstats->TxBroadcastFramesOK;
> +
> +	ns->rx_packets = pstats->RxUnicastFramesOK +
> +		pstats->RxMulticastFramesOK + pstats->RxBroadcastFramesOK;
> +
> +	ns->tx_bytes = pstats->TxOctetsOK;
> +	ns->rx_bytes = pstats->RxOctetsOK;
> +
> +	ns->tx_errors = pstats->TxLateCollisions + pstats->TxLengthErrors +
> +		pstats->TxUnderrun + pstats->TxFramesAbortedDueToXSCollisions;
> +	ns->rx_errors = pstats->RxDataErrors + pstats->RxJabberErrors +
> +		pstats->RxFCSErrors + pstats->RxAlignErrors +
> +		pstats->RxSequenceErrors + pstats->RxFrameTooLongErrors +
> +		pstats->RxSymbolErrors + pstats->RxRuntErrors;
> +
> +	ns->multicast  = pstats->RxMulticastFramesOK;
> +	ns->collisions = pstats->TxTotalCollisions;
> +
> +	/* detailed rx_errors */
> +	ns->rx_length_errors = pstats->RxFrameTooLongErrors +
> +		pstats->RxJabberErrors;
> +	ns->rx_over_errors   = 0;
> +	ns->rx_crc_errors    = pstats->RxFCSErrors;
> +	ns->rx_frame_errors  = pstats->RxAlignErrors;
> +	ns->rx_fifo_errors   = 0;
> +	ns->rx_missed_errors = 0;
> +
> +	/* detailed tx_errors */
> +	ns->tx_aborted_errors   = pstats->TxFramesAbortedDueToXSCollisions;
> +	ns->tx_carrier_errors   = 0;
> +	ns->tx_fifo_errors      = pstats->TxUnderrun;
> +	ns->tx_heartbeat_errors = 0;
> +	ns->tx_window_errors    = pstats->TxLateCollisions;
> +	return ns;
> +}
> +
> +static u32 get_msglevel(struct net_device *dev)
> +{
> +	struct adapter *adapter = dev->priv;
> +
> +	return adapter->msg_enable;
> +}
> +
> +static void set_msglevel(struct net_device *dev, u32 val)
> +{
> +	struct adapter *adapter = dev->priv;
> +
> +	adapter->msg_enable = val;
> +}
> +
> +static char stats_strings[][ETH_GSTRING_LEN] = {
> +	"TxOctetsOK",
> +	"TxOctetsBad",
> +	"TxUnicastFramesOK",
> +	"TxMulticastFramesOK",
> +	"TxBroadcastFramesOK",
> +	"TxPauseFrames",
> +	"TxFramesWithDeferredXmissions",
> +	"TxLateCollisions",
> +	"TxTotalCollisions",
> +	"TxFramesAbortedDueToXSCollisions",
> +	"TxUnderrun",
> +	"TxLengthErrors",
> +	"TxInternalMACXmitError",
> +	"TxFramesWithExcessiveDeferral",
> +	"TxFCSErrors",
> +
> +	"RxOctetsOK",
> +	"RxOctetsBad",
> +	"RxUnicastFramesOK",
> +	"RxMulticastFramesOK",
> +	"RxBroadcastFramesOK",
> +	"RxPauseFrames",
> +	"RxFCSErrors",
> +	"RxAlignErrors",
> +	"RxSymbolErrors",
> +	"RxDataErrors",
> +	"RxSequenceErrors",
> +	"RxRuntErrors",
> +	"RxJabberErrors",
> +	"RxInternalMACRcvError",
> +	"RxInRangeLengthErrors",
> +	"RxOutOfRangeLengthField",
> +	"RxFrameTooLongErrors"
> +};
> +
> +static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
> +{
> +	struct adapter *adapter = dev->priv;
> +
> +	strcpy(info->driver, driver_name);
> +	strcpy(info->version, driver_version);
> +	strcpy(info->fw_version, "N/A");
> +	strcpy(info->bus_info, pci_name(adapter->pdev));
> +}
> +
> +static int get_stats_count(struct net_device *dev)
> +{
> +	return ARRAY_SIZE(stats_strings);
> +}
> +
> +static void get_strings(struct net_device *dev, u32 stringset, u8 *data)
> +{
> +	if (stringset == ETH_SS_STATS)
> +		memcpy(data, stats_strings, sizeof(stats_strings));
> +}
> +
> +static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
> +		      u64 *data)
> +{
> +	struct adapter *adapter = dev->priv;
> +	struct cmac *mac = adapter->port[dev->if_port].mac;
> +	const struct cmac_statistics *s;
> +
> +	s = mac->ops->statistics_update(mac, MAC_STATS_UPDATE_FULL);

delete hook

> +	*data++ = s->TxOctetsOK;
> +	*data++ = s->TxOctetsBad;
> +	*data++ = s->TxUnicastFramesOK;
> +	*data++ = s->TxMulticastFramesOK;
> +	*data++ = s->TxBroadcastFramesOK;
> +	*data++ = s->TxPauseFrames;
> +	*data++ = s->TxFramesWithDeferredXmissions;
> +	*data++ = s->TxLateCollisions;
> +	*data++ = s->TxTotalCollisions;
> +	*data++ = s->TxFramesAbortedDueToXSCollisions;
> +	*data++ = s->TxUnderrun;
> +	*data++ = s->TxLengthErrors;
> +	*data++ = s->TxInternalMACXmitError;
> +	*data++ = s->TxFramesWithExcessiveDeferral;
> +	*data++ = s->TxFCSErrors;
> +
> +	*data++ = s->RxOctetsOK;
> +	*data++ = s->RxOctetsBad;
> +	*data++ = s->RxUnicastFramesOK;
> +	*data++ = s->RxMulticastFramesOK;
> +	*data++ = s->RxBroadcastFramesOK;
> +	*data++ = s->RxPauseFrames;
> +	*data++ = s->RxFCSErrors;
> +	*data++ = s->RxAlignErrors;
> +	*data++ = s->RxSymbolErrors;
> +	*data++ = s->RxDataErrors;
> +	*data++ = s->RxSequenceErrors;
> +	*data++ = s->RxRuntErrors;
> +	*data++ = s->RxJabberErrors;
> +	*data++ = s->RxInternalMACRcvError;
> +	*data++ = s->RxInRangeLengthErrors;
> +	*data++ = s->RxOutOfRangeLengthField;
> +	*data++ = s->RxFrameTooLongErrors;

other drivers insert a programmer sanity check, to ensure that the 
number of stat values output in this function matches the number 
returned by the ->get_stats_count() hook.


> +static int get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
> +{
> +	struct adapter *adapter = dev->priv;
> +	struct port_info *p = &adapter->port[dev->if_port];
> +
> +	cmd->supported = p->link_config.supported;
> +	cmd->advertising = p->link_config.advertising;
> +
> +	if (netif_carrier_ok(dev)) {
> +		cmd->speed = p->link_config.speed;
> +		cmd->duplex = p->link_config.duplex;
> +	} else {
> +		cmd->speed = -1;
> +		cmd->duplex = -1;
> +	}

I'm concerned about this -1 value, which userland isn't really expecting.

It appears e1000 is doing this too :(


> +	cmd->port = (cmd->supported & SUPPORTED_TP) ? PORT_TP : PORT_FIBRE;
> +	cmd->phy_address = p->phy->addr;
> +	cmd->transceiver = XCVR_EXTERNAL;
> +	cmd->autoneg = p->link_config.autoneg;
> +	cmd->maxtxpkt = 0;
> +	cmd->maxrxpkt = 0;
> +	return 0;
> +}
> +
> +static int speed_duplex_to_caps(int speed, int duplex)
> +{
> +	int cap = 0;
> +
> +	switch (speed) {
> +	case SPEED_10:
> +		if (duplex == DUPLEX_FULL)
> +			cap = SUPPORTED_10baseT_Full;
> +		else
> +			cap = SUPPORTED_10baseT_Half;
> +		break;
> +	case SPEED_100:
> +		if (duplex == DUPLEX_FULL)
> +			cap = SUPPORTED_100baseT_Full;
> +		else
> +			cap = SUPPORTED_100baseT_Half;
> +		break;
> +	case SPEED_1000:
> +		if (duplex == DUPLEX_FULL)
> +			cap = SUPPORTED_1000baseT_Full;
> +		else
> +			cap = SUPPORTED_1000baseT_Half;
> +		break;
> +	case SPEED_10000:
> +		if (duplex == DUPLEX_FULL)
> +			cap = SUPPORTED_10000baseT_Full;
> +	}
> +	return cap;
> +}

might be nice to make this a generic function.

but leave that until after the driver is merged.



> +static int set_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
> +{
> +	struct adapter *adapter = dev->priv;
> +
> +	unsigned int sge_coalesce_usecs = 0;
> +
> +	sge_coalesce_usecs = adapter->params.sge.last_rx_coalesce_raw;
> +	sge_coalesce_usecs /= board_info(adapter)->clock_core / 1000000;

do you _ever_ use clock_core value, when you are not dividing it by some 
constant?

It seems like the variable should be scaled once, rather than performing 
a divide each time you use it.


> +	if ( (adapter->params.sge.coalesce_enable && !c->use_adaptive_rx_coalesce) &&
> +	     (c->rx_coalesce_usecs == sge_coalesce_usecs) ) {
> +		adapter->params.sge.rx_coalesce_usecs =
> +			adapter->params.sge.default_rx_coalesce_usecs;
> +	} else {
> +		adapter->params.sge.rx_coalesce_usecs = c->rx_coalesce_usecs;
> +	}

style:  singleton C statements shouldn't be enclosed in braces {}


> +	adapter->params.sge.last_rx_coalesce_raw = adapter->params.sge.rx_coalesce_usecs;
> +	adapter->params.sge.last_rx_coalesce_raw *= (board_info(adapter)->clock_core / 1000000);
> +	adapter->params.sge.sample_interval_usecs = c->rate_sample_interval;
> +	adapter->params.sge.coalesce_enable = c->use_adaptive_rx_coalesce;
> +	t1_sge_set_coalesce_params(adapter->sge, &adapter->params.sge);
> +	return 0;
> +}
> +

> +static int ethtool_ioctl(struct net_device *dev, void *useraddr)
> +{
> +	u32 cmd;
> +	struct adapter *adapter = dev->priv;
> +
> +	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
> +		return -EFAULT;
> +
> +	switch (cmd) {
> +	case ETHTOOL_SETREG: {
> +		struct ethtool_reg edata;
> +
> +		if (!capable(CAP_NET_ADMIN))
> +			return -EPERM;
> +		if (copy_from_user(&edata, useraddr, sizeof(edata)))
> +			return -EFAULT;
> +		if ((edata.addr & 3) != 0 || edata.addr >= adapter->mmio_len)
> +			return -EINVAL;
> +		if (edata.addr == A_ESPI_MISC_CONTROL)
> +			t1_espi_set_misc_ctrl(adapter, edata.val);
> +		else {
> +			if (edata.addr == 0x950)
> +				t1_sge_set_ptimeout(adapter, edata.val);
> +			else
> +				writel(edata.val, adapter->regs + edata.addr);
> +		}
> +		break;
> +	}
> +	case ETHTOOL_GETREG: {
> +		struct ethtool_reg edata;
> +
> +		if (copy_from_user(&edata, useraddr, sizeof(edata)))
> +			return -EFAULT;
> +		if ((edata.addr & 3) != 0 || edata.addr >= adapter->mmio_len)
> +			return -EINVAL;
> +		if (edata.addr >= 0x900 && edata.addr <= 0x93c)
> +			edata.val = t1_espi_get_mon(adapter, edata.addr, 1);
> +		else {
> +			if (edata.addr == 0x950)
> +				edata.val = t1_sge_get_ptimeout(adapter);
> +			else
> +				edata.val = readl(adapter->regs + edata.addr);
> +		}
> +		if (copy_to_user(useraddr, &edata, sizeof(edata)))
> +			return -EFAULT;
> +		break;
> +	}
> +	case ETHTOOL_SETTPI: {
> +		struct ethtool_reg edata;
> +
> +		if (!capable(CAP_NET_ADMIN))
> +			return -EPERM;
> +		if (copy_from_user(&edata, useraddr, sizeof(edata)))
> +			return -EFAULT;
> +		if ((edata.addr & 3) != 0)
> +			return -EINVAL;
> +		t1_tpi_write(adapter, edata.addr, edata.val);
> +		break;
> +	}
> +	case ETHTOOL_GETTPI: {
> +		struct ethtool_reg edata;
> +
> +		if (copy_from_user(&edata, useraddr, sizeof(edata)))
> +			return -EFAULT;
> +		if ((edata.addr & 3) != 0)
> +			return -EINVAL;
> +		t1_tpi_read(adapter, edata.addr, &edata.val);
> +		if (copy_to_user(useraddr, &edata, sizeof(edata)))
> +			return -EFAULT;
> +		break;
> +	}
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +	return 0;
> +}

eliminate get/set register ioctls.  don't use ethtool namespace.


> +static int t1_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
> +{
> +	struct adapter *adapter = dev->priv;
> +	struct mii_ioctl_data *data = (struct mii_ioctl_data *)&req->ifr_data;
> +
> +	switch (cmd) {
> +	case SIOCGMIIPHY:
> +		data->phy_id = adapter->port[dev->if_port].phy->addr;
> +		/* FALLTHRU */
> +	case SIOCGMIIREG: {
> +		struct cphy *phy = adapter->port[dev->if_port].phy;
> +		u32 val;
> +
> +		if (!phy->mdio_read) return -EOPNOTSUPP;

one C statement per line


> +		phy->mdio_read(adapter, data->phy_id, 0, data->reg_num & 0x1f,
> +			       &val);
> +		data->val_out = val;
> +		break;
> +	}
> +	case SIOCSMIIREG: {
> +		struct cphy *phy = adapter->port[dev->if_port].phy;
> +
> +		if (!capable(CAP_NET_ADMIN)) return -EPERM;
> +		if (!phy->mdio_write) return -EOPNOTSUPP;

one C statement per line


> +		phy->mdio_write(adapter, data->phy_id, 0, data->reg_num & 0x1f,
> +				data->val_in);
> +		break;
> +	}
> +
> +	case SIOCCHETHTOOL:
> +		return ethtool_ioctl(dev, (void *)req->ifr_data);

don't obfuscate.  Use SIOCDEVPRIVATE.


> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +	return 0;
> +}
> +
> +static int t1_change_mtu(struct net_device *dev, int new_mtu)
> +{
> +	int ret;
> +	struct adapter *adapter = dev->priv;
> +	struct cmac *mac = adapter->port[dev->if_port].mac;
> +
> +	if (!mac->ops->set_mtu)
> +		return -EOPNOTSUPP;

delete hook


> +	if (new_mtu < 68)
> +		return -EINVAL;
> +	if ((ret = mac->ops->set_mtu(mac, new_mtu)))
> +		return ret;

ditto


> +	dev->mtu = new_mtu;
> +	return 0;
> +}
> +
> +static int t1_set_mac_addr(struct net_device *dev, void *p)
> +{
> +	struct adapter *adapter = dev->priv;
> +	struct cmac *mac = adapter->port[dev->if_port].mac;
> +	struct sockaddr *addr = p;
> +
> +	if (!mac->ops->macaddress_set)
> +		return -EOPNOTSUPP;
> +
> +	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
> +	mac->ops->macaddress_set(mac, dev->dev_addr);
> +	return 0;

ditto


> +#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
> +static void vlan_rx_register(struct net_device *dev,
> +				   struct vlan_group *grp)
> +{
> +	struct adapter *adapter = dev->priv;
> +
> +	spin_lock_irq(&adapter->async_lock);
> +	adapter->vlan_grp = grp;
> +	t1_set_vlan_accel(adapter, grp != NULL);
> +	spin_unlock_irq(&adapter->async_lock);
> +}
> +
> +static void vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
> +{
> +	struct adapter *adapter = dev->priv;
> +
> +	spin_lock_irq(&adapter->async_lock);
> +	if (adapter->vlan_grp)
> +		adapter->vlan_grp->vlan_devices[vid] = NULL;
> +	spin_unlock_irq(&adapter->async_lock);
> +}
> +#endif
> +
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +static void t1_netpoll(struct net_device *dev)
> +{
> +	struct adapter *adapter = dev->priv;
> +
> +	t1_interrupt(adapter->pdev->irq, adapter, NULL);
> +}
> +#endif

missing disable/enable_irq() calls


> +/*
> + * Periodic accumulation of MAC statistics.  This is used only if the MAC
> + * does not have any other way to prevent stats counter overflow.
> + */

counters will always overflow.

The stats reader is responsible to collecting stats at a rate rapid 
enough to compensate for this.
> 
> +static void ext_intr_task(void *data)
> +{
> +       u32 enable;
> +       struct adapter *adapter = data;
> +
> +       elmer0_ext_intr_handler(adapter);
> +
> +       /* Now reenable external interrupts */
> +       t1_write_reg_4(adapter, A_PL_CAUSE, F_PL_INTR_EXT);
> +       enable = t1_read_reg_4(adapter, A_PL_ENABLE);
> +       t1_write_reg_4(adapter, A_PL_ENABLE, enable | F_PL_INTR_EXT);
> +       adapter->slow_intr_mask |= F_PL_INTR_EXT;
> +}

> +/*
> + * Interrupt-context handler for elmer0 external interrupts.
> + */
> +void t1_elmer0_ext_intr(struct adapter *adapter)
> +{
> +	u32 enable = t1_read_reg_4(adapter, A_PL_ENABLE);
> +
> +	/*
> +	 * Schedule a task to handle external interrupts as we require
> +	 * a process context.  We disable EXT interrupts in the interim
> +	 * and let the task reenable them when it's done.
> +	 */
> +	adapter->slow_intr_mask &= ~F_PL_INTR_EXT;
> +	t1_write_reg_4(adapter, A_PL_ENABLE, enable & ~F_PL_INTR_EXT);
> +	schedule_work(&adapter->ext_intr_handler_task);
> +}

the above two functions have a tiny race window


> +static int __devinit init_one(struct pci_dev *pdev,
> +			      const struct pci_device_id *ent)
> +{
> +	static int version_printed;
> +
> +	int i, err, pci_using_dac = 0;
> +	unsigned long mmio_start, mmio_len;
> +	const struct board_info *bi;
> +	struct adapter *adapter = NULL;
> +	struct port_info *pi;
> +
> +	if (!version_printed) {
> +		printk(KERN_INFO "%s - version %s\n", driver_string,
> +		       driver_version);
> +		++version_printed;
> +	}
> +
> +	err = pci_enable_device(pdev);
> +	if (err)
> +		return err;
> +
> +	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
> +		CH_ERR("%s: cannot find PCI device memory base address\n",
> +		       pci_name(pdev));
> +		err = -ENODEV;
> +		goto out_disable_pdev;
> +	}
> +
> +	if (!pci_set_dma_mask(pdev, PCI_DMA_64BIT)) {
> +		pci_using_dac = 1;
> +		if (pci_set_consistent_dma_mask(pdev, PCI_DMA_64BIT)) {
> +			CH_ERR("%s: unable to obtain 64-bit DMA for"
> +			       "consistent allocations\n", pci_name(pdev));
> +			err = -ENODEV;
> +			goto out_disable_pdev;
> +		}
> +	} else if ((err = pci_set_dma_mask(pdev, PCI_DMA_32BIT)) != 0) {
> +		CH_ERR("%s: no usable DMA configuration\n", pci_name(pdev));
> +		goto out_disable_pdev;
> +	}

missing call to pci_set_consistent_dma_mask()

see drivers/net/tg3.c for an example.


> +	err = pci_request_regions(pdev, driver_name);
> +	if (err) {
> +		CH_ERR("%s: cannot obtain PCI resources\n", pci_name(pdev));
> +		goto out_disable_pdev;
> +	}
> +
> +	pci_set_master(pdev);
> +
> +	mmio_start = pci_resource_start(pdev, 0);
> +	mmio_len = pci_resource_len(pdev, 0);
> +	bi = t1_get_board_info(ent->driver_data);
> +
> +	for (i = 0; i < bi->port_number; ++i) {
> +		struct net_device *netdev;
> +
> +		netdev = alloc_etherdev(adapter ? 0 : sizeof(*adapter));
> +		if (!netdev) {
> +			err = -ENOMEM;
> +			goto out_free_dev;
> +		}
> +
> +		SET_MODULE_OWNER(netdev);
> +		SET_NETDEV_DEV(netdev, &pdev->dev);
> +
> +		if (!adapter) {
> +			adapter = netdev->priv;
> +			adapter->pdev = pdev;
> +			adapter->port[0].dev = netdev;  /* so we don't leak it */
> +
> +			adapter->regs = ioremap(mmio_start, mmio_len);
> +			if (!adapter->regs) {
> +				CH_ERR("%s: cannot map device registers\n",
> +				       pci_name(pdev));
> +				err = -ENOMEM;
> +				goto out_free_dev;
> +			}
> +
> +			if (t1_get_board_rev(adapter, bi, &adapter->params)) {
> +				err = -ENODEV;	  /* Can't handle this chip rev */
> +				goto out_free_dev;
> +			}
> +
> +			adapter->name = pci_name(pdev);
> +			adapter->msg_enable = dflt_msg_enable;
> +			adapter->mmio_len = mmio_len;
> +
> +			init_MUTEX(&adapter->mib_mutex);
> +			spin_lock_init(&adapter->tpi_lock);
> +			spin_lock_init(&adapter->work_lock);
> +			spin_lock_init(&adapter->async_lock);
> +
> +			INIT_WORK(&adapter->ext_intr_handler_task,
> +				  ext_intr_task, adapter);
> +			INIT_WORK(&adapter->stats_update_task, mac_stats_task,
> +				  adapter);
> +
> +			pci_set_drvdata(pdev, netdev);
> +
> +		}
> +
> +		pi = &adapter->port[i];
> +		pi->dev = netdev;
> +		netif_carrier_off(netdev);
> +		netdev->irq = pdev->irq;
> +		netdev->if_port = i;

Why are you setting this?  Does the value actually affect any operations?


> +		netdev->mem_start = mmio_start;
> +		netdev->mem_end = mmio_start + mmio_len - 1;

don't set this at all


> +		netdev->priv = adapter;
> +		netdev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
> +		adapter->flags |= RX_CSUM_ENABLED | TCP_CSUM_CAPABLE;
> +		if (pci_using_dac)
> +			netdev->features |= NETIF_F_HIGHDMA;
> +		if (vlan_tso_capable(adapter)) {
> +			adapter->flags |= UDP_CSUM_CAPABLE;
> +#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
> +			adapter->flags |= VLAN_ACCEL_CAPABLE;
> +			netdev->features |=
> +				NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
> +			netdev->vlan_rx_register = vlan_rx_register;
> +			netdev->vlan_rx_kill_vid = vlan_rx_kill_vid;
> +#endif
> +			adapter->flags |= TSO_CAPABLE;
> +			netdev->features |= NETIF_F_TSO;
> +		}
> +
> +		netdev->open = cxgb_open;
> +		netdev->stop = cxgb_close;
> +		netdev->hard_start_xmit = t1_start_xmit;
> +		netdev->hard_header_len += (adapter->flags & TSO_CAPABLE) ?
> +			sizeof(struct cpl_tx_pkt_lso) :
> +			sizeof(struct cpl_tx_pkt);

it's a bit unusual to be messing with hard_header_len.

probably unwise.


> +		netdev->get_stats = t1_get_stats;
> +		netdev->set_multicast_list = t1_set_rxmode;
> +		netdev->do_ioctl = t1_ioctl;
> +		netdev->change_mtu = t1_change_mtu;
> +		netdev->set_mac_address = t1_set_mac_addr;
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +		netdev->poll_controller = t1_netpoll;
> +#endif
> +		netdev->weight = 64;
> +
> +		SET_ETHTOOL_OPS(netdev, &t1_ethtool_ops);
> +	}
> +
> +	if (t1_init_sw_modules(adapter, bi) < 0) {
> +		err = -ENODEV;
> +		goto out_free_dev;
> +	}
> +
> +	/*
> +	 * The card is now ready to go.  If any errors occur during device
> +	 * registration we do not fail the whole card but rather proceed only
> +	 * with the ports we manage to register successfully.  However we must
> +	 * register at least one net device.
> +	 */
> +	for (i = 0; i < bi->port_number; ++i) {
> +		err = register_netdev(adapter->port[i].dev);
> +		if (err)
> +			CH_WARN("%s: cannot register net device %s, skipping\n",
> +				pci_name(pdev), adapter->port[i].dev->name);
> +		else {
> +			/*
> +			 * Change the name we use for messages to the name of
> +			 * the first successfully registered interface.
> +			 */
> +			if (!adapter->registered_device_map)
> +				adapter->name = adapter->port[i].dev->name;
> +
> +			__set_bit(i, &adapter->registered_device_map);
> +		}
> +	}
> +	if (!adapter->registered_device_map) {
> +		CH_ERR("%s: could not register any net devices\n",
> +		       pci_name(pdev));
> +		goto out_release_adapter_res;
> +	}
> +
> +	printk(KERN_INFO "%s: %s (rev %d), %s %dMHz/%d-bit\n", adapter->name,
> +	       bi->desc, adapter->params.chip_revision,
> +	       adapter->params.pci.is_pcix ? "PCIX" : "PCI",
> +	       adapter->params.pci.speed, adapter->params.pci.width);
> +	return 0;
> +
> + out_release_adapter_res:
> +	t1_free_sw_modules(adapter);
> + out_free_dev:
> +	if (adapter) {
> +		if (adapter->regs)
> +			iounmap(adapter->regs);
> +		for (i = bi->port_number - 1; i >= 0; --i)
> +			if (adapter->port[i].dev)
> +				free_netdev(adapter->port[i].dev);
> +	}
> +	pci_release_regions(pdev);
> + out_disable_pdev:
> +	pci_disable_device(pdev);
> +	pci_set_drvdata(pdev, NULL);
> +	return err;
> +}
> +
> +static inline void t1_sw_reset(struct pci_dev *pdev)
> +{
> +	pci_write_config_dword(pdev, A_PCICFG_PM_CSR, 3);
> +	pci_write_config_dword(pdev, A_PCICFG_PM_CSR, 0);
> +}

there should be standard functions for D3->D0 transition, IIRC



> +static void __devexit remove_one(struct pci_dev *pdev)
> +{
> +	struct net_device *dev = pci_get_drvdata(pdev);
> +
> +	if (dev) {
> +		int i;
> +		struct adapter *adapter = dev->priv;
> +
> +		for_each_port(adapter, i)
> +			if (test_bit(i, &adapter->registered_device_map))
> +				unregister_netdev(adapter->port[i].dev);
> +
> +		t1_free_sw_modules(adapter);
> +		iounmap(adapter->regs);
> +		while (--i >= 0)
> +			if (adapter->port[i].dev)
> +				free_netdev(adapter->port[i].dev);
> +		pci_release_regions(pdev);
> +		pci_disable_device(pdev);
> +		pci_set_drvdata(pdev, NULL);
> +		t1_sw_reset(pdev);
> +	}
> +}
> +
> +static struct pci_driver driver = {
> +	.name     = driver_name,
> +	.id_table = t1_pci_tbl,
> +	.probe    = init_one,
> +	.remove   = __devexit_p(remove_one),
> +};
> +
> +static int __init t1_init_module(void)
> +{
> +	return pci_module_init(&driver);
> +}
> +
> +static void __exit t1_cleanup_module(void)
> +{
> +	pci_unregister_driver(&driver);
> +}
> +
> +module_init(t1_init_module);
> +module_exit(t1_cleanup_module);
> +
> diff -puN /dev/null drivers/net/chelsio/cxgb2.h
> --- /dev/null	2004-08-10 19:55:00.000000000 -0600
> +++ 25-akpm/drivers/net/chelsio/cxgb2.h	2005-03-24 21:17:43.000000000 -0700

> +/* This belongs in if_ether.h */
> +#define ETH_P_CPL5 0xf

What is CPL5?

Might as well patch if_ether.h.


> +struct cmac;
> +struct cphy;
> +
> +struct port_info {
> +	struct net_device *dev;
> +	struct cmac *mac;
> +	struct cphy *phy;
> +	struct link_config link_config;
> +	struct net_device_stats netstats;
> +};
> +
> +struct cxgbdev;
> +struct t1_sge;
> +struct pemc3;
> +struct pemc4;
> +struct pemc5;
> +struct peulp;
> +struct petp;
> +struct pecspi;
> +struct peespi;
> +struct work_struct;
> +struct vlan_group;
> +
> +enum {					/* adapter flags */
> +	FULL_INIT_DONE        = 0x1,
> +	USING_MSI             = 0x2,
> +	TSO_CAPABLE           = 0x4,
> +	TCP_CSUM_CAPABLE      = 0x8,
> +	UDP_CSUM_CAPABLE      = 0x10,
> +	VLAN_ACCEL_CAPABLE    = 0x20,
> +	RX_CSUM_ENABLED       = 0x40,
> +};

use bit style '1 << n' ?


> +struct adapter {
> +	u8 *regs;
> +	struct pci_dev *pdev;
> +	unsigned long registered_device_map;
> +	unsigned long open_device_map;
> +	unsigned int flags;

unsigned long is generally better for bitflag variables


> +	const char *name;
> +	int msg_enable;
> +	u32 mmio_len;
> +
> +	struct work_struct ext_intr_handler_task;
> +	struct adapter_params params;
> +
> +	struct vlan_group *vlan_grp;
> +
> +	/* Terminator modules. */
> +	struct sge    *sge;
> +	struct pemc3  *mc3;
> +	struct pemc4  *mc4;
> +	struct pemc5  *mc5;
> +	struct petp   *tp;
> +	struct pecspi *cspi;
> +	struct peespi *espi;
> +	struct peulp  *ulp;
> +
> +	struct port_info port[MAX_NPORTS];
> +	struct work_struct stats_update_task;
> +	struct timer_list stats_update_timer;
> +
> +	struct semaphore mib_mutex;
> +	spinlock_t tpi_lock;
> +	spinlock_t work_lock;
> +
> +	spinlock_t async_lock ____cacheline_aligned; /* guards async operations */

can you explain this?  You really shouldn't mess with attributes on 
spinlocks.  That's highly arch-specific.


I gave up reviewing at this point.  That's plenty of changes to tackle, 
particularly the removal of all the t1_write_reg_4() wrappers.

	Jeff
