From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v2] udp: Resolve NULL pointer dereference over
 flow-based vxlan device
Date: Thu, 12 May 2016 13:55:53 -0700
Message-ID: <1463086553.23934.165.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160512022306.3691.40769.stgit@localhost.localdomain>
	 <20160512195003.26694.17950.stgit@localhost.localdomain>
	 <1463082953.23934.160.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAKgT0Ud_q7j0MT4oH_wFEw8vsSLZAc3jZbvcjeqZbfSe1gyDUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Jiri Benc <jbenc@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33048 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108AbcELUzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 16:55:55 -0400
Received: by mail-pf0-f195.google.com with SMTP id y7so7507670pfb.0
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 13:55:55 -0700 (PDT)
In-Reply-To: <CAKgT0Ud_q7j0MT4oH_wFEw8vsSLZAc3jZbvcjeqZbfSe1gyDUQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-12 at 13:27 -0700, Alexander Duyck wrote:

> I'm assuming this was using skb_dst(skb)->dev in order to allow for
> use of this function by other callers since the original function
> __udp4_lib_lookup_skb was using that.  If we change this then it
> reduces the likelihood of the code being reusable by other callers.
> In such a case I would probably want to go through and also rename the
> functions to make sure they are tagged as being GRO specific.
> 

__udp4_lib_lookup_skb() should use skb->dev as well,
or get the net pointer from its caller.

It is called from __udp4_lib_rcv() and this one simply does :

struct net *net = dev_net(skb->dev);

So for consistency (and small performance gain) I would suggest :

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f67f52ba4809..d9006f2d28eb 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -604,7 +604,7 @@ static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 {
        const struct iphdr *iph = ip_hdr(skb);
 
-       return __udp4_lib_lookup(dev_net(skb_dst(skb)->dev), iph->saddr, sport,
+       return __udp4_lib_lookup(dev_net(skb->dev), iph->saddr, sport,
                                 iph->daddr, dport, inet_iif(skb),
                                 udptable, skb);
 }
