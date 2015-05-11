From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH nf] conntrack: RFC5961 challenge ACK confuse conntrack
 LAST-ACK transition
Date: Mon, 11 May 2015 12:02:17 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1505111155120.30455@blackhole.kfki.hu>
References: <20150507125416.29956.24745.stgit@dragon>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150507125416.29956.24745.stgit@dragon>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, 7 May 2015, Jesper Dangaard Brouer wrote:

> In compliance with RFC5961, the network stack send challenge ACK in
> response to spurious SYN packets, since commit 0c228e833c88 ("tcp:
> Restore RFC5961-compliant behavior for SYN packets").
> 
> This pose a problem for netfilter conntrack in state LAST_ACK, because
> this challenge ACK is (falsely) seen as ACKing last FIN, causing a
> false state transition (into TIME_WAIT).
> 
> The challenge ACK is hard to distinguish from real last ACK.  Thus,
> solution introduce a flag that tracks the potential for seeing a
> challenge ACK, in case a SYN packet is let through and current state
> is LAST_ACK.
> 
> When conntrack transition LAST_ACK to TIME_WAIT happens, this flag is
> used for determining if we are expecting a challenge ACK.
> 
> Scapy based reproducer script avail here:
>  https://github.com/netoptimizer/network-testing/blob/master/scapy/tcp_hacks_3WHS_LAST_ACK.py
> 
> Fixes: 0c228e833c88 ("tcp: Restore RFC5961-compliant behavior for SYN packets")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

The patch looks OK to me, thanks Jesper.

Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Best regards,
Jozsef
> ---
> 
>  include/uapi/linux/netfilter/nf_conntrack_tcp.h |    3 ++
>  net/netfilter/nf_conntrack_proto_tcp.c          |   35 +++++++++++++++++++++--
>  2 files changed, 35 insertions(+), 3 deletions(-)
> 
> diff --git a/include/uapi/linux/netfilter/nf_conntrack_tcp.h b/include/uapi/linux/netfilter/nf_conntrack_tcp.h
> index 9993a42..ef9f80f 100644
> --- a/include/uapi/linux/netfilter/nf_conntrack_tcp.h
> +++ b/include/uapi/linux/netfilter/nf_conntrack_tcp.h
> @@ -42,6 +42,9 @@ enum tcp_conntrack {
>  /* The field td_maxack has been set */
>  #define IP_CT_TCP_FLAG_MAXACK_SET		0x20
>  
> +/* Marks possibility for expected RFC5961 challenge ACK */
> +#define IP_CT_EXP_CHALLENGE_ACK 		0x40
> +
>  struct nf_ct_tcp_flags {
>  	__u8 flags;
>  	__u8 mask;
> diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
> index 5caa0c4..ad0db66 100644
> --- a/net/netfilter/nf_conntrack_proto_tcp.c
> +++ b/net/netfilter/nf_conntrack_proto_tcp.c
> @@ -202,7 +202,7 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
>   *	sES -> sES	:-)
>   *	sFW -> sCW	Normal close request answered by ACK.
>   *	sCW -> sCW
> - *	sLA -> sTW	Last ACK detected.
> + *	sLA -> sTW	Last ACK detected (RFC5961 challenged)
>   *	sTW -> sTW	Retransmitted last ACK. Remain in the same state.
>   *	sCL -> sCL
>   */
> @@ -261,7 +261,7 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
>   *	sES -> sES	:-)
>   *	sFW -> sCW	Normal close request answered by ACK.
>   *	sCW -> sCW
> - *	sLA -> sTW	Last ACK detected.
> + *	sLA -> sTW	Last ACK detected (RFC5961 challenged)
>   *	sTW -> sTW	Retransmitted last ACK.
>   *	sCL -> sCL
>   */
> @@ -906,6 +906,7 @@ static int tcp_packet(struct nf_conn *ct,
>  					1 : ct->proto.tcp.last_win;
>  			ct->proto.tcp.seen[ct->proto.tcp.last_dir].td_scale =
>  				ct->proto.tcp.last_wscale;
> +			ct->proto.tcp.last_flags &= ~IP_CT_EXP_CHALLENGE_ACK;
>  			ct->proto.tcp.seen[ct->proto.tcp.last_dir].flags =
>  				ct->proto.tcp.last_flags;
>  			memset(&ct->proto.tcp.seen[dir], 0,
> @@ -923,7 +924,9 @@ static int tcp_packet(struct nf_conn *ct,
>  		 * may be in sync but we are not. In that case, we annotate
>  		 * the TCP options and let the packet go through. If it is a
>  		 * valid SYN packet, the server will reply with a SYN/ACK, and
> -		 * then we'll get in sync. Otherwise, the server ignores it. */
> +		 * then we'll get in sync. Otherwise, the server potentially
> +		 * respons with a challenge ACK if implementing RFC5961.
> +		 */
>  		if (index == TCP_SYN_SET && dir == IP_CT_DIR_ORIGINAL) {
>  			struct ip_ct_tcp_state seen = {};
>  
> @@ -939,6 +942,13 @@ static int tcp_packet(struct nf_conn *ct,
>  				ct->proto.tcp.last_flags |=
>  					IP_CT_TCP_FLAG_SACK_PERM;
>  			}
> +			/* Mark the potential for RFC5961 challenge ACK,
> +			 * this pose a special problem for LAST_ACK state
> +			 * as ACK is intrepretated as ACKing last FIN.
> +			 */
> +			if (old_state == TCP_CONNTRACK_LAST_ACK)
> +				ct->proto.tcp.last_flags |=
> +					IP_CT_EXP_CHALLENGE_ACK;
>  		}
>  		spin_unlock_bh(&ct->lock);
>  		if (LOG_INVALID(net, IPPROTO_TCP))
> @@ -970,6 +980,25 @@ static int tcp_packet(struct nf_conn *ct,
>  			nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
>  				  "nf_ct_tcp: invalid state ");
>  		return -NF_ACCEPT;
> +	case TCP_CONNTRACK_TIME_WAIT:
> +		/* RFC5961 compliance cause stack to send "challenge-ACK"
> +		 * e.g. in response to spurious SYNs.  Conntrack MUST
> +		 * not believe this ACK is acking last FIN.
> +		 */
> +		if (old_state == TCP_CONNTRACK_LAST_ACK
> +		    && index == TCP_ACK_SET
> +		    && ct->proto.tcp.last_dir != dir
> +		    && ct->proto.tcp.last_index == TCP_SYN_SET
> +		    && (ct->proto.tcp.last_flags & IP_CT_EXP_CHALLENGE_ACK)) {
> +			/* Detected RFC5961 challenge ACK */
> +			ct->proto.tcp.last_flags &= ~IP_CT_EXP_CHALLENGE_ACK;
> +			spin_unlock_bh(&ct->lock);
> +			if (LOG_INVALID(net, IPPROTO_TCP))
> +				nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL,
> +				      "nf_ct_tcp: challenge-ACK ignored ");
> +			return NF_ACCEPT; /* Don't change state */
> +		}
> +		break;
>  	case TCP_CONNTRACK_CLOSE:
>  		if (index == TCP_RST_SET
>  		    && (ct->proto.tcp.seen[!dir].flags & IP_CT_TCP_FLAG_MAXACK_SET)
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
