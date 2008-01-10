From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PROCFS] [NETNS] issue with /proc/net entries
Date: Thu, 10 Jan 2008 12:55:32 -0700
Message-ID: <m1ir21v4jv.fsf@ebiederm.dsl.xmission.com>
References: <478654E1.5050501@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:56356 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754030AbYAJT4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 14:56:22 -0500
In-Reply-To: <478654E1.5050501@bull.net> (Benjamin Thery's message of "Thu, 10
	Jan 2008 18:24:49 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Thery <benjamin.thery@bull.net> writes:

> Hi Eric,
>
> While testing the current network namespace stuff merged in net-2.6.25,
> I bumped into the following problem with the /proc/net/ entries.
> It doesn't always display the actual data of the current namespace,
> but sometime displays data from other namespaces.
>
> I bisected the problem to the commit:
> "proc: remove/Fix proc generic d_revalidate"
> 3790ee4bd86396558eedd86faac1052cb782e4e1
>
> The problem: If a process in a particular network namespace changes
> current directory to /proc/net, then processes in other network
> namespaces trying to look at /proc/net entries will see data from the
> first namespace (the one with CWD /proc/net). (See test case below).
>
> As you comments in the commit suggest, you seem to be aware of some
> issues when CONFIG_NET_NS=y. Is it one of these corner cases you
> identified? Any idea on how we can fix it?

Yes.  It isn't especially hard.   I have most of it in my queue
I just need to get the silly patches out of there.

Essentially we need to fix the caching of proc_generic entries,
So that we can have a proper d_revalidate implementation.

To get d_revalidate and the caching correct for /proc/net will take
just a bit more work.  We need to make /proc/net a symlink
to something like /proc/self/net so that we don't get excess
revalidates when switching between different processes.

Or else we can't properly implement the case you have described.
Where being in the directory causes the wrong version of /proc/net
to show up. Changing the contents of the dentry for /proc/net
should only happen during unshare.  Not when we switch between
processes or else we get into the d_revalidate leaks mount points
problem again.

We also need the check to see if something is mounted on top of
us before we call drop the dentry.  But if we don't even try until
we know the dentry is invalid it should not be too bad.

Eric
