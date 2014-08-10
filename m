From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v2 2/4] driver core: enable drivers to use deferred
	probe from init
Date: Sun, 10 Aug 2014 16:58:02 +0200
Message-ID: <20140810145802.GJ21930@wotan.suse.de>
References: <1406572110-26823-1-git-send-email-mcgrof@do-not-panic.com> <1406572110-26823-3-git-send-email-mcgrof@do-not-panic.com> <20140730.151107.1328294951387764830.davem@davemloft.net> <20140809164119.GI21930@wotan.suse.de> <20140810124331.GE30451@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mcgrof@do-not-panic.com,
	tiwai@suse.de, linux-kernel@vger.kernel.org,
	penguin-kernel@I-love.SAKURA.ne.jp, joseph.salisbury@canonical.com,
	kay@vrfy.org, gnomes@lxorguk.ukuu.org.uk,
	tim.gardner@canonical.com, pierre-fersing@pierref.org,
	akpm@linux-foundation.org, oleg@redhat.com, bpoirier@suse.de,
	nagalakshmi.nandigama@avagotech.com,
	praveen.krishnamoorthy@avagotech.com,
	sreekanth.reddy@avagotech.com, abhijit.mahajan@avagotech.com,
	hariprasad@chelsio.com, santosh@chelsio.com,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51121 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751122AbaHJO6I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Aug 2014 10:58:08 -0400
Content-Disposition: inline
In-Reply-To: <20140810124331.GE30451@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 10, 2014 at 08:43:31PM +0800, Greg KH wrote:
> On Sat, Aug 09, 2014 at 06:41:19PM +0200, Luis R. Rodriguez wrote:
> > On Wed, Jul 30, 2014 at 03:11:07PM -0700, David Miller wrote:
> > > From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
> > > Date: Mon, 28 Jul 2014 11:28:28 -0700
> > > 
> > > > Tetsuo bisected and found that commit 786235ee "kthread: make
> > > > kthread_create() killable" modified kthread_create() to bail as
> > > > soon as SIGKILL is received. This is causing some issues with
> > > > some drivers and at times boot. Joseph then found that failures
> > > > occur as the systemd-udevd process sends SIGKILL to modprobe if
> > > > probe on a driver takes over 30 seconds. When this happens probe
> > > > will fail on any driver, its why booting on some system will fail
> > > > if the driver happens to be a storage related driver. Some folks
> > > > have suggested fixing this by modifying kthread_create() to not
> > > > leave upon SIGKILL [3], upon review Oleg rejected this change and
> > > > the discussion was punted out to systemd to see if the default
> > > > timeout could be increased from 30 seconds to 120. The opinion of
> > > > the systemd maintainers is that the driver's behavior should
> > > > be fixed [4]. Linus seems to agree [5], however more recently even
> > > > networking drivers have been reported to fail on probe since just
> > > > writing the firmware to a device and kicking it can take easy over
> > > > 60 seconds [6]. Benjamim was able to trace the issues recently
> > > > reported on cxgb4 down to the same systemd-udevd 30 second timeout [6].
> > > > 
> > > > This is an alternative solution which enables drivers that are
> > > > known to take long to use deferred probe workqueue. This avoids
> > > > the 30 second timeout and lets us annotate drivers with long
> > > > init sequences.
> > > > 
> > > > As drivers determine a component is not yet available and needs
> > > > to defer probe you'll be notified this happen upon init for each
> > > > device but now with a message such as:
> > > > 
> > > > pci 0000:03:00.0: Driver cxgb4 requests probe deferral on init
> > > > 
> > > > You should see one of these per struct device probed.
> > > 
> > > It seems we're still discussing this.
> > > 
> > > I think I understand all of the underlying issues, and what I'll say
> > > is that perhaps we should use what Greg KH requested but via a helper
> > > that is easy to grep for.
> > > 
> > > I don't care if it's something like "module_long_probe_init()" and
> > > "module_long_probe_exit()", but it just needs to be some properly
> > > named interface which does the whole kthread or whatever bit.
> > 
> > I've tested the alternative kthread_run() proposal but unfortunately it
> > does not help resolve the issue, the timeout is still hit and a SIGKILL
> > still kills the driver probe. Please let me know how you'd all like us
> > to proceed, these defer probe patches do help cure the issue though.
> 
> Why doesn't it work?  Doesn't modprobe come right back and the init
> sequence still takes a while to run?  What exactly fails?

systemd uses kmod kmod_module_probe_insert_module(), what I see is that using
kthread_run() as a work around still causes probe to fail on a driver that
otherwise would work fine if all you do is sprinkle ssleep(33) (seconds) on the
init sequence. To see the issue you can test this on any of your network
drivers that get loaded automatically, I did my testing with iwlwifi by
purposely breaking it and then using the work around. It seems the probe
somehow still gets killed as before, I haven't debugged this further.

For example by breaking and fixing iwlwifi this yields:

ergon:~ # journalctl -b -0 -u systemd-udevd 

-- Logs begin at Mon 2014-08-04 21:55:28 EDT, end at Sun 2014-08-10 10:50:14 EDT. --
Aug 10 10:48:49 ergon systemd-udevd[257]: specified group 'input' unknown
Aug 10 10:48:55 ergon mtp-probe[493]: checking bus 3, device 2: "/sys/devices/pci0000:00/0000:00:14.0/usb3/3-7"
Aug 10 10:48:55 ergon mtp-probe[492]: checking bus 3, device 4: "/sys/devices/pci0000:00/0000:00:14.0/usb3/3-12"
Aug 10 10:49:24 ergon systemd-udevd[465]: seq 1755 '/devices/pci0000:00/0000:00:1c.1/0000:03:00.0' killed

ergon:~ # dmesg | grep iwlwifi
[   10.315538] iwlwifi Going to sleep for 33 seconds
[   43.323958] iwlwifi Done sleeping
[   43.324400] iwlwifi 0000:03:00.0: irq 50 for MSI/MSI-X
[   43.324534] iwlwifi 0000:03:00.0: Error allocating IRQ 50
[   43.326951] iwlwifi: probe of 0000:03:00.0 failed with error -4

The patch used:

diff --git a/drivers/net/wireless/iwlwifi/mvm/ops.c b/drivers/net/wireless/iwlwifi/mvm/ops.c
index 610dbcb..65e0ab2 100644
--- a/drivers/net/wireless/iwlwifi/mvm/ops.c
+++ b/drivers/net/wireless/iwlwifi/mvm/ops.c
@@ -63,6 +63,7 @@
 #include <linux/module.h>
 #include <linux/vmalloc.h>
 #include <net/mac80211.h>
+#include <linux/kthread.h>
 
 #include "iwl-notif-wait.h"
 #include "iwl-trans.h"
@@ -111,7 +112,7 @@ MODULE_PARM_DESC(power_scheme,
 /*
  * module init and exit functions
  */
-static int __init iwl_mvm_init(void)
+static int iwl_mvm_init_real(void *arg)
 {
 	int ret;
 
@@ -130,12 +131,21 @@ static int __init iwl_mvm_init(void)
 
 	return ret;
 }
+
+static struct task_struct *init_thread;
+
+static int __init iwl_mvm_init(void)
+{
+	init_thread = kthread_run(iwl_mvm_init_real, NULL, "iwl_mvm_init");
+	return 0;
+}
 module_init(iwl_mvm_init);
 
 static void __exit iwl_mvm_exit(void)
 {
 	iwl_opmode_deregister("iwlmvm");
 	iwl_mvm_rate_control_unregister();
+	kthread_stop(init_thread);
 }
 module_exit(iwl_mvm_exit);
 
diff --git a/drivers/net/wireless/iwlwifi/pcie/drv.c b/drivers/net/wireless/iwlwifi/pcie/drv.c
index 98950e4..c1f2823 100644
--- a/drivers/net/wireless/iwlwifi/pcie/drv.c
+++ b/drivers/net/wireless/iwlwifi/pcie/drv.c
@@ -489,6 +489,10 @@ static int iwl_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct iwl_trans_pcie *trans_pcie;
 	int ret;
 
+	printk("iwlwifi Going to sleep for 33 seconds\n");
+	ssleep(33);
+	printk("iwlwifi Done sleeping\n");
+
 	iwl_trans = iwl_trans_pcie_alloc(pdev, ent, cfg);
 	if (IS_ERR(iwl_trans))
 		return PTR_ERR(iwl_trans);
