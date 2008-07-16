From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 12/15] driver core: Implement tagged directory support for device classes.
Date: Wed, 16 Jul 2008 14:09:55 -0700
Message-ID: <m1ej5t1qos.fsf@frodo.ebiederm.org>
References: <m18wwiihbn.fsf_-_@frodo.ebiederm.org>
	<m14p76ih9a.fsf_-_@frodo.ebiederm.org>
	<m1zloyh2mb.fsf_-_@frodo.ebiederm.org>
	<m1vdzmh2jr.fsf_-_@frodo.ebiederm.org>
	<m1r6aah2hh.fsf_-_@frodo.ebiederm.org>
	<m1mykyh2fu.fsf_-_@frodo.ebiederm.org>
	<m1hcb6h2d2.fsf_-_@frodo.ebiederm.org> <486DD650.3000804@gmail.com>
	<m1tzf593ny.fsf@frodo.ebiederm.org> <486E2C3B.6020603@gmail.com>
	<20080704161200.GA1440@suse.de> <m1lk052ptp.fsf@frodo.ebiederm.org>
	<487D6A24.9070001@gmail.com> <m17ibmbd39.fsf@frodo.ebiederm.org>
	<487D8C0A.9060100@gmail.com> <m11w1u9w5j.fsf@frodo.ebiederm.org>
	<487D99C7.708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	netdev@vger.kernel.org
To: Tejun Heo <htejun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:52001 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757605AbYGPVMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 17:12:25 -0400
In-Reply-To: <487D99C7.708@gmail.com> (Tejun Heo's message of "Wed, 16 Jul
	2008 15:48:39 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tejun Heo <htejun@gmail.com> writes:
>> To do that I believe we would need to ensure sysfs does not use 
>> the inode->i_mutex lock except to keep the VFS layer out.  Allowing us
>> to safely change the directory structure, without holding it.
>
> I don't think sysfs is depending on i_mutex anymore but I need to go
> through the code to make sure.

The vfs still does. So at least for directory tree manipulation  we
need to hold i_mutex before we grab sysfs_mutex.

I think that means we need to unscramble the whole set of locking
order issues.

In lookup we have:
local_vfs_lock -> fs_global_lock

In modifications we have:
fs_global_lock -> local_vfs_lock

Which is the definition of a lock ordering problem.

Currently we play jump through some significant hoops to keep things
in local_vfs_lock -> fs_global_lock order.

If we also take the rename_mutex on directory adds and deletes we
may be able to keep jumping through those hoops.  However I expect
we would be in a much better situation if we could figure out how
to avoid the problem.

It looks like the easy way to handle this is to make the sysfs_dirent
list rcu protected.  Which means we can fix our lock ordering problem
without VFS modifications.  Allowing the locking to always
be: sysfs_mutex ... i_mutex.

After that it would be safe and a good idea to have unshared
inodes between superblocks, just so we don't surprise anyone
making generic VFS assumptions.

Eric
