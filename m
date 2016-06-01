From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: accept RST if SEQ matches right edge of
 SACK block
Date: Wed, 01 Jun 2016 08:48:38 -0700
Message-ID: <1464796118.5939.156.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1464694717-22548-1-git-send-email-pau.espin@tessares.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Pau Espin Pedrol <pau.espin@tessares.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33780 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465AbcFAPsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 11:48:40 -0400
Received: by mail-pf0-f196.google.com with SMTP id b124so4343620pfb.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 08:48:40 -0700 (PDT)
In-Reply-To: <1464694717-22548-1-git-send-email-pau.espin@tessares.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-05-31 at 13:38 +0200, Pau Espin Pedrol wrote:
> RFC 5961 advises to only accept RST packets containing a seq number
> matching the next expected seq number instead of the whole receive
> window in order to avoid spoofing attacks.
> 
> However, this situation is not optimal in the case SACK is in use at the
> time the RST is sent. I recently run into a scenario in which packet
> losses were high while uploading data to a server, and userspace was
> willing to frequently terminate connections by sending a RST. In
> this case, the ACK sent on the receiver side is frozen waiting for a lost
> packet retransmission and a SACK block is used to let the client
> continue uploading data. At some point later on, the client sends the
> RST, which matches the next expected seq number of the SACK block on the
> receiver side which is going forward receiving data.
> 
> In this scenario, as RFC 5961 defines, the SEQ doesn't match the frozen
> main ACK at receiver side and thus gets dropped and a challenge ACK is
> sent, which gets usually lost due to network conditions. The main
> consequence is that the connection stays alive for a while even if it
> made sense to accept the RST. This can get really bad if lots of
> connections like this one are created in few seconds, allocating all the
> resources of the server easily.
> 
> From security point of view: the maximum number of SACK blocks for a TCP
> connection is limited to 4 due to options field maximum length, and that
> means we match at maximum against 5 seq numbers, which should make it
> still difficult for attackers to inject a valid RST message.
> 
> This patch was tested in a 3.18 kernel and probed to improve the
> situation in the scenario described above.
> 
> Signed-off-by: Pau Espin Pedrol <pau.espin@tessares.net>
> ---
>  net/ipv4/tcp_input.c | 18 +++++++++++++++++-
>  1 file changed, 17 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index d6c8f4cd0..4727dc8 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -5159,6 +5159,7 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
>  				  const struct tcphdr *th, int syn_inerr)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
> +	bool rst_seq_match = false;
>  
>  	/* RFC1323: H1. Apply PAWS check first. */
>  	if (tcp_fast_parse_options(skb, th, tp) && tp->rx_opt.saw_tstamp &&
> @@ -5195,13 +5196,28 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
>  
>  	/* Step 2: check RST bit */
>  	if (th->rst) {
> -		/* RFC 5961 3.2 :
> +		/* RFC 5961 3.2 (extended to match against SACK too if available):
>  		 * If sequence number exactly matches RCV.NXT, then
>  		 *     RESET the connection
>  		 * else
>  		 *     Send a challenge ACK
>  		 */
>  		if (TCP_SKB_CB(skb)->seq == tp->rcv_nxt)
> +			rst_seq_match = true;
> +		else if (tcp_is_sack(tp)) {
> +			int this_sack;
> +			struct tcp_sack_block *sp = tp->rx_opt.dsack ?
> +					tp->duplicate_sack : tp->selective_acks;
> +

Please reorder your variables :
    long variable name foooooooooo;
    short var bar;


It not clear why we should use duplicate_sack[0] at all ?

dsack should be 0 at this point anyway ?

> +			for (this_sack = 0; this_sack < tp->rx_opt.num_sacks; ++this_sack) {
> +				if (TCP_SKB_CB(skb)->seq == sp[this_sack].end_seq) {
> +					rst_seq_match = true;
> +					break;
> +				}
> +			}
> +		}
> +
> +		if (rst_seq_match)
>  			tcp_reset(sk);
>  		else
>  			tcp_send_challenge_ack(sk, skb);
> -- 
> 2.5.0
> 
> 
