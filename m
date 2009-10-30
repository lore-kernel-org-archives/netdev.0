From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Fri, 30 Oct 2009 16:25:52 -0700
Message-ID: <m1my38lb0f.fsf@fess.ebiederm.org>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com>
	<20091018182144.GC23395@kvack.org>
	<200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com>
	<20091021165139.GL877@kvack.org> <m1d445yf2x.fsf@fess.ebiederm.org>
	<20091029233848.GV3141@kvack.org> <m1vdhxu01v.fsf@fess.ebiederm.org>
	<20091030143527.GA3141@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:47249 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933028AbZJ3XZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 19:25:53 -0400
In-Reply-To: <20091030143527.GA3141@kvack.org> (Benjamin LaHaise's message of "Fri\, 30 Oct 2009 10\:35\:27 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise <bcrl@lhnet.ca> writes:

> On Thu, Oct 29, 2009 at 06:45:32PM -0700, Eric W. Biederman wrote:
>> The reason for the existence of sysfs_dirent is as things grow larger
>> we want to keep the amount of RAM consumed down.  So we don't pin
>> everything in the dcache.  So we try and keep the amount of memory
>> consumed down.
>
> I'm aware of that, but for users running into this sort of scaling issue, 
> the amount of RAM required is a non-issue (30,000 interfaces require about 
> 1GB of RAM at present), making the question more one of how to avoid the 
> overhead for users who don't require it.  I'd prefer a config option.  The 
> only way I can really see saving memory usage is to somehow tie sysfs dirent 
> lookups into the network stack's own tables for looking up device entries.  
> The network stack already has to cope with this kind of scaling, and that 
> would save the RAM.

There is that.  I'm trying to figure out how to add the improvements
without making sysfs_dirent larger.  Which I think that is doable.

>> So I would like to see how much we can par down.
>
>> For dealing with seeks in the middle of readdir I expect the best way
>> to do that is to be inspired by htrees in extNfs and return a hash of
>> the filename as our position, and keep the filename list sorted by
>> that hash.  Since we are optimizing for size we don't need to store
>> that hash.  Then we can turn that list into a some flavor of sorted
>> binary tree.
>
> readdir() generally isn't an issue at present.

Supporting seekdir into the middle of a directory is the entire reason
I keep the entries sorted by inode.  If we sort by a hash of the name.
We can use the hash to support directory position in readdir and seekdir.
And we can completely remove the linear list when the rb_tree is introduced.

>> I'm surprised sysfs_count_nlink shows up, as it is not directly on the
>> add or remove path.  I think the answer there is to change s_flags
>> into a set of bitfields and make link_count one of them, perhaps
>> 16bits long.  If we ever overflow our bitfield we can just set link
>> count to 0, and userspace (aka find) will know it can't optimized
>> based on link count.
>
> It shows up because of the bits of userspace (udev) touching the directory 
> from things like the hotplug code path.

I realized after sending the message that s_mode in sysfs_dirent is a
real size offense.  It is a 16bit field packed in between two longs.
So in practice it is possible to move the s_mode  up next to s_flags
and add a s_nlink after it both unsigned short and get a cheap sysfs_nlink.

>> I was expecting someone to run into problems with the linear directory
>> of sysfs someday.
>
> Alas, sysfs isn't the only offender.

Agreed. Sysfs is probably the easiest to untangle.

Since I'm not quite ready to post my patches.  I will briefly
mention what I have in my queue and hopefully get things posted.

I have changes to make it so that sysfs never has to go from
the sysfs_dirent to the sysfs inode.  

I have changes to sys_sysctl() so that it becomes a filesystem lookup
under /proc/sys.  Which ultimately makes the code easier to maintain
and debug.

Now back to getting things forward ported and ready to post.

Eric
