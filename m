From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 09:30:35 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0804240921460.2779@woody.linux-foundation.org>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>  <20080424112514.055d8071@the-village.bc.nu>  <alpine.LFD.1.10.0804240828100.2779@woody.linux-foundation.org>  <20080424.083908.147395158.davem@davemloft.net>
 <517f3f820804240903y788102bar5c7d1fa9bcee1c8a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, alan@lxorguk.ukuu.org.uk,
	drepper@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: Michael Kerrisk <mtk.manpages@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60187 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752176AbYDXQbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 12:31:32 -0400
In-Reply-To: <517f3f820804240903y788102bar5c7d1fa9bcee1c8a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 24 Apr 2008, Michael Kerrisk wrote:
> 
> It strikes me to be cleanest to use the same solution for all of them
> -- i.e., new syscalls (seems simplest) or sys_indirect() -- including
> socket().

I certainly don't dislike sys_indirect either, but I've also done user 
mode programming, and when it comes to OS-specific things (and especially 
if they are even _version_-specific) I can tell you that basically nobody 
will ever use them if you cannot decide to use them dynamically.

Here's an example of a *successful* use of something like that:

	#ifndef O_NOATIME
	#define O_NOATIME 0
	#endif

	static unsigned int sha1_file_open_flag = O_NOATIME;

	...
	        fd = open(filename, O_RDONLY | sha1_file_open_flag);
	        if (fd < 0) {
	                /* See if it works without O_NOATIME */
	                switch (sha1_file_open_flag) {
	                default:
	                        fd = open(filename, O_RDONLY);
	                        if (fd >= 0)
	                                break;
	                /* Fallthrough */
	                case 0:
	                        return NULL;
	                }


	                /* If it failed once, it will probably fail again.
	                 * Stop using O_NOATIME
	                 */
	                sha1_file_open_flag = 0;
        }
	...

see? This is soemthing where I actually used Linux-specific code. And 
dammit, I'm _Linus_. Think of your normal programmer that isn't quite as 
Linux-oriented.

And that's the problem with anything that isn't flags-based. Once you do 
new system calls, doing the above is really quite nasty. How do you 
statically even _test_ that you have a system call? Now you need to add a 
whole autoconf thing for it existing, and when it does exist you still 
need to test whether it works, and you can't even do it in the slow-path 
like the above (which turns the failure into a fast-path _without_ the 
flag).

So while I don't dislike the indirect system call, I do think that if we 
can handle a large case of the problems with an added flag to already 
existing system calls, that does have huge advantages. Because it allows 
code like the above, which needs absolutely zero autoconf for linking 
errors etc..

			Linus
