From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net 2/2] net: core: explicitly select a txq before doing
 l2 forwarding
Date: Wed, 8 Jan 2014 09:40:25 -0500
Message-ID: <20140108144025.GA17802@neilslaptop.think-freely.org>
References: <1388978467-2075-1-git-send-email-jasowang@redhat.com>
 <1388978467-2075-2-git-send-email-jasowang@redhat.com>
 <20140106124248.GB24280@hmsreliant.think-freely.org>
 <52CB77A0.3030106@redhat.com>
 <20140107131730.GA12366@hmsreliant.think-freely.org>
 <52CCC431.3060403@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52046 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755435AbaAHOkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 09:40:42 -0500
Content-Disposition: inline
In-Reply-To: <52CCC431.3060403@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 08, 2014 at 11:21:21AM +0800, Jason Wang wrote:
> On 01/07/2014 09:17 PM, Neil Horman wrote:
> > On Tue, Jan 07, 2014 at 11:42:24AM +0800, Jason Wang wrote:
> >> On 01/06/2014 08:42 PM, Neil Horman wrote:
> >>> On Mon, Jan 06, 2014 at 11:21:07AM +0800, Jason Wang wrote:
> >>>> Currently, the tx queue were selected implicitly in ndo_dfwd_start_xmit(). The
> >>>> will cause several issues:
> >>>>
> >>>> - NETIF_F_LLTX was forced for macvlan device in this case which lead extra lock
> >>>>   contention.
> >>>> - dev_hard_start_xmit() was called with NULL txq which bypasses the net device
> >>>>   watchdog
> >>>> - dev_hard_start_xmit() does not check txq everywhere which will lead a crash
> >>>>   when tso is disabled for lower device.
> >>>>
> >>>> Fix this by explicitly introducing a select queue method just for l2 forwarding
> >>>> offload (ndo_dfwd_select_queue), and introducing dfwd_direct_xmit() to do the
> >>>> queue selecting and transmitting for l2 forwarding.
> >>>>
> >>>> With this fixes, NETIF_F_LLTX could be preserved for macvlan and there's no need
> >>>> to check txq against NULL in dev_hard_start_xmit().
> >>>>
> >>>> In the future, it was also required for macvtap l2 forwarding support since it
> >>>> provides a necessary synchronization method.
> >>>>
> >>>> Cc: John Fastabend <john.r.fastabend@intel.com>
> >>>> Cc: Neil Horman <nhorman@tuxdriver.com>
> >>>> Cc: e1000-devel@lists.sourceforge.net
> >>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> >>> Instead of creating another operation here to do special queue selection, why
> >>> not just have ndo_dfwd_start_xmit include a pointer to a pointer in its argument
> >>> list, so it can pass the txq it used back to the caller (dev_hard_start_xmit)?
> >>> ndo_dfwd_start_xmit already knows which queue set to pick from (since their
> >>> reserved for the device doing the transmitting).  It seems more clear to me than
> >>> creating a new netdevice operation.  
> >> See commit 8ffab51b3dfc54876f145f15b351c41f3f703195 ("macvlan: lockless
> >> tx path"). The point is keep the tx path lockless to be efficient and
> >> simplicity for management. And macvtap multiqueue was also implemented
> >> with this assumption. The real contention should be done in the txq of
> >> lower device instead of macvlan itself. This is also needed for
> >> multiqueue macvtap.
> > Ok, I see how you're preserving LLTX here, and thats great, but it doesn't
> > really buy us anything that I can see.  If a macvlan is using hardware
> > acceleration, it needs to arbitrate access to that hardware.  Weather thats done
> > by locking the lowerdev's tx queue lock or by enforcing locking on the macvlan
> > itself is equivalent.  The decision to use dfwd hardware acceleration is made on
> > open, so its not like theres any traffic that can avoid the lock, as it all goes
> > through the hardware.  All I see that this has bought us is an extra net_device
> > method (which isn't a big deal, but not necessecary as I see it).
> 
> As I replied to patch 1/2, looking at the code itself again. The locking
> on the lowerdev's tx queue is really need since we need synchronize with
> other control path. Two examples are dev watchdog and ixgbe_down() both
> of which will try to hold tx lock to synchronize the with transmission.
> Without holding the lowerdev tx lock, we may have more serious issues.
> Also, it's a little strange for a net device has two modes. Future
> developers need to care about two different tx lock paths which is sub
> optimal.
> 

Ok, having looked at this for a few hours, I agree, locking in the lowerdev has
some definiate advantages in plugging the holes you've pointed out.

> For the issue of an extra net_device method,  if you don't like we can
> reuse the ndo_select_queue by also passing the accel_priv to that method.
I do, that actually simplifies things, since it lets us use the entire
dev_hard_start_xmit path unmodified, which gives us the locking your looking for
without having to create a new slimmed down variant of dev_hard_start_xmit.

Regards
Neil
