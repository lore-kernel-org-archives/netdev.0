From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 11/29] drivers,
 media: convert cx88_core.refcount from atomic_t to refcount_t
Date: Mon,  6 Mar 2017 16:20:58 +0200
Message-ID: <1488810076-3754-12-git-send-email-elena.reshetova@intel.com>
References: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, linux-pci@vger.kernel.org,
 target-devel@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
 Elena Reshetova <elena.reshetova@intel.com>, devel@driverdev.osuosl.org,
 linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org,
 linux-serial@vger.kernel.org, fcoe-devel@open-fcoe.org,
 xen-devel@lists.xenproject.org, open-iscsi@googlegroups.com,
 linux-media@vger.kernel.org, Kees Cook <keescook@chromium.org>,
 linux-raid@vger.kernel.org, linux-bcache@vger.kernel.org,
 Hans Liljestrand <ishkamiel@gmail.com>, David Windsor <dwindsor@gmail.com>,
 netdev@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 drivers/media/pci/cx88/cx88-cards.c | 2 +-
 drivers/media/pci/cx88/cx88-core.c  | 4 ++--
 drivers/media/pci/cx88/cx88.h       | 3 ++-
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/media/pci/cx88/cx88-cards.c b/drivers/media/pci/cx88/cx88-cards.c
index cdfbde2..7fc5f5f 100644
--- a/drivers/media/pci/cx88/cx88-cards.c
+++ b/drivers/media/pci/cx88/cx88-cards.c
@@ -3670,7 +3670,7 @@ struct cx88_core *cx88_core_create(struct pci_dev *pci, int nr)
 	if (!core)
 		return NULL;
 
-	atomic_inc(&core->refcount);
+	refcount_set(&core->refcount, 1);
 	core->pci_bus  = pci->bus->number;
 	core->pci_slot = PCI_SLOT(pci->devfn);
 	core->pci_irqmask = PCI_INT_RISC_RD_BERRINT | PCI_INT_RISC_WR_BERRINT |
diff --git a/drivers/media/pci/cx88/cx88-core.c b/drivers/media/pci/cx88/cx88-core.c
index 973a9cd4..8bfa5b7 100644
--- a/drivers/media/pci/cx88/cx88-core.c
+++ b/drivers/media/pci/cx88/cx88-core.c
@@ -1052,7 +1052,7 @@ struct cx88_core *cx88_core_get(struct pci_dev *pci)
 			mutex_unlock(&devlist);
 			return NULL;
 		}
-		atomic_inc(&core->refcount);
+		refcount_inc(&core->refcount);
 		mutex_unlock(&devlist);
 		return core;
 	}
@@ -1073,7 +1073,7 @@ void cx88_core_put(struct cx88_core *core, struct pci_dev *pci)
 	release_mem_region(pci_resource_start(pci, 0),
 			   pci_resource_len(pci, 0));
 
-	if (!atomic_dec_and_test(&core->refcount))
+	if (!refcount_dec_and_test(&core->refcount))
 		return;
 
 	mutex_lock(&devlist);
diff --git a/drivers/media/pci/cx88/cx88.h b/drivers/media/pci/cx88/cx88.h
index 115414c..16c1313 100644
--- a/drivers/media/pci/cx88/cx88.h
+++ b/drivers/media/pci/cx88/cx88.h
@@ -24,6 +24,7 @@
 #include <linux/i2c-algo-bit.h>
 #include <linux/videodev2.h>
 #include <linux/kdev_t.h>
+#include <linux/refcount.h>
 
 #include <media/v4l2-device.h>
 #include <media/v4l2-fh.h>
@@ -339,7 +340,7 @@ struct cx8802_dev;
 
 struct cx88_core {
 	struct list_head           devlist;
-	atomic_t                   refcount;
+	refcount_t                   refcount;
 
 	/* board name */
 	int                        nr;
-- 
2.7.4
