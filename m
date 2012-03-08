From: <Parav.Pandit@Emulex.Com>
Subject: RE: [RFC 2/2] be2net: Added functionality to support RoCE driver
Date: Thu, 8 Mar 2012 05:04:38 -0800
Message-ID: <3cd7ea39-a8d3-4d63-9753-0c64fb7e3609@exht1.ad.emulex.com>
References: <1331142427-23721-1-git-send-email-parav.pandit@emulex.com>
 <1331142427-23721-2-git-send-email-parav.pandit@emulex.com>
 <470f5ea2-9344-42d5-b130-130d90a42250@exht1.ad.emulex.com>
 <20120308114859.GA23807@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <Parav.Pandit@Emulex.Com>
To: <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:55928 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757643Ab2CHNFE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 08:05:04 -0500
In-Reply-To: <20120308114859.GA23807@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inline.
Parav

-----Original Message-----
From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
Sent: Thursday, March 08, 2012 5:19 PM
To: Pandit, Parav
Cc: netdev@vger.kernel.org
Subject: Re: [RFC 2/2] be2net: Added functionality to support RoCE driver

parav.pandit@emulex.com <parav.pandit@emulex.com> :
[...]
> diff --git a/drivers/net/ethernet/emulex/benet/Makefile 
> b/drivers/net/ethernet/emulex/benet/Makefile
> index a60cd80..1a91b27 100644
> --- a/drivers/net/ethernet/emulex/benet/Makefile
> +++ b/drivers/net/ethernet/emulex/benet/Makefile
[...]
> @@ -372,6 +374,14 @@ struct be_adapter {
>  	u8 transceiver;
>  	u8 autoneg;
>  	u8 generation;		/* BladeEngine ASIC generation */
> +	u32 if_type;
> +	u8 __iomem *roce_db;	/* Door Bell */
> +	u32 roce_db_size;
> +	u32 roce_db_total_size;
> +	u64 roce_db_io_addr;

There may be room for some 'struct roce_db'.
[Parav] o.k. I'll move them to structure.

> +	void *ocrdma_dev;

Is there a reason why it could not be 'struct ocrdma_dev *o' ?
[Parav] Yes. Reason is NIC driver publishes interface to RoCE driver. NIC driver is not aware of ocrdma_dev structure.
So its void pointer.

> +	struct list_head entry;
> +
>  	u32 flash_status;
>  	struct completion flash_compl;
>  
> @@ -398,6 +408,9 @@ struct be_adapter {
>  #define OFF				0
>  #define lancer_chip(adapter)	((adapter->pdev->device == OC_DEVICE_ID3) || \
>  				 (adapter->pdev->device == OC_DEVICE_ID4))
> +#define be_roce_supported(adapter) ((adapter->if_type == SLI_INTF_TYPE_3 || \
> +				adapter->sli_family == SKYHAWK_SLI_FAMILY) && \
> +				(adapter->function_mode & RDMA_ENABLED))

No need for a macro. Could be static inline.

>  
>  extern const struct ethtool_ops be_ethtool_ops;
>  
> @@ -544,4 +557,17 @@ extern void be_cq_notify(struct be_adapter 
> *adapter, u16 qid, bool arm,  extern void be_link_status_update(struct 
> be_adapter *adapter, u8 link_status);  extern void 
> be_parse_stats(struct be_adapter *adapter);  extern int 
> be_load_fw(struct be_adapter *adapter, u8 *func);
> +
> +/*
> + * internal function to initialize-cleanup roce device.
> + */
> +extern void be_roce_dev_add(struct be_adapter *adapter); extern void 
> +be_roce_dev_remove(struct be_adapter *adapter);
> +
> +/*
> + * internal function to open-close roce device during ifup-ifdown.
> + */
> +extern void be_roce_dev_open(struct be_adapter *adapter); extern void 
> +be_roce_dev_close(struct be_adapter *adapter);

Nit: the name of the argument does not matter much here.

[...]
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c 
> b/drivers/net/ethernet/emulex/benet/be_main.c
> index e703d64..9554cc9 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
[...]
> @@ -3139,19 +3155,45 @@ static void be_unmap_pci_bars(struct be_adapter *adapter)
>  		iounmap(adapter->csr);
>  	if (adapter->db)
>  		iounmap(adapter->db);
> +	if (adapter->roce_db)
> +		iounmap(adapter->roce_db);
> +}
> +
> +static int lancer_roce_map_pci_bars(struct be_adapter *adapter) {
> +	struct pci_dev *pdev = adapter->pdev;
> +	u8 __iomem *addr;
> +	addr = ioremap_nocache(pci_resource_start(pdev, 2),
> +				pci_resource_len(pdev, 2));

- missing empty line.
- use pci_iomap

> +	if (addr == NULL)
> +		return -ENOMEM;
> +
> +	adapter->roce_db = addr;
> +	adapter->roce_db_io_addr = pci_resource_start(pdev, 2);
> +	adapter->roce_db_size = 8192;
> +	adapter->roce_db_total_size = pci_resource_len(pdev, 2);
> +	return 0;
>  }
>  
>  static int be_map_pci_bars(struct be_adapter *adapter)  {
> +	struct pci_dev *pdev = adapter->pdev;
>  	u8 __iomem *addr;
>  	int db_reg;
>  
>  	if (lancer_chip(adapter)) {
> -		addr = ioremap_nocache(pci_resource_start(adapter->pdev, 0),
> -			pci_resource_len(adapter->pdev, 0));
> -		if (addr == NULL)
> -			return -ENOMEM;
> -		adapter->db = addr;
> +		if (adapter->if_type == SLI_INTF_TYPE_2 ||
> +		    adapter->if_type == SLI_INTF_TYPE_3) {
> +			addr = ioremap_nocache(pci_resource_start(pdev, 0),
> +			    pci_resource_len(adapter->pdev, 0));

pci_iomap

> +			if (addr == NULL)
> +				return -ENOMEM;
> +			adapter->db = addr;
> +		}
> +		if (adapter->if_type == SLI_INTF_TYPE_3) {
> +			if (lancer_roce_map_pci_bars(adapter))
> +				goto pci_map_err;
> +		}
>  		return 0;
>  	}
>  
[...]
> @@ -3353,7 +3400,21 @@ static int be_dev_family_check(struct be_adapter *adapter)
>  						SLI_INTF_IF_TYPE_SHIFT;
>  
>  		if (((sli_intf & SLI_INTF_VALID_MASK) != SLI_INTF_VALID) ||
> -			if_type != 0x02) {
> +			((if_type != SLI_INTF_TYPE_2) &&
> +			 (if_type != SLI_INTF_TYPE_3))) {

You can remove some parenthesis.

It may benefit from a 'bool be_type_2_3' (could be used twice).


[...]
> diff --git a/drivers/net/ethernet/emulex/benet/be_roce.c 
> b/drivers/net/ethernet/emulex/benet/be_roce.c
> new file mode 100644
> index 0000000..7002160
> --- /dev/null
> +++ b/drivers/net/ethernet/emulex/benet/be_roce.c
> @@ -0,0 +1,185 @@
[...]
> +static struct ocrdma_driver *ocrdma_drv; static 
> +LIST_HEAD(be_adapter_list); static 
> +DEFINE_MUTEX(be_adapter_list_lock);
> +
> +static void _be_roce_dev_add(struct be_adapter *adapter) {
> +	struct be_dev_info dev_info;
> +	int i, roce_vect_cnt = 0;

roce_vect_cnt : excess visibility and useless init

> +	struct pci_dev *pdev = adapter->pdev;
> +
> +	if (!ocrdma_drv || !ocrdma_drv->add || adapter->ocrdma_dev)
> +		return;

The registration logic seems a bit convoluted.

Are there real use-cases where the device and the ocrdma_drv could be loaded in different relative ordering ?

[Parav] Above checks whether its already registered or not, whether it has registered proper callback function or not.
I'll add comment for same.

> +	if (pdev->device == OC_DEVICE_ID5) {
> +		/* only msix is supported on these devices */
> +		if (!msix_enabled(adapter))
> +			return;
> +		/* DPP region address and length */
> +		dev_info.dpp_unmapped_addr = pci_resource_start(pdev, 2);
> +		dev_info.dpp_unmapped_len = pci_resource_len(pdev, 2);
> +	} else {
> +		dev_info.dpp_unmapped_addr = 0;
> +		dev_info.dpp_unmapped_len = 0;
> +	}
> +	dev_info.pdev = adapter->pdev;
> +	if (adapter->sli_family == SKYHAWK_SLI_FAMILY)
> +		dev_info.db = adapter->db;
> +	else
> +		dev_info.db = adapter->roce_db;
> +	dev_info.unmapped_db = adapter->roce_db_io_addr;
> +	dev_info.db_page_size = adapter->roce_db_size;
> +	dev_info.db_total_size = adapter->roce_db_total_size;
> +	dev_info.netdev = adapter->netdev;
> +	memcpy(dev_info.mac_addr, adapter->netdev->dev_addr, ETH_ALEN);
> +	dev_info.dev_family = adapter->sli_family;
> +	dev_info.vendor_id = adapter->pdev->vendor;
> +	dev_info.device_id = adapter->pdev->device;

I wonder why you peel struct pci_dev so early.

> +	if (msix_enabled(adapter)) {
> +		/* provide all the vectors, so that EQ creation response
> +		 * can decide which one to use.
> +		 */
> +		roce_vect_cnt = adapter->num_msix_vec;
> +		dev_info.intr_mode = BE_INTERRUPT_MODE_MSIX;
> +		dev_info.msix.num_vectors =
> +		    min(roce_vect_cnt, MAX_ROCE_MSIX_VECTORS);
> +		/* provide start index of the vector,
> +		 * so in case of linear usage,
> +		 * it can use the base as starting point.
> +		 */
> +		dev_info.msix.start_vector = adapter->num_eqs;
> +		for (i = 0; i < dev_info.msix.num_vectors; i++)
> +			dev_info.msix.vector_list[i] =
> +			    adapter->msix_entries[i].vector;

Parenthesis around the for statement ?

[...]
> +void be_roce_dev_close(struct be_adapter *adapter) {
> +	if (be_roce_supported(adapter)) {
> +		mutex_lock(&be_adapter_list_lock);
> +		_be_roce_dev_close(adapter);
> +		mutex_unlock(&be_adapter_list_lock);
> +	}
> +}

There should be no need to check for be_roce_supported() once the probe is done.
[Parav] I think there is a need to check for same. Because NIC driver can be loaded for few device which supported NIC and few which are NIC+ROCE.
If we don't check it will incur the cost of taking and releasing mutex lock, which can be easily avoid with this check.

> +
> +int be_roce_register_driver(struct ocrdma_driver *drv) {
> +	struct be_adapter *dev;
> +	struct net_device *netdev = NULL;

netdev should be in the list_for_each_entry loop.

> +	int status = 0;
> +
> +	mutex_lock(&be_adapter_list_lock);
> +	if (ocrdma_drv) {
> +		mutex_unlock(&be_adapter_list_lock);
> +		return -EINVAL;

Either use goto or the status variable is not needed.

> +	}
> +	ocrdma_drv = drv;
> +	list_for_each_entry(dev, &be_adapter_list, entry) {
> +		_be_roce_dev_add(dev);
> +		netdev = dev->netdev;
> +		if (netif_running(netdev) && netif_oper_up(netdev))
> +			_be_roce_dev_open(dev);
> +	}
> +	mutex_unlock(&be_adapter_list_lock);
> +	return status;
> +}
> +EXPORT_SYMBOL(be_roce_register_driver);
> +
> +int be_roce_unregister_driver(struct ocrdma_driver *drv)

It always return 0 : make it void.

> +{
> +	struct be_adapter *dev;
> +	mutex_lock(&be_adapter_list_lock);

Missing empty line.

[...]
> diff --git a/drivers/net/ethernet/emulex/benet/be_roce.h 
> b/drivers/net/ethernet/emulex/benet/be_roce.h
> new file mode 100644
> index 0000000..0bb3634
> --- /dev/null
> +++ b/drivers/net/ethernet/emulex/benet/be_roce.h
[...]
> +struct pci_dev;
> +struct net_device;

Why not a proper #include ?

> +
> +enum be_interrupt_mode {
> +	BE_INTERRUPT_MODE_MSIX = 0,
> +	BE_INTERRUPT_MODE_INTX = 1,
> +	BE_INTERRUPT_MODE_MSI = 2,

Please <tab>= instead of <space>=

> +};
> +
> +#define MAX_ROCE_MSIX_VECTORS   16
> +struct be_dev_info {
> +	u16 vendor_id;
> +	u16 device_id;

See remark above. I'd rather keep the relevant pci_dev around.

[...]
> +/* ocrdma driver register's the callback functions with nic driver. 
> +*/ struct ocrdma_driver {
> +	unsigned char name[32];
> +	void *(*add) (struct be_dev_info *dev_info);
> +	void (*remove) (void *device_handle);
> +	void (*state_change_handler) (void *roce_handle, u32 new_state);

Please don't abuse void * like that. :o(
[Parav] This interface provided by NIC doesn't have to know about the structure of RoCE driver as its provide the service to upper layer driver.
So void* pointer helps to achieve that. I may be lacking the disadvantage of how void* could badly affect it.
Other little heavy option is to use a shared structure between RoCE and NIC driver. This just increase the roce_device structure by another 8 bytes and stores redundant info.
Something like below,
be_roce.h
struct nic_roce_common_struct { 
	struct netdev *dev;
};
*/ struct ocrdma_driver {
	unsigned char name[32];
	struct nic_roce_common_struct *(*add) (struct be_dev_info *dev_info);
	void (*remove) (struct nic_roce_common_struct *);
	void (*state_change_handler) (struct nic_roce_common_struct *, u32 new_state);

roce_driver_main.h
struct roce_device { 
	struct nic_roce_common_struct common_struct;
	....
	....
};
Any other simpler solution/suggestion?

--
Ueimor
