From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.24-rc5-mm1
Date: Fri, 14 Dec 2007 10:08:07 +0800
Message-ID: <20071214020807.GA12426@gondor.apana.org.au>
References: <20071213024050.7d6e5f3e.akpm@linux-foundation.org> <47613F18.6080601@bull.net> <4761494E.1050704@bull.net> <20071213.094554.136920553.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: benjamin.thery@bull.net, pierre.peiffer@bull.net,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3048 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760427AbXLNCIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 21:08:42 -0500
Content-Disposition: inline
In-Reply-To: <20071213.094554.136920553.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 13, 2007 at 09:45:54AM -0800, David Miller wrote:
> From: Benjamin Thery <benjamin.thery@bull.net>
> Date: Thu, 13 Dec 2007 16:01:34 +0100
> 
> > The problem comes from the new macro UDPX_INC_STATS_BH introduced
> > by Herbert, which was a nice addition to increment the correct 
> > UDP MIB depending on the socket family, but unfortunately 
> > the use of this macro from kernel code (I mean code not compiled 
> > as module) requires that IPv6 is also compiled in kernel 
> > (CONFIG_IPv6=y) in order to have udp_stats_in6 defined at link 
> > time.
> 
> Herbert, please take a look at this, thanks!

OK, let's just move udp_stats_in6 into net/ipv4/udp.c.  It's only
40 bytes or less.

[UDP]: Move udp_stats_in6 into net/ipv4/udp.c

Now that external users may increment the counters directly, we need to
ensure that udp_stats_in6 is always available.  Otherwise we'd either
have to requrie the external users to be built as modules or ipv6 to be
built-in.

This isn't too bad because udp_stats_in6 is just a pair of pointers plus
an EXPORT, e.g., just 40 (16 + 24) bytes on x86-64.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 9ed6393..3d60215 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -112,6 +112,9 @@
 DEFINE_SNMP_STAT(struct udp_mib, udp_statistics) __read_mostly;
 EXPORT_SYMBOL(udp_statistics);
 
+DEFINE_SNMP_STAT(struct udp_mib, udp_stats_in6) __read_mostly;
+EXPORT_SYMBOL(udp_stats_in6);
+
 struct hlist_head udp_hash[UDP_HTABLE_SIZE];
 DEFINE_RWLOCK(udp_hash_lock);
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 8cbdcc9..7db5a9d 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -51,9 +51,6 @@
 #include <linux/seq_file.h>
 #include "udp_impl.h"
 
-DEFINE_SNMP_STAT(struct udp_mib, udp_stats_in6) __read_mostly;
-EXPORT_SYMBOL(udp_stats_in6);
-
 static inline int udp_v6_get_port(struct sock *sk, unsigned short snum)
 {
 	return udp_get_port(sk, snum, ipv6_rcv_saddr_equal);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
