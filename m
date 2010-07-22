From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] Driver-core: Fix bluetooth network device rename regression
Date: Thu, 22 Jul 2010 02:16:02 -0700
Message-ID: <m1zkxj27xp.fsf_-_@fess.ebiederm.org>
References: <20100621222938.GA20583@suse.de>
	<m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
	<m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de>
	<m1630q7x5v.fsf_-_@fess.ebiederm.org>
	<20100708211930.GA15385@kroah.com> <m1r5jdbobe.fsf@fess.ebiederm.org>
	<20100708230601.GB17002@kroah.com>
	<20100719133451.0862ca62.akpm@linux-foundation.org>
	<20100720201334.GA11991@suse.de> <m139vd5sms.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Greg KH <greg@kroah.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:47419 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754436Ab0GVJQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 05:16:14 -0400
In-Reply-To: <m139vd5sms.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's message of "Tue\, 20 Jul 2010 22\:08\:27 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


With CONFIG_SYSFS_DEPRECATED_V2 enabled I can rename any network device
anything as long as the new name does not conflict with another network
device.

With CONFIG_SYSFS_DEPRECATED_V2 disabled without this fix bluetooth benp
devices, and the mac80211_hwsim driver can not be renamed to any arbitrary
name that happens to conflict with any other name that is used in their
parent devices directory.

The device model usage of the bluetooth bnep driver has not changed since
the current device model sysfs laytout was introduced.   Making this a latent
and very annoying regression.

This regression was reported at the time it was introduced and apprently a
few cases were missed by:

commit 864062457a2e444227bd368ca5f2a2b740de604f
Author: Kay Sievers <kay.sievers@vrfy.org>
Date:   Wed Mar 14 03:25:56 2007 +0100

    driver core: fix namespace issue with devices assigned to classes

      - uses a kset in "struct class" to keep track of all directories
        belonging to this class
      - merges with the /sys/devices/virtual logic.
      - removes the namespace-dir if the last member of that class
        leaves the directory.

    There may be locking or refcounting fixes left, I stopped when it seemed
    to work with network and sound modules. :)

    From: Kay Sievers <kay.sievers@vrfy.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

That bug fix had a completely undocumented and apparently deliberate omission
where it does not apply in some cases.  Those omitted cases cover the
bluetooth network driver.

What makes this regression a serious issue now is the introduction of network
namespace support in sysfs took this from a mild bug to complete driver
non-function.

Several reasons have been put forward not to use this one line bug fix in
the driver core.

- We don't have special cases in the driver core.

  This is non-sense we currently have special cases for block devices
  scattered all throughout the driver core.

- The driver is at fault.

  The bluetooth driver's driver core usage predates the introduction of the
  current sysfs layout.  It has been 3 years and no one has bothered
  to change the driver in all of this time.

  If this was really a driver issue that someone cared about and not simply
  an academic issue the driver should have been fixed long since.

I offer these reasons to make the change.

- There is not enough information available for sysfs to support rename
  or delete of symlinks when only the source directory but not the destination
  directory is tagged.

- All of the proposals put forth will change the sysfs layout slightly in
  one way or another.

- A network device special case makes sense as network devices are unique
  in placing a user choosen name sysfs.

- The driver that are affected are different in sysfs from all other
  network devices which likely already consuses any userspace software
  that cares about the exact device layout.

- The change is one line that is obviously correct and has no chance
  of affecting anything that it is not a network device.

- Real users have hit this problem and reported this bug and those users
  deserve drivers that work.

The fix is a trivial change to get_device_parent to always create
the network class directory in any parent of a network device,
Ignoring the incorrect, non-obvious and esoteric rules that the
driver core is trying to impose on the creation of class directories.

Ideally I would remove those crazy special cases get_device_parent for all
devices but in testing it was observed there are other devices such as the
input layer that don't create the class directories today, and applying the
change broadly is likely to break something in userspace and there is no
need to take that risk.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/base/core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 9630fbd..ffb8443 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -673,7 +673,7 @@ static struct kobject *get_device_parent(struct device *dev,
 		 */
 		if (parent == NULL)
 			parent_kobj = virtual_device_parent(dev);
-		else if (parent->class)
+		else if (parent->class && (strcmp(dev->class->name, "net") != 0))
 			return &parent->kobj;
 		else
 			parent_kobj = &parent->kobj;
-- 
1.6.5.2.143.g8cc62

