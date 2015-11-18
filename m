From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH -next] net: tcp: move to timewait when receiving data post
 active-close
Date: Wed, 18 Nov 2015 18:35:59 +0100
Message-ID: <1447868159.400039.443456489.4AB3FECE@webmail.messagingengine.com>
References: <1447859024-1040-1-git-send-email-fw@strlen.de>
 <1447860480.22599.151.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151118153621.GA5860@breakpoint.cc>
 <1447861591.22599.157.camel@edumazet-glaptop2.roam.corp.google.com>
 <1447862057.909111.443349025.5B7D067D@webmail.messagingengine.com>
 <1447867736.22599.169.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	marcelo.leitner@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:57156 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756441AbbKRRgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 12:36:00 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 2719520C19
	for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 12:36:00 -0500 (EST)
In-Reply-To: <1447867736.22599.169.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 18, 2015, at 18:28, Eric Dumazet wrote:
> On Wed, 2015-11-18 at 16:54 +0100, Hannes Frederic Sowa wrote:
> 
> > Still, the RST packet can be dropped along the way. So the teardown of
> > the socket on the other side might not happen.
> 
> This is why it is better to send RST for every incoming in-excess packet

I agree it would be better to send a RST than ACK incoming data. Just
thinking out loud, would it make sense to add a sub-state to timewait so
we RST all other packets for TIMEWAIT_LEN duration?

> Try following packetdrill test, before and after your patch :
> 
> 0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
> 0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> 0.000 bind(3, ..., ...) = 0
> 0.000 listen(3, 1) = 0
> 0.100 < S 0:0(0) win 29200 <mss 1460>
> 0.100 > S. 0:0(0) ack 1 <mss 1460>
> 0.200 < . 1:1(0) ack 1 win 257
> 0.200 accept(3, ..., ...) = 4
> // close our side.
> 0.210 close(4) = 0
> // we should expect to see FIN now, sk moves to FIN_WAIT_1
> 0.210 > F. 1:1(0) ack 1 win 29200
> 
> // receive data, but sk already closed -> Reset
> +.010 < P. 1:1001(1000) ack 1 win 46
> +0    > R 1:1(0) win 0
> 
> // Are we properly sending a RST like prior packet did ?
> +.010 < P. 1001:2001(1000) ack 1 win 46
> +0    > R 1:1(0) win 0

Thanks,
Hannes
