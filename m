From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: RE: [PATCH 3/3] netxen: qlogic ethernet : Fix Endian Bug.
Date: Fri, 9 Mar 2012 10:34:49 -0600
Message-ID: <13A253B3F9BEFE43B93C09CF75F63CAA81A8AB3B75@MNEXMB1.qlogic.org>
References: <1330789663-30481-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: santosh nayak <santoshprasadnayak@gmail.com>,
	Sony Chacko <sony.chacko@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330789663-30481-1-git-send-email-santoshprasadnayak@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> -----Original Message-----
> From: santosh nayak [mailto:santoshprasadnayak@gmail.com]
> Sent: Saturday, March 03, 2012 9:18 PM
> To: Sony Chacko
> Cc: Rajesh Borundia; netdev; linux-kernel; kernel-
> janitors@vger.kernel.org; Santosh Nayak
> Subject: [PATCH 3/3] netxen: qlogic ethernet : Fix Endian Bug.
> 
> From: Santosh Nayak <santoshprasadnayak@gmail.com>
> 
> Fix endian bug.
> 
> Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
> ---
>  drivers/net/ethernet/qlogic/netxen/netxen_nic.h    |    4 ++--
>  drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c |   12 +++++++-----
>  .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    2 +-
>  3 files changed, 10 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
> b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
> index 2eeac32..b5de8a7 100644
> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
> @@ -954,7 +954,7 @@ typedef struct nx_mac_list_s {
> 
>  struct nx_vlan_ip_list {
>  	struct list_head list;
> -	u32 ip_addr;
> +	__be32 ip_addr;
>  };
> 
>  /*
> @@ -1780,7 +1780,7 @@ int netxen_process_rcv_ring(struct
> nx_host_sds_ring *sds_ring, int max);
>  void netxen_p3_free_mac_list(struct netxen_adapter *adapter);
>  int netxen_config_intr_coalesce(struct netxen_adapter *adapter);
>  int netxen_config_rss(struct netxen_adapter *adapter, int enable);
> -int netxen_config_ipaddr(struct netxen_adapter *adapter, u32 ip, int
> cmd);
> +int netxen_config_ipaddr(struct netxen_adapter *adapter, __be32 ip,
> int cmd);
>  int netxen_linkevent_request(struct netxen_adapter *adapter, int
> enable);
>  void netxen_advert_link_change(struct netxen_adapter *adapter, int
> linkup);
>  void netxen_pci_camqm_read_2M(struct netxen_adapter *, u64, u64 *);
> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
> b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
> index 6f37470..0f81287 100644
> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
> @@ -909,10 +909,11 @@ int netxen_config_rss(struct netxen_adapter
> *adapter, int enable)
>  	return rv;
>  }
> 
> -int netxen_config_ipaddr(struct netxen_adapter *adapter, u32 ip, int
> cmd)
> +int netxen_config_ipaddr(struct netxen_adapter *adapter, __be32 ip,
> int cmd)
>  {
>  	nx_nic_req_t req;
>  	u64 word;
> +	u64 ip_addr;
>  	int rv;
> 
>  	memset(&req, 0, sizeof(nx_nic_req_t));
> @@ -922,7 +923,8 @@ int netxen_config_ipaddr(struct netxen_adapter
> *adapter, u32 ip, int cmd)
>  	req.req_hdr = cpu_to_le64(word);
> 
>  	req.words[0] = cpu_to_le64(cmd);
> -	req.words[1] = cpu_to_le64(ip);
> +	ip_addr = be32_to_cpu(ip);
> +	*(__be64 *)&req.words[1] = cpu_to_be64(ip_addr);

Adapter requires ip value in big endian stored at lower 32 bit address.
The cpu_to_be64 will swap the lower 32 bit with higher 32 bit and adapter
Will get incorrect ip addr. Instead u can do.

       U32 *ip_addr;
       ip_addr = (u32 *)&req.words[1];
       *ip_addr = ip;

     
> 
>  	rv = netxen_send_cmd_descs(adapter, (struct cmd_desc_type0
> *)&req, 1);
>  	if (rv != 0) {
> @@ -1050,7 +1052,7 @@ int netxen_get_flash_mac_addr(struct
> netxen_adapter *adapter, u64 *mac)
>  	if (netxen_get_flash_block(adapter, offset, sizeof(u64), pmac) ==
> -1)
>  		return -1;
> 
> -	if (*mac == cpu_to_le64(~0ULL)) {
> +	if (*mac == ~0ULL) {

*mac is in little endian format so compare it with cpu_to_le64.

> 
>  		offset = NX_OLD_MAC_ADDR_OFFSET +
>  			(adapter->portnum * sizeof(u64));
> @@ -1059,7 +1061,7 @@ int netxen_get_flash_mac_addr(struct
> netxen_adapter *adapter, u64 *mac)
>  					offset, sizeof(u64), pmac) == -1)
>  			return -1;
> 
> -		if (*mac == cpu_to_le64(~0ULL))
> +		if (*mac == ~0ULL)

*mac here is in little endian format so compare it with cpu_to_le64.

>  			return -1;
>  	}
>  	return 0;
> @@ -2178,7 +2180,7 @@ lock_try:
>  		NX_WR_DUMP_REG(FLASH_ROM_WINDOW, adapter->ahw.pci_base0,
> waddr);
>  		raddr = FLASH_ROM_DATA + (fl_addr & 0x0000FFFF);
>  		NX_RD_DUMP_REG(raddr, adapter->ahw.pci_base0, &val);
> -		*data_buff++ = cpu_to_le32(val);
> +		*data_buff++ = val;

It should be cpu_to_le32 as it is returned to tool which requires
output in little endian.

>  		fl_addr += sizeof(val);
>  	}
>  	readl((void __iomem *)(adapter->ahw.pci_base0 +
> NX_FLASH_SEM2_ULK));
> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
> b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
> index 8dc4a134..70783b4 100644
> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
> @@ -818,7 +818,7 @@ netxen_check_options(struct netxen_adapter
> *adapter)
>  			adapter->driver_mismatch = 1;
>  			return;
>  		}
> -		ptr32[i] = cpu_to_le32(val);
> +		ptr32[i] = val;

Here val should be in little endian (cpu_to_le32) as it will be referenced by byte array to print serial number.

>  		offset += sizeof(u32);
>  	}
> 
> --
> 1.7.4.4
> 


Sorry for Late reply.

Rajesh
