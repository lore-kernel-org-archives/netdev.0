From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Tue, 29 Dec 2009 10:03:57 -0800
Message-ID: <m1pr5xy7w2.fsf@fess.ebiederm.org>
References: <20091229050114.GC14362@heat> <m1y6km11lj.fsf@fess.ebiederm.org>
	<20091229151146.GA32153@us.ibm.com>
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
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091229151146.GA32153@us.ibm.com> (Serge E. Hallyn's message of "Tue\, 29 Dec 2009 09\:11\:46 -0600")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Serge E. Hallyn" <serue@us.ibm.com> writes:
>
> I have two comments on the idea:
>
> 1. We don't want to complicate the current capabilities
>    concepts and API, so if we do something like this,
>    we should make sure not to try to store these
>    unprivileged capabilities with the current privilege
>    capabilities.

I was afraid there might be a complication like that.
Then the user interface side of what I am proposing
needs some more thought.

> In my last email last night I detailed a way to use regular
> capabilities to make the prctl(PR_SET_NETWORK, PR_DROP_NET)
> safer.

Yes.  I missed that earlier my apologies.

>> I can see one of two possible reasons you are avoiding the
>> suggestion to disable setuid root.
>> - You have a use for setuid root executables in your contained
>>   environment.  If you do what is that use?
>
> I don't think Michael was avoiding that.  Rather, we haven't quite
> spelled out what it means to disable setuid root, and we haven't
> (to my satisfaction) detailed how setuid root would undo the
> prctl(PR_SET_NETWORK, PR_DROP_NET) - i.e. is it only on a
> privilege-granting setuid-root, or all setuids?

Michael finds suid-root granting network access incompatible
with what he is trying to achieve.  The practical example is
network denied applications may communicate with the outside
world by calling ping.

> Eric, let me specifically point out a 'disable setuid-root'
> problem on linux: root still owns most of the system even when
> it's not privileged.  So does "disable setuid-root" mean
> we don't allow exec of setuid-root binaries at all, or that
> we don't setuid to root, or that we just don't raise privileges
> for setuid-root?

The semantics I am suggesting under the title "disable suid exec" are
to flag a process such that, that process and any future children may
not increase their kernel enforced privileges.  In practice this means
attempts to exec any suid binaries will fail.  Likewise attempting to
exec a binary flagged with in the filesystem to gain capabilities will
also fail.

This would appear to require denying of ptracing applications
with other/more privileges, failing attempts to raise the
capabilities on one of the processes, and I think failing
all setuid/setgid calls.

In my conception this is a useful subset of unshare(USERNS) that can
be easily implemented now.

>> - Disabling suid root executables is an indirect path to your
>>   goal.
>> 
>> The problem with the disable_network semantics you want
>> is that they allow you to perform a denial of service attack
>> on privileged users.  An unprivileged DOS attack is unsuitable
>> for a general purpose feature in a general purpose kernel.
>
> Though to be honest I'm still unconvinced that the disablenetwork
> is dangerous.  I think long-term a more general solution like what
> I outlined above might be good, but short-term a sysctl that
> turns on or off the ability to drop network would suffice imo.

I have seen the following arguments put forth.
  - Certain kinds of logging are broken from suid executables.
  - Certain questionable but existing user space authentication
    policies will be broken.

That is enough for me to strongly suspect someone with a more
devious mind than myself could find something worse.  I know
it took me over a year to figure out how someone could exploit
unshare(NETNS).

The goal is to find something that unprivileged applications can use
safely, and can be available by default in distro kernels.

A syscall that removes the ability to exec suid executables appears to
meet that goal, as well as be the necessary prerequisite for enabling
other forms of isolation without causing security problems.

Eric
