From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH v2] net: don't allow CAP_NET_ADMIN to load non-netdev
 kernel modules
Date: Thu, 24 Mar 2011 14:03:53 -0400
Message-ID: <1300989839.2398.17.camel@localhost.localdomain>
References: <201102272122.52643.arnd@arndb.de>
	 <4D6B6AE7.2050202@msgid.tls.msk.ru> <20110228095133.GA4351@albatros>
	 <20110228.112349.104067277.davem@davemloft.net>
	 <20110301194845.GA3533@albatros> <1299010390.2529.30.camel@bwh-desktop>
	 <20110301213313.GA6507@albatros>
	 <AANLkTikr=qfFeaXDkiBbK-4KvKS83LzURrUj4L2TP8_u@mail.gmail.com>
	 <20110324153714.GB2648@peq.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Paris <eparis@parisplace.org>,
	Vasiliy Kulikov <segoon@openwall.com>,
	linux-kernel@vger.kernel.org, mjt@tls.msk.ru, arnd@arndb.de,
	mirqus@gmail.com, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
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
To: "Serge E. Hallyn" <serge.hallyn@ubuntu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30285 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751565Ab1CXSFh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2011 14:05:37 -0400
In-Reply-To: <20110324153714.GB2648@peq.hallyn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-03-24 at 10:37 -0500, Serge E. Hallyn wrote:
> Quoting Eric Paris (eparis@parisplace.org):
> > On Tue, Mar 1, 2011 at 4:33 PM, Vasiliy Kulikov <segoon@openwall.com> wrote:
> ...
> > This patch is causing a bit of a problem in Fedora.  The problem lies
> 
> Sorry, what exactly is the problem it is causing?  I gather it's
> spitting out printks?  What exactly do the printks say?  The patch
> included at bottom checks for CAP_NET_ADMIN before checking for
> CAP_SYS_MODULE, so these must be cases which historically always
> quietly failed, and are now hitting the 'pr_err' which this patch
> adds?

Not quite.  SELinux logs every time an operation is denied.  This patch
means that every time a module is requested which does not exist as
netdev-* we check CAP_SYS_MODULE.  SELinux does not allow CAP_SYS_MODULE
and thus we get SELinux complaining that tasks are trying to load
modules.  I do have one report from a user who claims this is breaking
his system, but I'm not sure I believe him as I have yet to see any
dmesg printk from the pr_err.

On my local system reproduce the SELinux denials on every boot as
something tries to autoload "reg", "wifi0", and "virbr0".  I have no
modules which match these.  Thus the first try for CAP_NET_ADMIN
+netdev-wifi0 fails.  We then hit the CAP_SYS_MODULE check which SELinux
rejects and puts up a huge warning that someone is trying to load code
into the kernel.  Big red flags.  Even in permissive, where the
capable(CAP_SYS_MODULE) passes, we won't hit the pr_err() since there is
not module for "wifi"

I think there are 3 possibilities:

Change SELinux policy so as to not complain when udev/NM/libvirt try to
check CAP_SYS_MODULE, but that's a bad idea, since if they every try to
use init_module(2) we won't get denials.

Change this callsite to a _noaudit check.  Which is better than above
but still not great since we wouldn't get a denial log if anybody had
tried to load xfs....

Figure out a way to stop the calls to "reg" "wifi0" and "virbr0" if they
don't exist.

I feel like the last one is the best way, but I don't know what a
solution could look like....

