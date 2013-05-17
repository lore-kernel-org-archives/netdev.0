From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: use ipv6_dup_options() from
 ip6_append_data()
Date: Fri, 17 May 2013 07:53:13 -0700
Message-ID: <1368802393.3301.90.camel@edumazet-glaptop>
References: <1368742990.3301.67.camel@edumazet-glaptop>
	 <1368750452.3301.74.camel@edumazet-glaptop>
	 <20130517135804.GA16069@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Neal Cardwell <ncardwell@google.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:35969 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010Ab3EQOxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 10:53:15 -0400
Received: by mail-pd0-f176.google.com with SMTP id r11so95258pdi.21
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 07:53:15 -0700 (PDT)
In-Reply-To: <20130517135804.GA16069@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Fri, 2013-05-17 at 21:58 +0800, Herbert Xu wrote:

> However, I think this function is just as buggy as the original
> code that I replaced.  If you look at the code that fills in the
> options in ip6_datagram_send_ctl, you'll find that the options do
> not lie in the memory area of the opt + opt->tot_len.  They instead
> point to data in the cmsg.
> 
> So I think we should
> 
> 1) fix ipv6_dup_options to do what I tried do but in a non-buggy way;
> 2) make the UDP path use it.
> 
> BTW, in the UDP path we also have a socket so we can just charge the
> memory to it and avoid using kmalloc at all.

OK, so I guess for stable we should use kzalloc(), and work on a cleanup
in net-next.

Thanks !

[PATCH] ipv6: fix possible crashes in ip6_cork_release()

commit 0178b695fd6b4 ("ipv6: Copy cork options in ip6_append_data")
added some code duplication and bad error recovery, leading to potential
crash in ip6_cork_release() as kfree() could be called with garbage.

use kzalloc() to make sure this wont happen.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Neal Cardwell <ncardwell@google.com>
---
 net/ipv6/ip6_output.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d2eedf1..dae1949 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1147,7 +1147,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 			if (WARN_ON(np->cork.opt))
 				return -EINVAL;
 
-			np->cork.opt = kmalloc(opt->tot_len, sk->sk_allocation);
+			np->cork.opt = kzalloc(opt->tot_len, sk->sk_allocation);
 			if (unlikely(np->cork.opt == NULL))
 				return -ENOBUFS;
 
