From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 -next 3/3] tcp: honour SO_BINDTODEVICE for TW_RST case
 too
Date: Tue, 22 Dec 2015 22:47:00 +0100
Message-ID: <5679C4D4.50804@stressinduktion.org>
References: <1450729766-14926-1-git-send-email-fw@strlen.de>
 <1450729766-14926-4-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:49614 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932612AbbLVVrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 16:47:04 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 86FB820D0E
	for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 16:47:02 -0500 (EST)
In-Reply-To: <1450729766-14926-4-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21.12.2015 21:29, Florian Westphal wrote:
> Hannes points out that when we generate tcp reset for timewait sockets we
> pretend we found no socket and pass NULL sk to tcp_vX_send_reset().
> 
> Make it cope with inet tw sockets and then provide tw sk.
> 
> This makes RSTs appear on correct interface when SO_BINDTODEVICE is used.
> 
> Packetdrill test case:
> // want default route to be used, we rely on BINDTODEVICE
> `ip route del 192.0.2.0/24 via 192.168.0.2 dev tun0`
> 
> 0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
> // test case still works due to BINDTODEVICE
> 0.001 setsockopt(3, SOL_SOCKET, SO_BINDTODEVICE, "tun0", 4) = 0
> 0.100...0.200 connect(3, ..., ...) = 0
> 
> 0.100 > S 0:0(0) <mss 1460,sackOK,nop,nop>
> 0.200 < S. 0:0(0) ack 1 win 32792 <mss 1460,sackOK,nop,nop>
> 0.200 > . 1:1(0) ack 1
> 
> 0.210 close(3) = 0
> 
> 0.210 > F. 1:1(0) ack 1 win 29200
> 0.300 < . 1:1(0) ack 2 win 46
> 
> // more data while in FIN_WAIT2, expect RST
> 1.300 < P. 1:1001(1000) ack 1 win 46
> 
> // fails without this change -- default route is used
> 1.301 > R 1:1(0) win 0
> 
> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Tested and works fine, thanks Florian and Eric!
