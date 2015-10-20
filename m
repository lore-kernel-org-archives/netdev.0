From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCH nf-next 4/4] netfilter: ipv6: avoid nf_iterate recursion
Date: Mon, 19 Oct 2015 23:25:48 -0700
Message-ID: <CANr6G5z3SYGo-f7OmKwncHFK0M01YkeWk2W9tPcQWX3LV5NEEA@mail.gmail.com>
References: <1445112865-31523-1-git-send-email-fw@strlen.de> <1445112865-31523-5-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netfilter-devel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andy Zhou <azhou@nicira.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1445112865-31523-5-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17 October 2015 at 13:14, Florian Westphal <fw@strlen.de> wrote:
> @@ -606,19 +599,22 @@ struct sk_buff *nf_ct_frag6_gather(struct net *net, struct sk_buff *skb, u32 use
>                 spin_unlock_bh(&fq->q.lock);
>                 pr_debug("Can't insert skb to queue\n");
>                 inet_frag_put(&fq->q, &nf_frags);
> -               return skb;
> +               return -EINVAL;
>         }
>
> +       /* after queue has assumed skb ownership, only 0 or -EINPROGRESS
> +        * must be returned.
> +        */
> +       ret = -EINPROGRESS;
>         if (fq->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
> -           fq->q.meat == fq->q.len) {
> -               ret_skb = nf_ct_frag6_reasm(fq, skb, dev);
> -               if (ret_skb == NULL)
> -                       pr_debug("Can't reassemble fragmented packets\n");
> -       }
> +           fq->q.meat == fq->q.len &&
> +           nf_ct_frag6_reasm(fq, skb, dev))
> +               ret = 0;
> +
>         spin_unlock_bh(&fq->q.lock);
>
>         inet_frag_put(&fq->q, &nf_frags);
> -       return ret_skb;
> +       return ret;
>  }
>  EXPORT_SYMBOL_GPL(nf_ct_frag6_gather);

Minor nit below, feel free to disregard if it misses some code style
guideline. The lock/unlock reads easier to me if the
unlocking/frag_put is grouped together, something like the following
incremental:

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c
b/net/ipv6/netfilter/nf_conntrack_reasm.c
index b87dd75967d0..edfd290792f5 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -596,10 +596,8 @@ int nf_ct_frag6_gather(struct net *net, struct
sk_buff *skb, u32 user)
        spin_lock_bh(&fq->q.lock);

        if (nf_ct_frag6_queue(fq, skb, fhdr, nhoff) < 0) {
-               spin_unlock_bh(&fq->q.lock);
-               pr_debug("Can't insert skb to queue\n");
-               inet_frag_put(&fq->q, &nf_frags);
-               return -EINVAL;
+               ret = -EINVAL;
+               goto unlock;
        }

        /* after queue has assumed skb ownership, only 0 or -EINPROGRESS
@@ -611,9 +609,11 @@ int nf_ct_frag6_gather(struct net *net, struct
sk_buff *skb, u32 user)
            nf_ct_frag6_reasm(fq, skb, dev))
                ret = 0;

+unlock:
        spin_unlock_bh(&fq->q.lock);
-
        inet_frag_put(&fq->q, &nf_frags);
+       if (unlikely(ret == -EINVAL))
+               pr_debug("Can't insert skb to queue\n");
        return ret;
 }
 EXPORT_SYMBOL_GPL(nf_ct_frag6_gather);
