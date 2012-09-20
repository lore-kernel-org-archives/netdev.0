From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Thu, 20 Sep 2012 22:25:22 +0200
Message-ID: <1348172722.2669.10.camel@edumazet-glaptop>
References: <CAGK4HS_ZKKrzFh+c3WDxbkMFpDTg7ehw9ydp39k6JPFA_j1YOw@mail.gmail.com>
	 <1348119475.31352.60.camel@edumazet-glaptop> <505B4E13.5000501@hp.com>
	 <20120920.154007.1073423645697694793.davem@davemloft.net>
	 <505B773E.9070501@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, subramanian.vijay@gmail.com,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51749 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099Ab2ITUZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 16:25:27 -0400
Received: by bkuw11 with SMTP id w11so462135bku.19
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2012 13:25:26 -0700 (PDT)
In-Reply-To: <505B773E.9070501@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-20 at 13:06 -0700, Rick Jones wrote:

> 
> Yes, I was being too fast and loose with my wording, paying more 
> attention to the netperf tests than the rest of it.  While loopback may 
> be lossless, TCP retransmissions over loopback shouldn't be all *that* 
> surprising.

Sending perfect packets (large packets) should trigger no retransmits.

In your tests, you send one-byte packets, so obviously the receiver will
drop some of them, because sk_rcvbuf limit (or the backlog limit) is hit
very fast.

(This should be less frequent with TCP coalescing that was recently
introduced : We are able to coalesce about 1600 'one-byte packets' into
a single one.)

netperf -t TCP_STREAM over loopback should not drop packets or
retransmit them.

# netstat -s|grep TCPRcvCoalesce
    TCPRcvCoalesce: 0

# netperf -t TCP_RR -- -b 1024 -D -S 16K -o
local_transport_retrans,remote_transport_retrans MIGRATED TCP
REQUEST/RESPONSE TEST from 0.0.0.0 () port 0 AF_INET to localhost ()
port 0 AF_INET : nodelay : first burst 1024
Local Transport Retransmissions,Remote Transport Retransmissions
0,0

# netstat -s|grep TCPRcvCoalesce
    TCPRcvCoalesce: 2072191
