From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] netns: add /proc/*/net/id symlink
Date: Sat, 21 May 2011 08:39:37 -0700
Message-ID: <m11uzsxdty.fsf@fess.ebiederm.org>
References: <20110521093936.GA3015@p183>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, equinox@diac24.net
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:52416 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755511Ab1EUPjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2011 11:39:44 -0400
In-Reply-To: <20110521093936.GA3015@p183> (Alexey Dobriyan's message of "Sat,
	21 May 2011 12:39:36 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan <adobriyan@gmail.com> writes:

> David Lamparter pointed some real scenarios where knowing
> if two processes live in same netns is important,
> like "how do I kill _all_ processes in netns to shutdown it".

Currently today the way I do this is md5sum /proc/<pid>/mounts.

That works because it is usually necessary to have a separate mount
namespace with a separate set of mounts to accommodate sysfs.

> Currently only kernel knows if two netns are the same.
> Userspace maybe can look at different proc files to find a match
> indirectly sysconf-style but result will be ugly no matter what.

Somewhat. 

Right now today without patches if we limit ourselves to the network
namespace there is a pretty valid way to do this.

stat /proc/<pid>/net/dev and compare the inode numbers.

Or any other file in /proc/*/net/.  The inode numbers are the
same if you are in the same network namespace.

> Add /proc/*/net/id symlink which "points" to an integer.
>
> 	$ readlink /proc/net/id
> 	0
>
> 	$ readlink /proc/2941/net/id
> 	1
>
> "id" is not a file because 1 syscall is faster than 3 syscalls.
>
> The only rules and expectations for userspace are:
> [as if they will comply, ha-ha]
>
> * init_net always has id 0
> * two netns do not have same id
> * id is unsigned integer

I don't like this patch because we already have a proc interface
that already solves this in production kernels today.

- stat is a single syscall
- two netns do not have the same id
- id is an ino_t.

Now it probably needs to be better documented that /proc/*/net/*
have the same inode number if the network namespace is the
same, as everyone including myself overlooked this very handy
existing property.




Writing this it occurs to me there is a misfeature in my pending
namespace file descriptor code.  Right now /proc/<pid>/ns/net
has a floating inode number and it would be good if I could make
that a inode number be the same for every file that refers to
the same network namespace. Ugh.

Eric

