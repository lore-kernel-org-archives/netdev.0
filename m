From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH RFC 00/77] Re-design MSI/MSI-X interrupts enablement
 pattern
Date: Thu, 3 Oct 2013 23:49:45 +0100
Message-ID: <1380840585.3419.50.camel@bwh-desktop.uk.level5networks.com>
References: <cover.1380703262.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"Ralf Baechle" <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>,
	Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Andy King <acking-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>, Jon Mason <jon.mason-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Matt Porter <mporter-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	<linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>,
	<linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>, <linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	<linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <iss_storagedev-VXdhtT5mjnY@public.gmane.org>,
	<linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	<linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
	Solarflare linux maintainers <linux-net-drivers@solarfla
To: Alexander Gordeev <agordeev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1380703262.git.agordeev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-10-02 at 12:48 +0200, Alexander Gordeev wrote:
> This series is against "next" branch in Bjorn's repo:
> git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci.git
> 
> Currently pci_enable_msi_block() and pci_enable_msix() interfaces
> return a error code in case of failure, 0 in case of success and a
> positive value which indicates the number of MSI-X/MSI interrupts
> that could have been allocated. The latter value should be passed
> to a repeated call to the interfaces until a failure or success:
>
> 
> 	for (i = 0; i < FOO_DRIVER_MAXIMUM_NVEC; i++)
> 		adapter->msix_entries[i].entry = i;
> 
> 	while (nvec >= FOO_DRIVER_MINIMUM_NVEC) {
> 		rc = pci_enable_msix(adapter->pdev,
> 				     adapter->msix_entries, nvec);
> 		if (rc > 0)
> 			nvec = rc;
> 		else
> 			return rc;
> 	}
> 
> 	return -ENOSPC;
> 
> 
> This technique proved to be confusing and error-prone. Vast share
> of device drivers simply fail to follow the described guidelines.
> 
> This update converts pci_enable_msix() and pci_enable_msi_block()
> interfaces to canonical kernel functions and makes them return a
> error code in case of failure or 0 in case of success.
[...]

I think this is fundamentally flawed: pci_msix_table_size() and
pci_get_msi_cap() can only report the limits of the *device* (which the
driver usually already knows), whereas MSI allocation can also be
constrained due to *global* limits on the number of distinct IRQs.

Currently pci_enable_msix() will report a positive value if it fails due
to the global limit.  Your patch 7 removes that.  pci_enable_msi_block()
unfortunately doesn't appear to do this.

It seems to me that a more useful interface would take a minimum and
maximum number of vectors from the driver.  This wouldn't allow the
driver to specify that it could only accept, say, any even number within
a certain range, but you could still leave the current functions
available for any driver that needs that.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
