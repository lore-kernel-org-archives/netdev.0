From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC net-next PATCH 1/4] pci: Add flag indicating device has
 been assigned by KVM
Date: Fri, 29 Jul 2011 12:54:46 -0400
Message-ID: <20110729165446.GA6731@dumpdata.com>
References: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
 <20110727221749.8435.19000.stgit@gitlad.jf.intel.com>
 <1311865877.24408.144.camel@cthulhu.hellion.org.uk>
 <43F901BD926A4E43B106BF17856F0755019414D525@orsmsx508.amr.corp.intel.com>
 <1311870459.24408.151.camel@cthulhu.hellion.org.uk>
 <43F901BD926A4E43B106BF17856F0755019414D59C@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Campbell <ijc@hellion.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <43F901BD926A4E43B106BF17856F0755019414D59C@orsmsx508.amr.corp.intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > > On Wed, 2011-07-27 at 15:17 -0700, Greg Rose wrote:
> > > > > Device drivers that create and destroy SR-IOV virtual functions via
> > > > > calls to pci_enable_sriov() and pci_disable_sriov can cause
> > catastrophic
> > > > > failures if they attempt to destroy VFs while they are assigned to
> > > > > guest virtual machines.  By adding a flag for use by the KVM module
> > > > > to indicate that a device is assigned a device driver can check that
> > > > > flag and avoid destroying VFs while they are assigned and avoid
> > system
> > > > > failures.
> OK, but I hope Xen can still use the dev_flag assignment bit.

Yeah, I think the attached patch would do it, but I need to double check it.
Do you have a git tree with this patchset?

Um, so you are fixing up ixgbe only - what about the cxgb4 and be driver?
Shouldn't they also get some of this treatment?



diff --git a/drivers/xen/xen-pciback/xenbus.c b/drivers/xen/xen-pciback/xenbus.c
index 206c4ce0..0d72e84 100644
--- a/drivers/xen/xen-pciback/xenbus.c
+++ b/drivers/xen/xen-pciback/xenbus.c
@@ -250,6 +250,7 @@ static int xen_pcibk_export_device(struct xen_pcibk_device *pdev,
 		goto out;
 
 	dev_dbg(&dev->dev, "registering for %d\n", pdev->xdev->otherend_id);
+	dev->dev_flags |= PCI_DEV_FLAGS_ASSIGNED;
 	if (xen_register_device_domain_owner(dev,
 					     pdev->xdev->otherend_id) != 0) {
 		dev_err(&dev->dev, "device has been assigned to another " \
@@ -289,6 +290,7 @@ static int xen_pcibk_remove_device(struct xen_pcibk_device *pdev,
 	}
 
 	dev_dbg(&dev->dev, "unregistering for %d\n", pdev->xdev->otherend_id);
+	dev->dev_flags &= ~PCI_DEV_FLAGS_ASSIGNED;
 	xen_unregister_device_domain_owner(dev);
 
 	xen_pcibk_release_pci_dev(pdev, dev);
