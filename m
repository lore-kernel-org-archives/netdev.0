From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2 net-next 4/7] tcp: Make use of MSG_EOR flag in
 tcp_sendmsg
Date: Mon, 18 Apr 2016 19:50:41 -0700
Message-ID: <1461034241.10638.145.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461019569-3037369-1-git-send-email-kafai@fb.com>
	 <1461019569-3037369-5-git-send-email-kafai@fb.com>
	 <1461021493.10638.131.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160418234202.GA27948@kafai-mba.local>
	 <1461024417.10638.141.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160419022704.GB35817@dreloong-mbp.local.DHCP.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35238 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756AbcDSCun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 22:50:43 -0400
Received: by mail-pa0-f42.google.com with SMTP id fs9so1528224pac.2
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 19:50:43 -0700 (PDT)
In-Reply-To: <20160419022704.GB35817@dreloong-mbp.local.DHCP.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-18 at 19:27 -0700, Martin KaFai Lau wrote:
> On Mon, Apr 18, 2016 at 05:06:57PM -0700, Eric Dumazet wrote:
> > It should only be a request from user space to ask TCP to not aggregate
> > stuff on future sendpage()/sendmsg() on the skb carrying this new flag.
> >
> How about something like this.  Please advise if tcp_sendmsg_noappend can
> be simpler.
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index c0ef054..ac31798 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -762,7 +762,8 @@ struct tcp_skb_cb {
> 
>  	__u8		ip_dsfield;	/* IPv4 tos or IPv6 dsfield	*/
>  	__u8		txstamp_ack:1,	/* Record TX timestamp for ack? */
> -			unused:7;
> +			eor:1,		/* Is skb MSG_EOR marked */
> +			unused:6;
>  	__u32		ack_seq;	/* Sequence number ACK'd	*/
>  	union {
>  		struct inet_skb_parm	h4;
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 4d73858..12772be 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -874,6 +874,13 @@ static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
>  	return mss_now;
>  }
> 
> +static bool tcp_sendmsg_noappend(const struct sock *sk)
> +{
> +	const struct sk_buff *skb = tcp_write_queue_tail(sk);
> +
> +	return (!skb || TCP_SKB_CB(skb)->eor);
> +}
> +
>  static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
>  				size_t size, int flags)
>  {
> @@ -903,6 +910,9 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
>  	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
>  		goto out_err;
> 
> +	if (tcp_sendmsg_noappend(sk))
> +		goto new_segment;
> +
>  	while (size > 0) {
>  		struct sk_buff *skb = tcp_write_queue_tail(sk);
>  		int copy, i;
> @@ -960,6 +970,7 @@ new_segment:
>  		size -= copy;
>  		if (!size) {
>  			tcp_tx_timestamp(sk, sk->sk_tsflags, skb);
> +			TCP_SKB_CB(skb)->eor = !!(flags & MSG_EOR);
>  			goto out;
>  		}
> 
> @@ -1145,6 +1156,9 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
> 
>  	sg = !!(sk->sk_route_caps & NETIF_F_SG);
> 
> +	if (tcp_sendmsg_noappend(sk))
> +		goto new_segment;
> +
>  	while (msg_data_left(msg)) {
>  		int copy = 0;
>  		int max = size_goal;
> @@ -1250,6 +1264,7 @@ new_segment:
>  		copied += copy;
>  		if (!msg_data_left(msg)) {
>  			tcp_tx_timestamp(sk, sockc.tsflags, skb);
> +			TCP_SKB_CB(skb)->eor = !!(flags & MSG_EOR);
>  			goto out;
>  		}

I believe it is slightly wrong (to do the goto new_segment if there is
no data to send)

I would instead use this fast path, doing the test _when_ we already
have an skb to test for.

diff --git a/include/net/tcp.h b/include/net/tcp.h
index fd40f8c64d5f..015851634195 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -760,7 +760,8 @@ struct tcp_skb_cb {
 
 	__u8		ip_dsfield;	/* IPv4 tos or IPv6 dsfield	*/
 	__u8		txstamp_ack:1,	/* Record TX timestamp for ack? */
-			unused:7;
+			eor:1,		/* Is skb MSG_EOR marked */
+			unused:6;
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
 	union {
 		struct inet_skb_parm	h4;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4d73858991af..1944c19885ab 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -908,7 +908,9 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 		int copy, i;
 		bool can_coalesce;
 
-		if (!tcp_send_head(sk) || (copy = size_goal - skb->len) <= 0) {
+		if (!tcp_send_head(sk) ||
+		    (copy = size_goal - skb->len) <= 0 ||
+		    TCP_SKB_CB(skb)->eor) {
 new_segment:
 			if (!sk_stream_memory_free(sk))
 				goto wait_for_sndbuf;
@@ -960,6 +962,7 @@ new_segment:
 		size -= copy;
 		if (!size) {
 			tcp_tx_timestamp(sk, sk->sk_tsflags, skb);
+			TCP_SKB_CB(skb)->eor = !!(flags & MSG_EOR);
 			goto out;
 		}
 
@@ -1156,7 +1159,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 			copy = max - skb->len;
 		}
 
-		if (copy <= 0) {
+		if (copy <= 0 || TCP_SKB_CB(skb)->eor) {
 new_segment:
 			/* Allocate new segment. If the interface is SG,
 			 * allocate skb fitting to single page.
@@ -1250,6 +1253,7 @@ new_segment:
 		copied += copy;
 		if (!msg_data_left(msg)) {
 			tcp_tx_timestamp(sk, sockc.tsflags, skb);
+			TCP_SKB_CB(skb)->eor = !!(flags & MSG_EOR);
 			goto out;
 		}
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 6451b83d81e9..acfbff81ef47 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1171,6 +1171,8 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 	TCP_SKB_CB(skb)->tcp_flags = flags & ~(TCPHDR_FIN | TCPHDR_PSH);
 	TCP_SKB_CB(buff)->tcp_flags = flags;
 	TCP_SKB_CB(buff)->sacked = TCP_SKB_CB(skb)->sacked;
+	TCP_SKB_CB(buff)->eor = TCP_SKB_CB(skb)->eor;
+	TCP_SKB_CB(skb)->eor = 0;
 
 	if (!skb_shinfo(skb)->nr_frags && skb->ip_summed != CHECKSUM_PARTIAL) {
 		/* Copy and checksum data tail into the new buffer. */
@@ -1730,6 +1732,8 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
 
 	/* This packet was never sent out yet, so no SACK bits. */
 	TCP_SKB_CB(buff)->sacked = 0;
+	TCP_SKB_CB(buff)->eor = TCP_SKB_CB(skb)->eor;
+	TCP_SKB_CB(skb)->eor = 0;
 
 	buff->ip_summed = skb->ip_summed = CHECKSUM_PARTIAL;
 	skb_split(skb, buff, len);
@@ -2471,6 +2475,7 @@ static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 
 	/* Merge over control information. This moves PSH/FIN etc. over */
 	TCP_SKB_CB(skb)->tcp_flags |= TCP_SKB_CB(next_skb)->tcp_flags;
+	TCP_SKB_CB(skb)->eor = TCP_SKB_CB(next_skb)->eor;
 
 	/* All done, get rid of second SKB and account for it so
 	 * packet counting does not break.
@@ -2502,7 +2507,8 @@ static bool tcp_can_collapse(const struct sock *sk, const struct sk_buff *skb)
 	/* Some heurestics for collapsing over SACK'd could be invented */
 	if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)
 		return false;
-
+	if (TCP_SKB_CB(skb)->eor)
+		return false;
 	return true;
 }
 
