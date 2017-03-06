From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 03/29] drivers,
 char: convert vma_data.refcnt from atomic_t to refcount_t
Date: Mon,  6 Mar 2017 16:20:50 +0200
Message-ID: <1488810076-3754-4-git-send-email-elena.reshetova@intel.com>
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
 drivers/char/mspec.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/char/mspec.c b/drivers/char/mspec.c
index a9c2fa3..7b75669 100644
--- a/drivers/char/mspec.c
+++ b/drivers/char/mspec.c
@@ -43,6 +43,7 @@
 #include <linux/string.h>
 #include <linux/slab.h>
 #include <linux/numa.h>
+#include <linux/refcount.h>
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <linux/atomic.h>
@@ -89,7 +90,7 @@ static int is_sn2;
  * protect in fork case where multiple tasks share the vma_data.
  */
 struct vma_data {
-	atomic_t refcnt;	/* Number of vmas sharing the data. */
+	refcount_t refcnt;	/* Number of vmas sharing the data. */
 	spinlock_t lock;	/* Serialize access to this structure. */
 	int count;		/* Number of pages allocated. */
 	enum mspec_page_type type; /* Type of pages allocated. */
@@ -144,7 +145,7 @@ mspec_open(struct vm_area_struct *vma)
 	struct vma_data *vdata;
 
 	vdata = vma->vm_private_data;
-	atomic_inc(&vdata->refcnt);
+	refcount_inc(&vdata->refcnt);
 }
 
 /*
@@ -162,7 +163,7 @@ mspec_close(struct vm_area_struct *vma)
 
 	vdata = vma->vm_private_data;
 
-	if (!atomic_dec_and_test(&vdata->refcnt))
+	if (!refcount_dec_and_test(&vdata->refcnt))
 		return;
 
 	last_index = (vdata->vm_end - vdata->vm_start) >> PAGE_SHIFT;
@@ -274,7 +275,7 @@ mspec_mmap(struct file *file, struct vm_area_struct *vma,
 	vdata->vm_end = vma->vm_end;
 	vdata->type = type;
 	spin_lock_init(&vdata->lock);
-	atomic_set(&vdata->refcnt, 1);
+	refcount_set(&vdata->refcnt, 1);
 	vma->vm_private_data = vdata;
 
 	vma->vm_flags |= VM_IO | VM_PFNMAP | VM_DONTEXPAND | VM_DONTDUMP;
-- 
2.7.4
