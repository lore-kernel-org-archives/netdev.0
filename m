From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next] tcp: reduce cpu usage under tcp memory
 pressure when SO_SNDBUF is set
Date: Mon, 10 Aug 2015 07:47:02 -0700
Message-ID: <1439218022.1084.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150807183136.D0DF92026@prod-mail-relay10.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35325 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753150AbbHJOrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 10:47:05 -0400
Received: by pacgr6 with SMTP id gr6so28555171pac.2
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 07:47:04 -0700 (PDT)
In-Reply-To: <20150807183136.D0DF92026@prod-mail-relay10.akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-08-07 at 18:31 +0000, Jason Baron wrote:
> From: Jason Baron <jbaron@akamai.com>
> 
> When SO_SNDBUF is set and we are under tcp memory pressure, the effective write
> buffer space can be much lower than what was set using SO_SNDBUF. For example,
> we may have set the buffer to 100kb, but we may only be able to write 10kb. In
> this scenario poll()/select()/epoll(), are going to continuously return POLLOUT,
> followed by -EAGAIN from write() in a very tight loop.
> 
> Introduce sk->sk_effective_sndbuf, such that we can track the 'effective' size
> of the sndbuf, when we have a short write due to memory pressure. By using the
> sk->sk_effective_sndbuf instead of the sk->sk_sndbuf when we are under memory
> pressure, we can delay the POLLOUT until 1/3 of the buffer clears as we normally
> do. There is no issue here when SO_SNDBUF is not set, since the tcp layer will
> auto tune the sk->sndbuf.
> 
> In my testing, this brought a single threaad's cpu usage down from 100% to 1%
> while maintaining the same level of throughput when under memory pressure.
> 

I am not sure we need to grow socket for something that looks like a
flag ?

Also you add a race in sk_stream_wspace() as sk_effective_sndbuf value
can change under us.

+       if (sk->sk_effective_sndbuf)
+               return sk->sk_effective_sndbuf - sk->sk_wmem_queued;
+
