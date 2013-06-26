From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: oops in udpv6_sendmsg
Date: Wed, 26 Jun 2013 04:15:07 -0700
Message-ID: <1372245307.3301.171.camel@edumazet-glaptop>
References: <20130329184006.GA23893@redhat.com>
	 <1364582958.5113.49.camel@edumazet-glaptop>
	 <1364865839.5113.165.camel@edumazet-glaptop>
	 <20130417010213.GA9027@redhat.com>
	 <1366164132.3205.21.camel@edumazet-glaptop>
	 <20130417141138.GA17648@redhat.com>
	 <1366208856.3205.23.camel@edumazet-glaptop>
	 <1366214751.3205.29.camel@edumazet-glaptop>
	 <20130625212851.GA20081@order.stressinduktion.org>
	 <1372238557.3301.145.camel@edumazet-glaptop>
	 <1372238996.3301.149.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:38430 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791Ab3FZLPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 07:15:04 -0400
Received: by mail-ee0-f41.google.com with SMTP id d17so7313893eek.14
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 04:15:02 -0700 (PDT)
In-Reply-To: <1372238996.3301.149.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Wed, 2013-06-26 at 02:29 -0700, Eric Dumazet wrote:
> On Wed, 2013-06-26 at 02:22 -0700, Eric Dumazet wrote:
> > ip6_rt_put
> > 
> > Oh well...
> > 
> > It sounds we mix ipv4/ipv6 dst on an IPV6 socket.
> > 
> > So an IPV4 actor thinks he got a "struct rtable" pointer and messes
> > critical fields which overlay struct rt6_info components, for example
> > rt6i_node
> > 
> > rt6_inode  shares the same storage with : 
> > 
> > rt_type/rt_is_input/rt_uses_gateway/rt_iif
> > 
> > In my case, rt_iif is 0
> > 
> > CC Steffen Klassert, because of commit
> > 8141ed9fcedb278f4a3a78680591bef1e55f75fb
> > ("ipv4: Add a socket release callback for datagram sockets")
> 
> ip6_sk_dst_lookup_flow()/ip6_sk_dst_check() look buggy, they assume the
> socket dst is an IPv6 one.
> 
> But its not true if ip4_datagram_connect() was called before.

Following patch fixes the problem for me :

[PATCH] ipv6: ip6_sk_dst_check() must not assume ipv6 dst

It's possible to use AF_INET6 sockets and to connect to an IPv4
destination. After this, socket dst cache is a pointer to a rtable,
not rt6_info.

ip6_sk_dst_check() should check the socket dst cache is IPv6, or else
various corruptions/crashes can happen.

Dave Jones can reproduce immediate crash with 
trinity -q -l off -n -c sendmsg -c connect

With help from Hannes Frederic Sowa

Reported-by: Dave Jones <davej@redhat.com>
Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/ip6_output.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 95703ba..d5d20cd 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -821,11 +821,17 @@ static struct dst_entry *ip6_sk_dst_check(struct sock *sk,
 					  const struct flowi6 *fl6)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct rt6_info *rt = (struct rt6_info *)dst;
+	struct rt6_info *rt;
 
 	if (!dst)
 		goto out;
 
+	if (dst->ops->family != AF_INET6) {
+		dst_release(dst);
+		return NULL;
+	}
+
+	rt = (struct rt6_info *)dst;
 	/* Yes, checking route validity in not connected
 	 * case is not very simple. Take into account,
 	 * that we do not support routing by source, TOS,
