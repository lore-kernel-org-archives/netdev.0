From: Oren Laadan <orenl@librato.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v6)
Date: Tue, 04 Aug 2009 04:27:27 -0400
Message-ID: <4A77F0EF.9090602@librato.com>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com>	<1248295301-30930-6-git-send-email-danms@us.ibm.com>	<4A6F2D62.9040005@librato.com> <87ljm8czsf.fsf@caffeine.danplanet.com>	<4A6F6B19.9010508@librato.com> <878wi6yxui.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, Alexey Dobriyan <adobriyan@gmail.com>,
	netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp201.iad.emailsrvr.com ([207.97.245.201]:40972 "EHLO
	smtp201.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755268AbZHDI12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 04:27:28 -0400
In-Reply-To: <878wi6yxui.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dan Smith wrote:
> OL> Hmm.. then what happens when you have a circular dependency ?  For
> OL> example, three dgram sockets, A, B and C where: A->B, B->C and
> OL> C->A ('->' means connected).
> 
> So, I've been cooking up changes to the patch and a test for this
> case.  However, it seems like it's not valid, unless I'm missing
> something.  The man page for connect() says:
> 
>   If the socket sockfd is of type SOCK_DGRAM then serv_addr is the
>   address to which datagrams are sent by default, and the only address
>   from which datagrams are received.
> 
> So, even though you can connect() a DGRAM socket and then sendto()
> datagrams to a different location, it doesn't appear that the
> relationship between A and B is really valid, at least the connection
> between A and B is not functional.  In fact, in my testing, if you try
> to connect() C back to A, you get "Operation not permitted" because A
> is already connected elsewhere.

Weird ... I have a faint memory of seeing that happen (which is
why I brought it up).

Does this mean that a situation of A->B and B->C is valid only as
long as A->B is done first, otherwise A->B will fail because B will
already be connected to C ?

Then, the other problem is to restore correctly you need to mimic
the behavior of sendto() because of the way the skb references the
original socket for the write-buf accounting :(

In turn, this means that during checkpoint you need to record the
_origin_ of each buffer in the queue of afunix dgram sockets :((

Sigh :(((

Oren.
