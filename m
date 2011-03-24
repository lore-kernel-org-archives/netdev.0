From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] net: don't allow CAP_NET_ADMIN to load non-netdev
 kernel modules
Date: Thu, 24 Mar 2011 18:33:04 +0000
Message-ID: <1300991584.2689.35.camel@bwh-desktop>
References: <201102272122.52643.arnd@arndb.de>
	 <4D6B6AE7.2050202@msgid.tls.msk.ru> <20110228095133.GA4351@albatros>
	 <20110228.112349.104067277.davem@davemloft.net>
	 <20110301194845.GA3533@albatros> <1299010390.2529.30.camel@bwh-desktop>
	 <20110301213313.GA6507@albatros>
	 <AANLkTikr=qfFeaXDkiBbK-4KvKS83LzURrUj4L2TP8_u@mail.gmail.com>
	 <20110324153714.GB2648@peq.hallyn.com>
	 <1300989839.2398.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Eric Paris <eparis@parisplace.org>,
	Vasiliy Kulikov <segoon@openwall.com>,
	linux-kernel@vger.kernel.org, mjt@tls.msk.ru, arnd@arndb.de,
	mirqus@gmail.com, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com, therbert@google.com,
	xiaosuo@gmail.com, jesse@nicira.com, kees.cook@canonical.com,
	eugene@redhat.com, dan.j.rosenberg@gmail.com,
	akpm@linux-foundation.org, Greg KH <greg@kroah.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	LSM List <linux-security-module@vger.kernel.org>,
	Daniel J Walsh <dwalsh@redhat.com>,
	David Howells <dhowells@redhat.com>
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1300989839.2398.17.camel@localhost.localdomain>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-03-24 at 14:03 -0400, Eric Paris wrote:
> On Thu, 2011-03-24 at 10:37 -0500, Serge E. Hallyn wrote:
> > Quoting Eric Paris (eparis@parisplace.org):
> > > On Tue, Mar 1, 2011 at 4:33 PM, Vasiliy Kulikov <segoon@openwall.com> wrote:
> > ...
> > > This patch is causing a bit of a problem in Fedora.  The problem lies
> > 
> > Sorry, what exactly is the problem it is causing?  I gather it's
> > spitting out printks?  What exactly do the printks say?  The patch
> > included at bottom checks for CAP_NET_ADMIN before checking for
> > CAP_SYS_MODULE, so these must be cases which historically always
> > quietly failed, and are now hitting the 'pr_err' which this patch
> > adds?
> 
> Not quite.  SELinux logs every time an operation is denied.  This patch
> means that every time a module is requested which does not exist as
> netdev-* we check CAP_SYS_MODULE.  SELinux does not allow CAP_SYS_MODULE
> and thus we get SELinux complaining that tasks are trying to load
> modules.

This is exactly what would have happened before 2.6.32.  Unfortunately
the incorrect behaviour introduced in 2.6.32 (CAP_NET_ADMIN allows you
to load any module installed in the usual place) is now present in
basically every current distribution, and it sounds like some of them
now assume that dev_load() no longer requires CAP_SYS_MODULE.

[...]
> I think there are 3 possibilities:
>
> Change SELinux policy so as to not complain when udev/NM/libvirt try to
> check CAP_SYS_MODULE, but that's a bad idea, since if they every try to
> use init_module(2) we won't get denials.
>
> Change this callsite to a _noaudit check.  Which is better than above
> but still not great since we wouldn't get a denial log if anybody had
> tried to load xfs....

There are no evil bits in device or module names, so the kernel can't
tell whether the attempt should be logged.  But then, adding some sort
of policy option for whether to audit CAP_SYS_MODULE use here strikes me
as over-engineering.  Just make a decision based on what SELinux users
seem to prefer.

> Figure out a way to stop the calls to "reg" "wifi0" and "virbr0" if they
> don't exist.
>
> I feel like the last one is the best way, but I don't know what a
> solution could look like....

This really has to be done in userland, where these names are being
invented.  Though I suspect the usual way to check whether an interface
exists would be SIOCGIFINDEX, which calls dev_load()!  An alternate
would be to check whether /sys/class/net/<name> exists, but I seem to
recall that /sys/class is somewhat deprecated.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

