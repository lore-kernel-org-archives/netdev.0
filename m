From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: don't break the loop while meeting the active_path
 so as to find the matched transport
Date: Tue, 12 Mar 2013 11:44:27 -0400
Message-ID: <20130312154427.GA5969@neilslaptop.think-freely.org>
References: <1362728377-11025-1-git-send-email-xufeng.zhang@windriver.com>
 <20130308142720.GA9873@hmsreliant.think-freely.org>
 <CA+=dFzjyd4av9D1TmrvguRXv-V7JnGWYJcN=ZEDu8Qhz2s+U7Q@mail.gmail.com>
 <20130311133121.GD12682@hmsreliant.think-freely.org>
 <513F1B76.2060603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Xufeng Zhang <xufengzhang.main@gmail.com>,
	Xufeng Zhang <xufeng.zhang@windriver.com>, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <513F1B76.2060603@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 12, 2013 at 08:11:34AM -0400, Vlad Yasevich wrote:
> On 03/11/2013 09:31 AM, Neil Horman wrote:
> >On Mon, Mar 11, 2013 at 10:14:50AM +0800, Xufeng Zhang wrote:
> >>On 3/8/13, Neil Horman <nhorman@tuxdriver.com> wrote:
> >>>On Fri, Mar 08, 2013 at 03:39:37PM +0800, Xufeng Zhang wrote:
> >>>>sctp_assoc_lookup_tsn() function searchs which transport a certain TSN
> >>>>was sent on, if not found in the active_path transport, then go search
> >>>>all the other transports in the peer's transport_addr_list, however, we
> >>>>should continue to the next entry rather than break the loop when meet
> >>>>the active_path transport.
> >>>>
> >>>>Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
> >>>>---
> >>>>  net/sctp/associola.c |    2 +-
> >>>>  1 files changed, 1 insertions(+), 1 deletions(-)
> >>>>
> >>>>diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> >>>>index 43cd0dd..d2709e2 100644
> >>>>--- a/net/sctp/associola.c
> >>>>+++ b/net/sctp/associola.c
> >>>>@@ -1079,7 +1079,7 @@ struct sctp_transport *sctp_assoc_lookup_tsn(struct
> >>>>sctp_association *asoc,
> >>>>  			transports) {
> >>>>
> >>>>  		if (transport == active)
> >>>>-			break;
> >>>>+			continue;
> >>>>  		list_for_each_entry(chunk, &transport->transmitted,
> >>>>  				transmitted_list) {
> >>>>  			if (key == chunk->subh.data_hdr->tsn) {
> >>>>--
> >>>>1.7.0.2
> >>>>
> >>>>
> >>>
> >>>This works, but what might be better would be if we did a move to front
> >>>heuristic in sctp_assoc_set_primary.  E.g. when we set the active_path, move
> >>>the
> >>>requisite transport to the front of the transport_addr_list.  If we did
> >>>that,
> >>>then we could just do one for loop in sctp_assoc_lookup_tsn and wind up
> >>>implicitly check the active path first without having to check it seprately
> >>>and
> >>>skip it in the second for loop.
> >>
> >>Thanks for your review, Neil!
> >>
> >>I know what you mean, yes, it's most probably that the searched TSN was
> >>transmitted in the currently active_path, but what should we do if not.
> >>
> >>Check the comment in sctp_assoc_lookup_tsn() function:
> >>/* Let's be hopeful and check the active_path first. */
> >>/* If not found, go search all the other transports. */
> >>
> >>It has checked the active_path first and then traverse all the other
> >>transports in
> >>the transport_addr_list except the active_path.
> >>
> >>So what I want to fix here is the inconsistency between the function
> >>should do and
> >>the code actually does.
> >>
> >I understand what you're doing, and I agree that the fix is functional (Hence
> >my "This works" statement in my last note).  What I'm suggesting is that, since
> >you're messing about in that code anyway that you clean it up while your at it,
> >so that we don't need to have the if (transport == active) check at all.  We
> >trade in some extra work in a non-critical path (sctp_assoc_set_primary), for
> >the removal of an extra for loop operation and a conditional check in a much
> >hotter path.  Something like this (completely untested), is what I was thinking
> >
> >
> >diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> >index 43cd0dd..8ae873c 100644
> >--- a/net/sctp/associola.c
> >+++ b/net/sctp/associola.c
> >@@ -505,6 +505,9 @@ void sctp_assoc_set_primary(struct sctp_association *asoc,
> >
> >  	asoc->peer.primary_path = transport;
> >
> >+	list_del_rcu(&transport->transports);
> >+	list_add_rcu(&transport->transports, &asoc->peer.transport_addr_list);
> >+
> >  	/* Set a default msg_name for events. */
> >  	memcpy(&asoc->peer.primary_addr, &transport->ipaddr,
> >  	       sizeof(union sctp_addr));
> >@@ -1040,7 +1043,6 @@ struct sctp_chunk *sctp_get_ecne_prepend(struct sctp_association *asoc)
> >  struct sctp_transport *sctp_assoc_lookup_tsn(struct sctp_association *asoc,
> >  					     __u32 tsn)
> >  {
> >-	struct sctp_transport *active;
> >  	struct sctp_transport *match;
> >  	struct sctp_transport *transport;
> >  	struct sctp_chunk *chunk;
> >@@ -1057,29 +1059,16 @@ struct sctp_transport *sctp_assoc_lookup_tsn(struct sctp_association *asoc,
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
> 
> Neil, active_patch != primary_path all the time.  In fact, when you
> have path primary path failure, active path will change while
> primary
> may only change when the user says so.
Thats a good point, thank you Vlad.  We would need to only update the
transport_addr_list in set_primary if its state is ACTIVE or UNKNOWN.  We would
also need to update it if the active path changes in
sctp_assoc_control_transport, if the new active path is different from the old.
Both of those paths however are not intended to be run frequently, so I think
this is still a viable optimization.  I'm working on it now.
Neil

> 
> So, you may still get into a situation where primary and active
> paths are different.
> 
> The optimization here may not work at all under those circumstances.
> 
> -vlad
> 
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
