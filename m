From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next v2 2/8] tipc: compensate for double accounting
 in socket rcv buffer
Date: Wed, 14 May 2014 10:45:42 -0700
Message-ID: <1400089542.7973.104.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400060355-26308-1-git-send-email-jon.maloy@ericsson.com>
	 <1400060355-26308-3-git-send-email-jon.maloy@ericsson.com>
	 <1400068021.7973.78.camel@edumazet-glaptop2.roam.corp.google.com>
	 <A2BAEFC30C8FD34388F02C9B3121859D1C25134A@eusaamb103.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"maloy@donjonn.com" <maloy@donjonn.com>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:54194 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbaENRpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 13:45:43 -0400
Received: by mail-pb0-f41.google.com with SMTP id uo5so1591851pbc.14
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 10:45:43 -0700 (PDT)
In-Reply-To: <A2BAEFC30C8FD34388F02C9B3121859D1C25134A@eusaamb103.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-14 at 12:53 +0000, Jon Maloy wrote:

> For us, the underlying problem is that sk_backlog.len does not
> give correct information about the buffer situation.  There is a comment
> in  _release_sock() trying to explain why.:
> 
> /*
>   * Doing the zeroing here guarantee we can not loop forever
>   * while a wild producer attempts to flood us.
>   */
> 
> but I fail to understand how this scenario can happen even with TCP.
> Yes, it can throw away packets, but not until the receive buffer is full,
> and then sk_add_backlog() should start rejecting new messages anyway?
> There is evidently something I have missed here.

The following can happen :

An innocent user thread does a socket system call.
It owns the socket.

Then a flood of incoming messages happen, constantly trying to push new
packets for this socket. Note the packets can be spoofed ones.

Softirq handler notices socket is owned by 'user', so queue packets into
backlog, unless the sk_rcvbuf limit is hit.

If we were releasing sk_backlog.len for every dequeued skb, we could
have a deadlock for the innocent user thread, who could never exit from
__release_sock()

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=8eae939f1400326b06d0c9afe53d2a484a326871

So really you do not want to 'relax' this check.

All you need to do is have a big enough sk_rcvbuf for the expected and
reasonable amount of memory you allow to be stored in input queues for
your socket.
