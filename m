From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch v2] net: heap overflow in __audit_sockaddr()
Date: Wed, 27 Nov 2013 22:18:23 +0100
Message-ID: <20131127211823.GD20630@order.stressinduktion.org>
References: <1380748306.1795.67.camel@bwh-desktop.uk.level5networks.com> <20131002212720.GA30492@elgon.mountain> <20131127113218.GB1612@dcvr.yhbt.net> <20131127115120.GC20630@order.stressinduktion.org> <CA+55aFwP5NWG9doOqZRy7fBdUpwW-bDwEJxjMV0Yr3q3Y=30Fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Wong <normalperson@yhbt.net>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	"security@kernel.org" <security@kernel.org>,
	=?utf-8?B?SsO8cmk=?= Aedla <juri.aedla@gmail.com>,
	"# .39.x" <stable@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43012 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753802Ab3K0VSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 16:18:24 -0500
Content-Disposition: inline
In-Reply-To: <CA+55aFwP5NWG9doOqZRy7fBdUpwW-bDwEJxjMV0Yr3q3Y=30Fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 27, 2013 at 12:24:41PM -0800, Linus Torvalds wrote:
> On Wed, Nov 27, 2013 at 3:51 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> >
> > We have to clamp msg_namelen to max sizeof(struct sockaddr_storage).
> > The sendmsg handler will check msg_namelen again and error out correctly if
> > the size of msg_name is too short.
> 
> Yeah, clamping sounds like the right thing to do at least for
> receiving. For sending, you should say "we can't send packets that big
> due to memory constraints" (of, for the case of a sockaddr, "to an
> address this big"), but for receiving the size of the user space
> buffer is kind of irrelevant - if the user gives a bigger buffer than
> necessary, who cares? We just need to make sure that the kernel
> doesn't then allocate silly-big temporary buffers internally.
>
> There seems to be a patch floating around to clamp things already.

Data buffers are clamed fine already.

The sockaddr buffers are currently always 128 bytes (== sizeof(struct
sockaddr_storage)) in size and are allocated on the stack of the
recvmsg/sendmsg syscall handlers. We normally don't have high stack usage
on recvmsg calls but it could be worth trying to optimize that on sendmsg,
I agree. I have not seen a patch which tries to do so but maybe I haven't
looked far enough back in the mailing list archives.

Clamping on sending seems necessary to not break exisiting applications. I
guess those programs expect the kernel to know which namelen the
protocol expects and only use that part of the provided sockaddr
buffer (an example is the mentioned ruby bug in this thread which
seems to pass down the size of a union for all possile sockaddrs:
<https://bugs.ruby-lang.org/issues/9124#note-2>).

I recently noticed a some more subtile annoyance in that code:

We don't know the anticipated sockaddr size before calling the recvmsg
handler. Hence it is currently possible that we dequeue a packet from
the socket receiving queue and later error out and drop the packet because
the user provided a socket address buffer which is too small. IMHO we
should catch that before dequeueing the packet. Either we can export the
address size via the per-protocol-structures or we have to start passing the
user provided buffer sizes down the stack (currently all recvmsg handlers
expect to always have 128 bytes for storing addresses).

I'll look into this.

Greetings,

  Hannes
