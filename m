From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: TSO packets automatic sizing
Date: Sun, 25 Aug 2013 19:22:39 -0700
Message-ID: <1377483759.8828.104.camel@edumazet-glaptop>
References: <1377304192.8828.43.camel@edumazet-glaptop>
	 <CADVnQymvQz67k1_f4rRJxPVUFWL=rM5vnT-ZO1VPSxN-E0uzDA@mail.gmail.com>
	 <1377370594.8828.72.camel@edumazet-glaptop>
	 <CAK6E8=f0S5SSr5vEN2L-J69aNPC78W9qbGT3Wp5z-65AGp+ZRA@mail.gmail.com>
	 <1377477425.8828.101.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Van Jacobson <vanj@google.com>,
	Tom Herbert <therbert@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:33199 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755712Ab3HZCWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Aug 2013 22:22:41 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so2831031pdj.8
        for <netdev@vger.kernel.org>; Sun, 25 Aug 2013 19:22:41 -0700 (PDT)
In-Reply-To: <1377477425.8828.101.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-08-25 at 17:37 -0700, Eric Dumazet wrote:
> On Sun, 2013-08-25 at 15:01 -0700, Yuchung Cheng wrote:
> 
> > Any idea to get rid of this undesirable extra RTT delay?
> 
> Its probably a bug in the push code.

For exact write/send of a multiple of MSS, I think following patch
should fix the bug.

If we filled a packet, we must send it.

For the other problem, I think its related to Nagle.

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ab64eea..dd326f4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1187,7 +1187,8 @@ new_segment:
 
 			from += copy;
 			copied += copy;
-			if ((seglen -= copy) == 0 && iovlen == 0)
+			seglen -= copy;
+			if (seglen == 0 && iovlen == 0 && skb->len < max)
 				goto out;
 
 			if (skb->len < max || (flags & MSG_OOB) || unlikely(tp->repair))
