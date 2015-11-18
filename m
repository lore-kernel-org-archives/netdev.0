From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next] net: tcp: move to timewait when receiving data
 post active-close
Date: Wed, 18 Nov 2015 09:28:56 -0800
Message-ID: <1447867736.22599.169.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447859024-1040-1-git-send-email-fw@strlen.de>
	 <1447860480.22599.151.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151118153621.GA5860@breakpoint.cc>
	 <1447861591.22599.157.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1447862057.909111.443349025.5B7D067D@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	marcelo.leitner@gmail.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34105 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754241AbbKRR3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 12:29:10 -0500
Received: by padhx2 with SMTP id hx2so50983120pad.1
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 09:29:10 -0800 (PST)
In-Reply-To: <1447862057.909111.443349025.5B7D067D@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-18 at 16:54 +0100, Hannes Frederic Sowa wrote:

> Still, the RST packet can be dropped along the way. So the teardown of
> the socket on the other side might not happen.

This is why it is better to send RST for every incoming in-excess packet

Try following packetdrill test, before and after your patch :

0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
0.000 bind(3, ..., ...) = 0
0.000 listen(3, 1) = 0
0.100 < S 0:0(0) win 29200 <mss 1460>
0.100 > S. 0:0(0) ack 1 <mss 1460>
0.200 < . 1:1(0) ack 1 win 257
0.200 accept(3, ..., ...) = 4
// close our side.
0.210 close(4) = 0
// we should expect to see FIN now, sk moves to FIN_WAIT_1
0.210 > F. 1:1(0) ack 1 win 29200

// receive data, but sk already closed -> Reset
+.010 < P. 1:1001(1000) ack 1 win 46
+0    > R 1:1(0) win 0

// Are we properly sending a RST like prior packet did ?
+.010 < P. 1001:2001(1000) ack 1 win 46
+0    > R 1:1(0) win 0
