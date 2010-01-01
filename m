From: "Andrew G. Morgan" <morgan@kernel.org>
Subject: Re: [RFC][PATCH v3] Unprivileged: Disable raising of privileges
Date: Fri, 1 Jan 2010 13:17:33 -0800
Message-ID: <551280e51001011317u44347082r4bd288f10475be18@mail.gmail.com>
References: <551280e50912300652r1007dee0j8de750bf33af9b3c@mail.gmail.com>
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
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
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
	=?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.c
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <m1oclfkmuz.fsf@fess.ebiederm.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2009/12/31 Eric W. Biederman <ebiederm@xmission.com>:
> "Andrew G. Morgan" <morgan@kernel.org> writes:
>
>> Since there is already independent support for disabling file
>> capabilities (the privilege escalation part), I see these two
>> mechanisms as separable.
>
> I guess there is something that resembles support for disabling
> privilege escalation. =A0The problem is that it requires privilege to
> use it.

Just to be clear, this does not prevent luser1 -> luser2 transitions
(even though it does strip root of its privilege), but here is a
concrete worked example of what support is in the current kernel.

That is, here is a program that cripples privilege in a process tree.
Other than setting it up one time, you don't need to become root (or
visit a *uid=3D0) to execute it, and because capabilities are not
naively inherited nothing about the privilege of the limiter
executable can leak through the execve().

Setup (see below for source code, and
http://ols.fedoraproject.org/OLS/Reprints-2008/hallyn-reprint.pdf for
an explanation of how it all works):

luser> cc -o limiter limiter.c -lcap
luser> sudo /usr/sbin/setcap cap_setpcap=3Dp ./limiter

Use:

luser> ./limiter /bin/bash
[feeling powerless]
luser> ...try something privileged... or look at /proc/self/status etc.
luser> exit
luser> back in parent shell

//---- cut here 8< ----- [this is limiter.c]
/* Quick demo of blocking privilege */
#include <stdio.h>
#include <sys/capability.h>
#include <sys/prctl.h>
#include <stdlib.h>

int main(int argc, char *argv[], char *envp[])
{
     if (argc < 2) {
	  fprintf(stderr, "usage: %s <execv args>\n", argv[0]);
	  exit(1);
     }
     cap_t needed =3D cap_from_text("cap_setpcap=3Dep");
     if (cap_set_proc(needed) !=3D 0) {
	  perror("cap_set_proc failed");
	  exit(1);
     }
     int cap =3D 0;
     int set;
     while ((set =3D prctl(PR_CAPBSET_READ, cap)) >=3D 0) {
	  if (set && prctl(PR_CAPBSET_DROP, cap)) {
	       fprintf(stderr, "failed to drop bset capability: %s\n",
		       cap_to_name(cap));
	       exit(1);
	  }
	  cap++;
     }
     if (prctl(PR_SET_SECUREBITS, 0x2e /* magic combination */)) {
	  perror("unable lock secure-bits");
	  exit(1);
     }
     fprintf(stderr, "[feeling powerless]\n");
     execve(argv[1], argv + 1, envp);
     fprintf(stderr, "[execve(\"%s\",...) failed - try something else.]=
\n",
	     argv[1]);
     exit(1);
}
//---- cut here 8< -----

> I have no problem with expressing this in a fine grained manner inter=
nally
> to the kernel but the user space interface needs to be atomic so that
> we can enable this all without privilege.

I'm not clear on the need for this specific detail.

> Further I may be off but I think the implementation would be more
> challenging than what I have already posted. =A0That doesn't mean it
> won't be more useful long term.

[Not sure I followed this bit.]

I can see a desire to block luser -> luser transitions being a good
thing, but not because it has anything to do with privilege.

Cheers [and happy New Year!]

Andrew

>
> Eric
> --
> To unsubscribe from this list: send the line "unsubscribe linux-secur=
ity-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
