From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation [try #3]
Date: Tue, 20 Mar 2007 22:26:13 +0000
Message-ID: <15256.1174429573@redhat.com>
References: <20070320213657.15afe5fa@lxorguk.ukuu.org.uk>  <20070320195856.12853.63473.stgit@warthog.cambridge.redhat.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org, dhowells@redhat.com
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59101 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752022AbXCTW0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 18:26:31 -0400
In-Reply-To: <20070320213657.15afe5fa@lxorguk.ukuu.org.uk> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> - recvmsg not supporting MSG_TRUNC is rather weird and really ought to be
> fixed one day as its useful to find out the sizeof message pending when
> combined with MSG_PEEK

Hmmm...  I hadn't considered that.  I assumed MSG_TRUNC not to be useful as
arbitrarily chopping bits out of the request or reply would seem to be
pointless.

> - RXRPC_MIN_SECURITY_LEVEL reads into rx->min_sec_level and then if it is
> invalid reports an error but doesn't restore the valid level

Fixed.

> - Why does rxrpc_writable always return 0 ?

Good point.  That's slightly tricky to deal with as output messages don't
remain queued on the socket struct itself.  Hmmm...

One thing I'd like to be able to do is pass the sk_buffs I've set up to UDP
directly rather than having to call the UDP socket's sendmsg.  That'd eliminate
a copy.  But I decided to get it working right first, then look at cute
optimisations like that.

Such a thing would also be useful for the AFS filesystem: it could pass skbuffs
it has preloaded to AF_RXRPC, which would then hand them on to UDP.

> - rxrpc_process_soft_ACKs doesn't itself limit and check acns->nAcks is
> always below RXRPC_MAXACKS, as this is a stakc variable it ought to be
> paranoid about it. I think its ok from the caller check but its very hard
> to prove...

nAcks is a uint8_t.  If that can exceed RXRPC_MAXACKS (255) then I suspect I'll
have more pressing worries.  I could put a check in there, but the compiler
would give me a warning:-/

> It needs a lot more eyes/review due to the complexity and network
> exposure though - not your fault, whoever designed RXRPC's 8)

It's not an entirely insane protocol:-) Actually, part of the problem is Linux
itself.

David
