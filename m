From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: use l4 hash for locally generated
 multipath flows
Date: Thu, 29 Oct 2015 08:28:30 -0700
Message-ID: <1446132510.7476.152.camel@edumazet-glaptop2.roam.corp.google.com>
References: <006ec2edb2d592ab9b90ccc5c084ac8926e811df.1446053264.git.pabeni@redhat.com>
	 <1446129070.7476.148.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446130859.4431.17.camel@dhcp-176-88.mxp.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter =?ISO-8859-1?Q?N=F8rlund?= <pch@ordbogen.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35255 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757264AbbJ2P2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 11:28:32 -0400
Received: by pasz6 with SMTP id z6so43887340pas.2
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 08:28:31 -0700 (PDT)
In-Reply-To: <1446130859.4431.17.camel@dhcp-176-88.mxp.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-29 at 16:00 +0100, Paolo Abeni wrote:

> This patch do not add dissection code: it use the information provided
> by the available flowi4 structure. Moreover the skb is not available on
> the calling site (in __ip_route_output_key_hash) and pushing it all the
> way will require a lot of intrusive changes. Do you think it's the
> better option ?

If skb is provided, then we could use its information.

Local TCP flows now provide l4 hash in skb, and automatically shuffles
it in case of dst failures.

This provides resilience over dead paths, over variety of
aggregation-like devices (bonding being an example)

# git grep -n4 sk_rethink_txhash
include/net/sock.h-1695-{
include/net/sock.h-1696-        sk->sk_txhash = net_tx_rndhash();
include/net/sock.h-1697-}
include/net/sock.h-1698-
include/net/sock.h:1699:static inline void sk_rethink_txhash(struct sock *sk)
include/net/sock.h-1700-{
include/net/sock.h-1701-        if (sk->sk_txhash)
include/net/sock.h-1702-                sk_set_txhash(sk);
include/net/sock.h-1703-}
--
include/net/sock.h-1725-static inline void dst_negative_advice(struct sock *sk)
include/net/sock.h-1726-{
include/net/sock.h-1727-        struct dst_entry *ndst, *dst = __sk_dst_get(sk);
include/net/sock.h-1728-
include/net/sock.h:1729:        sk_rethink_txhash(sk);
include/net/sock.h-1730-
include/net/sock.h-1731-        if (dst && dst->ops->negative_advice) {
include/net/sock.h-1732-                ndst = dst->ops->negative_advice(dst);
include/net/sock.h-1733-
