From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/5] NetXen: temp monitoring, newer firmware support, mm footprint reduction
Date: Fri, 1 Dec 2006 01:02:04 +0100
Message-ID: <20061201000204.GA19837@electric-eye.fr.zoreil.com>
References: <20061130185002.GA32305@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, amitkale@netxen.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:53469 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S967994AbWLAACt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 19:02:49 -0500
To: Don Fry <brazilnut@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20061130185002.GA32305@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don Fry <brazilnut@us.ibm.com> :
> NetXen: 1G/10G Ethernet Driver updates
> 	- Temparature monitoring and device control
> 	- Memory footprint reduction
> 	- Driver changes to support newer version of firmware
> 
> Signed-off-by: Amit S. Kale <amitkale@netxen.com>
> Signed-off-by: Don Fry <brazilnut@us.ibm.com>
> 
> diff -Nupr netdev-2.6/drivers/net/netxen.one/netxen_nic_ethtool.c netdev-2.6/drivers/net/netxen/netxen_nic_ethtool.c
> --- netdev-2.6/drivers/net/netxen.one/netxen_nic_ethtool.c	2006-11-30 09:16:23.000000000 -0800
> +++ netdev-2.6/drivers/net/netxen/netxen_nic_ethtool.c	2006-11-30 09:22:41.000000000 -0800
> @@ -53,6 +53,9 @@ struct netxen_nic_stats {
>  #define NETXEN_NIC_STAT(m) sizeof(((struct netxen_port *)0)->m), \
>  			offsetof(struct netxen_port, m)
>  
> +#define NETXEN_NIC_PORT_WINDOW 0x10000
> +#define NETXEN_NIC_INVALID_DATA 0xDEADBEEF
> +
>  static const struct netxen_nic_stats netxen_nic_gstrings_stats[] = {
>  	{"rcvd_bad_skb", NETXEN_NIC_STAT(stats.rcvdbadskb)},
>  	{"xmit_called", NETXEN_NIC_STAT(stats.xmitcalled)},
> @@ -111,9 +114,9 @@ netxen_nic_get_drvinfo(struct net_device
>  {
>  	struct netxen_port *port = netdev_priv(dev);
>  	struct netxen_adapter *adapter = port->adapter;
> -	uint32_t fw_major = 0;
> -	uint32_t fw_minor = 0;
> -	uint32_t fw_build = 0;
> +	u32 fw_major = 0;
> +	u32 fw_minor = 0;
> +	u32 fw_build = 0;

The description of the patch did not announce (welcome) cleanup.

There are a few ones.

[...]
>  	strncpy(drvinfo->driver, "netxen_nic", 32);
>  	strncpy(drvinfo->version, NETXEN_NIC_LINUX_VERSIONID, 32);
> @@ -136,6 +139,8 @@ netxen_nic_get_settings(struct net_devic
>  {
>  	struct netxen_port *port = netdev_priv(dev);
>  	struct netxen_adapter *adapter = port->adapter;
> +	struct netxen_board_info *boardinfo;
> +	boardinfo = &adapter->ahw.boardcfg;

Missing separating line or merge the two lines.

[...]
> @@ -182,13 +174,47 @@ netxen_nic_get_settings(struct net_devic
>  
>  		ecmd->speed = SPEED_10000;
>  		ecmd->duplex = DUPLEX_FULL;
> -		ecmd->phy_address = port->portnum;
> -		ecmd->transceiver = XCVR_EXTERNAL;
>  		ecmd->autoneg = AUTONEG_DISABLE;
> -		return 0;
> +	} else
> +		return -EIO;
> +
> +	ecmd->phy_address = port->portnum;
> +	ecmd->transceiver = XCVR_EXTERNAL;
> +
> +	switch ((netxen_brdtype_t) boardinfo->board_type) {
> +	case NETXEN_BRDTYPE_P2_SB35_4G:
> +	case NETXEN_BRDTYPE_P2_SB31_2G:
> +		ecmd->supported |= SUPPORTED_Autoneg;
> +		ecmd->advertising |= ADVERTISED_Autoneg;
> +	case NETXEN_BRDTYPE_P2_SB31_10G_CX4:
> +		ecmd->supported |= SUPPORTED_TP;
> +		ecmd->advertising |= ADVERTISED_TP;
> +		ecmd->port = PORT_TP;
> +		ecmd->autoneg = (boardinfo->board_type ==
> +				 NETXEN_BRDTYPE_P2_SB31_10G_CX4) ?
> +		    (AUTONEG_DISABLE) : (port->link_autoneg);
> +		break;
> +	case NETXEN_BRDTYPE_P2_SB31_10G_HMEZ:
> +	case NETXEN_BRDTYPE_P2_SB31_10G_IMEZ:
> +		ecmd->supported |= SUPPORTED_MII;
> +		ecmd->advertising |= ADVERTISED_MII;
> +		ecmd->port = PORT_FIBRE;
> +		ecmd->autoneg = AUTONEG_DISABLE;
> +		break;
> +	case NETXEN_BRDTYPE_P2_SB31_10G:
> +		ecmd->supported |= SUPPORTED_FIBRE;
> +		ecmd->advertising |= ADVERTISED_FIBRE;
> +		ecmd->port = PORT_FIBRE;
> +		ecmd->autoneg = AUTONEG_DISABLE;
> +		break;
> +	default:
> +		printk("ERROR: Unsupported board model %d\n",
> +		       (netxen_brdtype_t) boardinfo->board_type);

Missing KERN_ERR

[...]
> diff -Nupr netdev-2.6/drivers/net/netxen.one/netxen_nic.h netdev-2.6/drivers/net/netxen/netxen_nic.h
> --- netdev-2.6/drivers/net/netxen.one/netxen_nic.h	2006-11-30 09:16:23.000000000 -0800
> +++ netdev-2.6/drivers/net/netxen/netxen_nic.h	2006-11-30 09:22:41.000000000 -0800
[...]
> @@ -328,6 +343,7 @@ typedef enum {
>  	NETXEN_BRDTYPE_P2_SB31_10G_HMEZ = 0x000e,
>  	NETXEN_BRDTYPE_P2_SB31_10G_CX4 = 0x000f
>  } netxen_brdtype_t;
> +#define NUM_SUPPORTED_BOARDS (sizeof(netxen_boards)/sizeof(netxen_brdinfo_t))
>  
>  typedef enum {
>  	NETXEN_BRDMFG_INVENTEC = 1
[...]
> @@ -869,7 +937,10 @@ static inline void netxen_nic_disable_in
>  	/*
>  	 * ISR_INT_MASK: Can be read from window 0 or 1.
>  	 */
> -	writel(0x7ff, (void __iomem *)(adapter->ahw.pci_base + ISR_INT_MASK));
> +	writel(0x7ff,
> +	       (void __iomem
> +		*)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK)));
> +

Yuck.

[...]
> @@ -888,13 +959,83 @@ static inline void netxen_nic_enable_int
>  		break;
>  	}
>  
> -	writel(mask, (void __iomem *)(adapter->ahw.pci_base + ISR_INT_MASK));
> +	writel(mask,
> +	       (void __iomem
> +		*)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK)));
>  
>  	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
>  		mask = 0xbff;
>  		writel(mask, (void __iomem *)
> -		       (adapter->ahw.pci_base + ISR_INT_TARGET_MASK));
> +		       (PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_TARGET_MASK)));
> +	}
> +}
> +
> +/*
> + * NetXen Board information
> + */
> +
> +#define NETXEN_MAX_SHORT_NAME 16
> +typedef struct {
> +	netxen_brdtype_t brdtype;	/* type of board */
> +	long ports;		/* max no of physical ports */
> +	char short_name[NETXEN_MAX_SHORT_NAME];
> +} netxen_brdinfo_t;

typedef

> +
> +static const netxen_brdinfo_t netxen_boards[] = {
> +	{NETXEN_BRDTYPE_P2_SB31_10G_CX4, 1, "XGb CX4"},
> +	{NETXEN_BRDTYPE_P2_SB31_10G_HMEZ, 1, "XGb HMEZ"},
> +	{NETXEN_BRDTYPE_P2_SB31_10G_IMEZ, 2, "XGb IMEZ"},
> +	{NETXEN_BRDTYPE_P2_SB31_10G, 1, "XGb XFP"},
> +	{NETXEN_BRDTYPE_P2_SB35_4G, 4, "Quad Gb"},
> +	{NETXEN_BRDTYPE_P2_SB31_2G, 2, "Dual Gb"},
> +};
> +
> +#define NUM_SUPPORTED_BOARDS (sizeof(netxen_boards)/sizeof(netxen_brdinfo_t))

Already defined. See @@ -328,6 +343,7 @@ typedef enum {


> +
> +static inline void get_brd_ports_name_by_type(u32 type, int *ports, char *name)
> +{
> +	int i, found = 0;
> +	for (i = 0; i < NUM_SUPPORTED_BOARDS; ++i) {
> +		if (netxen_boards[i].brdtype == type) {
> +			*ports = netxen_boards[i].ports;
> +			strcpy(name, netxen_boards[i].short_name);
> +			found = 1;
> +			break;
> +		}
> +	}
> +	if (!found) {
> +		*ports = 0;
> +		name = "Unknown";
> +	}
> +}

- 'i' and 'found' carry the same information.
- this function does not seem to be used anywhere.
- avoid inline

[...]
> diff -Nupr netdev-2.6/drivers/net/netxen.one/netxen_nic_hw.c netdev-2.6/drivers/net/netxen/netxen_nic_hw.c
> --- netdev-2.6/drivers/net/netxen.one/netxen_nic_hw.c	2006-11-30 09:16:23.000000000 -0800
> +++ netdev-2.6/drivers/net/netxen/netxen_nic_hw.c	2006-11-30 09:22:41.000000000 -0800
[...]
> @@ -214,25 +225,34 @@ int netxen_nic_hw_resources(struct netxe
>  	}
>  	DPRINTK(INFO, "Recieve Peg ready too. starting stuff\n");
>  
> -	addr = pci_alloc_consistent(adapter->ahw.pdev,
> -				    sizeof(struct cmd_desc_type0) *
> -				    adapter->max_tx_desc_count,
> -				    &hw->cmd_desc_phys_addr);
> +	addr = netxen_alloc(adapter->ahw.pdev,
> +			    sizeof(struct cmd_desc_type0) *
> +			    adapter->max_tx_desc_count,
> +			    &hw->cmd_desc_phys_addr, &hw->cmd_desc_pdev);
> +
>  	if (addr == NULL) {
>  		DPRINTK(ERR, "bad return from pci_alloc_consistent\n");
> -		err = -ENOMEM;
> -		return err;
> +		return -ENOMEM;
>  	}
>  
> -	/* we need to prelink all of the cmd descriptors */
> -	pcmd = (struct cmd_desc_type0 *)addr;
> -	for (i = 1; i < adapter->max_tx_desc_count; i++) {
> -		pcmd->netxen_next =
> -		    (card_cmdring + i * sizeof(struct cmd_desc_type0));
> -		pcmd++;
> +	pause_addr = netxen_alloc(adapter->ahw.pdev, 512,
> +				  (dma_addr_t *) & hw->pause_physaddr,
> +				  &hw->pause_pdev);
> +	if (pause_addr == NULL) {
> +		DPRINTK(1, ERR, "bad return from pci_alloc_consistent\n");
> +		return -ENOMEM;

"addr" leak (whatever is done outside of the function, hw->cmd_desc_phys_addr
is set but hw->cmd_desc_head is not).

> +	}
> +
> +	hw->pauseaddr = (char *)pause_addr;

Cast from void *

[...]
> @@ -254,10 +275,11 @@ int netxen_nic_hw_resources(struct netxe
>  			rcv_desc->desc_head = (struct rcv_desc *)addr;
>  		}
>  
> -		addr = pci_alloc_consistent(adapter->ahw.pdev,
> -					    STATUS_DESC_RINGSIZE,
> -					    &recv_ctx->
> -					    rcv_status_desc_phys_addr);
> +		addr = netxen_alloc(adapter->ahw.pdev,
> +				    STATUS_DESC_RINGSIZE,
> +				    &recv_ctx->
> +				    rcv_status_desc_phys_addr,
> +				    &recv_ctx->rcv_status_desc_pdev);

Yuck

[...]
> @@ -629,7 +675,7 @@ void netxen_nic_write_w0(struct netxen_a
>  	void __iomem *addr;
>  
>  	netxen_nic_pci_change_crbwindow(adapter, 0);
> -	addr = (void __iomem *)(adapter->ahw.pci_base + index);
> +	addr = (void __iomem *)(pci_base_offset(adapter, index));
>  	writel(value, addr);
>  	netxen_nic_pci_change_crbwindow(adapter, 1);
>  }
> @@ -639,7 +685,7 @@ void netxen_nic_read_w0(struct netxen_ad
>  {
>  	void __iomem *addr;
>  
> -	addr = (void __iomem *)(adapter->ahw.pci_base + index);
> +	addr = (void __iomem *)(pci_base_offset(adapter, index));

Useless cast: pci_base_offset() returns (void __iomem *).

-- 
Ueimor
