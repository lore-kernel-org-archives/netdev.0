From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation [try #3]
Date: Wed, 21 Mar 2007 18:10:35 +0000
Message-ID: <24260.1174500635@redhat.com>
References: <15256.1174429573@redhat.com>  <20070320213657.15afe5fa@lxorguk.ukuu.org.uk> <20070320195856.12853.63473.stgit@warthog.cambridge.redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, davem@davemloft.net,
	netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37312 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965145AbXCVA5O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 20:57:14 -0400
In-Reply-To: <15256.1174429573@redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Howells <dhowells@redhat.com> wrote:

> > - recvmsg not supporting MSG_TRUNC is rather weird and really ought to be
> > fixed one day as its useful to find out the sizeof message pending when
> > combined with MSG_PEEK
> 
> Hmmm...  I hadn't considered that.  I assumed MSG_TRUNC not to be useful as
> arbitrarily chopping bits out of the request or reply would seem to be
> pointless.

But why do I need to support MSG_TRUNC?  I currently have things arranged so
that if you do a recvmsg() that doesn't pull everything out of a packet then
the next time you do a recvmsg() you'll get the next part of the data in that
packet.  MSG_EOR is flagged when recvmsg copies across the last byte of data
of a particular phase.

I might at some point in the future enable recvmsg() to keep pulling packets
off the Rx queue and copying them into userspace until the userspace buffer is
full or we find that the next packet is not the logical next in sequence.

Hmmm...  I'm actually overloading MSG_EOR.  MSG_EOR is flagged on the last
data read, and is also flagged for terminal messages (end or reply data,
abort, net error, final ACK, etc).  I wonder if I should use MSG_MORE (or its
lack) instead to indicate the end of data, and only set MSG_EOR on the
terminal message.

MSG_MORE is set by the app to flag to sendmsg() that there's more data to
come, so it would be consistent to use it for recvmsg() too.

David
