From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: [PATCH] e1000, errata 2{3,
	4} - possible EEH or memory corruption when DMA crosses a 64k
	boundary
Date: Tue, 1 Feb 2005 11:36:31 -0800
Message-ID: <468F3FDA28AA87429AD807992E22D07E041A065B@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: linuxppc64-dev@ozlabs.org,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Content-class: urn:content-classes:message
To: "Olaf Hering" <olh@suse.de>, <netdev@oss.sgi.com>
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

The patch attached to your mail does not seem to be complete. Did the
mail application truncate?

In any case, this fix is required in e1000. It is *not* in the latest
driver that is released but *is* in the driver that is lined up for
release in a couple of weeks.

Thanks,
Ganesh.

>-----Original Message-----
>From: Olaf Hering [mailto:olh@suse.de]
>Sent: Tuesday, February 01, 2005 11:28 AM
>To: Venkatesan, Ganesh; netdev@oss.sgi.com
>Cc: linuxppc64-dev@ozlabs.org
>Subject: [PATCH] e1000, errata 2{3,4} - possible EEH or memory
corruption
>when DMA crosses a 64k boundary
>
>
>We have this patch in SLES9 SP1.
>I asked google about 'fix for errata 23, cant cross 64kB boundary', and
>it shhows such a patch is also part of RH 2.6.9.
>It still applies to current Linus tree.
>Can you check wether this is still required for the current driver?
>
>
>References: SUSE48368 LTC12567
>
>Need to check 64k boundary on DMA address as well.
>
>We also need to have 64k boundary checking on the DMA address
>that comes back from pci_map_single(). This address is what will
>be passed to the adapter on ppc64 for it to DMA into.  It's the
>address that the adapter sees which will trip erratum 23.
>
>The so patched driver passed a quick netperf run and a weekend
>long stress test.
>
>diff -puN drivers/net/e1000-new/e1000_main.c~64k-align-check-dma-suse
>drivers/net/e1000-new/e1000_main.c
>---
linux-2.6.5-7.127/drivers/net/e1000-new/e1000_main.c~64k-align-check-
>dma-suse	Wed Dec  8 16:55:46 2004
>+++ linux-2.6.5-7.127-moilanen/drivers/net/e1000-new/e1000_main.c
Thu Dec
>9 15:46:04 2004
>@@ -2579,6 +2579,29 @@ e1000_alloc_rx_buffers(struct e1000_adap
>
adapter->rx_buffer_len,
> 						  PCI_DMA_FROMDEVICE);
>
>+		if(adapter->hw.mac_type =3D=3D e1000_82545 ||
>+		   adapter->hw.mac_type =3D=3D e1000_82546)   {
>+			/* fix for errata 23, cant cross 64kB boundary
*/
>+			begin =3D (unsigned long)buffer_info->dma;
>+			end   =3D (unsigned long)(adapter->rx_buffer_len)
- 1;
>+
>+			if(!e1000_check_64k_alignment(adapter, begin,
end)) {
>+
>+				DPRINTK(RX_ERR,ERR,"dma align check
failed: "
>+				        "begin: 0x%lx, end: 0x%lx\n",
begin, end);
>+
>+				dev_kfree_skb(skb);
>+				buffer_info->skb =3D NULL;
>+
>+				pci_unmap_single(pdev,
>+						 buffer_info->dma,
>+						 adapter->rx_buffer_len,
>+						 PCI_DMA_FROMDEVICE);
>+
>+				break; /* while !buffer_info->skb */
>+			}
>+		}
>+
> 		rx_desc =3D E1000_RX_DESC(*rx_ring, i);
> 		rx_desc->buffer_addr =3D cpu_to_le64(buffer_info->dma);
>
