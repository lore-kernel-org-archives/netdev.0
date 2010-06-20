From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] Driver-core: Always create network class directories in get_device_parent.
Date: Sun, 20 Jun 2010 05:46:54 -0700
Message-ID: <m1ocf5hnwh.fsf_-_@fess.ebiederm.org>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	<1275998127.1899.38.camel@yio.site>
	<1275998603.3706.118.camel@jlt3.sipsolutions.net>
	<AANLkTinev96yxFCFSdDdT89jjgYR4ChUCMU2-aSj8kkh@mail.gmail.com>
	<1276005970.3706.132.camel@jlt3.sipsolutions.net>
	<AANLkTikB0Amzi61JLxdY5HL-2s_nbYo3JH8vXooXzHdQ@mail.gmail.com>
	<1276007174.3706.133.camel@jlt3.sipsolutions.net>
	<AANLkTikNEzJHPrOUK6DKMoWvcblTBInaIhVbk96OtZxe@mail.gmail.com>
	<1276009590.3706.135.camel@jlt3.sipsolutions.net>
	<AANLkTimSqF4D4jPj-HzOjl1vxjf2T7YvlGdR6zcJZ9Pp@mail.gmail.com>
	<1276014816.3706.137.camel@jlt3.sipsolutions.net>
	<AANLkTilUd2Bp1h4SzlW5f5KevoRM-os_fQrivLHbZyKY@mail.gmail.com>
	<1276250151.3640.11.camel@jlt3.sipsolutions.net>
	<AANLkTil4IvOiDHnLwAaeseEPVgYp-EF5TK1HfHitY3-H@mail.gmail.com>
	<1276507247.3926.13.camel@jlt3.sipsolutions.net>
	<bug-16215-7251@https.bugzilla.kernel.org/>
	<AANLkTin2sci1gSmwx-tjazYGFAcUNRKhJFI7Bt0KvVe3@mail.gmail.com>
	<m139wiuswa.fsf_-_@fess.ebiederm.org>
	<AANLkTilVHF0dITpB3yJYaCnGPonhdl7NWnb-P12RAFTs@mail.gmail.com>
	<1277033628.3642.1.camel@jlt3.sipsolutions.net>
	<AANLkTikZAKZA9mfb7RjaqNFnX8gCM3A9PTfH350botL8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>,
	Kay Sievers <kay.sievers@vrfy.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:47402 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753441Ab0FTMrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jun 2010 08:47:01 -0400
In-Reply-To: <AANLkTikZAKZA9mfb7RjaqNFnX8gCM3A9PTfH350botL8@mail.gmail.com> (Kay Sievers's message of "Sun\, 20 Jun 2010 13\:46\:20 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In get_device_parent there was added check to not add a class
directory when a class device was put under another class device.  The
check was put in place as a just in case measure to not break old
userspace if any existing code happened to depend on it.  Devices in
the input subsystem are affected by this code path so there is a
reasonable chance that some piece of user space will break if we just
remove this kludge.

At the same time there are at least two network drivers that have
potential unnecessary namespace conflicts because class directories
have not been created for their network devices.

With the introduction of tagged sysfs directories for properly
handling network namespace support this omission in creating the class
directories went from a bad thing in terms of namespace pollution, to
actually breaking device_remove.

Currently there are two reported network device drivers that break
because the class directory was not created by the device layer.  The
usb bnep driver and the mac80211_hwsim driver.

Every solution proposed changes the sysfs layout for the affected
devices, and thus has the potential to break userspace.

Since we are changing the sysfs layout anyway, and since we are now
talking about several devices all with the same problem, all caused by
the same over convservative bit of code.  Let's fix the device layer
for network devices.

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

