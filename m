From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [RFC PATCH net-next 1/2] tcp: RTO Restart (RTOR)
Date: Mon, 7 Dec 2015 14:46:23 -0200
Message-ID: <20151207164623.GA22976@mrl.redhat.com>
References: <cover.1449478261.git.per.hurtig@kau.se>
 <4719073d7d8285006b2fe5f1b67a3fe5255c503e.1449478261.git.per.hurtig@kau.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, edumazet@google.com, ncardwell@google.com,
	nanditad@google.com, tom@herbertland.com, ycheng@google.com,
	viro@zeniv.linux.org.uk, fw@strlen.de, daniel@iogearbox.net,
	willemb@google.com, ilpo.jarvinen@helsinki.fi,
	pasi.sarolahti@iki.fi, stephen@networkplumber.org,
	netdev@vger.kernel.org, anna.brunstrom@kau.se, apetlund@simula.no,
	michawe@ifi.uio.no, mohammad.rajiullah@kau.se
To: Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46969 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932421AbbLGQqe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2015 11:46:34 -0500
Content-Disposition: inline
In-Reply-To: <4719073d7d8285006b2fe5f1b67a3fe5255c503e.1449478261.git.per.hurtig@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 07, 2015 at 10:00:11AM +0100, Per Hurtig wrote:
> This patch implements the RTO restart modification (RTOR). When data is
> ACKed, and the RTO timer is restarted, the time elapsed since the last
> outstanding segment was transmitted is subtracted from the calculated RTO
> value. This way, the RTO timer will expire after exactly RTO seconds, and
> not RTO + RTT [+ delACK] seconds.
> 
> This patch also implements a new sysctl (tcp_timer_restart) that is used
> to control the timer restart behavior.
> 
> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
> ---
>  Documentation/networking/ip-sysctl.txt | 12 ++++++++++++
>  include/net/tcp.h                      |  4 ++++
>  net/ipv4/sysctl_net_ipv4.c             | 10 ++++++++++
>  net/ipv4/tcp_input.c                   | 24 ++++++++++++++++++++++++
>  4 files changed, 50 insertions(+)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index 2ea4c45..4094128 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt

(snip)

> @@ -2997,6 +2998,18 @@ static void tcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
>  	tcp_sk(sk)->snd_cwnd_stamp = tcp_time_stamp;
>  }
>  
> +static u32 tcp_unsent_pkts(const struct sock *sk)
> +{
> +	struct sk_buff *skb = tcp_send_head(sk);
> +	u32 pkts = 0;
> +
> +	if (skb)
> +		tcp_for_write_queue_from(skb, sk)
> +			pkts += tcp_skb_pcount(skb);
> +
> +	return pkts;
> +}
> +
>  /* Restart timer after forward progress on connection.
>   * RFC2988 recommends to restart timer to now+rto.
>   */
> @@ -3027,6 +3040,17 @@ void tcp_rearm_rto(struct sock *sk)
>  			 */
>  			if (delta > 0)
>  				rto = delta;
> +		} else if (icsk->icsk_pending == ICSK_TIME_RETRANS &&
> +			   (sysctl_tcp_timer_restart == 1 ||
> +			    sysctl_tcp_timer_restart == 3) &&
> +			   (tp->packets_out + tcp_unsent_pkts(sk) <
> +			    TCP_RTORESTART_THRESH)) {

(snip)

By when this gets hit, you could have a big write queue.
What about wrapping at least this this condition 
tp->packets_out + tcp_unsent_pkts(sk) < TCP_RTORESTART_THRESH
in its own check function? Like:

+static bool tcp_can_rtor(const struct sock *sk)
+{
+	struct sk_buff *skb = tcp_send_head(sk);
+	s32 target = TCP_RTORESTART_THRESH - tp->packets_out;
+
+	if (target <= 0)
+		return false;
+
+	if (skb) {
+		tcp_for_write_queue_from(skb, sk) {
+			target -= tcp_skb_pcount(skb);
+			if (target <= 0)
+				return false;
+		}
+	}
+
+	return true;
+}

This way it will only traverse what is needed for the check itself.

  Marcelo
