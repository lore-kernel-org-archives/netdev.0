From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 2/5] NetXen: Multicast filter for NetXen driver
Date: Fri, 1 Jun 2007 13:24:57 +0200
Message-ID: <200706011324.57678.mb@bu3sch.de>
References: <200706011114.l51BEZTx004682@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:39117
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756429AbXFALZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 07:25:25 -0400
In-Reply-To: <200706011114.l51BEZTx004682@dut39.unminc.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 01 June 2007 13:14:35 Mithlesh Thukral wrote:
> NetXen: Add multicast filter code
> This patch will add manage the multicast filter from driver.
> It will add capability to write multicast addresses to hardware.
> 
> Signed-by: Mithlesh Thukral <mithlesh@netxen.com>
> ---
> 
>  drivers/net/netxen/netxen_nic.h     |   24 +++++
>  drivers/net/netxen/netxen_nic_hdr.h |    3 
>  drivers/net/netxen/netxen_nic_hw.c  |  115 +++++++++++++++++++++++++-
>  3 files changed, 139 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
> index ad6688e..c74402f 100644
> --- a/drivers/net/netxen/netxen_nic.h
> +++ b/drivers/net/netxen/netxen_nic.h
> @@ -261,6 +261,27 @@ #define netxen_set_msg_ctxid(config_word
>  #define netxen_set_msg_opcode(config_word, val)	\
>  	((config_word) &= ~(0xf<<28), (config_word) |= (val & 0xf) << 28)
>  
> +#define netxen_set_addr_ctl_id_pool0(config_word, val)	\
> +	((config_word) &= ~3, (config_word) |= val & 0x3)
> +#define netxen_set_addr_ctl_enable_xtnd_0(config_word)	\
> +	((config_word) |= 1 << 2)
> +#define netxen_set_addr_ctl_id_pool1(config_word, val)	\
> +	((config_word) &= ~(0x3<<4), (config_word) |= (val & 0x3) << 4)
> +#define netxen_set_addr_ctl_enable_xtnd_1(config_word)	\
> +	((config_word) |= 1 << 6)
> +#define netxen_set_addr_ctl_id_pool2(config_word, val)	\
> +	((config_word) &= ~(0x3<<8), (config_word) |= (val & 0x3) << 8)
> +#define netxen_set_addr_ctl_enable_xtnd_2(config_word)	\
> +	((config_word) |= 1 << 10)
> +#define netxen_set_addr_ctl_id_pool3(config_word, val)	\
> +	((config_word) &= ~(0x3<<12), (config_word) |= (val & 0x3) << 12)
> +#define netxen_set_addr_ctl_enable_xtnd_3(config_word)	\
> +	((config_word) |= 1 << 14)
> +#define netxen_set_addr_ctl_mode(config_word, val)	\
> +	((config_word) &= ~(0x3<<26), (config_word) |= (val & 0x3) << 26)
> +#define netxen_set_addr_ctl_enable_poll(config_word, val)	\
> +	((config_word) &= ~(0xf<<30), (config_word) |= (val & 0xf) << 30)
> +
>  struct netxen_rcv_context {
>  	__le64 rcv_ring_addr;
>  	__le32 rcv_ring_size;
> @@ -883,6 +904,9 @@ struct netxen_adapter {
>  	unsigned char mac_addr[ETH_ALEN];
>  	int mtu;
>  	int portnum;
> +	u8 promisc;
> +	u8 mc_enabled;
> +	u8 max_mc_count;
>  
>  	spinlock_t tx_lock;
>  	spinlock_t lock;
> diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
> index 608e37b..2bfecbc 100644
> --- a/drivers/net/netxen/netxen_nic_hdr.h
> +++ b/drivers/net/netxen/netxen_nic_hdr.h
> @@ -545,6 +545,9 @@ #define NETXEN_MULTICAST_ADDR_HI_1	(NETX
>  #define NETXEN_MULTICAST_ADDR_HI_2	(NETXEN_CRB_NIU + 0x1018)
>  #define NETXEN_MULTICAST_ADDR_HI_3	(NETXEN_CRB_NIU + 0x101c)
>  
> +#define NETXEN_UNICAST_ADDR_BASE	(NETXEN_CRB_NIU + 0x1080)
> +#define NETXEN_MULTICAST_ADDR_BASE	(NETXEN_CRB_NIU + 0x1100)
> +
>  #define	NETXEN_NIU_GB_MAC_CONFIG_0(I)		\
>  	(NETXEN_CRB_NIU + 0x30000 + (I)*0x10000)
>  #define	NETXEN_NIU_GB_MAC_CONFIG_1(I)		\
> diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
> index baff17a..fff3844 100644
> --- a/drivers/net/netxen/netxen_nic_hw.c
> +++ b/drivers/net/netxen/netxen_nic_hw.c
> @@ -303,6 +303,93 @@ int netxen_nic_set_mac(struct net_device
>  	return 0;
>  }
>  
> +#define NETXEN_UNICAST_ADDR(port, index)	\
> +	(NETXEN_UNICAST_ADDR_BASE+(port*32)+(index*8))
> +
> +int netxen_nic_enable_mcast_filter(struct netxen_adapter *adapter)
> +{
> +	u32 val = 0;
> +	u16 port = physical_port[adapter->portnum];
> +
> +	if (adapter->mc_enabled)
> +		return 0;
> +	
> +	netxen_set_addr_ctl_enable_poll(val, 0xf);
> +
> +	if (adapter->ahw.board_type == NETXEN_NIC_XGBE)
> +		netxen_set_addr_ctl_mode(val, 0x3);
> +	else
> +		netxen_set_addr_ctl_mode(val, 0x0);
> +
> +	netxen_set_addr_ctl_id_pool0(val, 0x0);
> +	netxen_set_addr_ctl_id_pool1(val, 0x1);
> +	netxen_set_addr_ctl_id_pool2(val, 0x2);
> +	netxen_set_addr_ctl_id_pool3(val, 0x3);
> +
> +	netxen_set_addr_ctl_enable_xtnd_0(val);
> +	netxen_set_addr_ctl_enable_xtnd_1(val);
> +	netxen_set_addr_ctl_enable_xtnd_2(val);
> +	netxen_set_addr_ctl_enable_xtnd_3(val);
> +	
> +	netxen_crb_writelit_adapter(adapter, NETXEN_MAC_ADDR_CNTL_REG, val);
> +	
> +	val = 0xffffff;
> +
> +	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port,0), val);
> +	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port,0)+4, 
> +					val);
> +	
> +	memcpy(&val, adapter->mac_addr, 3);
> +	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port,1), val);
> +
> +	memcpy(&val, adapter->mac_addr+3, 3);
> +	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port,1) + 4,
> +					val);
> +
> +	adapter->mc_enabled = 1;
> +	return 0;
> +}
> +
> +int netxen_nic_disable_mcast_filter(struct netxen_adapter *adapter)
> +{
> +	u32 val =  0;
> +	u16 port = physical_port[adapter->portnum];
> +
> +	if(!adapter->mc_enabled)
> +		return 0;
> +
> +	netxen_crb_writelit_adapter(adapter, NETXEN_MAC_ADDR_CNTL_REG, val);
> +
> +	memcpy(&val, adapter->mac_addr, 3);
> +	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port,0), val);
> +
> +	memcpy(&val, adapter->mac_addr+3, 3);
> +	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port,0) + 4,
> +					val);
> +
> +	adapter->mc_enabled = 0;
> +	return 0;
> +}
> +
> +#define NETXEN_MCAST_ADDR(port, index)	\
> +	(NETXEN_MULTICAST_ADDR_BASE+(port*0x80)+(index*8))
> +
> +int netxen_nic_set_mcast_addr(struct netxen_adapter *adapter, int index, 
> +				u8 *addr)
> +{
> +	u32 hi = 0;
> +	u32 lo = 0;
> +	u16 port = physical_port[adapter->portnum];
> +
> +	memcpy(&hi, addr, 3);
> +	memcpy(&lo, addr+3, 3);
> +
> +	netxen_crb_writelit_adapter(adapter, NETXEN_MCAST_ADDR(port,index), hi);
> +	netxen_crb_writelit_adapter(adapter, NETXEN_MCAST_ADDR(port,index) + 4,
> +					hi);
> +	return 0;
> +}
> +

Uhm, is that copying of a u8 array (which is little endian) to
an arch-endian u32. I'd say this will break on bigendian architectures.
Your code just works on little endian architectures.

-- 
Greetings Michael.
