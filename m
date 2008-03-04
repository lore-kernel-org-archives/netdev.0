From: David Miller <davem@davemloft.net>
Subject: Re: inet established hash question
Date: Tue, 04 Mar 2008 14:24:13 -0800 (PST)
Message-ID: <20080304.142413.254346205.davem@davemloft.net>
References: <47CDA6E4.1050505@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opurdila@ixiacom.com
To: cratiu@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34201
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754249AbYCDWYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 17:24:19 -0500
In-Reply-To: <47CDA6E4.1050505@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cosmin Ratiu <cratiu@ixiacom.com>
Date: Tue, 04 Mar 2008 21:45:40 +0200

> My question is whether this is a good thing to do or not, as I am
> not so good with hash functions, so I can't say for sure if we won't
> run into a collision with a different setup.

It makes perfect sense, I'll add the following patch to
the tree, thanks!

[TCP]: Improve ipv4 established hash function.

If all of the entropy is in the local and foreign addresses,
but xor'ing together would cancel out that entropy, the
current hash performs poorly.

Suggested by Cosmin Ratiu:

	Basically, the situation is as follows: There is a client
	machine and a server machine. Both create 15000 virtual
	interfaces, open up a socket for each pair of interfaces and
	do SIP traffic. By profiling I noticed that there is a lot of
	time spent walking the established hash chains with this
	particular setup.

	The addresses were distributed like this: client interfaces
	were 198.18.0.1/16 with increments of 1 and server interfaces
	were 198.18.128.1/16 with increments of 1. As I said, there
	were 15000 interfaces. Source and destination ports were 5060
	for each connection.  So in this case, ports don't matter for
	hashing purposes, and the bits from the address pairs used
	cancel each other, meaning there are no differences in the
	whole lot of pairs, so they all end up in the same hash chain.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 70013c5..89cd011 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -175,7 +175,8 @@ extern void build_ehash_secret(void);
 static inline unsigned int inet_ehashfn(const __be32 laddr, const __u16 lport,
 					const __be32 faddr, const __be16 fport)
 {
-	return jhash_2words((__force __u32) laddr ^ (__force __u32) faddr,
+	return jhash_3words((__force __u32) laddr,
+			    (__force __u32) faddr,
 			    ((__u32) lport) << 16 | (__force __u32)fport,
 			    inet_ehash_secret);
 }
