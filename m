From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [udplite] [Patch 1/1] [BUG-FIX]: Avoid u16 checksum coverage
	wrap-around
Date: Mon, 30 Jun 2008 12:54:27 +0100
Message-ID: <20080630115427.GA8416@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:34872 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755277AbYF3Lyf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2008 07:54:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found this out while writing documentation: there is no protection
against wrap-around of the setsockopt() argument. Patch applies to
net-2.6 and has been tested to protect the given ranges.

Gerrit
-----------------------> Patch <---------------------------------------
udplite: Protection against coverage value wrap-around

The UDP-Lite (sender/receiver) checksum coverages use u16, while the
corresponding setsocktopt() argument is `int'. 

When specifying a checksum coverage greater than 0xFFFF, this can yield
 * illegal checksum coverage, due to wrap-around (65537 <= val <= 65543);
 * unexpected results (other values >= 0xFFFF).
Furthermore, UDP-Litev6 jumbogramps are not supported (RFC 3828, 3.5).

This patch now explicitly disallows invalid checksum coverage values.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 Documentation/networking/udplite.txt |   12 ++++--------
 include/net/udplite.h                |    6 ++++++
 net/ipv4/udp.c                       |    8 ++++----
 3 files changed, 14 insertions(+), 12 deletions(-)

--- a/include/net/udplite.h
+++ b/include/net/udplite.h
@@ -29,6 +29,12 @@ static inline int udplite_sk_init(struct sock *sk)
 	return 0;
 }
 
+/* Values between 1..7 are invalid. IPv6 jumbograms are not supported (3.5) */
+static inline bool udplite_valid_cscov(const u32 cscov)
+{
+	return cscov == 0 || (cscov >= 8 && cscov <= USHORT_MAX);
+}
+
 /*
  * 	Checksumming routines
  */
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1317,8 +1317,8 @@ int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 	case UDPLITE_SEND_CSCOV:
 		if (!is_udplite)         /* Disable the option on UDP sockets */
 			return -ENOPROTOOPT;
-		if (val != 0 && val < 8) /* Illegal coverage: use default (8) */
-			val = 8;
+		if (!udplite_valid_cscov(val))
+			return -EINVAL;
 		up->pcslen = val;
 		up->pcflag |= UDPLITE_SEND_CC;
 		break;
@@ -1329,8 +1329,8 @@ int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 	case UDPLITE_RECV_CSCOV:
 		if (!is_udplite)         /* Disable the option on UDP sockets */
 			return -ENOPROTOOPT;
-		if (val != 0 && val < 8) /* Avoid silly minimal values.       */
-			val = 8;
+		if (!udplite_valid_cscov(val))
+			return -EINVAL;
 		up->pcrlen = val;
 		up->pcflag |= UDPLITE_RECV_CC;
 		break;
--- a/Documentation/networking/udplite.txt
+++ b/Documentation/networking/udplite.txt
@@ -118,10 +118,9 @@
 
   If the sender specifies a value of 0 as coverage length, the module
   assumes full coverage, transmits a packet with coverage length of 0
-  and according checksum.  If the sender specifies a coverage < 8 and
-  different from 0, the kernel assumes 8 as default value.  Finally,
-  if the specified coverage length exceeds the packet length, the packet
-  length is used instead as coverage length.
+  and according checksum. Values between 1..7 and greater than 65535 are
+  invalid. Finally, if the specified coverage length exceeds the packet 
+  length, the packet length is used instead as coverage length.
 
   2) Receiver Socket Options
 
@@ -130,9 +129,6 @@
   always wants the whole of the packet covered. In this case, all
   partially covered packets are dropped and an error is logged.
 
-  It is not possible to specify illegal values (<0 and <8); in these
-  cases the default of 8 is assumed.
-
   All packets arriving with a coverage value less than the specified
   threshold are discarded, these events are also logged.
 
@@ -148,7 +144,7 @@
         getsockopt(sockfd, SOL_SOCKET, SO_NO_CHECK, &value, ...);
 
   is meaningless (as in TCP). Packets with a zero checksum field are
-  illegal (cf. RFC 3828, sec. 3.1) will be silently discarded.
+  illegal (cf. RFC 3828, sec. 3.1) and will be silently discarded.
 
   4) Fragmentation
 
-- 
