From: Michael Stone <michael@laptop.org>
Subject: Re: Network isolation with RLIMIT_NETWORK, cont'd.
Date: Sun, 13 Dec 2009 09:21:50 -0500
Message-ID: <20091213142149.GB4777@heat>
References: <m1ljh7jijk.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont <rdenis@simphalempin.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Linux Containers <containers@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.laptop.org ([18.85.2.145]:47749 "HELO mail.laptop.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753231AbZLMOTz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2009 09:19:55 -0500
Content-Disposition: inline
In-Reply-To: <m1ljh7jijk.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Biederman wrote:

> I have added the container's list to the cc as there is some overlap.

Good idea; thanks.

> Overall what you have looks ad-hoc, and very special case which is
> likely to impair maintenance in the future.

Unfortunately, these are the semantics which are necessary to make further
progress on sandboxing real Linux apps with the discretionary access control
facilities which are available today.

> You can in theory confuse a suid root application and cause it to take action
> with it's elevated privileges that violate the security policy. 

You're right, in theory. In practice, the setuid-root facility is a rather
special escape hatch which *everyone* in this field knows must be carefully
audited and maintained when building or updating trustworthy systems.

Also, in practice, I'm not expecting perfection today. Nor was I last year, nor
am I next year. What I am expecting is that the kernel will supply me (perhaps
with my assistance along the way) with the access control facilities that I
need to do my job in userland. This is one of them.

> The network namespace has more potential to confuse existing applications
> than your mechanism, but the problem seems to remain.

I'm glad to hear that you find this mechanism to be comparatively less
confusing.

>>   1. ptrace() 
>>      
>>      It was pointed out by Alan Cox, Andi Kleen, and others that processes
>>      which dropped their RLIMIT_NETWORK rlimit were still able to directly
>>      perform networking through a ptrace()'d victim.
>> 
>>      The new patchset adds an access check to __ptrace_may_access() to prevent
>>      this behavior.
> 
> Solve that with an unused uid.  

I already do, in general. (As do the other people requesting this facility.)

The reason for the __ptrace_may_access() check is that the logical way for
*application authors* whose code is *already* running in a fresh uid to further
improve system security is to separate their network I/O from their parsing
code a process boundary and to drop networking privileges in the parser.

>>   2. unshare(CLONE_NEWNET)
>> 
>>      It was pointed out by James Morris that network namespaces could be used
>>      to implement behavior similar to the behavior this patchset is designed to
>>      implement. To address this criticism, I added support for network
>>      namespaces to my sandboxing utility (Rainbow).
>> 
>>      Unfortunately, I have discovered that network namespaces in their current
>>      form are not appropriate for my use cases because they prevent the
>>      namespace'd apps from connecting to the X server, even over plain old
>>      AF_UNIX sockets.
>
>We discussed that a while ago, and there is no fundamental reason to
>disallow opening unix domain sockets from another network namespace.

I disagree. I like that the network namespaces have (fairly) clear semantics.
They are excellent semantics for some of my other use cases, like testing
networked software [1]. They're probably quite nice for full-blown
containerization. They're just not right for the kind of lightweight sandboxing
of complicated legacy apps that I'm doing.

[1]: http://dev.laptop.org/git/users/mstone/dnshash/tree/docs/unit_testing.txt

>> The RLIMIT_NETWORK facility I propose contains a specific exception for
>> AF_UNIX filesystem sockets since those sockets are already bound by
>> regular Unix discretionary access control.
> 
> What is more significant than unix discretionary access control is the
> fact that the set of available af_unix sockets you can bind to is filtered
> by the mount namespace.

Actually, the Unix DAC is far more important for my purposes. The reason is
that it's unprivileged, already understood by literally *everyone* involved in
Unix security, and it has the best tools support of any access control
mechanism.

For comparison, I do use CLONE_NEWNS mount namespaces and they've been a real
pain because

   a) unlike in Plan 9, they're privileged,

   b) they greatly complicate debugging the isolated app because you see
      different things inside and outside the namespace,

   c) there's no good way to manipulate them from userland, and

   d) they're poorly documented outside of the mount man page.

Regards,

Michael
