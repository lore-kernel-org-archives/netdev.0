From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] netns: add /proc/*/net/id symlink
Date: Sat, 21 May 2011 17:15:38 -0700
Message-ID: <m1vcx3r3o5.fsf@fess.ebiederm.org>
References: <20110521093936.GA3015@p183> <m11uzsxdty.fsf@fess.ebiederm.org>
	<20110521223054.GA3198@p183>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, equinox@diac24.net,
	Linux Containers <containers@lists.osdl.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57546 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898Ab1EVAPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2011 20:15:45 -0400
In-Reply-To: <20110521223054.GA3198@p183> (Alexey Dobriyan's message of "Sun,
	22 May 2011 01:30:54 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Adding the containers list.

Alexey Dobriyan <adobriyan@gmail.com> writes:

> On Sat, May 21, 2011 at 08:39:37AM -0700, Eric W. Biederman wrote:
>> Alexey Dobriyan <adobriyan@gmail.com> writes:
>> > * init_net always has id 0
>> > * two netns do not have same id
>> > * id is unsigned integer
>> 
>> I don't like this patch because we already have a proc interface
>> that already solves this in production kernels today.
>> 
>> - stat is a single syscall
>> - two netns do not have the same id
>> - id is an ino_t.
>
> Yeah, stat /proc/*/net/dev works.
> If you document this, it means we can't change the way ->low_ino is set.
> And we can't do other things inside irregular part of procfs.

Maybe.  Certainly there are things that would suggest we need some
fixes to this part of procfs.

> But can we add clean interface once in a while.

I am all for making a clean solution.  I don't see a proc file
in in /proc/net that provides a small integer as particularly clean.

It has the classic problem of what namespace are namespaces named in.
It only solves the problem for the network namespace.

So on that level I really like the idea of inode numbers in proc
being the place where we have a name.  People generally don't get
confused about inode numbers understanding they are an implementation
detail but they do understand that inode numbers plus filesystem
information can be used to compare files for identity.

So let's skip the fact that /proc/*/net/dev happens to work for a
moment.

For clean interfaces I am in the process of adding /proc/<pid>/ns/net,
/proc/<pid>/ns/ipc, and /proc/<pid>/ns/uts.

If we can make those files inode number be the same if the namespace is
the same like /proc/<pid>/net/dev is today.  I think we will have a
clean solution.

Additionally that solution will work for comparing network namespaces
that don't happen to have any processes in them at the moment.  Because
fstat works on file descriptors.

With the /proc/<pid>/ns/net file and bind mounts I have solved the
deeper problem of how do we get userspace policy into the naming of
namespaces.  With those files and the setns system call I have solved
the other problem of what is a good way to refer to namespaces without
assuming a global name.  So once those changes are merged I expect there
to be much less pressure to misuse any kind of identifier we can have.

And if we only make the guarantee about inode consistency for the
/proc/<pid>/ns/FILE files I don't expect it will make maintenance
of procfs any harder than it already is.

Eric

