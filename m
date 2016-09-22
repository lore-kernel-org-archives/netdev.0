From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf v3] netfilter: seqadj: Fix the wrong ack adjust for
 the RST packet without ack
Date: Thu, 22 Sep 2016 08:27:01 +0200
Message-ID: <20160922062701.GA2240@salvia>
References: <1474510965-2049-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, gfree.wind@gmail.com,
        Eric Dumazet <eric.dumazet@gmail.com>
To: fgao@ikuai8.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1474510965-2049-1-git-send-email-fgao@ikuai8.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On top of Eric's comments.

On Thu, Sep 22, 2016 at 10:22:45AM +0800, fgao@ikuai8.com wrote:
> diff --git a/net/netfilter/nf_conntrack_seqadj.c b/net/netfilter/nf_conntrack_seqadj.c
> index dff0f0c..3bd9c7e 100644
> --- a/net/netfilter/nf_conntrack_seqadj.c
> +++ b/net/netfilter/nf_conntrack_seqadj.c
> @@ -179,30 +179,34 @@ int nf_ct_seq_adjust(struct sk_buff *skb,
>  
>  	tcph = (void *)skb->data + protoff;
>  	spin_lock_bh(&ct->lock);
> +
>  	if (after(ntohl(tcph->seq), this_way->correction_pos))
>  		seqoff = this_way->offset_after;
>  	else
>  		seqoff = this_way->offset_before;
>  
> -	if (after(ntohl(tcph->ack_seq) - other_way->offset_before,
> -		  other_way->correction_pos))
> -		ackoff = other_way->offset_after;
> -	else
> -		ackoff = other_way->offset_before;
> -
>  	newseq = htonl(ntohl(tcph->seq) + seqoff);
> -	newack = htonl(ntohl(tcph->ack_seq) - ackoff);
> -
>  	inet_proto_csum_replace4(&tcph->check, skb, tcph->seq, newseq, false);
> -	inet_proto_csum_replace4(&tcph->check, skb, tcph->ack_seq, newack,
> -				 false);
> -
> -	pr_debug("Adjusting sequence number from %u->%u, ack from %u->%u\n",
> -		 ntohl(tcph->seq), ntohl(newseq), ntohl(tcph->ack_seq),
> -		 ntohl(newack));
>  
> +	pr_debug("Adjusting sequence number from %u->%u\n",
> +		 ntohl(tcph->seq), ntohl(newseq));
>  	tcph->seq = newseq;
> -	tcph->ack_seq = newack;
> +
> +	if (likely(tcph->ack)) {

I'd suggest:

        if (!tcph->ack)
                goto out;

given gcc sets goto branch as unlikely already, then you place an "out"
label...

> +		if (after(ntohl(tcph->ack_seq) - other_way->offset_before,
> +			  other_way->correction_pos))
> +			ackoff = other_way->offset_after;
> +		else
> +			ackoff = other_way->offset_before;
> +
> +		newack = htonl(ntohl(tcph->ack_seq) - ackoff);
> +		inet_proto_csum_replace4(&tcph->check, skb, tcph->ack_seq,
> +					 newack, false);
> +
> +		pr_debug("Adjusting ack number from %u->%u\n",
> +			 ntohl(tcph->ack_seq), ntohl(newack));
> +		tcph->ack_seq = newack;
> +	}
>  
>  	res = nf_ct_sack_adjust(skb, protoff, tcph, ct, ctinfo);

out:    <- here

>  	spin_unlock_bh(&ct->lock);

This will get you a smaller patch fix.
