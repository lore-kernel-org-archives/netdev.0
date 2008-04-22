From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: atl1 64-bit => 32-bit DMA borkage (reproducible, bisected)
Date: Mon, 21 Apr 2008 21:08:21 -0500
Message-ID: <20080421210821.28053a92@osprey.hogchain.net>
References: <20080414183221.GA5234@martell.zuzino.mipt.ru>
	<20080414195613.GA4772@martell.zuzino.mipt.ru>
	<Pine.LNX.4.64.0804141301580.7803@schroedinger.engr.sgi.com>
	<20080419111719.GA6724@martell.zuzino.mipt.ru>
	<20080419144535.GA4814@martell.zuzino.mipt.ru>
	<20080419215444.2d4623f5@osprey.hogchain.net>
	<20080420111453.GA4902@martell.zuzino.mipt.ru>
	<20080420060607.2b1be48b@osprey.hogchain.net>
	<20080420122631.GA4761@martell.zuzino.mipt.ru>
	<20080420133704.63f5cc10@osprey.hogchain.net>
	<20080420205500.GA4762@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Luca Tettamanti <kronos.it@gmail.com>,
	Chris Snook <csnook@redhat.com>, Jeff Garzik <jeff@garzik.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christoph Lameter <clameter@sgi.com>, torvalds@osdl.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost03.isp.att.net ([204.127.217.103]:55959 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754363AbYDVCIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 22:08:25 -0400
In-Reply-To: <20080420205500.GA4762@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Apr 2008 00:55:00 +0400
Alexey Dobriyan <adobriyan@gmail.com> wrote:

> Aha, ifconfig down is enough. Here is how reproducer looks like now:
> 
> 	./sync-linux-linus && ssh core2 "sudo /sbin/ifconfig eth0
> down"
> 
> where first script is basically scp(1).
> 
> Also, booting with 1G or 2G of RAM (mem=1024m) makes issue go away.
> 
> printk at dev_close() time shows that NETIF_F_HIGHDMA was not somehow
> enabled.
> 

Alexey, can you please try this (very minimally tested) patch?

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 5586fc6..07fe5c0 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -1115,9 +1115,6 @@ static void atl1_free_ring_resources(struct atl1_adapter *adapter)
 	struct atl1_rrd_ring *rrd_ring = &adapter->rrd_ring;
 	struct atl1_ring_header *ring_header = &adapter->ring_header;
 
-	atl1_clean_tx_ring(adapter);
-	atl1_clean_rx_ring(adapter);
-
 	kfree(tpd_ring->buffer_info);
 	pci_free_consistent(pdev, ring_header->size, ring_header->desc,
 		ring_header->dma);
@@ -3423,6 +3420,8 @@ static int atl1_set_ringparam(struct net_device *netdev,
 		adapter->rrd_ring = rrd_old;
 		adapter->tpd_ring = tpd_old;
 		adapter->ring_header = rhdr_old;
+		atl1_clean_tx_ring(adapter);
+		atl1_clean_rx_ring(adapter);
 		atl1_free_ring_resources(adapter);
 		adapter->rfd_ring = rfd_new;
 		adapter->rrd_ring = rrd_new;
