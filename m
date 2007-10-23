From: Michael Ellerman <michael@ellerman.id.au>
Subject: [PATCH] Read back MSI message in rtas_setup_msi_irqs() so restore
	works
Date: Tue, 23 Oct 2007 14:23:44 +1000 (EST)
Message-ID: <5f47235ce3542c80e043f7f183400ab3d576f1dd.1193113342.git.michael@ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, linuxppc-dev@ozlabs.org,
	mchan@broadcom.com, linux-pci@atrey.karlin.mff.cuni.cz,
	"David S. Miller" <davem@davemloft.net>
To: Paul Mackerras <paulus@samba.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

There are plans afoot to use pci_restore_msi_state() to restore MSI
state after a device reset. In order for this to work for the RTAS MSI
backend, we need to read back the MSI message from config space after
it has been setup by firmware.

This should be sufficient for restoring the MSI state after a device
reset, however we will need to revisit this for suspend to disk if that
is ever implemented on pseries.

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
---

Linas, can you test this on your setup with your EEH stuff? I haven't got
any MSI supporting hardware/firmware combination.


 arch/powerpc/platforms/pseries/msi.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/platforms/pseries/msi.c b/arch/powerpc/platforms/pseries/msi.c
index 2793a1b..f15222b 100644
--- a/arch/powerpc/platforms/pseries/msi.c
+++ b/arch/powerpc/platforms/pseries/msi.c
@@ -171,6 +171,7 @@ static int rtas_setup_msi_irqs(struct pci_dev *pdev, int nvec, int type)
 	struct pci_dn *pdn;
 	int hwirq, virq, i, rc;
 	struct msi_desc *entry;
+	struct msi_msg msg;
 
 	pdn = get_pdn(pdev);
 	if (!pdn)
@@ -213,6 +214,11 @@ static int rtas_setup_msi_irqs(struct pci_dev *pdev, int nvec, int type)
 
 		dev_dbg(&pdev->dev, "rtas_msi: allocated virq %d\n", virq);
 		set_irq_msi(virq, entry);
+
+		/* Read config space back so we can restore after reset */
+		read_msi_msg(virq, &msg);
+		entry->msg = msg;
+
 		unmask_msi_irq(virq);
 	}
 
-- 
1.5.1.3.g7a33b
