From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Mon, 28 Dec 2009 12:13:16 -0600
Message-ID: <20091228181316.GA16277@us.ibm.com>
References: <20091227010441.GA12077@heat>
 <200912271736.GDB17180.OFJHOOQStMFLVF@I-love.SAKURA.ne.jp>
 <20091227083857.GC11737@elf.ucw.cz>
 <200912272049.FIB35755.OMFFOOJQtVLFSH@I-love.SAKURA.ne.jp>
 <20091227150300.GB19414@hallyn.com>
 <20091227190802.GH11737@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	viro@ZenIV.linux.org.uk, michael@laptop.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, andi@firstfloor.org,
	david@lang.hm, socketcan@hartkopp.net, alan@lxorguk.ukuu.org.uk,
	herbert@gondor.apana.org.au, Valdis.Kletnieks@vt.edu,
	bdonlan@gmail.com, zbr@ioremap.net, cscott@cscott.net,
	jmorris@namei.org, ebiederm@xmission.com, bernie@codewiz.org,
	mrs@mythic-beasts.com, randy.dunlap@oracle.com,
	xiyou.wangcong@gmail.com, sam@synack.fr, casey@schaufler-ca.com
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091227190802.GH11737@elf.ucw.cz>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Pavel Machek (pavel@ucw.cz):
> Hi!
> 
> > > I think seccomp() is too much restricted to apply for general applications.
> > > Most applications will need some other syscalls in addition to exit(), read()
> > > and write(). Most applications cannot use seccomp().
> > > 
> > > What I want to do is similar to seccomp(), but allows userland process to
> > > forbid some syscalls like execve(), mount(), chroot(), link(), unlink(),
> > > socket(), bind(), listen() etc. selectively.
> > 
> > The nice thing about the disablenetwork module is that (AFAICS so far)
> > it actually is safe for an unprivileged user to do.  I can't think of
> > any setuid-root software which, if started with restricted-network by
> > an unprivileged user, would become unsafe rather than simply
> > failing.
> 
> "I can't see" is not strong enough test, I'd say.
> 
> For example, I can easily imagine something like pam falling back to
> local authentication when network is unavailable. If you disable
> network for su...
> 
> It would be also extremely easy to DoS something like sendmail -- if
> it forks into background and then serves other users' requests.

But you can just as easily unplug the network cable (or flip the
wireless switch).  So in the case of authentication, either your
nsswitch.conf says to fall back to files, or it doesn't - in either
case it's what you expected...

Michael, a few possibilities have been brought up.  To toss in
one more, what about making a separate capability CAP_NETWORK_REENABLE,
and requiring that in order to reset prctl(PR_SET_NETWORK) or
whatever?  Then if you don't want to allow that, you can drop
CAP_NETWORK_REENABLE from your bounding set, and you'll never
be able to reset it.

It's not just a silly extra step - dropping CAP_NETWORK_REENABLE
from your bounding set requires privilege, so now we are at
least saying that it takes privilege to allow a less-privileged
process to stop a more-privileged process from regaining network
requires privilege later.

That specific example isn't good - the problem is, someone has to sit
there knowing to do the prctl(PR_SET_NETWORK).  It doesn't do anything
to prevent the nefarious unprivileged user from doing
prctl(PR_DROP_NETWORK) and then running a setuid-root daemon, and if the
daemon doesn't know about PR_SET_NETWORK then it still will run without
priv.

So I prefer a similar but slightly different construct - the key
being requiring privilege to be able to say "it's ok to deny privileged
software network".  We can either

	1. introduce a sysctl which says whether or not setuid-root
	   re-enables network by default,
or
	2. add an extra bit to your per-task network data, which
	   again says "for root we re-enable network" or not.
or heck
	3. make it a boot flag.

In any case, the idea would be that on your bitfrost systems init, or
some early privileged process, would say "for me and all my children,
if an unprivileged process does PR_DROP_NETWORK then that holds even
for setuid-root programs.

-serge
