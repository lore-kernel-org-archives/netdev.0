From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 3/6] sysfs: Implement sysfs tagged directory support.
Date: Tue, 30 Mar 2010 21:23:54 -0700
Message-ID: <m1eij1rued.fsf@fess.ebiederm.org>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
	<1269973889-25260-3-git-send-email-ebiederm@xmission.com>
	<20100331024346.GB27001@us.ibm.com> <m1zl1prwie.fsf@fess.ebiederm.org>
	<20100331040234.GA7184@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:54875 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896Ab0CaEYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 00:24:19 -0400
In-Reply-To: <20100331040234.GA7184@us.ibm.com> (Serge E. Hallyn's message of "Tue\, 30 Mar 2010 23\:02\:34 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Serge E. Hallyn" <serue@us.ibm.com> writes:

>> > This is a huge patch, and for the most part I haven't found any problems,
>> > except potentially this one.  It looks like sysfs_rename_link() checks
>> > old_ns and new_ns before calling sysfs_rename().  But sysfs_mutex isn't
>> > taken until sysfs_rename().  sysfs_rename() will then proceed to do
>> > the rename, and unconditionally set sd->ns = new_ns.
>> >
>> > In the meantime, it seems as though new_ns might have exited, and
>> > sysfs_exit_ns() unset new_ns on the new parent dir.  This means that
>> > we'll end up with the namespace code having thought that it cleared
>> > all new_ns's, but this file will have snuck by.  Meaning an action on
>> > the renamed file might dereference a freed namespace.
>> >
>> > Or am I way off base?
>> 
>> There are a couple of reasons why this is not a concern.
>> 
>> The only new_ns we clear is on the super block.
>
> Oops, yeah - I failed to note that.
>
>> sysfs itself never dereferences namespace arguments and only uses them
>> for comparison purposes.  They are just cookies that cause comparisons
>> to differ from a sysfs perspective.
>> 
>> The upper levels are responsible for taking care of them selves
>> sysfs_mutex does not protect them.  If you compile out sysfs the sysfs
>> mutex is not even present.
>> 
>> In the worst case if the upper levels mess up we will have a stale
>> token that we never dereference on a sysfs dirent, which in a pathological
>> case will happen to be the same as a new namespace and we will have
>> a spurious directory entry that we have leaked.
>> 
>> In practice we move all network devices (and thus sysfs files) out of
>> a network namespace before allowing it to exit.
>
> Ok, that makes sense too - so any tagged sysfs file created for some object
> in a ns must be deleted at netns exit.  I could imagine someone expecting
> that if the ns exits, the tasks in the ns will exit, causing the sysfs
> mount to be umounted and auto-deleting the files?  (which of course would
> get buggered if task in other ns was examining the mount which it got
> through mounts propagation)  We'll have to make sure noone does that.  Should
> it be documented somewhere, or is that obvious enough?

In general it is simply true.  An object in a namespace either keeps
the namespace alive, or it is destroyed when the namespace exits
because the object is unreachable.

So the only possible problem I can think of is of ordering the object
destruction and calling sysfs_exit_ns.    So for the moment I am going
to vote that this is simply obvious enough not to worry about in detail.

It is also pretty obvious if you trace the code and ask how does sysfs
dirent X get destroyed.

Today there is just a wee bit of automatic file destruction at the sysfs
level.    The device layer does not take advantage of it, and in hierarchical
situation it leads to bugs.  So even I think if we document anything it
should be that sysfs can not safely automatically delete anything, for
you.

Eric
