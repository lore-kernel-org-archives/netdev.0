From: Mauro Carvalho Chehab <mchehab@redhat.com>
Subject: Re: SYSFS "errors"
Date: Tue, 19 Feb 2013 11:35:21 -0300
Message-ID: <20130219113521.510db290@redhat.com>
References: <20130219101121.GJ23197@arwen.pp.htv.fi>
	<20130219081149.46972f56@redhat.com>
	<20130219114345.GA26623@pd.tnic>
	<20130219091610.2b746a30@redhat.com>
	<20130219123502.GD26623@pd.tnic>
	<20130219094640.2abf1a66@redhat.com>
	<20130219130626.GE26623@pd.tnic>
	<20130219131500.GW23197@arwen.pp.htv.fi>
	<20130219132853.GG26623@pd.tnic>
	<20130219133809.GA4390@arwen.pp.htv.fi>
	<20130219135056.GH26623@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Felipe Balbi <balbi@ti.com>, Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, JBottomley@parallels.com,
	linux-scsi@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Doug Thompson <dougthompson@xmission.com>,
	linux-edac@vger.kernel.org, rjw@sisk.pl, linux-pm@vger.kernel.org
To: Borislav Petkov <bp@alien8.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130219135056.GH26623@pd.tnic>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, 19 Feb 2013 14:50:56 +0100
Borislav Petkov <bp@alien8.de> escreveu:

> On Tue, Feb 19, 2013 at 03:38:09PM +0200, Felipe Balbi wrote:
> > because changing the permission will cause the same issue:
> 
> Actually, I take that back. Mauro's patch will already create the file
> anyway:
> 
> 	if (mci->set_sdram_scrub_rate || mci->get_sdram_scrub_rate)
> 
> Adjusting the permissions is simply the last missing piece to this patch
> to make the interface to userspace 100% coherent.

That's covers everything but Hannes arguments. I don't think that
adding just one more device_create_file() on a driver that creates
dozens (or hundreds) of sys nodes, depending on the number of DIMMS
on the system would make it any worse.

Regards,
Mauro

[PATCH EDAC] edac: only create sdram_scrub_rate where supported

Currently, sdram_scrub_rate sysfs node is created even if the device
doesn't support get/set the scub rate. Change the logic to only
create this device node when the operation is supported.

Reported-by: Felipe Balbi <balbi@ti.com>
Signed-off-by: Mauro Carvalho Chehab <mchehab@redhat.com>

diff --git a/drivers/edac/edac_mc_sysfs.c b/drivers/edac/edac_mc_sysfs.c
index 9c58da6..4f4b613 100644
--- a/drivers/edac/edac_mc_sysfs.c
+++ b/drivers/edac/edac_mc_sysfs.c
@@ -7,7 +7,7 @@
  *
  * Written Doug Thompson <norsk5@xmission.com> www.softwarebitmaker.com
  *
- * (c) 2012 - Mauro Carvalho Chehab <mchehab@redhat.com>
+ * (c) 2012-2013 - Mauro Carvalho Chehab <mchehab@redhat.com>
  *	The entire API were re-written, and ported to use struct device
  *
  */
@@ -681,9 +681,6 @@ static ssize_t mci_sdram_scrub_rate_store(struct device *dev,
 	unsigned long bandwidth = 0;
 	int new_bw = 0;
 
-	if (!mci->set_sdram_scrub_rate)
-		return -ENODEV;
-
 	if (strict_strtoul(data, 10, &bandwidth) < 0)
 		return -EINVAL;
 
@@ -707,9 +704,6 @@ static ssize_t mci_sdram_scrub_rate_show(struct device *dev,
 	struct mem_ctl_info *mci = to_mci(dev);
 	int bandwidth = 0;
 
-	if (!mci->get_sdram_scrub_rate)
-		return -ENODEV;
-
 	bandwidth = mci->get_sdram_scrub_rate(mci);
 	if (bandwidth < 0) {
 		edac_printk(KERN_DEBUG, EDAC_MC, "Error reading scrub rate\n");
@@ -870,8 +864,7 @@ DEVICE_ATTR(ce_count, S_IRUGO, mci_ce_count_show, NULL);
 DEVICE_ATTR(max_location, S_IRUGO, mci_max_location_show, NULL);
 
 /* memory scrubber attribute file */
-DEVICE_ATTR(sdram_scrub_rate, S_IRUGO | S_IWUSR, mci_sdram_scrub_rate_show,
-	mci_sdram_scrub_rate_store);
+DEVICE_ATTR(sdram_scrub_rate, 0, NULL, NULL);
 
 static struct attribute *mci_attrs[] = {
 	&dev_attr_reset_counters.attr,
@@ -882,7 +875,6 @@ static struct attribute *mci_attrs[] = {
 	&dev_attr_ce_noinfo_count.attr,
 	&dev_attr_ue_count.attr,
 	&dev_attr_ce_count.attr,
-	&dev_attr_sdram_scrub_rate.attr,
 	&dev_attr_max_location.attr,
 	NULL
 };
@@ -1017,6 +1009,22 @@ int edac_create_sysfs_mci_device(struct mem_ctl_info *mci)
 		return err;
 	}
 
+	if (mci->set_sdram_scrub_rate || mci->get_sdram_scrub_rate) {
+		if (mci->get_sdram_scrub_rate) {
+			dev_attr_sdram_scrub_rate.attr.mode |= S_IRUGO;
+			dev_attr_sdram_scrub_rate.show = &mci_sdram_scrub_rate_show;
+		}
+		if (mci->set_sdram_scrub_rate) {
+			dev_attr_sdram_scrub_rate.attr.mode |= S_IWUSR;
+			dev_attr_sdram_scrub_rate.store = &mci_sdram_scrub_rate_store;
+		}
+		err = device_create_file(&mci->dev,
+					 &dev_attr_sdram_scrub_rate);
+		if (err) {
+			edac_dbg(1, "failure: create sdram_scrub_rate\n");
+			goto fail2;
+		}
+	}
 	/*
 	 * Create the dimm/rank devices
 	 */
@@ -1061,6 +1069,7 @@ fail:
 			continue;
 		device_unregister(&dimm->dev);
 	}
+fail2:
 	device_unregister(&mci->dev);
 	bus_unregister(&mci->bus);
 	kfree(mci->bus.name);

-- 

Cheers,
Mauro
