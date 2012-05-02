From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/6] tcp: Repair socket queues
Date: Wed, 02 May 2012 13:11:04 +0200
Message-ID: <1335957064.22133.428.camel@edumazet-glaptop>
References: <4F901572.4040009@parallels.com>
	 <4F9015ED.7020607@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:45565 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640Ab2EBLLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 07:11:10 -0400
Received: by eekc41 with SMTP id c41so131564eek.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 04:11:08 -0700 (PDT)
In-Reply-To: <4F9015ED.7020607@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-19 at 17:41 +0400, Pavel Emelyanov wrote:
> Reading queues under repair mode is done with recvmsg call.
> The queue-under-repair set by TCP_REPAIR_QUEUE option is used
> to determine which queue should be read. Thus both send and
> receive queue can be read with this.
> 
> Caller must pass the MSG_PEEK flag.
> 
> Writing to queues is done with sendmsg call and yet again --
> the repair-queue option can be used to push data into the
> receive queue.
> 
> When putting an skb into receive queue a zero tcp header is
> appented to its head to address the tcp_hdr(skb)->syn and
> the ->fin checks by the (after repair) tcp_recvmsg. These
> flags flags are both set to zero and that's why.
> 
> The fin cannot be met in the queue while reading the source
> socket, since the repair only works for closed/established
> sockets and queueing fin packet always changes its state.
> 
> The syn in the queue denotes that the respective skb's seq
> is "off-by-one" as compared to the actual payload lenght. Thus,
> at the rcv queue refill we can just drop this flag and set the
> skb's sequences to precice values.
> 
> When the repair mode is turned off, the write queue seqs are
> updated so that the whole queue is considered to be 'already sent,
> waiting for ACKs' (write_seq = snd_nxt <= snd_una). From the
> protocol POV the send queue looks like it was sent, but the data
> between the write_seq and snd_nxt is lost in the network.
> 
> This helps to avoid another sockoption for setting the snd_nxt
> sequence. Leaving the whole queue in a 'not yet sent' state (as
> it will be after sendmsg-s) will not allow to receive any acks
> from the peer since the ack_seq will be after the snd_nxt. Thus
> even the ack for the window probe will be dropped and the
> connection will be 'locked' with the zero peer window.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> ---
>  net/ipv4/tcp.c        |   89 +++++++++++++++++++++++++++++++++++++++++++++++--
>  net/ipv4/tcp_output.c |    1 +
>  2 files changed, 87 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index e38d6f2..47e2f49 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -912,6 +912,39 @@ static inline int select_size(const struct sock *sk, bool sg)
>  	return tmp;
>  }
>  
> +static int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size)
> +{
> +	struct sk_buff *skb;
> +	struct tcp_skb_cb *cb;
> +	struct tcphdr *th;
> +
> +	skb = alloc_skb(size + sizeof(*th), sk->sk_allocation);

I am not sure any check is performed on 'size' ?

A caller might trigger OOM or wrap bug.
