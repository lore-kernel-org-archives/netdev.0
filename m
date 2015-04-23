From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fix tcp fin memory accounting
Date: Thu, 23 Apr 2015 09:16:55 -0700
Message-ID: <1429805815.22254.57.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429661349.18561.23.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5538F821.6070503@akamai.com>
	 <1429797767.22254.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150423.115447.2163146250304402014.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: johunt@akamai.com, netdev@vger.kernel.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:34867 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966196AbbDWQQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 12:16:58 -0400
Received: by iejt8 with SMTP id t8so64507630iej.2
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 09:16:58 -0700 (PDT)
In-Reply-To: <20150423.115447.2163146250304402014.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-23 at 11:54 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 23 Apr 2015 07:02:47 -0700
> 
> > +		if (!tcp_send_head(sk)) {
> > +			tp->snd_nxt++;
> > +			return;
> > +		}
> 
> I'm not so sure about this.  Why is this needed?
> 
> Otherwise patch looks fine to me.
> 

I guess I need to add a comment then ;)

If we want to pretend FIN was sent, we also need to tweak tp->snd_nxt to
match new tskb->end_seq (or tp->write_seq).

I tested following packetdrill script and confirmed that if I do not
tweak snd_nxt, last packet sent is incorrect :

	> . 5001:5001(0) ack 2

This might be because our stack relies that we never coalesce something
on one already sent skb (we do this check in tcp_sendmsg() for example)

Also note the funny thing : The FIN that is finally sent also has a Push
flag. I believe its fine to leave this, as it is not incorrect at
protocol perspective, and removing the push would add some logic when we
split the packet to remove the ACKed part.


// Initialize a server socket.
0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
+0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
+0 bind(3, ..., ...) = 0
+0 listen(3, 1) = 0

+0    < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>
+0    > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 6>
+.010 < . 1:1(0) ack 1 win 257

+0 accept(3, ..., ...) = 4

+0.010 write(4, ..., 5000) = 5000
+0    > P. 1:5001(5000) ack 1

// this assumes kernel is not able to allocate fresh skb to 
// hold FIN
+.010 shutdown(4, SHUT_RDWR) = 0
+0    < . 1:1(0) ack 5001 win 257

// Yeah ! note the FIN that we 'retransmit' also gets a Push
+0.209    > FP. 5001:5001(0) ack 1

+0 read(4, ..., 1000) = 0
+0 write(4, ..., 1000) = -1 EPIPE (Broken pipe)

+.010 close(4) = 0

// TLP at 2*RTT after the original send of FIN.
+.201 > FP. 5001:5001(0) ack 1

// Receive an ACK for the remaining outstanding data.
+.010 < . 1:1(0) ack 5002 win 257

// Receive a FIN.
+.010 < F. 1:1(0) ack 5002 win 257
// Make sure final packet is correct
+0    > . 5002:5002(0) ack 2
