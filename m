From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [RFC][PATCH] Fix another namespace issue with devices assigned to classes
Date: Wed, 02 Jun 2010 17:53:12 -0700
Message-ID: <m17hmhrl6v.fsf_-_@fess.ebiederm.org>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	<20100602154608.GB12361@kroah.com>
	<1275493693.3915.12.camel@jlt3.sipsolutions.net>
	<m1ljaxxvcj.fsf@fess.ebiederm.org>
	<1275495677.3915.16.camel@jlt3.sipsolutions.net>
	<m14ohlxu51.fsf@fess.ebiederm.org>
	<1275498007.3915.20.camel@jlt3.sipsolutions.net>
	<m1ocftwdp7.fsf@fess.ebiederm.org>
	<1275501157.3915.22.camel@jlt3.sipsolutions.net>
	<m1y6exux6x.fsf@fess.ebiederm.org>
	<1275506732.3915.41.camel@jlt3.sipsolutions.net>
	<m16321t4ke.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>,
	Kay Sievers <kay.sievers@vrfy.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58231 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932771Ab0FCAxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 20:53:22 -0400
In-Reply-To: <m16321t4ke.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Wed\, 02 Jun 2010 16\:09\:21 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In the last painful restructuring of sysfs we created started
creating class directories under normal devices so we could place
devices such as network devices directly under their the hardware
that implements them instead of in their class directories like
/sys/class/net/.  This creation of class directories avoids the
need to worry about namespace clonflicts if something is renamed.

A special exception was made for devices that were still placed
directly in their class directory.  Looking at how this interacts
with the wireless network devices it appears this special exception
is either completely unneeded or at least needs to be restricted to
a parent device with the same class as the child device.  Certainly
in the case of unrelated classes we very much have the possibility
of namespace classes and we should be creating the subdirectory.

Johannes this should fix your issue with mac80211_hwsim, where
the device symlink were not destroyed when the driver was removed.

Greg, Kay where does that parent->class check come into play?  Do
we need it at all?

> commit 864062457a2e444227bd368ca5f2a2b740de604f
> Author: Kay Sievers <kay.sievers@vrfy.org>
> Date:   Wed Mar 14 03:25:56 2007 +0100
> 
>     driver core: fix namespace issue with devices assigned to classes
>     
>       - uses a kset in "struct class" to keep track of all directories
>         belonging to this class
>       - merges with the /sys/devices/virtual logic.
>       - removes the namespace-dir if the last member of that class
>         leaves the directory.
>     
>     There may be locking or refcounting fixes left, I stopped when it seemed
>     to work with network and sound modules. :)
>     
>     From: Kay Sievers <kay.sievers@vrfy.org>
>     Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

---

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 9630fbd..3725f81 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -673,7 +673,7 @@ static struct kobject *get_device_parent(struct device *dev,
 		 */
 		if (parent == NULL)
 			parent_kobj = virtual_device_parent(dev);
-		else if (parent->class)
+		else if (parent->class == dev->class)
 			return &parent->kobj;
 		else
 			parent_kobj = &parent->kobj;
