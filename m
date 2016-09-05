From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH 2/2 nf] netfilter: seqadj: Fix the wrong ack adjust for
 the RST packet without ack
Date: Mon, 5 Sep 2016 23:06:49 +0800
Message-ID: <CA+6hz4rWCnLdNhzEKwKPdES9suKCZshEEZrCRnmx+gMcrwBg5Q@mail.gmail.com>
References: <1473087725-22089-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Feng Gao <gfree.wind@gmail.com>, Gao Feng <fgao@ikuai8.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
        coreteam@netfilter.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:35543 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933747AbcIEPGu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 11:06:50 -0400
In-Reply-To: <1473087725-22089-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

On Mon, Sep 5, 2016 at 11:02 PM,  <fgao@ikuai8.com> wrote:
> From: Gao Feng <fgao@ikuai8.com>
>
> It is valid that the TCP RST packet which does not set ack flag, and bytes
> of ack number are zero. For these RST packets, seqadj could not adjust the
> ack number.
>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  net/netfilter/nf_conntrack_seqadj.c | 34 +++++++++++++++++++---------------
>  1 file changed, 19 insertions(+), 15 deletions(-)
>
> diff --git a/net/netfilter/nf_conntrack_seqadj.c b/net/netfilter/nf_conntrack_seqadj.c
> index 7f8d814..65bb4a6 100644
> --- a/net/netfilter/nf_conntrack_seqadj.c
> +++ b/net/netfilter/nf_conntrack_seqadj.c
> @@ -182,30 +182,34 @@ int nf_ct_seq_adjust(struct sk_buff *skb,
>
>         tcph = (void *)skb->data + protoff;
>         spin_lock_bh(&ct->lock);
> +
>         if (after(ntohl(tcph->seq), this_way->correction_pos))
>                 seqoff = this_way->offset_after;
>         else
>                 seqoff = this_way->offset_before;
>
> -       if (after(ntohl(tcph->ack_seq) - other_way->offset_before,
> -                 other_way->correction_pos))
> -               ackoff = other_way->offset_after;
> -       else
> -               ackoff = other_way->offset_before;
> -
>         newseq = htonl(ntohl(tcph->seq) + seqoff);
> -       newack = htonl(ntohl(tcph->ack_seq) - ackoff);
> -
>         inet_proto_csum_replace4(&tcph->check, skb, tcph->seq, newseq, false);
> -       inet_proto_csum_replace4(&tcph->check, skb, tcph->ack_seq, newack,
> -                                false);
> -
> -       pr_debug("Adjusting sequence number from %u->%u, ack from %u->%u\n",
> -                ntohl(tcph->seq), ntohl(newseq), ntohl(tcph->ack_seq),
> -                ntohl(newack));
>
> +       pr_debug("Adjusting sequence number from %u->%u\n",
> +                ntohl(tcph->seq), ntohl(newseq));
>         tcph->seq = newseq;
> -       tcph->ack_seq = newack;
> +
> +       if (likely(tcph->ack)) {
> +               if (after(ntohl(tcph->ack_seq) - other_way->offset_before,
> +                         other_way->correction_pos))
> +                       ackoff = other_way->offset_after;
> +               else
> +                       ackoff = other_way->offset_before;
> +
> +               newack = htonl(ntohl(tcph->ack_seq) - ackoff);
> +               inet_proto_csum_replace4(&tcph->check, skb, tcph->ack_seq,
> +                                        newack, false);
> +
> +               pr_debug("Adjusting ack number from %u->%u\n",
> +                        ntohl(tcph->ack_seq), ntohl(newack));
> +               tcph->ack_seq = newack;
> +       }
>
>         res = nf_ct_sack_adjust(skb, protoff, tcph, ct, ctinfo);
>         spin_unlock_bh(&ct->lock);
> --
> 1.9.1
>
>

This patch is generated base on the patch commit "netfilter: seqadj:
Fix one possible panic in seqadj when mem is exhausted" whose link is
http://patchwork.ozlabs.org/patch/665116/.

So its subject contains "2/2".

Best Regards
Feng



Best Regards
Feng
