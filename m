From: John Dykstra <john.dykstra1@gmail.com>
Subject: [PATCH] tcp:  Use correct peer adr when copying MD5 keys (WAS:
	[PATCHv2] tcp: Fix MD5 signature checking on IPv4 mapped sockets)
Date: Fri, 17 Jul 2009 19:23:22 +0000
Message-ID: <1247858602.8509.7.camel@Maple>
References: <1247756691.7627.5.camel@Maple>
	 <20090716113652.65dd1c8d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Adam Langley <agl@imperialviolet.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f185.google.com ([209.85.216.185]:41717 "EHLO
	mail-px0-f185.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027AbZGQTX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 15:23:26 -0400
Received: by pxi15 with SMTP id 15so718736pxi.33
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 12:23:26 -0700 (PDT)
In-Reply-To: <20090716113652.65dd1c8d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-07-16 at 11:36 -0700, Stephen Hemminger wrote:
> On Thu, 16 Jul 2009 10:04:51 -0500
> John Dykstra <john.dykstra1@gmail.com> wrote:
> 
> > This revision to the patch removes a misplaced
> > blank line.
> > 
> > ---
> > Fix MD5 signature checking so that an IPv4 active open
> > to an IPv6 socket can succeed.  In particular, use the
> > correct address family's signature generation function
> > for the SYN/ACK.
> > 
> > Reported-by:   Stephen Hemminger <shemminger@vyatta.com>
> > Signed-off-by: John Dykstra <john.dykstra1@gmail.com>
> 
> This fixes the syn-ack, but data does not flow.

The following patch is _in addition_ to the one I sent out yesterday.
Since they are independent, and fix different bugs, I'm leaving them
separate.

I guess it's clear not many people are running authenticated BGP
sessions on Linux...

---

[PATCH] tcp:  Use correct peer adr when copying MD5 keys

When the TCP connection handshake completes on the passive
side, a variety of state must be set up in the "child" sock,
including the key if MD5 authentication is being used.  Fix TCP
for both address families to label the key with the peer's
destination address, rather than the address from the listening
sock, which is usually the wildcard.

Reported-by:   Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: John Dykstra <john.dykstra1@gmail.com>
---
 net/ipv4/tcp_ipv4.c |    2 +-
 net/ipv6/tcp_ipv6.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7c107eb..6d88219 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1374,7 +1374,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		 */
 		char *newkey = kmemdup(key->key, key->keylen, GFP_ATOMIC);
 		if (newkey != NULL)
-			tcp_v4_md5_do_add(newsk, inet_sk(sk)->daddr,
+			tcp_v4_md5_do_add(newsk, newinet->daddr,
 					  newkey, key->keylen);
 		newsk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ae3d657..d849dd5 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1442,7 +1442,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		 */
 		char *newkey = kmemdup(key->key, key->keylen, GFP_ATOMIC);
 		if (newkey != NULL)
-			tcp_v6_md5_do_add(newsk, &inet6_sk(sk)->daddr,
+			tcp_v6_md5_do_add(newsk, &newnp->daddr,
 					  newkey, key->keylen);
 	}
 #endif
-- 
1.5.4.3



