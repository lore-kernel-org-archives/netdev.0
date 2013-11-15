From: Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2.50 1/6] ofp-actions: Consider L4 actions
	after mpls_push as inconsistent
Date: Fri, 15 Nov 2013 08:55:42 -0800
Message-ID: <6A09EE11-CDFA-4E49-AB7F-34746ED4765D@nicira.com>
References: <1384506623-18503-1-git-send-email-horms@verge.net.au>
	<1384506623-18503-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1384506623-18503-2-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

Looks good to me,

Acked-by: Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

> On Nov 15, 2013, at 1:10 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> 
> After an mpls_push action the resulting packet is MPLS and
> the MPLS payload is opaque. Thus nothing can be assumed
> about the packets network protocol and it is inconsistent
> to apply L4 actions.
> 
> With regards to actions that affect the packet at other layers
> of the protocol stack:
> 
> * L3: The consistency of L3 actions should already be handled correctly
>  by virtue of the dl_type of the flow being temporarily altered
>  during consistency checking by both push_mpls and pop_mpls actions.
> 
> * MPLS: The consistency checking of MPLS actions appear to already be
>  handled correctly.
> 
> * VLAN: At this time Open vSwitch on mpls_push an MPLS LSE is always
>  added after any VLAN tags that follow the ethernet header.
>  That is the tag ordering defined prior to OpenFlow1.3. As such
>  VLAN actions should sill be equally valid before and after mpls_push
>  and mpls_pop actions.
> 
> * L2 actions are equally valid before and after mpls_push and mpls_pop actions.
> 
> Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
> 
> ---
> v2.50
> * Correct typo in comment. nw_protocol -> nw_proto
> 
> v2.49
> * First post
> ---
> lib/ofp-actions.c    |  9 ++++++++-
> tests/ofp-actions.at | 12 ++++++++++++
> 2 files changed, 20 insertions(+), 1 deletion(-)
> 
> diff --git a/lib/ofp-actions.c b/lib/ofp-actions.c
> index abc9505..03ad1a4 100644
> --- a/lib/ofp-actions.c
> +++ b/lib/ofp-actions.c
> @@ -1869,7 +1869,8 @@ ofpact_check_output_port(ofp_port_t port, ofp_port_t max_ports)
>     }
> }
> 
> -/* May modify flow->dl_type and flow->vlan_tci, caller must restore them.
> +/* May modify flow->dl_type, flow->nw_proto and flow->vlan_tci,
> + * caller must restore them.
>  *
>  * Modifies some actions, filling in fields that could not be properly set
>  * without context. */
> @@ -2056,6 +2057,10 @@ ofpact_check__(struct ofpact *a, struct flow *flow,
> 
>     case OFPACT_PUSH_MPLS:
>         flow->dl_type = ofpact_get_PUSH_MPLS(a)->ethertype;
> +        /* The packet is now MPLS and the MPLS payload is opaque.
> +         * Thus nothing can be assumed about the network protocol.
> +         * Temporarily mark that we have no nw_proto. */
> +        flow->nw_proto = 0;
>         return 0;
> 
>     case OFPACT_POP_MPLS:
> @@ -2127,6 +2132,7 @@ ofpacts_check(struct ofpact ofpacts[], size_t ofpacts_len,
>     struct ofpact *a;
>     ovs_be16 dl_type = flow->dl_type;
>     ovs_be16 vlan_tci = flow->vlan_tci;
> +    uint8_t nw_proto = flow->nw_proto;
>     enum ofperr error = 0;
> 
>     OFPACT_FOR_EACH (a, ofpacts, ofpacts_len) {
> @@ -2139,6 +2145,7 @@ ofpacts_check(struct ofpact ofpacts[], size_t ofpacts_len,
>     /* Restore fields that may have been modified. */
>     flow->dl_type = dl_type;
>     flow->vlan_tci = vlan_tci;
> +    flow->nw_proto = nw_proto;
>     return error;
> }
> 
> diff --git a/tests/ofp-actions.at b/tests/ofp-actions.at
> index cdca8ca..08ebccf 100644
> --- a/tests/ofp-actions.at
> +++ b/tests/ofp-actions.at
> @@ -477,3 +477,15 @@ AT_CHECK(
>   [ovs-ofctl '-vPATTERN:console:%c|%p|%m' parse-ofp11-instructions < input.txt],
>   [0], [expout], [experr])
> AT_CLEANUP
> +
> +AT_SETUP([ofp-actions - inconsistent MPLS actions])
> +OVS_VSWITCHD_START
> +dnl OK: Use fin_timeout action on TCP flow
> +AT_CHECK([ovs-ofctl -O OpenFlow11 -vwarn add-flow br0 'tcp actions=fin_timeout(idle_timeout=1)'])
> +dnl Bad: Use fin_timeout action on TCP flow that has been converted to MPLS
> +AT_CHECK([ovs-ofctl -O OpenFlow11 -vwarn add-flow br0 'tcp actions=push_mpls:0x8847,fin_timeout(idle_timeout=1)'],
> +         [1], [], [dnl
> +ovs-ofctl: actions are invalid with specified match (OFPBAC_MATCH_INCONSISTENT)
> +])
> +OVS_VSWITCHD_STOP
> +AT_CLEANUP
> -- 
> 1.8.4
> 
> _______________________________________________
> dev mailing list
> dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
> http://openvswitch.org/mailman/listinfo/dev
