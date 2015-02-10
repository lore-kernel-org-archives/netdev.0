From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel sends ICMP unreachable for GRE packets even if there is
 a listening socket
Date: Tue, 10 Feb 2015 08:18:03 -0800
Message-ID: <1423585083.28434.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150210152410.GA9225@sesse.net>
	 <1423584596.28434.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:61716 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbbBJQSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 11:18:07 -0500
Received: by mail-pa0-f41.google.com with SMTP id kx10so17973099pab.0
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 08:18:07 -0800 (PST)
In-Reply-To: <1423584596.28434.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-02-10 at 08:09 -0800, Eric Dumazet wrote:
> On Tue, 2015-02-10 at 16:24 +0100, Steinar H. Gunderson wrote:
> > [Resent from Bugzilla]
> > 
> > Hi,
> > 
> > I have a userspace GRE listener, which opens a raw socket (error handling removed):
> > 
> >         int gresock = socket(AF_INET6, SOCK_RAW, IPPROTO_GRE);
> >         bind(gresock, (sockaddr *)&my_addr, sizeof(my_addr));
> > 
> > and then select()s and recvfrom()s on it, as well as sendto().
> > 
> > This works great. I can send and receive GRE packets. However, Linux _also_
> > sends ICMPv6 unreachables when the other end sends to me. I assume this is
> > because I don't have a corresponding kernel GRE tunnel interface. (I don't use
> > the kernel GRE because I want, among others, stronger reordering functionality
> > and possibly error correction, which is not in any standard.)
> > 
> > Can this be suppressed when I have such a socket giong? ip6tables -A OUTPUT can
> > stop them, but it seems very hacky and kludgy.
> 
> Thats because you loaded ip6_gre maybe ?

Not clear why we even bother sending ICMP in ipv6, while we do nothing
in ipv4 similar case

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index bc28b7d42a6dab05abee80d4fa84c102d92ca91f..8ff364b93bc2909253a6a0ef7268fc2dfb92c77c 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -572,7 +572,6 @@ static int ip6gre_rcv(struct sk_buff *skb)
 
 		return 0;
 	}
-	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
 
 drop:
 	kfree_skb(skb);
