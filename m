From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: af_packet: don't enable global timestamps
Date: Tue, 4 Sep 2007 09:59:58 +0200
Message-ID: <20070904095958.53c86337.dada1@cosmosbay.com>
References: <20070904063525.060e7a77@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:58818 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751859AbXIDIAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2007 04:00:00 -0400
In-Reply-To: <20070904063525.060e7a77@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 4 Sep 2007 06:35:25 +0100
Stephen Hemminger <shemminger@linux-foundation.org> wrote:

> Andi mentioned he did something like this already, but never
> submitted it.
> 
> The dhcp client application uses AF_PACKET with a packet filter to
> receive data. The application doesn't even use timestamps, but because
> the AF_PACKET API has timestamps, they get turned on globally which
> causes an expensive time of day lookup for every packet received
> on any system that uses the standard DHCP client.
> 
> The fix is to not enable the timestamp (but use if if available).
> This causes the time lookup to only occur on those packets
> that are destined for the AF_PACKET socket. 
> The timestamping occurs after packet filtering
> so all packets dropped by filtering to not cause a clock call.
> 
> The one downside of this a a few microseconds additional delay
> added from the normal timestamping location (netif_rx) until the
> receive callback in AF_PACKET. But since the offset is fairly consistent
> it should not upset applications that do want really use timestamps,
> like wireshark.

This patch seems the correct fix for this longstanding problem.

Please note that if wireshark/tcpdump processes really want precise timestamps, 
they still can ask this by using setsockopt(SO_TIMESTAMP or SO_TIMESTAMPNS) on their private socket.

(We already know that running a sniffer has a cost anyway)

> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> 
> --- a/net/packet/af_packet.c	2007-07-23 09:31:26.000000000 +0100
> +++ b/net/packet/af_packet.c	2007-09-03 14:55:00.000000000 +0100
> @@ -640,11 +640,10 @@ static int tpacket_rcv(struct sk_buff *s
>  	h->tp_snaplen = snaplen;
>  	h->tp_mac = macoff;
>  	h->tp_net = netoff;
> -	if (skb->tstamp.tv64 == 0) {
> -		__net_timestamp(skb);
> -		sock_enable_timestamp(sk);
> -	}
> -	tv = ktime_to_timeval(skb->tstamp);
> +	if (skb->tstamp.tv64)
> +		tv = ktime_to_timeval(skb->tstamp);
> +	else
> +		do_gettimeofday(&tv);
>  	h->tp_sec = tv.tv_sec;
>  	h->tp_usec = tv.tv_usec;
>  

