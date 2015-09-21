From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC 0/3] kcm: Kernel Connection Multiplexor (KCM)
Date: Mon, 21 Sep 2015 10:33:12 -0700
Message-ID: <CALx6S34gmbEybQKmsL2=0wGh+LjktBLSimpOCrxWUyTYFFUhfA@mail.gmail.com>
References: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
	<20150921122422.GA31092@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:34100 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753480AbbIURdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 13:33:13 -0400
Received: by iofb144 with SMTP id b144so128103384iof.1
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 10:33:12 -0700 (PDT)
In-Reply-To: <20150921122422.GA31092@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sowmini,

Thanks for your comments, some replies are in line.

> A lot of this design is very similar to the PF_RDS/RDS-TCP
> design. There too, we have a PF_RDS dgram socket (that already
> supports SEQPACKET semantics today) that can be tunneled over TCP.
>
> The biggest design difference that I see in your proposal is
> that you are using BPF so presumably the demux has more flexibility
> than RDS, which does the demux based on RDS port numbers?
>
I did look a bit a RDS. Major differences with KCM are:

- KCM does not implement any specific protocol in the kernel. Parsing
in receive is accomplished using BPF which allows protocol parsing to
be programmed from userspace.
- Connection management is done in userspace. This is particularly
important when connections need to switch into a protocol mode, like
when doing HTTP/2, Web sockets, SPDY, etc. over port 80.

> Would it make sense to build your solution on top of RDS,
> rather than re-invent solutions for many of the challenges
> that one encounters when building a dgram-over-stream hybrid
> socket (see "lessons learned" list below)?

There might be some points of leverage, but as I pointed out the
primary goal of KCM is the multiplexing and datagram interface over
TCP not application protocol implementation in the kernel. It might be
interesting if there were a common protocol generic library to handle
the user interface.

>
> Some things that were not clear to me from the patch-set:
>
> The doc statses that we re-assemble packets the "stated length" -
> but how will the receiver know the "stated length"?

BPF program returns the length of the next message. In my testing so
far I've been using HTTP/2 which defines a frame format with first 3
bytes being header length field . The BPF program (using LLVM/Clang--
thanks Alexei!) is just:

int bpf_prog1(struct __sk_buff *skb)
{
     return (load_word(skb, 0) >> 8) + 9;
}

> (fwiw, RDS figures that out from the header len in RDS,
> and elsewhere I think you allude to some similar encaps
> header - is that a correct understanding?)
>
KCM does not define any encaps header, it is intended to support
existing ones. For instance, BPF code to get length from an RDS
message would be:

int bpf_prog1(struct __sk_buff *skb)
{
     return load_word(skb, 16) + 40;
}

> not clear from the diagram: Is there one TCP socket per kcm-socket?
> what is the relation (one-one, many-one etc.)  between a kcm-socket and
> a psock?  How does the ksock-psock-tcp-sock association get set up?
>
Each multiplexor is logically one destination. At the top multiple KCM
sockets allow concurrent operations in userspace, at the bottom
multiple TCP connections allow for load balancing. An application
controls construction of the multiplexor and would presumably create
multiplexor for each peer. See Documentaiton/net/kcm.txt for the
details on interfaces for plumbing.

> the notes say one can "accept()" over a kcm socket- but "accept()"
> is itself a connection-oriented concept- one does not accept() on
> a dgram socket. So what exactly does this mean, and why not just
> use the well-defined TCP socket semantics at that point (with something
> like XDR for message boundary marking)?
>
The accept method is overloaded on KCM sockets to do the socket
cloning operation. This is unrelated to TCP semantics, connection
management is performed on TCP sockets (i.e. before being attached to
a KCM multiplexor).

> In the "fwiw" bucket of lessons learned from RDS..  please ignore if
> you were already aware of these-
>
> In the case of RDS, since multiple rds/dgram sockets share a single TCP
> socket, some issues that have to be dealt with are
>
> - congestion/starvation: we dont want tcp to start advertising
>   zero-window because one dgram socket pair has flooded the pipe
>   and the peer is not reading. So the RDS protocol has port-congestion
>   RDS control plane messages that track congestion at the RDS port.
>
In KCM all upper sockets are equivalent so there is not HOL blocking
on receive or transmit. A message received on a multiplexor can be
steered to any socket that is receiving. Conceivably, we could
implement some message affinity, for instance sending an RPC reply to
same socket that made the request, but even that I think should only
be best effort to avoid having to deal with blocking.

> - imposes some constraints on the TCP send side- if sock1 and sock2
>   are sharing a tcp socket, and both are sending dgrams over the
>   stream, dgrams from sock1 may get interleaved  (see comments above
>   rds_send_xmit() for a note on how rds deals witt this). There are ways
>   to fan this out over multiple tcp sockets (and I'm working on those,
>   to improve the scaling), but just a note that there is some complexity
>   to be dealt with here. Not sure if this was considered in the "KCM
>   sockets" section in patch2..
>
Writing and reading messages atomically is a critical operation of the
multiplexor. This is implemented using a reservation model (see
reserve_psock, unreserve_psock).

> - in general the "dgram-over-stream" hybrid has some peculiar issues. E.g.,
>   dgram APIs like BINDTODEVICE and IP_PKTINFO cannot be applied
>   to the underlying stream. In the typical use case for RDS (database
>   clusters) there's a reasonable workaround for this using network
>   namespaces to define bundles of outgoing interfaces, but that solution
>   may not always be workable for other use-cases. Thus it might actually
>   be more obvious to simply use tcp sockets (and use something like XDR
>   for message boundary markers on the stream).
>
My intent is to add an "unconnected" mode to KCM which would allow
connections to different destinations (represented by connection
groups) to be attached to the same MUX. Destinations would be
specified by some sort of AF_KCM sockaddr.

Thanks,
Tom

> --Sowmini
>
>
>
