From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [patch] ip_local_port_range sysctl has annoying default
Date: Mon, 14 May 2007 10:08:43 -0700
Message-ID: <4648979B.3080000@hp.com>
References: <20070512124039.2155c593@chirp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@coreworks.de
To: Mark Glines <mark@glines.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:37714 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755308AbXENRIu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 13:08:50 -0400
In-Reply-To: <20070512124039.2155c593@chirp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Glines wrote:
> (resending to netdev and copying maintainers, at Alan Cox's suggestion.  Thanks Alan!)
> On Sat, 12 May 2007 12:12:38 -0700 "H. Peter Anvin" <hpa@zytor.com> wrote:
> 
> 
>>Mark Glines wrote:
>>
>>>Well, in that case, is there anything wrong with just using the
>>>range IANA recommends, in all cases?
>>>
>>
>>I think the IANA range is considered too small in most cases; I
>>suspect there is also a feeling that "there be dragons" near the very
>>top.

About the only dragons which come to mind would be the very old, decrepit, 
barely able to puff wisps of steam let alone fire, dragons with the high-order 
bit set that would be misinterpreted by those treating port numbers as a short 
rather than an unsigned short.

> Ok, thanks for the explanation.  Sounds like we're using high port
> numbers in the "spirit" of the IANA recommendation, without using
> their actual numbers.
> 
> I still haven't gotten an answer to this: is there a performance
> issue (or memory usage or security or something) with using the same
> port range in all cases, even on memory-constrained systems (or whatever
> it is that determines the bind hash size)?  And if there is, can't we
> *still* use big numbers, even if the range isn't as wide?
> 
> If there's no reason not to (security, resource consumption,
> whatever), I think it would be an improvement to use high, out of the
> way port numbering in all cases.  (Especially since the kernel already
> does this on most of my machines, anyway.)
> 
> There was a comment in there about how 32768-61000 should be used on
> high-use systems; is there a drawback to just using this range
> *everywhere*?  (It's already the default in non-memory-constrained
> cases, because of what tcp_init() was doing.)

I would think that a "high use system" would probably want even more than 
32768-61000.  Where the size of the anonymous/ephemeral port space seems to 
come-up most (in my  experience thusfar) often is in situations where someone is 
churning through lots of connections at a time.  They probably want something 
more like 5000-65535.

Frankly, such applications probably aught (again IMO) to be making explicit 
bind() calls to pick local port numbers in that range just as decades-old web 
server benchmarks do.

One nice thing about 49152-65535 is that if you have an application with a 
busted loop, it will "only" absorb 16K ports before it starts to fail.  Still 
and all not necessarily a big deal

Oddly enough, it seems that on a system with a 2.6.21.1 kernel, the 32768-61000 
is already there:

hpcpc102:~# sysctl -a | grep port
error: permission denied on key 'net.ipv4.route.flush'
net.ipv4.ip_local_port_range = 32768    61000


I cannot imagine there is anything "safer" about 61000 than 63355.  They both 
have that "sign-bit" set.

While it is "security through obscurity" having the same default port range as 
other platforms would I suppose make it just a little bit more difficult for 
fingerprinting.

random thoughts,

rick jones

Solaris:
# ndd /dev/tcp tcp_smallest_anon_port
32768
# ndd /dev/tcp tcp_largest_anon_port
65535
# uname -a
SunOS competitive10 5.10 Generic_118833-36 sun4v sparc SUNW,Sun-Fire-T200

HP-UX:

# ndd /dev/tcp tcp_smallest_anon_port
49152
# ndd /dev/tcp tcp_largest_anon_port
65535
# uname -a
HP-UX loiter B.11.23 U ia64 4283463096 unlimited-user license

no idea about AIX or BSD or Windows...


> Thanks,
> 
> Signed-off-by: Mark Glines <mark@glines.org>
> 
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> index 43fb160..12d9ddc 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -29,12 +29,7 @@ const char inet_csk_timer_bug_msg[] = "inet_csk BUG:
> unknown timer value\n";
>  EXPORT_SYMBOL(inet_csk_timer_bug_msg);
>  #endif
>  
> -/*
> - * This array holds the first and last local port number.
> - * For high-usage systems, use sysctl to change this to
> - * 32768-61000
> - */
> -int sysctl_local_port_range[2] = { 1024, 4999 };
> +int sysctl_local_port_range[2] = { 32768, 61000 };
>  
>  int inet_csk_bind_conflict(const struct sock *sk,
>  			   const struct inet_bind_bucket *tb)
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index bd4c295..33ef0e7 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2465,13 +2465,10 @@ void __init tcp_init(void)
>  			order++)
>  		;
>  	if (order >= 4) {
> -		sysctl_local_port_range[0] = 32768;
> -		sysctl_local_port_range[1] = 61000;
>  		tcp_death_row.sysctl_max_tw_buckets = 180000;
>  		sysctl_tcp_max_orphans = 4096 << (order - 4);
>  		sysctl_max_syn_backlog = 1024;
>  	} else if (order < 3) {
> -		sysctl_local_port_range[0] = 1024 * (3 - order);
>  		tcp_death_row.sysctl_max_tw_buckets >>= (3 - order);
>  		sysctl_tcp_max_orphans >>= (3 - order);
>  		sysctl_max_syn_backlog = 128;
> 
> 
> 
> Mark
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

