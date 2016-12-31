From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] af_packet: Provide a TPACKET_V2 compatible Tx
 path for TPACKET_V3
Date: Fri, 30 Dec 2016 19:48:26 -0500
Message-ID: <20161231004826.GC31800@oracle.com>
References: <1483116853-45769-1-git-send-email-sowmini.varadhan@oracle.com>
 <CAF=yD-+CMjr_9s2wVZOQEPAP5h9jpnMe3vckYGbQ9hnQoGWFEw@mail.gmail.com>
 <20161230230316.GB31800@oracle.com>
 <CAF=yD-JiRDnYPB=W37T5tF7rVVGD5bACK6YkSWwuGdF2PdOdBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:38278 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752210AbcLaAso (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 19:48:44 -0500
Content-Disposition: inline
In-Reply-To: <CAF=yD-JiRDnYPB=W37T5tF7rVVGD5bACK6YkSWwuGdF2PdOdBQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (12/30/16 18:39), Willem de Bruijn wrote:
> 
> Variable length slots seems like the only one from that list that
> makes sense on Tx.
> 
> It is already possible to prepare multiple buffers before triggering
> transmit, so the block-based signal moderation is not very relevant.

FWIW, here is our experience

In our use cases, the blocking on the RX side comes quite naturally
to the application (since, upon waking from select(), we try 
to read as many requests as possible, until we run out of buffers
and/or input), but the response side is not batched today: the server
application sends out one response at a time, and trying to change
this would need additional batching-intelligence in the server. We
are working on the latter part, but as you point out, we can  prepare
multiple buffers before triggering transmit, so some variant of block
TX seems achievable.

Our response messages are usually well-defined multiples of PAGE_SIZE,
(and we are able to set Jumbo MTU) so the variable length slots is not
an issue we foresee (see additional comment on this below).

The block RX is interesting because it allows the server better control
over context-switches and system-calls. This is important because our
input request stream tends to be bursty - the senders (clients) of the
request have to do some computationally intense work before sending the
next request, so being able to adjust the timeout for poll wakeup at
the server is a useful knob.

Having 2 sockets instead of one is unattractive because it just makes
the existing API more clumsy - today  we are using UDP, RDS-TCP and
RDS-IB sockets, and all of this is built around a POSIX-like paradigm
of having some type of select(), sendmsg(), recvmsg() API with a single
socket. Even just extending this to also handle TPACKET_V2 (and tracking
needed context) is messy. Having to convert all this to a 2-socket model
would need significant perf justification, and we havent seen that
justification in our micro-benchmarks yet.

(and fwiw, the POSIX-like API with a single file desc for all I/O
is a major consideration, since the I/O can come from other sources 
like disk, fs etc, and it's cleanest if we follow the same paradigm
for networking as well)

> > since then apps that want to use the Rx benefits
> > have to deal with this dual socket feature, where
> > with "one socket for super-fast rx, zero Tx".
> > The zero-tx part sounds like a regression to me.
> 
> What is the issue with using separate sockets that you are
> having? I generally end up using that even with V2.

Why do you end up having to use 2 sockets with V2? That part
worked out quite nicely for my case (for a simple netserver like 
req/resp handler).

> But the semantics for V3 are currenty well defined. Calling something
> V3, but using V2 semantics is a somewhat unintuitive interface to me.

One fundamental part of tpacket that makes it attractive to 
alternatives like netmap, dpdk etc is that the API follows the
semantics of the classic  unix socket and fd APIs: support for basic
select/sendmsg/recvmsg that work for everything until _V3. 

> I don't see a benefit in defining something that does not implement
> any new features. Especially if it blocks adding the expected
> semantics later.

V3 removed the sendmsg feature.  This patch puts back that feature.

> That said, if there is a workload that benefits from using a
> single socket, and especially if it can be forward compatible with
> support for variable sized slots, then I do not object. I was just
> having a look at that second point, actually.

Actually I'm not averse to looking at extensions (or at least,
place-holders) to allow variable sized slots- do you have any
suggestions? As I mentioned before, the use-cases that I see
do not need variable length slots, thus I have not thought
too deeply about it. But if we think this may be needed in the 
future can't it be accomodated by additional sockopts (or even 
per-packet cmsghdr?) on top of V3? 

> Could you also extend the TX_RING test in
> tools/testing/selftests/net/psock_tpacket.c if there are no other
> blocking issues?

sure, I can do that. Let me do this for patchv2. 

--Sowmini
