From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc 2/3 v2] [E1000-devel] [rfc 3/4] igb: Common error path in
 igb_init_vfs()
Date: Thu, 26 Nov 2009 10:27:39 +1100
Message-ID: <20091125232739.GN4794@verge.net.au>
References: <20091125063213.203372240@vergenet.net>
 <20091125063531.218106764@vergenet.net>
 <4B0DB12C.3030709@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Arnd Bergmann <arndbergmann@googlemail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53296 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758997AbZKYX1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 18:27:34 -0500
Content-Disposition: inline
In-Reply-To: <4B0DB12C.3030709@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 25, 2009 at 02:35:24PM -0800, Alexander Duyck wrote:
> Simon Horman wrote:
> >Drop out into an error path on error.
> >
> >This is a bit superfluous as things stand, though arguably
> >it already makes the code cleaner. But it should help things a lot
> >if igb_init_vfs() has a several things to unwind on error.
> >
> >This patch eliminates resetting adapter->vfs_allocated_count to 0
> >in the case where CONFIG_PCI_IOV is not set, because in that
> >case adapter->vfs_allocated_count can never be non-zero.
> >
> >Signed-off-by: Simon Horman <horms@verge.net.au>
> >
> >--- Thu, 05 Nov 2009 11:58:50 +1100
> >* Initial post
> >
> >Wed, 25 Nov 2009 16:44:15 +1100
> >* Merged with " Initialise adapter->vfs_allocated_count in igb_init_vf()",
> >  however the initialisation of adapter->vfs_allocated_count is no
> >  longer moved into igb_init_vf() as doing so results in a panic.
> >
> >Index: net-next-2.6/drivers/net/igb/igb_main.c
> >===================================================================
> >--- net-next-2.6.orig/drivers/net/igb/igb_main.c	2009-11-25 17:05:43.000000000 +1100
> >+++ net-next-2.6/drivers/net/igb/igb_main.c	2009-11-25 17:05:44.000000000 +1100
> >@@ -1753,38 +1753,37 @@ static void __devinit igb_init_vf(struct
> > {
> > #ifdef CONFIG_PCI_IOV
> > 	struct pci_dev *pdev = adapter->pdev;
> >+	unsigned char mac_addr[ETH_ALEN];
> >+	int i;
> > 	if (adapter->vfs_allocated_count > 7)
> > 		adapter->vfs_allocated_count = 7;
> >-	if (adapter->vfs_allocated_count) {
> >-		adapter->vf_data = kcalloc(adapter->vfs_allocated_count,
> >-		                           sizeof(struct vf_data_storage),
> >-		                           GFP_KERNEL);
> >-		/* if allocation failed then we do not support SR-IOV */
> >-		if (!adapter->vf_data) {
> >-			adapter->vfs_allocated_count = 0;
> >-			dev_err(&pdev->dev, "Unable to allocate memory for VF "
> >-			        "Data Storage\n");
> >-		}
> >+	adapter->vf_data = kcalloc(adapter->vfs_allocated_count,
> >+				   sizeof(struct vf_data_storage), GFP_KERNEL);
> >+	/* if allocation failed then we do not support SR-IOV */
> >+	if (!adapter->vf_data) {
> >+		dev_err(&pdev->dev, "Unable to allocate memory for VF "
> >+		        "Data Storage\n");
> >+		goto err_zero;
> > 	}
> The only issue I see with the changes above is that if SR-IOV is not
> enabled via the max_vfs option you will end up returning an error
> even though there is nothing wrong.  You might want to go and keep
> the if statement near the start and do something like:
> 	if (!adapter->vfs_allocated_count)
> 		goto err_zero;
> 
> This way you can avoid the false error report.

Good idea, I will add that.

> >-	if (pci_enable_sriov(pdev, adapter->vfs_allocated_count)) {
> >-		kfree(adapter->vf_data);
> >-		adapter->vf_data = NULL;
> >-#endif /* CONFIG_PCI_IOV */
> >-		adapter->vfs_allocated_count = 0;
> >-#ifdef CONFIG_PCI_IOV
> >-	} else {
> >-		unsigned char mac_addr[ETH_ALEN];
> >-		int i;
> >-		dev_info(&pdev->dev, "%d vfs allocated\n",
> >-		         adapter->vfs_allocated_count);
> >-		for (i = 0; i < adapter->vfs_allocated_count; i++) {
> >-			random_ether_addr(mac_addr);
> >-			igb_set_vf_mac(adapter, i, mac_addr);
> >-		}
> >+	if (pci_enable_sriov(pdev, adapter->vfs_allocated_count))
> >+		goto err_free;
> >+
> >+	dev_info(&pdev->dev, "%d vfs allocated\n",
> >+		 adapter->vfs_allocated_count);
> >+	for (i = 0; i < adapter->vfs_allocated_count; i++) {
> >+		random_ether_addr(mac_addr);
> >+		igb_set_vf_mac(adapter, i, mac_addr);
> > 	}
> >+
> >+	return;
> >+err_free:
> >+	kfree(adapter->vf_data);
> >+err_zero:
> >+	adapter->vf_data = NULL;
> >+	adapter->vfs_allocated_count = 0;
> > #endif /* CONFIG_PCI_IOV */
> > }
> >
> 
> My preference here would be to bump the #endif up two lines so that
> adapter->vf_data = NULL and adapter->vfs_allocated_count = 0 are ran
> in the non-iov case.  That way we know that SR-IOV is explicitly
> disabled.

I'm not sure that its necessary but it certainly does seem to be
a clean and safe way to handle things. I'll update the patch.

