From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: optimize searching the active path for tsns
Date: Tue, 12 Mar 2013 21:20:07 -0400
Message-ID: <20130313012006.GA6958@hmsreliant.think-freely.org>
References: <513F5120.7090209@gmail.com>
 <1363109382-753-1-git-send-email-nhorman@tuxdriver.com>
 <513F97BE.6040800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel-org,
	Xufeng Zhang <xufengzhang.main@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40584 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755507Ab3CMBUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 21:20:23 -0400
Content-Disposition: inline
In-Reply-To: <513F97BE.6040800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 12, 2013 at 05:01:50PM -0400, Vlad Yasevich wrote:
> Hi Neil
> 
> On 03/12/2013 01:29 PM, Neil Horman wrote:
> >SCTP currently attempts to optimize the search for tsns on a transport by first
> >checking the active_path, then searching alternate transports.  This operation
> >however is a bit convoluted, as we explicitly search the active path, then serch
> >all other transports, skipping the active path, when its detected.  Lets
> >optimize this by preforming a move to front on the transport_addr_list every
> >time the active_path is changed.  The active_path changes occur in relatively
> >non-critical paths, and doing so allows us to just search the
> >transport_addr_list in order, avoiding an extra conditional check in the
> >relatively hot tsn lookup path.  This also happens to fix a bug where we break
> >out of the for loop early in the tsn lookup.
> >
> >CC: Xufeng Zhang <xufengzhang.main@gmail.com>
> >CC: vyasevich@gmail.com
> >CC: davem@davemloft.net
> >CC: netdev@vger.kernel.org
> >---
> >  net/sctp/associola.c | 31 ++++++++++++-------------------
> >  1 file changed, 12 insertions(+), 19 deletions(-)
> >
> >diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> >index 43cd0dd..7af96b3 100644
> >--- a/net/sctp/associola.c
> >+++ b/net/sctp/associola.c
> >@@ -513,8 +513,11 @@ void sctp_assoc_set_primary(struct sctp_association *asoc,
> >  	 * user wants to use this new path.
> >  	 */
> >  	if ((transport->state == SCTP_ACTIVE) ||
> >-	    (transport->state == SCTP_UNKNOWN))
> >+	    (transport->state == SCTP_UNKNOWN)) {
> >+		list_del_rcu(&transport->transports);
> >+		list_add_rcu(&transport->transports, &asoc->peer.transport_addr_list);
> >  		asoc->peer.active_path = transport;
> >+	}
> 
> What would happen if at the same time someone is walking the list
> through the proc interfaces?
> 
> Since you are effectively changing the .next pointer, I think it is
> possible to get a duplicate transport output essentially corrupting
> the output.
> 
It would be the case, but you're using the rcu variants of the list_add macros
at all the points where we modify the list (some of which we do at call sites
right before we call set_primary, see sctp_assoc_add_peer, where
list_add_tail_rcu also modifies a next pointer).  So if this is a problem, its a
problem without this patch.  In fact looking at it, our list access to
transport_addr_list is broken, as we use rcu apis to modify the list but non-rcu
apis to traverse the list.  I'll need to fix that first.

> Personally, I don't think that this particular case is worth the
> optimization since we are trying to optimize a TSN search that only
> happens when ECNE chunk is received.  You say that it is a hot path.
> Is ECNE really such a common occurrence?
> 
Not particularly, but I'm guessing its more used than the path that switches the
active path.  Plus its just more elegant, modifying the list so we don't have to
have two identical for loops in the lookup_tsn function, plus a check for the
transport that we already checked.

> Additionally, I don't think this is really an optimization as the
> current and new code do exactly the same thing:
>  1) look at active path
>  2) look at the rest of the paths
> 
Thats not the optimization, its trading where we do work in the interests of
making the more used path faster (we drop an if condition, and remove some
duplicated code).

> This just makes cleaner code at the expense of list shuffling.
> 
Yes, that sounds like a good trade to me. But as noted above, we probably need
to fix the transport_addr_list access first.
Neil

> -vlad
> >
> >  	/*
> >  	 * SFR-CACC algorithm:
> >@@ -964,6 +967,10 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
> >  	}
> >
> >  	/* Set the active and retran transports.  */
> >+	if (asoc->peer.active_path != first) {
> >+		list_del_rcu(first);
> >+		list_add_rcu(first, &asoc->peer.transport_addr_list);
> >+	}
> >  	asoc->peer.active_path = first;
> >  	asoc->peer.retran_path = second;
> >  }
> >@@ -1040,7 +1047,6 @@ struct sctp_chunk *sctp_get_ecne_prepend(struct sctp_association *asoc)
> >  struct sctp_transport *sctp_assoc_lookup_tsn(struct sctp_association *asoc,
> >  					     __u32 tsn)
> >  {
> >-	struct sctp_transport *active;
> >  	struct sctp_transport *match;
> >  	struct sctp_transport *transport;
> >  	struct sctp_chunk *chunk;
> >@@ -1057,29 +1063,16 @@ struct sctp_transport *sctp_assoc_lookup_tsn(struct sctp_association *asoc,
> >  	 * The general strategy is to search each transport's transmitted
> >  	 * list.   Return which transport this TSN lives on.
> >  	 *
> >-	 * Let's be hopeful and check the active_path first.
> >-	 * Another optimization would be to know if there is only one
> >-	 * outbound path and not have to look for the TSN at all.
> >+	 * Note, that sctp_assoc_set_primary does a move to front operation
> >+	 * on the active_path transport, so this code implicitly checks
> >+	 * the active_path first, as we most commonly expect to find our TSN
> >+	 * there.
> >  	 *
> >  	 */
> >
> >-	active = asoc->peer.active_path;
> >-
> >-	list_for_each_entry(chunk, &active->transmitted,
> >-			transmitted_list) {
> >-
> >-		if (key == chunk->subh.data_hdr->tsn) {
> >-			match = active;
> >-			goto out;
> >-		}
> >-	}
> >-
> >-	/* If not found, go search all the other transports. */
> >  	list_for_each_entry(transport, &asoc->peer.transport_addr_list,
> >  			transports) {
> >
> >-		if (transport == active)
> >-			break;
> >  		list_for_each_entry(chunk, &transport->transmitted,
> >  				transmitted_list) {
> >  			if (key == chunk->subh.data_hdr->tsn) {
> >
> 
> 
