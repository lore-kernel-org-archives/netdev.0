From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH V4 6/7] xen-netback: coalesce slots in TX path and fix
 regressions
Date: Fri, 12 Apr 2013 16:35:44 +0100
Message-ID: <1365780944.15783.97.camel@zakaz.uk.xensource.com>
References: <1365776646-10796-1-git-send-email-wei.liu2@citrix.com>
	 <1365776646-10796-7-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"jbeulich@suse.com" <jbeulich@suse.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:39409 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746Ab3DLPfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 11:35:48 -0400
In-Reply-To: <1365776646-10796-7-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-12 at 15:24 +0100, Wei Liu wrote:
> +/*
> + * This is the maximum slots a skb can have. If a guest sends a skb
> + * which exceeds this limit it is considered malicious.
> + */
> +#define MAX_SKB_SLOTS_DEFAULT 20
> +static unsigned int max_skb_slots = MAX_SKB_SLOTS_DEFAULT;
> +
> +static int max_skb_slots_set(const char *val, const struct kernel_param *kp)
> +{
> +       int ret;
> +       unsigned int param = 0;
> +
> +       ret = kstrtouint(val, 10, &param);
> +
> +       if (ret < 0 || param < XEN_NETIF_NR_SLOTS_MIN)
> +               return -EINVAL;
> +
> +       max_skb_slots = param;
> +
> +       return 0;
> +}
> +
> +static __moduleparam_const struct kernel_param_ops max_skb_slots_param_ops = {
> +       .set = max_skb_slots_set,
> +       .get = param_get_uint,
> +};
> +
> +module_param_cb(max_skb_slots, &max_skb_slots_param_ops,
> +               &max_skb_slots, 0444);

Is all this infrastructure instead of module_param_int just so we can
check XEN_NETIF_NR_SLOTS_MIN? I'm inclined to suggest that if an admin
wants to set a smaller slot limit then they get to keep the pieces.

Or if you really want to check it then you could check+log/reject in the
module init function.

> +
> +typedef unsigned int pending_ring_idx_t;
> +#define INVALID_PENDING_RING_IDX (~0U)
> +
>  struct pending_tx_info {
> -       struct xen_netif_tx_request req;
> +       struct xen_netif_tx_request req; /* coalesced tx request  */
>         struct xenvif *vif;
> +       pending_ring_idx_t head; /* head != INVALID_PENDING_RING_IDX
> +                                 * if it is head of one or more tx
> +                                 * reqs
> +                                 */
>  };
> -typedef unsigned int pending_ring_idx_t;
> 
>  struct netbk_rx_meta {
>         int id;
> @@ -102,7 +138,11 @@ struct xen_netbk {
>         atomic_t netfront_count;
> 
>         struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
> -       struct gnttab_copy tx_copy_ops[MAX_PENDING_REQS];
> +       /* Coalescing tx requests before copying makes number of grant
> +        * copy ops greater of equal to number of slots required. In
                              ^or

> +        * worst case a tx request consumes 2 gnttab_copy.

I'm happy with this as an upper bound but can it be made smaller?

For example there are at most MAX_PENDING_REQS on the ring, but we are
filling MAX_SKB_FRAGS with that data, therefore only MAX_SKB_FRAGS (-1?)
or those requests can cross a frag boundary and therefore the actual max
is MAX_PENDING_REQS+MAX_SKB_FRAGS.

Is that logic right? Perhaps need to account for data going into the
head too with another +N?

> +        */
> +       struct gnttab_copy tx_copy_ops[2*MAX_PENDING_REQS];
> 
>         u16 pending_ring[MAX_PENDING_REQS];
> 
[...]

> 
> -               memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + frags),
> +               /* Xen network protocol had implicit dependency on
> +                * MAX_SKB_FRAGS. XEN_NETIF_NR_SLOTS_MIN is set to the
> +                * historical MAX_SKB_FRAGS value 18 to honor the same
> +                * behavior as before. Any packet using more than 18
> +                * slots but less than max_skb_slots slots is dropped
> +                */

It seems a bit odd not to accept such a thing if the local network stack
can cope with it but I suppose the intention here is to maintain the
historical status quo to reduce the problem space when we imminently
implement proper negotiation between front- and backend about the number
of slots they can handle?

> +               if (!drop_err && slots >= XEN_NETIF_NR_SLOTS_MIN) {
> +                       if (net_ratelimit())
> +                               netdev_dbg(vif->dev,
> +                                          "Too many slots (%d), dropping packet\n",
> +                                          slots);

Could log the limits here?

> +                       drop_err = -E2BIG;
> +               }
> +
> +               memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + slots),

> @@ -1038,11 +1179,21 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
> 
>         for (i = start; i < nr_frags; i++) {
>                 int j, newerr;
> +               pending_ring_idx_t head;
> 
>                 pending_idx = frag_get_pending_idx(&shinfo->frags[i]);
> +               tx_info = &netbk->pending_tx_info[pending_idx];
> +               head = tx_info->head;
> 
>                 /* Check error status: if okay then remember grant handle. */
> -               newerr = (++gop)->status;
> +               do {
> +                       newerr = (++gop)->status;
> +                       if (newerr)
> +                               break;
> +                       peek = netbk->pending_ring[pending_index(++head)];
> +               } while (netbk->pending_tx_info[peek].head
> +                        == INVALID_PENDING_RING_IDX);

The 80 column limit is a soft one (and I think its greater nowadays
anyhow) and in cases like this the "cure" is worse than the disease, at
least in IMHO...

You are using INVALID_PENDING_RING_IDX as an indication of further
chaining, so the naming is a little counter intuitive. I can't think of
a name I like (something with "continuation" in it?) but perhaps a
helper function pending_tx_is_head(netbk, peek) or something would make
it read more clearly?

> +
>                 if (likely(!newerr)) {
>                         /* Had a previous error? Invalidate this fragment. */
>                         if (unlikely(err))
