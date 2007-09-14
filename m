From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] af_packet: allow disabling timestamps
Date: Fri, 14 Sep 2007 12:26:42 +0200
Message-ID: <20070914122642.5343b128@oldman>
References: <1186669314.24669.56.camel@localhost.localdomain>
	<20070809143322.GA5345@2ka.mipt.ru>
	<1186683234.24669.65.camel@localhost.localdomain>
	<20070809181823.GA32449@2ka.mipt.ru>
	<1186685450.24669.81.camel@localhost.localdomain>
	<20070913124253.60da52f2@oldman>
	<20070913142406.299944c3.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Unai Uribarri <unai.uribarri@optenet.com>,
	"David S. Miller" <davem@davemloft.net>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44400 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752659AbXINK1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 06:27:43 -0400
In-Reply-To: <20070913142406.299944c3.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Sep 2007 14:24:06 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> On Thu, 13 Sep 2007 12:42:53 +0200
> Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> 
> > Currently, af_packet does not allow disabling timestamps. This patch changes
> > that but doesn't force global timestamps on.
> > 
> > This shows up in bugzilla as:
> > 	http://bugzilla.kernel.org/show_bug.cgi?id=4809
> > 
> > Patch against net-2.6.24 tree.
> > 
> 
> I am not sure I understood this patch.
> 
> This means that tcpdump/ethereal wont get precise timestamps 
> (gathered when packet is received), but imprecise ones (gathered when the sniffer reads the packet)
> 
> I added some time ago ktime infrastructure to eventually get nanosecond 
> precision in libpcap, so I would prefer a step in the right direction :)
> 
> Should'nt we use something like :
> 
> [PATCH] af_packet : allow disabling timestamps, or requesting nanosecond precision.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 5a16e38..1c10b9d 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -563,6 +563,7 @@ set_rcvbuf:
>  		} else {
>  			sock_reset_flag(sk, SOCK_RCVTSTAMP);
>  			sock_reset_flag(sk, SOCK_RCVTSTAMPNS);
> +			sock_disable_timestamp(sk);
>  		}
>  		break;
>  
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 745e2cb..409de44 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -650,12 +650,27 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
>  	h->tp_snaplen = snaplen;
>  	h->tp_mac = macoff;
>  	h->tp_net = netoff;
> -	if (skb->tstamp.tv64)
> -		tv = ktime_to_timeval(skb->tstamp);
> -	else
> -		do_gettimeofday(&tv);
> -	h->tp_sec = tv.tv_sec;
> -	h->tp_usec = tv.tv_usec;
> +	h->tp_sec = 0;
> +	h->tp_usec = 0;
> +	if ((sock_flag(sk, SOCK_TIMESTAMP))) {
> +		if (sock_flag(sk, SOCK_RCVTSTAMPNS)) {
> +			struct timespec ts;
> +			if (skb->tstamp.tv64)
> +				ts = ktime_to_timespec(skb->tstamp);
> +			else
> +				getnstimeofday(&ts);
> +			h->tp_sec = ts.tv_sec;
> +			h->tp_usec = ts.tv_nsec; /* cheat a litle bit */
> +		}
> +		else {
> +			if (skb->tstamp.tv64)
> +				tv = ktime_to_timeval(skb->tstamp);
> +			else
> +				do_gettimeofday(&tv);
> +			h->tp_sec = tv.tv_sec;
> +			h->tp_usec = tv.tv_usec;
> +		}
> +	}
>  
>  	sll = (struct sockaddr_ll*)((u8*)h + TPACKET_ALIGN(sizeof(*h)));
>  	sll->sll_halen = 0;
> @@ -1014,6 +1029,7 @@ static int packet_create(struct net *net, struct socket *sock, int protocol)
>  		sock->ops = &packet_ops_spkt;
>  
>  	sock_init_data(sock, sk);
> +	sock_enable_timestamp(sk);
>  
>  	po = pkt_sk(sk);
>  	sk->sk_family = PF_PACKET;

No, then we end up timestamping all the packets, even if they get dropped by
packet filter. The change in 2.6.24 allows dhclient (and rstp) to only call
hires clock source for packets they want, not all packets.

Perhaps the timestamping needs to change into a tristate flag?
