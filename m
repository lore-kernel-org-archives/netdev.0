From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12201] New: long wait in call_usermodehelper()
 / queue_work() / wait_for_completion()
Date: Thu, 11 Dec 2008 14:37:58 -0800
Message-ID: <20081211143758.510b51b6.akpm@linux-foundation.org>
References: <bug-12201-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
To: mike@nauticaltech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38603 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757415AbYLKWiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 17:38:06 -0500
In-Reply-To: <bug-12201-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 11 Dec 2008 14:15:21 -0800 (PST)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12201
> 
>            Summary: long wait in call_usermodehelper() / queue_work() /
>                     wait_for_completion()
>            Product: Process Management
>            Version: 2.5
>      KernelVersion: 2.6.26.8
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: process_other@kernel-bugs.osdl.org
>         ReportedBy: mike@nauticaltech.com
> 
> 
> Latest working kernel version: None
> Earliest failing kernel version: 2.6.26 (can't test any older)

It'd be great if you could test something more recent please.

> Distribution: CentOS 5
> Hardware Environment: Sun x4450, 16-cores, 128GB of RAM
> Software Environment: CentOS 5 + Apache webserver
> Problem Description:
> My problem started with SSH using the audit library, and my kernel not having
> AUDIT support.  During strace, any call to socket(PF_NETLINK, SOCK_RAW,
> NETLINK_AUDIT) took 1-2 seconds to return.  During this time, sys% was high.

Well this is bad.  We don't want the kernel calling out to userspace
each time you run socket(PF_NETLINK, ...).  The performance could be
awful.

I don't know if this is a net problem, an audit problem or whatever. 
Probably the offending kernel code simply shouldn't exist if
CONFIG_AUDIT=n.

Please attach a copy of the config to
http://bugzilla.kernel.org/show_bug.cgi?id=12201

> As I continued to dig deeper (using lots of printks), I found that these delays
> were caused by the netlink_create() code calling request_module() to find/load
> a module for AUDIT support which doesn't exist.
> 
> Continuing to dig, I found that request_module() uses call_usermodehelper() to
> run /sbin/modprobe to find/load the module.
> 
> The farthest I got is that after the process is created, we call
> wait_for_completion() to get the result of that process.  This waiting process
> takes 1-2 seconds.
> 
> The big problem in troubleshooting here is that this only starts to happen
> after the server has been online for a while (10 days maybe) and serving lots
> of traffic.  The delay gradually builds up and maxes out at around 2 seconds.
> 
> If I manually call /sbin/modprobe on the commandline and provide it the same
> arguments that call_usermodehelper() uses, the command returns instantly 100%
> of the time (assuming server has been on for a while).
> 
> If I write a small pilot program that calls socket(PF_NETLINK, SOCK_RAW,
> NETLINK_AUDIT), it will delay by 1-2 seconds 100% of the time (assuming server
> has been online for a while).  Certain protocol types given to socket() have
> zero delay (because no module needs to be loaded).
> 
> Steps to reproduce:
> Once server has been online for a while, a simple call to socket(PF_NETLINK,
> SOCK_RAW, NETLINK_AUDIT) shows the problem.

OK, weird.

Please get sysrq working then get us a task trace, so we can see who is
sleeping where.  Do this:


- run your "small pilot program"

- wait one second (so we catch it while it is delaying)

- echo t > /proc/sysrq-trigger

- dmesg -s 1000000 > foo

- send us a copy of foo.

(foo will be large, so it would be best to attach it to
http://bugzilla.kernel.org/show_bug.cgi?id=12201 then email us the URL)

(Using `echo w > /proc/sysrq-trigger' would work too, if we know that
the offending processes are stuck in D state.  It will produce less
output)

