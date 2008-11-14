From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: Validation of DMA params breaks e100 driver
	(2.6.28-rc2)
Date: Thu, 13 Nov 2008 17:21:50 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.63.0811131718390.984@jbrandeb-desk.amr.corp.intel.com>
References: <4909E08F.9040306@users.sourceforge.net>
	<20081031210131.GA18015@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="824171-17616-1226625710=:984"
Cc: e1000-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?X-UNKNOWN?Q?Anders_Grafstr=F6m?= <grfstrm@users.sourceforge.net>,
	"linux-arm-kernel@lists.arm.linux.org.uk"
	<linux-arm-kernel@lists.arm.linux.org.uk>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20081031210131.GA18015@flint.arm.linux.org.uk>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--824171-17616-1226625710=:984
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 31 Oct 2008, Russell King - ARM Linux wrote:

> On Thu, Oct 30, 2008 at 05:27:59PM +0100, Anders Grafstr=F6m wrote:
> > The e100 driver triggers BUG_ON(buf->direction !=3D dir)
> > by doing pci_map_single(..., PCI_DMA_BIDIRECTIONAL)
> > and pci_dma_sync_single_for_device(..., PCI_DMA_TODEVICE).
> >=20
> > I'm guessing it's allowed to do that and that something like
> > the patch below is called for?
>=20
> No, it is not allowed to do that - that's why it's called "BUG_ON".
> Changing the DMA direction, especially with dmabounce will result
> in unexpected behaviour.

okay, how about this patch...  only compile tested as I couldn't get=20
net-next-2.6 to boot on my test machine.  I'll get some testing done on=20
this, but in the meantime....

e100: fix dma error in direction for mapping

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Russell King - ARM Linux wrote:
> On Thu, Oct 30, 2008 at 05:27:59PM +0100, Anders Grafstr=C3=B6m wrote:
>> The e100 driver triggers BUG_ON(buf->direction !=3D dir)
>> by doing pci_map_single(..., PCI_DMA_BIDIRECTIONAL)
>> and pci_dma_sync_single_for_device(..., PCI_DMA_TODEVICE).
>>=20
>> I'm guessing it's allowed to do that and that something like
>> the patch below is called for?
>=20
> No, it is not allowed to do that - that's why it's called "BUG_ON".
> Changing the DMA direction, especially with dmabounce will result
> in unexpected behaviour.

This is my attempt to fix this issue:

Reported by: Anders Grafstrom <grfstrm@users.sourceforge.net>
CC: Russell King <linux@arm.linux.org.uk>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/e100.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 62cdefa..c9c7079 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -166,7 +166,7 @@
=20
 #define DRV_NAME=09=09"e100"
 #define DRV_EXT=09=09=09"-NAPI"
-#define DRV_VERSION=09=09"3.5.23-k4"DRV_EXT
+#define DRV_VERSION=09=09"3.5.23-k6"DRV_EXT
 #define DRV_DESCRIPTION=09=09"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT=09=09"Copyright(c) 1999-2006 Intel Corporation"
 #define PFX=09=09=09DRV_NAME ": "
@@ -1804,7 +1804,7 @@ static int e100_rx_alloc_skb(struct nic *nic, struct =
rx *rx)
 =09=09struct rfd *prev_rfd =3D (struct rfd *)rx->prev->skb->data;
 =09=09put_unaligned_le32(rx->dma_addr, &prev_rfd->link);
 =09=09pci_dma_sync_single_for_device(nic->pdev, rx->prev->dma_addr,
-=09=09=09sizeof(struct rfd), PCI_DMA_TODEVICE);
+=09=09=09sizeof(struct rfd), PCI_DMA_BIDIRECTIONAL);
 =09}
=20
 =09return 0;
@@ -1823,7 +1823,7 @@ static int e100_rx_indicate(struct nic *nic, struct r=
x *rx,
=20
 =09/* Need to sync before taking a peek at cb_complete bit */
 =09pci_dma_sync_single_for_cpu(nic->pdev, rx->dma_addr,
-=09=09sizeof(struct rfd), PCI_DMA_FROMDEVICE);
+=09=09sizeof(struct rfd), PCI_DMA_BIDIRECTIONAL);
 =09rfd_status =3D le16_to_cpu(rfd->status);
=20
 =09DPRINTK(RX_STATUS, DEBUG, "status=3D0x%04X\n", rfd_status);
@@ -1850,7 +1850,7 @@ static int e100_rx_indicate(struct nic *nic, struct r=
x *rx,
=20
 =09/* Get data */
 =09pci_unmap_single(nic->pdev, rx->dma_addr,
-=09=09RFD_BUF_LEN, PCI_DMA_FROMDEVICE);
+=09=09RFD_BUF_LEN, PCI_DMA_BIDIRECTIONAL);
=20
 =09/* If this buffer has the el bit, but we think the receiver
 =09 * is still running, check to see if it really stopped while
@@ -1942,7 +1942,7 @@ static void e100_rx_clean(struct nic *nic, unsigned i=
nt *work_done,
 =09=09new_before_last_rfd->command |=3D cpu_to_le16(cb_el);
 =09=09pci_dma_sync_single_for_device(nic->pdev,
 =09=09=09new_before_last_rx->dma_addr, sizeof(struct rfd),
-=09=09=09PCI_DMA_TODEVICE);
+=09=09=09PCI_DMA_BIDIRECTIONAL);
=20
 =09=09/* Now that we have a new stopping point, we can clear the old
 =09=09 * stopping point.  We must sync twice to get the proper
@@ -1950,11 +1950,11 @@ static void e100_rx_clean(struct nic *nic, unsigned=
 int *work_done,
 =09=09old_before_last_rfd->command &=3D ~cpu_to_le16(cb_el);
 =09=09pci_dma_sync_single_for_device(nic->pdev,
 =09=09=09old_before_last_rx->dma_addr, sizeof(struct rfd),
-=09=09=09PCI_DMA_TODEVICE);
+=09=09=09PCI_DMA_BIDIRECTIONAL);
 =09=09old_before_last_rfd->size =3D cpu_to_le16(VLAN_ETH_FRAME_LEN);
 =09=09pci_dma_sync_single_for_device(nic->pdev,
 =09=09=09old_before_last_rx->dma_addr, sizeof(struct rfd),
-=09=09=09PCI_DMA_TODEVICE);
+=09=09=09PCI_DMA_BIDIRECTIONAL);
 =09}
=20
 =09if(restart_required) {
@@ -1977,7 +1977,7 @@ static void e100_rx_clean_list(struct nic *nic)
 =09=09for(rx =3D nic->rxs, i =3D 0; i < count; rx++, i++) {
 =09=09=09if(rx->skb) {
 =09=09=09=09pci_unmap_single(nic->pdev, rx->dma_addr,
-=09=09=09=09=09RFD_BUF_LEN, PCI_DMA_FROMDEVICE);
+=09=09=09=09=09RFD_BUF_LEN, PCI_DMA_BIDIRECTIONAL);
 =09=09=09=09dev_kfree_skb(rx->skb);
 =09=09=09}
 =09=09}
@@ -2020,7 +2020,7 @@ static int e100_rx_alloc_list(struct nic *nic)
 =09before_last->command |=3D cpu_to_le16(cb_el);
 =09before_last->size =3D 0;
 =09pci_dma_sync_single_for_device(nic->pdev, rx->dma_addr,
-=09=09sizeof(struct rfd), PCI_DMA_TODEVICE);
+=09=09sizeof(struct rfd), PCI_DMA_BIDIRECTIONAL);
=20
 =09nic->rx_to_use =3D nic->rx_to_clean =3D nic->rxs;
 =09nic->ru_running =3D RU_SUSPENDED;
@@ -2221,7 +2221,7 @@ static int e100_loopback_test(struct nic *nic, enum l=
oopback loopback_mode)
 =09msleep(10);
=20
 =09pci_dma_sync_single_for_cpu(nic->pdev, nic->rx_to_clean->dma_addr,
-=09=09=09RFD_BUF_LEN, PCI_DMA_FROMDEVICE);
+=09=09=09RFD_BUF_LEN, PCI_DMA_BIDIRECTIONAL);
=20
 =09if(memcmp(nic->rx_to_clean->skb->data + sizeof(struct rfd),
 =09   skb->data, ETH_DATA_LEN))
--824171-17616-1226625710=:984
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
--824171-17616-1226625710=:984
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel

--824171-17616-1226625710=:984--
