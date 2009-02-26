From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: IPv4/IPv6 sysctl unregistration deadlock
Date: Thu, 26 Feb 2009 08:49:24 -0800
Message-ID: <20090226084924.16cb3e08@nehalam>
References: <49A4D5D5.5090602@trash.net>
	<20090225061902.GA32430@gondor.apana.org.au>
	<49A4E3F8.4050406@trash.net>
	<49A4F0D7.20304@trash.net>
	<20090225084321.GA1101@gondor.apana.org.au>
	<m163ixk9t2.fsf@fess.ebiederm.org>
	<20090226062257.GA11511@gondor.apana.org.au>
	<m14oyhis31.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41653 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753024AbZBZQt3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 11:49:29 -0500
In-Reply-To: <m14oyhis31.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Feb 2009 23:18:42 -0800
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Herbert Xu <herbert@gondor.apana.org.au> writes:
> 
> > On Wed, Feb 25, 2009 at 10:10:33PM -0800, Eric W. Biederman wrote:
> >>
> >> How does adding a rename operation to sysctl sound?
> >
> > Yes that would definitely help.  Of course for the unregister case
> > we'd still need either an async removal or a no-op as Patrick
> > suggested.
> 
> After having reread the thread and looking at the code I think
> I understand what is happening.
> 
> sysctl, proc, and sysfs all need to wait until there are no
> more users before their unregister operation succeeds.  So that
> we can guarantee that it is safe to remove a module that provides
> the callback function.
> 
> Currently ndo_stop, NETDEV_DOWN, unlist_netdevice and I don't
> know how much other code is run from unregister_netdevice
> with the rtnl lock.  If we do an asynchronous unregister
> we need to ensure that entire code path is safe without
> rtnl_lock.  And we would need to run the unregister work
> from rtnl_lock.
> 
> Ugh.  netdev_store() and a few other functions in net-sysfs.c
> take rtnl_lock.  The instance in netdev_store appears to date
> back to 21 May 2003 sometime during 2.5.
> 
> So this is an old problem that we are just noticing now. Ugh.
> 
> Currently rtnl_lock() protects the netdevice_notifier_chain.
> So it appears we need to hold rtnl_lock().
> 
> Which leads me to conclude either we need to completely rewrite the
> locking rules for the networking stack, or we need to teach the sysfs,
> sysctl, and proc how to grab a subsystem lock around a callback.
> 
> We already do this for netlink with netlink_create_kernel.
> 
> So I guess we need a variants of:
> register_sysctl_table, proc_create, and class_create_file.
> 
> What a pain, but at least it looks like it can work.
> 
> Eric

What about something like this:

Subject: [PATCH] Avoid race between network down and sysfs


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/net-sysfs.c	2009-02-26 08:36:18.000000000 -0800
+++ b/net/core/net-sysfs.c	2009-02-26 08:37:51.000000000 -0800
@@ -77,7 +77,9 @@ static ssize_t netdev_store(struct devic
 	if (endp == buf)
 		goto err;
 
-	rtnl_lock();
+	if (!rtnl_trylock())
+		return -ERESTARTSYS;
+
 	if (dev_isalive(net)) {
 		if ((ret = (*set)(net, new)) == 0)
 			ret = len;
