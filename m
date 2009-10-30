From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Thu, 29 Oct 2009 18:45:32 -0700
Message-ID: <m1vdhxu01v.fsf@fess.ebiederm.org>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com>
	<20091018182144.GC23395@kvack.org>
	<200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com>
	<20091021165139.GL877@kvack.org> <m1d445yf2x.fsf@fess.ebiederm.org>
	<20091029233848.GV3141@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52891 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbZJ3Bpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 21:45:35 -0400
In-Reply-To: <20091029233848.GV3141@kvack.org> (Benjamin LaHaise's message of "Thu\, 29 Oct 2009 19\:38\:48 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise <bcrl@lhnet.ca> writes:

> On Thu, Oct 29, 2009 at 04:07:18PM -0700, Eric W. Biederman wrote:
>> Could you keep me in the loop with that.  I have some pending cleanups for
>> all of those pieces of code and may be able to help/advice/review.
>
> Here are the sysfs scaling improvements.  I have to break them up, as there 
> are 3 separate changes in this patch: 1. use an rbtree for name lookup in 
> sysfs, 2. keep track of the number of directories for the purpose of 
> generating the link count, as otherwise too much cpu time is spent in 
> sysfs_count_nlink when new entries are added, and 3. when adding a new 
> sysfs_dirent, walk the list backwards when linking it in, as higher 
> numbered inodes tend to be at the end of the list, not the beginning.

The reason for the existence of sysfs_dirent is as things grow larger
we want to keep the amount of RAM consumed down.  So we don't pin
everything in the dcache.  So we try and keep the amount of memory
consumed down.

So I would like to see how much we can par down.

For dealing with seeks in the middle of readdir I expect the best way
to do that is to be inspired by htrees in extNfs and return a hash of
the filename as our position, and keep the filename list sorted by
that hash.  Since we are optimizing for size we don't need to store
that hash.  Then we can turn that list into a some flavor of sorted
binary tree.

I'm surprised sysfs_count_nlink shows up, as it is not directly on the
add or remove path.  I think the answer there is to change s_flags
into a set of bitfields and make link_count one of them, perhaps
16bits long.  If we ever overflow our bitfield we can just set link
count to 0, and userspace (aka find) will know it can't optimized
based on link count.

I was expecting someone to run into problems with the linear directory
of sysfs someday.

Eric

