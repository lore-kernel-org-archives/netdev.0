From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Ksummit-2010-discuss] [v2] Remaining BKL users, what to do
Date: Tue, 19 Oct 2010 22:44:41 +0200
Message-ID: <201010192244.41913.arnd@arndb.de>
References: <201009161632.59210.arnd@arndb.de> <201010192140.47433.oliver@neukum.org> <20101019202912.GA30133@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver@neukum.org>, Valdis.Kletnieks@vt.edu,
	Dave Airlie <airlied@gmail.com>,
	codalist@telemann.coda.cs.cmu.edu,
	ksummit-2010-discuss@lists.linux-foundation.org,
	autofs@linux.kernel.org, Jan Harkes <jaharkes@cs.cmu.edu>,
	Samuel Ortiz <samuel@sortiz.org>, Jan Kara <jack@suse.cz>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, Anders Larsen <al@alarsen.net>,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	Bryan Schumaker <bjschuma@netapp.com>,
	Christoph Hellwig <hch@infradead.org>,
	Petr Vandrovec <vandrove@vc.cvut.cz>,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	linux-fsdevel@vger.kernel.org,
	Evgeniy Dushistov <dushistov@mail.ru>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Hendry <andrew.hendry@gmail.com>,
	linux-media@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101019202912.GA30133@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 19 October 2010 22:29:12 Greg KH wrote:
> On Tue, Oct 19, 2010 at 09:40:47PM +0200, Oliver Neukum wrote:
> > Am Dienstag, 19. Oktober 2010, 21:37:35 schrieb Greg KH:
> > > > So no need to clean it up for multiprocessor support.
> > > > 
> > > > http://download.intel.com/design/chipsets/datashts/29067602.pdf
> > > > http://www.intel.com/design/chipsets/specupdt/29069403.pdf
> > > 
> > > Great, we can just drop all calls to lock_kernel() and the like in the
> > > driver and be done with it, right?
> > 
> > No,
> > 
> > you still need to switch off preemption.
> 
> Hm, how would you do that from within a driver?

I think this would do:
---
drm/i810: remove SMP support and BKL

The i810 and i815 chipsets supported by the i810 drm driver were not
officially designed for SMP operation, so the big kernel lock is
only required for kernel preemption. This disables the driver if
preemption is enabled and removes all calls to lock_kernel in it.

If you own an Acorp 6A815EPD mainboard with a i815 chipset and
two Pentium-III sockets, and want to run recent kernels on it,
tell me about it.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---

diff --git a/drivers/gpu/drm/Kconfig b/drivers/gpu/drm/Kconfig
index b755301..e071bc8 100644
--- a/drivers/gpu/drm/Kconfig
+++ b/drivers/gpu/drm/Kconfig
@@ -73,8 +73,8 @@ source "drivers/gpu/drm/radeon/Kconfig"
 
 config DRM_I810
 	tristate "Intel I810"
-	# BKL usage in order to avoid AB-BA deadlocks, may become BROKEN_ON_SMP
-	depends on DRM && AGP && AGP_INTEL && BKL
+	# PREEMPT requires BKL support here, which was removed
+	depends on DRM && AGP && AGP_INTEL && !PREEMPT
 	help
 	  Choose this option if you have an Intel I810 graphics card.  If M is
 	  selected, the module will be called i810.  AGP support is required
diff --git a/drivers/gpu/drm/i810/i810_dma.c b/drivers/gpu/drm/i810/i810_dma.c
index ff33e53..8f371e8 100644
--- a/drivers/gpu/drm/i810/i810_dma.c
+++ b/drivers/gpu/drm/i810/i810_dma.c
@@ -37,7 +37,6 @@
 #include <linux/interrupt.h>	/* For task queue support */
 #include <linux/delay.h>
 #include <linux/slab.h>
-#include <linux/smp_lock.h>
 #include <linux/pagemap.h>
 
 #define I810_BUF_FREE		2
@@ -94,7 +93,6 @@ static int i810_mmap_buffers(struct file *filp, struct vm_area_struct *vma)
 	struct drm_buf *buf;
 	drm_i810_buf_priv_t *buf_priv;
 
-	lock_kernel();
 	dev = priv->minor->dev;
 	dev_priv = dev->dev_private;
 	buf = dev_priv->mmap_buffer;
@@ -104,7 +102,6 @@ static int i810_mmap_buffers(struct file *filp, struct vm_area_struct *vma)
 	vma->vm_file = filp;
 
 	buf_priv->currently_mapped = I810_BUF_MAPPED;
-	unlock_kernel();
 
 	if (io_remap_pfn_range(vma, vma->vm_start,
 			       vma->vm_pgoff,
@@ -116,7 +113,7 @@ static int i810_mmap_buffers(struct file *filp, struct vm_area_struct *vma)
 static const struct file_operations i810_buffer_fops = {
 	.open = drm_open,
 	.release = drm_release,
-	.unlocked_ioctl = i810_ioctl,
+	.unlocked_ioctl = drm_ioctl,
 	.mmap = i810_mmap_buffers,
 	.fasync = drm_fasync,
 	.llseek = noop_llseek,
@@ -1242,19 +1239,6 @@ int i810_driver_dma_quiescent(struct drm_device *dev)
 	return 0;
 }
 
-/*
- * call the drm_ioctl under the big kernel lock because
- * to lock against the i810_mmap_buffers function.
- */
-long i810_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
-{
-	int ret;
-	lock_kernel();
-	ret = drm_ioctl(file, cmd, arg);
-	unlock_kernel();
-	return ret;
-}
-
 struct drm_ioctl_desc i810_ioctls[] = {
 	DRM_IOCTL_DEF_DRV(I810_INIT, i810_dma_init, DRM_AUTH|DRM_MASTER|DRM_ROOT_ONLY|DRM_UNLOCKED),
 	DRM_IOCTL_DEF_DRV(I810_VERTEX, i810_dma_vertex, DRM_AUTH|DRM_UNLOCKED),
diff --git a/drivers/gpu/drm/i810/i810_drv.c b/drivers/gpu/drm/i810/i810_drv.c
index 88bcd33..9642d3c 100644
--- a/drivers/gpu/drm/i810/i810_drv.c
+++ b/drivers/gpu/drm/i810/i810_drv.c
@@ -57,7 +57,7 @@ static struct drm_driver driver = {
 		 .owner = THIS_MODULE,
 		 .open = drm_open,
 		 .release = drm_release,
-		 .unlocked_ioctl = i810_ioctl,
+		 .unlocked_ioctl = drm_ioctl,
 		 .mmap = drm_mmap,
 		 .poll = drm_poll,
 		 .fasync = drm_fasync,
@@ -79,6 +79,10 @@ static struct drm_driver driver = {
 
 static int __init i810_init(void)
 {
+	if (num_present_cpus() > 1) {
+		pr_err("drm/i810 does not support SMP\n");
+		return -EINVAL;
+	}
 	driver.num_ioctls = i810_max_ioctl;
 	return drm_init(&driver);
 }
