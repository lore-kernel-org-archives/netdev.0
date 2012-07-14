From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC 1/2] PCI-Express Non-Transparent Bridge Support
Date: Fri, 13 Jul 2012 17:00:45 -0700
Message-ID: <20120713170045.493dc213@nehalam.linuxnetplumber.net>
References: <1342215900-3358-1-git-send-email-jon.mason@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>
To: Jon Mason <jon.mason@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38691 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756017Ab2GNABD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2012 20:01:03 -0400
In-Reply-To: <1342215900-3358-1-git-send-email-jon.mason@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Jul 2012 14:44:59 -0700
Jon Mason <jon.mason@intel.com> wrote:

> A PCI-Express non-transparent bridge (NTB) is a point-to-point PCIe bus
> connecting 2 systems, providing electrical isolation between the two subsystems.
> A non-transparent bridge is functionally similar to a transparent bridge except
> that both sides of the bridge have their own independent address domains.  The
> host on one side of the bridge will not have the visibility of the complete
> memory or I/O space on the other side of the bridge.  To communicate across the
> non-transparent bridge, each NTB endpoint has one (or more) apertures exposed to
> the local system.  Writes to these apertures are mirrored to memory on the
> remote system.  Communications can also occur through the use of doorbell
> registers that initiate interrupts to the alternate domain, and scratch-pad
> registers accessible from both sides.
> 
> The NTB device driver is needed to configure these memory windows, doorbell, and
> scratch-pad registers as well as use them in such a way as they can be turned
> into a viable communication channel to the remote system.  ntb_hw.[ch]
> determines the usage model (NTB to NTB or NTB to Root Port) and abstracts away
> the underlying hardware to provide access and a common interface to the doorbell
> registers, scratch pads, and memory windows.  These hardware interfaces are
> exported so that other, non-mainlined kernel drivers can access these.
> ntb_transport.[ch] also uses the exported interfaces in ntb_hw.[ch] to setup a
> communication channel(s) and provide a reliable way of transferring data from
> one side to the other, which it then exports so that "client" drivers can access
> them.  These client drivers are used to provide a standard kernel interface
> (i.e., Ethernet device) to NTB, such that Linux can transfer data from one
> system to the other in a standard way.
> 
> Signed-off-by: Jon Mason <jon.mason@intel.com>

> +
> +static int max_num_cbs = 2;
> +module_param(max_num_cbs, uint, 0644);
> +MODULE_PARM_DESC(max_num_cbs, "Maximum number of NTB transport connections");

Rather than making it a fixed size, could you dynamically set these up
with rtnl_link_ops?

> +static struct ntb_device *ntbdev;

What about multiple boards in system?

> +/**
> + * ntb_hw_link_status() - return the hardware link status
> + * @ndev: pointer to ntb_device instance
> + *
> + * Returns true if the hardware is connected to the remote system
> + *
> + * RETURNS: true or false based on the hardware link state
> + */
> +bool ntb_hw_link_status(struct ntb_device *ndev)
> +{
> +	return ndev->link_status == NTB_LINK_UP;
> +}
> +EXPORT_SYMBOL(ntb_hw_link_status);

Why isn't this inline in some header?

> +/**
> + * ntb_query_pdev() - return the pci_dev pointer
> + * @ndev: pointer to ntb_device instance
> + *
> + * Given the ntb pointer return the pci_dev pointerfor the NTB hardware device
> + *
> + * RETURNS: a pointer to the ntb pci_dev
> + */
> +struct pci_dev *ntb_query_pdev(struct ntb_device *ndev)
> +{
> +	return ndev->pdev;
> +}
> +EXPORT_SYMBOL(ntb_query_pdev);
> +
> +/**
> + * ntb_query_max_cbs() - return the maximum number of callback tuples
> + * @ndev: pointer to ntb_device instance
> + *
> + * The number of callbacks can vary depending on the platform and MSI-X/MSI
> + * enablement
> + *
> + * RETURNS: the maximum number of callback tuples (3, 15, or 33)
> + */
> +unsigned int ntb_query_max_cbs(struct ntb_device *ndev)
> +{
> +	return ndev->max_cbs > max_num_cbs ? max_num_cbs : ndev->max_cbs;
> +}
> +EXPORT_SYMBOL(ntb_query_max_cbs);
> +
> +/**
> + * ntb_register_event_callback() - register event callback
> + * @ndev: pointer to ntb_device instance
> + * @func: callback function to register
> + *
> + * This function registers a callback for any HW driver events such as link
> + * up/down, power management notices and etc.
> + *
> + * RETURNS: An appropriate -ERRNO error value on error, or zero for success.
> + */
> +int ntb_register_event_callback(struct ntb_device *ndev,
> +				void (*func)(void *handle, unsigned int event))
> +{
> +	if (ndev->event_cb)
> +		return -EINVAL;
> +
> +	ndev->event_cb = func;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(ntb_register_event_callback);
> +
> +/**
> + * ntb_unregister_event_callback() - unregisters the event callback
> + * @ndev: pointer to ntb_device instance
> + *
> + * This function unregisters the existing callback from transport
> + */
> +void ntb_unregister_event_callback(struct ntb_device *ndev)
> +{
> +	ndev->event_cb = NULL;
> +}
> +EXPORT_SYMBOL(ntb_unregister_event_callback);
> +
