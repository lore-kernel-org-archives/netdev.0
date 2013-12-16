From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2 6/9] xen-netback: Handle guests with too many
 frags
Date: Mon, 16 Dec 2013 18:09:08 +0000
Message-ID: <20131216180908.GC25969@zion.uk.xensource.com>
References: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com>
 <1386892097-15502-7-git-send-email-zoltan.kiss@citrix.com>
 <20131213154307.GN21900@zion.uk.xensource.com>
 <52AF2602.2000409@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52AF2602.2000409@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 16, 2013 at 04:10:42PM +0000, Zoltan Kiss wrote:
> On 13/12/13 15:43, Wei Liu wrote:
> >On Thu, Dec 12, 2013 at 11:48:14PM +0000, Zoltan Kiss wrote:
> >>Xen network protocol had implicit dependency on MAX_SKB_FRAGS. Netback has to
> >>handle guests sending up to XEN_NETBK_LEGACY_SLOTS_MAX slots. To achieve that:
> >>- create a new skb
> >>- map the leftover slots to its frags (no linear buffer here!)
> >>- chain it to the previous through skb_shinfo(skb)->frag_list
> >>- map them
> >>- copy the whole stuff into a brand new skb and send it to the stack
> >>- unmap the 2 old skb's pages
> >>
> >
> >Do you see performance regression with this approach?
> Well, it was pretty hard to reproduce that behaviour even with NFS.
> I don't think it happens often enough that it causes a noticable
> performance regression. Anyway, it would be just as slow as the
> current grant copy with coalescing, maybe a bit slower due to the
> unmapping. But at least we use a core network function to do the
> coalescing.
> Or, if you mean the generic performance, if this problem doesn't
> appear, then no, I don't see performance regression.
> 

OK, thanks for comfirming.

> >>Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> >>
> >>---
> >>  drivers/net/xen-netback/netback.c |   99 +++++++++++++++++++++++++++++++++++--
> >>  1 file changed, 94 insertions(+), 5 deletions(-)
> >>
> >>diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> >>index e26cdda..f6ed1c8 100644
> >>--- a/drivers/net/xen-netback/netback.c
> >>+++ b/drivers/net/xen-netback/netback.c
> >>@@ -906,11 +906,15 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
> >>  	u16 pending_idx = *((u16 *)skb->data);
> >>  	int start;
> >>  	pending_ring_idx_t index;
> >>-	unsigned int nr_slots;
> >>+	unsigned int nr_slots, frag_overflow = 0;
> >>
> >>  	/* At this point shinfo->nr_frags is in fact the number of
> >>  	 * slots, which can be as large as XEN_NETBK_LEGACY_SLOTS_MAX.
> >>  	 */
> >>+	if (shinfo->nr_frags > MAX_SKB_FRAGS) {
> >>+		frag_overflow = shinfo->nr_frags - MAX_SKB_FRAGS;
> >>+		shinfo->nr_frags = MAX_SKB_FRAGS;
> >>+	}
> >>  	nr_slots = shinfo->nr_frags;
> >>
> >
> >It is also probably better to check whether shinfo->nr_frags is too
> >large which makes frag_overflow > MAX_SKB_FRAGS. I know skb should be
> >already be valid at this point but it wouldn't hurt to be more careful.
> Ok, I've added this:
> 	/* At this point shinfo->nr_frags is in fact the number of
> 	 * slots, which can be as large as XEN_NETBK_LEGACY_SLOTS_MAX.
> 	 */
> +	if (shinfo->nr_frags > MAX_SKB_FRAGS) {
> +		if (shinfo->nr_frags > XEN_NETBK_LEGACY_SLOTS_MAX) return NULL;
> +		frag_overflow = shinfo->nr_frags - MAX_SKB_FRAGS;
> 

What I suggested is

   BUG_ON(frag_overflow > MAX_SKB_FRAGS)

Wei.
