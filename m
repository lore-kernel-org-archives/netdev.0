From: Jon Maxwell <jmaxwell37@gmail.com>
Subject: [PATCH net-next] cnic: call cp->stop_hw() in cnic_start_hw() on allocation failure
Date: Thu,  5 May 2016 09:55:51 +1000
Message-ID: <1462406151-5224-1-git-send-email-jmaxwell37@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, jmaxwell@redhat.com,
	ivecera@redhat.com, Jon Maxwell <jmaxwell37@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We recently had a system crash in the cnic module. Vmcore analysis conf=
irmed=20
that "ip link up" was executed which failed due to an allocation failur=
e=20
because of memory fragmentation. Futher analysis revealed that the cnic=
 irq=20
vector was still allocated after the "ip link up" that failed. When=20
"ip link down" was executed it called free_msi_irqs() which crashed the=
 system=20
because the cnic irq was still inuse.

PANIC: "kernel BUG at drivers/pci/msi.c:411!"

The code execution was:

cnic_netdev_event()
if (event =3D=3D NETDEV_UP) {
=2E
=2E
       =E2=96=B9       if (!cnic_start_hw(dev))
cnic_start_hw()
calls cnic_cm_open() which failed with -ENOMEM
cnic_start_hw() then took the err1 path:

err1:=E2=86=A9
       cp->free_resc(dev);=E2=86=A9 <---- frees resources but not irq v=
ector
       pci_dev_put(dev->pcidev);=E2=86=A9
       return err;=E2=86=A9
}=E2=86=A9

This returns control back to cnic_netdev_event() but now the cnic irq v=
ector=20
is still allocated even although cnic_cm_open() failed. The next=20
"ip link down" while trigger the crash.=20

The cnic_start_hw() routine is not handling the allocation failure corr=
ectly.=20
=46ix this by checking whether CNIC_DRV_STATE_HANDLES_IRQ flag is set i=
ndicating=20
that the hardware has been started in cnic_start_hw(). If it has then c=
all=20
cp->stop_hw() which frees the cnic irq vector and cnic resources. Other=
wise=20
just maintain the previous behaviour and free cnic resources.=20

I reproduced this by injecting an ENOMEM error into cnic_cm_alloc_mem()=
s return
code.=20

# ip link set dev enpX down
# ip link set dev enpX up <--- hit's allocation failure
# ip link set dev enpX down <--- crashes here

With this patch I confirmed there was no crash in the reproducer.

Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>
---
 drivers/net/ethernet/broadcom/cnic.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/etherne=
t/broadcom/cnic.c
index b69dc58..b1d2ac8 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -5350,7 +5350,10 @@ static int cnic_start_hw(struct cnic_dev *dev)
 	return 0;
=20
 err1:
-	cp->free_resc(dev);
+	if (ethdev->drv_state & CNIC_DRV_STATE_HANDLES_IRQ)
+		cp->stop_hw(dev);
+	else
+		cp->free_resc(dev);
 	pci_dev_put(dev->pcidev);
 	return err;
 }
--=20
1.8.3.1
