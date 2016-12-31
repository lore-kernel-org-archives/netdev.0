From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] af_packet: Provide a TPACKET_V2 compatible Tx
 path for TPACKET_V3
Date: Fri, 30 Dec 2016 23:59:08 -0500
Message-ID: <CAF=yD-Jgui0gBeZuzfJRN1uozV+LqVm76tnKUnChSg7_z9-1ng@mail.gmail.com>
References: <1483116853-45769-1-git-send-email-sowmini.varadhan@oracle.com>
 <CAF=yD-+CMjr_9s2wVZOQEPAP5h9jpnMe3vckYGbQ9hnQoGWFEw@mail.gmail.com>
 <20161230230316.GB31800@oracle.com> <CAF=yD-JiRDnYPB=W37T5tF7rVVGD5bACK6YkSWwuGdF2PdOdBQ@mail.gmail.com>
 <20161231004826.GC31800@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:33148 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754615AbcLaE7u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 23:59:50 -0500
Received: by mail-ua0-f193.google.com with SMTP id d5so19117964uag.0
        for <netdev@vger.kernel.org>; Fri, 30 Dec 2016 20:59:49 -0800 (PST)
In-Reply-To: <20161231004826.GC31800@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> What is the issue with using separate sockets that you are
>> having? I generally end up using that even with V2.
>
> Why do you end up having to use 2 sockets with V2? That part
> worked out quite nicely for my case (for a simple netserver like
> req/resp handler).

Yes, that should work fine, actually. I was thinking of multi-threaded
setups where using per-cpu tx sockets avoids cacheline bouncing, but
there is no reason to have a receive socket on each cpu. But that's
not a standard setup.

>> But the semantics for V3 are currenty well defined. Calling something
>> V3, but using V2 semantics is a somewhat unintuitive interface to me.
>
> One fundamental part of tpacket that makes it attractive to
> alternatives like netmap, dpdk etc is that the API follows the
> semantics of the classic  unix socket and fd APIs: support for basic
> select/sendmsg/recvmsg that work for everything until _V3.
>
>> I don't see a benefit in defining something that does not implement
>> any new features. Especially if it blocks adding the expected
>> semantics later.
>
> V3 removed the sendmsg feature.  This patch puts back that feature.

You mean send ring, right? The sendmsg call works fine on a single socket
alongside an RX_RING until a TX_RING is installed.

>> That said, if there is a workload that benefits from using a
>> single socket, and especially if it can be forward compatible with
>> support for variable sized slots, then I do not object. I was just
>> having a look at that second point, actually.
>
> Actually I'm not averse to looking at extensions (or at least,
> place-holders) to allow variable sized slots- do you have any
> suggestions?

It is probably enough to just enforce that tp_next_offset is always
sane. Either that it points to the start of the next packet, even
though that currently can also be inferred from frame_size. Or, that
it is always zero unless the ring is to be interpreted as holding
variable sized frames. If the field is non-zero, drop the packet.

> As I mentioned before, the use-cases that I see
> do not need variable length slots, thus I have not thought
> too deeply about it. But if we think this may be needed in the
> future can't it be accomodated by additional sockopts (or even
> per-packet cmsghdr?) on top of V3?
>
>> Could you also extend the TX_RING test in
>> tools/testing/selftests/net/psock_tpacket.c if there are no other
>> blocking issues?
>
> sure, I can do that. Let me do this for patchv2.

Great. Thanks!
