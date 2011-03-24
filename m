From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH v2] net: don't allow CAP_NET_ADMIN to load non-netdev
 kernel modules
Date: Thu, 24 Mar 2011 18:15:18 -0400
Message-ID: <1301004924.14296.12.camel@localhost.localdomain>
References: <1300991584.2689.35.camel@bwh-desktop>
	 <20110324202634.GB9191@peq.hallyn.com> <20110324143944.29f4c362@nehalam>
	 <20110324.144628.58411809.davem@davemloft.net>
	 <20110324215747.GA12585@peq.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	bhutchings@solarflare.com, eparis@parisplace.org,
	segoon@openwall.com, linux-kernel@vger.kernel.org, mjt@tls.msk.ru,
	arnd@arndb.de, mirqus@gmail.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, eric.dumazet@gmail.com,
	therbert@google.com, xiaosuo@gmail.com, jesse@nicira.com,
	kees.cook@canonical.com, eugene@redhat.com,
	dan.j.rosenberg@gmail.com, akpm@linux-foundation.org,
	greg@kroah.com, sds@tycho.nsa.gov,
	linux-security-module@vger.kernel.org, dwalsh@redhat.com,
	dhowells@redhat.com
To: "Serge E. Hallyn" <serge.hallyn@ubuntu.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20110324215747.GA12585@peq.hallyn.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-03-24 at 16:57 -0500, Serge E. Hallyn wrote:
> Quoting David Miller (davem@davemloft.net):
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Thu, 24 Mar 2011 14:39:44 -0700
> > 
> > > This breaks for many of the tunneling protocols, that rely on
> > > autoload for names like "sit0"
> > 
> > Frankly I'm very disappointed in the fallout this has been causing.
> > 
> > Everyone supporting this change, get real, and admit it doing in fact
> > cause a serious regression.
> 
> Sorry, I thought this was causing some extra audit messages but no
> actual breakage?

I've got one report of someone claiming their system broke, but I'm not
convinced I believe it since his dmesg didn't show the magic pr_err()
when it should have.  It's certainly possible this can break someone in
a system which uses fine grained capabilities controls, but I agree it's
pretty unlikely.  My biggest personal concern is that I have a whole
darn bunch of new scary messages which are popping out of people's
computers since they don't have CAP_SYS_MODULE.  While I can silence
them, it's going to hide use of init_module() directly as well, which I
really don't want to hide from the scary logs....

> > If you can't get past that simple fact, you cannot discuss this issue
> > intelligently.
> > 
> > You can't say "userland will fix things up"
> > 
> > Because we're never supposed to break userland in the first place.
> > 
> > There is simply no excuse for this and I want this change reverted
> > both in Linus's tree and in -stable.
> 
> Eric, in this particular case, since we've already done a
> 'capable(CAP_NET_ADMIN)', I woudl argue that doing the check
> for CAP_SYS_ADMIN without auditing failure (even if it requires
> a new helper in capability.c) isn't horrible.  Thoughts?

s/CAP_SYS_ADMIN/CAP_SYS_MODULE/

I can do that.  It was actually my #2 suggestion.  But, I'm certainly
willing to put some of the burden on userspace.  SELinux policy is a
userspace construct and we often force other userspace applications to
fix things they do poorly (even if it gets us a rep for being
'difficult')  Non-SELinux systems aren't going to see this problem,
because basically noone else I know of tries to enforce any kind of
capabilities sets other than all or none, so you'll never see
CAP_NET_ADMIN without CAP_SYS_MODULE.

I guess what it comes down to is that I'm happy to break Fedora user's
with SELinux if in the end it gets us a better system.  I'd be happy to
just rip the whole CAP_SYS_MODULE portion out and blame it on SELinux,
but I know that's not what upstream does.  So given what we have today I
personally would push for a no_audit() interface rather than a complete
revert.   (or maybe a compile option so I can turn off the fallback
altogether and force people to come into compliance)

-Eric

