From: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2.42 1/5] odp: Allow VLAN actions after MPLS
	actions
Date: Fri, 4 Oct 2013 09:21:33 -0700
Message-ID: <20131004162133.GG29572@nicira.com>
References: <1380874200-8981-1-git-send-email-horms@verge.net.au>
	<1380874200-8981-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1380874200-8981-2-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 04, 2013 at 05:09:56PM +0900, Simon Horman wrote:
> From: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
> 
> OpenFlow 1.1 and 1.2, and 1.3 differ in their handling of MPLS actions in the
> presence of VLAN tags. To allow correct behaviour to be committed in
> each situation, this patch adds a second round of VLAN tag action
> handling to commit_odp_actions(), which occurs after MPLS actions. This
> is implemented with a new field in 'struct xlate_in' called 'vlan_tci'.
> 
> When an push_mpls action is composed, the flow's current VLAN state is
> stored into xin->vlan_tci, and flow->vlan_tci is set to 0 (pop_vlan). If
> a VLAN tag is present, it is stripped; if not, then there is no change.
> Any later modifications to the VLAN state is written to xin->vlan_tci.
> When committing the actions, flow->vlan_tci is used before MPLS actions,
> and xin->vlan_tci is used afterwards. This retains the current datapath
> behaviour, but allows VLAN actions to be applied in a more flexible
> manner.
> 
> Both before and after this patch MPLS LSEs are pushed onto a packet after
> any VLAN tags that may be present. This is the behaviour described in
> OpenFlow 1.1 and 1.2. OpenFlow 1.3 specifies that MPLS LSEs should be
> pushed onto a packet before any VLAN tags that are present. Support
> for this will be added by a subsequent patch that makes use of
> the infrastructure added by this patch.
> 
> Signed-off-by: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
> Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

I noticed a couple more minor points.

First, it seems to me that the "vlan_tci" member that this adds to
xlate_in could go in xlate_ctx just as well.  I would prefer that,
because (as far as I can tell) there is no reason for the client to use
any value other than flow->vlan_tci here, and putting it in xlate_ctx
hides it from the client.

Thanks for rearranging the code and updating the comment in
do_xlate_actions().  It makes the operation clearer.  But now that it's
clear I have an additional question.  Does it really make sense to have
'vlan_tci' as only a local variable in do_xlate_actions()?  Presumably,
MPLS and VLANs should interact the same way regardless of whether they
are separated by resubmits or goto_tables.  That is, I suspect that this
is xlate_ctx state, not local state.

Thanks,

Ben.
