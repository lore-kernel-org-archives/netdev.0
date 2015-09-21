From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH RFC 0/3] kcm: Kernel Connection Multiplexor (KCM)
Date: Mon, 21 Sep 2015 08:24:22 -0400
Message-ID: <20150921122422.GA31092@oracle.com>
References: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24560 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751903AbbIUMY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 08:24:29 -0400
Content-Disposition: inline
In-Reply-To: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/20/15 15:29), Tom Herbert wrote:
> 
> Kernel Connection Multiplexor (KCM) is a facility that provides a
> message based interface over TCP for generic application protocols.
> The motivation for this is based on the observation that although
> TCP is byte stream transport protocol with no concept of message
> boundaries, a common use case is to implement a framed application
> layer protocol running over TCP. To date, most TCP stacks offer
> byte stream API for applications, which places the burden of message
> delineation, message I/O operation atomicity, and load balancing
> in the application. With KCM an application can efficiently send
> and receive application protocol messages over TCP using a
> datagram interface.

A lot of this design is very similar to the PF_RDS/RDS-TCP
design. There too, we have a PF_RDS dgram socket (that already 
supports SEQPACKET semantics today) that can be tunneled over TCP.

The biggest design difference that I see in your proposal is 
that you are using BPF so presumably the demux has more flexibility
than RDS, which does the demux based on RDS port numbers?

Would it make sense to build your solution on top of RDS,
rather than re-invent solutions for many of the challenges
that one encounters when building a dgram-over-stream hybrid
socket (see "lessons learned" list below)?

Some things that were not clear to me from the patch-set:

The doc statses that we re-assemble packets the "stated length" -
but how will the receiver know the "stated length"? 
(fwiw, RDS figures that out from the header len in RDS,
and elsewhere I think you allude to some similar encaps
header - is that a correct understanding?)

not clear from the diagram: Is there one TCP socket per kcm-socket? 
what is the relation (one-one, many-one etc.)  between a kcm-socket and
a psock?  How does the ksock-psock-tcp-sock association get set up? 

the notes say one can "accept()" over a kcm socket- but "accept()"
is itself a connection-oriented concept- one does not accept() on
a dgram socket. So what exactly does this mean, and why not just
use the well-defined TCP socket semantics at that point (with something
like XDR for message boundary marking)?

In the "fwiw" bucket of lessons learned from RDS..  please ignore if
you were already aware of these- 

In the case of RDS, since multiple rds/dgram sockets share a single TCP
socket, some issues that have to be dealt with are

- congestion/starvation: we dont want tcp to start advertising
  zero-window because one dgram socket pair has flooded the pipe
  and the peer is not reading. So the RDS protocol has port-congestion
  RDS control plane messages that track congestion at the RDS port.

- imposes some constraints on the TCP send side- if sock1 and sock2
  are sharing a tcp socket, and both are sending dgrams over the 
  stream, dgrams from sock1 may get interleaved  (see comments above
  rds_send_xmit() for a note on how rds deals witt this). There are ways
  to fan this out over multiple tcp sockets (and I'm working on those,
  to improve the scaling), but just a note that there is some complexity
  to be dealt with here. Not sure if this was considered in the "KCM
  sockets" section in patch2..

- in general the "dgram-over-stream" hybrid has some peculiar issues. E.g.,
  dgram APIs like BINDTODEVICE and IP_PKTINFO cannot be applied
  to the underlying stream. In the typical use case for RDS (database 
  clusters) there's a reasonable workaround for this using network
  namespaces to define bundles of outgoing interfaces, but that solution
  may not always be workable for other use-cases. Thus it might actually
  be more obvious to simply use tcp sockets (and use something like XDR
  for message boundary markers on the stream).

--Sowmini
 
