From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH 07/19] timberdale: mfd_cell is now implicitly available
 to drivers
Date: Wed, 6 Apr 2011 17:23:23 +0200
Message-ID: <20110406152322.GA2757@sortiz-mobl>
References: <20110202195417.228e2656@queued.net>
 <20110202200812.3d8d6cba@queued.net>
 <20110331230522.GI437@ponder.secretlab.ca>
 <20110401112030.GA3447@sortiz-mobl>
 <20110401104756.2f5c6f7a@debxo>
 <BANLkTi=bCd_+f=EG-O=U5VH_ZNjFhxkziQ@mail.gmail.com>
 <20110401235239.GE29397@sortiz-mobl>
 <BANLkTi=bq=OGzXFp7qiBr7x_BnGOWf=DRQ@mail.gmail.com>
 <20110404100314.GC2751@sortiz-mobl>
 <20110405030428.GB29522@ponder.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andres Salomon <dilinger@queued.net>, linux-kernel@vger.kernel.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	khali@linux-fr.org, ben-linux@fluff.org,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	David Brownell <dbrownell@users.sourceforge.net>,
	linux-i2c@vger.kernel.org, linux-media@vger.kernel.org,
	netdev@vger.kernel.org, spi-devel-general@lists.sourceforge.net,
	Mocean Laboratories <info@mocean-labs.com>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110405030428.GB29522@ponder.secretlab.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 04, 2011 at 09:04:29PM -0600, Grant Likely wrote:
> > The second step would be to get rid of mfd_get_data() and have all subdrivers
> > going back to the regular platform_data way. They would no longer be dependant
> > on the MFD code except for those who really need it. In that case they could
> > just call mfd_get_cell() and get full access to their MFD cell.
> 
> The revert to platform_data needs to happen ASAP though.  If this
> second step isn't ready really quickly, then the current patches
> should be reverted to give some breathing room for creating the
> replacement patches.  However, it's not such a rush if the below
> patch really does eliminate all of the nastiness of the original
> series. (I haven't looked and a rolled up diff of the first series and
> this change, so I don't know for sure).
I am done reverting these changes, with a final patch getting rid of
mfd_get_data. See
git://git.kernel.org/pub/scm/linux/kernel/git/sameo/mfd-2.6.git for-linus

I still need to give it a second review before pushing it to lkml for
comments. It's 20 patches long, so I'm not entirely sure Linus would take that
at that point.
Pushing patch #1 would be enough for fixing the issues introduced by the
original patchset, so I'm leaning toward pushing it and leaving the 19 other
patches for the next merge window.


> In principle I agree with this patch.  Some comments below.
Thanks for the comments. I think I addressed all of them in patch #1:


---
 drivers/base/platform.c  |    1 +
 drivers/mfd/mfd-core.c   |   15 +++++++++++++--
 include/linux/device.h   |    3 +++
 include/linux/mfd/core.h |    7 +++++--
 4 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/drivers/base/platform.c b/drivers/base/platform.c
index f051cff..bde6b97 100644
--- a/drivers/base/platform.c
+++ b/drivers/base/platform.c
@@ -149,6 +149,7 @@ static void platform_device_release(struct device *dev)
 
 	of_device_node_put(&pa->pdev.dev);
 	kfree(pa->pdev.dev.platform_data);
+	kfree(pa->pdev.dev.mfd_cell);
 	kfree(pa->pdev.resource);
 	kfree(pa);
 }
diff --git a/drivers/mfd/mfd-core.c b/drivers/mfd/mfd-core.c
index d01574d..99b0d6d 100644
--- a/drivers/mfd/mfd-core.c
+++ b/drivers/mfd/mfd-core.c
@@ -18,6 +18,18 @@
 #include <linux/pm_runtime.h>
 #include <linux/slab.h>
 
+static int mfd_platform_add_cell(struct platform_device *pdev, const struct mfd_cell *cell)
+{
+	if (!cell)
+		return 0;
+
+	pdev->dev.mfd_cell = kmemdup(cell, sizeof(*cell), GFP_KERNEL);
+	if (!pdev->dev.mfd_cell)
+		return -ENOMEM;
+
+	return 0;
+}
+
 int mfd_cell_enable(struct platform_device *pdev)
 {
 	const struct mfd_cell *cell = mfd_get_cell(pdev);
@@ -75,7 +87,7 @@ static int mfd_add_device(struct device *parent, int id,
 
 	pdev->dev.parent = parent;
 
-	ret = platform_device_add_data(pdev, cell, sizeof(*cell));
+	ret = mfd_platform_add_cell(pdev, cell);
 	if (ret)
 		goto fail_res;
 
@@ -123,7 +135,6 @@ static int mfd_add_device(struct device *parent, int id,
 
 	return 0;
 
-/*	platform_device_del(pdev); */
 fail_res:
 	kfree(res);
 fail_device:
diff --git a/include/linux/device.h b/include/linux/device.h
index ab8dfc0..cf353cf 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -33,6 +33,7 @@ struct class;
 struct subsys_private;
 struct bus_type;
 struct device_node;
+struct mfd_cell;
 
 struct bus_attribute {
 	struct attribute	attr;
@@ -444,6 +445,8 @@ struct device {
 	struct device_node	*of_node; /* associated device tree node */
 	const struct of_device_id *of_match; /* matching of_device_id from driver */
 
+	struct mfd_cell	*mfd_cell; /* MFD cell pointer */
+
 	dev_t			devt;	/* dev_t, creates the sysfs "dev" */
 
 	spinlock_t		devres_lock;
diff --git a/include/linux/mfd/core.h b/include/linux/mfd/core.h
index ad1b19a..28f81cf 100644
--- a/include/linux/mfd/core.h
+++ b/include/linux/mfd/core.h
@@ -86,7 +86,7 @@ extern int mfd_clone_cell(const char *cell, const char **clones,
  */
 static inline const struct mfd_cell *mfd_get_cell(struct platform_device *pdev)
 {
-	return pdev->dev.platform_data;
+	return pdev->dev.mfd_cell;
 }
 
 /*
@@ -95,7 +95,10 @@ static inline const struct mfd_cell *mfd_get_cell(struct platform_device *pdev)
  */
 static inline void *mfd_get_data(struct platform_device *pdev)
 {
-	return mfd_get_cell(pdev)->mfd_data;
+	if (pdev->dev.mfd_cell)
+		return mfd_get_cell(pdev)->mfd_data;
+	else
+		return pdev->dev.platform_data;
 }
 
 extern int mfd_add_devices(struct device *parent, int id,
-- 
1.7.2.3

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
