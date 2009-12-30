From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Tue, 29 Dec 2009 21:50:08 -0600
Message-ID: <20091230035008.GA6819@us.ibm.com>
References: <20091229050114.GC14362@heat>
 <m1y6km11lj.fsf@fess.ebiederm.org>
 <20091229151146.GA32153@us.ibm.com>
 <3e8340490912290805s103fb789y13acea4a84669b20@mail.gmail.com>
 <m3oclhzgm4.fsf@ursa.amorsen.dk>
 <m17hs5y0mg.fsf@fess.ebiederm.org>
 <20091229211139.0732a0c1@lxorguk.ukuu.org.uk>
 <m1iqbpwjtp.fsf@fess.ebiederm.org>
 <20091229223631.GB22578@us.ibm.com>
 <m1zl51uoqd.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Benny Amorsen <benny+usenet@amorsen.dk>,
	Bryan Donlan <bdonlan@gmail.com>,
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
	Casey Schaufler <casey@schaufler-ca.com>,
	Pavel Machek <pavel@ucw.cz>, Al V
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1zl51uoqd.fsf@fess.ebiederm.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
> "Serge E. Hallyn" <serue@us.ibm.com> writes:
> 
> > Quoting Eric W. Biederman (ebiederm@xmission.com):
> >> Alan Cox <alan@lxorguk.ukuu.org.uk> writes:
> >> 
> >> >> > Execute != read. The executable file may contain secrets which must not
> >> >> > be available to the user running the setuid program. If you fail the
> >> >> > setuid, the user will be able to ptrace() and then the secret is
> >> >> > revealed.
> >> >> >
> >> >> > It's amazing how many security holes appear from what seems like a very
> >> >> > simple request.
> >> >> 
> >> >> Do we have a security hole in nosuid mount option?
> >> >> Can someone write a patch to fix it?
> >> >
> >> > If a setuid app can read a key when its erroneously not set setuid then
> >> > the user can read it too.
> >> >
> >> > Anything you can do with ptrace you can do yourself !
> >> 
> >> Now that I think about it this is really something completely separate
> >> from setuid.  This is about being able to read the text segment with
> >> ptrace when you on have execute permissions on the file.
> >> 
> >> I just skimmed through fs/exec.c and we set the undumpable process
> >> flag in that case so ptrace should not work in that case.
> >
> > And in fact you can't do a new ptrace_attach, but if you're already
> > tracing the task when it execs the unreadable-but-executable file,
> > then the ptrace can continue.
> >
> > Just looking at the code, it appears 2.2 was the same way (though I
> > could be missing where it used to enforce that).
> >
> > So, is that intended?  What exactly would we do about it if not?
> > Just refuse exec of a unreadable-but-executable file if we're
> > being traced?
> 
> In common cap we drop the new capabilities if we are being ptraced.
> Look for brm->unsafe.

Yes - that isn't the issue.  The issue is with a file to which
we have execute permission but not read.  If user hallyn has two
terminals open, and terminal one does ./foo then terminal two
cannot do strace -f -p `pidof foo`.  But user hallyn can do
strace -f -p ./foo and succeed.

So we refuse ptrace_attach to an existing process with dumpable
turned off, but a pre-existing ptrace attach isn't affected by
executing a file which causes dumpable to be unset.

It goes back to finding a way to figure out what is inside the
file when the installer obviously thought we shouldn't be able
to read the file.

Do we care?  <shrug>

-serge
