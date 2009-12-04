From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v4] net: Introduce realloc_netdev_mq()
Date: Fri, 4 Dec 2009 13:49:51 +0000
Message-ID: <20091204134951.GA9711@ff.dom.local>
References: <4B17EFE3.4080301@gmail.com> <20091203202937.GA11436@ami.dom.local> <4B182DC6.5030800@gmail.com> <20091203.133108.254093305.davem@davemloft.net> <4B1832DD.1070805@gmail.com> <20091203224742.GA16646@ami.dom.local> <4B18440A.2080507@gmail.com> <20091204130134.GA9336@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	kaber@trash.net, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:61356 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbZLDNtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 08:49:51 -0500
Received: by bwz27 with SMTP id 27so1953134bwz.21
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2009 05:49:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091204130134.GA9336@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 04, 2009 at 01:01:34PM +0000, Jarek Poplawski wrote:
> On Fri, Dec 04, 2009 at 12:04:42AM +0100, Eric Dumazet wrote:
> ...
> > bnx2 for example could not be patched easily, following patch doesnt work.
> > 
> > diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> > index 4cae2a8..8bd5d0d 100644
> > --- a/drivers/net/bnx2.c
> > +++ b/drivers/net/bnx2.c
> > @@ -6177,6 +6177,7 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
> >  
> >  	bp->num_tx_rings = rounddown_pow_of_two(bp->irq_nvecs);
> > -	bp->dev->real_num_tx_queues = bp->num_tx_rings;
> > +	realloc_netdev_mq(bp->dev, bp->num_tx_rings);
> >  
> >  	bp->num_rx_rings = bp->irq_nvecs;
> >  }
> 
> Eric, if didn't miss something in the example you gave at the
> beginning of this thread, it seems a change like below (not compiled)
> should fix your problem (without even testing MSI exactly)?

OOPS! Take 2...;-)
 
Jarek P.
---

 drivers/net/bnx2.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 4bfc808..c1ba2b1 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -8288,6 +8288,11 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev->features |= NETIF_F_TSO6;
 		vlan_features_add(dev, NETIF_F_TSO6);
 	}
+
+	if (!((bp->flags & BNX2_FLAG_MSIX_CAP) ||
+	     (bp->flags & BNX2_FLAG_MSI_CAP)) || disable_msi)
+		realloc_netdev_mq(dev, 1);
+
 	if ((rc = register_netdev(dev))) {
 		dev_err(&pdev->dev, "Cannot register net device\n");
 		goto error;
