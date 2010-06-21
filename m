From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Bugme-new] [Bug 16257] New: sysfs changes break hwsim and bnep drivers
Date: Mon, 21 Jun 2010 15:22:32 -0700
Message-ID: <m1mxuodo0n.fsf@fess.ebiederm.org>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
	<20100621150826.762ac9f2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:40059 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752919Ab0FUWWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 18:22:45 -0400
In-Reply-To: <20100621150826.762ac9f2.akpm@linux-foundation.org> (Andrew Morton's message of "Mon\, 21 Jun 2010 15\:08\:26 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Sun, 20 Jun 2010 11:23:02 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=16257
>
> Said to be a post-2.6.34 regression caused by the net namespaces changes.
>
> There's a massive thread there and I didn't work out whether it's
> already been fixed?

The fix is pending.

The cause is understood.  Roughly we started caring about something
being true in all cases and there are bugs where it is not.

The patch below is less pretty than I would like, but it is trivial
and it fixes the problem in all cases, and in exactly the cases that
are broken today.

I have received no feedback since I posted it.  Right now there are no
viable alternatives on the table for the 2.6.35 timeframe.  The only
suggested alternatives is to rewrite the affected drivers sysfs
support and fix the driver core so that rewrite is actually possible.

>From ada3a8448d376000e8cf586f0e4062e2f578c80f Mon Sep 17 00:00:00 2001
From: Eric W. Biederman <ebiederm@xmission.com>
Date: Sat, 19 Jun 2010 22:58:39 -0700
Subject: [PATCH] Driver-core: Always create network class directories in get_device_parent.

In get_device_parent there was added check to not add a class
directory when a class device was put under another class device.
The check was put in place as a just in case measure to not break
old userspace if any existing code happened to depend on it.
Devices in the input subsystem are affected by this code path so
there is a reasonable chance that some piece of user space will
break if we just remove this cludge.

At the same time there are at least two network drivers that
have potential unnecessary namespace conflicts because class
directories have not been created for their network devices.

With the introduction of tagged sysfs directories for properly
handling network namespace support this omission in creating
the class directories went from a bad thing in terms of namespace
pollution, to actually breaking device_remove.

Currently there are two reported network device drivers that
break because the class directory was not created by the device
layer.  The usb bnep driver and the mac80211_hwsim driver.

Every solution proposed changes the sysfs layout for the affected
devices, and thus has the potential to break userspace.

Since we are changing the sysfs layout anyway, and since we are now
talking about several devices all with the same problem, all caused
by the same over convservative bit of code.  Let's fix the device
layer for network devices.

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


