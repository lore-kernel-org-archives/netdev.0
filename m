From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ RFC ] igb: first draft of igb rtnl_link_ops interface for vf creation
 (was Re: [net-next PATCH v3] igbvf: add new driver to support 82576 virtual
 functions)
Date: Thu, 26 Mar 2009 17:30:01 -0700
Message-ID: <49CC1E09.4010405@intel.com>
References: <49CAD25F.4080705@intel.com>	<20090325.201219.98810772.davem@davemloft.net>	<5f2db9d90903252027n7079ca54v76c06ec3849c65d9@mail.gmail.com> <20090325.203450.58187435.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:41532 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933099AbZC0AaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 20:30:04 -0400
In-Reply-To: <20090325.203450.58187435.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Wed, 25 Mar 2009 20:27:28 -0700
> 
>> On Wed, Mar 25, 2009 at 8:12 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>> Date: Wed, 25 Mar 2009 17:54:55 -0700
>>>
>>>> Since the issue isn't the igbvf driver there is no reason for it to
>>>> be held up.
>>> I disagree, I think both cases should be fixed.
>>>
>>> Just because we do something already never means that it's
>>> ok to proliferate the mistake further.
>> That isn't what I mean.  The code he is referring to exists nowhere in
>> the igbvf driver.  I suppose I can edit the igbvf commit comments so
>> that they don't mention the sysfs entry, but the code is in the igb
>> driver.
> 
> I know it's in the igb driver, I fully understand that.
> 
> And I'm saying it was a mistake to merge that, it slipped past
> me in my review of that change, and we need to move forward
> and get rid of this thing.

Ok, I have already submitted the patches to remove the sysfs entry, and the 
comments about it from the commit in igbvf to Jeff.  Hopefully we can get 
the pushed through sometime soon.

In the meantime I have been working on the rtnl_link_ops approach and I 
think I have a few things going but I wanted to get some input before I go 
much further.

First, is it ok for me to call rtnl_unlock prior to doing my settings 
changes on the sriov config space, followed by rtnl_lock afterwards in my 
newlink and dellink operations?  I ask because I had to do this in order to 
prevent a deadlock when the pci-hotplug events fired for the vfs and called 
unregister/register_netdev.

Second is it acceptable for me to just free the netdev at the end of 
newlink and call delete on the PF interface directly?  I ask because I 
don't have any use for the netdevs that are generated and I cannot call 
delete on specific VFs anyway since they are allocated/freed in LIFO order 
so I would always have to free the last one I allocated.

I have included a patch for review below that implements these changes 
against the current driver.  Please feel free to comment.

Thanks,

Alex

--

This patch converts igb from using a sysfs interface to allocate vfs to 
using the rtnl_link interface.

Basically the new interface work like this to add a VF:
ip link add eth3 type igbpf

To delete a VF it would be:
ip link del eth3 type igbpf

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

---

 drivers/net/igb/igb_main.c |  120 +++++++++++++++++++++++++++++---------------
 1 files changed, 80 insertions(+), 40 deletions(-)


diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 7d3ac76..d1e9425 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -154,11 +154,17 @@ static void igb_netpoll(struct net_device *);
 #endif
 
 #ifdef CONFIG_PCI_IOV
-static ssize_t igb_set_num_vfs(struct device *, struct device_attribute *,
-                               const char *, size_t);
-static ssize_t igb_show_num_vfs(struct device *, struct device_attribute *,
-                               char *);
-DEVICE_ATTR(num_vfs, S_IRUGO | S_IWUSR, igb_show_num_vfs, igb_set_num_vfs);
+static int igb_new_vf(struct net_device *dev, struct nlattr *tb[],
+                      struct nlattr *data[]);
+static void igb_del_vf(struct net_device *dev);
+static void igb_setup_vf(struct net_device *dev);
+
+static struct rtnl_link_ops igbpf_link_ops __read_mostly = {
+	.kind		= "igbpf",
+	.setup		= igb_setup_vf,
+	.newlink 	= igb_new_vf,
+	.dellink	= igb_del_vf,
+};
 #endif
 static pci_ers_result_t igb_io_error_detected(struct pci_dev *,
 		     pci_channel_state_t);
@@ -304,11 +310,18 @@ static int __init igb_init_module(void)
 
 	global_quad_port_a = 0;
 
+#ifdef CONFIG_PCI_IOV
+	/* since iov functionality isn't critical to base device function we
+	 * can accept failure.  If it fails we can't enable sr-iov */
+	rtnl_link_register(&igbpf_link_ops);
+
+#endif
 #ifdef CONFIG_IGB_DCA
 	dca_register_notify(&dca_notifier);
 #endif
 
 	ret = pci_register_driver(&igb_driver);
+
 	return ret;
 }
 
@@ -326,6 +339,9 @@ static void __exit igb_exit_module(void)
 	dca_unregister_notify(&dca_notifier);
 #endif
 	pci_unregister_driver(&igb_driver);
+#ifdef CONFIG_PCI_IOV
+	rtnl_link_unregister(&igbpf_link_ops);
+#endif
 }
 
 module_exit(igb_exit_module);
@@ -1235,6 +1251,11 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_sw_init;
 
+#ifdef CONFIG_PCI_IOV
+	if ((hw->mac.type == e1000_82576) && !pci_enable_sriov(pdev, 0))
+		netdev->rtnl_link_ops = &igbpf_link_ops;
+
+#endif
 	/* setup the private structure */
 	err = igb_sw_init(adapter);
 	if (err)
@@ -1394,19 +1415,6 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
-#ifdef CONFIG_PCI_IOV
-	/* since iov functionality isn't critical to base device function we
-	 * can accept failure.  If it fails we don't allow iov to be enabled */
-	if (hw->mac.type == e1000_82576) {
-		err = pci_enable_sriov(pdev, 0);
-		if (!err)
-			err = device_create_file(&netdev->dev,
-			                         &dev_attr_num_vfs);
-		if (err)
-			dev_err(&pdev->dev, "Failed to initialize IOV\n");
-	}
-
-#endif
 #ifdef CONFIG_IGB_DCA
 	if (dca_add_requester(&pdev->dev) == 0) {
 		adapter->flags |= IGB_FLAG_DCA_ENABLED;
@@ -1554,6 +1562,8 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 	 * would have already happened in close and is redundant. */
 	igb_release_hw_control(adapter);
 
+	netdev->rtnl_link_ops = NULL;
+
 	unregister_netdev(netdev);
 
 	if (!igb_check_reset_block(&adapter->hw))
@@ -5402,37 +5412,28 @@ static void igb_vmm_control(struct igb_adapter *adapter)
 }
 
 #ifdef CONFIG_PCI_IOV
-static ssize_t igb_show_num_vfs(struct device *dev,
-                                struct device_attribute *attr, char *buf)
+static int igb_set_num_vfs(struct net_device *dev, unsigned int num_vfs)
 {
-	struct igb_adapter *adapter = netdev_priv(to_net_dev(dev));
-
-	return sprintf(buf, "%d\n", adapter->vfs_allocated_count);
-}
-
-static ssize_t igb_set_num_vfs(struct device *dev,
-                               struct device_attribute *attr,
-                               const char *buf, size_t count)
-{
-	struct net_device *netdev = to_net_dev(dev);
-	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct igb_adapter *adapter = netdev_priv(dev);
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
-	unsigned int num_vfs, i;
+	unsigned int i;
 	unsigned char mac_addr[ETH_ALEN];
-	int err;
+	int err = 0;
 
-	sscanf(buf, "%u", &num_vfs);
+
+	if (hw->mac.type != e1000_82576)
+		return -EINVAL;
 
 	if (num_vfs > 7)
 		num_vfs = 7;
 
 	/* value unchanged do nothing */
 	if (num_vfs == adapter->vfs_allocated_count)
-		return count;
+		return -EINVAL;
 
-	if (netdev->flags & IFF_UP)
-		igb_close(netdev);
+	if (dev->flags & IFF_UP)
+		igb_close(dev);
 
 	igb_reset_interrupt_capability(adapter);
 	igb_free_queues(adapter);
@@ -5440,6 +5441,7 @@ static ssize_t igb_set_num_vfs(struct device *dev,
 	adapter->rx_ring = NULL;
 	adapter->vfs_allocated_count = 0;
 
+	rtnl_unlock();
 	/* reclaim resources allocated to VFs since we are changing count */
 	if (adapter->vf_data) {
 		/* disable iov and allow time for transactions to clear */
@@ -5451,6 +5453,7 @@ static ssize_t igb_set_num_vfs(struct device *dev,
 		wr32(E1000_IOVCTL, E1000_IOVCTL_REUSE_VFQ);
 		msleep(100);
 		dev_info(&pdev->dev, "IOV Disabled\n");
+		err = 0;
 	}
 
 	if (num_vfs) {
@@ -5458,10 +5461,12 @@ static ssize_t igb_set_num_vfs(struct device *dev,
 		                           sizeof(struct vf_data_storage),
 		                           GFP_KERNEL);
 		if (!adapter->vf_data) {
+			err = -ENOMEM;
 			dev_err(&pdev->dev, "Could not allocate VF private "
 				"data - IOV enable failed\n");
 		} else {
 			err = pci_enable_sriov(pdev, num_vfs);
+			msleep(100);
 			if (!err) {
 				adapter->vfs_allocated_count = num_vfs;
 				dev_info(&pdev->dev, "%d vfs allocated\n", num_vfs);
@@ -5475,15 +5480,50 @@ static ssize_t igb_set_num_vfs(struct device *dev,
 			}
 		}
 	}
+	rtnl_lock();
 
 	igb_set_interrupt_capability(adapter);
 	igb_alloc_queues(adapter);
 	igb_reset(adapter);
 
-	if (netdev->flags & IFF_UP)
-		igb_open(netdev);
+	if (dev->flags & IFF_UP)
+		igb_open(dev);
 
-	return count;
+	return err;
+}
+
+static int igb_new_vf(struct net_device *dev, struct nlattr *tb[],
+                      struct nlattr *data[])
+{
+	struct net_device *netdev;
+	struct igb_adapter *adapter;
+	int err;
+
+	netdev = __dev_get_by_index(dev_net(dev), nla_get_u32(tb[IFLA_LINK]));
+
+	if (!netdev)
+		return -ENODEV;
+	
+	adapter = netdev_priv(netdev);
+	err = igb_set_num_vfs(netdev, adapter->vfs_allocated_count + 1);
+	if (!err)
+		free_netdev(dev);
+
+	return err;
+
+}
+
+static void igb_del_vf(struct net_device *dev)
+{
+	struct igb_adapter *adapter = netdev_priv(dev);
+
+	if (adapter->vfs_allocated_count > 0)
+		igb_set_num_vfs(dev, adapter->vfs_allocated_count - 1);
+}
+
+static void igb_setup_vf(struct net_device *dev)
+{
+	/* do nothing for now */
 }
 #endif /* CONFIG_PCI_IOV */
 /* igb_main.c */


