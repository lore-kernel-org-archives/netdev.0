From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Tue, 29 Dec 2009 09:11:46 -0600
Message-ID: <20091229151146.GA32153@us.ibm.com>
References: <20091229050114.GC14362@heat>
 <m1y6km11lj.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Pavel Machek <pavel@ucw.cz>, Al Viro <viro@ZenIV.linux.org.uk>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:49145 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752049AbZL2PLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 10:11:52 -0500
Content-Disposition: inline
In-Reply-To: <m1y6km11lj.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Eric W. Biederman (ebiederm@xmission.com):
> Michael Stone <michael@laptop.org> writes:
> 
> > Serge,
> >
> > I think that Pavel's point, at its strongest and most general, could be
> > rephrased as:
> >
> >   "Adding *any* interesting isolation facility to the kernel breaks backwards
> >    compatibility for *some* program [in a way that violates security goals]."
> 
> *some* privileged program.
> 
> > The reason is the one that I identified in my previous note:
> >
> >   "The purpose of isolation facilities is to create membranes inside which
> >    grievous security faults are converted into availability faults."
> >
> > The question then is simply:
> >
> >   "How do we want to deal with the compatibility-breaking changes created by
> >    introducing new isolation facilities?"
> 
> You have a very peculiar taxonomy of the suggestions,
> that fails to capture the concerns.
> 
> I strongly recommend working out a way to disable
> setuid exec.  Ideally we would use capabilities to
> achieve this.  
> 
> Serge can we have a capability that unprivelged processes
> normally have an can drop without privelege?

David Madore suggested such a system several years ago:
http://lkml.org/lkml/2006/9/5/246

I have two comments on the idea:

1. We don't want to complicate the current capabilities
   concepts and API, so if we do something like this,
   we should make sure not to try to store these
   unprivileged capabilities with the current privilege
   capabilities.
	
2. This in itself does nothing to address the problem of
   unprivileged tasks denying privilege from privileged
   programs, thereby threatening the system.

In my last email last night I detailed a way to use regular
capabilities to make the prctl(PR_SET_NETWORK, PR_DROP_NET)
safer.

We could generalize that a bit:

1. we add a set of 'user_capabilities' like 'network', 'open',
etc, which are the rights to do an unprivileged network socket
create, file open, etc.

2. For each user_capability, we add a new 'CAP_REGAIN_$userpriv'
POSIX capability.

3. When a file is executed, we always add CAP_REGAIN_* to the
file permitted and effective sets.  That means that after
exec, they will always be in pE.

4. So long as CAP_REGAIN_foo is in pE toward the end of exec,
we re-enable the user_capability foo.

5. A privileged program can remove CAP_REGAIN_foo from the
capability bounding set.  It, and all it's children, will then
not have CAP_REGAIN_foo in pE after exec, so that if userspace
has removed foo from the user_capabilities set, it will not
be returned.

So, again, /bin/login, or pam, or /sbin/init can drop
CAP_REGAIN_* from its bounding set if userspace is designed
with that functionality in mind, in other words the distro or
admin trusts that privileged programs won't ruin the system if
they are denied certain features.

> I can see one of two possible reasons you are avoiding the
> suggestion to disable setuid root.
> - You have a use for setuid root executables in your contained
>   environment.  If you do what is that use?

I don't think Michael was avoiding that.  Rather, we haven't quite
spelled out what it means to disable setuid root, and we haven't
(to my satisfaction) detailed how setuid root would undo the
prctl(PR_SET_NETWORK, PR_DROP_NET) - i.e. is it only on a
privilege-granting setuid-root, or all setuids?

Eric, let me specifically point out a 'disable setuid-root'
problem on linux: root still owns most of the system even when
it's not privileged.  So does "disable setuid-root" mean
we don't allow exec of setuid-root binaries at all, or that
we don't setuid to root, or that we just don't raise privileges
for setuid-root?

> - Disabling suid root executables is an indirect path to your
>   goal.
> 
> The problem with the disable_network semantics you want
> is that they allow you to perform a denial of service attack
> on privileged users.  An unprivileged DOS attack is unsuitable
> for a general purpose feature in a general purpose kernel.

Though to be honest I'm still unconvinced that the disablenetwork
is dangerous.  I think long-term a more general solution like what
I outlined above might be good, but short-term a sysctl that
turns on or off the ability to drop network would suffice imo.
For ultra-secure sites at three-letter government agencies, we
could also provide a boot arg that disables the feature altogether,
and of course a grub password and IMA/EVM/trusted-boot could
ensure the boot arg isn't messed with.

> Your sysctl, your boot option, your Kconfig option all fail
> to be viable options for the same reason.  Your facility is
> only valid in an audited userspace.
> 
> Disabling setuid-exec especially to a subset of processes is
> valid in an unaudited userspace as it does not allow propagating
> the DOS to privileged processes.

-serge
