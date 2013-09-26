From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v4 3/3] bonding: document the new xmit policy modes and update the changed ones
Date: Thu, 26 Sep 2013 18:13:44 +0200
Message-ID: <1380212024-3417-4-git-send-email-nikolay@redhat.com>
References: <1380212024-3417-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, vfalico@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5108 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753377Ab3IZQRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Sep 2013 12:17:25 -0400
In-Reply-To: <1380212024-3417-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new documentation for encap2+3 and encap3+4, also update the formula
for the old modes due to the changes.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v2, v3, v4: no change

 Documentation/networking/bonding.txt | 66 ++++++++++++++++++++----------------
 1 file changed, 36 insertions(+), 30 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 9b28e71..3856ed2 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -743,21 +743,16 @@ xmit_hash_policy
 		protocol information to generate the hash.
 
 		Uses XOR of hardware MAC addresses and IP addresses to
-		generate the hash.  The IPv4 formula is
+		generate the hash.  The formula is
 
-		(((source IP XOR dest IP) AND 0xffff) XOR
-			( source MAC XOR destination MAC ))
-				modulo slave count
+		hash = source MAC XOR destination MAC
+		hash = hash XOR source IP XOR destination IP
+		hash = hash XOR (hash RSHIFT 16)
+		hash = hash XOR (hash RSHIFT 8)
+		And then hash is reduced modulo slave count.
 
-		The IPv6 formula is
-
-		hash = (source ip quad 2 XOR dest IP quad 2) XOR
-		       (source ip quad 3 XOR dest IP quad 3) XOR
-		       (source ip quad 4 XOR dest IP quad 4)
-
-		(((hash >> 24) XOR (hash >> 16) XOR (hash >> 8) XOR hash)
-			XOR (source MAC XOR destination MAC))
-				modulo slave count
+		If the protocol is IPv6 then the source and destination
+		addresses are first hashed using ipv6_addr_hash.
 
 		This algorithm will place all traffic to a particular
 		network peer on the same slave.  For non-IP traffic,
@@ -779,21 +774,16 @@ xmit_hash_policy
 		slaves, although a single connection will not span
 		multiple slaves.
 
-		The formula for unfragmented IPv4 TCP and UDP packets is
-
-		((source port XOR dest port) XOR
-			 ((source IP XOR dest IP) AND 0xffff)
-				modulo slave count
+		The formula for unfragmented TCP and UDP packets is
 
-		The formula for unfragmented IPv6 TCP and UDP packets is
+		hash = source port, destination port (as in the header)
+		hash = hash XOR source IP XOR destination IP
+		hash = hash XOR (hash RSHIFT 16)
+		hash = hash XOR (hash RSHIFT 8)
+		And then hash is reduced modulo slave count.
 
-		hash = (source port XOR dest port) XOR
-		       ((source ip quad 2 XOR dest IP quad 2) XOR
-			(source ip quad 3 XOR dest IP quad 3) XOR
-			(source ip quad 4 XOR dest IP quad 4))
-
-		((hash >> 24) XOR (hash >> 16) XOR (hash >> 8) XOR hash)
-			modulo slave count
+		If the protocol is IPv6 then the source and destination
+		addresses are first hashed using ipv6_addr_hash.
 
 		For fragmented TCP or UDP packets and all other IPv4 and
 		IPv6 protocol traffic, the source and destination port
@@ -801,10 +791,6 @@ xmit_hash_policy
 		formula is the same as for the layer2 transmit hash
 		policy.
 
-		The IPv4 policy is intended to mimic the behavior of
-		certain switches, notably Cisco switches with PFC2 as
-		well as some Foundry and IBM products.
-
 		This algorithm is not fully 802.3ad compliant.  A
 		single TCP or UDP conversation containing both
 		fragmented and unfragmented packets will see packets
@@ -815,6 +801,26 @@ xmit_hash_policy
 		conversations.  Other implementations of 802.3ad may
 		or may not tolerate this noncompliance.
 
+	encap2+3
+
+		This policy uses the same formula as layer2+3 but it
+		relies on skb_flow_dissect to obtain the header fields
+		which might result in the use of inner headers if an
+		encapsulation protocol is used. For example this will
+		improve the performance for tunnel users because the
+		packets will be distributed according to the encapsulated
+		flows.
+
+	encap3+4
+
+		This policy uses the same formula as layer3+4 but it
+		relies on skb_flow_dissect to obtain the header fields
+		which might result in the use of inner headers if an
+		encapsulation protocol is used. For example this will
+		improve the performance for tunnel users because the
+		packets will be distributed according to the encapsulated
+		flows.
+
 	The default value is layer2.  This option was added in bonding
 	version 2.6.3.  In earlier versions of bonding, this parameter
 	does not exist, and the layer2 policy is the only policy.  The
-- 
1.8.1.4
