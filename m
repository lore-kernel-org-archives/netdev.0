From: Bryan Donlan <bdonlan@gmail.com>
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Sun, 10 Jan 2010 21:15:54 -0500
Message-ID: <3e8340491001101815p887b96dr22b9b3f3108a7541@mail.gmail.com>
References: <f73f7ab81001101418x3b3f8652j256f6311ad6244c5@mail.gmail.com>
	<20100110230839.GB3825@heat> <3e8340491001101541tc776ad9r887be13393bcb7fd@mail.gmail.com>
	<4B4A83E0.9000207@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michael Stone <michael@laptop.org>,
	Kyle Moffett <kyle@moffetthome.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Pavel Machek <pavel@ucw.cz>,
	A
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4B4A83E0.9000207@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 10, 2010 at 8:50 PM, Casey Schaufler <casey@schaufler-ca.com> wrote:
> Bryan Donlan wrote:
>> On Sun, Jan 10, 2010 at 6:08 PM, Michael Stone <michael@laptop.org> wrote:
>>
>>> Paraphrasing Kyle:
>>>
>>>
>>>> Suppose there exist PAM modules which lazily fork background processes.
>>>> Now
>>>> assume that one of those PAM modules is hooked from /etc/pam.d/su, that
>>>> the
>>>> module fails closed when the network is unavailable, and that Mallory wins
>>>> the race to start the daemon. Boom.
>>>>
>>> I'm not disagreeing that there are configurations of programs, written for
>>> kernels without disablenetwork, which cease to be correct on kernels that
>>> provide it. However, all this says to me is that people who need to use
>>> those
>>> configurations probably shouldn't use disablenetwork. (Or that we haven't
>>> found
>>> exactly the right semantics for disablenetwork yet.)
>>>
>>
>> With the semantics given, the choice for using disablenetwork is given
>> to the unprivileged process, not to the administrator or privileged
>> process, so people using these configurations have no choice - the
>> malicious local user can just use it anyway.
>>
>> I still think requiring a drop of suid abilities would be best - if
>> the suid process wants to run in a no-network environment it can still
>> disablenetwork itself.
>>
>>
>
> Stop. If you can count on the program to use the mechanisms you've
> described correctly you can count on it to use exec, socket, and
> bind correctly. You're only trading one set of behaviors for another.

I don't think there's any argument that a program designed with
disablenetwork in mind will have no problems with disablenetwork
existing. The only concern is when a malicious (or ill-conceived)
program disables network access, then invokes a naive setuid program.

What I meant by the above is is, by my reading Michael suggests that
systems where there are setuid programs that grossly misbehave without
network access should simply not use disablenetwork; however my point
is that there is no such choice available to the administrator. In the
proposed APIs, disablenetwork is always available, and any untrusted
user can push it on all setuid programs in the system.

There were also suggestions of setuid programs that might themselves
want to drop network access; but one can simply have said setuid
program drop network access after it's executed, rather than relying
on the (untrusted anyway!) invoker to do so. So there's no need to
have it set by the caller, and indeed this may be undesirable because
the suid program will need to drop it again _anyway_ since it can't
assume the caller really did drop it. And of course, since this suid
program is asking for its network access to be disabled, it is
presumably prepared to deal with the consequences.

Finally, if there is a need for an untrusted program to invoke a
set-uid program, this can always be emulated by making a request over
a unix domain socket. Since presumably the program that used the
disablenetwork facility is designed around said disablenetwork
facility, it's not much of a burden to expect it use such a facility
in the unlikely case that there's a program that can't be trusted to
use the network, but does need to make some privileged operations.

In short:

* If network access is restored over suid, then we can leak data over
ping or any number of other routes, so that's right out.
* If network access is denied over suid, there are concerns of denial
of service in certain configurations.
* If suid is denied entirely, we have no denial of service or
information leak concerns via the suid mechanism (since the mechanism
is completely unusable). And if we really do need to execute something
at an elevated privilege, we can ask a helper daemon to do it on our
behalf.
