From: Greg Rose <gvrose8192-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] datapath: Fix for force/commit action failures
Date: Thu, 13 Jul 2017 10:12:15 -0700
Message-ID: <174ca16b-264f-66ac-af0d-eec003cbcd07@gmail.com>
References: <1499963124-7841-1-git-send-email-gvrose8192@gmail.com>
	<76FBD265-9CC9-4366-A075-203E76BA4E97@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
To: Darrell Ball <dball-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <76FBD265-9CC9-4366-A075-203E76BA4E97-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/13/2017 10:08 AM, Darrell Ball wrote:
> 
> 
> On 7/13/17, 9:25 AM, "ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org on behalf of Greg Rose" <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org on behalf of gvrose8192-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> 
>      When there is an established connection in direction A->B, it is
>      possible to receive a packet on port B which then executes
>      ct(commit,force) without first performing ct() - ie, a lookup.
>      In this case, we would expect that this packet can delete the existing
>      entry so that we can commit a connection with direction B->A. However,
>      currently we only perform a check in skb_nfct_cached() for whether
>      OVS_CS_F_TRACKED is set and OVS_CS_F_INVALID is not set, ie that a
>      lookup previously occurred. In the above scenario, a lookup has not
>      occurred but we should still be able to statelessly look up the
>      existing entry and potentially delete the entry if it is in the
>      opposite direction.
>      
>      This patch extends the check to also hint that if the action has the
>      force flag set, then we will lookup the existing entry so that the
>      force check at the end of skb_nfct_cached has the ability to delete
>      the connection.
>      
>      CC: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
>      CC: Pravin Shalar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
>      Signed-off-by: Joe Stringer <joe-LZ6Gd1LRuIk@public.gmane.org>
>      Signed-off-by: Greg Rose <gvrose8192-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>      ---
>       net/openvswitch/conntrack.c | 12 ++++++++----
>       1 file changed, 8 insertions(+), 4 deletions(-)
>      
>      diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
>      index 08679eb..9041cf8 100644
>      --- a/net/openvswitch/conntrack.c
>      +++ b/net/openvswitch/conntrack.c
>      @@ -641,17 +641,21 @@ static bool skb_nfct_cached(struct net *net,
>       	ct = nf_ct_get(skb, &ctinfo);
>       	/* If no ct, check if we have evidence that an existing conntrack entry
>       	 * might be found for this skb.  This happens when we lose a skb->_nfct
>      -	 * due to an upcall.  If the connection was not confirmed, it is not
>      -	 * cached and needs to be run through conntrack again.
>      +	 * due to an upcall, or if the direction is being forced.  If the
>      +	 * connection was not confirmed, it is not cached and needs to be run
>      +	 * through conntrack again.
>       	 */
>      -	if (!ct && key->ct_state & OVS_CS_F_TRACKED &&
>      +	if ((!ct && (key->ct_state & OVS_CS_F_TRACKED) &&
>       	    !(key->ct_state & OVS_CS_F_INVALID) &&
>      -	    key->ct_zone == info->zone.id) {
>      +	     key->ct_zone == info->zone.id) ||
>      +	     (!key->ct_state && info->force)) {
>       		ct = ovs_ct_find_existing(net, &info->zone, info->family, skb,
>       					  !!(key->ct_state
>       					     & OVS_CS_F_NAT_MASK));
>       		if (ct)
>       			nf_ct_get(skb, &ctinfo);
>      +		else
>      +			return false;
> 
> the above else case looks redundant since it maps to the following check
>       	if (!ct)
>       		return false;
> which services a superset of the code flow.

Sure, we can let it fall through... missed that.

After waiting for more review I'll send a V2 patch.

Thanks for the review Darrell

- Greg

> 
>       	}
>       	if (!ct)
>       		return false;
>      --
>      1.8.3.1
>      
>      _______________________________________________
>      dev mailing list
>      dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
>      https://urldefense.proofpoint.com/v2/url?u=https-3A__mail.openvswitch.org_mailman_listinfo_ovs-2Ddev&d=DwICAg&c=uilaK90D4TOVoH58JNXRgQ&r=BVhFA09CGX7JQ5Ih-uZnsw&m=5da6ykiSQJBoJXmpq6iVknmPAc5JDzlVngmp8j_xcXA&s=PsX-njQ_hFqy8P77KNEyX0i7u165p2Wrbg4uAYqfbGs&e=
>      
> 
