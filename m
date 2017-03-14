From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net-next 0/4] gtp: support multiple APN's per GTP endpoint
Date: Tue, 14 Mar 2017 12:25:44 +0100
Message-ID: <20170314112548.24027-1-aschultz@tpip.net>
Cc: osmocom-net-gprs@lists.osmocom.org,
        netdev <netdev@vger.kernel.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>
To: Harald Welte <laforge@gnumonks.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:54377 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750846AbdCNL1X (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 07:27:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support multiple APN's per GTP endpoint and as an additional benefit support
multiple GTP sockets per GTP entity.

Use case multiple APN's:
------------------------

In 3GPP a APN is control path construct. When mappend into the data path,
it mean that UE IP's can be source from independended IP networks with
overlaping IP ranges.

3GPP, TS 29.061 version 13.6.0 Release 13, Section 11.3 describes this as:

> 2. each private network manages its own addressing. In general this will
>    result in different private networks having overlapping address ranges.
>    A logically separate connection (e.g. an IP in IP tunnel or layer 2
>    virtual circuit) is used between the GGSN/P-GW and each private network.
>    In this case the IP address alone is not necessarily unique. The pair
>    of values, Access Point Name (APN) and IPv4 address and/or IPv6 prefixes,
>    is unique.

To support such a setup, each APN is mapped to a Linux network device.
VRF-Lite, network namespaces or other mechanismns can the be used to realize
the full separation of the per APN IP networks.

Use case multiple GTP sockets per GTP entity:
---------------------------------------------

A GTP entity like a PGW can use multiple GTP sockets for:

 * separate IPv4 and IPv6 transport endpoints
 * support multiple reference points in separated IP networks, e.g. have
   Gn/Gp/S5/S8 in a GRX attaches network and S2a/S2b in another private
   network

Especially the S2a/S2b separation is an important scenario. The networks
use for roaming and non roaming attachment (Gn/Gp/S5/S8 reference points)
are usually different from the connection for trusted and untrusted WiFi
access (S2a/S2b). Will the GTP transport networks are separated, it is
still desirable to terminated the tunnels in the same GTP entity to ensure
uninterrupted IP connectivity during 3G/LTE to/from WiFi handover.

Implementation:
---------------

APN's are a control path construct, the identification of the associated network
device need therefore to be bound to be tunnel endpoint identifier.

This series moves the hash for the incoming tunnel endpoint identifiers into
the socket to support multiple network devices per GTP socket. It the adds
a method of enabling the GTP encapsulation on a socket without having to
bound the socket to a network device and finally allows to specify a GTP
socket per PDP context.

API impact:
-----------

This is probably the most problematic part of this series...

The removeal of the TEID form the netdevice also means that the gtp genl API
for retriving tunnel information and removing tunnels needs to be adjusted.

Before this change it was possible to change a GTP tunnel using the gtp
netdevice id and the teid. The teid is no longer unique per gtp netdevice.
After this change it has to be either the netdevice and MS IP or the GTP
socket and teid.

Fortunatly, libgtpnl has always populated the Link Id, TEID, GSN Peer IP and
MS IP. The library interface has ensured that all information that is mandatory
after this change is guaranteed to be present.

The only project that doesn't use libgtpnl (OpenAir-CN) is also populating
all of those values.

The API change will therefore not break any existing userspace applications.
