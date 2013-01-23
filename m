From: Yannick Koehler <yannick@koehler.name>
Subject: Re: Unix Socket buffer attribution
Date: Wed, 23 Jan 2013 11:41:16 -0500
Message-ID: <CAJ4BwwFYKYOJoP34cGqWyE_AzxMwDNqFG-XDjLB6ZdO4nQmY4w@mail.gmail.com>
References: <CAJ4BwwFZo=ktoNBpw14yxyvR1QPQ_xVzKRs=R7qv03g1uwn8pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38965 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752976Ab3AWQlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 11:41:17 -0500
Received: by mail-wi0-f177.google.com with SMTP id hm2so907027wib.4
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 08:41:16 -0800 (PST)
In-Reply-To: <CAJ4BwwFZo=ktoNBpw14yxyvR1QPQ_xVzKRs=R7qv03g1uwn8pg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did some more research, I found out that netlink and
sock_queue_err_skb does the same trick that I claim to be missing
under the net/unix/af_unix.c.  After adding the code, I got a problem
since af_unix.c "_recvmsg()" functions assume that the skb->sk is
holding the peer socket not the current one related to the receive
skb.  It extract the sun_path name from it.  Since with UDP each
packet may have a different peer, the only solution I found was to use
the skb control block to hold the peer name.  The problem is that this
cb member is 48 bytes in length and sun_path is 108 bytes in size.  So
I had to increase it from 48 to 160 bytes.

This obviously increase the cost of an SKB struct, so I do not really
like this solution. But at least it seems to prove my point and now,
with this I can have my clients working except the one mis-behaving.
I am attaching a patch.

I also saw this thread that would be somehow related:

http://www.mail-archive.com/netdev@vger.kernel.org/msg20195.html

Basically since we now count the buffer size into the socket who
receives it we can safely use this check instead of looking at the
receive queue size:

   if (atomic_read(&other->sk_rmem_alloc) + skb->truesize >=
(unsigned)other->sk_rcvbuf) {

So anyway I sent my patch, and I am awaiting for comments on how to improve it.

--
Yannick Koehler
