From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: IPv4/IPv6 sysctl unregistration deadlock
Date: Thu, 26 Feb 2009 08:55:31 -0800
Message-ID: <20090226085531.5d124843@nehalam>
References: <49A4D5D5.5090602@trash.net>
	<20090225061902.GA32430@gondor.apana.org.au>
	<49A4E3F8.4050406@trash.net>
	<49A4F0D7.20304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41931 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755612AbZBZQze (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 11:55:34 -0500
In-Reply-To: <49A4F0D7.20304@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Feb 2009 08:18:47 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Patrick McHardy wrote:
> > Herbert Xu wrote:
> >> On Wed, Feb 25, 2009 at 06:23:33AM +0100, Patrick McHardy wrote:
> >>> An easy fix would be to keep track of whether sysctl unregistration
> >>> is in progress in IPv4/IPv6 and ignore new requests from that point
> >>> on. Its not very elegant though, so I was wondering whether anyone
> >>> has a better suggestion.
> >>
> >> We could make the unregistration asynchronous and invoke a callback
> >> when it's done.  Then we can simply hold a net_device refcount and
> >> relinquish it in the callback
> > 
> > That sounds simple enough. I'll see if I can come up with a patch, thanks.
> 
> Unfortunately its more complicated than I thought because of
> device renames, where the sysctl pointer is reused after
> unregistration and the rename/unregistration/re-registration
> should be atomic. Deferring unregistration means we can't perform
> the new registration immediately unless we allow multiple
> registrations for a single device to be active simulaneously,
> which introduces a whole new set of problems.
> 
> Simply ignoring the request during unregistration doesn't seem
> so bad after all, the main problem is that it intoduces a different
> race on renames where a write to the "forwarding" file returns
> success, but the change doesn't take effect. We could return
> -ENOENT, but that seems a bit strange after open() returned success.
> Maybe -EBUSY, although I would prefer to make this transparent
> to userspace.
> 
> Another alternative would be to simply not take the RTNL in
> the sysctl handler since we're already taking dev_base_lock
> before performing any forwaring changes. But in case of IPv4
> we need it for disabling LRO.
> 
> I think I'm stuck. Will rethink it after some coffee :)

Will the following help? It punts the problem back out to VFS which
will restart.

--- a/net/ipv6/addrconf.c	2009-02-26 08:51:09.000000000 -0800
+++ b/net/ipv6/addrconf.c	2009-02-26 08:54:08.000000000 -0800
@@ -493,15 +493,17 @@ static void addrconf_forward_change(stru
 	read_unlock(&dev_base_lock);
 }
 
-static void addrconf_fixup_forwarding(struct ctl_table *table, int *p, int old)
+static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int old)
 {
 	struct net *net;
 
 	net = (struct net *)table->extra2;
 	if (p == &net->ipv6.devconf_dflt->forwarding)
-		return;
+		return 0;
+
+	if (!rtnl_trylock())
+		return -ERESTARTSYS;
 
-	rtnl_lock();
 	if (p == &net->ipv6.devconf_all->forwarding) {
 		__s32 newf = net->ipv6.devconf_all->forwarding;
 		net->ipv6.devconf_dflt->forwarding = newf;
@@ -512,6 +514,7 @@ static void addrconf_fixup_forwarding(st
 
 	if (*p)
 		rt6_purge_dflt_routers(net);
+	return 1;
 }
 #endif
 
@@ -3977,7 +3980,7 @@ int addrconf_sysctl_forward(ctl_table *c
 	ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
 
 	if (write)
-		addrconf_fixup_forwarding(ctl, valp, val);
+		ret = addrconf_fixup_forwarding(ctl, valp, val);
 	return ret;
 }
 
@@ -4013,8 +4016,7 @@ static int addrconf_sysctl_forward_strat
 	}
 
 	*valp = new;
-	addrconf_fixup_forwarding(table, valp, val);
-	return 1;
+	return addrconf_fixup_forwarding(table, valp, val);
 }
 
 static struct addrconf_sysctl_table
