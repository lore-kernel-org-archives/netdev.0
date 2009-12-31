From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC][PATCH v3] Unprivileged: Disable raising of privileges
Date: Thu, 31 Dec 2009 15:46:21 -0600
Message-ID: <20091231214621.GA14116@us.ibm.com>
References: <20091230201712.GA23999@us.ibm.com>
 <m1hbr8tb8q.fsf_-_@fess.ebiederm.org>
 <20091230212931.233003b9@lxorguk.ukuu.org.uk>
 <m1skasrvnq.fsf@fess.ebiederm.org>
 <20091230230042.5d2e78ac@lxorguk.ukuu.org.uk>
 <3e8340490912301844p4fddaf57ke58ceeba9582e0fa@mail.gmail.com>
 <20091231173334.5e3d7557@lxorguk.ukuu.org.uk>
 <20091231175257.GA7210@us.ibm.com>
 <551280e50912311020x2bdc5b1o699a601f67b91662@mail.gmail.com>
 <m1oclfkmuz.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Andrew G. Morgan" <morgan@kernel.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Bryan Donlan <bdonlan@gmail.com>,
	Benny Amorsen <benny+usenet@amorsen.dk>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1oclfkmuz.fsf@fess.ebiederm.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
> "Andrew G. Morgan" <morgan@kernel.org> writes:
> 
> > Since there is already independent support for disabling file
> > capabilities (the privilege escalation part), I see these two
> > mechanisms as separable.
> 
> I guess there is something that resembles support for disabling
> privilege escalation.  The problem is that it requires privilege to
> use it.
> 
> I have no problem with expressing this in a fine grained manner internally
> to the kernel but the user space interface needs to be atomic so that
> we can enable this all without privilege.
> 
> Further I may be off but I think the implementation would be more
> challenging than what I have already posted.  That doesn't mean it
> won't be more useful long term.
> 
> Eric

Right, what we can currently do with capabilities is:

	1. drop capabilities from the bounding set.  This is
	   privileged because it is fine-grained, and can trick
	   capability-unaware privileged programs.
	2. drop CAP_SETUID from pP, pI, and the bounding set,
	   to prevent any future setuids.  Privileged for the
	   same reason as 1.
	3. set SECURE_NOROOT and SECURE_NOSUIDFIXUP, so that
	   uid 0 won't automatically get privileges.

It doesn't provide a way for stopping setuid on setuid binaries, though,
and as we've previously noted, while we'd *like* to say that uids and
privileges can be treated separately, in reality the unprivileged
root user still owns most of the system.  So we should also provide the
per-task nosuid bit, meaning do not change uid for a setuid binary.  This
could be treated as another securebit,

	SECURE_NOSUID

So if the capabilities module supports a special
	prctl(PR_SET_NOSUID)
which at the same time completely empties pP, pE, pI, and
the bounding set, and sets the SECURE_NOSUID securebit, that
should be safe for an unprivileged user.  (There is no need
for SECURE_NOROOT and SECURE_NOSUIDFIXUP in that case obviously).

Or, it could set SECURE_NOSUID|SECURE_NOROOT|SECURE_NOSUID_FIXUP
(and the corresponding _LOCKED bits).

-serge
