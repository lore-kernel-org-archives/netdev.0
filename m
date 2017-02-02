From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] loopback: clear pfmemalloc on outgoing skb's
Date: Thu, 02 Feb 2017 09:06:29 -0800
Message-ID: <1486055189.13103.53.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485983078-2372-1-git-send-email-jbacik@fb.com>
         <1485992285.6360.168.camel@edumazet-glaptop3.roam.corp.google.com>
         <1486050971.29885.24.camel@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        "David S . Miller" <davem@davemloft.net>
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35188 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752134AbdBBRGm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 12:06:42 -0500
Received: by mail-pg0-f67.google.com with SMTP id 204so2299000pge.2
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 09:06:42 -0800 (PST)
In-Reply-To: <1486050971.29885.24.camel@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-02 at 10:56 -0500, Josef Bacik wrote:

> The problem is we set skb->pfmemalloc a bunch of different places, such
> as __skb_fill_page_desc, which appears to be used in both the RX and TX
> path, so we can't just kill it there.  Do we want to go through and
> audit each one, provide a way for callers to indicate if we care about
> pfmemalloc and solve this problem that way?  I feel like that's more
> likely to bite us in the ass down the line, and somebody who doesn't
> know the context is going to come along and change it and regress us to
> the current situation.  The only place this is a problem is with
> loopback, and my change is contained to this one weird case.  Thanks,

I mentioned this in another mail :

Same issue will happen with veth, or any kind of driver allowing skb
being given back to the stack in RX.

So your patch on loopback is not the definitive patch.

We probably should clear pf->memalloc directly in TCP write function.

Note that I clear it on the clone, not in original skb.

(It might be very useful to keep skb->pfmemalloc on original skbs in
write queue, at least for debugging purposes)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8ce50dc3ab8cac821b8a2c3e0d31f0aa42f5c9d5..010280f1592d3bd195315882c364bdbbd4a1c2ec 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -944,6 +944,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
                        skb = skb_clone(skb, gfp_mask);
                if (unlikely(!skb))
                        return -ENOBUFS;
+               skb->pfmemalloc = 0;
        }
 
        inet = inet_sk(sk);
