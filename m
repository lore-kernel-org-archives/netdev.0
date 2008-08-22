From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [git pull] VFS patches, the first series
Date: Thu, 21 Aug 2008 17:08:25 -0700
Message-ID: <m1iqttnc7a.fsf@frodo.ebiederm.org>
References: <20080727012212.GW28946@ZenIV.linux.org.uk>
	<m1d4k2zui4.fsf@frodo.ebiederm.org>
	<m1od3mthma.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, <netdev@vger.kernel.org>,
	"Denis V. Lunev" <den@openvz.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:51354 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826AbYHVAOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 20:14:01 -0400
In-Reply-To: <m1od3mthma.fsf@frodo.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 21 Aug 2008 10:14:53 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ebiederm@xmission.com (Eric W. Biederman) writes:

> ebiederm@xmission.com (Eric W. Biederman) writes:
>
>> Al Viro <viro@ZenIV.linux.org.uk> writes:
>>
>>> The first part of huge pile.  Mostly it's untangling nameidata handling,
>>> digging towards the pieces that kill intents and cleaning pathname
>>> resolution in general.  ->permission() sanitizing and sysctl procfs
>>> treatment rewrite needed for it.  A bunch of descriptor handling fixes.
>>> Plus part of assorted patched from the last cycle sent by other folks.
>>> A _lot_ more is still pending; this is what I'd managed to pull into
>>> a series by this point.  Please, pull from
>>> git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6.git/ for-linus
>>
>> Al a quick heads up.  In testing movement of network devices between
>> namespaces  I hit the recently added WARN_ON in unregister_sysctl_table.
>
> It seems to be some new oddness when destroying a network namespace.
>
> If I don't have network devices to push out of the network namespace
> when I clean it up nothing happens.  When I do I get this nice beautiful
> backtrace.
>
> I will dig into the sysctl code in a bit and see if I can understand
> why this is happening.

Ok.  The situation is now clear.

/proc/sys/net/ipv4/neigh/default does not currently exist in network
namespaces.    This looks like an oversight.

In my network namespace I have the interfaces lo, sit, veth0

We have the result that /proc/sys/net/ipv4/neigh/veth0 has /proc/sys/net/ipv4/neigh/lo.

lo gets unregistered before veth0 when we bring the network namespaces down.
Then when veth gets unregistered we have a problem.

I'm not certain what to do about it.  The semantics of the how the
sysctl tables are access have changed significantly.  Now the first 
sysctl table to describe a directory must remain until there are no
other tables that have entries in that directory and a sysctl table
must have a pure path of directories for any portion of the address
space it shares with an earlier sysctl table.  This is noticeably
different from the union mount semantics we have had previously for
the sysctl tables.

If it doesn't look to bad to maintain the new semantics it looks like
the right thing to do is to add some additional checks so we get more
precise warnings (who knows what out of tree sysctl code will do) and
to find someplace I can insert a net/ipv4/neigh sysctl directory into
(ipv4_net_table looks like it will work) to keep the network namespace
code working safely.

Al btw nice trick using compare to keep the dentries separate allowing
us to cache everything in /proc.  I feel silly for missing that one.
Want to get together in the next couple of weeks and build a tree that
updates the sysctls infrastructure to suck less?

Eric

> ------------[ cut here ]------------
> WARNING: at /home/eric/projects/linux/linux-2.6-arastra-ns/kernel/sysctl.c:1929
> unregister_sysctl_table+0xb5/0x
> e5()
> Modules linked in:
> Pid: 22, comm: netns Tainted: G        W 2.6.27-rc3x86_64 #48
>
> Call Trace:
>  [<ffffffff802361da>] warn_on_slowpath+0x51/0x77
>  [<ffffffff8023c631>] unregister_sysctl_table+0x34/0xe5
>  [<ffffffff8023c6b2>] unregister_sysctl_table+0xb5/0xe5
>  [<ffffffff80523f8c>] neigh_sysctl_unregister+0x1a/0x31
>  [<ffffffff80559635>] inetdev_event+0x2b4/0x3d1
>  [<ffffffff8024b850>] notifier_call_chain+0x29/0x56
>  [<ffffffff8051fa2a>] dev_change_net_namespace+0x1bb/0x1da
>  [<ffffffff8051fa9d>] default_device_exit+0x54/0xa2
>  [<ffffffff8052105e>] netdev_run_todo+0x1fd/0x206
>  [<ffffffff8051ce0b>] cleanup_net+0x0/0x95
>  [<ffffffff8051ce6f>] cleanup_net+0x64/0x95
>  [<ffffffff80244e58>] run_workqueue+0xf1/0x1ee
>  [<ffffffff80244e02>] run_workqueue+0x9b/0x1ee
>  [<ffffffff802459ee>] worker_thread+0xd8/0xe3
>  [<ffffffff80248426>] autoremove_wake_function+0x0/0x2e
>  [<ffffffff80245916>] worker_thread+0x0/0xe3
>  [<ffffffff80248311>] kthread+0x47/0x76
>  [<ffffffff805c7529>] trace_hardirqs_on_thunk+0x3a/0x3f
>  [<ffffffff8020cdc9>] child_rip+0xa/0x11
>  [<ffffffff8020c3ff>] restore_args+0x0/0x30
>  [<ffffffff80230bcd>] finish_task_switch+0x0/0xc4
>  [<ffffffff802482ca>] kthread+0x0/0x76
>  [<ffffffff8020cdbf>] child_rip+0x0/0x11
>
> ---[ end trace f9cc56de378eb3ce ]---
