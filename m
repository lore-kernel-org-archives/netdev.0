From: John <linux@8192.net>
Subject: [PATCH V2 2/2] bonding support for IPv6 transmit hashing
Date: Tue, 17 Apr 2012 17:28:02 -0700
Message-ID: <4F8E0A92.5090408@8192.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp191.dfw.emailsrvr.com ([67.192.241.191]:36127 "EHLO
	smtp191.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753150Ab2DRAhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 20:37:43 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by smtp9.relay.dfw1a.emailsrvr.com (SMTP Server) with ESMTP id ABD123C0323
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 20:28:00 -0400 (EDT)
Received: by smtp9.relay.dfw1a.emailsrvr.com (Authenticated sender: john-AT-8192.net) with ESMTPSA id 781883C0264
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 20:28:00 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--- a/Documentation/networking/bonding.txt	2012-02-08 19:21:53.000000000 -0800
+++ b/Documentation/networking/bonding.txt	2012-02-13 01:11:35.000000000 -0800
@@ -753,12 +753,22 @@
  		protocol information to generate the hash.

  		Uses XOR of hardware MAC addresses and IP addresses to
-		generate the hash.  The formula is
+		generate the hash.  The IPv4 formula is

  		(((source IP XOR dest IP) AND 0xffff) XOR
  			( source MAC XOR destination MAC ))
  				modulo slave count

+		The IPv6 forumla is
+
+		iphash =
+			(source ip quad 2 XOR dest IP quad 2) XOR
+			(source ip quad 3 XOR dest IP quad 3) XOR
+			(source ip quad 4 XOR dest IP quad 4)
+
+		((iphash >> 16) XOR (iphash >> 8) XOR iphash)
+			modulo slave count
+
  		This algorithm will place all traffic to a particular
  		network peer on the same slave.  For non-IP traffic,
  		the formula is the same as for the layer2 transmit
@@ -779,19 +789,30 @@
  		slaves, although a single connection will not span
  		multiple slaves.

-		The formula for unfragmented TCP and UDP packets is
+		The formula for unfragmented IPv4 TCP and UDP packets is

  		((source port XOR dest port) XOR
  			 ((source IP XOR dest IP) AND 0xffff)
  				modulo slave count

-		For fragmented TCP or UDP packets and all other IP
-		protocol traffic, the source and destination port
+		The formula for unfragmented IPv6 TCP and UDP packets is
+
+		iphash =
+			(source ip quad 2 XOR dest IP quad 2) XOR
+			(source ip quad 3 XOR dest IP quad 3) XOR
+			(source ip quad 4 XOR dest IP quad 4)
+
+		((source port XOR dest port) XOR
+			(iphash >> 16) XOR (iphash >> 8) XOR iphash)
+				modulo slave count
+
+		For fragmented TCP or UDP packets and all other IPv4 and
+		IPv6 protocol traffic, the source and destination port
  		information is omitted.  For non-IP traffic, the
  		formula is the same as for the layer2 transmit hash
  		policy.

-		This policy is intended to mimic the behavior of
+		The IPv4 policy is intended to mimic the behavior of
  		certain switches, notably Cisco switches with PFC2 as
  		well as some Foundry and IBM products.
