From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] try parent numa_node at first before using default
Date: Thu, 12 Jul 2007 11:31:41 -0700
Message-ID: <20070712183141.GB22471@kroah.com>
References: <200707101641.17672.yinghai.lu@sun.com> <469610D4.70009@s5r6.in-berlin.de> <20070712172310.4d662e1f@gondolin.boeblingen.de.ibm.com> <200707121059.54320.yinghai.lu@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andi Kleen <ak@suse.de>, rientjes@google.com,
	Christoph Lameter <clameter@sgi.com>,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Yinghai Lu <Yinghai.Lu@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:35869 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753923AbXGLSh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 14:37:59 -0400
Content-Disposition: inline
In-Reply-To: <200707121059.54320.yinghai.lu@sun.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 12, 2007 at 10:59:53AM -0700, Yinghai Lu wrote:
> [PATCH] try parent numa_node at first before using default
> 
> For pci_device, pcibios_scan_root and pci_scan_root will call pci_device_add.
> pci_device_add will call device_initialize and set_dev_node(&dev->dev,
> pcibus_to_node(bus)).
> other device such as netdev, and usb_device, set_dev_node is never be
> used. So that field numa_node always is -1.
> 
> So for netdev, it will need to use dev->parent to get pci_device to
> use it's numa_node. esp in netdev_alloc_skb()
> not sure how other device such as infiniband do that.
> 
> Actually before patch
> [PATCH 1/2] x86_64: get mp_bus_to_node as early
> there is a bug about squence of bus->sysdata and using pcibus_to_node.
> the numa_node of pci_dev->dev is never set correctly...always 0.
> 
> So some device have to use pcibus_to_node(to_pci_dev(dev)->bus) directly
> such as dma_alloc_pages in arch/x86_64/kernel/pci-dma.c.
> or hwif_to_node in include/linux/ide.h
> 
> According to Stefan Richter
>   - Change all subsystems to set dev->parent before device_initialize().
>     *Document* that the device_initialize() API has this requirement.
>     This is counter-intuitive, amounts to some work across the kernel,
>     and could be gotten wrong again in future code because it's a
>     counter-intuitive API.
> 
>   - Move your code from device_initialize() to device_add().  One minor
>     drawback is that node-specific allocations based on the device's
>     numa_node would not be optimized before device_add(), but there is
>     probably no need for this.  Driver probes come after device_add().
> 
>   - Let subsystems explicitly call set_dev_node() on their own.
> 
> this patch is using second method.
> 
> Also we don't need call set_dev_node in pci_device_add anymore. but need to
> make sure every pci root bus's bridge device numa is set.
> 
> with this patch, we could use device->numa_node direclty for all device.

Please split this into two separate patches, as they are doing two
different things.  One for the driver core, and one for pci devices.

Also, what kind of performance issues have you seen with this patch in
place?  As your previous patches were incorrect, I am guessing that you
are not able to test this?

thanks,

greg k-h
