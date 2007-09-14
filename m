From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [ofa-general] Re: [PATCH v2] iw_cxgb3: Support "iwarp-only"
	interfaces to avoid 4-tuple conflicts.
Date: Fri, 14 Sep 2007 17:09:41 +0400
Message-ID: <20070914130941.GG18517@2ka.mipt.ru>
References: <20070913191617.30937.95960.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org,
	linux-kernel@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20070913191617.30937.95960.stgit@dell3.ogc.int>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 13, 2007 at 02:16:17PM -0500, Steve Wise (swise@opengridcomputing.com) wrote:
> 
> iw_cxgb3: Support "iwarp-only" interfaces to avoid 4-tuple conflicts.
> 
> Version 2:
> 
> - added a per-device mutex for the address and listening endpoints lists.
> 
> - wait for all replies if sending multiple passive_open requests to rnic.
> 
> - log warning if no addresses are available when a listen is issued.
> 
> - tested
> 
> ---
> 
> Design:
> 
> The sysadmin creates "for iwarp use only" alias interfaces of the form
> "devname:iw*" where devname is the native interface name (eg eth0) for the
> iwarp netdev device.  The alias label can be anything starting with "iw".
> The "iw" immediately after the ':' is the key used by the iw_cxgb3 driver.
> 
> EG:
> 	ifconfig eth0 192.168.70.123 up
> 	ifconfig eth0:iw1 192.168.71.123 up
> 	ifconfig eth0:iw2 192.168.72.123 up
> 
> In the above example, 192.168.70/24 is for TCP traffic, while
> 192.168.71/24 and 192.168.72/24 are for iWARP/RDMA use.
> 
> The rdma-only interface must be on its own IP subnet. This allows routing
> all rdma traffic onto this interface.
> 
> The iWARP driver must translate all listens on address 0.0.0.0 to the
> set of rdma-only ip addresses for the device in question.  This prevents
> incoming connect requests to the TCP ipaddresses from going up the
> rdma stack.

If the only solutions to solve a problem with hardware are to steal
packets or became a real device, then real device is much more
appropriate. Is that correct?

> +static void insert_ifa(struct iwch_dev *rnicp, struct in_ifaddr *ifa)
> +{
> +	struct iwch_addrlist *addr;
> +
> +	addr = kmalloc(sizeof *addr, GFP_KERNEL);

As a small nitpick: this wants to be sizeof(struct in_ifaddr)

> +	if (!addr) {
> +		printk(KERN_ERR MOD "%s - failed to alloc memory!\n",
> +		       __FUNCTION__);
> +		return;
> +	}
> +	addr->ifa = ifa;
> +	mutex_lock(&rnicp->mutex);
> +	list_add_tail(&addr->entry, &rnicp->addrlist);
> +	mutex_unlock(&rnicp->mutex);
> +}

What about providing error back to caller and fail to register?

> +static void remove_ifa(struct iwch_dev *rnicp, struct in_ifaddr *ifa)
> +{
> +	struct iwch_addrlist *addr, *tmp;
> +
> +	mutex_lock(&rnicp->mutex);
> +	list_for_each_entry_safe(addr, tmp, &rnicp->addrlist, entry) {
> +		if (addr->ifa == ifa) {
> +			list_del_init(&addr->entry);
> +			kfree(addr);
> +			goto out;
> +		}
> +	}
> +out:
> +	mutex_unlock(&rnicp->mutex);
> +}
> +
> +static int netdev_is_ours(struct iwch_dev *rnicp, struct net_device *netdev)
> +{
> +	int i;
> +
> +	for (i = 0; i < rnicp->rdev.port_info.nports; i++)
> +		if (netdev == rnicp->rdev.port_info.lldevs[i])
> +			return 1;
> +	return 0;
> +}
> +
> +static inline int is_iwarp_label(char *label)
> +{
> +	char *colon;
> +
> +	colon = strchr(label, ':');
> +	if (colon && !strncmp(colon+1, "iw", 2))
> +		return 1;
> +	return 0;
> +}

I.e. it is not allowed to create ':iw' alias for anyone else?
Well, looks crappy, but if it is the only solution...

> +static int nb_callback(struct notifier_block *self, unsigned long event,
> +		       void *ctx)
> +{
> +	struct in_ifaddr *ifa = ctx;
> +	struct iwch_dev *rnicp = container_of(self, struct iwch_dev, nb);
> +
> +	PDBG("%s rnicp %p event %lx\n", __FUNCTION__, rnicp, event);
> +
> +	switch (event) {
> +	case NETDEV_UP:
> +		if (netdev_is_ours(rnicp, ifa->ifa_dev->dev) &&
> +		    is_iwarp_label(ifa->ifa_label)) {
> +			PDBG("%s label %s addr 0x%x added\n",
> +				__FUNCTION__, ifa->ifa_label, ifa->ifa_address);
> +			insert_ifa(rnicp, ifa);
> +			iwch_listeners_add_addr(rnicp, ifa->ifa_address);
> +		}
> +		break;
> +	case NETDEV_DOWN:
> +		if (netdev_is_ours(rnicp, ifa->ifa_dev->dev) &&
> +		    is_iwarp_label(ifa->ifa_label)) {
> +			PDBG("%s label %s addr 0x%x deleted\n",
> +				__FUNCTION__, ifa->ifa_label, ifa->ifa_address);
> +			iwch_listeners_del_addr(rnicp, ifa->ifa_address);
> +			remove_ifa(rnicp, ifa);
> +		}
> +		break;
> +	default:
> +		break;
> +	}
> +	return 0;
> +}
> +
> +static void delete_addrlist(struct iwch_dev *rnicp)
> +{
> +	struct iwch_addrlist *addr, *tmp;
> +
> +	mutex_lock(&rnicp->mutex);
> +	list_for_each_entry_safe(addr, tmp, &rnicp->addrlist, entry) {
> +		list_del_init(&addr->entry);
> +		kfree(addr);
> +	}
> +	mutex_unlock(&rnicp->mutex);
> +}
> +
> +static void populate_addrlist(struct iwch_dev *rnicp)
> +{
> +	int i;
> +	struct in_device *indev;
> +
> +	for (i = 0; i < rnicp->rdev.port_info.nports; i++) {
> +		indev = in_dev_get(rnicp->rdev.port_info.lldevs[i]);
> +		if (!indev)
> +			continue;
> +		for_ifa(indev)
> +			if (is_iwarp_label(ifa->ifa_label)) {
> +				PDBG("%s label %s addr 0x%x added\n",
> +				     __FUNCTION__, ifa->ifa_label,
> +				     ifa->ifa_address);
> +				insert_ifa(rnicp, ifa);
> +			}
> +		endfor_ifa(indev);
> +	}
> +}
> +
>  static void rnic_init(struct iwch_dev *rnicp)
>  {
>  	PDBG("%s iwch_dev %p\n", __FUNCTION__,  rnicp);
> @@ -70,6 +187,12 @@ static void rnic_init(struct iwch_dev *r
>  	idr_init(&rnicp->qpidr);
>  	idr_init(&rnicp->mmidr);
>  	spin_lock_init(&rnicp->lock);
> +	INIT_LIST_HEAD(&rnicp->addrlist);
> +	INIT_LIST_HEAD(&rnicp->listen_eps);
> +	mutex_init(&rnicp->mutex);
> +	rnicp->nb.notifier_call = nb_callback;
> +	populate_addrlist(rnicp);
> +	register_inetaddr_notifier(&rnicp->nb);
>  
>  	rnicp->attr.vendor_id = 0x168;
>  	rnicp->attr.vendor_part_id = 7;
> @@ -148,6 +271,8 @@ static void close_rnic_dev(struct t3cdev
>  	mutex_lock(&dev_mutex);
>  	list_for_each_entry_safe(dev, tmp, &dev_list, entry) {
>  		if (dev->rdev.t3cdev_p == tdev) {
> +			unregister_inetaddr_notifier(&dev->nb);
> +			delete_addrlist(dev);
>  			list_del(&dev->entry);
>  			iwch_unregister_device(dev);
>  			cxio_rdev_close(&dev->rdev);
> diff --git a/drivers/infiniband/hw/cxgb3/iwch.h b/drivers/infiniband/hw/cxgb3/iwch.h
> index caf4e60..7fa0a47 100644
> --- a/drivers/infiniband/hw/cxgb3/iwch.h
> +++ b/drivers/infiniband/hw/cxgb3/iwch.h
> @@ -36,6 +36,8 @@ #include <linux/mutex.h>
>  #include <linux/list.h>
>  #include <linux/spinlock.h>
>  #include <linux/idr.h>
> +#include <linux/notifier.h>
> +#include <linux/inetdevice.h>
>  
>  #include <rdma/ib_verbs.h>
>  
> @@ -101,6 +103,11 @@ struct iwch_rnic_attributes {
>  	u32 cq_overflow_detection;
>  };
>  
> +struct iwch_addrlist {
> +	struct list_head entry;
> +	struct in_ifaddr *ifa;
> +};
> +
>  struct iwch_dev {
>  	struct ib_device ibdev;
>  	struct cxio_rdev rdev;
> @@ -111,6 +118,10 @@ struct iwch_dev {
>  	struct idr mmidr;
>  	spinlock_t lock;
>  	struct list_head entry;
> +	struct notifier_block nb;
> +	struct list_head addrlist;
> +	struct list_head listen_eps;
> +	struct mutex mutex;
>  };
>  
>  static inline struct iwch_dev *to_iwch_dev(struct ib_device *ibdev)
> diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
> index 1cdfcd4..954069f 100644
> --- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
> +++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
> @@ -1127,23 +1127,149 @@ static int act_open_rpl(struct t3cdev *t
>  	return CPL_RET_BUF_DONE;
>  }
>  
> -static int listen_start(struct iwch_listen_ep *ep)
> +static int wait_for_reply(struct iwch_ep_common *epc)
> +{
> +	PDBG("%s ep %p waiting\n", __FUNCTION__, epc);
> +	wait_event(epc->waitq, epc->rpl_done);
> +	PDBG("%s ep %p done waiting err %d\n", __FUNCTION__, epc, epc->rpl_err);
> +	return epc->rpl_err;
> +}
> +
> +static struct iwch_listen_entry *alloc_listener(struct iwch_listen_ep *ep,
> +						  __be32 addr)

Do you know, that cxgb3 function names suck? :)
Especially get_skb().

> +{
> +	struct iwch_dev *h = to_iwch_dev(ep->com.cm_id->device);
> +	struct iwch_listen_entry *le;
> +
> +	le = kmalloc(sizeof *le, GFP_KERNEL);

Wants to be sizeof(struct iwch_listen_entry) and in other places too.

I skipped rdma internals of the patch, since I do not know it enough 
to judge, but your approach looks good from core network point of view.
Maybe you should automatically create an alias each time new interface
is added so that admin would not care about proper aliases?

-- 
	Evgeniy Polyakov
