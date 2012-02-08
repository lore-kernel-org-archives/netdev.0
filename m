From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the kmap_atomic tree with the  tree
Date: Wed, 8 Feb 2012 15:10:57 +1100
Message-ID: <20120208151057.5ad413a05fbbb393b4a00109@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__8_Feb_2012_15_10_57_+1100_D/o8y.tTWtjeLgzd"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:34421 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753700Ab2BHELL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 23:11:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__8_Feb_2012_15_10_57_+1100_D/o8y.tTWtjeLgzd
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Cong,

Today's linux-next merge of the kmap_atomic tree got a conflict in
drivers/net/ethernet/intel/e1000e/netdev.c between commit 0e15df490eef
("e1000e: minor whitespace and indentation cleanup") from the net-next
tree and commit 2b4ba510a572 ("net: remove the second argument of k
[un]map_atomic()") from the kmap_atomic tree.

I fixed it up (see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/intel/e1000e/netdev.c
index 293a760,7a1ea1d..0000000
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@@ -1267,49 -1253,43 +1267,48 @@@ static bool e1000_clean_rx_irq_ps(struc
  		skb_put(skb, length);
 =20
  		{
 -		/*
 -		 * this looks ugly, but it seems compiler issues make it
 -		 * more efficient than reusing j
 -		 */
 -		int l1 =3D le16_to_cpu(rx_desc->wb.upper.length[0]);
 -
 -		/*
 -		 * page alloc/put takes too long and effects small packet
 -		 * throughput, so unsplit small packets and save the alloc/put
 -		 * only valid in softirq (napi) context to call kmap_*
 -		 */
 -		if (l1 && (l1 <=3D copybreak) &&
 -		    ((length + l1) <=3D adapter->rx_ps_bsize0)) {
 -			u8 *vaddr;
 -
 -			ps_page =3D &buffer_info->ps_pages[0];
 +			/*
 +			 * this looks ugly, but it seems compiler issues make
 +			 * it more efficient than reusing j
 +			 */
 +			int l1 =3D le16_to_cpu(rx_desc->wb.upper.length[0]);
 =20
  			/*
 -			 * there is no documentation about how to call
 -			 * kmap_atomic, so we can't hold the mapping
 -			 * very long
 +			 * page alloc/put takes too long and effects small
 +			 * packet throughput, so unsplit small packets and
 +			 * save the alloc/put only valid in softirq (napi)
 +			 * context to call kmap_*
  			 */
 -			dma_sync_single_for_cpu(&pdev->dev, ps_page->dma,
 -						PAGE_SIZE, DMA_FROM_DEVICE);
 -			vaddr =3D kmap_atomic(ps_page->page);
 -			memcpy(skb_tail_pointer(skb), vaddr, l1);
 -			kunmap_atomic(vaddr);
 -			dma_sync_single_for_device(&pdev->dev, ps_page->dma,
 -						   PAGE_SIZE, DMA_FROM_DEVICE);
 -
 -			/* remove the CRC */
 -			if (!(adapter->flags2 & FLAG2_CRC_STRIPPING))
 -				l1 -=3D 4;
 -
 -			skb_put(skb, l1);
 -			goto copydone;
 -		} /* if */
 +			if (l1 && (l1 <=3D copybreak) &&
 +			    ((length + l1) <=3D adapter->rx_ps_bsize0)) {
 +				u8 *vaddr;
 +
 +				ps_page =3D &buffer_info->ps_pages[0];
 +
 +				/*
 +				 * there is no documentation about how to call
 +				 * kmap_atomic, so we can't hold the mapping
 +				 * very long
 +				 */
 +				dma_sync_single_for_cpu(&pdev->dev,
 +							ps_page->dma,
 +							PAGE_SIZE,
 +							DMA_FROM_DEVICE);
- 				vaddr =3D kmap_atomic(ps_page->page,
- 						    KM_SKB_DATA_SOFTIRQ);
++				vaddr =3D kmap_atomic(ps_page->page);
 +				memcpy(skb_tail_pointer(skb), vaddr, l1);
- 				kunmap_atomic(vaddr, KM_SKB_DATA_SOFTIRQ);
++				kunmap_atomic(vaddr);
 +				dma_sync_single_for_device(&pdev->dev,
 +							   ps_page->dma,
 +							   PAGE_SIZE,
 +							   DMA_FROM_DEVICE);
 +
 +				/* remove the CRC */
 +				if (!(adapter->flags2 & FLAG2_CRC_STRIPPING))
 +					l1 -=3D 4;
 +
 +				skb_put(skb, l1);
 +				goto copydone;
 +			} /* if */
  		}
 =20
  		for (j =3D 0; j < PS_PAGE_BUFFERS; j++) {

--Signature=_Wed__8_Feb_2012_15_10_57_+1100_D/o8y.tTWtjeLgzd
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPMfXRAAoJEECxmPOUX5FE7V0P/3+l9mxPaG2NmlFZxvoD0Xoi
Es7KBAPRujQ8krJs0uwauCnuCSvPdjqXFa+1fI6CmRBvRHUq6MUv/964ORLMrpzx
yi+US/RhvirI7Zvx6CaRFr3Z7vG1CmNZfB6vLY0QhnitVxg1utjqw7URPSK54oEk
HPHJc0cJtYxb5roFaQPfpp9zlZ6xx0xkombL4cssQ/9zFEgKg4mXvsVMZBLpE5RY
mwM+3EdFMneNXzFNcCjm3fOVdZMcrsuaDiHjRE5vVtMoo3/gt3FSIpi/IOReF1IL
61dqZVp5mvBHjDDS3w/rcwiF81FMJ1WpmS/LNfF03E9gPr7MYP2kw9UsanYXcF2l
faAES8IdNS/QzDuqzyzrmqcFuHnalJ26tkMcTebpbHeoUS4/0PH1W4dgLFA6CGCr
TZrd2X0KEDe4SYaE1pyxkI3mO/Ea7B+Me9IAYnTzPHhWs9Ub+e0Qt8EcpWUWTo10
IJtFOmh4GyAcL54+q8lXrD0QxioCMw8L9e9FR/RNWpzy+2gMUo8Q9s4xioM5zhUi
TobS2ZxAI5KI93x8ooMLFNwkd974gj0crqm+OTWLU7mLfBa957k6/nqz7jupA5Og
PunPMavwm/nbr5HnlgKIH6A+zl75TS5yE9oDNJc9VYsaXzFxtIlDqKFNhDTLIVH3
kq877kfNl7ywKEOjqIuy
=szrf
-----END PGP SIGNATURE-----

--Signature=_Wed__8_Feb_2012_15_10_57_+1100_D/o8y.tTWtjeLgzd--
