From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] sctp: optimize searching the active path for tsns
Date: Wed, 13 Mar 2013 09:41:23 -0700
Message-ID: <20130313164123.GA8193@linux.vnet.ibm.com>
References: <513F5120.7090209@gmail.com>
 <1363109382-753-1-git-send-email-nhorman@tuxdriver.com>
 <513F97BE.6040800@gmail.com>
 <20130313012006.GA6958@hmsreliant.think-freely.org>
 <513FD9B8.9010300@gmail.com>
 <20130313132809.GA17592@hmsreliant.think-freely.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel-org,
	Xufeng Zhang <xufengzhang.main@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:39594 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756330Ab3CMQl4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Mar 2013 12:41:56 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 13 Mar 2013 12:41:54 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 53E3538C80A5
	for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 12:41:26 -0400 (EDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2DGfP46180404
	for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 12:41:26 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2DGi0mr000456
	for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 10:44:01 -0600
Content-Disposition: inline
In-Reply-To: <20130313132809.GA17592@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 13, 2013 at 09:28:09AM -0400, Neil Horman wrote:
> On Tue, Mar 12, 2013 at 09:43:20PM -0400, Vlad Yasevich wrote:
> > On 03/12/2013 09:20 PM, Neil Horman wrote:
> > >On Tue, Mar 12, 2013 at 05:01:50PM -0400, Vlad Yasevich wrote:
> > >>Hi Neil
> > >>
> > >>On 03/12/2013 01:29 PM, Neil Horman wrote:
> > >>>SCTP currently attempts to optimize the search for tsns on a transport by first
> > >>>checking the active_path, then searching alternate transports.  This operation
> > >>>however is a bit convoluted, as we explicitly search the active path, then serch
> > >>>all other transports, skipping the active path, when its detected.  Lets
> > >>>optimize this by preforming a move to front on the transport_addr_list every
> > >>>time the active_path is changed.  The active_path changes occur in relatively
> > >>>non-critical paths, and doing so allows us to just search the
> > >>>transport_addr_list in order, avoiding an extra conditional check in the
> > >>>relatively hot tsn lookup path.  This also happens to fix a bug where we break
> > >>>out of the for loop early in the tsn lookup.
> > >>>
> > >>>CC: Xufeng Zhang <xufengzhang.main@gmail.com>
> > >>>CC: vyasevich@gmail.com
> > >>>CC: davem@davemloft.net
> > >>>CC: netdev@vger.kernel.org
> > >>>---
> > >>>  net/sctp/associola.c | 31 ++++++++++++-------------------
> > >>>  1 file changed, 12 insertions(+), 19 deletions(-)
> > >>>
> > >>>diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> > >>>index 43cd0dd..7af96b3 100644
> > >>>--- a/net/sctp/associola.c
> > >>>+++ b/net/sctp/associola.c
> > >>>@@ -513,8 +513,11 @@ void sctp_assoc_set_primary(struct sctp_association *asoc,
> > >>>  	 * user wants to use this new path.
> > >>>  	 */
> > >>>  	if ((transport->state == SCTP_ACTIVE) ||
> > >>>-	    (transport->state == SCTP_UNKNOWN))
> > >>>+	    (transport->state == SCTP_UNKNOWN)) {
> > >>>+		list_del_rcu(&transport->transports);
> > >>>+		list_add_rcu(&transport->transports, &asoc->peer.transport_addr_list);
> > >>>  		asoc->peer.active_path = transport;
> > >>>+	}
> > >>
> > >>What would happen if at the same time someone is walking the list
> > >>through the proc interfaces?
> > >>
> > >>Since you are effectively changing the .next pointer, I think it is
> > >>possible to get a duplicate transport output essentially corrupting
> > >>the output.
> > >>
> > >It would be the case, but you're using the rcu variants of the list_add macros
> > >at all the points where we modify the list (some of which we do at call sites
> > >right before we call set_primary, see sctp_assoc_add_peer, where
> > >list_add_tail_rcu also modifies a next pointer).  So if this is a problem, its a
> > >problem without this patch.  In fact looking at it, our list access to
> > >transport_addr_list is broken, as we use rcu apis to modify the list but non-rcu
> > >apis to traverse the list.  I'll need to fix that first.
> > 
> > As long as we are under lock, we don't need rcu variants for
> > traversal.  The traversals done by the sctp_seq_ functions already
> > use correct rcu variants.
> > 
> > I don't see this as a problem right now since we either delete the
> > transport, or add it.  We don't move it to a new location in the list.
> > With the move, what could happen is that while sctp_seq_ is printing
> > a transport, you might move it to another spot, and the when you grab
> > the .next pointer on the next iteration, it points to a completely
> > different spot.
> > 
> Ok, I see what you're saying, and looking at the seq code, with your description
> I see how we're using half the rcu code to allow the proc interface to avoid
> grabbing the socket lock.  But this just strikes me a poor coding.  Its
> confusing to say the least, and begging for mistakes like the one I just made to
> be made again.  Regardless of necessisty, it seems to me the code would be both
> more readable and understandible if we modified it so that we used the rcu api
> consistently to access that list.

Not sure exactly what the desired behavior is, but if the idea is to be
able to move an element within an RCU-protected list without dragging
RCU readers along (and thus having the readers possibly traverse parts
of the list multiple times), here are some ways of accomplishing this:

o	Insert a synchronize_rcu() between the removal and the
	reinsertion (which means upgrading any spinlocks to mutexes
	or some such).

o	Instead of moving the object, insert a copy after removing
	the old version.  Any readers referencing the old copy would
	continue down the list.  A reader traversing the list between
	the removal of the original and the insertion of the copy might
	miss the moving element.

	You could instead insert the copy before removing the original,
	so that both copies are in the list for a bit, in which case a
	concurrent reader might see both.

o	If it is OK to miss elements but bad to repeat them, instead
	of moving the selected element to the beginning of the list,
	move all items preceding that element to the end of the list.

o	Have a pair of list_heads in each object, along with an index
	telling which of them pair readers should use.  Make the change
	using the non-current set of list_heads.  Flip the index.
	Wait for a grace period before allowing the next update.

On the off-chance that any of this is helpful...  There are probably
other ways of making this work as well.

							Thanx, Paul
