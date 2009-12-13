From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Network isolation with RLIMIT_NETWORK, cont'd.
Date: Sun, 13 Dec 2009 02:05:19 -0800
Message-ID: <m1ljh7jijk.fsf@fess.ebiederm.org>
References: <20091213034418.GA4416@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	=?utf-8?Q?R=C3=A9mi?= Denis-Courmont <rdenis@simphalempin.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Linux Containers <containers@lists.osdl.org>
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091213034418.GA4416@heat> (Michael Stone's message of "Sat\, 12 Dec 2009 22\:44\:18 -0500")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I have added the container's list to the cc as there is some overlap.

Michael Stone <michael@laptop.org> writes:

> Dear lkml,
> 
> A few months ago [1], I asked for feedback on a new network isolation primitive
> named "RLIMIT_NETWORK" designed for use with Unix sandboxing utilities like
> Rainbow, Plash, and friends [2]. Thank you to all those CC'ed for your helpful
> early remarks.
> 
> Here is an updated patchset with responses to the following criticisms:

Overall what you have looks addhoc, and very special case which is
likely to impair maintenance in the future.

Furthermore you have not addressed the primary issue that keeps
unshare(CLONE_NEWNET) requiring root privileges.  You can in theory
confuse a suid root application and cause it to take action with it's
elevated privileges that violate the security policy.  The network
namespace has more potential to confuse existing applications than
your mechanism, but the problem seems to remain.

>   1. ptrace() 
>      
>      It was pointed out by Alan Cox, Andi Kleen, and others that processes
>      which dropped their RLIMIT_NETWORK rlimit were still able to directly
>      perform networking through a ptrace()'d victim.
> 
>      The new patchset adds an access check to __ptrace_may_access() to prevent
>      this behavior.

Solve that with an unused uid.  That ptrace_may_access check is
completely non-intuitive, and a problem if we ever remove the current
== task security module bug avoidance.

>   2. unshare(CLONE_NEWNET)
> 
>      It was pointed out by James Morris that network namespaces could be used
>      to implement behavior similar to the behavior this patchset is designed to
>      implement. To address this criticism, I added support for network
>      namespaces to my sandboxing utility (Rainbow).
> 
>      Unfortunately, I have discovered that network namespaces in their current
>      form are not appropriate for my use cases because they prevent the
>      namespace'd apps from connecting to the X server, even over plain old
>      AF_UNIX sockets.

We discussed that a while ago, and there is no fundamental reason to
disallow opening unix domain sockets from another network namespace.
The reason this has not been done, is that no one has taken a good
hard look at the packet transmit path and said there are no technical
problems for packets traversing between two network namespaces.

It is probably time to revisit that.


>      The RLIMIT_NETWORK facility I propose contains a specific exception for
>      AF_UNIX filesystem sockets since those sockets are already bound by
>      regular Unix discretionary access control.

What is more significant that unix discretionary access control is the
fact that the set of available af_unix sockets you can bind to is filtered
by the mount namespace.


With respect to the problem of handling suid root applications my long
term plan is to finish the security credentials namespace aka
unshare(NEWUSER).  Making the capabilities namespace local and
changing all uid based checks from uid1 == uid2 to (ns1, uid1) ==
(ns2, uid2).  At which point suid root applications will not be a
problem because the problem root capabilities will not be available
for them to acquire.

Eric
