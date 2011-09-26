From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [net-next 1/8] pci: Add flag indicating device has been assigned
 by KVM [and Xen]
Date: Mon, 26 Sep 2011 12:25:52 -0400
Message-ID: <20110926162552.GA4175@phenom.oracle.com>
References: <43F901BD926A4E43B106BF17856F0755019C518C0E@orsmsx508.amr.corp.intel.com>
 <1316790220.23371.105.camel@zakaz.uk.xensource.com>
 <43F901BD926A4E43B106BF17856F0755019C518C47@orsmsx508.amr.corp.intel.com>
 <1316792710.2182.124.camel@jtkirshe-mobl>
 <20110923164326.GA23363@phenom.oracle.com>
 <43F901BD926A4E43B106BF17856F0755019C518D57@orsmsx508.amr.corp.intel.com>
 <20110923180025.GA6251@phenom.oracle.com>
 <43F901BD926A4E43B106BF17856F0755019C518E23@orsmsx508.amr.corp.intel.com>
 <20110923190537.GA18850@phenom.oracle.com>
 <1316839300.2182.134.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	Ian Campbell <ijc@hellion.org.uk>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:55402 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268Ab1IZQ0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 12:26:25 -0400
Content-Disposition: inline
In-Reply-To: <1316839300.2182.134.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 23, 2011 at 09:41:39PM -0700, Jeff Kirsher wrote:
> On Fri, 2011-09-23 at 12:05 -0700, Konrad Rzeszutek Wilk wrote:
> > > > > Version 2 of this patch with the modified comment was just posted to
> > > > netdev.  Ian Campbell had mentioned that the Xen pciback driver should be
> > > > modified to use this flag but I don't believe any patches for it have been
> > > > created yet.
> > > > 
> > > > http://marc.info/?i=20110729165446.GA6731@dumpdata.com
..
Any plans to support bnx4 and igb with this feature? Any ETA?

Dave,

Please also add this patch to your net-next queue.

>From 53cada5f5f614a856f6ea5a09dc565d6a455d7c2 Mon Sep 17 00:00:00 2001
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Mon, 26 Sep 2011 12:22:01 -0400
Subject: [PATCH] xen/pciback: Add flag indicating device has been assigned by Xen

Device drivers that create and destroy SR-IOV virtual functions via
calls to pci_enable_sriov() and pci_disable_sriov can cause catastrophic
failures if they attempt to destroy VFs while they are assigned to
guest virtual machines.  By adding a flag for use by the Xen PCI back
to indicate that a device is assigned a device driver can check that
flag and avoid destroying VFs while they are assigned and avoid system
failures.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/xen/xen-pciback/xenbus.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/xen/xen-pciback/xenbus.c b/drivers/xen/xen-pciback/xenbus.c
index 978d2c6..18db31f 100644
--- a/drivers/xen/xen-pciback/xenbus.c
+++ b/drivers/xen/xen-pciback/xenbus.c
@@ -249,6 +249,7 @@ static int xen_pcibk_export_device(struct xen_pcibk_device *pdev,
 		goto out;
 
 	dev_dbg(&dev->dev, "registering for %d\n", pdev->xdev->otherend_id);
+	dev->dev_flags |= PCI_DEV_FLAGS_ASSIGNED;
 	if (xen_register_device_domain_owner(dev,
 					     pdev->xdev->otherend_id) != 0) {
 		dev_err(&dev->dev, "device has been assigned to another " \
@@ -288,6 +289,7 @@ static int xen_pcibk_remove_device(struct xen_pcibk_device *pdev,
 	}
 
 	dev_dbg(&dev->dev, "unregistering for %d\n", pdev->xdev->otherend_id);
+	dev->dev_flags &= ~PCI_DEV_FLAGS_ASSIGNED;
 	xen_unregister_device_domain_owner(dev);
 
 	xen_pcibk_release_pci_dev(pdev, dev);
-- 
1.7.4.1
