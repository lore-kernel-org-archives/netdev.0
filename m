From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 14/21] NTB: Fix Sparse Warnings
Date: Sun, 20 Jan 2013 15:45:34 -0800
Message-ID: <20130120234534.GD14196@kroah.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
 <1358586155-23322-15-git-send-email-jon.mason@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1358586155-23322-15-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 19, 2013 at 02:02:28AM -0700, Jon Mason wrote:
> Address the sparse warnings and resulting fallout
> 
> Signed-off-by: Jon Mason <jon.mason@intel.com>
> ---
>  drivers/ntb/ntb_hw.c        |    7 ++++---
>  drivers/ntb/ntb_hw.h        |    4 ++--
>  drivers/ntb/ntb_transport.c |   32 ++++++++++++++++----------------
>  3 files changed, 22 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/ntb/ntb_hw.c b/drivers/ntb/ntb_hw.c
> index 18cb5dc..b792ccd 100644
> --- a/drivers/ntb/ntb_hw.c
> +++ b/drivers/ntb/ntb_hw.c
> @@ -104,8 +104,9 @@ MODULE_DEVICE_TABLE(pci, ntb_pci_tbl);
>   *
>   * RETURNS: An appropriate -ERRNO error value on error, or zero for success.
>   */
> -int ntb_register_event_callback(struct ntb_device *ndev,
> -				void (*func)(void *handle, unsigned int event))
> +int
> +ntb_register_event_callback(struct ntb_device *ndev,
> +			    void (*func)(void *handle, enum ntb_hw_event event))

What is sparse complaining about here that moving the function name to
the start of the line fixes?  That shouldn't be necessary at all.  Ah,
the enum?  If so, why change the first line at all?

>  {
>  	if (ndev->event_cb)
>  		return -EINVAL;
> @@ -344,7 +345,7 @@ int ntb_read_remote_spad(struct ntb_device *ndev, unsigned int idx, u32 *val)
>   *
>   * RETURNS: pointer to virtual address, or NULL on error.
>   */
> -void *ntb_get_mw_vbase(struct ntb_device *ndev, unsigned int mw)
> +void __iomem *ntb_get_mw_vbase(struct ntb_device *ndev, unsigned int mw)

That makes sense to fix.

>  {
>  	if (mw > NTB_NUM_MW)
>  		return NULL;
> diff --git a/drivers/ntb/ntb_hw.h b/drivers/ntb/ntb_hw.h
> index 5e00951..3a3038c 100644
> --- a/drivers/ntb/ntb_hw.h
> +++ b/drivers/ntb/ntb_hw.h
> @@ -165,14 +165,14 @@ int ntb_register_db_callback(struct ntb_device *ndev, unsigned int idx,
>  void ntb_unregister_db_callback(struct ntb_device *ndev, unsigned int idx);
>  int ntb_register_event_callback(struct ntb_device *ndev,
>  				void (*event_cb_func) (void *handle,
> -						       unsigned int event));
> +						      enum ntb_hw_event event));
>  void ntb_unregister_event_callback(struct ntb_device *ndev);
>  int ntb_get_max_spads(struct ntb_device *ndev);
>  int ntb_write_local_spad(struct ntb_device *ndev, unsigned int idx, u32 val);
>  int ntb_read_local_spad(struct ntb_device *ndev, unsigned int idx, u32 *val);
>  int ntb_write_remote_spad(struct ntb_device *ndev, unsigned int idx, u32 val);
>  int ntb_read_remote_spad(struct ntb_device *ndev, unsigned int idx, u32 *val);
> -void *ntb_get_mw_vbase(struct ntb_device *ndev, unsigned int mw);
> +void __iomem *ntb_get_mw_vbase(struct ntb_device *ndev, unsigned int mw);
>  resource_size_t ntb_get_mw_size(struct ntb_device *ndev, unsigned int mw);
>  void ntb_ring_sdb(struct ntb_device *ndev, unsigned int idx);
>  void *ntb_find_transport(struct pci_dev *pdev);
> diff --git a/drivers/ntb/ntb_transport.c b/drivers/ntb/ntb_transport.c
> index b3afb24..e0bdfd7 100644
> --- a/drivers/ntb/ntb_transport.c
> +++ b/drivers/ntb/ntb_transport.c
> @@ -58,7 +58,7 @@
>  #include <linux/ntb.h>
>  #include "ntb_hw.h"
>  
> -#define NTB_TRANSPORT_VERSION	1
> +#define NTB_TRANSPORT_VERSION	2

How is this a sparse fix?

>  static unsigned int transport_mtu = 0x401E;
>  module_param(transport_mtu, uint, 0644);
> @@ -91,14 +91,14 @@ struct ntb_transport_qp {
>  	bool qp_link;
>  	u8 qp_num;	/* Only 64 QP's are allowed.  0-63 */
>  
> -	struct ntb_rx_info *rx_info;
> +	struct ntb_rx_info __iomem *rx_info;
>  	struct ntb_rx_info *remote_rx_info;
>  
>  	void (*tx_handler) (struct ntb_transport_qp *qp, void *qp_data,
>  			    void *data, int len);
>  	struct list_head tx_free_q;
>  	spinlock_t ntb_tx_free_q_lock;
> -	void *tx_mw;
> +	void __iomem *tx_mw;
>  	unsigned int tx_index;
>  	unsigned int tx_max_entry;
>  	unsigned int tx_max_frame;
> @@ -166,7 +166,7 @@ enum {
>  };
>  
>  struct ntb_payload_header {
> -	u64 ver;
> +	unsigned int ver;

why does sparse care about this?

thanks,

greg k-h
