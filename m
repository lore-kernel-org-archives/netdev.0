From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] Driver-core: Always create class directories for classses that support namespaces.
Date: Sat, 24 Jul 2010 22:43:35 -0700
Message-ID: <m1tynonmk8.fsf_-_@fess.ebiederm.org>
References: <20100719133451.0862ca62.akpm@linux-foundation.org>
	<20100720201334.GA11991@suse.de> <m139vd5sms.fsf_-_@fess.ebiederm.org>
	<m1zkxj27xp.fsf_-_@fess.ebiederm.org>
	<AANLkTimM5Ea8mQ7aX4kDq3dgF3P-t2Wm3dERhckC69Ja@mail.gmail.com>
	<m1vd87toy9.fsf@fess.ebiederm.org>
	<AANLkTil3Q1Vobw48AvStl9gphaJcyUGlt6ZnMLanDMVn@mail.gmail.com>
	<1279822828.12439.24.camel@jlt3.sipsolutions.net>
	<20100722182827.GA12821@suse.de>
	<1279823801.12439.31.camel@jlt3.sipsolutions.net>
	<20100722185449.GB528@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg KH <greg@kroah.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>,
	"<linux-kernel@vger.kernel.org> Marcel Holtmann"
	<marcel@holtmann.org>, linux-bluetooth@vger.kernel.org,
	Greg KH <gregkh@suse.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:45942 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551Ab0GYFoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jul 2010 01:44:05 -0400
In-Reply-To: <20100722185449.GB528@suse.de> (Greg KH's message of "Thu\, 22 Jul 2010 11\:54\:49 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This fixes the regression in 2.6.35-rcX where bluetooth network devices would
fail to be deleted from sysfs, causing their destruction and recreation to
fail.  In addition this fixes the mac80211_hwsim driver where it would leave
around sysfs files when the driver was removed.  This problem is discussed at
https://bugzilla.kernel.org/show_bug.cgi?id=16257

The reason for the regression is that the network namespace support added to
sysfs expects and requires that network devices be put in directories that can
contain only network devices.  Today get_device_parent almost provides that
guarantee for all class devices, except for a specific exception when the
parent of a class devices is a class device.  It would be nice to simply
remove that arguably incorrect special case, but apparently the input devices
depend on it being there.  So I have only removed it for class devices with
network namespace support.  Which today are the network devices.

It has been suggested that a better fix would be to change the parent device
from a class device to a bus device, which in the case of the bluetooth driver
would change /sys/class/bluetooth to /sys/bus/bluetoth, I can not see how we
would avoid significant userspace breakage if we were to make that change.

Adding an extra directory in the path to the device will also be userspace
visible but it is much less likely to break things.  Everything is still
accessible from /sys/class (for example), and it fixes two bugs.  Adding an
extra directory fixes a 3 year old regression introduced with the new sysfs
layout that makes if impossible to rename bnep0 network devices to names that
conflict with hci device attributes like hci_revsion.  Adding an additional
directory remove the new failure modes introduced by the network namespace
code.

If it weren't for the regession in the renaming of network devices I would
figure out how to just make the sysfs code deal with this configuration of
devices.

In summary this patch fixes regressions by changing:
"/sys/class/bluetooth/hci0/bnep0" to "/sys/class/bluetooth/hci0/net/bnep0".

Reported-by: Johannes Berg <johannes@sipsolutions.net>
Reported-by: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---

p.s. Linus my apologies for sending this directly but I have gotten an
incredible amount of flak trying to fix this problem, and I would like
not to leave an accidental regression whose cause is well known in
2.6.35 if I can help it.

 drivers/base/core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 9630fbd..9b9d3bd 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -673,7 +673,7 @@ static struct kobject *get_device_parent(struct device *dev,
 		 */
 		if (parent == NULL)
 			parent_kobj = virtual_device_parent(dev);
-		else if (parent->class)
+		else if (parent->class && !dev->class->ns_type)
 			return &parent->kobj;
 		else
 			parent_kobj = &parent->kobj;
-- 
1.6.5.2.143.g8cc62

