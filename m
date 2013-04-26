From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v6 0/4] Add packet recirculation
Date: Fri, 26 Apr 2013 11:42:46 +0900
Message-ID: <20130426024245.GC31993@verge.net.au>
References: <1366100051-14772-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ravi K <rkerur@gmail.com>, Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>, Ben Pfaff <blp@nicira.com>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:47689 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932462Ab3DZCmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 22:42:50 -0400
Content-Disposition: inline
In-Reply-To: <1366100051-14772-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse,

On Tue, Apr 16, 2013 at 05:14:06PM +0900, Simon Horman wrote:
> Recirculation is a technique to allow a frame to re-enter
> frame processing. This is intended to be used after actions
> have been applied to the frame with modify the frame in
> some way that makes it possible for richer processing to occur.
> 
> An example is and indeed targeted use case is MPLS. If an MPLS frame has an
> mpls_pop action applied with the IPv4 ethernet type then it becomes
> possible to decode the IPv4 portion of the frame. This may be used to
> construct a facet that modifies the IPv4 portion of the frame. This is not
> possible prior to the mpls_pop action as the contents of the frame after
> the MPLS stack is not known to be IPv4.

I'm wondering if you could look over this, I believe it
addresses all the issues raised in your review of v5.

> 
> 
> Status:
> 
> I have dropped the RFC prefix from this series as I now believe
> it is feature-complete. Any and all review is greatly appreciated.
> 
> Design:
> 
> * New recirculation action.
> 
>   ovs-vswitchd adds a recirculation action to the end of a list of
>   datapath actions for a flow when the actions are truncated because
>   insufficient flow match information is available to add the next
>   OpenFlow action.  The recirculation action is preceded by an action
>   to set the skb_mark to an id which can be used to scope a facet lookup
>   of a recirculated packet.
> 
>   e.g.  pop_mpls(0x0800),dec_ttl becomes pop_mpls(0x800),set(skb_mark(id)),recirculate
> 
> * Datapath behaviour
> 
>   Then the datapath encounters a recirculate action it:
>   + Recalculates the flow key based on the packet
>     which will typically have been modified by previous actions
>   + As the recirculate action is preceded by a set(skb_mark(id)) action,
>     the new match key will now include skb_mark=id.
>   + Performs a lookup using the new match key
>   + Processes the packet if a facet matches the key or;
>   + Makes an upcall if necessary
> 
> * No facet behaviour
> 
>   + Loop:
>     1) translate actions
>     2) If there is a recirculate action, execute packet
>        and go back to 1) for remaining actions.
> 
> 
> Base/Pre-requisites:
> 
> This patch depends on "[PATCH v2.24] datapath: Add basic MPLS support to kernel".
> There are currently no other patches in the recirculation series.
> 
> 
> Availability:
> 
> For reference this patch is available in git at:
> git://github.com/horms/openvswitch.git devel/mpls-recirculate.v6
> 
> 
> Change Log:
> 
> v6
> * Rearange patches so as only to add self-contained working chages
> * Create execute_actions() in lib/execute-actions.c
>   - This moves makes much more action execution code than before
>     from the user-spcace datapath into common library code.
> * Add set skb_priority support to execute_set_action()
> * Add set tunnel support to execute_set_action()
> * Support revalidation of facets for recirculated packets
> * Address other elements Jesse's review, as noted in
>   per-patch changelogs
> 
> 
> v5
> * Correct declaration of facet_find_by_id to match definition:
>   ovs_be32 -> uint32_t.
> * Enhancements to recirculation id code:
>   - Allow efficient lookup of facets by their recirculation id
>   - Add RECIRCULATION_ID_DUMMY which may be used in cases
>     where no facet it used. It is an arbitrary valid id.
>   - Also add recirculated element to action_xlate_ctx()
>     to use to detect if a recirculation action was added during
>     translation. The previous scheme of checking if recirculation_id
>     was not RECIRCULATION_ID_NONE is broken for cases where
>     the context is initialised with a recirculation_id other than
>     RECIRCULATION_ID_NONE. E.g. when RECIRCULATION_ID_DUMMY is used.
>   - Avoid id collision
> 
> rfc4:
> * Allow recirculation without facets in ovs-vswitchd
>   - Handle flow miss without facet
>   - Packet out
> * Minor enhancement to recirculation id management: Add RECIRCULATE_ID_NONE
>   to use instead of using 0 directly.
> * Correct calculation of facet->recirculation_ofpacts and
>   facet->recirculation_ofpacts_len in subfacet_make_actions()
>   in the case of more than one level of recirculation.
> 
> rfc3
> * Use IS_ERR_OR_NULL()
> * Handle facet consistency checking by constructing a chain of facets
>   from the given facet, to its recirculation parent and then its parent
>   until the topmost facet.  If there is no recirculation  the chain will
>   be of length one. If there is one recirculation action then the chain
>   will be of length two. And so on.
> 
>   The topmost facet in the chain can is used to lookup the rule to be
>   verified. The chain is then walked from top to bottom, translating
>   actions up to the end or the first recirculation action that is
>   encountered, whichever comes first. As the code walks down the chain
>   it updates the actions that are executed to start of the actions to
>   be executed to be just after the end of the actions executed in the
>   previous facet in the chain. This is similar to the way that facets
>   are created when a recirculation action is encountered.
> 
> rfc2
> * As suggested by Jesse Gross
>   - Update for changes to ovs_dp_process_received_packet()
>     to no longer check if OVS_CB(skb)->flow is pre-initialised.
>   - Do not add spurious printk debugging to ovs_execute_actions()
>   - Do not add spurious debugging messages to commit_set_nw_action()
>   - Correct typo in comment above commit_odp_actions().
>   - Do not execute recirculation in ovs-vswitchd, rather allow
>     the datapath to make an upcall when a recirculation action
>     is encountered on execute.
>     + This implicitly breaks support for recirculation without facets,
>       so for now force all misses of MPLS frames to be handled with
>       a facet; and treat handling of recirculation for packet_out as
>       a todo item.
>   - Use skb_mark for recirculation_id in match. This avoids
>     both expanding the match and including a recirculation_id parameter
>     with the recirculation action: set_skb_mark should be used before
>     the recirculation action.
>   - Tidy up ownership of skb in ovs_execute_actions
> 
> rfc1
> * Initial post
> 
> 
> Patch List and Diffstat:
> 
> Simon Horman (5):
>   Add execute_actions
>   Add set skb_mark support to execute_set_action
>   Add set skb_priority support to execute_set_action
>   Add set tunnel support to execute_set_action
>   Add packet recirculation
> 
>  datapath/actions.c          |    9 +-
>  datapath/datapath.c         |  105 ++++---
>  datapath/datapath.h         |    2 +-
>  include/linux/openvswitch.h |    4 +
>  lib/automake.mk             |    2 +
>  lib/dpif-netdev.c           |  249 +++++-----------
>  lib/execute-actions.c       |  225 +++++++++++++++
>  lib/execute-actions.h       |   34 +++
>  lib/flow.h                  |    4 +
>  lib/odp-util.c              |   17 +-
>  lib/odp-util.h              |    4 +
>  ofproto/ofproto-dpif.c      |  675 ++++++++++++++++++++++++++++++++++++++-----
>  12 files changed, 1032 insertions(+), 298 deletions(-)
>  create mode 100644 lib/execute-actions.c
>  create mode 100644 lib/execute-actions.h
> 
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
