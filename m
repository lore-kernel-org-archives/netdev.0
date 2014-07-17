From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 0/9] gue: Generic UDP Encapsulation
Date: Wed, 16 Jul 2014 21:14:10 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407162053360.24931@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:33083 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575AbaGQETb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 00:19:31 -0400
Received: by mail-ig0-f202.google.com with SMTP id r2so225955igi.5
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 21:19:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Generic UDP Encapsulation (GUE) describes a general mechanism in
which IP tunnels (more packets of an IP protocol) are encapsulated
in UDP packets. The value using of UDP encapsulation is that mechanisms
in the network which work on UDP can be leveraged (e.g. RSS, ECMP,
etc.). In this patch set we implement "direct GUE encapsulation" in
which IPIP, GRE, or SIT packets are directly encapsulated in UDP
without any additional encpasulation header. The IP protocol of the
encapsulated packet is implied by the destination port (so for instance
we would bind to one port for receiving GRE/UDP, one for IPIP/UDP,
etc.)

GRE/UDP is specified in I-D draft-yong-tsvwg-gre-in-udp-encap-02,
IPIP and SIT can be similarly implemented. There is also a proposed
GUE protocol (draft-herbert-gue-01) which includes an encapsulation
header that specificies protocol of the encapsulated packet as well
as allowing for optional data fields. This can be implemented in a
follow on patch.

This patch set implements GUE as an optional extension to IP tunnels.
An IP tunnel can be configured to encapsulate using GUE (via new
"ip tunnel" commands). On transmit, the UDP header is a logically an
inserted header in the encapsulation and does not entail the need for
a separate network interface.

On the receive side XFRM and udp_encap_rcv are used. The only real work
needed here is that the UDP header is stripped and the packet is
reinjected to IP protocol processing for the protocol implied by the
destination port.

This patch set includes:
 - Implementation of GUE receive path including interfaces to call for
   binding UDP port and indicating associated IP protocol
 - Generic changes to ip_tunnel to insert UDP header on transmit when
   doing GUE encapsulation
 - Modifications to GRE, IPIP, and SIT code to configure GUE and
   transmit with the encapsulation, as well as setup code to open a
   UDP listener port for the protocol

Follow on patches will include
 - Modifications to ip tunnel command to configure GUE on a tunnel
 - Support for GRO and GSO (which includes solving issues of multi
   layer encapsulation 
 - GUE protocol implementation

* Performance

I ran performance numbers using netperf TCP_RR with 200 streams,
comparing encapsulation without GUE, encapsulation with GUE, and
encapsulation with GUE and configuring RSS to use UDP ports
"ethtool -N eth0 rx-flow-hash udp4 sdfn" (bnx2x NIC). The performance
differences are similar for GRE, IPIP, and SIT. GRE numbers are
below (SIT and IPIP numbers can be found in related patches).

  No GUE
    71.01% CPU utilization
    180/257/381 90/95/99% latencies
    1.03838e+06 tps

  With GUE
    73.73% CPU utilization
    182/261/369 90/95/99% latencies
    1.01568e+06 tps

  With GUE and UDP RSS
    94.49% CPU utilization
    156/248/461 90/95/99% latencies
    1.15948e+06 tps

No GUE vs. with GUE (no UDP RSS) demonstrates the simple cost of adding
the UDP encapsulation. As the above data shows, the difference isn't
hugely significant.  In comparing, with GUE and GUE with UDP RSS, the
tps went up but CPU utilization increased disproportionately. I suspect
this is more than overhead from parallelism in networking stack (ie.
more networking interrupts) but issues in the UDP receive path,
particularly the cost of taking socket references. Addressing the UDP
receive path performance for UDP encapsulation will hopefully be some
future work (IMO the overhead of UDP for encapsulation should be
negligible and hopefully won't require SO_REUSEPORT for that).
