From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net-next 4/4] Extend Kernel GTP-U tunneling documentation
Date: Tue, 14 Mar 2017 12:25:48 +0100
Message-ID: <20170314112548.24027-5-aschultz@tpip.net>
References: <20170314112548.24027-1-aschultz@tpip.net>
Cc: osmocom-net-gprs@lists.osmocom.org,
        netdev <netdev@vger.kernel.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>
To: Harald Welte <laforge@gnumonks.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:37472 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750868AbdCNL10 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 07:27:26 -0400
In-Reply-To: <20170314112548.24027-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* clarify specification references for v0/v1
* add section "APN vs. Network device"
* add section "Local GTP-U entity and tunnel identification"

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
Signed-off-by: Harald Welte <laforge@gnumonks.org>
---
 Documentation/networking/gtp.txt | 103 +++++++++++++++++++++++++++++++++++++--
 1 file changed, 99 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/gtp.txt b/Documentation/networking/gtp.txt
index 93e9675..0d9c18f 100644
--- a/Documentation/networking/gtp.txt
+++ b/Documentation/networking/gtp.txt
@@ -1,6 +1,7 @@
 The Linux kernel GTP tunneling module
 ======================================================================
-Documentation by Harald Welte <laforge@gnumonks.org>
+Documentation by Harald Welte <laforge@gnumonks.org> and
+                 Andreas Schultz <aschultz@tpip.net>
 
 In 'drivers/net/gtp.c' you are finding a kernel-level implementation
 of a GTP tunnel endpoint.
@@ -91,9 +92,13 @@ http://git.osmocom.org/libgtpnl/
 
 == Protocol Versions ==
 
-There are two different versions of GTP-U: v0 and v1.  Both are
-implemented in the Kernel GTP module.  Version 0 is a legacy version,
-and deprecated from recent 3GPP specifications.
+There are two different versions of GTP-U: v0 [GSM TS 09.60] and v1
+[3GPP TS 29.281].  Both are implemented in the Kernel GTP module.
+Version 0 is a legacy version, and deprecated from recent 3GPP
+specifications.
+
+GTP-U uses UDP for transporting PDUs.  The receiving UDP port is 2151
+for GTPv1-U and 3386 for GTPv0-U.
 
 There are three versions of GTP-C: v0, v1, and v2.  As the kernel
 doesn't implement GTP-C, we don't have to worry about this.  It's the
@@ -133,3 +138,93 @@ doe to a lack of user interest, it never got merged.
 In 2015, Andreas Schultz came to the rescue and fixed lots more bugs,
 extended it with new features and finally pushed all of us to get it
 mainline, where it was merged in 4.7.0.
+
+== Architectural Details ==
+
+=== Local GTP-U entity and tunnel identification ===
+
+GTP-U uses UDP for transporting PDU's. The receiving UDP port is 2152
+for GTPv1-U and 3386 for GTPv0-U.
+
+There is only one GTP-U entity (and therefor SGSN/GGSN/S-GW/PDN-GW
+instance) per IP address. Tunnel Endpoint Identifier (TEID) are unique
+per GTP-U entity.
+
+A specific tunnel is only defined by the destination entity. Since the
+destination port is constant, only the destination IP and TEID define
+a tunnel. The source IP and Port have no meaning for the tunnel.
+
+Therefore:
+
+  * when sending, the remote entity is defined by the remote IP and
+    the tunnel endpoint id. The source IP and port have no meaning and
+    can be changed at any time.
+
+  * when receiving the local entity is defined by the local
+    destination IP and the tunnel endpoint id. The source IP and port
+    have no meaning and can change at any time.
+
+[3GPP TS 29.281] Section 4.3.0 defines this so:
+
+> The TEID in the GTP-U header is used to de-multiplex traffic
+> incoming from remote tunnel endpoints so that it is delivered to the
+> User plane entities in a way that allows multiplexing of different
+> users, different packet protocols and different QoS levels.
+> Therefore no two remote GTP-U endpoints shall send traffic to a
+> GTP-U protocol entity using the same TEID value except
+> for data forwarding as part of mobility procedures.
+
+The definition above only defines that two remote GTP-U endpoints
+*should not* send to the same TEID, it *does not* forbid or exclude
+such a scenario. In fact, the mentioned mobility procedures make it
+necessary that the GTP-U entity accepts traffic for TEIDs from
+multiple or unknown peers.
+
+Therefore, the receiving side identifies tunnels exclusively based on
+TEIDs, not based on the source IP!
+
+== APN vs. Network Device ==
+
+The GTP-U driver creates a Linux network device for each Gi/SGi
+interface.
+
+[3GPP TS 29.281] calls the Gi/SGi reference point an interface. This
+may lead to the impression that the GGSN/P-GW can have only one such
+interface.
+
+Correct is that the Gi/SGi reference point defines the interworking
+between +the 3GPP packet domain (PDN) based on GTP-U tunnel and IP
+based networks.
+
+There is no provision in any of the 3GPP documents that limits the
+number of Gi/SGi interfaces implemented by a GGSN/P-GW.
+
+[3GPP TS 29.061] Section 11.3 makes it clear that the selection of a
+specific Gi/SGi interfaces is made through the Access Point Name
+(APN):
+
+> 2. each private network manages its own addressing. In general this
+>    will result in different private networks having overlapping
+>    address ranges. A logically separate connection (e.g. an IP in IP
+>    tunnel or layer 2 virtual circuit) is used between the GGSN/P-GW
+>    and each private network.
+>
+>    In this case the IP address alone is not necessarily unique.  The
+>    pair of values, Access Point Name (APN) and IPv4 address and/or
+>    IPv6 prefixes, is unique.
+
+In order to support the overlapping address range use case, each APN
+is mapped to a separate Gi/SGi interface (network device).
+
+NOTE: The Access Point Name is purely a control plane (GTP-C) concept.
+At the GTP-U level, only Tunnel Endpoint Identifiers are present in
+GTP-U packets and network devices are known
+
+Therefore for a given UE the mapping in IP to PDN network is:
+  * network device + MS IP -> Peer IP + Peer TEID,
+
+and from PDN to IP network:
+  * local GTP-U IP + TEID  -> network device
+
+Furthermore, before a received T-PDU is injected into the network
+device the MS IP is checked against the IP recorded in PDP context.
-- 
2.10.2
