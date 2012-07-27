From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: TCP stalls with 802.3ad + bridge + kvm guest
Date: Fri, 27 Jul 2012 13:00:05 -0700
Message-ID: <26496.1343419205@death.nxdomain>
References: <20120727183840.GE17572@p12n.org>
Cc: netdev@vger.kernel.org, jgoerzen@efolder.net
To: Peter Samuelson <psamuelson@efolder.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:60757 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752549Ab2G0UAd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2012 16:00:33 -0400
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 27 Jul 2012 16:00:31 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 378366E803C
	for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 16:00:08 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6RK07E9390212
	for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 16:00:07 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6S1V094023524
	for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 21:31:00 -0400
In-reply-to: <20120727183840.GE17572@p12n.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Samuelson <psamuelson@efolder.net> wrote:
>So, we have the following network stack:
>
>    ixgbe [10 Gbit port] -- bonding [802.3ad] -- bridge -- KVM guest
>
>(There's also a VLAN layer, but I can reproduce this problem without
>it.)  It all works, except that with some flows in the KVM guest - I
>can reproduce using smbclient - transfers keep stalling, such that I'm
>averaging well under 1 MB/s.  Should be more like 100 MB/s.
>
>Oddly, this only occurs when both the 802.3ad and KVM are used:
>
>    Server        Agg        Client         TCP stalls
>    --------------------------------------------------
>    external      none       KVM guest      no
>    external      802.3ad    KVM host       no
>    KVM host      802.3ad    KVM guest      no
>    external      802.3ad    KVM guest      yes

	Does the "none" for Agg (the first line) mean no bonding at all?

	Does the problem happen if the bond is a different mode
(balance-xor, for example)?

>I don't understand the stalls.  'ping -f' does not show any dropped
>packets.  tcpdump seems to show a lot of retransmits (server to
>client), out-of-order TCP segments (server to client), and duplicate
>ACKs (client to server).

	Do the various stats on the host and guest show any drops?
E.g., from "netstat -i" and "tc -s qdisc"

>Further notes:
>
>- OS for KVM host (and guest) is Debian stable, with kernels from
>  Debian backports.  I've tried several kernels including 3.4,
>  currently using 3.2.20.
>
>- Arista 10 Gbit switch, no congestion to speak of, all the test
>  traffic is local to the switch.
>
>- I can reproduce with either 1 or 2 active ports in the LACP group.
>
>- The host IP is bound to the bridge, not directly to bond0.
>
>- First noticed problem with a Windows VM and SMB.  I can reproduce
>  100% using smbclient, but wget (http) goes full speed.
>
>Does any of this sound familiar?  Is it a known issue?  Can anyone
>offer any hints?  I can run tcpdump on the client, the server or any
>point in the KVM host network stack, in case anyone is better at
>interpreting them than I am.

	Maybe; I've seen a similar-sounding problem with CIFS wherein
the loss of the last or near-last packet that's part of the CIFS request
will cause TCP to run a full RTO.  This occurs because CIFS has no more
packets to send, as it's waiting for a response, so there is no
subsequent traffic that will trigger duplicate ACKs from the peer and
thus initiate a fast retransmission.  I may be mangling the CIFS
details, but that's the packet exchange that occurs, and it resulted in
very poor performance for CIFS.

	The case I saw this in was not using KVM, but was instead
dropping some packets at a network bottleneck.  In that case, CIFS
experienced the poor performance, but NFS did not; the NFS packet
captures also showed the lost packets, but NFS would continue to send
and issue fast retransmissions in response to the duplicate ACKs it
received.  Perhaps this mirrors your experience with CIFS vs. wget, and
your bottleneck is somewhere on the host itself in the virtual
networking.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
