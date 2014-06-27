From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 01/13] tipc: eliminate case of writing to freed
 memory
Date: Fri, 27 Jun 2014 07:41:02 -0400
Message-ID: <20140627114101.GA9138@hmsreliant.think-freely.org>
References: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
 <1403746902-20408-2-git-send-email-jon.maloy@ericsson.com>
 <20140626105656.GA16025@hmsreliant.think-freely.org>
 <53ACE5F0.3050608@donjonn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jon Maloy <jon.maloy@ericsson.com>, davem@davemloft.net,
	netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com,
	tipc-discussion@lists.sourceforge.net
To: Jon Maloy <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49967 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596AbaF0LlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 07:41:18 -0400
Content-Disposition: inline
In-Reply-To: <53ACE5F0.3050608@donjonn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 26, 2014 at 10:33:04PM -0500, Jon Maloy wrote:
> On 06/26/2014 05:56 AM, Neil Horman wrote:
> > On Wed, Jun 25, 2014 at 08:41:30PM -0500, Jon Maloy wrote:
> >> In the function tipc_nodesub_notify() we call a function pointer
> >> aggregated into the object to be notified, whereafter we set
> >> the function pointer to NULL. However, in some cases the function
> >> pointed to will free the struct containing the function pointer,
> >> resulting in a write to already freed memory.
> >>
> >> This bug seems to always have been there, without causing any
> >> notable harm.
> >>
> >> In this commit we fix the problem by inverting the order of the
> >> zeroing and the function call.
> >>
> >> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
> >> ---
> >>  net/tipc/node_subscr.c |    6 ++++--
> >>  1 file changed, 4 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/net/tipc/node_subscr.c b/net/tipc/node_subscr.c
> >> index 7c59ab1..2d13eea 100644
> >> --- a/net/tipc/node_subscr.c
> >> +++ b/net/tipc/node_subscr.c
> >> @@ -84,11 +84,13 @@ void tipc_nodesub_unsubscribe(struct tipc_node_subscr *node_sub)
> >>  void tipc_nodesub_notify(struct list_head *nsub_list)
> >>  {
> >>  	struct tipc_node_subscr *ns, *safe;
> >> +	net_ev_handler handle_node_down;
> >>  
> >>  	list_for_each_entry_safe(ns, safe, nsub_list, nodesub_list) {
> >> -		if (ns->handle_node_down) {
> >> -			ns->handle_node_down(ns->usr_handle);
> >> +		handle_node_down = ns->handle_node_down;
> >> +		if (handle_node_down) {
> >>  			ns->handle_node_down = NULL;
> >> +			handle_node_down(ns->usr_handle);
> >>  		}
> >>  	}
> >>  }
> > If its true that some functions pointed to by handle_node_down free the struct
> > pointing to the function pointer, than this change isn't sufficient.  The only
> > caller to tipc_nodesub_notify is node_lost_contact, which dereferences the same
> > structure right after the call to tipc_nodesub_notify.
> 
> In think you misunderstand. The pointer (n_ptr*) passed as parameter in
> node_sub_notify() points to a struct of type tipc_node. This one is *not*
> freed during the call. But it aggregates a linked list of structs of type
> nsub. Those are the ones containing the mentioned function pointer, and
> the ones potentially being being released during the traversal of the list.
> 
> I cannot see that any of these struct are references after the call to
> node_sub_notify().
> 
> ///jon
>  
You're right, I was looking at Linus' tree, not the net-next tree.  In the
former, the struct as a whole, not the list_head is passed in.

Neil

> 
> 
> >
> > Neil
> >
> >> -- 
> >> 1.7.9.5
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe netdev" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> 
> 
