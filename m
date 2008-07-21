From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: v2 [Patch 1/1] [BUG-FIX] udplite: Avoid u16 checksum coverage
	wrap-around
Date: Mon, 21 Jul 2008 11:04:09 +0100
Message-ID: <20080721100409.GA13198@gerrit.erg.abdn.ac.uk>
References: <20080630115427.GA8416@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:46481 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756300AbYGUKEU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 06:04:20 -0400
Content-Disposition: inline
In-Reply-To: <20080630115427.GA8416@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, can you please have a look at the patch below?

As per earlier request, the default behaviour of rounding small setsockopt
values up to the minimum of 8 has not been changed.

The upshot is that the API now makes it impossible to set an illegal value.
The result has been tested and was found to work.

>>>>>>>>>>>>>>>>>>>>>>>> Patch v2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
udplite: Protection against coverage value wrap-around

This patch clamps the cscov setsockopt values to a maximum of 0xFFFF.

Setsockopt values greater than 0xffff can cause an unwanted wrap-around.
Further, IPv6 jumbograms are not supported (RFC 3838, 3.5), so that values
greater than 0xffff are not even useful.

Further changes: fixed a typo in the documentation.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/udplite.txt |    2 +-
 net/ipv4/udp.c                       |    4 ++++
 2 files changed, 5 insertions(+), 1 deletion(-)

--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1325,6 +1325,8 @@ int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 			return -ENOPROTOOPT;
 		if (val != 0 && val < 8) /* Illegal coverage: use default (8) */
 			val = 8;
+		else if (val > USHORT_MAX)
+			val = USHORT_MAX;
 		up->pcslen = val;
 		up->pcflag |= UDPLITE_SEND_CC;
 		break;
@@ -1337,6 +1339,8 @@ int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 			return -ENOPROTOOPT;
 		if (val != 0 && val < 8) /* Avoid silly minimal values.       */
 			val = 8;
+		else if (val > USHORT_MAX)
+			val = USHORT_MAX;
 		up->pcrlen = val;
 		up->pcflag |= UDPLITE_RECV_CC;
 		break;
--- a/Documentation/networking/udplite.txt
+++ b/Documentation/networking/udplite.txt
@@ -148,7 +148,7 @@
         getsockopt(sockfd, SOL_SOCKET, SO_NO_CHECK, &value, ...);
 
   is meaningless (as in TCP). Packets with a zero checksum field are
-  illegal (cf. RFC 3828, sec. 3.1) will be silently discarded.
+  illegal (cf. RFC 3828, sec. 3.1) and will be silently discarded.
 
   4) Fragmentation
 
