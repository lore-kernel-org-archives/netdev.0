From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: IPv4/IPv6 sysctl unregistration deadlock
Date: Wed, 25 Feb 2009 23:18:42 -0800
Message-ID: <m14oyhis31.fsf@fess.ebiederm.org>
References: <49A4D5D5.5090602@trash.net>
	<20090225061902.GA32430@gondor.apana.org.au>
	<49A4E3F8.4050406@trash.net> <49A4F0D7.20304@trash.net>
	<20090225084321.GA1101@gondor.apana.org.au>
	<m163ixk9t2.fsf@fess.ebiederm.org>
	<20090226062257.GA11511@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:58416 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbZBZHSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 02:18:14 -0500
In-Reply-To: <20090226062257.GA11511@gondor.apana.org.au> (Herbert Xu's message of "Thu\, 26 Feb 2009 14\:22\:57 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> writes:

> On Wed, Feb 25, 2009 at 10:10:33PM -0800, Eric W. Biederman wrote:
>>
>> How does adding a rename operation to sysctl sound?
>
> Yes that would definitely help.  Of course for the unregister case
> we'd still need either an async removal or a no-op as Patrick
> suggested.

After having reread the thread and looking at the code I think
I understand what is happening.

sysctl, proc, and sysfs all need to wait until there are no
more users before their unregister operation succeeds.  So that
we can guarantee that it is safe to remove a module that provides
the callback function.

Currently ndo_stop, NETDEV_DOWN, unlist_netdevice and I don't
know how much other code is run from unregister_netdevice
with the rtnl lock.  If we do an asynchronous unregister
we need to ensure that entire code path is safe without
rtnl_lock.  And we would need to run the unregister work
from rtnl_lock.

Ugh.  netdev_store() and a few other functions in net-sysfs.c
take rtnl_lock.  The instance in netdev_store appears to date
back to 21 May 2003 sometime during 2.5.

So this is an old problem that we are just noticing now. Ugh.

Currently rtnl_lock() protects the netdevice_notifier_chain.
So it appears we need to hold rtnl_lock().

Which leads me to conclude either we need to completely rewrite the
locking rules for the networking stack, or we need to teach the sysfs,
sysctl, and proc how to grab a subsystem lock around a callback.

We already do this for netlink with netlink_create_kernel.

So I guess we need a variants of:
register_sysctl_table, proc_create, and class_create_file.

What a pain, but at least it looks like it can work.

Eric
