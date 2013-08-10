From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH] netfilter: nf_conntrack: fix tcp_in_window for Fast
 Open
Date: Sat, 10 Aug 2013 15:01:36 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1308101501070.5256@blackhole.kfki.hu>
References: <1376094087-17700-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, edumazet@google.com
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1376094087-17700-1-git-send-email-ycheng@google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 9 Aug 2013, Yuchung Cheng wrote:

> Currently the conntrack checks if the ending sequence of a packet
> falls within the observed receive window. However it does so even
> if it has not observe any packet from the remote yet and uses an
> uninitialized receive window (td_maxwin).
> 
> If a connection uses Fast Open to send a SYN-data packet which is
> dropped afterward in the network. The subsequent SYNs retransmits
> will all fail this check and be discarded, leading to a connection
> timeout. This is because the SYN retransmit does not contain data
> payload so
> 
> end == initial sequence number (isn) + 1
> sender->td_end == isn + syn_data_len
> receiver->td_maxwin == 0
> 
> The fix is to only apply this check after td_maxwin is initialized.
> 
> Reported-by: Michael Chan <mcfchan@stanford.edu>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

> ---
>  net/netfilter/nf_conntrack_proto_tcp.c | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
> index 4d4d8f1..e0f9a32 100644
> --- a/net/netfilter/nf_conntrack_proto_tcp.c
> +++ b/net/netfilter/nf_conntrack_proto_tcp.c
> @@ -526,7 +526,7 @@ static bool tcp_in_window(const struct nf_conn *ct,
>  	const struct nf_conntrack_tuple *tuple = &ct->tuplehash[dir].tuple;
>  	__u32 seq, ack, sack, end, win, swin;
>  	s16 receiver_offset;
> -	bool res;
> +	bool res, in_recv_win;
>  
>  	/*
>  	 * Get the required data from the packet.
> @@ -649,14 +649,18 @@ static bool tcp_in_window(const struct nf_conn *ct,
>  		 receiver->td_end, receiver->td_maxend, receiver->td_maxwin,
>  		 receiver->td_scale);
>  
> +	/* Is the ending sequence in the receive window (if available)? */
> +	in_recv_win = !receiver->td_maxwin ||
> +		      after(end, sender->td_end - receiver->td_maxwin - 1);
> +
>  	pr_debug("tcp_in_window: I=%i II=%i III=%i IV=%i\n",
>  		 before(seq, sender->td_maxend + 1),
> -		 after(end, sender->td_end - receiver->td_maxwin - 1),
> +		 (in_recv_win ? 1 : 0),
>  		 before(sack, receiver->td_end + 1),
>  		 after(sack, receiver->td_end - MAXACKWINDOW(sender) - 1));
>  
>  	if (before(seq, sender->td_maxend + 1) &&
> -	    after(end, sender->td_end - receiver->td_maxwin - 1) &&
> +	    in_recv_win &&
>  	    before(sack, receiver->td_end + 1) &&
>  	    after(sack, receiver->td_end - MAXACKWINDOW(sender) - 1)) {
>  		/*
> @@ -725,7 +729,7 @@ static bool tcp_in_window(const struct nf_conn *ct,
>  			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
>  			"nf_ct_tcp: %s ",
>  			before(seq, sender->td_maxend + 1) ?
> -			after(end, sender->td_end - receiver->td_maxwin - 1) ?
> +			in_recv_win ?
>  			before(sack, receiver->td_end + 1) ?
>  			after(sack, receiver->td_end - MAXACKWINDOW(sender) - 1) ? "BUG"
>  			: "ACK is under the lower bound (possible overly delayed ACK)"
> -- 
> 1.8.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
