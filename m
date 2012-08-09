From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next] bonding: don't allow the master to become its slave
Date: Thu, 9 Aug 2012 22:09:53 +0100
Message-ID: <1344546593.2593.24.camel@bwh-desktop.uk.solarflarecom.com>
References: <1344537049-11473-1-git-send-email-fbl@redhat.com>
	 <1344539003.2593.7.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120809163906.6dc0b6d4@obelix.rh>
	 <20120809195539.GB1783@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Flavio Leitner <fbl@redhat.com>, netdev <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Leonardo Chiquitto <lchiquitto@suse.com>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13251 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754042Ab2HIVJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 17:09:57 -0400
In-Reply-To: <20120809195539.GB1783@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-09 at 21:55 +0200, Jiri Pirko wrote:
> Thu, Aug 09, 2012 at 09:39:06PM CEST, fbl@redhat.com wrote:
> >On Thu, 9 Aug 2012 20:03:23 +0100
> >Ben Hutchings <bhutchings@solarflare.com> wrote:
> >
> >> On Thu, 2012-08-09 at 15:30 -0300, Flavio Leitner wrote:
> >> > It doesn't make any sense to allow the master to become
> >> > its slave. That creates a loop of events causing a crash.
> >> 
> >> What if there are other intermediate devices, e.g. the slave is a VLAN
> >> sub-device of the bond?  And doesn't team also have this problem?
> >> 
> >> I think a more general check for such loops might be required.
> >
> >Maybe patching netdev_set_master() to fail in the loop case is
> >the way to go.  That would work for bonding, team and bridge.
> >
> >What you think?
> 
> 
> How about other devices who do not use "->master" like vlan, macvlan?

And they shouldn't use master, because they allow multiple upper devices
may be stacked on a single lower device.  Instead they use iflink, but
that's an ifindex and not a net_device pointer.

So I think we can catch simple loops with:

--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4445,8 +4445,22 @@ int netdev_set_master(struct net_device *slave, struct net_device *master)
 	ASSERT_RTNL();
 
 	if (master) {
+		struct net_device *bottom, *top;
+
 		if (old)
 			return -EBUSY;
+
+		/* Prevent loops */
+		bottom = slave;
+		while (bottom->iflink != bottom->ifindex)
+			bottom = __dev_get_by_index(dev_net(bottom),
+						    bottom->iflink);
+		top = master;
+		while (top->master)
+			top = top->master;
+		if (top == bottom)
+			return -EBUSY;
+
 		dev_hold(master);
 	}
 
--- END ---

But then there can be quite silly device relationships like:

               +-------+
               | bond0 |
               ++-----++
               /       \
+-------+ +---+---+ +---+---+ +-------+
| vlan0 | | vlan1 | | vlan2 | | vlan3 |
+---+---+ +---+---+ +---+---+ +---+---+
     \       /           \       /
     ++-----++           ++--+--++
     | bond1 |           | bond2 |
     +-------+           +-------+
      :     :             :     :

Suppose the user tries to make bond0 a slave of bond1; we need to go to
somewhat more effort to detect the loop.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
