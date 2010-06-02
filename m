From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: sysfs class/net/ problem
Date: Wed, 02 Jun 2010 16:09:21 -0700
Message-ID: <m16321t4ke.fsf@fess.ebiederm.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:48781 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811Ab0FBXJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 19:09:28 -0400
In-Reply-To: <1275506732.3915.41.camel@jlt3.sipsolutions.net> (Johannes Berg's message of "Wed\, 02 Jun 2010 21\:25\:32 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> writes:

> On Wed, 2010-06-02 at 11:05 -0700, Eric W. Biederman wrote:
>
>> My current hypothesis is something is causing us to try and delete
>> the symlink from the wrong namespace, so we just skip that part of it.
>
> Hmm... ok:
>
> [   70.338274] create link wlan2 ns=(null)

Inside of sysfs_do_create_link we compute sd->s_ns just before
sysfs_addrm_start.

With this sequence:
if (sysfs_ns_type(parent_sd))
		sd->s_ns = target->ktype->namespace(target);

> ...
> [   71.881775] delete link wlan2 ns=(null)
> [   71.881777] hash_and_remove ffff88001f9563c0, (null), wlan2
> [   71.881782] sd=ffff88001ce2d9c0, sdns=ffffffff8271c260
>
> and thus we skip sysfs_remove_one() in sysfs_hash_and_remove() because
> sysfs_find_dirent() return an sd with a different ns than we passed in.
> Why is the ns we pass in NULL, shouldn't it be init_ns?

NULL is what is used in the case where something is not bound to a
namespace (most of sysfs).  It should be init_ns.

If we have a NULL ns in sysfs_delete_link than I expect targ->sd == NULL.
As targ->sd->s_ns should equal init_ns.

So now I just need to figure out if targ->sd is NULL in delete link is
NULL in which case we have an ordering issue or if targ->sd->s_ns is NULL
in which case I have something confused with the network namespaces.

Looking at your report:
# ls -l /sys/class/net/
total 0
lrwxrwxrwx 1 root root 0 Jun  2 13:12 eth0 -> ../../devices/pci0000:00/0000:00:03.0/net/eth0
lrwxrwxrwx 1 root root 0 Jun  2 13:12 lo -> ../../devices/virtual/net/lo
lrwxrwxrwx 1 root root 0 Jun  2 13:14 wlan0 -> ../../devices/virtual/mac80211_hwsim/hwsim0/wlan0
lrwxrwxrwx 1 root root 0 Jun  2 13:14 wlan1 -> ../../devices/virtual/mac80211_hwsim/hwsim1/wlan1
lrwxrwxrwx 1 root root 0 Jun  2 13:14 wlan2 -> ../../devices/virtual/mac80211_hwsim/hwsim2/wlan2

It appears that devices/virtual/mac80211_hwsim/hwsim0/wlan0 is not a
normal network device.  The symlink does not point into a net
directory.  Which is done with the normal network devices to ensure
they don't have conflicting names with anything else.

Are your network devices not members of net_class (defined in
net/core/net-sysfs.c)?  There is some odd class_create magic going on
in init_mac80211_hwsim.

Let's see.

netdev_register_kobject unconditionally sets dev->class = &net_class.

device_add calls setup_parent which calls get_device_parent.
get_device_parent calls virtual_device_parent if no parent is present,
or it the parent does not have a class it creates a net directory.

So we are in the case where the parent directory has a class, which I did
not realize was there. Ugh.  Does this matter?

Let's see.

In sysfs_create_link if the parent sysfs_dirent has a namespace type I
assume that the kobject target of the symlink will have a ktype that
returns the namespace the dirent should be in.  Since the target kobject
is a normal network device that assumption is fulfilled.

In sysfs_delete_link I assume that the target kobject dirent has a useful
sd->s_ns, which it will if you are in a class_net subdirectory but hwsim0
seems to be something else.  So the target of the sysfs_dirent does not
appear to meet these requirements, because the target directory is not
name-spacified.

This appears to be specific to the mac80211_hwsim driver I don't think it even
affects other wireless drivers.

What I don't see at the moment is how we get
devices/virtual/mac80211_hwsim/hwsim0/ as our parent directory for
network devices.

Johannes any clues?

If I have read this right this is a bug that only affects mac80211_hwsim because
it does magic creating it's own devices and classes, which ordinary drivers don't
do.

Eric

