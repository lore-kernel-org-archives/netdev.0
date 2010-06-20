From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] Driver-core: Always create class directories fixing the broken network drivers.
Date: Sat, 19 Jun 2010 23:20:37 -0700
Message-ID: <m139wiuswa.fsf_-_@fess.ebiederm.org>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	<1275914205.29978.10.camel@jlt3.sipsolutions.net>
	<AANLkTilqB2sAyfBTLhYT_a2_TySGay4FFG6SGJUZ1o_4@mail.gmail.com>
	<1275989260.3706.115.camel@jlt3.sipsolutions.net>
	<AANLkTinMauFsJTKS3eT-pT44KQ8PSf3HJLS8CZIeHmxP@mail.gmail.com>
	<1275990325.3706.116.camel@jlt3.sipsolutions.net>
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
	<AANLkTin2sci1gSmwx-tjazYGFAcUNRKhJFI7Bt0KvVe3@mail.gmail.com>
        <bug-16215-7251@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>,
	Kay Sievers <kay.sievers@vrfy.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47610 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339Ab0FTGUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jun 2010 02:20:43 -0400
In-Reply-To: <AANLkTin2sci1gSmwx-tjazYGFAcUNRKhJFI7Bt0KvVe3@mail.gmail.com> (Kay Sievers's message of "Mon\, 14 Jun 2010 11\:39\:11 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In get_device_parent there is a check to not add a class directory
when a class device was put under another class device.  The check was
put in place as a just in case measure to not break old userspace if
any existing code happened to depend on it.  Currently the only known
way that we get a class device under a class device is due to the
rearrangement of devices that happened when the new sysfs layout was
introduced.

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
the same over conservative bit of code.  Let's kill that bit of code.

There have been other proposals to fix this but they all have been
more complicated, and none of them have actually resulted in working
code.

Any userspace that works with both the old and the new sysfs layouts
should not be affected by this change, and even if someone depends
on it we are talking a very small number of drivers overall that
are affected.

My apologoies for not fully catching this hole in the logic the
when this code was originally added.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/base/core.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 9630fbd..7b1c4d4 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -673,8 +673,6 @@ static struct kobject *get_device_parent(struct device *dev,
 		 */
 		if (parent == NULL)
 			parent_kobj = virtual_device_parent(dev);
-		else if (parent->class)
-			return &parent->kobj;
 		else
 			parent_kobj = &parent->kobj;
 
-- 
1.6.5.2.143.g8cc62

