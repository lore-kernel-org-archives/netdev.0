From: Olaf Hering <olh@suse.de>
Subject: [PATCH] e1000, errata 2{3,
	4} - possible EEH or memory corruption when DMA crosses a 64k
	boundary
Date: Tue, 1 Feb 2005 20:27:35 +0100
Message-ID: <20050201192735.GB7433@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linuxppc64-dev@ozlabs.org
To: Ganesh Venkatesan <ganesh.venkatesan@intel.com>,
	netdev@oss.sgi.com
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/cgi-bin/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/cgi-bin/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org


We have this patch in SLES9 SP1.
I asked google about 'fix for errata 23, cant cross 64kB boundary', and
it shhows such a patch is also part of RH 2.6.9.
It still applies to current Linus tree.
Can you check wether this is still required for the current driver?


References: SUSE48368 LTC12567

Need to check 64k boundary on DMA address as well.

We also need to have 64k boundary checking on the DMA address
that comes back from pci_map_single(). This address is what will
be passed to the adapter on ppc64 for it to DMA into.  It's the
address that the adapter sees which will trip erratum 23. 

The so patched driver passed a quick netperf run and a weekend
long stress test.

diff -puN drivers/net/e1000-new/e1000_main.c~64k-align-check-dma-suse drivers/net/e1000-new/e1000_main.c
--- linux-2.6.5-7.127/drivers/net/e1000-new/e1000_main.c~64k-align-check-dma-suse	Wed Dec  8 16:55:46 2004
+++ linux-2.6.5-7.127-moilanen/drivers/net/e1000-new/e1000_main.c	Thu Dec  9 15:46:04 2004
@@ -2579,6 +2579,29 @@ e1000_alloc_rx_buffers(struct e1000_adap
 						  adapter->rx_buffer_len,
 						  PCI_DMA_FROMDEVICE);
 
+		if(adapter->hw.mac_type == e1000_82545 ||
+		   adapter->hw.mac_type == e1000_82546)   {
+			/* fix for errata 23, cant cross 64kB boundary */
+			begin = (unsigned long)buffer_info->dma;
+			end   = (unsigned long)(adapter->rx_buffer_len) - 1;
+
+			if(!e1000_check_64k_alignment(adapter, begin, end)) {
+
+				DPRINTK(RX_ERR,ERR,"dma align check failed: "
+				        "begin: 0x%lx, end: 0x%lx\n", begin, end);
+
+				dev_kfree_skb(skb);
+				buffer_info->skb = NULL;
+				
+				pci_unmap_single(pdev,
+						 buffer_info->dma,
+						 adapter->rx_buffer_len,
+						 PCI_DMA_FROMDEVICE);
+
+				break; /* while !buffer_info->skb */
+			}
+		}
+
 		rx_desc = E1000_RX_DESC(*rx_ring, i);
 		rx_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
