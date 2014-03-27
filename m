From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: Grant copy the header instead of
 map and memcpy
Date: Thu, 27 Mar 2014 11:35:36 +0000
Message-ID: <1395920136.22909.76.camel@kazak.uk.xensource.com>
References: <1395868707-22683-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395868707-22683-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-03-26 at 21:18 +0000, Zoltan Kiss wrote:
> An old inefficiency of the TX path that we are grant mapping the first slot,
> and then copy the header part to the linear area. Instead, doing a grant copy
> for that header straight on is more reasonable. Especially because there are
> ongoing efforts to make Xen avoiding TLB flush after unmap when the page were
> not touched in Dom0. In the original way the memcpy ruined that.
> The key changes:
> - the vif has a tx_copy_ops array again
> - xenvif_tx_build_gops sets up the grant copy operations
> - we don't have to figure out whether the header and first frag are on the same
>   grant mapped page or not
> 
> Unrelated, but I've made a small refactoring in xenvif_get_extras as well.

Just a few thoughts, not really based on close review of the code.

Do you have any measurements for this series or workloads where it is
particularly beneficial?

You've added a second hypercall to tx_action, probably those can be
combined into one vm exit by using a multicall. Also you should omit
either if their respective nr_?ops is zero (can nr_cops ever be zero?)

Adding another MAX_PENDING_REQS sized array is unfortunate. Could we
perhaps get away with only ever doing copy for the first N requests (for
small N) in a frame and copying up the request, N should be chosen to be
large enough to cover the more common cases (which I suppose is Windows
which puts the network and transport headers in separate slots). This
might allow the copy array to be smaller, at the expense of still doing
the map+memcpy for some corner cases.

Or (and I confess this is a skanky hack): we overlay tx_copy_ops and
tx_map_ops in a union, and insert one set of ops from the front and the
other from the end, taking great care around when and where they meet.


>  static int xenvif_tx_check_gop(struct xenvif *vif,
>  			       struct sk_buff *skb,
> -			       struct gnttab_map_grant_ref **gopp)
> +			       struct gnttab_map_grant_ref **gopp,
> +			       struct gnttab_copy **gopp_copy)

I think a precursor patch which only does s/gopp/gopp_map/ would be
beneficial.
> @@ -1164,7 +1147,9 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
>  	return false;
>  }
>  
> -static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
> +static unsigned xenvif_tx_build_gops(struct xenvif *vif,
> +				     int budget,
> +				     unsigned *copy_ops)

I think you should turn the nr map ops into an explicit pointer return
too, having one thing go via the formal return code and another via a
pointer is a bit odd.

>  	struct gnttab_map_grant_ref *gop = vif->tx_map_ops, *request_gop;
>  	struct sk_buff *skb;
> @@ -1267,24 +1252,37 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
>  			}
>  		}
>  
> -		xenvif_tx_create_gop(vif, pending_idx, &txreq, gop);
> -
> -		gop++;
> -
>  		XENVIF_TX_CB(skb)->pending_idx = pending_idx;
>  
>  		__skb_put(skb, data_len);

Can't you allocate the skb with sufficient headroom? (or maybe I've
forgotten again how skb payload management works and __skb_put is
effectively free on an empty skb?)

> +		vif->tx_copy_ops[*copy_ops].source.u.ref = txreq.gref;
> +		vif->tx_copy_ops[*copy_ops].source.domid = vif->domid;
> +		vif->tx_copy_ops[*copy_ops].source.offset = txreq.offset;
> +
> +		vif->tx_copy_ops[*copy_ops].dest.u.gmfn = virt_to_mfn(skb->data);
> +		vif->tx_copy_ops[*copy_ops].dest.domid = DOMID_SELF;
> +		vif->tx_copy_ops[*copy_ops].dest.offset = offset_in_page(skb->data);
> +
> +		vif->tx_copy_ops[*copy_ops].len = data_len;

Do we want to copy the entire first frag even if it is e.g. a complete
page?

I'm not sure where the tradeoff lies between doing a grant copy of more
than necessary and doing a map+memcpy when the map is already required
for the page frag anyway.

What about the case where the first frag is less than PKT_PROT_LEN? I
think you still do map+memcpy in that case?

> @@ -1375,6 +1374,7 @@ static int xenvif_handle_frag_list(struct xenvif *vif, struct sk_buff *skb)
>  static int xenvif_tx_submit(struct xenvif *vif)
>  {
>  	struct gnttab_map_grant_ref *gop = vif->tx_map_ops;

Another candidate for a precursor patch renaming for clarity.

Ian.
