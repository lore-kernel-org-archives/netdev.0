From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Strange network timeouts w/ 2.6.30.5
Date: Thu, 20 Aug 2009 15:45:21 +0200
Message-ID: <m3skfmk39q.fsf@intrepid.localdomain>
References: <985009134.71250769263099.JavaMail.root@mail.holmansrus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Walt Holman <walt@holmansrus.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754648AbZHTNpc@vger.kernel.org>
In-Reply-To: <985009134.71250769263099.JavaMail.root@mail.holmansrus.com> (Walt Holman's message of "Thu\, 20 Aug 2009 06\:54\:23 -0500 \(CDT\)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Walt Holman <walt@holmansrus.com> writes:

> dmesg is attached. This box does have >2GB Ram (6GB total).  The dmes=
g
> will show e100 init'd 3 times since the first is the stock modprobe,
> 2nd was forced with use_io and the 3rd modprobe was after reverting
> the patch.

You most probably can't test without swiotlb (RAM has to be limited to
2 GB or so), can you? That would (dis)prove my theory. Alternatively (o=
r
better), a test on IOMMU-equipped system would do.

Since swiotlb is x86-only thing (though other 64-bit archs may have
something similar), I think the correct work around is to enable the
"for_device" handoff on !X86.

Something like maybe:

Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 014dfb6..b610088 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1762,9 +1762,12 @@ static int e100_rx_indicate(struct nic *nic, str=
uct rx *rx,
=20
 			if (ioread8(&nic->csr->scb.status) & rus_no_res)
 				nic->ru_running =3D RU_SUSPENDED;
+#ifndef CONFIG_X86
+		/* FIXME interferes with swiotlb. */
 		pci_dma_sync_single_for_device(nic->pdev, rx->dma_addr,
 					       sizeof(struct rfd),
 					       PCI_DMA_BIDIRECTIONAL);
+#endif
 		return -ENODATA;
 	}
=20
--=20
Krzysztof Halasa
