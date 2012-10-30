From: Steven Barth <steven@midlink.org>
Subject: Re: IPV6_PKTINFO seems not to be honored correctly by RAW-sockets
Date: Tue, 30 Oct 2012 17:52:39 +0100
Message-ID: <509005D7.8050106@midlink.org>
References: <508F969C.9080300@midlink.org> <1351593768.12280.779.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chi.subsignal.org ([188.40.166.11]:33576 "EHLO
	chi.subsignal.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964817Ab2J3Qwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 12:52:41 -0400
In-Reply-To: <1351593768.12280.779.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your quick reply.

I just saw that there is also a IPV6_PKTINFO setsockopt-option which was 
probably what your patch affects.

However what I actually meant was the IPV6_PKTINFO control message for 
sendmsg. Sorry for being ambiguous here. I tried to trace the bug down a 
bit further with my unfortunately very limited kernel debugging skills.

It seems that the destined interface is correctly set in fl6->flowi6_oif 
also still when it reaches ip6_push_pending_frames in ip6_output.c so I 
guess it must be lost some time later but I couldn't find out exactly 
where yet. I'll try to find more information later if I can find some 
free time.


Regards,

Steven



On 30.10.2012 11:42, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> On Tue, 2012-10-30 at 09:58 +0100, Steven Barth wrote:
>> Hi,
>>
>> I recently noticed that there might be an unexpected behavior in the
>> handling of IPV6_PKTINFO for RAW-sockets. It seems that the given
>> destination interface is ignored.
>>
>> I just reproduced this on 3.7.0-rc3 vanilla but some quick tests with
>> 2.6.32 and 3.5 distro-kernels on different machines showed the same.
>>
>> I've noticed this first in my own software but I could also reproduce it
>> easily with standard tools like ping6 from iputils:
>>
>> Have 2 network interfaces with (global) IPv6-addresses assigned (e.g.
>> eth0 with fd00::1/64 and eth1 with fd01::1/64) and do a ping6 -I eth1
>> fd00::1 (ping6 from iputils uses IPV6_PKTINFO internally).
>>
>> For me the result was that even though I set the interface to eth1 the
>> ECHO was still send to eth0.
>>
>> Also (although probably unrelated) forwarding for IPv6 was disabled.
>>
>> If I try something similar with IPv4 and ping -I ... the ECHO doesn't go
>> out on eth0 but - as expected - on eth1.
>>
>> However if I use traceroute(6) with -I (ICMP-traceroute) and the -i
>> option to determine the interface, packages seem to be sent through the
>> expected interface. Internally it seems that traceroute(6) uses
>> SO_BINDTODEVICE instead of IP(V6)_PKTINFO which seems to work.
>>
>> So it seems there might be something wrong with IPV6_PKTINFO or is this
>> expected behavior?
>>
>
> I believe its not expected behavior.
>
> Is the following patch fixing it ?
>
> Thanks
>
> [PATCH] ipv6: raw: honor IPV6_PKTINFO
>
> Let ping6 -I interface works correctly.
>
> If socket was not bound to a given interface, check if IPV6_PKTINFO was
> issued on this socket.
>
> Reported-by: Steven Barth <steven@midlink.org>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
> index d8e95c7..363ee65 100644
> --- a/net/ipv6/raw.c
> +++ b/net/ipv6/raw.c
> @@ -814,8 +814,8 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
>   		fl6.flowlabel = np->flow_label;
>   	}
>
> -	if (fl6.flowi6_oif == 0)
> -		fl6.flowi6_oif = sk->sk_bound_dev_if;
> +	if (!fl6.flowi6_oif)
> +		fl6.flowi6_oif = sk->sk_bound_dev_if ?: np->sticky_pktinfo.ipi6_ifindex;
>
>   	if (msg->msg_controllen) {
>   		opt = &opt_space;
>
>
