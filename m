From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: optimize searching the active path for tsns
Date: Wed, 13 Mar 2013 10:21:04 -0400
Message-ID: <20130313142104.GE17592@hmsreliant.think-freely.org>
References: <513F5120.7090209@gmail.com>
 <1363109382-753-1-git-send-email-nhorman@tuxdriver.com>
 <513F97BE.6040800@gmail.com>
 <20130313012006.GA6958@hmsreliant.think-freely.org>
 <513FD9B8.9010300@gmail.com>
 <20130313132809.GA17592@hmsreliant.think-freely.org>
 <514087F3.5080601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Xufeng Zhang <xufengzhang.main@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47798 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933256Ab3CMOVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 10:21:13 -0400
Content-Disposition: inline
In-Reply-To: <514087F3.5080601@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 13, 2013 at 10:06:43AM -0400, Vlad Yasevich wrote:
> On 03/13/2013 09:28 AM, Neil Horman wrote:
> >On Tue, Mar 12, 2013 at 09:43:20PM -0400, Vlad Yasevich wrote:
> >>On 03/12/2013 09:20 PM, Neil Horman wrote:
> >>>On Tue, Mar 12, 2013 at 05:01:50PM -0400, Vlad Yasevich wrote:
> >>>>Hi Neil
> >>>>
> >>>>On 03/12/2013 01:29 PM, Neil Horman wrote:
> >>>>>SCTP currently attempts to optimize the search for tsns on a transport by first
> >>>>>checking the active_path, then searching alternate transports.  This operation
> >>>>>however is a bit convoluted, as we explicitly search the active path, then serch
> >>>>>all other transports, skipping the active path, when its detected.  Lets
> >>>>>optimize this by preforming a move to front on the transport_addr_list every
> >>>>>time the active_path is changed.  The active_path changes occur in relatively
> >>>>>non-critical paths, and doing so allows us to just search the
> >>>>>transport_addr_list in order, avoiding an extra conditional check in the
> >>>>>relatively hot tsn lookup path.  This also happens to fix a bug where we break
> >>>>>out of the for loop early in the tsn lookup.
> >>>>>
> >>>>>CC: Xufeng Zhang <xufengzhang.main@gmail.com>
> >>>>>CC: vyasevich@gmail.com
> >>>>>CC: davem@davemloft.net
> >>>>>CC: netdev@vger.kernel.org
> >>>>>---
> >>>>>  net/sctp/associola.c | 31 ++++++++++++-------------------
> >>>>>  1 file changed, 12 insertions(+), 19 deletions(-)
> >>>>>
> >>>>>diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> >>>>>index 43cd0dd..7af96b3 100644
> >>>>>--- a/net/sctp/associola.c
> >>>>>+++ b/net/sctp/associola.c
> >>>>>@@ -513,8 +513,11 @@ void sctp_assoc_set_primary(struct sctp_association *asoc,
> >>>>>  	 * user wants to use this new path.
> >>>>>  	 */
> >>>>>  	if ((transport->state == SCTP_ACTIVE) ||
> >>>>>-	    (transport->state == SCTP_UNKNOWN))
> >>>>>+	    (transport->state == SCTP_UNKNOWN)) {
> >>>>>+		list_del_rcu(&transport->transports);
> >>>>>+		list_add_rcu(&transport->transports, &asoc->peer.transport_addr_list);
> >>>>>  		asoc->peer.active_path = transport;
> >>>>>+	}
> >>>>
> >>>>What would happen if at the same time someone is walking the list
> >>>>through the proc interfaces?
> >>>>
> >>>>Since you are effectively changing the .next pointer, I think it is
> >>>>possible to get a duplicate transport output essentially corrupting
> >>>>the output.
> >>>>
> >>>It would be the case, but you're using the rcu variants of the list_add macros
> >>>at all the points where we modify the list (some of which we do at call sites
> >>>right before we call set_primary, see sctp_assoc_add_peer, where
> >>>list_add_tail_rcu also modifies a next pointer).  So if this is a problem, its a
> >>>problem without this patch.  In fact looking at it, our list access to
> >>>transport_addr_list is broken, as we use rcu apis to modify the list but non-rcu
> >>>apis to traverse the list.  I'll need to fix that first.
> >>
> >>As long as we are under lock, we don't need rcu variants for
> >>traversal.  The traversals done by the sctp_seq_ functions already
> >>use correct rcu variants.
> >>
> >>I don't see this as a problem right now since we either delete the
> >>transport, or add it.  We don't move it to a new location in the list.
> >>With the move, what could happen is that while sctp_seq_ is printing
> >>a transport, you might move it to another spot, and the when you grab
> >>the .next pointer on the next iteration, it points to a completely
> >>different spot.
> >>
> >Ok, I see what you're saying, and looking at the seq code, with your description
> >I see how we're using half the rcu code to allow the proc interface to avoid
> >grabbing the socket lock.  But this just strikes me a poor coding.  Its
> >confusing to say the least, and begging for mistakes like the one I just made to
> >be made again.  Regardless of necessisty, it seems to me the code would be both
> >more readable and understandible if we modified it so that we used the rcu api
> >consistently to access that list.
> >Neil
> >
> 
> Can you elaborate a bit on why you believe we are using half of the
> rcu code?
> 
We're using the rcu list add/del apis on the write side when
we modify the transport_addr_list, but we're using the non-rcu primitives on the
read side, save for the proc interface.  Granted that generally safe, exepct for
any case in which you do exactly what we were speaking about above.  I know were
not doing that now, but it seems to me it would be better to use the rcu
primitives consistently, so that it was clear how to access the list.  It would
prevent mistakes like the one I just made, as well as other possible mistakes,
in which future coding errors.

> I think to support the move operation you are proposing here, you
> need something like
> 	list_for_each_entry_safe_rcu()
> 
Not to the best of my knoweldge.  Consistent use of the rcu list access
primitives is safe against rcu list mutation primitives, as long as the read
side is protected by the rcu_read_lock.  As long as thats locked, any mutations
won't be seen by the read context until after we exit the read side critical
section.

> where the .next pointer is fetched through rcu_dereference() to
> guard against its possible.
> 
You won't see the updated next pointer until the read critical side ends.  Thats
why you need to do an rcu_read_lock in addition to grabbing the socket lock.

> But even that would only work if the move happens to the the earlier
> spot (like head) of the list.  If the move happens to the later part
> of the list (like tail), you may end up visiting the same list node
> twice.
> 
Again, not if you hold the rcu_read_lock.  Doing so creates a quiescent point in
which the status of the list is held until such time as read side critical
section exits.  The move (specifically the delete and the add) won't be seen by
the reading context until that quiescent point completes, which by definition is
when that reader is done reading.

Neil

> I think rcu simply can't guard against this.
> 
> -vlad
> 
> 
