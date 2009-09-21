From: Jamie Lokier <jamie@shareable.org>
Subject: Re: fanotify as syscalls
Date: Tue, 22 Sep 2009 00:12:27 +0100
Message-ID: <20090921231227.GJ14700@shareable.org>
References: <20090912094110.GB24709@ioremap.net> <200909190000.43556.agruen@suse.de> <1253329471.2630.30.camel@dhcp231-106.rdu.redhat.com> <200909212204.51077.agruen@suse.de> <20090921202823.GB14700@shareable.org> <alpine.DEB.2.00.0909211456180.1116@makko.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Gruenbacher <agruen@suse.de>,
	Eric Paris <eparis@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk, alan@linux.intel.com, hch@infradead.org
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0909211456180.1116@makko.or.mcafeemobile.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Davide Libenzi wrote:
> On Mon, 21 Sep 2009, Jamie Lokier wrote:
> 
> > I think so to, and that'd be a great all round solution.
> 
> If this is for anti-malware vendors

Personally I'm not interested in anti-malware, and am simply
interested in leveraging fsnotify improvements to accelerate userspace
caches of information which depends on files (indexes, templates,
compiler caches, stat caches etc.).  Basically make inotify better,
and sufficiently correct for that purpose.

My sticking my oar in lately is to ensure the fsnotify improvements
are going in the (imho) right direction.  There's a lot of interesting
apps waiting in the wings on this.  It doesn't have to be complicated,
just... sensible.

> to intercept userspace accesses 
> they're currently doing it by hacking the syscall table, why don't we 
> offer a way to monitor syscalls (kernel side) in a non racy way?
> Modules can [un]register themselves for syscall intercaption, and receive 
> the syscall number and parameters. They'd be able to change paramters, 
> return error codes, and so on.
> The cost of the check in the syscall path could even be under an 
> alternative-like patching, if really neeeded.
> The Pros of this would be:
> 
> - The kernel code to implement this would be trivially small, with no 
>   I-need-this-feature-too growth potential

(Fwiw, the {fa,fs,i}notify thing looks to me like it's getting simpler
as we go.  Good design = decrease complexity + increase versatility.
E.g. see epoll.)

> - There won't be any externally visible API to maintain (and its kernel 
>   counter part) and expand
> 
> - Any system call can be intercepted, allowing it to be flexible while 
>   leaving the burden of the interception handling, and communication with 
>   userspace policy enforcers, to the anti-malware (or whoever really) 
>   companies modules
> 
> The anti-malware are already doing this (intercepting syscall), they 
> already have code for it, and they always did (writing kernel 
> modules/drivers, that is) for Windows.

I don't mind at all if fanotify is replaced by a general purpose "take
over the system call table" solution for anti-malware, and I still get
to keep the fsnotify improvements :-)

But I can't help noticing that we _already_ have quite well placed
hooks for intercepting system calls, called security_this and
security_that (SELinux etc), albeit they can't redirect things so much.

However, being a little kinder, I suspect even the anti-malware
vendors would rather not slow down everything with race-prone
complicated tracking of everything every process does...  which is why
fanotify allows it's "interest set" to be reduced from everything to a
subset of files, and it's results to be cached, and let the races be
handled in the normal way by VFS.

Once you have an "interest set" and focus on files, it looks somewhat
reasonable to use the fsnotify hooks.

...That is, if you believe monitoring files is the best approach to
anti-malware.  I can't help noticing that on (ahem) Windows, running
just a "virus checker" which generically scans every file independent
of it's location looking for signatures and keeping up with patches is
no longer considered good enough.

-- Jamie

