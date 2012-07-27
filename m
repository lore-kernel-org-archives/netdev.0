From: Peter Samuelson <psamuelson@efolder.net>
Subject: TCP stalls with 802.3ad + bridge + kvm guest
Date: Fri, 27 Jul 2012 13:38:40 -0500
Message-ID: <20120727183840.GE17572@p12n.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgoerzen@efolder.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx11.dcmx.net ([207.210.100.175]:52765 "EHLO mx11.dcmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752338Ab2G0TbO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2012 15:31:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


So, we have the following network stack:

    ixgbe [10 Gbit port] -- bonding [802.3ad] -- bridge -- KVM guest

(There's also a VLAN layer, but I can reproduce this problem without
it.)  It all works, except that with some flows in the KVM guest - I
can reproduce using smbclient - transfers keep stalling, such that I'm
averaging well under 1 MB/s.  Should be more like 100 MB/s.

Oddly, this only occurs when both the 802.3ad and KVM are used:

    Server        Agg        Client         TCP stalls
    --------------------------------------------------
    external      none       KVM guest      no
    external      802.3ad    KVM host       no
    KVM host      802.3ad    KVM guest      no
    external      802.3ad    KVM guest      yes

I don't understand the stalls.  'ping -f' does not show any dropped
packets.  tcpdump seems to show a lot of retransmits (server to
client), out-of-order TCP segments (server to client), and duplicate
ACKs (client to server).

Further notes:

- OS for KVM host (and guest) is Debian stable, with kernels from
  Debian backports.  I've tried several kernels including 3.4,
  currently using 3.2.20.

- Arista 10 Gbit switch, no congestion to speak of, all the test
  traffic is local to the switch.

- I can reproduce with either 1 or 2 active ports in the LACP group.

- The host IP is bound to the bridge, not directly to bond0.

- First noticed problem with a Windows VM and SMB.  I can reproduce
  100% using smbclient, but wget (http) goes full speed.

Does any of this sound familiar?  Is it a known issue?  Can anyone
offer any hints?  I can run tcpdump on the client, the server or any
point in the KVM host network stack, in case anyone is better at
interpreting them than I am.

Thanks,
Peter
