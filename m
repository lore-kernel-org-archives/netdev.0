From: "Bhanu Prakash Gollapudi" <bprakash@broadcom.com>
Subject: Re: [RFC PATCH 2/5] libfcoe: Create new libfcoe control
 interfaces
Date: Fri, 14 Sep 2012 00:06:05 -0700
Message-ID: <5052D75D.5060908@broadcom.com>
References: <20120910225908.13140.97277.stgit@fritz>
 <20120910225919.13140.63240.stgit@fritz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	linux-scsi@vger.kernel.org, devel@open-fcoe.org
To: "Robert Love" <robert.w.love@intel.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20120910225919.13140.63240.stgit@fritz>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/10/2012 3:59 PM, Robert Love wrote:
> This patch is the first in a series that will remove
> libfcoe's create, destroy, enable and disable module
> parameters and replace them with interface files in
> the new /sys/bus/fcoe subsystem.
>
> Old layout:
>
> /sys/module/libfcoe/parameters/{create,destroy,enable,disable,vn2vn_create}
>
> New layout:
>
> /sys/bus/fcoe/ctlr_{create,destroy}
> /sys/bus/fcoe/ctlr_X/{enable,disable,start}
>
> This patch moves fcoe drivers to the following
> initialization sequence-
>
> 1) create/alloc
> 2) configure
> 3) start
>
> A control sysfs interface at /sys/bus/fcoe/ctlr_create
> is added. Writing the interface name to this file
> will allocate memory and create a sysfs entry for a
> new fcoe_ctlr_device. The user may then tune the interface in
> any desired way. After configuration the user will
> echo any value into the /sys/bus/fcoe/devices/ctlr_X/start
> interface to proceed with logging in.
>
> VN2VN logins will still use the module parameters.
> A follow up patch to this one will make the 'mode'
> attribute of the fcoe_ctlr_device writable. Which will
> allow a user to change the ctlr's mode to 'VN2VN'.
>
> Signed-off-by: Robert Love <robert.w.love@intel.com>
> ---
>   Documentation/ABI/testing/sysfs-bus-fcoe |   43 ++++++++++++
>   drivers/scsi/fcoe/fcoe.h                 |    9 +++
>   drivers/scsi/fcoe/fcoe_ctlr.c            |    2 -
>   drivers/scsi/fcoe/fcoe_sysfs.c           |   78 ++++++++++++++++++++++
>   drivers/scsi/fcoe/fcoe_transport.c       |  105 +++++++++++++++++++++++++++++-
>   include/scsi/fcoe_sysfs.h                |    4 +
>   include/scsi/libfcoe.h                   |   14 ++++
>   7 files changed, 250 insertions(+), 5 deletions(-)
>

<snip>

> diff --git a/drivers/scsi/fcoe/fcoe_ctlr.c b/drivers/scsi/fcoe/fcoe_ctlr.c
> index bd899bf..ccb92323 100644
> --- a/drivers/scsi/fcoe/fcoe_ctlr.c
> +++ b/drivers/scsi/fcoe/fcoe_ctlr.c
> @@ -147,7 +147,7 @@ static void fcoe_ctlr_map_dest(struct fcoe_ctlr *fip)
>    */
>   void fcoe_ctlr_init(struct fcoe_ctlr *fip, enum fip_state mode)
>   {
> -	fcoe_ctlr_set_state(fip, FIP_ST_LINK_WAIT);
> +	fcoe_ctlr_set_state(fip, FIP_ST_DISABLED);

Robert, what is the reason for initializing it to DISABLED? Unless the 
FIP state is FIP_ST_LINK_WAIT, fcoe_ctlr_link_up() doesnt set 
lport->link_up and hence does not allow any FIP/FCoE frames to be sent out.

>   	fip->mode = mode;
>   	INIT_LIST_HEAD(&fip->fcfs);
>   	mutex_init(&fip->ctlr_mutex);

<snip>

> @@ -627,6 +626,108 @@ static int libfcoe_device_notification(struct notifier_block *notifier,
>   	return NOTIFY_OK;
>   }
>
> +ssize_t fcoe_ctlr_create_store(struct bus_type *bus,
> +			       const char *buf, size_t count)
> +{
> +	struct net_device *netdev = NULL;
> +	struct fcoe_transport *ft = NULL;
> +	struct fcoe_ctlr_device *ctlr_dev = NULL;
> +	int rc = -ENODEV;
> +	int err;
> +
> +	mutex_lock(&ft_mutex);
> +
> +	netdev = fcoe_if_to_netdev(buf);
> +	if (!netdev) {
> +		LIBFCOE_TRANSPORT_DBG("Invalid device %s.\n", buf);
> +		rc = -ENODEV;
> +		goto out_nodev;
> +	}
> +
> +	ft = fcoe_netdev_map_lookup(netdev);
> +	if (ft) {
> +		LIBFCOE_TRANSPORT_DBG("transport %s already has existing "
> +				      "FCoE instance on %s.\n",
> +				      ft->name, netdev->name);
> +		rc = -EEXIST;
> +		goto out_putdev;
> +	}
> +
> +	ft = fcoe_transport_lookup(netdev);
> +	if (!ft) {
> +		LIBFCOE_TRANSPORT_DBG("no FCoE transport found for %s.\n",
> +				      netdev->name);
> +		rc = -ENODEV;
> +		goto out_putdev;
> +	}
> +
> +	/* pass to transport create */
> +	err = ft->alloc ? ft->alloc(netdev) : -ENODEV;
> +	if (err) {
> +		fcoe_del_netdev_mapping(netdev);
> +		rc = -ENOMEM;
> +		goto out_putdev;
> +	}
> +
> +	err = fcoe_add_netdev_mapping(netdev, ft);
> +	if (err) {
> +		LIBFCOE_TRANSPORT_DBG("failed to add new netdev mapping "
> +				      "for FCoE transport %s for %s.\n",
> +				      ft->name, netdev->name);
> +		rc = -ENODEV;
> +		goto out_putdev;
> +	}
> +
> +	LIBFCOE_TRANSPORT_DBG("transport %s %s to create fcoe on %s.\n",
> +			      ft->name, (ctlr_dev) ? "succeeded" : "failed",
> +			      netdev->name);

Where is ctlr_dev updated? I guess you're intending to check return 
status of ft->alloc() here.

> +
> +out_putdev:
> +	dev_put(netdev);
> +out_nodev:
> +	mutex_unlock(&ft_mutex);
> +	return rc;
> +}
> +
> +ssize_t fcoe_ctlr_destroy_store(struct bus_type *bus,
> +				const char *buf, size_t count)
> +{
> +	int rc = -ENODEV;
> +	struct net_device *netdev = NULL;
> +	struct fcoe_transport *ft = NULL;
> +
> +	mutex_lock(&ft_mutex);
> +
> +	netdev = fcoe_if_to_netdev(buf);
> +	if (!netdev) {
> +		LIBFCOE_TRANSPORT_DBG("invalid device %s.\n", buf);
> +		goto out_nodev;
> +	}
> +
> +	ft = fcoe_netdev_map_lookup(netdev);
> +	if (!ft) {
> +		LIBFCOE_TRANSPORT_DBG("no FCoE transport found for %s.\n",
> +				      netdev->name);
> +		goto out_putdev;
> +	}
> +
> +	/* pass to transport destroy */
> +	rc = ft->destroy(netdev);
> +	if (rc)
> +		goto out_putdev;
> +
> +	fcoe_del_netdev_mapping(netdev);
> +	LIBFCOE_TRANSPORT_DBG("transport %s %s to destroy fcoe on %s.\n",
> +			      ft->name, (rc) ? "failed" : "succeeded",
> +			      netdev->name);
> +	rc = count; /* required for successful return */
> +out_putdev:
> +	dev_put(netdev);
> +out_nodev:
> +	mutex_unlock(&ft_mutex);
> +	return rc;
> +}
> +EXPORT_SYMBOL(fcoe_ctlr_destroy_store);
>
>   /**
>    * fcoe_transport_create() - Create a fcoe interface
> diff --git a/include/scsi/fcoe_sysfs.h b/include/scsi/fcoe_sysfs.h
> index 421ae67..8c5ea70 100644
> --- a/include/scsi/fcoe_sysfs.h
> +++ b/include/scsi/fcoe_sysfs.h
> @@ -36,6 +36,9 @@ struct fcoe_sysfs_function_template {
>   	void (*get_fcoe_ctlr_fcs_error)(struct fcoe_ctlr_device *);
>   	void (*get_fcoe_ctlr_mode)(struct fcoe_ctlr_device *);
>   	void (*set_fcoe_ctlr_mode)(struct fcoe_ctlr_device *);
> +	int  (*set_fcoe_ctlr_start)(struct fcoe_ctlr_device *);
> +	int  (*set_fcoe_ctlr_enable)(struct fcoe_ctlr_device *);
> +	int  (*set_fcoe_ctlr_disable)(struct fcoe_ctlr_device *);
>   	void (*get_fcoe_fcf_selected)(struct fcoe_fcf_device *);
>   	void (*get_fcoe_fcf_vlan_id)(struct fcoe_fcf_device *);
>   };
> @@ -64,6 +67,7 @@ struct fcoe_ctlr_device {
>
>   	int                             fcf_dev_loss_tmo;
>   	enum fip_conn_type              mode;
> +	u8                              started:1;
>
>   	/* expected in host order for displaying */
>   	struct fcoe_fc_els_lesb         lesb;
> diff --git a/include/scsi/libfcoe.h b/include/scsi/libfcoe.h
> index 20533cc..b19a489 100644
> --- a/include/scsi/libfcoe.h
> +++ b/include/scsi/libfcoe.h
> @@ -289,8 +289,11 @@ static inline bool is_fip_mode(struct fcoe_ctlr *fip)
>    * @attached:	whether this transport is already attached
>    * @list:	list linkage to all attached transports
>    * @match:	handler to allow the transport driver to match up a given netdev
> + * @alloc:      handler to allocate per-instance FCoE structures
> + *		(no discovery or login)
>    * @create:	handler to sysfs entry of create for FCoE instances
> - * @destroy:	handler to sysfs entry of destroy for FCoE instances
> + * @destroy:    handler to delete per-instance FCoE structures
> + *		(frees all memory)
>    * @enable:	handler to sysfs entry of enable for FCoE instances
>    * @disable:	handler to sysfs entry of disable for FCoE instances
>    */
> @@ -299,6 +302,7 @@ struct fcoe_transport {
>   	bool attached;
>   	struct list_head list;
>   	bool (*match) (struct net_device *device);
> +	int (*alloc) (struct net_device *device);
>   	int (*create) (struct net_device *device, enum fip_state fip_mode);
>   	int (*destroy) (struct net_device *device);
>   	int (*enable) (struct net_device *device);
> @@ -375,4 +379,12 @@ struct fcoe_netdev_mapping {
>   int fcoe_transport_attach(struct fcoe_transport *ft);
>   int fcoe_transport_detach(struct fcoe_transport *ft);
>
> +/* sysfs store handler for ctrl_control interface */
> +ssize_t fcoe_ctlr_create_store(struct bus_type *bus,
> +			       const char *buf, size_t count);
> +ssize_t fcoe_ctlr_destroy_store(struct bus_type *bus,
> +				const char *buf, size_t count);
> +
>   #endif /* _LIBFCOE_H */
> +
> +
>
>


