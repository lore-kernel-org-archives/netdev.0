From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] ipv4: tcp: remove per net tcp_sock
Date: Sat, 21 Jul 2012 10:28:51 +0200
Message-ID: <1342859331.2626.8385.camel@edumazet-glaptop>
References: <1342719243.2626.4571.camel@edumazet-glaptop>
	 <20120721170035.be1bb3aff663ecf9e81028e2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com,
	wsommerfeld@google.com
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:43467 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563Ab2GUI2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2012 04:28:55 -0400
Received: by wgbdr13 with SMTP id dr13so4325872wgb.1
        for <netdev@vger.kernel.org>; Sat, 21 Jul 2012 01:28:54 -0700 (PDT)
In-Reply-To: <20120721170035.be1bb3aff663ecf9e81028e2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sat, 2012-07-21 at 17:00 +0900, Hiroaki SHIMODA wrote:
> On Thu, 19 Jul 2012 19:34:03 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > +static DEFINE_PER_CPU(struct inet_sock, unicast_sock) = {
> > +	.sk = {
> > +		.__sk_common = {
> > +			.skc_refcnt = ATOMIC_INIT(1),
> > +		},
> > +		.sk_wmem_alloc	= ATOMIC_INIT(1),
> > +		.sk_allocation	= GFP_ATOMIC,
> > +		.sk_flags	= (1UL << SOCK_USE_WRITE_QUEUE),
> > +	},
> > +	.pmtudisc = IP_PMTUDISC_WANT,
> > +};
> 
> RST packet generated from unicast_sock have 0 TTL value.
> I think ".uc_ttl = -1" is needed in above initialization.

Good catch, thanks a lot !

[PATCH net-next] ipv4: tcp: set unicast_sock uc_ttl to -1

Set unicast_sock uc_ttl to -1 so that we select the right ttl,
instead of sending packets with a 0 ttl.

Bug added in commit be9f4a44e7d4 (ipv4: tcp: remove per net tcp_sock)

Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/ip_output.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index c528f84..665abbb 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1476,7 +1476,8 @@ static DEFINE_PER_CPU(struct inet_sock, unicast_sock) = {
 		.sk_allocation	= GFP_ATOMIC,
 		.sk_flags	= (1UL << SOCK_USE_WRITE_QUEUE),
 	},
-	.pmtudisc = IP_PMTUDISC_WANT,
+	.pmtudisc	= IP_PMTUDISC_WANT,
+	.uc_ttl		= -1,
 };
 
 void ip_send_unicast_reply(struct net *net, struct sk_buff *skb, __be32 daddr,
