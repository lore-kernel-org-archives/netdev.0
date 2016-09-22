From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH nf v3] netfilter: seqadj: Fix the wrong ack adjust for
 the RST packet without ack
Date: Wed, 21 Sep 2016 22:20:51 -0700
Message-ID: <1474521651.23058.91.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1474510965-2049-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kaber@trash.net,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36749 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752899AbcIVFUx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 01:20:53 -0400
In-Reply-To: <1474510965-2049-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-22 at 10:22 +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> It is valid that the TCP RST packet which does not set ack flag, and bytes
> of ack number are zero. But current seqadj codes would adjust the "0" ack
> to invalid ack number. Actually seqadj need to check the ack flag before
> adjust it for these RST packets.
> 
> The following is my test case
> 
> client is 10.26.98.245, and add one iptable rule:
> iptables  -I INPUT -p tcp --sport 12345 -m connbytes --connbytes 2:
> --connbytes-dir reply --connbytes-mode packets -j REJECT --reject-with
> tcp-reset
> This iptables rule could generate on TCP RST without ack flag.
> 
> server:10.172.135.55
> Enable the synproxy with seqadjust by the following iptables rules
> iptables -t raw -A PREROUTING -i eth0 -p tcp -d 10.172.135.55 --dport 12345
> -m tcp --syn -j CT --notrack
> 
> iptables -A INPUT -i eth0 -p tcp -d 10.172.135.55 --dport 12345 -m conntrack
> --ctstate INVALID,UNTRACKED -j SYNPROXY --sack-perm --timestamp --wscale 7
> --mss 1460
> iptables -A OUTPUT -o eth0 -p tcp -s 10.172.135.55 --sport 12345 -m conntrack
> --ctstate INVALID,UNTRACKED -m tcp --tcp-flags SYN,RST,ACK SYN,ACK -j ACCEPT
> 
> The following is my test result.
> 
> 1. packet trace on client
> root@routers:/tmp# tcpdump -i eth0 tcp port 12345 -n
> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
> listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
> IP 10.26.98.245.45154 > 10.172.135.55.12345: Flags [S], seq 3695959829,
> win 29200, options [mss 1460,sackOK,TS val 452367884 ecr 0,nop,wscale 7],
> length 0
> IP 10.172.135.55.12345 > 10.26.98.245.45154: Flags [S.], seq 546723266,
> ack 3695959830, win 0, options [mss 1460,sackOK,TS val 15643479 ecr 452367884,
> nop,wscale 7], length 0
> IP 10.26.98.245.45154 > 10.172.135.55.12345: Flags [.], ack 1, win 229,
> options [nop,nop,TS val 452367885 ecr 15643479], length 0
> IP 10.172.135.55.12345 > 10.26.98.245.45154: Flags [.], ack 1, win 226,
> options [nop,nop,TS val 15643479 ecr 452367885], length 0
> IP 10.26.98.245.45154 > 10.172.135.55.12345: Flags [R], seq 3695959830,
> win 0, length 0
> 
> 2. seqadj log on server
> [62873.867319] Adjusting sequence number from 602341895->546723267,
> ack from 3695959830->3695959830
> [62873.867644] Adjusting sequence number from 602341895->546723267,
> ack from 3695959830->3695959830
> [62873.869040] Adjusting sequence number from 3695959830->3695959830,
> ack from 0->55618628
> 
> To summarize, it is clear that the seqadj codes adjust the 0 ack when receive
> one TCP RST packet without ack.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  v3: Add the reproduce steps and packet trace
>  v2: Regenerate because the first patch is removed
>  v1: Initial patch
> 
>  net/netfilter/nf_conntrack_seqadj.c | 34 +++++++++++++++++++---------------
>  1 file changed, 19 insertions(+), 15 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_seqadj.c b/net/netfilter/nf_conntrack_seqadj.c
> index dff0f0c..3bd9c7e 100644
> --- a/net/netfilter/nf_conntrack_seqadj.c
> +++ b/net/netfilter/nf_conntrack_seqadj.c
> @@ -179,30 +179,34 @@ int nf_ct_seq_adjust(struct sk_buff *skb,
>  
>  	tcph = (void *)skb->data + protoff;
>  	spin_lock_bh(&ct->lock);
> +

Please do not add style change during a bug fix.

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

If tcph->ack is not set, why are we calling nf_ct_sack_adjust() ?

>  	res = nf_ct_sack_adjust(skb, protoff, tcph, ct, ctinfo);
>  	spin_unlock_bh(&ct->lock);
