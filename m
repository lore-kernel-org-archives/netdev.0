From: Jason Baron <jbaron@akamai.com>
Subject: Re: [RFC PATCH net-next] tcp: reduce cpu usage under tcp memory pressure
 when SO_SNDBUF is set
Date: Mon, 10 Aug 2015 13:29:15 -0400
Message-ID: <55C8DF6B.9080509@akamai.com>
References: <20150807183136.D0DF92026@prod-mail-relay10.akamai.com> <1439218022.1084.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a23-79-238-175.deploy.static.akamaitechnologies.com ([23.79.238.175]:43025
	"EHLO prod-mail-xrelay07.akamai.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753820AbbHJR3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 13:29:17 -0400
In-Reply-To: <1439218022.1084.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/10/2015 10:47 AM, Eric Dumazet wrote:
> On Fri, 2015-08-07 at 18:31 +0000, Jason Baron wrote:
>> From: Jason Baron <jbaron@akamai.com>
>>
>> When SO_SNDBUF is set and we are under tcp memory pressure, the effective write
>> buffer space can be much lower than what was set using SO_SNDBUF. For example,
>> we may have set the buffer to 100kb, but we may only be able to write 10kb. In
>> this scenario poll()/select()/epoll(), are going to continuously return POLLOUT,
>> followed by -EAGAIN from write() in a very tight loop.
>>
>> Introduce sk->sk_effective_sndbuf, such that we can track the 'effective' size
>> of the sndbuf, when we have a short write due to memory pressure. By using the
>> sk->sk_effective_sndbuf instead of the sk->sk_sndbuf when we are under memory
>> pressure, we can delay the POLLOUT until 1/3 of the buffer clears as we normally
>> do. There is no issue here when SO_SNDBUF is not set, since the tcp layer will
>> auto tune the sk->sndbuf.
>>
>> In my testing, this brought a single threaad's cpu usage down from 100% to 1%
>> while maintaining the same level of throughput when under memory pressure.
>>
> 
> I am not sure we need to grow socket for something that looks like a
> flag ?
>


So I added a new field because I needed to store the new 'effective'
sndbuf somewhere and then restore the original value that was set via
SO_SNDBUF. So its really b/c of SO_SNDBUF. We could perhaps use the fact
that we are in memory pressure to signal wakeups differently, but I'm
not sure exactly how.


> Also you add a race in sk_stream_wspace() as sk_effective_sndbuf value
> can change under us.
> 
> +       if (sk->sk_effective_sndbuf)
> +               return sk->sk_effective_sndbuf - sk->sk_wmem_queued;
> +
> 
> 
> 
> 

thanks. better?

--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -798,8 +798,10 @@ static inline int sk_stream_min_wspace(const struct
sock *sk)

 static inline int sk_stream_wspace(const struct sock *sk)
 {
-       if (sk->sk_effective_sndbuf)
-               return sk->sk_effective_sndbuf - sk->sk_wmem_queued;
+       int effective_sndbuf = sk->sk_effective_sndbuf;
+
+       if (effective_sndbuf)
+               return effective_sndbuf - sk->sk_wmem_queued;

        return sk->sk_sndbuf - sk->sk_wmem_queued;
 }


Thanks,

-Jason
