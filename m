From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] Suspicious bug in module refcounting
Date: Mon, 9 Feb 2009 16:18:31 +0100
Message-ID: <20090209151830.GC6018@dhcp35.suse.cz>
References: <20090203134721.GA11069@pingi.kke.suse.de> <200902041418.09630.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <kkeil@suse.de>, linux-kernel@vger.kernel.org,
	richard kennedy <richard@rsk.demon.co.uk>,
	Dan Williams <dan.j.williams@intel.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	dwmw2@infradead.org, Scott Wood <scottwood@freescale.com>,
	netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
	Rusty Russell <rusty@rustcorp.com.au>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:37319 "EHLO dhcp35"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754454AbZBIPSd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2009 10:18:33 -0500
Content-Disposition: inline
In-Reply-To: <200902041418.09630.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed 04-02-09 14:18:08, Rusty Russell wrote:
> On Wednesday 04 February 2009 00:17:21 Karsten Keil wrote:
> > The refcount is a per CPU atomic variable, module_refcount() simple add
> > in a fully unprotected loop (not disabled irqs, not protected against
> > scheduling) all per cpu values.
> 
> Hi Karsten,
> 
>    Yes, the BUG_ON() is overly aggressive.  And I really hate __module_get,
> and it looks like most of the callers are completely bogus.  The watchdog
> drivers use it to nail themselves in place in their open routines: this is
> OK, if a bit weird.
> 
>    We should only use __module_get() when you *can't handle* failure;
> otherwise you should accept that the admin did rmmod --wait and don't use the
> module any further.
> 
>   dmaengine.c seems to be taking liberties like this.  AFAICT it can error
> out, so why not just try_module_get() always?
> 
>   gameport.c, serio.c and input.c increment their own refcount, but to get
> into those init functions someone must be holding a refcount already (ie. a
> module depends on this module).  Ditto cyber2000fb.c, and MTD.
> 
>   mdio-bitbang.c should definitely use try_module_get.
> 
>   loop.c bumping its own refcount, Al might know why, but definitely can be
> try_module_get() if it's valid at all.
> 
>   net/socket.c can also handle failure, so that's another try_module_get.
> 
> etc.
> 
> > I think we should replace all unprotected __module_get() calls with
> > try_module_get(), or remove __module_get() completely.
> 
> Agreed.  We will need a "nail_module()" call for those legitimate uses (which
> should clear mod->exit, rather than manipulating the refcount at all).
> 
> Meanwhile, I'll remove the BUG_ON for 2.6.29.
> 
> Thanks,
> Rusty.
> 
> module: remove over-zealous check in __module_get()
> 
> module_refcount() isn't reliable outside stop_machine(), as demonstrated
> by Karsten Keil <kkeil@suse.de>, networking can trigger it under load
> (an inc on one cpu and dec on another while module_refcount() is tallying
>  can give false results, for example).
> 
> Almost noone should be using __module_get, but that's another issue.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> diff --git a/include/linux/module.h b/include/linux/module.h
> --- a/include/linux/module.h
> +++ b/include/linux/module.h
> @@ -407,7 +407,6 @@ static inline void __module_get(struct m
>  static inline void __module_get(struct module *module)
>  {
>  	if (module) {
> -		BUG_ON(module_refcount(module) == 0);
>  		local_inc(__module_ref_addr(module, get_cpu()));
>  		put_cpu();
>  	}

Based on this change, would it make sense to update sys_accept to change
__module_get to try_module_get like in the following patch?


>From 368c52b25414d1ccd0851d77fa5f20431487c172 Mon Sep 17 00:00:00 2001
From: Michal Hocko <mhocko@suse.cz>
Date: Mon, 9 Feb 2009 16:06:15 +0100
Subject: [PATCH] [NET] replace __module_get by try_module_get in accept4

After 7f9a50a5b89b87f8e754f59ae9968da28be618a5 we are not checking for
potential BUG in module reference counting. Therefore we should replace
__module_get by try_module_get and BUG if the module is being unloaded.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 net/socket.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 35dd737..d0d4c92 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1444,10 +1444,11 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 	newsock->ops = sock->ops;
 
 	/*
-	 * We don't need try_module_get here, as the listening socket (sock)
-	 * has the protocol module (sock->ops->owner) held.
+	 * Socket's owner cannot be in unloading path because there
+	 * must be at least one listening reference
 	 */
-	__module_get(newsock->ops->owner);
+	if (unlikely(!try_module_get(newsock->ops->owner)))
+		BUG();
 
 	newfd = sock_alloc_fd(&newfile, flags & O_CLOEXEC);
 	if (unlikely(newfd < 0)) {
-- 
1.5.6.5


-- 
Michal Hocko
L3 team 
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic
