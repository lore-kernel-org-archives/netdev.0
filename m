From: Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [RFC 02/11] Add RoCE driver framework
Date: Mon, 12 Sep 2016 21:44:00 +0300
Message-ID: <516b98c7-477a-4890-0d92-529dc32f2c4e@mellanox.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-3-git-send-email-Ram.Amrani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>, <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>, <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1473696465-27986-3-git-send-email-Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Hi Ram,

Just a few thoughts 

On 12/09/2016 19:07, Ram Amrani wrote:
> Adds a skeletal implementation of the qed* RoCE driver -
> basically the ability to communicate with the qede driver and
> receive notifications from it regarding various init/exit events.
> 
> Signed-off-by: Rajesh Borundia <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/infiniband/Kconfig                   |   2 +
>  drivers/infiniband/hw/Makefile               |   1 +
>  drivers/infiniband/hw/qedr/Kconfig           |   7 +
>  drivers/infiniband/hw/qedr/Makefile          |   3 +
>  drivers/infiniband/hw/qedr/main.c            | 293 +++++++++++++++++++++++++
>  drivers/infiniband/hw/qedr/qedr.h            |  60 ++++++
>  drivers/net/ethernet/qlogic/qede/Makefile    |   1 +
>  drivers/net/ethernet/qlogic/qede/qede.h      |   9 +
>  drivers/net/ethernet/qlogic/qede/qede_main.c |  35 ++-
>  drivers/net/ethernet/qlogic/qede/qede_roce.c | 309 +++++++++++++++++++++++++++
>  include/linux/qed/qed_if.h                   |   3 +-
>  include/linux/qed/qede_roce.h                |  88 ++++++++
>  include/uapi/linux/pci_regs.h                |   3 +
>  13 files changed, 803 insertions(+), 11 deletions(-)
>  create mode 100644 drivers/infiniband/hw/qedr/Kconfig
>  create mode 100644 drivers/infiniband/hw/qedr/Makefile
>  create mode 100644 drivers/infiniband/hw/qedr/main.c
>  create mode 100644 drivers/infiniband/hw/qedr/qedr.h
>  create mode 100644 drivers/net/ethernet/qlogic/qede/qede_roce.c
>  create mode 100644 include/linux/qed/qede_roce.h

[SNIP]

> +
> +MODULE_DESCRIPTION("QLogic 40G/100G ROCE Driver");
> +MODULE_AUTHOR("QLogic Corporation");
> +MODULE_LICENSE("Dual BSD/GPL");
> +MODULE_VERSION(QEDR_MODULE_VERSION);
> +
> +uint debug;
> +module_param(debug, uint, 0);
> +MODULE_PARM_DESC(debug, "Default debug msglevel");

Why are you adding this as a module parameter? 


> +static LIST_HEAD(qedr_dev_list);
> +static DEFINE_SPINLOCK(qedr_devlist_lock);
> +

You already have a qedr_dev_list mutex in the qede_roce.c file,
why do you need this spinlock as well?

> +void qedr_ib_dispatch_event(struct qedr_dev *dev, u8 port_num,
> +			    enum ib_event_type type)
> +{
> +	struct ib_event ibev;
> +
> +	ibev.device = &dev->ibdev;
> +	ibev.element.port_num = port_num;
> +	ibev.event = type;
> +
> +	ib_dispatch_event(&ibev);
> +}
> +
> +static enum rdma_link_layer qedr_link_layer(struct ib_device *device,
> +					    u8 port_num)
> +{
> +	return IB_LINK_LAYER_ETHERNET;
> +}
> +
> +static int qedr_register_device(struct qedr_dev *dev)
> +{
> +	strlcpy(dev->ibdev.name, "qedr%d", IB_DEVICE_NAME_MAX);
> +
> +	memcpy(dev->ibdev.node_desc, QEDR_NODE_DESC, sizeof(QEDR_NODE_DESC));
> +	dev->ibdev.owner = THIS_MODULE;
> +
> +	dev->ibdev.get_link_layer = qedr_link_layer;
> +
> +	return 0;
> +}
> +
> +/* QEDR sysfs interface */
> +static ssize_t show_rev(struct device *device, struct device_attribute *attr,
> +			char *buf)
> +{
> +	struct qedr_dev *dev = dev_get_drvdata(device);
> +
> +	return scnprintf(buf, PAGE_SIZE, "0x%x\n", dev->pdev->vendor);
> +}
> +
> +static ssize_t show_fw_ver(struct device *device, struct device_attribute *attr,
> +			   char *buf)
> +{
> +	return scnprintf(buf, PAGE_SIZE, "%s\n", "FW_VER_TO_ADD");
> +}

Ira Weiny has added a generic way to expose firmware versions in the rdma stack,
can you have please have a look at c73428230d98d1352bcc69cd8306c292a85e1e42 and
see how he converted the mlx5_ib module to use it.

> +static ssize_t show_hca_type(struct device *device,
> +			     struct device_attribute *attr, char *buf)
> +{
> +	return scnprintf(buf, PAGE_SIZE, "%s\n", "HCA_TYPE_TO_SET");
> +}
> +
> +static DEVICE_ATTR(hw_rev, S_IRUGO, show_rev, NULL);
> +static DEVICE_ATTR(fw_ver, S_IRUGO, show_fw_ver, NULL);
> +static DEVICE_ATTR(hca_type, S_IRUGO, show_hca_type, NULL);
> +
> +static struct device_attribute *qedr_attributes[] = {
> +	&dev_attr_hw_rev,
> +	&dev_attr_fw_ver,
> +	&dev_attr_hca_type
> +};
> +
> +static void qedr_remove_sysfiles(struct qedr_dev *dev)
> +{
> +	int i;
> +
> +	for (i = 0; i < ARRAY_SIZE(qedr_attributes); i++)
> +		device_remove_file(&dev->ibdev.dev, qedr_attributes[i]);
> +}
> +
> +void qedr_config_debug(uint debug, u32 *p_dp_module, u8 *p_dp_level)
> +{
> +	*p_dp_level = 0;
> +	*p_dp_module = 0;
> +
> +	if (debug & QED_LOG_VERBOSE_MASK) {
> +		*p_dp_level = QED_LEVEL_VERBOSE;
> +		*p_dp_module = (debug & 0x3FFFFFFF);
> +	} else if (debug & QED_LOG_INFO_MASK) {
> +		*p_dp_level = QED_LEVEL_INFO;
> +	} else if (debug & QED_LOG_NOTICE_MASK) {
> +		*p_dp_level = QED_LEVEL_NOTICE;
> +	}
> +}
> +
> +static void qedr_pci_set_atomic(struct qedr_dev *dev, struct pci_dev *pdev)
> +{
> +	struct pci_dev *bridge;
> +	u32 val;
> +
> +	dev->atomic_cap = IB_ATOMIC_NONE;
> +
> +	bridge = pdev->bus->self;
> +	if (!bridge)
> +		return;
> +
> +	/* Check whether we are connected directly or via a switch */
> +	while (bridge && bridge->bus->parent) {
> +		DP_NOTICE(dev,
> +			  "Device is not connected directly to root. bridge->bus->number=%d primary=%d\n",
> +			  bridge->bus->number, bridge->bus->primary);
> +		/* Need to check Atomic Op Routing Supported all the way to
> +		 * root complex.
> +		 */
> +		pcie_capability_read_dword(bridge, PCI_EXP_DEVCAP2, &val);
> +		if (!(val & PCI_EXP_DEVCAP2_ATOMIC_ROUTE)) {
> +			pcie_capability_clear_word(pdev,
> +						   PCI_EXP_DEVCTL2,
> +						   PCI_EXP_DEVCTL2_ATOMIC_REQ);
> +			return;
> +		}
> +		bridge = bridge->bus->parent->self;
> +	}
> +	bridge = pdev->bus->self;
> +
> +	/* according to bridge capability */
> +	pcie_capability_read_dword(bridge, PCI_EXP_DEVCAP2, &val);
> +	if (val & PCI_EXP_DEVCAP2_ATOMIC_COMP64) {
> +		pcie_capability_set_word(pdev, PCI_EXP_DEVCTL2,
> +					 PCI_EXP_DEVCTL2_ATOMIC_REQ);
> +		dev->atomic_cap = IB_ATOMIC_GLOB;
> +	} else {
> +		pcie_capability_clear_word(pdev, PCI_EXP_DEVCTL2,
> +					   PCI_EXP_DEVCTL2_ATOMIC_REQ);
> +	}
> +}
> +
> +static struct qedr_dev *qedr_add(struct qed_dev *cdev, struct pci_dev *pdev,
> +				 struct net_device *ndev)
> +{
> +	struct qedr_dev *dev;
> +	int rc = 0, i;
> +
> +	dev = (struct qedr_dev *)ib_alloc_device(sizeof(*dev));
> +	if (!dev) {
> +		pr_err("Unable to allocate ib device\n");
> +		return NULL;
> +	}
> +
> +	qedr_config_debug(debug, &dev->dp_module, &dev->dp_level);
> +	DP_VERBOSE(dev, QEDR_MSG_INIT, "qedr add device called\n");
> +
> +	dev->pdev = pdev;
> +	dev->ndev = ndev;
> +	dev->cdev = cdev;
> +
> +	qedr_pci_set_atomic(dev, pdev);
> +
> +	rc = qedr_register_device(dev);
> +	if (rc) {
> +		DP_ERR(dev, "Unable to allocate register device\n");
> +		goto init_err;
> +	}
> +
> +	for (i = 0; i < ARRAY_SIZE(qedr_attributes); i++)
> +		if (device_create_file(&dev->ibdev.dev, qedr_attributes[i]))
> +			goto init_err;
> +
> +	spin_lock(&qedr_devlist_lock);
> +	list_add_tail_rcu(&dev->entry, &qedr_dev_list);
> +	spin_unlock(&qedr_devlist_lock);
> +
> +	DP_VERBOSE(dev, QEDR_MSG_INIT, "qedr driver loaded successfully\n");
> +	return dev;
> +
> +init_err:
> +	ib_dealloc_device(&dev->ibdev);
> +	DP_ERR(dev, "qedr driver load failed rc=%d\n", rc);
> +
> +	return NULL;
> +}
> +
> +static void qedr_remove(struct qedr_dev *dev)
> +{
> +	/* First unregister with stack to stop all the active traffic
> +	 * of the registered clients.
> +	 */
> +	qedr_remove_sysfiles(dev);
> +
> +	spin_lock(&qedr_devlist_lock);
> +	list_del_rcu(&dev->entry);
> +	spin_unlock(&qedr_devlist_lock);
> +
> +	ib_dealloc_device(&dev->ibdev);
> +}
> +
> +static int qedr_close(struct qedr_dev *dev)
> +{
> +	qedr_ib_dispatch_event(dev, 1, IB_EVENT_PORT_ERR);
> +

Why are you sending port number hard-coded as 1?

Mark
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
