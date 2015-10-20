From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCH nf-next 3/4] netfilter: ipv6: in-place replacement of last skb
Date: Tue, 20 Oct 2015 11:39:24 -0700
Message-ID: <CANr6G5zgPbVeagJUePm9+e_fxSBu5Kr9iYM_k+Eh672h0Pa9kQ@mail.gmail.com>
References: <1445112865-31523-1-git-send-email-fw@strlen.de> <1445112865-31523-4-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netfilter-devel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andy Zhou <azhou@nicira.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1445112865-31523-4-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17 October 2015 at 13:14, Florian Westphal <fw@strlen.de> wrote:
> @@ -425,6 +425,35 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct net_device *dev)
>                 add_frag_mem_limit(fq->q.net, clone->truesize);
>         }
>
> +       /* morph head into last received skb: prev.
> +        *
> +        * This allows callers of ipv6 conntrack defrag to continue
> +        * to use the last skb(frag) passed into the reasm engine.
> +        * The last skb frag 'silently' turns into the full reassembled skb.
> +        *
> +        * Since prev is also part of q->fragments we have to clone it first.
> +        */
> +       if (head != prev) {
> +               struct sk_buff *iter;
> +
> +               fp = skb_clone(prev, GFP_ATOMIC);
> +               if (!fp)
> +                       goto out_oom;
> +
> +               fp->next = prev->next;
> +               skb_queue_walk(head, iter) {
> +                       if (iter->next != prev)
> +                               continue;
> +                       iter->next = fp;
> +                       break;
> +               }
> +
> +               skb_morph(prev, head);
> +               prev->next = head->next;
> +               consume_skb(head);
> +               head = prev;
> +       }
> +
>         /* We have to remove fragment header from datagram and to relocate
>          * header in order to calculate ICV correctly. */
>         skb_network_header(head)[fq->nhoffset] = skb_transport_header(head)[0];

This hunk looks very similar to the logic in ip_frag_reasm(). Did you
consider refactoring to share it?
